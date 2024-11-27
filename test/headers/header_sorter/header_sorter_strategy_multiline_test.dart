// ignore_for_file: prefer_single_quotes

import 'package:test/test.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';

void main() {
  setUp(() {});

  test('mergeMultilineLines """ ', () {
    const text = """
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fx/src/dictionary/data_sources/shared_preferences_dictionary_local_data_source.dart';
import 'package:fx/src/dictionary/dictionary.dart';

import '../../mocks.dart';

void main() {
  late Region region;
  late SharedPreferences preferences;
  late SharedPreferencesDictionaryLocalDataSource dataSource;

  setUp(() {
    region = Region.us;
    preferences = MockSharedPreferences();
    dataSource = SharedPreferencesDictionaryLocalDataSource(preferences);
  });

  test(
    'When saving a list of currencies, it is converted to json '
    'and save to shared preferences',
    () async {
      when(
        () => preferences.setString(
          dataSource.keyForRegion('currencies', region),
          json,
        ),
      ).thenAnswer((_) => Future.value(true));

      await dataSource.saveCurrencies(region, currencies);

      verify(
        () => preferences.setString(
          dataSource.keyForRegion('currencies', region),
          json,
        ),
      );
    },
  );
}

const currencies = [
  Currency(code: 'GBP', symbol: '£', viewOrder: 0),
  Currency(code: 'EUR', symbol: 'e', viewOrder: 1),
];

final json1 = '''[{"code":"GBP"}]''';
final json2 = '''[{"code":"GBP"}]'''.replaceAll('\n', '');
final json3 = '''[{"code":"GBP"}]'''
   .replaceAll('\n', '');
final json4 = '''
[{"code":"GBP","symbol":"£","viewOrder":0,"decimalCount":2},{"code":"EUR","symbol":"e","viewOrder":1,"decimalCount":2}]
'''
    .replaceAll('\n', '');
final json5 = '''
[
 {"code":"GBP","symbol":"£","viewOrder":0,"decimalCount":2},
 {
   "code":"EUR",
   "symbol":"e",
   "viewOrder":1,
   "decimalCount":2
 }
]
'''
    .replaceAll('\n', '');
    
""";
    final lines = text.split('\n');
    expect(lines, hasLength(74));

    mergeMultilineLines(lines, startPattern: "'''", endPattern: "'''");
    expect(lines, hasLength(62));
  });
}
