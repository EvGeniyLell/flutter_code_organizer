// ignore_for_file: prefer_single_quotes

import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_parts_strategy.dart';

import 'test_data.dart';

void main() {
  setUp(() {});

  test('Strategy Exports', () {
    final originalLines = getFileData().split('\n');
    // check that the original data loaded correctly
    expect(originalLines, hasLength(61));

    final lines = [...originalLines];
    final strategy = HeaderSorterPartsStrategy(lines);

    // check that the lines have been reduced correctly
    expect(lines, hasLength(59));

    // Parts
    expect(strategy.parts, hasLength(2));
    expect(strategy.parts[0], "part 'account.freezed.dart';");
    expect(strategy.parts[1], "part 'account.g.dart';");

    expect(strategy.firstRemoveIndex, 33);
  });
}
