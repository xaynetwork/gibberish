import 'package:gibberish/detection.dart';
import 'package:gibberish/language.dart';

export 'detection.dart';
export 'detectors.dart';

bool isGibberish(Language language, String text) {
  return analyze(language, text).isGibberish;
}

Analysis analyze(Language language, String text) =>
    Detector(language.dict).analyze(text);
