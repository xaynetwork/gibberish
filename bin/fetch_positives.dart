import 'dart:convert';
import 'dart:io';

import 'package:gibberish/language.dart';
import 'package:http/http.dart' as http;

import 'fetch_blob.dart';
import 'training.dart';

typedef GetArticle = Future<String?> Function(String title, Language language);

void main(List args) async {
  if (args.length != 1) {
    print(
        'Usage: dart fetch_articles [threeLetterLang] > positives/[threeLetterLang].json');
    exit(1);
  }

  final name = args[0];
  Language lang = Language.values.firstWhere((element) {
    return element.name == name;
  });

  createArticleBlob(lang, getArticleExtract);
}

Future<String?> getArticleExtract(String name, Language languages) async {
  final response = await http.get(Uri.parse(
      'https://${languages.project}/w/api.php?action=query&prop=extracts&exsentences=10&exlimit=1&titles=$name&explaintext=1&formatversion=2&format=json'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['query']['pages'][0]['extract'];
  } else {
    return null;
  }
}
