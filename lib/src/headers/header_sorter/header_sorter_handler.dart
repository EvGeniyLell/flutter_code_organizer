import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_exports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_imports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_order_item_type.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_parts_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';

class HeaderSorterHandler {
  static List<String> defaultReader(File file) {
    // file.readAsLinesSync() works wrong for this case
    return file.readAsStringSync().split('\n');
  }

  static void defaultWriter(File file, String content) {
    return file.writeAsStringSync(content);
  }

  factory HeaderSorterHandler({
    required File file,
    required String projectName,
    List<String> Function(File file)? reader,
    void Function(File file, String content)? writer,
  }) {
    final lines = (reader ?? HeaderSorterHandler.defaultReader)(file);
    final resolvedWriter = writer ?? HeaderSorterHandler.defaultWriter;
    final originalCode = [...lines];

    return HeaderSorterHandler.private(
      file: file,
      imports: HeaderSorterImportsStrategy(lines, projectName: projectName),
      exports: HeaderSorterExportsStrategy(lines, projectName: projectName),
      parts: HeaderSorterPartsStrategy(lines),
      code: lines,
      originalCode: originalCode,
      writer: resolvedWriter,
    );
  }

  @visibleForTesting
  const HeaderSorterHandler.private({
    required this.file,
    required this.imports,
    required this.exports,
    required this.parts,
    required this.code,
    required this.originalCode,
    required this.writer,
  });

  final File file;

  final HeaderSorterImportsStrategy imports;
  final HeaderSorterExportsStrategy exports;
  final HeaderSorterPartsStrategy parts;

  final List<String> code;
  final List<String> originalCode;

  final void Function(File file, String content) writer;

  int get firstRemoveIndex {
    return [
          imports.firstRemoveIndex,
          exports.firstRemoveIndex,
          parts.firstRemoveIndex,
        ].fold(null, (int? previousValue, int? index) {
          if (index == null) {
            return previousValue;
          }
          if (previousValue == null) {
            return index;
          }
          return min(previousValue, index);
        }) ??
        0;
  }

  @visibleForTesting
  List<String> orderItems({
    required List<HeaderSorterOrderItemType> sortOrder,
  }) {
    final resolvedOrder =
        HeaderSorterOrderItemTypeExtension.mergeWithDefaultOrder(sortOrder);

    final result = <String>[];
    for (final item in resolvedOrder) {
      switch (item) {
        case HeaderSorterOrderItemType.importDart:
          result.addAll(imports.dart);
        case HeaderSorterOrderItemType.importFlutter:
          result.addAll(imports.flutter);
        case HeaderSorterOrderItemType.importPackage:
          result.addAll(imports.package);
        case HeaderSorterOrderItemType.importProject:
          result.addAll(imports.project);
        case HeaderSorterOrderItemType.importRelative:
          result.addAll(imports.relative);
        case HeaderSorterOrderItemType.exportDart:
          result.addAll(exports.dart);
        case HeaderSorterOrderItemType.exportFlutter:
          result.addAll(exports.flutter);
        case HeaderSorterOrderItemType.exportPackage:
          result.addAll(exports.package);
        case HeaderSorterOrderItemType.exportProject:
          result.addAll(exports.project);
        case HeaderSorterOrderItemType.exportRelative:
          result.addAll(exports.relative);
        case HeaderSorterOrderItemType.part:
          result.addAll(parts.parts);
        case HeaderSorterOrderItemType.space:
          result.add('');
      }
    }
    return result;
  }

  @visibleForTesting
  List<String> buildNewCode({
    required List<HeaderSorterOrderItemType> sortOrder,
  }) {
    final topCode = code.sublist(0, firstRemoveIndex);
    final bottomCode = code.sublist(firstRemoveIndex);

    final newCode = <String>[
      ...topCode,
      ...orderItems(sortOrder: sortOrder),
      ...bottomCode,
    ];

    // remove double empty lines
    bool previousLineIsEmpty = true;
    newCode.removeWhere((line) {
      if (line.trim().isEmpty) {
        if (previousLineIsEmpty) {
          return true;
        }
        previousLineIsEmpty = true;
        return false;
      }
      previousLineIsEmpty = false;
      return false;
    });

    return newCode;
  }

  bool save({required List<HeaderSorterOrderItemType> sortOrder}) {
    final newCode = buildNewCode(sortOrder: sortOrder);

    final buffer = newCode.join('\n');
    final originalBuffer = originalCode.join('\n');

    if (buffer == originalBuffer) {
      return false;
    }

    file.writeAsStringSync(buffer);

    return true;
  }
}

extension Defaults on HeaderSorterHandler {}
