// ignore_for_file: prefer_single_quotes

import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';

void main() {
  setUp(() {});

  test('mergeMultilineLines """ ', () {
    const text = """
import 'package:flutter_code_organizer/src/A/A.dart';
    
final test = r'''
import 'package:flutter_code_organizer/src/B/B.dart';

part 'file.g.dart';
''';
""";
    final lines = text.split('\n');
    expect(lines, hasLength(8));

    mergeMultilineLines(lines, startPattern: "'''", endPattern: "'''");
    expect(lines, hasLength(4));
    expect(lines[0], startsWith("import"));
    expect(lines[0], endsWith("A/A.dart';"));
    expect(lines[1], endsWith(""));
    expect(lines[2], startsWith("final test = r'''"));
    expect(lines[2], endsWith("''';"));
    expect(lines[3], endsWith(""));
  });
}
