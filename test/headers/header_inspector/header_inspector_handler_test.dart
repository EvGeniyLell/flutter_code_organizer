import 'dart:io';

import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';
import 'package:test/test.dart';

import 'test_source_a1.dart';

void main() {
  final sourceMap = {
    File('test/lib/src/splash/ui/source_a1.dart'): sourceA1,
  };

  setUp(() {});

  group('HeaderSorterHandler', () {
    for (final entry in sourceMap.entries) {
      final file = entry.key;
      final source = entry.value;
      group(source.description, () {
        HeaderInspectorHandler.reader =
            (File file) => source.source.split('\n');

        final handler = HeaderInspectorHandler(
          file: file,
          projectName: source.projectName,
          projectDir: 'test',
        );

        print('lines ${handler.lines.length}');

        test('AllExceptions', () {
          final exceptions = handler.findAllExceptions(
            forbidThemselfPackageImports: true,
            forbidOtherFeaturesPackageImports: true,
            forbidRelativeImports: true,
            forbidPackageExports: true,
            forbidOtherFeaturesRelativeExports: true,
          );

          for (final exception in exceptions) {
            print(exception);
          }

          // expect(result.join('\n'), source.imports);
        });
      });
    }
  });
}
