// all letters and Umlaute + european special chars
final word = RegExp(r"[a-zA-Z\u00C0-\u017F]+", unicode: true);

List<String> splitArticleInWords(String article) {
  final allMatches = word.allMatches(article);
  return allMatches
      .map((e) => e.group(0))
      .where((element) => element != null)
      .cast<String>()
      .toList();
}
