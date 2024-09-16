import 'dart:io';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';
import 'package:test/test.dart';

import 'test_source_a1.dart';

void main() {
  final sourceMap = {
    File('test/source_a1.dart'): sourceA1,
  };

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
            HeaderSorterHandler.reader =
                (File file) => source.source.split('\n');

            final handler = HeaderSorterHandler(
              file: file,
              projectName: source.projectName,
            );

            test('imports', () {
              final strategy = handler.imports;
              final result = strategy.sorted(
                spaceDartFlutter: true,
                spaceFlutterPackage: true,
                spacePackageProject: true,
                spaceProjectRelative: true,
              )..add('');

              expect(result.join('\n'), source.imports);
            });

            test('exports', () {
              final strategy = handler.exports;
              final result = strategy.sorted(
                spaceDartFlutter: true,
                spaceFlutterPackage: true,
                spacePackageProject: true,
                spaceProjectRelative: true,
              )..add('');

              expect(result.join('\n'), source.exports);
            });

            test('paths', () {
              final strategy = handler.parts;
              final result = strategy.sorted()..add('');

              expect(result.join('\n'), source.parts);
            });

            test('result', () {
              final newCode = handler.buildNewCode(
                spaceDartFlutter: true,
                spaceFlutterPackage: true,
                spacePackageProject: true,
                spaceProjectRelative: true,
              )..add('');

              expect(newCode.join('\n'), source.result);
            });
          },
        );
      }
    },
  );
}
