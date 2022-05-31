// all letters and Umlaute + european special chars
import 'package:gibberish/trigram_utils.dart';

final word = RegExp(r"[a-zA-Z\u00C0-\u017F]+", unicode: true);

List<String> splitArticleInWords(String article) {
  final allMatches = word.allMatches(article);
  return allMatches
      .map((e) => e.group(0))
      .where((element) => element != null)
      .cast<String>()
      .toList();
}

List<String> splitArticleInTrigrams(String article, {int gramSize = 3}) {
  return getCleanTrigrams(article, distance: gramSize);
}
