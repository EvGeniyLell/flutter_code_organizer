import 'dart:io';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_exports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_imports_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_parts_strategy.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:test/test.dart';

import 'source.dart';

void main() {
  const projectName = 'fx';
  final sourceMap = {
    File('test/source_a1.dart'): sourceA1,
  };

  void printList(List<String> list, {required String title}) {
    print('-- $title -----------------------------');
    for (final line in list) {
      print(line);
    }
    print('^^ $title ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
  }

  HeaderSorterHandler createHandler(
    TestSource source, {
    required File file,
    required String projectName,
  }) {
    final lines = source.source.split('\n');
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

  setUp(() {});

  group(
    'HeaderSorterHandler',
    () {
      for (final entry in sourceMap.entries) {
        final file = entry.key;
        final source = entry.value;
        group(
          source.description,
          () {
            final handler = createHandler(
              source,
              file: file,
              projectName: projectName,
            );

            test('imports', () {
              final strategy = handler.imports;
              final result = strategy.sorted(
                spaceDartFlutter: true,
                spaceFlutterPackage: true,
                spacePackageProject: true,
              )..add('');

              expect(result.join('\n'), source.imports);
            });

            test('exports', () {
              final strategy = handler.exports;
              final result = strategy.sorted(
                spaceDartFlutter: true,
                spaceFlutterPackage: true,
                spacePackageProject: true,
              )..add('');

              expect(result.join('\n'), source.exports);
            });

            test('paths', () {
              final strategy = handler.parts;
              final result = strategy.sorted()..add('');

              expect(result.join('\n'), source.parts);
            });

            // final strategy = handler.imports;
            // final result = strategy.sorted(
            //   spaceDartFlutter: true,
            //   spaceFlutterPackage: true,
            //   spacePackageProject: true,
            // );
            //
            // printList(strategy.dartImports, title: 'dartImports');
            // printList(strategy.flutterImports, title: 'flutterImports');
            // printList(strategy.packageImports, title: 'packageImports');
            // printList(strategy.projectImports, title: 'projectImports');
            // printList(result, title: 'result');

            // expect(output.length, 1);
            // expect(output.firstOrNull, isNotNull);
            // expect(output.first?.unColorize().length, 120);
          },
        );
      }
    },
  );

  // test('Printer prints ', () {
  //   final handler = createHandler(
  //     sourceA1,
  //     file: File('test/source_a1.dart'),
  //     projectName: 'fx',
  //   );
  //   final strategy = handler.imports;
  //   final result = strategy.sorted(
  //     spaceDartFlutter: true,
  //     spaceFlutterPackage: true,
  //     spacePackageProject: true,
  //   );
  //
  //   printList(strategy.dartImports, title: 'dartImports');
  //   printList(strategy.flutterImports, title: 'flutterImports');
  //   printList(strategy.packageImports, title: 'packageImports');
  //   printList(strategy.projectImports, title: 'projectImports');
  //   printList(result, title: 'result');
  //
  //   // expect(output.length, 1);
  //   // expect(output.firstOrNull, isNotNull);
  //   // expect(output.first?.unColorize().length, 120);
  // });
}
