import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/common/remote_config/extensions/arguments_map_extension.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';
import 'package:flutter_code_organizer/src/headers/utils/remote_config.dart';

import '../../common/mocks.dart';

void main() {
  final file = File('test/feature_a0.dart');
  const projectName = 'app';
  const projectDir = 'test';

  final sourceLines = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  IOManager.instance = MockIOManager();
  when(() => IOManager().readFile(file)).thenReturn(sourceLines.join('\n'));

  test('For each line handler should make a Item', () {
    final handler = HeaderInspectorHandler(
      file: file,
      projectName: projectName,
      projectDir: projectDir,
    );

    expect(handler.items, hasLength(10));
  });

  test('Func findAllExceptions should recall findException for each item', () {
    final item = MockItem();
    final remoteForbidConfig =
        RemoteInspectorForbidConfig(name: 'test', description: 'test')
          ..init(null, ArgumentsMap());

    Item itemBuilder({
      required List<String> features,
      required File file,
      required int index,
      required String projectDir,
      required String projectName,
      required String source,
    }) =>
        item;

    final handler = HeaderInspectorHandler(
      file: file,
      projectName: projectName,
      projectDir: projectDir,
      itemBuilder: itemBuilder,
    );

    verifyZeroInteractions(item);

    // Mocking findException method
    int lineIndex = 0;
    when(
      () => item.findException(
        forbidThemselfPackageImports: remoteForbidConfig,
        forbidOtherFeaturesPackageImports: remoteForbidConfig,
        forbidRelativeImports: remoteForbidConfig,
        forbidPackageExports: remoteForbidConfig,
        forbidOtherFeaturesRelativeExports: remoteForbidConfig,
      ),
    ).thenReturn(
      HeaderInspectorException(
        type: HeaderInspectorExceptionType.themselfPackageImport,
        file: file,
        source: sourceLines[lineIndex],
        line: lineIndex++,
      ),
    );

    // should call findException for each item
    // and return all exceptions
    final result = handler.findAllExceptions(
      forbidThemselfPackageImports: remoteForbidConfig,
      forbidOtherFeaturesPackageImports: remoteForbidConfig,
      forbidRelativeImports: remoteForbidConfig,
      forbidPackageExports: remoteForbidConfig,
      forbidOtherFeaturesRelativeExports: remoteForbidConfig,
    );

    // 10 times according to sourceLines length
    expect(result, hasLength(10));

    // all exceptions should be collected from mocked return
    expect(
      result,
      predicate((List<HeaderInspectorException> e) {
        return e.every(
              (element) =>
                  element.type ==
                  HeaderInspectorExceptionType.themselfPackageImport,
            ) &&
            e.every((element) => element.file == file) &&
            e.every((element) => element.source == sourceLines[element.line]);
      }),
    );

    verify(
      () => item.findException(
        forbidThemselfPackageImports: remoteForbidConfig,
        forbidOtherFeaturesPackageImports: remoteForbidConfig,
        forbidRelativeImports: remoteForbidConfig,
        forbidPackageExports: remoteForbidConfig,
        forbidOtherFeaturesRelativeExports: remoteForbidConfig,
      ),
    ).called(10);

    verifyNoMoreInteractions(item);
  });
}

class MockItem extends Mock implements Item {}
