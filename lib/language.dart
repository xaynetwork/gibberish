enum Language {
  english('assets/results/en2.json'),
  german('assets/results/de.json'),
  dutch('assets/results/nl.json'),
  french('assets/results/fr.json'),
  polish('assets/results/pl.json'),
  spanish('assets/results/es.json');

  const Language(this.wordSetFile);

  final String wordSetFile;
}
