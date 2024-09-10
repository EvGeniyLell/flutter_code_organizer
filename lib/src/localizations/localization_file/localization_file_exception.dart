import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_inspector/src/localizations/localization_file/localization_file.dart';

enum LocalizationFileExceptionType {
  keySame,
  valueSame,
  keyAndValueSame,
  keyMissed,
}

@immutable
class LocalizationFileException {
  const LocalizationFileException({
    required this.type,
    required this.item,
    required this.file,
  });

  final LocalizationFileExceptionType type;
  final LocalizationFileItem item;
  final File file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationFileException &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          item == other.item &&
          file == other.file;

  @override
  int get hashCode => type.hashCode ^ item.hashCode ^ file.hashCode;

  bool isCompatible(LocalizationFileException other) {
    return switch (type) {
      LocalizationFileExceptionType.keySame =>
        other.type == type && item.key == other.item.key,
      LocalizationFileExceptionType.valueSame =>
        other.type == type && item.value == other.item.value,
      LocalizationFileExceptionType.keyAndValueSame => other.type == type &&
          item.key == other.item.key &&
          item.value == other.item.value,
      LocalizationFileExceptionType.keyMissed =>
        other.type == type && item.key == other.item.key,
    };
  }

  @override
  String toString() {
    return '$LocalizationFileException{type: $type, item: $item}';
  }
}

extension GroupLocalizationFileExceptionExtension
    on List<LocalizationFileException> {
  List<List<LocalizationFileException>> groupByItem() {
    final result = <List<LocalizationFileException>>[];
    for (final item in this) {
      final index = result.indexWhere((group) {
        return group.first.isCompatible(item);
      });
      if (index == -1) {
        result.add([item]);
      } else {
        result[index].add(item);
      }
    }
    return result;
  }
}
