// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_handler.dart';

import '../common/mocks.dart';
import 'test_data.dart';

void main() {
  final fileEn1 = File('test/localization/feature1/en1.arb');
  final fileUa1 = File('test/localization/feature1/ua1.arb');
  final fileEn2 = File('test/localization/feature2/en2.arb');
  const localePattern = '(\\w{2})\\d{1}\\.arb\$';

  IOManager.instance = MockIOManager();
  when(() => IOManager().readFile(fileEn1)).thenReturn(getFileEn1Data());
  when(() => IOManager().readFile(fileEn2)).thenReturn(getFileEn2Data());
  when(() => IOManager().readFile(fileUa1)).thenReturn(getFileUa1Data());

  final handlerEn1 = LocalizationInspectorHandler(
    file: fileEn1,
    localePattern: localePattern,
  );

  final handlerEn2 = LocalizationInspectorHandler(
    file: fileEn2,
    localePattern: localePattern,
  );

  final handlerUa1 = LocalizationInspectorHandler(
    file: fileUa1,
    localePattern: localePattern,
  );

  group('LocalizationInspectorHandler: Init', () {
    test('EN1', () {
      final handler = handlerEn1;
      expect(handler.locale, 'en');
      expect(handler.items, hasLength(3));
      expect(
        handler.items[0],
        const Item(key: 'keyA', value: 'EN Value A', lineIndex: 2),
      );
      expect(
        handler.items[1],
        const Item(key: 'keyB', value: 'EN Value B', lineIndex: 8),
      );
      expect(
        handler.items[2],
        const Item(
          key: 'keyC',
          value: 'EN Value C with {param1} and {param2}',
          lineIndex: 14,
        ),
      );
    });
    test('EN2', () {
      final handler = handlerEn2;
      expect(handler.locale, 'en');
      expect(handler.items, hasLength(5));
      expect(
        handler.items[0],
        const Item(key: 'keyA', value: 'EN Value A Other', lineIndex: 2),
      );
      expect(
        handler.items[1],
        const Item(key: 'keyBOther', value: 'EN Value B', lineIndex: 8),
      );
      expect(
        handler.items[2],
        const Item(
          key: 'keyC',
          value: 'EN Value C with {param1} and {param2}',
          lineIndex: 14,
        ),
      );
      expect(
        handler.items[3],
        const Item(
          key: 'keyCOther',
          value: 'EN Value C with {param1} and {param2}',
          lineIndex: 27,
        ),
      );
      expect(
        handler.items[4],
        const Item(
          key: 'keyCOther2',
          value: 'EN Value C with {param1} and {param3}',
          lineIndex: 40,
        ),
      );
    });
    test('UA1', () {
      final handler = handlerUa1;
      expect(handler.locale, 'ua');
      expect(handler.items, hasLength(2));
      expect(
        handler.items[0],
        const Item(key: 'keyA', value: 'UA Value A', lineIndex: 2),
      );
      expect(
        handler.items[1],
        const Item(
          key: 'keyCOther',
          value: 'UA Value C with {param1} and {param2}',
          lineIndex: 8,
        ),
      );
    });
  });

  group('LocalizationInspectorHandler: Find', () {
    final handlers = [handlerEn1, handlerEn2, handlerUa1];
    test('Duplicates', () {
      final duplicates = handlers.findDuplicates(
        findKeyAndValueDuplicates: true,
        findKeyDuplicates: true,
        findValueDuplicates: true,
      );

      expect(duplicates, hasLength(8));
      // 2
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn1,
            line: 2,
            type: LocalizationInspectorExceptionType.keyDuplicate,
            key: 'keyA',
            value: 'EN Value A',
          ),
        ),
        isTrue,
      );
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn2,
            line: 2,
            type: LocalizationInspectorExceptionType.keyDuplicate,
            key: 'keyA',
            value: 'EN Value A Other',
          ),
        ),
        isTrue,
      );
      // 8
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn1,
            line: 8,
            type: LocalizationInspectorExceptionType.valueDuplicate,
            key: 'keyB',
            value: 'EN Value B',
          ),
        ),
        isTrue,
      );
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn2,
            line: 8,
            type: LocalizationInspectorExceptionType.valueDuplicate,
            key: 'keyBOther',
            value: 'EN Value B',
          ),
        ),
        isTrue,
      );
      // 14
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn1,
            line: 14,
            type: LocalizationInspectorExceptionType.keyAndValueDuplicate,
            key: 'keyC',
            value: 'EN Value C with {param1} and {param2}',
          ),
        ),
        isTrue,
      );
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn2,
            line: 14,
            type: LocalizationInspectorExceptionType.keyAndValueDuplicate,
            key: 'keyC',
            value: 'EN Value C with {param1} and {param2}',
          ),
        ),
        isTrue,
      );
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn1,
            line: 14,
            type: LocalizationInspectorExceptionType.valueDuplicate,
            key: 'keyC',
            value: 'EN Value C with {param1} and {param2}',
          ),
        ),
        isTrue,
      );
      // 27
      expect(
        duplicates.contains(
          LocalizationInspectorException(
            file: fileEn2,
            line: 27,
            type: LocalizationInspectorExceptionType.valueDuplicate,
            key: 'keyCOther',
            value: 'EN Value C with {param1} and {param2}',
          ),
        ),
        isTrue,
      );
    });
    test('Missed', () {
      final duplicates = handlers.findMissed(
        findMissedKeys: true,
      );

      expect(duplicates, hasLength(6));

      bool pair({
        required File fileA,
        required int lineA,
        required String key,
        required String value,
        required File fileB,
      }) {
        return duplicates.contains(
              LocalizationInspectorException(
                file: fileA,
                line: lineA,
                type: LocalizationInspectorExceptionType.keyMissed,
                key: key,
                value: value,
              ),
            ) &&
            duplicates.contains(
              LocalizationInspectorException(
                file: fileB,
                line: 0,
                type: LocalizationInspectorExceptionType.keyMissed,
                key: key,
                value: value,
              ),
            );
      }

      // keyB
      expect(
        pair(
          fileA: fileEn1,
          lineA: 8,
          key: 'keyB',
          value: 'EN Value B',
          fileB: fileUa1,
        ),
        isTrue,
      );
      // keyC
      expect(
        pair(
          fileA: fileEn1,
          lineA: 14,
          key: 'keyC',
          value: 'EN Value C with {param1} and {param2}',
          fileB: fileUa1,
        ),
        isTrue,
      );
      // keyCOther
      expect(
        pair(
          fileA: fileUa1,
          lineA: 8,
          key: 'keyCOther',
          value: 'UA Value C with {param1} and {param2}',
          fileB: fileEn1,
        ),
        isTrue,
      );
    });
  });
}
