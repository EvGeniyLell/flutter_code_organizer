import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_organizer/src/localizations/utils/arb_lines_extension.dart';

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
    final items = IOManager()
        .readFile(file)
        .split('\n')
        .topLevelCompactMapIndexed((lineIndex, line) {
      final itemMath = itemRegExp.firstMatch(line);
      final key = itemMath?.group(1);
      if (key != null) {
        return Item(
          key: key,
          value: itemMath?.group(2),
          lineIndex: lineIndex,
        );
      }
    });

    return LocalizationInspectorHandler.private(
      file: file,
      locale: locale,
      items: items,
    );
  }

  @visibleForTesting
  const LocalizationInspectorHandler.private({
    required this.file,
    required this.locale,
    required this.items,
  });

  final File file;
  final String locale;
  @visibleForTesting
  final List<Item> items;

  /// Search for intersections between localizations different features.
  /// If other localization has the same key or value.
  List<LocalizationInspectorException> findIntersections(
    LocalizationInspectorHandler other, {
    required bool findKeyAndValueDuplicates,
    required bool findKeyDuplicates,
    required bool findValueDuplicates,
  }) {
    final result = <LocalizationInspectorException>[];
    for (final item in items) {
      for (final otherItem in other.items) {
        final keySame = item.key == otherItem.key;
        final valueSame = item.value == otherItem.value;

        void add(LocalizationInspectorExceptionType type) {
          result.addAll([
            item.toException(file: file, type: type),
            otherItem.toException(file: other.file, type: type),
          ]);
        }

        if (findKeyAndValueDuplicates && keySame && valueSame) {
          add(LocalizationInspectorExceptionType.keyAndValueDuplicate);
        } else if (findKeyDuplicates && keySame) {
          add(LocalizationInspectorExceptionType.keyDuplicate);
        } else if (findValueDuplicates && valueSame) {
          add(LocalizationInspectorExceptionType.valueDuplicate);
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
    for (final item in items) {
      final hasEqualKey = other.items.any((otherItem) {
        return otherItem.key == item.key;
      });
      if (!hasEqualKey) {
        result.addAll([
          item.toException(
            file: file,
            type: LocalizationInspectorExceptionType.keyMissed,
          ),
          item.copyWithLineIndex(0).toException(
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
@immutable
class Item {
  const Item({
    required this.key,
    required this.value,
    required this.lineIndex,
  });

  final String key;
  final String? value;
  final int lineIndex;

  Item copyWithLineIndex(int lineIndex) {
    return Item(key: key, value: value, lineIndex: lineIndex);
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value &&
          lineIndex == other.lineIndex;

  @override
  int get hashCode => key.hashCode ^ value.hashCode ^ lineIndex.hashCode;

  @override
  String toString() {
    return '$Item{key: $key, value: $value, '
        'lineIndex: $lineIndex}';
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
        group.forEachWithEachNext((aLHandler, bLHandler) {
          exceptions.addAll(
            aLHandler.findIntersections(
              bLHandler,
              findKeyDuplicates: findKeyDuplicates,
              findValueDuplicates: findValueDuplicates,
              findKeyAndValueDuplicates: findKeyAndValueDuplicates,
            ),
          );
        });
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
        group.forEachWithEach((aLHandler, bLHandler) {
          exceptions.addAll(aLHandler.findMissedKeys(bLHandler));
        });
      });
    }
    return exceptions;
  }
}

@visibleForTesting
extension GroupLocalizationInspectorHandlerIterableExtension
    on Iterable<LocalizationInspectorHandler> {
  List<List<LocalizationInspectorHandler>> groupByLocale() {
    return groupBy((group, element) {
      return group.first.locale == element.locale;
    });
  }

  List<List<LocalizationInspectorHandler>> groupByFolder() {
    return groupBy((group, element) {
      return group.first.file.path.fromFilePathToDirPath() ==
          element.file.path.fromFilePathToDirPath();
    });
  }
}
