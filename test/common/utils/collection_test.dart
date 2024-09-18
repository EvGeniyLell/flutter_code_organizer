import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/common/common.dart';

void main() {
  final source = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

  group('CollectionList', () {
    test('removeWhereIndexed', () {
      final result = [...source]..removeWhereIndexed((index, value) {
          return index > 5;
        });
      expect(result, hasLength(6));
      expect(result[0], 'A');
      expect(result[1], 'B');
      expect(result[5], 'F');
    });

    test('forEachWithEach', () {
      final result = <String>[];
      source.forEachWithEach((a, b) {
        result.add('$a$b');
      });
      expect(result, hasLength(90));
      expect(result[0], 'AB');
      expect(result[1], 'AC');
      expect(result[89], 'JI');
    });

    test('forEachWithEach: includeSame', () {
      final result = <String>[];
      source.forEachWithEach(
        (a, b) => result.add('$a$b'),
        includeSame: true,
      );
      expect(result, hasLength(100));
      expect(result[0], 'AA');
      expect(result[1], 'AB');
      expect(result[99], 'JJ');
    });

    test('forEachWithEachNext', () {
      final result = <String>[];
      source.forEachWithEachNext((a, b) {
        result.add('$a$b');
      });
      expect(result, hasLength(45));
      expect(result[0], 'AB');
      expect(result[1], 'AC');
      expect(result[44], 'IJ');
    });
  });

  group('CollectionIterable', () {
    test('forEachIndexed', () {
      final result = <int, String>{};
      source.forEachIndexed((index, value) {
        result[index] = value;
      });
      expect(result, hasLength(10));
      expect(result[0], 'A');
      expect(result[1], 'B');
      expect(result[9], 'J');
    });

    test('mapIndexed', () {
      final result = source.mapIndexed((index, value) {
        return '$index$value';
      }).toList();
      expect(result, hasLength(10));
      expect(result[0], '0A');
      expect(result[1], '1B');
      expect(result[9], '9J');
    });

    test('groupBy', () {
      final result = source.groupBy((group, element) {
        if (group.isEmpty) {
          return true;
        }
        return group.first.runes.first % 3 == element.runes.first % 3;
      });
      expect(result, hasLength(3));
      expect(result[0], ['A', 'D', 'G', 'J']);
      expect(result[1], ['B', 'E', 'H']);
      expect(result[2], ['C', 'F', 'I']);
    });
  });
}
