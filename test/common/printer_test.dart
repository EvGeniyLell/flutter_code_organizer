import 'package:test/test.dart';
import 'package:flutter_code_organizer/src/common/common.dart';

void main() {
  final printer = Printer();
  List<String?> output = [];

  final testMap = {
    'header 1': printer.h1,
    'footer1': printer.f1,
  };

  setUp(() {
    output = [];
    Printer.output = ([String? message]) {
      output.add(message);
    };
  });

  group(
    'Printer should print line with length 120 for short message',
    () {
      const message = 'Hello';

      testMap.forEach((key, value) {
        test('Printer prints $key', () {
          value(message);

          expect(output.length, 1);
          expect(output.firstOrNull, isNotNull);
          expect(output.first?.unColorize().length, 120);
        });
      });
    },
  );

  group(
    'Printer should print line with length more then 120 for long message',
    () {
      const message = 'Hello long long long long long long long long long long '
          'more  long long long long long long long long long long long long '
          'again  long long long long long long long long long long long long';

      testMap.forEach((key, value) {
        test('Printer prints $key', () {
          value(message);

          expect(output.length, 1);
          expect(output.firstOrNull, isNotNull);
          expect(output.first?.unColorize().length, greaterThan(120));
        });
      });
    },
  );
}
