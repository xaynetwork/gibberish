/// List top rated projects
import 'dart:convert';
import 'dart:io';

import 'package:gibberish/language.dart';
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
      case Language.english:
        return 'en.wikipedia.org';
      case Language.german:
        return 'de.wikipedia.org';
      case Language.dutch:
        return 'nl.wikipedia.org';
      case Language.french:
        return 'fr.wikipedia.org';
      case Language.polish:
        return 'pl.wikipedia.org';

      case Language.spanish:
        return 'es.wikipedia.org';
    }
  }

  String get topviews {
    switch (this) {
      case Language.english:
        return 'test/assets/topviews/en-topviews-2021.json';
      case Language.german:
        return 'test/assets/topviews/de-topviews-2021.json';
      case Language.dutch:
        return 'test/assets/topviews/nl-topviews-2021.json';
      case Language.french:
        return 'test/assets/topviews/fr-topviews-2021.json';
      case Language.polish:
        return 'test/assets/topviews/pl-topviews-2021.json';
      case Language.spanish:
        return 'test/assets/topviews/es-topviews-2021.json';
    }
  }
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
  trainFromWikipedia(Language.polish, getArticleContent);
  trainFromWikipedia(Language.spanish, getArticleContent);
  trainFromWikipedia(Language.french, getArticleContent);
  trainFromWikipedia(Language.dutch, getArticleContent);
  trainFromWikipedia(Language.german, getArticleContent);
}

Future<void> trainFromFile(Language language, String fileName) async {
  final totals = <String, int>{};

  final totalWords =
      await processArticle(() => File(fileName).readAsString(), totals);

  var list = totals.entries.toList();
  list.sort((a, b) => b.value.compareTo(a.value));
  print(jsonEncode({
    'language': language.name,
    'totals': totalWords,
    'words': Map.fromEntries(list.take(1000)),
  }));
}

Future<void> trainFromWikipedia(
    Language language, GetArticle getArticle) async {
  final totals = <String, int>{};
  var totalWords = 0;

  final topArticles = jsonDecode(await File(language.topviews).readAsString());

  for (var entry in topArticles.take(100)) {
    final title = entry['article'];
    print(title);
    totalWords +=
        await processArticle(() => getArticle(title, language), totals);
  }

  var list = totals.entries.toList();
  list.sort((a, b) => b.value.compareTo(a.value));
  print(jsonEncode({
    'language': language.name,
    'totals': totalWords,
    'words': Map.fromEntries(list.take(1000)),
  }));
}

Future<int> processArticle(
    Future<String?> Function() getArticle, Map<String, int> totals) async {
  final article = await getArticle();

  final result = countWords(article);
  result.counts.forEach((key, value) {
    final count = totals.putIfAbsent(key, () => 0);
    totals[key] = count + value;
  });
  return result.totals;
}

CountResult countWords(String? article) {
  final words = <String, int>{};
  int total = 0;
  if (article != null) {
    article = article.replaceFirst(pronunciation, '');

    final allMatches = word.allMatches(article);
    total = allMatches.length;
    for (var match in allMatches) {
      final group = match.group(0);
      if (group != null) {
        words[group] = words.putIfAbsent(group, () => 0) + 1;
      }
    }
  }

  return CountResult(total, words);
}
