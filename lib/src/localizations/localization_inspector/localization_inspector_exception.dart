import 'dart:io';

import 'package:flutter_code_inspector/src/common/common_exception.dart';

class LocalizationInspectorException
    extends CommonException<LocalizationInspectorExceptionDescription> {
  factory LocalizationInspectorException({
    required File file,
    required LocalizationInspectorExceptionType type,
    required String key,
    required String? value,
    required int line,
    int? row,
  }) {
    return LocalizationInspectorException._(
      file: file,
      description: LocalizationInspectorExceptionDescription(
        type: type,
        key: key,
        value: value,
      ),
      line: line,
      row: row,
    );
  }

  const LocalizationInspectorException._({
    required super.file,
    required super.description,
    required super.line,
    super.row,
  });
}

enum LocalizationInspectorExceptionType {
  keySame,
  valueSame,
  keyAndValueSame,
  keyMissed,
}

class LocalizationInspectorExceptionDescription {
  const LocalizationInspectorExceptionDescription({
    required this.type,
    required this.key,
    required this.value,
  });

  final LocalizationInspectorExceptionType type;
  final String key;
  final String? value;

  @override
  String toString() {
    return '$LocalizationInspectorExceptionDescription'
        '{type: $type, key: $key, value: $value}';
  }
}

extension on LocalizationInspectorExceptionDescription {
  bool isCompatible(LocalizationInspectorExceptionDescription other) {
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
        return group.first.description.isCompatible(item.description);
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
