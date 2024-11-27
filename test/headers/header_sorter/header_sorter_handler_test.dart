import 'dart:io';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_order_item_type.dart';
import 'package:test/test.dart';

import 'test_source_a1.dart';
import 'test_source_a2.dart';

void main() {
  final sourceMap = {
    File('test/source_a1.dart'): sourceA1,
    File('test/source_a2.dart'): sourceA2,
  };

  final sortOrder = HeaderSorterOrderItemTypeExtension.defaultOrder();

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

            test('result', () {
              final newCode = handler.buildNewCode(
                sortOrder: sortOrder,
              )..add('');

              expect(newCode.join('\n'), source.result);
            });
          },
        );
      }
    },
  );
}
