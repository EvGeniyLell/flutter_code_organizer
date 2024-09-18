// ignore_for_file: prefer_single_quotes
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_imports_strategy.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  const projectName = 'app';

  setUp(() {});

  test('Strategy Imports', () {
    final originalLines = getFileData().split('\n');
    // check that the original data loaded correctly
    expect(originalLines, hasLength(61));

    final lines = [...originalLines];
    final strategy = HeaderSorterImportsStrategy(
      lines,
      projectName: projectName,
    );

    // check that the lines have been reduced correctly
    expect(lines, hasLength(43));

    // Dart
    expect(strategy.dart, hasLength(2));
    expect(strategy.dart[0], "import 'dart:async';");
    expect(strategy.dart[1], "import 'dart:io';");

    // Flutter
    expect(strategy.flutter, hasLength(1));
    expect(
      strategy.flutter[0],
      "import 'package:flutter/material.dart';",
    );

    // Package
    expect(strategy.package, hasLength(2));
    expect(
      strategy.package[0],
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    );
    expect(
      strategy.package[1],
      "import 'package:solar/solar.dart';",
    );

    // Project
    expect(strategy.project, hasLength(6));
    expect(
      strategy.project[0],
      "import 'package:app/src/account/business_objects/account_subscription_type.dart';",
    );
    expect(
      strategy.project[1],
      "import 'package:app/src/account/business_objects/white_label.dart';",
    );
    expect(
      strategy.project[2],
      "import 'package:app/src/common/common.dart'\n"
      "    hide\n"
      "        CoordinateMapperExtensions,\n"
      "        CoordinateDtoMapperExtensions,\n"
      "        CoordinateMapper,\n"
      "        CoordinateDtoMapper;",
    );
    expect(
      strategy.project[3],
      "import 'package:app/src/common/common.dart';",
    );
    expect(
      strategy.project[4],
      "import 'package:app/src/dictionary/dictionary.dart';",
    );
    expect(
      strategy.project[5],
      "import 'package:app/src/notifications/notifications.dart';",
    );

    // Relative
    expect(strategy.relative, hasLength(2));
    expect(
      strategy.relative[0],
      "import '../notifications/notifications.dart';",
    );
    expect(
      strategy.relative[1],
      "import 'notifications/notifications.dart';",
    );

    expect(strategy.firstRemoveIndex, 6);
  });
}
