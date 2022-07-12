import 'dart:convert';
import 'dart:io';

import 'package:gibberish/language.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'training.dart';

typedef GetArticle = Future<String?> Function(String title, Language language);

void main(List args) async {
  if (args.length != 1) {
    print(
        'Usage: dart fetch_blob [threeLetterLang] > blob/[threeLetterLang].json');
    exit(1);
  }

  final name = args[0];
  Language lang = Language.values.firstWhere((element) {
    return element.name == name;
  });

  createArticleBlob(lang, getArticleContent);
}

Future<void> createArticleBlob(Language language, GetArticle getArticle) async {
  final articles = <Future<MapEntry<String, String>>>[];

  final topArticles = jsonDecode(await File(language.topviews).readAsString());

  for (var entry in topArticles.take(100)) {
    final title = entry['article'];
    Future<String?> fetch() async {
      try {
        return await getArticle(title, language);
      } catch (e, st) {
        stderr.writeAll(['Could not parse $title\n', e, '\n\n', st]);
        return null;
      }
    }

    articles.add(fetch().then((value) => MapEntry(title, value ?? '')));
  }
  final res = await Future.wait(articles);
  print(jsonEncode(Map.fromEntries(res)));
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
