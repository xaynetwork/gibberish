/// List top rated projects
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:gibberish/detection.dart';
import 'package:gibberish/language.dart';
import 'package:gibberish/trigram_utils.dart';
import 'package:gibberish/utils.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

// the pronunciation block that wikipedia uses: [ˈiːlɒn ˈɹiːv ˈmʌsk]
final pronunciation = RegExp(r"\[.+\]");
final quote = RegExp(r"\[\d+\]");
final curlies = RegExp(r"{.*}");
final template = RegExp(r"\.[a-z-]+");

extension on Language {
  String get project {
    switch (this) {
      case Language.eng:
        return 'en.wikipedia.org';
      case Language.deu:
        return 'de.wikipedia.org';
      case Language.dut:
        return 'nl.wikipedia.org';
      case Language.fre:
        return 'fr.wikipedia.org';
      case Language.pol:
        return 'pl.wikipedia.org';
      case Language.esp:
        return 'es.wikipedia.org';
    }
  }

  String get topviews => 'assets/topviews/${name}.json';
}

typedef GetArticle = Future<String?> Function(String title, Language language);

Future<String?> getArticleExtract(String name, Language languages) async {
  final response = await http.get(Uri.parse(
      'https://${languages.project}/w/api.php?action=query&prop=extracts&exsentences=10&exlimit=1&titles=$name&explaintext=1&formatversion=2&format=json'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['query']['pages'][0]['extract'];
  } else {
    return null;
  }
}

Future<String?> getArticleContent(String name, Language language) async {
  final response = await http.get(Uri.parse(
      'https://${language.project}/w/api.php?action=parse&page=$name&prop=text&format=json'));
  if (response.statusCode == 200) {
    final html = parse(jsonDecode(response.body)['parse']['text']['*']);
    final list = html.querySelectorAll('p');
    final text =
        list.map((e) => e.text).reduce((value, element) => element + value);
    return text
        .replaceAll(quote, '')
        .replaceAll(template, '')
        .replaceAll(curlies, '');
  } else {
    return null;
  }
}

class Count implements Comparable<Count> {
  final int total;
  final int count;

  double get ratio => total == 0 ? .0 : count / total;

  Count(this.total, this.count);

  Count operator +(Count other) =>
      Count(total + other.total, count + other.count);

  @override
  int compareTo(Count other) => ratio.compareTo(other.ratio);
}

class CountResult {
  final int totals;
  final Map<String, int> counts;

  CountResult(this.totals, this.counts);
}

void main() async {
  await Future.wait(training());
}

Iterable<Future> training() {
  // createArticleBlob(Language.french, getArticleContent);

  return Language.values
      .map((e) => generateDict(e, gramSize: kGramSize, dictSize: kDictSize));
}

Future<void> generateDict(Language language,
    {required int gramSize, int dictSize = 1000}) async {
  final raw = jsonDecode(
      await File('assets/blobs/${language.name}.json').readAsString());
  trainFromWikipedia(
    language,
    (title, lang) async => raw[title],
    gramSize: gramSize,
    dictSize: dictSize,
  ).then((value) => writeToFile(
        'const ${language.name}Dictionary = $value;',
        'lib/results/${language.name}.dart',
      ));
}

Future<void> writeToFile(String text, String fileName) async =>
    await File(fileName).writeAsString(text);

Future<void> createArticleBlob(Language language, GetArticle getArticle) async {
  final articles = <Future<MapEntry<String, String>>>[];

  final topArticles = jsonDecode(await File(language.topviews).readAsString());

  for (var entry in topArticles.take(100)) {
    final title = entry['article'];
    articles.add(getArticle(title, language)
        .then((value) => MapEntry(title, value ?? '')));
  }
  final res = await Future.wait(articles);
  print(jsonEncode(Map.fromEntries(res)));
}

Future<void> trainFromFile(Language language, String fileName,
    {required int gramSize}) async {
  final totals = <String, int>{};

  final totalWords = await processArticle(
      () => File(fileName).readAsString(), totals,
      gramSize: gramSize);

  var list = totals.entries.toList();
  list.sort((a, b) => b.value.compareTo(a.value));
  print(jsonEncode({
    'language': language.name,
    'totals': totalWords,
    'words': Map.fromEntries(list.take(1000)),
  }));
}

Future<String> trainFromWikipedia(Language language, GetArticle getArticle,
    {required int gramSize, required int dictSize}) async {
  final totals = <String, int>{};
  var totalWords = 0;

  final topArticles = jsonDecode(await File(language.topviews).readAsString());

  for (var entry in topArticles.take(100)) {
    final title = entry['article'];
    print(title);
    totalWords += await processArticle(
        () => getArticle(title, language), totals,
        gramSize: gramSize);
  }

  var list = totals.entries.toList();
  list.sort((a, b) => b.value.compareTo(a.value));
  final words = Map.fromEntries(
      list.take(dictSize).map((e) => MapEntry(e.key, e.value / totalWords)));

  final name = language.name;
  final positives =
      jsonDecode(await File('assets/positives/$name.json').readAsString())
          as Map;
  final negatives =
      jsonDecode(await File('assets/gibberish.json').readAsString()) as Map;

  List<String> split(dynamic article) =>
      splitArticleInTrigrams(article, gramSize: gramSize).toList();

  /// searching for min distance
  var map =
      positives.values.map(split).map((e) => Detector.distanceScore(e, words));
  final positiveDistance = _max(map);
  final positiveDistanceAvr = _avr(map);
  map =
      negatives.values.map(split).map((e) => Detector.distanceScore(e, words));
  final negativeDistance = _min(map);
  final negativeDistanceAvr = _avr(map);

  /// searching for max chained score
  map = positives.values
      .map(split)
      .map((e) => Detector.chainedProbabilityScore(e, words));
  final positiveChained = _min(map);
  final positiveChainedAvr = _avr(map);

  map = negatives.values
      .map(split)
      .map((e) => Detector.chainedProbabilityScore(e, words));
  final negativeChained = _max(map);
  final negativeChainedAvr = _avr(map);

  // The padding gives the calculated values some room for unknown inputs
  final paddingMultiplierChained =
      pow(2.2, log((positiveChainedAvr - negativeChainedAvr).abs()) / log(10));

  final paddingMultiplierDistance = pow(
      2.2, log((positiveDistanceAvr - negativeDistanceAvr).abs()) / log(10));

  final chainedPadding =
      (positiveChained - negativeChained).abs() * paddingMultiplierChained;
  final distancePadding =
      (positiveDistance - negativeDistance).abs() * paddingMultiplierDistance;

  return jsonEncode({
    'language': language.name,
    'gramSize': gramSize,
    'maxDistanceScore': positiveDistance + distancePadding,
    'minChainedScore': positiveChained - chainedPadding,
    'words': words,
  });
}

double _min(Iterable<double> l) {
  final list = l.toList();
  list.sort();
  return list.first;
}

double _max(Iterable<double> l) {
  final list = l.toList();
  list.sort();
  return list.last;
}

double _avr(Iterable<double> l) =>
    l.isEmpty ? 0 : l.reduce((value, element) => value + element) / l.length;

Future<int> processArticle(
    Future<String?> Function() getArticle, Map<String, int> totals,
    {required int gramSize}) async {
  final article = await getArticle();

  final result = countWords(article, gramSize: gramSize);
  result.counts.forEach((key, value) {
    final count = totals.putIfAbsent(key, () => 0);
    totals[key] = count + value;
  });
  return result.totals;
}

CountResult countWords(String? article, {required int gramSize}) {
  final words = getCleanTrigramsAsDictionary(article ?? '', gramSize: gramSize);
  final total = words.values.reduce((value, element) => value + element);

  return CountResult(total, words);
}