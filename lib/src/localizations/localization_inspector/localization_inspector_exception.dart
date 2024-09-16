

import 'package:flutter_code_organizer/src/common/common_exception.dart';

class LocalizationInspectorException extends CommonException {
  const LocalizationInspectorException({
    required super.file,
    required this.type,
    required this.key,
    required this.value,
    required super.line,
    super.row,
  }) : super(source: 'key: $key, value: $value');

  final LocalizationInspectorExceptionType type;
  final String key;
  final String? value;
}

enum LocalizationInspectorExceptionType {
  keySame,
  valueSame,
  keyAndValueSame,
  keyMissed,
}

extension on LocalizationInspectorException {
  bool isCompatible(LocalizationInspectorException other) {
    return switch (type) {
      LocalizationInspectorExceptionType.keySame =>
        type == other.type && key == other.key,
      LocalizationInspectorExceptionType.valueSame =>
        type == other.type && value == other.value,
      LocalizationInspectorExceptionType.keyAndValueSame =>
        type == other.type && key == other.key && value == other.value,
      LocalizationInspectorExceptionType.keyMissed =>
        type == other.type && key == other.key,
    };
  }
}

extension GroupLocalizationFileExceptionExtension
    on List<LocalizationInspectorException> {
  List<List<LocalizationInspectorException>> groupByItem() {
    final result = <List<LocalizationInspectorException>>[];
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
