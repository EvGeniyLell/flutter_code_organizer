import 'package:flutter_code_organizer/src/common/common.dart';

class LocalizationInspectorException extends CommonException {
  const LocalizationInspectorException({
    required super.file,
    required this.type,
    required this.key,
    required this.value,
    required super.line,
  }) : super(source: 'key: $key, value: $value');

  final LocalizationInspectorExceptionType type;
  final String key;
  final String? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is LocalizationInspectorException &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode =>
      super.hashCode ^ type.hashCode ^ key.hashCode ^ value.hashCode;

  @override
  String toString() {
    return '$LocalizationInspectorException'
        '{link: ${asLink()}, type: $type, key: $key, value: $value}';
  }
}

enum LocalizationInspectorExceptionType {
  keyDuplicate,
  valueDuplicate,
  keyAndValueDuplicate,
  keyMissed,
}

extension on LocalizationInspectorException {
  bool isCompatible(LocalizationInspectorException other) {
    return switch (type) {
      LocalizationInspectorExceptionType.keyDuplicate =>
        type == other.type && key == other.key,
      LocalizationInspectorExceptionType.valueDuplicate =>
        type == other.type && value == other.value,
      LocalizationInspectorExceptionType.keyAndValueDuplicate =>
        type == other.type && key == other.key && value == other.value,
      LocalizationInspectorExceptionType.keyMissed =>
        type == other.type && key == other.key,
    };
  }
}

extension GroupLocalizationFileExceptionExtension
    on List<LocalizationInspectorException> {
  List<List<LocalizationInspectorException>> groupByItem() {
    return groupBy((group, element) {
      return group.first.isCompatible(element);
    });
  }
}
