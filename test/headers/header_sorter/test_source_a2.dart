// ignore_for_file: unnecessary_raw_strings
import '../test_source/test_source.dart';
export '../test_source/test_source.dart';

const sourceA2 = TestSource(
  projectName: 'fx',
  description: 'A2: all imports, exports, parts with spaces',
  source: r"""import 'package:flutter_test/flutter_test.dart';
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

  test(
    'When reading a list of currencies, it is read from shared preferences '
    'and converted back to business objects',
    () async {
      when(
        () => preferences.getString(
          dataSource.keyForRegion('currencies', region),
        ),
      ).thenReturn(json);

      final result = await dataSource.getCurrencies(region);

      expect(result, currencies);
    },
  );
}

const currencies = [
  Currency(code: 'GBP', symbol: '£', viewOrder: 0),
  Currency(code: 'EUR', symbol: 'e', viewOrder: 1),
];

final json = '''
[{"code":"GBP","symbol":"£","viewOrder":0,"decimalCount":2},{"code":"EUR","symbol":"e","viewOrder":1,"decimalCount":2}]
'''
    .replaceAll('\n', '');
    
""",
  result: r'''
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

  test(
    'When reading a list of currencies, it is read from shared preferences '
    'and converted back to business objects',
    () async {
      when(
        () => preferences.getString(
          dataSource.keyForRegion('currencies', region),
        ),
      ).thenReturn(json);

      final result = await dataSource.getCurrencies(region);

      expect(result, currencies);
    },
  );
}

const currencies = [
  Currency(code: 'GBP', symbol: '£', viewOrder: 0),
  Currency(code: 'EUR', symbol: 'e', viewOrder: 1),
];

''',
  imports: r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fx/src/dictionary/data_sources/shared_preferences_dictionary_local_data_source.dart';
import 'package:fx/src/dictionary/dictionary.dart';

import '../../mocks.dart';
''',
  exports: r'''
''',
  parts: r'''
''',
);
