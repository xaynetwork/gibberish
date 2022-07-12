import 'package:gibberish/gibberish.dart';
import 'package:gibberish/language.dart';

class Detectors {
  Detectors._();

  static Detection detect(String article) {
    return Detection(Map.fromIterable(Language.values,
        key: (k) => k, value: (v) => analyze(v, article)));
  }
}
