import 'dart:convert';
import 'dart:io';

import 'package:franc/franc.dart';
import 'package:gibberish/gibberish.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async {
  // verify that the configs full fill our expectation
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
          quota: lessThanOrEqualTo(0.43),
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
    {required quota}) async {
  final entries = await getEntries();
  final res = <Analysis>[];
  for (var article in entries) {
    final analysis = detector.analyze(article.value);
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
