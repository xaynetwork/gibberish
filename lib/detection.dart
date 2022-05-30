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
    list.sort((a, b) => b.value.totalScore.compareTo(a.value.totalScore));
    return list.isEmpty ? null : list.first;
  }
}

class Analysis {
  Analysis({
    required this.totalScore,
    required this.distanceScore,
    required this.distributionScore,
    required this.words,
  });

  bool get isGibberish =>
      totalScore < 0.30 || (distanceScore > 0.03 && words > 30);
  final double totalScore;
  final double distanceScore;
  final double distributionScore;
  final int words;

  String toString() =>
      "${isGibberish ? '❌' : '✅'} (total: $totalScore distance: $distanceScore, distribution: $distributionScore )";
}

class Detector {
  final Map _dictionary;

  Detector(this._dictionary);

  Analysis analyze(String article) {
    final words = splitArticleInWords(article);

    return Analysis(
      totalScore: _totalScore(words),
      distanceScore: _distanceScore(words),
      distributionScore: _distributionScore(words),
      words: words.length,
    );
  }

  double _totalScore(List<String> words) {
    if (words.isEmpty) {
      throw 'Article does not contain any words';
    }

    final keys = Set.from(_dictionary['words'].keys);
    final listOfWords = words.toList();

    return listOfWords
            .where((element) => keys.contains(element))
            .toList()
            .length /
        listOfWords.length;
  }

  double _distanceScore(List<String> words) {
    if (words.isEmpty) {
      throw 'Article does not contain any words';
    }

    final wordDistribution = <String, int>{};
    words.forEach((key) =>
        wordDistribution[key] = wordDistribution.putIfAbsent(key, () => 0) + 1);
    final totalWords = words.length;

    final int total = _dictionary['totals'];
    final used = Map.fromIterable(_dictionary['words'].entries,
        key: (k) => k.key,
        value: (v) {
          final wordScore = wordDistribution[v.key];
          if (wordScore == null) {
            return null;
          } else {
            return ((wordScore / totalWords) - v.value / total).abs();
          }
        });

    var scores = used.values.where((element) => element != null).cast<double>();
    return scores.isEmpty
        ? 0
        : scores.reduce((value, element) => value + element) / scores.length;
  }

  double _distributionScore(List<String> words) {
    if (words.isEmpty) {
      throw 'Article does not contain any words';
    }

    final wordSet = words.toSet();
    final hitmap = Map.fromIterable(_dictionary['words'].keys,
        value: (v) => wordSet.contains(v) ? 1 : 0, key: (k) => k);
    final usedWords = hitmap.values.reduce((value, element) => value + element);

    return usedWords.toDouble();
  }
}
