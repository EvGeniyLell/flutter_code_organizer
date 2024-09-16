import 'dart:io';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_organizer/src/localizations/utils/arb_lines_extension.dart';
import 'package:meta/meta.dart';

class LocalizationInspectorHandler {
  factory LocalizationInspectorHandler({
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
        return Item(
          key: key,
          value: itemMath?.group(2),
          lineIndex: lineNumber,
        );
      }
    });

    return LocalizationInspectorHandler._(
      file: file,
      locale: locale,
      items: items,
    );
  }

  const LocalizationInspectorHandler._({
    required this.file,
    required this.locale,
    required List<Item> items,
  }) : _items = items;

  final File file;
  final String locale;
  final List<Item> _items;

  /// Search for intersections between localizations different features.
  /// If other localization has the same key or value.
  List<LocalizationInspectorException> findIntersections(
    LocalizationInspectorHandler other, {
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
    LocalizationInspectorHandler other,
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

@visibleForTesting
class Item {
  const Item({
    required this.key,
    required this.value,
    required this.lineIndex,
  });

  final String key;
  final String? value;
  final int lineIndex;

  Item copyWithLineNumber(int lineNumber) {
    return Item(key: key, value: value, lineIndex: lineNumber);
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
    return '$Item{key: $key, value: $value, '
        'lineNumber: $lineIndex}';
  }
}

extension GroupLocalizationInspectorHandlerIterableExtension
    on Iterable<LocalizationInspectorHandler> {
  List<List<LocalizationInspectorHandler>> groupByLocale() {
    final result = <List<LocalizationInspectorHandler>>[];
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

  List<List<LocalizationInspectorHandler>> groupByFolder() {
    final result = <List<LocalizationInspectorHandler>>[];
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

extension FindLocalizationInspectorHandlerIterableExtension
    on Iterable<LocalizationInspectorHandler> {
  Set<LocalizationInspectorException> findDuplicates({
    required bool findKeyAndValueDuplicates,
    required bool findKeyDuplicates,
    required bool findValueDuplicates,
  }) {
    final exceptions = <LocalizationInspectorException>{};
    if (findKeyDuplicates || findValueDuplicates || findKeyAndValueDuplicates) {
      groupByLocale().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = aIndex + 1; bIndex < group.length; bIndex += 1) {
            final aLHandler = group[aIndex];
            final bLHandler = group[bIndex];
            exceptions.addAll(
              aLHandler.findIntersections(
                bLHandler,
                findKeyDuplicates: findKeyDuplicates,
                findValueDuplicates: findValueDuplicates,
                findKeyAndValueDuplicates: findKeyAndValueDuplicates,
              ),
            );
          }
        }
      });
    }
    return exceptions;
  }

  Set<LocalizationInspectorException> findMissed({
    required bool findMissedKeys,
  }) {
    final exceptions = <LocalizationInspectorException>{};
    if (findMissedKeys) {
      groupByFolder().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = 0; bIndex < group.length; bIndex += 1) {
            if (aIndex == bIndex) {
              continue;
            }
            final aLHandler = group[aIndex];
            final bLHandler = group[bIndex];
            exceptions.addAll(aLHandler.findMissedKeys(bLHandler));
          }
        }
      });
    }
    return exceptions;
  }
}
