import 'package:gibberish/detection.dart';
import 'package:gibberish/language.dart';
import 'package:gibberish/results/deu.dart';
import 'package:gibberish/results/dut.dart';
import 'package:gibberish/results/eng.dart';
import 'package:gibberish/results/esp.dart';
import 'package:gibberish/results/fre.dart';
import 'package:gibberish/results/ita.dart';
import 'package:gibberish/results/pol.dart';
import 'package:gibberish/results/ukr.dart';

export 'detection.dart';
export 'detectors.dart';

bool isGibberish(Language language, String text) {
  return analyze(language, text).isGibberish;
}

Analysis analyze(Language language, String text) =>
    Detector(language.dict).analyze(text);

extension DictExtions on Language {
  Map get dict {
    switch (this) {
      case Language.eng:
        return engDictionary;
      case Language.deu:
        return deuDictionary;
      case Language.dut:
        return dutDictionary;
      case Language.fre:
        return freDictionary;
      case Language.pol:
        return polDictionary;
      case Language.esp:
        return espDictionary;
      case Language.ukr:
        return ukrDictionary;
      case Language.ita:
        return itaDictionary;
    }
  }
}
