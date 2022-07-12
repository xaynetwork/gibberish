import 'package:gibberish/results/deu.dart';
import 'package:gibberish/results/dut.dart';
import 'package:gibberish/results/eng.dart';
import 'package:gibberish/results/esp.dart';
import 'package:gibberish/results/fre.dart';
import 'package:gibberish/results/pol.dart';

const int kGramSize = 3;
const int kDictSize = 750;

enum Language {
  eng(engDictionary),
  deu(deuDictionary),
  dut(dutDictionary),
  fre(freDictionary),
  pol(polDictionary),
  esp(espDictionary);

  const Language(this.dict);

  final Map dict;
}
