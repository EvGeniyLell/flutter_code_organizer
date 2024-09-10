import 'package:colorize/colorize.dart';
import 'package:flutter_code_inspector/src/localizations/localization_file/localization_file_exception.dart';
import 'package:flutter_code_inspector/src/common/common.dart';

extension LocalizationFileExceptionUiExtension on LocalizationFileException {
  String toIssue() {
    String e(String? message) {
      return Colorize(message ?? 'null').red().toString();
    }

    return switch (type) {
      LocalizationFileExceptionType.keySame =>
        'Key ${e(item.key)} is duplicated',
      LocalizationFileExceptionType.valueSame =>
        'Value ${e(item.value?.sample(10))} is duplicated',
      LocalizationFileExceptionType.keyAndValueSame =>
        'Key ${e(item.key)} and Value are duplicated',
      LocalizationFileExceptionType.keyMissed => 'Key ${e(item.key)} is missed',
    };
  }

  String toLink() {
    return '${file.path}:${item.lineNumber} '
        '(${item.key}: ${item.value?.sample(10)})';
  }
}
