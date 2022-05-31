import 'package:gibberish/detection.dart';
import 'package:gibberish/language.dart';
import 'package:gibberish/results/de.dart';
import 'package:gibberish/results/en.dart';
import 'package:gibberish/results/es.dart';
import 'package:gibberish/results/fr.dart';
import 'package:gibberish/results/nl.dart';
import 'package:gibberish/results/pl.dart';

class Detectors {
  Detectors._();

  static late final english = Detector(englishDictionary, Language.english);
  static late final german = Detector(germanDictionary, Language.german);
  static late final spanish = Detector(spanishDictionary, Language.spanish);
  static late final french = Detector(frenchDictionary, Language.french);
  static late final dutch = Detector(dutchDictionary, Language.dutch);
  static late final polish = Detector(polishDictionary, Language.polish);

  static Detection detect(String article) {
    return Detection(Map.fromIterable(Language.values,
        key: (k) => k,
        value: (v) {
          switch (v as Language) {
            case Language.english:
              return english.analyze(article);
            case Language.polish:
              return polish.analyze(article);
            case Language.dutch:
              return dutch.analyze(article);
            case Language.french:
              return french.analyze(article);
            case Language.spanish:
              return spanish.analyze(article);
            case Language.german:
              return german.analyze(article);
          }
        }));
  }
}
