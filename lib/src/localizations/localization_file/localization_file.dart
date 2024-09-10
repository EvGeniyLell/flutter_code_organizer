library localization_file;

import 'dart:io';

import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/localizations/localization_file/localization_file_exception.dart';

export 'localization_file_exception.dart';
export 'localization_file_exception_ui_extension.dart';

class LocalizationFile {
  factory LocalizationFile(File file, {required String localePattern}) {
    // get locale from file path
    final localeRegExp = RegExp(localePattern);
    final locale = localeRegExp.firstMatch(file.path)?.group(1) ?? 'unknown';

    // read file by lines
    // search for keys and values
    // like this:
    // "helpAndSupport": "Help & Support",
    final items = <LocalizationFileItem>[];
    final itemRegExp = RegExp(r'"(\w+)": "(.*)",');
    final deepIncreaseExp = RegExp(r'\{');
    final deepDecreaseExp = RegExp(r'\}');

    final lines = file.readAsLinesSync();
    int lineNumber = 0;
    int deep = 0;
    for (final line in lines) {
      lineNumber += 1;

      deepIncreaseExp.allMatches(line).forEach((_) {
        deep += 1;
      });
      deepDecreaseExp.allMatches(line).forEach((_) {
        deep -= 1;
      });

      if (deep > 1) {
        continue;
      }

      final itemMath = itemRegExp.firstMatch(line);
      final key = itemMath?.group(1);
      if (key != null) {
        items.add(
          LocalizationFileItem(
            key: key,
            value: itemMath?.group(2),
            lineNumber: lineNumber,
          ),
        );
      }
    }

    return LocalizationFile._(file: file, locale: locale, items: items);
  }

  const LocalizationFile._({
    required this.file,
    required this.locale,
    required this.items,
  });

  final File file;
  final String locale;
  final List<LocalizationFileItem> items;

  /// Search for intersections between localizations different features.
  /// If other localization has the same key or value.
  List<LocalizationFileException> findIntersections(
    LocalizationFile other, {
    required bool findKeyAndValueDuplicates,
    required bool findKeyDuplicates,
    required bool findValueDuplicates,
  }) {
    final result = <LocalizationFileException>[];
    for (final item in items) {
      for (final otherItem in other.items) {
        final keySame = item.key == otherItem.key;
        final valueSame = item.value == otherItem.value;

        void add(LocalizationFileExceptionType type) {
          result.addAll([
            LocalizationFileException(item: item, type: type, file: file),
            LocalizationFileException(
              item: otherItem,
              type: type,
              file: other.file,
            ),
          ]);
        }

        if (findKeyAndValueDuplicates && keySame && valueSame) {
          add(LocalizationFileExceptionType.keyAndValueSame);
        } else if (findKeyDuplicates && keySame) {
          add(LocalizationFileExceptionType.keySame);
        } else if (findValueDuplicates && valueSame) {
          add(LocalizationFileExceptionType.valueSame);
        }
      }
    }
    return result;
  }

  /// Search for missed keys between localizations for the same feature.
  /// If other localization has not the same key.
  List<LocalizationFileException> findMissedKeys(LocalizationFile other) {
    final result = <LocalizationFileException>[];
    for (final item in items) {
      final hasEqualKey = other.items.any((otherItem) {
        return otherItem.key == item.key;
      });
      if (!hasEqualKey) {
        result.addAll([
          LocalizationFileException(
            item: item,
            file: file,
            type: LocalizationFileExceptionType.keyMissed,
          ),
          LocalizationFileException(
            item: item.copyWithLineNumber0(),
            file: other.file,
            type: LocalizationFileExceptionType.keyMissed,
          ),
        ]);
      }
    }
    return result;
  }
}

class LocalizationFileItem {
  const LocalizationFileItem({
    required this.key,
    required this.value,
    required this.lineNumber,
  });

  final String key;
  final String? value;
  final int lineNumber;

  LocalizationFileItem copyWithLineNumber0() {
    return LocalizationFileItem(key: key, value: value, lineNumber: 0);
  }

  @override
  String toString() {
    return '$LocalizationFileItem{key: $key, value: $value, '
        'lineNumber: $lineNumber}';
  }
}

extension GroupLocalizationFileExtension on List<LocalizationFile> {
  List<List<LocalizationFile>> groupByLocale() {
    final result = <List<LocalizationFile>>[];
    for (final localizationFile in this) {
      final index = result.indexWhere((group) {
        return group.first.locale == localizationFile.locale;
      });
      if (index == -1) {
        result.add([localizationFile]);
      } else {
        result[index].add(localizationFile);
      }
    }
    return result;
  }

  List<List<LocalizationFile>> groupByFolder() {
    final result = <List<LocalizationFile>>[];
    for (final localizationFile in this) {
      final index = result.indexWhere((group) {
        return group.first.file.path.fromFilePathToDirPath() ==
            localizationFile.file.path.fromFilePathToDirPath();
      });
      if (index == -1) {
        result.add([localizationFile]);
      } else {
        result[index].add(localizationFile);
      }
    }
    return result;
  }
}
