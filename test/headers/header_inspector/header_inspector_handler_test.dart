import 'dart:io';

import 'package:flutter_code_organizer/src/common/remote_config/extensions/arguments_map_extension.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';
import 'package:flutter_code_organizer/src/headers/utils/remote_config.dart';
import 'package:test/test.dart';

import 'test_source_a1.dart';

void main() {
  final sourceMap = {
    File('test/lib/src/feature_a0/feature_a1/feature_a2.dart'): sourceA1,
  };
  final remoteForbidConfig =
      RemoteInspectorForbidConfig(name: 'test', description: 'test')
        ..init(null, ArgumentsMap());

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

        test('AllExceptions', () {
          final exceptions = handler.findAllExceptions(
            forbidThemselfPackageImports: remoteForbidConfig,
            forbidOtherFeaturesPackageImports: remoteForbidConfig,
            forbidRelativeImports: remoteForbidConfig,
            forbidPackageExports: remoteForbidConfig,
            forbidOtherFeaturesRelativeExports: remoteForbidConfig,
          );

          //print(exceptions);

          for (final type in HeaderInspectorExceptionType.values) {
            print('-- ${type.name}');
            final subExceptions = exceptions.where((e) {
              return e.type == type;
            });
            for (final exception in subExceptions) {
              print(exception);
            }
          }

          // print('-- All');
          // for (final exception in exceptions) {
          //   print(exception);
          // }

          // expect(result.join('\n'), source.imports);
        });
      });
    }
  });
}
