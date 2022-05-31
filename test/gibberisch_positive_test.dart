import 'dart:convert';
import 'dart:io';

import 'package:franc/franc.dart';
import 'package:gibberish/gibberish.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

final defaultSize = 3;

void main() {
  group('Positive: ', () {
    test(
      'All English articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.english,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['english']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );

    test(
      'All German articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.german,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['german']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );

    test(
      'All Polish articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.polish,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['polish']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );

    test(
      'All French articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.french,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['french']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );

    test(
      'All Dutch articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.dutch,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['dutch']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );

    test(
      'All Spanish articles should be detected as non gibberish',
      () async {
        await verify(
          Detectors.spanish,
          () async => jsonDecode(await File('test/assets/articles.json')
                  .readAsString())['spanish']
              .entries,
          quota: 1,
          gramSize: defaultSize,
        );
      },
    );
  });

  group('Negative:', () {
    test(
      'English: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.english,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.39),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'German: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.german,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.0),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'Spanish: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.spanish,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.1),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'Polish: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.polish,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.0),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'Dutch: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.dutch,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.0),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'French: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detectors.french,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(0.0),
          gramSize: defaultSize,
        );
      },
    );

    test(
      'Franc benchmark: No detection',
      () async {
        await verifyFranc(
          Detectors.english,
          () async => jsonDecode(
                  await File('test/assets/gibberish.json').readAsString())
              .entries,
          quota: lessThanOrEqualTo(1),
        );
      },
    );
  });
}

Future<void> verify(
    Detector detector, Future<Iterable<MapEntry>> Function() getEntries,
    {required quota, required int gramSize}) async {
  final entries = await getEntries();
  final res = <Analysis>[];
  for (var article in entries) {
    final analysis = detector.analyze(article.value, gramSize: gramSize);
    print("${article.key}: $analysis");
    res.add(analysis);
  }

  var detected = res
          .map((e) => e.isGibberish ? 0 : 1)
          .reduce((value, element) => value + element) /
      res.length;
  expect(detected, quota);
}

final franc = Franc();

Future<void> verifyFranc(
    Detector detector, Future<Iterable<MapEntry>> Function() getEntries,
    {required quota}) async {
  final entries = await getEntries();
  final res = <Map<String, double>>[];
  for (var article in entries) {
    final analysis = await franc.detectLanguages(article.value);
    print("${article.key}: ${analysis.entries.take(3)}");
    res.add(analysis);
  }

  var detected = res
          .map((e) => e['und'] == 1 ? 0 : 1)
          .reduce((value, element) => value + element) /
      res.length;
  expect(detected, quota);
}

Analysis? isGibberish(String article) {
  return Detectors.detect(article).analysis;
}
