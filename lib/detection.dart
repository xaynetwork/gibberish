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
    required this.minChainedScore,
    required this.maxDistanceScore,
  });

  bool get isGibberish => !textMakesSense;

  // bool get textMakesSense =>
  //     (language != Language.polish &&
  //         chainedScore > 0.0011 &&
  //         (distanceScore < 0.016)) ||
  //     (language == Language.polish &&
  //         chainedScore > 0.00057 &&
  //         distanceScore < 0.0018);

  bool get textMakesSense =>
      (chainedScore > minChainedScore) && (distanceScore < maxDistanceScore);

  final double distanceScore;
  final double chainedScore;
  final double minChainedScore;
  final double maxDistanceScore;

  final int words;

  String toString() =>
      "${isGibberish ? '❌' : '✅'} (distance: $distanceScore chained: $chainedScore)";
}

class Detector {
  final Map _dictionary;

  Detector(this._dictionary);

  Analysis analyze(String article, {int maxSize = 3600}) {
    final words =
        splitArticleInTrigrams(article, gramSize: _dictionary['gramSize'])
            .take(maxSize)
            .toList();

    return Analysis(
      distanceScore: distanceScore(words, _dictionary['words']),
      chainedScore: chainedProbabilityScore(words, _dictionary['words']),
      words: words.length,
      maxDistanceScore: _dictionary["maxDistanceScore"],
      minChainedScore: _dictionary["minChainedScore"],
    );
  }

  static double distanceScore(List<String> input, Map words) {
    if (input.isEmpty) {
      throw 'Article does not contain any words';
    }

    final inputDistribution = <String, int>{};
    input.forEach((key) => inputDistribution[key] =
        inputDistribution.putIfAbsent(key, () => 0) + 1);
    final inputsLength = input.length;

    final used = Map.fromIterable(words.entries,
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

  static double chainedProbabilityScore(List<String> input, Map words) {
    if (input.isEmpty) {
      throw 'Article does not contain any words';
    }

    var count = input.length;
    final logProb = input.map((e) {
      var val = words[e];
      return val ?? 0;
    }).reduce((value, element) => value + element);

    return count == 0 || logProb == 0 ? 0 : logProb / count;
  }
}
