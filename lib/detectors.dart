import 'package:gibberish/detection.dart';
import 'package:gibberish/language.dart';

class Detectors {
  Detectors._();

  static late final english = Detector(Language.english.wordSetFile);
  static late final german = Detector(Language.german.wordSetFile);
  static late final spanish = Detector(Language.spanish.wordSetFile);
  static late final french = Detector(Language.french.wordSetFile);
  static late final dutch = Detector(Language.dutch.wordSetFile);
  static late final polish = Detector(Language.polish.wordSetFile);

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
