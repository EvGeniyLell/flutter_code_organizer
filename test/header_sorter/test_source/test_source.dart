export 'test_source_a1.dart';

class TestSource {
  const TestSource({
    required this.projectName,
    required this.description,
    required this.source,
    required this.result,
    required this.imports,
    required this.exports,
    required this.parts,
  });

  final String projectName;
  final String description;
  final String source;
  final String result;
  final String imports;
  final String exports;
  final String parts;
}