// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:flutter_code_organizer/src/common/remote_config/extensions/arguments_map_extension.dart';
import 'package:flutter_code_organizer/src/headers/utils/remote_config.dart';
import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';

import 'test_data.dart';

void main() {
  final file = File('test/lib/src/feature_a0/feature_a1/feature_a2.dart');
  const projectName = 'app';
  const projectDir = 'test';
  final testDataList = TestHeaderInspectorHandleItemData.list(file);

  test('All exception types should be tested.', () {
    final notTestedTypes = [...HeaderInspectorExceptionType.values];
    for (final testData in testDataList) {
      final testedTypes = [
        testData.forbiddenThemselfPackageImports,
        testData.forbiddenOtherFeaturesPackageImports,
        testData.forbiddenRelativeImports,
        testData.forbiddenPackageExports,
        testData.forbiddenOtherFeaturesRelativeExports,
      ];
      notTestedTypes.removeWhere(testedTypes.contains);
      if (notTestedTypes.isEmpty) {
        break;
      }
    }

    expect(notTestedTypes, isEmpty);
  });

  group('Test Items of HeaderSorterHandler', () {
    int index = 0;
    for (final testData in testDataList) {
      index += 1;
      group('Item: $index', () {
        final item = Item.private(
          index: index,
          projectName: projectName,
          projectDir: projectDir,
          file: testData.file,
          source: testData.source,
          features: testData.file.getProjectSRCFeaturesByPath(projectDir),
        );

        test('forbiddenThemselfPackageImports', () {
          final exception = item.forbiddenThemselfPackageImports();
          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return e?.type == testData.forbiddenThemselfPackageImports;
            }),
          );
        });

        test('forbiddenOtherFeaturesPackageImports', () {
          final exception = item.forbiddenOtherFeaturesPackageImports();
          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return e?.type == testData.forbiddenOtherFeaturesPackageImports;
            }),
          );
        });

        test('forbiddenRelativeImports', () {
          final exception = item.forbiddenRelativeImports();
          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return e?.type == testData.forbiddenRelativeImports;
            }),
          );
        });

        test('forbiddenPackageExports', () {
          final exception = item.forbiddenPackageExports();
          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return e?.type == testData.forbiddenPackageExports;
            }),
          );
        });

        test('forbiddenOtherFeaturesRelativeExports', () {
          final exception = item.forbiddenOtherFeaturesRelativeExports();
          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return e?.type == testData.forbiddenOtherFeaturesRelativeExports;
            }),
          );
        });

        test('findException', () {
          final remoteForbidConfig =
              RemoteInspectorForbidConfig(name: 'test', description: 'test')
                ..init(null, ArgumentsMap());

          final exception = item.findException(
            forbidThemselfPackageImports: remoteForbidConfig,
            forbidOtherFeaturesPackageImports: remoteForbidConfig,
            forbidRelativeImports: remoteForbidConfig,
            forbidPackageExports: remoteForbidConfig,
            forbidOtherFeaturesRelativeExports: remoteForbidConfig,
          );

          expect(
            exception,
            predicate((HeaderInspectorException? e) {
              return [
                testData.forbiddenThemselfPackageImports,
                testData.forbiddenOtherFeaturesPackageImports,
                testData.forbiddenRelativeImports,
                testData.forbiddenPackageExports,
                testData.forbiddenOtherFeaturesRelativeExports,
              ].contains(e?.type);
            }),
          );
        });
      });
    }
  });
}
