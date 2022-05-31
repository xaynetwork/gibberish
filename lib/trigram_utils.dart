/// Copied from francd 170e633af9a7b8b31769eb232f99e105e1359692
///

/// Get dictionary with trigrams as its keys,
/// and their occurrence count as values.
Map<String, int> getCleanTrigramsAsDictionary(String text, {int distance = 3}) {
  final List<String> trigrams = getCleanTrigrams(text, distance: distance);
  final Map<String, int> dictionary = {};
  trigrams.forEach((element) {
    dictionary.update(element, (occurrence) => occurrence + 1,
        ifAbsent: () => 1);
  });
  return dictionary;
}

/// Get clean, padded, trigrams.
List<String> getCleanTrigrams(String text, {int distance = 3}) {
  return _makeTrigrams(' ' + _clean(text) + ' ', distance);
}

//Get list of trigrams for given string
List<String> _makeTrigrams(String value, int distance) {
  final trigrams = <String>[];
  int index;
  if (value.isEmpty) return trigrams;
  index = value.length - distance + 1;
  if (index < 1) return trigrams;
  while (index-- > 0) {
    trigrams.add(value.substring(index, index + distance));
  }
  return trigrams;
}

// Removed general non-important (as in, for language detection) punctuation
// marks, symbols, and numbers.
String _clean(String value) {
  if (value.isEmpty) {
    return '';
  }
  return value
      .replaceAll(RegExp(r"[\u0021-\u0040]+"), ' ')
      .replaceAll(RegExp(r"\s+"), ' ')
      .trim();
}
