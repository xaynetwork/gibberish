import 'package:gibberish/language.dart';
import 'package:gibberish/utils.dart';

class Detection {
  final Map<Language, Analysis> results;

  Detection(this.results);

  late final MapEntry<Language, Analysis>? _entry = _findLanguage();
  late final Language? detectedLanguage = _entry?.key;
  late final Analysis? analysis = _entry?.value;

  late final bool isGibberish =
      results.values.where((element) => !element.isGibberish).isEmpty;

  MapEntry<Language, Analysis>? _findLanguage() {
    final list =
        results.entries.where((element) => !element.value.isGibberish).toList();
    list.sort((a, b) => b.value.distanceScore.compareTo(a.value.chainedScore));
    return list.isEmpty ? null : list.first;
  }
}

class Analysis {
  Analysis({
    required this.distanceScore,
    required this.chainedScore,
    required this.words,
    required this.language,
  });

  bool get isGibberish => !textMakesSense;

  bool get textMakesSense =>
      (language != Language.polish &&
          chainedScore > 0.0011 &&
          (distanceScore < 0.016 || words < 60)) ||
      (language == Language.polish &&
          chainedScore > 0.00057 &&
          distanceScore < 0.0018);

  final double distanceScore;
  final double chainedScore;
  final int words;
  final Language language;

  String toString() =>
      "${isGibberish ? '❌' : '✅'} (distance: $distanceScore chained: $chainedScore)";
}

class Detector {
  final Map _dictionary;
  final Language _language;

  Detector(this._dictionary, this._language);

  Analysis analyze(String article, {int maxSize = 3600, int gramSize = 3}) {
    final words = splitArticleInTrigrams(article, gramSize: gramSize)
        .take(maxSize)
        .toList();

    return Analysis(
      distanceScore: _distanceScore(words),
      chainedScore: _chainedProbabilityScore(words),
      words: words.length,
      language: _language,
    );
  }

  double _distanceScore(List<String> input) {
    if (input.isEmpty) {
      throw 'Article does not contain any words';
    }

    final inputDistribution = <String, int>{};
    input.forEach((key) => inputDistribution[key] =
        inputDistribution.putIfAbsent(key, () => 0) + 1);
    final inputsLength = input.length;

    final used = Map.fromIterable(_dictionary['words'].entries,
        key: (k) => k.key,
        value: (dictEntry) {
          final inputScore = inputDistribution[dictEntry.key];
          if (inputScore == null) {
            return null;
          } else {
            return ((inputScore / inputsLength) - dictEntry.value).abs();
          }
        });

    var scores = used.values.where((element) => element != null).cast<double>();
    return scores.isEmpty
        ? 0
        : scores.reduce((value, element) => value + element) / scores.length;
  }

  double _chainedProbabilityScore(List<String> words) {
    if (words.isEmpty) {
      throw 'Article does not contain any words';
    }

    var count = words.length;
    final logProb = words.map((e) {
      var val = _dictionary['words'][e];
      return val ?? 0;
    }).reduce((value, element) => value + element);

    return count == 0 || logProb == 0 ? 0 : logProb / count;
  }
}
