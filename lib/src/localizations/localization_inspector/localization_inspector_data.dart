import 'dart:io';

import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_inspector/src/localizations/utils/arb_lines_extension.dart';

class LocalizationInspectorData {
  factory LocalizationInspectorData({
    required File file,
    required String localePattern,
  }) {
    // get locale from file path
    final localeRegExp = RegExp(localePattern);
    final locale = localeRegExp.firstMatch(file.path)?.group(1) ?? 'unknown';

    // read file by lines
    // search for localizations keys and values
    // like this:
    // "helpAndSupport": "Help & Support",
    final itemRegExp = RegExp(r'"(\w+)": "(.*)",');
    final items = file.readAsLinesSync().topLevelCompactMap((line, lineNumber) {
      final itemMath = itemRegExp.firstMatch(line);
      final key = itemMath?.group(1);
      if (key != null) {
        return _Item(
          key: key,
          value: itemMath?.group(2),
          lineIndex: lineNumber,
        );
      }
    });

    return LocalizationInspectorData._(
      file: file,
      locale: locale,
      items: items,
    );
  }

  const LocalizationInspectorData._({
    required this.file,
    required this.locale,
    required List<_Item> items,
  }) : _items = items;

  final File file;
  final String locale;
  final List<_Item> _items;

  // TODO: add support for call method to exec all checks

  /// Search for intersections between localizations different features.
  /// If other localization has the same key or value.
  List<LocalizationInspectorException> findIntersections(
    LocalizationInspectorData other, {
    required bool findKeyAndValueDuplicates,
    required bool findKeyDuplicates,
    required bool findValueDuplicates,
  }) {
    final result = <LocalizationInspectorException>[];
    for (final item in _items) {
      for (final otherItem in other._items) {
        final keySame = item.key == otherItem.key;
        final valueSame = item.value == otherItem.value;

        void add(LocalizationInspectorExceptionType type) {
          result.addAll([
            item.toException(file: file, type: type),
            otherItem.toException(file: other.file, type: type),
          ]);
        }

        if (findKeyAndValueDuplicates && keySame && valueSame) {
          add(LocalizationInspectorExceptionType.keyAndValueSame);
        } else if (findKeyDuplicates && keySame) {
          add(LocalizationInspectorExceptionType.keySame);
        } else if (findValueDuplicates && valueSame) {
          add(LocalizationInspectorExceptionType.valueSame);
        }
      }
    }
    return result;
  }

  /// Search for missed keys between localizations for the same feature.
  /// If other localization has not the same key.
  List<LocalizationInspectorException> findMissedKeys(
    LocalizationInspectorData other,
  ) {
    final result = <LocalizationInspectorException>[];
    for (final item in _items) {
      final hasEqualKey = other._items.any((otherItem) {
        return otherItem.key == item.key;
      });
      if (!hasEqualKey) {
        result.addAll([
          item.toException(
            file: file,
            type: LocalizationInspectorExceptionType.keyMissed,
          ),
          item.copyWithLineNumber(0).toException(
                file: other.file,
                type: LocalizationInspectorExceptionType.keyMissed,
              ),
        ]);
      }
    }
    return result;
  }
}

class _Item {
  const _Item({
    required this.key,
    required this.value,
    required this.lineIndex,
  });

  final String key;
  final String? value;
  final int lineIndex;

  _Item copyWithLineNumber(int lineNumber) {
    return _Item(key: key, value: value, lineIndex: lineNumber);
  }

  LocalizationInspectorException toException({
    required File file,
    required LocalizationInspectorExceptionType type,
  }) {
    return LocalizationInspectorException(
      file: file,
      type: type,
      key: key,
      value: value,
      line: lineIndex,
    );
  }

  @override
  String toString() {
    return '$_Item{key: $key, value: $value, '
        'lineNumber: $lineIndex}';
  }
}

extension GroupLocalizationFileExtension on List<LocalizationInspectorData> {
  List<List<LocalizationInspectorData>> groupByLocale() {
    final result = <List<LocalizationInspectorData>>[];
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

  List<List<LocalizationInspectorData>> groupByFolder() {
    final result = <List<LocalizationInspectorData>>[];
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
