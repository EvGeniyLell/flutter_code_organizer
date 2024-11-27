import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_order_item_type.dart';

import '../../common/mocks.dart';
import 'test_data.dart';

void main() {
  final file = File('test/feature_a0.dart');
  const projectName = 'app';

  IOManager.instance = MockIOManager();

  test('Sorter Handler: init', () {
    when(() => IOManager().readFile(file)).thenReturn(getFileData());
    final handler = HeaderSorterHandler(
      file: file,
      projectName: projectName,
    );

    expect(handler.firstRemoveIndex, 5);
    expect(handler.originalCode, hasLength(61));
    expect(handler.code, hasLength(34));
  });

  group('Sorter Handler: buildNewCode', () {
    when(() => IOManager().readFile(file)).thenReturn('');
    final handler = HeaderSorterHandler(
      file: file,
      projectName: projectName,
    );

    handler.code.clear();

    void replaceItems(List<String> target, List<String> newItems) {
      target
        ..clear()
        ..addAll(newItems);
    }

    replaceItems(
      handler.imports.dart,
      ['Dart Import 1', 'Dart Import 2'],
    );
    replaceItems(
      handler.imports.flutter,
      ['Flutter Import 1', 'Flutter Import 2'],
    );
    replaceItems(
      handler.imports.package,
      ['Packages Import 1', 'Packages Import 2'],
    );
    replaceItems(
      handler.imports.project,
      ['Project Import 1', 'Project Import 2'],
    );
    replaceItems(
      handler.imports.relative,
      ['Relative Import 1', 'Relative Import 2'],
    );

    replaceItems(
      handler.exports.dart,
      ['Dart Export 1', 'Dart Export 2'],
    );
    replaceItems(
      handler.exports.flutter,
      ['Flutter Export 1', 'Flutter Export 2'],
    );
    replaceItems(
      handler.exports.package,
      ['Packages Export 1', 'Packages Export 2'],
    );
    replaceItems(
      handler.exports.project,
      ['Project Export 1', 'Project Export 2'],
    );
    replaceItems(
      handler.exports.relative,
      ['Relative Export 1', 'Relative Export 2'],
    );
    replaceItems(
      handler.parts.parts,
      ['Part 1', 'Part 2'],
    );

    test('default order', () {
      final result = handler.buildNewCode(
        sortOrder: HeaderSorterOrderItemTypeExtension.defaultOrder(),
      );

      expect(result, [
        'Dart Import 1',
        'Dart Import 2',
        '',
        'Flutter Import 1',
        'Flutter Import 2',
        '',
        'Packages Import 1',
        'Packages Import 2',
        '',
        'Project Import 1',
        'Project Import 2',
        '',
        'Relative Import 1',
        'Relative Import 2',
        '',
        'Dart Export 1',
        'Dart Export 2',
        '',
        'Flutter Export 1',
        'Flutter Export 2',
        '',
        'Packages Export 1',
        'Packages Export 2',
        '',
        'Project Export 1',
        'Project Export 2',
        '',
        'Relative Export 1',
        'Relative Export 2',
        '',
        'Part 1',
        'Part 2',
      ]);
    });

    test('Multi space should be trimmed to one', () {
      final result = handler.buildNewCode(
        sortOrder: [
          HeaderSorterOrderItemType.importDart,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.importFlutter,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.importPackage,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.importProject,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.importRelative,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.exportDart,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.exportFlutter,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.exportPackage,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.exportProject,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.exportRelative,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.space,
          HeaderSorterOrderItemType.part,
        ],
      );
      expect(result, [
        'Dart Import 1',
        'Dart Import 2',
        '',
        'Flutter Import 1',
        'Flutter Import 2',
        '',
        'Packages Import 1',
        'Packages Import 2',
        '',
        'Project Import 1',
        'Project Import 2',
        '',
        'Relative Import 1',
        'Relative Import 2',
        '',
        'Dart Export 1',
        'Dart Export 2',
        '',
        'Flutter Export 1',
        'Flutter Export 2',
        '',
        'Packages Export 1',
        'Packages Export 2',
        '',
        'Project Export 1',
        'Project Export 2',
        '',
        'Relative Export 1',
        'Relative Export 2',
        '',
        'Part 1',
        'Part 2',
      ]);
    });

    test('Doubles rule should be trimmed to one', () {
      // importFlutter used three times
      final result = handler.buildNewCode(
        sortOrder: [
          HeaderSorterOrderItemType.importDart,
          HeaderSorterOrderItemType.importFlutter,
          HeaderSorterOrderItemType.importFlutter,
          HeaderSorterOrderItemType.importPackage,
          HeaderSorterOrderItemType.importProject,
          HeaderSorterOrderItemType.importRelative,
          HeaderSorterOrderItemType.exportDart,
          HeaderSorterOrderItemType.exportFlutter,
          HeaderSorterOrderItemType.exportPackage,
          HeaderSorterOrderItemType.exportProject,
          HeaderSorterOrderItemType.exportRelative,
          HeaderSorterOrderItemType.part,
          HeaderSorterOrderItemType.importFlutter,
        ],
      );
      expect(result, [
        'Dart Import 1',
        'Dart Import 2',
        'Flutter Import 1',
        'Flutter Import 2',
        'Packages Import 1',
        'Packages Import 2',
        'Project Import 1',
        'Project Import 2',
        'Relative Import 1',
        'Relative Import 2',
        'Dart Export 1',
        'Dart Export 2',
        'Flutter Export 1',
        'Flutter Export 2',
        'Packages Export 1',
        'Packages Export 2',
        'Project Export 1',
        'Project Export 2',
        'Relative Export 1',
        'Relative Export 2',
        'Part 1',
        'Part 2',
      ]);
    });

    test('Not included order items should be added to the end of order', () {
      final result = handler.buildNewCode(
        sortOrder: [
          HeaderSorterOrderItemType.importDart,
          HeaderSorterOrderItemType.importFlutter,
          // HeaderSorterOrderItemType.importPackage,
          HeaderSorterOrderItemType.importProject,
          //HeaderSorterOrderItemType.importRelative,
          HeaderSorterOrderItemType.exportDart,
          HeaderSorterOrderItemType.exportFlutter,
          // HeaderSorterOrderItemType.exportPackage,
          HeaderSorterOrderItemType.exportProject,
          //HeaderSorterOrderItemType.exportRelative,
          HeaderSorterOrderItemType.part,
          HeaderSorterOrderItemType.space,
        ],
      );
      expect(result, [
        'Dart Import 1',
        'Dart Import 2',
        'Flutter Import 1',
        'Flutter Import 2',
        'Project Import 1',
        'Project Import 2',
        'Dart Export 1',
        'Dart Export 2',
        'Flutter Export 1',
        'Flutter Export 2',
        'Project Export 1',
        'Project Export 2',
        'Part 1',
        'Part 2',
        '',
        'Packages Import 1',
        'Packages Import 2',
        '',
        'Relative Import 1',
        'Relative Import 2',
        '',
        'Packages Export 1',
        'Packages Export 2',
        '',
        'Relative Export 1',
        'Relative Export 2',
        '',
      ]);
    });
  });
}
