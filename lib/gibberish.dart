import 'package:gibberish/detection.dart';
import 'package:gibberish/detectors.dart';
import 'package:gibberish/language.dart';

export 'detection.dart';
export 'detectors.dart';

bool isGibberish(Language language, String text) {
  return analyze(language, text).isGibberish;
}

Analysis analyze(Language language, String text) {
  switch (language) {
    case Language.english:
      return Detectors.english.analyze(text);
    case Language.polish:
      return Detectors.polish.analyze(text);
    case Language.dutch:
      return Detectors.dutch.analyze(text);
    case Language.french:
      return Detectors.french.analyze(text);
    case Language.spanish:
      return Detectors.spanish.analyze(text);
    case Language.german:
      return Detectors.german.analyze(text);
  }
}
