import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/localizations/localization_inspector/localization_inspector_exception.dart';

extension PrinterLocalizationInspectorExceptionExtension on Printer {
  void exceptionsGroups(List<List<LocalizationInspectorException>> groups) {
    final printer = Printer();
    for (final group in groups) {
      final headerException = group.firstOrNull;
      if (headerException != null) {
        printer.exceptionAsGroupHeader(headerException);
        for (final itemException in group) {
          printer.exceptionAsGroupItem(itemException);
        }
      }
    }
  }

  void exceptionAsGroupHeader(LocalizationInspectorException exception) {
    String e(String? message) => colorizeError(message ?? 'null');

    d1(
      switch (exception.description.type) {
        LocalizationInspectorExceptionType.keySame =>
          'Key ${e(exception.description.key)} is duplicated',
        LocalizationInspectorExceptionType.valueSame =>
          'Value ${e(exception.description.value?.sample())} is duplicated',
        LocalizationInspectorExceptionType.keyAndValueSame =>
          'Key ${e(exception.description.key)} and Value are duplicated',
        LocalizationInspectorExceptionType.keyMissed =>
          'Key ${e(exception.description.key)} is missed',
      },
    );
  }

  void exceptionAsGroupItem(LocalizationInspectorException exception) {
    final description = exception.description;
    c1(
      'file ${exception.asLink()} '
      '(${description.key}: ${description.value?.sample()})',
    );
  }
}
