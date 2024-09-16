import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_exports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_imports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_parts_strategy.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:meta/meta.dart';

class HeaderSorterHandler {
  factory HeaderSorterHandler({
    required File file,
    required String projectName,
  }) {
    final lines = file.readAsLinesSync();
    final originalCode = List<String>.from(lines);
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
      '',
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

    //print('### newCode: ${newCode.length} (${originalCode.length})');
    final buffer = newCode.join('\n');
    final originalBuffer = [...originalCode, ''].join('\n');
    int bufIndex = 0;
    int? difI;
    String? getC(String s, int index) {
      try {
        return s[index];
      } on Object {
        return null;
      }
    }

    void printSample(String l, String r, int index) {
      if(index == -1) {
        return;
      }
      const shift = 5;
      final iStart = max(index - shift, 0);
      print('L:----------------\n '
          '${l.substring(iStart, min(index + shift, l.length))}\n'
          '--------------------:L');
      print('R:----------------\n '
          '${r.substring(iStart, min(index + shift, r.length))}\n'
          '--------------------:R');
      for (int i = iStart; i < index + shift; i++) {
        final lC = getC(l, i);
        final rC = getC(r, i);
        if (lC == null && rC == null) {
          break;
        }
        final lR = lC != null ? '${utf8.encode(lC)}' : '[null]';
        final rR = rC != null ? '${utf8.encode(rC)}' : '[null]';
        print('${lR.padLeft(9)} ${rR.padLeft(9)}');
      }
    }

    while (difI == null) {
      final nB = getC(buffer, bufIndex);
      final oB = getC(originalBuffer, bufIndex);
      if (nB == null && oB == null) {
        difI = -1;
        break;
      }
      if (nB == null || oB == null) {
        difI = bufIndex;
        break;
      }
      bufIndex += 1;
    }

    print('file: ${file.path}');
    print('difI: $difI in (${buffer.length}:${originalBuffer.length})');
    printSample(buffer, originalBuffer, difI);

    if (buffer == originalBuffer) {
      return false;
    }

    file.writeAsStringSync(buffer);

    return true;
  }
}
