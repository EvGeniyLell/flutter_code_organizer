import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_exports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_imports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_parts_strategy.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:meta/meta.dart';

class HeaderSorterHandler {
  @visibleForTesting
  static List<String> Function(File file) reader =
      // file.readAsLinesSync() works wrong for this case
      (File file) => file.readAsStringSync().split('\n');

  factory HeaderSorterHandler({
    required File file,
    required String projectName,
  }) {
    final lines = reader(file);
    final originalCode = [...lines];
    mergeMultilineLines(lines, startPattern: "^import '", endPattern: ';\$');
    mergeMultilineLines(lines, startPattern: "^export '", endPattern: ';\$');
    mergeMultilineLines(lines, startPattern: "^part '", endPattern: ';\$');
    return HeaderSorterHandler.private(
      file: file,
      imports: HeaderSorterImportsStrategy(lines, projectName: projectName),
      exports: HeaderSorterExportsStrategy(lines, projectName: projectName),
      parts: HeaderSorterPartsStrategy(lines),
      code: lines,
      originalCode: originalCode,
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
  });

  final File file;

  final HeaderSorterImportsStrategy imports;
  final HeaderSorterExportsStrategy exports;
  final HeaderSorterPartsStrategy parts;

  final List<String> code;
  final List<String> originalCode;

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
  List<String> buildNewCode({
    required bool spaceDartFlutter,
    required bool spaceFlutterPackage,
    required bool spacePackageProject,
    required bool spaceProjectRelative,
  }) {
    final topCode = code.sublist(0, firstRemoveIndex);
    final bottomCode = code.sublist(firstRemoveIndex);
    final newCode = [
      ...topCode,
      '',
      ...imports.sorted(
        spaceDartFlutter: spaceDartFlutter,
        spaceFlutterPackage: spaceFlutterPackage,
        spacePackageProject: spacePackageProject,
        spaceProjectRelative: spaceProjectRelative,
      ),
      '',
      ...exports.sorted(
        spaceDartFlutter: spaceDartFlutter,
        spaceFlutterPackage: spaceFlutterPackage,
        spacePackageProject: spacePackageProject,
        spaceProjectRelative: spaceProjectRelative,
      ),
      '',
      ...parts.sorted(),
      '',
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

  bool save({
    required bool spaceDartFlutter,
    required bool spaceFlutterPackage,
    required bool spacePackageProject,
    required bool spaceProjectRelative,
  }) {
    final newCode = buildNewCode(
      spaceDartFlutter: spaceDartFlutter,
      spaceFlutterPackage: spaceFlutterPackage,
      spacePackageProject: spacePackageProject,
      spaceProjectRelative: spaceProjectRelative,
    );

    final buffer = newCode.join('\n');
    final originalBuffer = originalCode.join('\n');

    if (buffer == originalBuffer) {
      return false;
    }

    file.writeAsStringSync(buffer);

    return true;
  }
}
