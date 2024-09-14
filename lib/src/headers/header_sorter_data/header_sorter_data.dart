import 'dart:io';
import 'dart:math';

import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_exports_strategy.dart';
import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_imports_strategy.dart';
import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_parts_strategy.dart';

class HeaderSorterData {
  factory HeaderSorterData({
    required File file,
    required String projectName,
  }) {
    final lines = file.readAsLinesSync();
    return HeaderSorterData._(
      file: file,
      imports: HeaderSorterDataImportsStrategy(lines, projectName: projectName),
      exports: HeaderSorterDataExportsStrategy(lines, projectName: projectName),
      parts: HeaderSorterDataPartsStrategy(lines),
      code: lines,
    );
  }

  const HeaderSorterData._({
    required this.file,
    required this.imports,
    required this.exports,
    required this.parts,
    required this.code,
  });

  final File file;

  final HeaderSorterDataImportsStrategy imports;
  final HeaderSorterDataExportsStrategy exports;
  final HeaderSorterDataPartsStrategy parts;

  final List<String> code;

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
}
