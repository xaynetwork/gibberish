const int kGramSize = 3;
const int kDictSize = 750;

/// To learn a new Language follow this steps:
///
/// - add the new language to [Language]
///   i.e. ukr
///   implement all switches with [UnimplementedError]
/// - download the 500 wikipedia topviews from
///   https://pageviews.wmcloud.org/topviews/?project=it.wikipedia.org&platform=all-access&date=last-year&excludes=
///   for the given language project (in this example this is italian)
/// - save the file in assets/topviews/[THREE_LETTER_NEW_LANG].json (i.e. deu, eng,...)
/// - download the articles by running
///   dart bin/fetch.dart [THREE_LETTER_NEW_LANG] > assets/blob/[THREE_LETTER_NEW_LANG].json
/// - the fetch positives (you can / should add new positives to this file when you find articles that need to be covered)
///   dart bin/fetch_positives.dart [THREE_LETTER_NEW_LANG] > assets/positives/[THREE_LETTER_NEW_LANG].json
/// - [optional] add new gibberish examples to gibberish.json
/// - Run bin/train.sh
/// - Implement the switches with the generated dict files (i.e ukrDictionary)
/// - verify that `dart test` passes
///   In case that one test doesn't pass you can modify the test class to cover the expected alternative coverage
///   We allways wanna have 100% on the positives and almost 0% on the negatives
enum Language {
  eng,
  deu,
  dut,
  fre,
  pol,
  esp,
  ukr,
  ita;
}
