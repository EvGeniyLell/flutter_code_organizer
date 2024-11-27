// ignore_for_file: prefer_single_quotes

import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_exports_strategy.dart';

import 'test_data.dart';

void main() {
  const projectName = 'app';

  setUp(() {});

  test('Strategy Exports', () {
    final originalLines = getFileData().split('\n');
    // check that the original data loaded correctly
    expect(originalLines, hasLength(61));

    final lines = [...originalLines];
    final strategy = HeaderSorterExportsStrategy(
      lines,
      projectName: projectName,
    );

    // check that the lines have been reduced correctly
    expect(lines, hasLength(54));

    // Dart
    expect(strategy.dart, hasLength(1));
    expect(strategy.dart[0], "export 'dart:io';");

    // Flutter
    expect(strategy.flutter, hasLength(1));
    expect(
      strategy.flutter[0],
      "export 'package:flutter/src/splash_screen/ui/splash_page_builder.dart';",
    );

    // Package
    expect(strategy.package, hasLength(1));
    expect(
      strategy.package[0],
      "export 'package:mac_os/src/splash_screen/ui/splash_page_builder.dart';",
    );

    // Project
    expect(strategy.project, hasLength(1));
    expect(
      strategy.project[0],
      "export 'package:app/src/splash_screen/ui/splash_page_builder.dart';",
    );

    // Relative
    expect(strategy.relative, hasLength(3));
    expect(
      strategy.relative[0],
      "export '../splash_screen/ui/splash_page_builder.dart';",
    );
    expect(
      strategy.relative[1],
      "export 'cubits/splash_cubit.dart';",
    );
    expect(
      strategy.relative[2],
      "export 'ui/splash_page_builder.dart';",
    );

    expect(strategy.firstRemoveIndex, 17);
  });
}
