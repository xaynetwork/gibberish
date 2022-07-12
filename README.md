# gibberish
A super fast gibberish text detection lib for Dart

It helps to check if an article makes sense in a given language. 
Works really good for articles longer than 40 Words.

## Install

Add this to your project
```yaml
  gibberish:
    git:
      url: https://github.com/xaynetwork/gibberish
```

## Usage

```dart
  final gibberishCandidate = analyze(Language.eng, 'Lorem ipsum ...');
  print('Is gibberish? ${gibberishCandidate.isGibberish}');    
```

## Contribute / Add new Language

Please read the comments in [lib/language.dart](lib/language.dart)

