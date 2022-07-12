import 'dart:convert';
import 'dart:io';

import 'package:gibberish/gibberish.dart';
import 'package:gibberish/language.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async {
  // verify that the configs full fill our expectation
  group('Positive: ', () {
    for (var lang in Language.values) {
      final name = lang.name;
      test(
        'All $name articles should be detected as non gibberish',
        () async {
          await verify(
            Detector(lang.dict),
            () async => jsonDecode(
                    await File('assets/positives/$name.json').readAsString())
                .entries,
            quota: 1,
          );
        },
      );
    }
  });

  group('Negative:', () {
    test(
      'English: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detector(Language.eng.dict),
          () async =>
              jsonDecode(await File('assets/gibberish.json').readAsString())
                  .entries,
          quota: lessThanOrEqualTo(0.43),
        );
      },
    );

    test(
      'Italian: Gibberish be detected as gibberish',
      () async {
        await verify(
          Detector(Language.ita.dict),
          () async =>
              jsonDecode(await File('assets/gibberish.json').readAsString())
                  .entries,
          quota: lessThanOrEqualTo(0.07),
        );
      },
    );

    final languages = Language.values.toList()

      /// many gibberish generators are based on english thus we perform relatively bad on that
      ..remove(Language.eng)

      /// some gibberish used the lorem ipsum concept that looks a bit like italian
      ..remove(Language.ita);

    for (var lang in languages) {
      final name = lang.name;
      test(
        '$name: Gibberish be detected as gibberish',
        () async {
          await verify(
            Detector(lang.dict),
            () async =>
                jsonDecode(await File('assets/gibberish.json').readAsString())
                    .entries,
            quota: 0.0,
          );
        },
      );
    }
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

Analysis? isGibberish(String article) {
  return Detectors.detect(article).analysis;
}
