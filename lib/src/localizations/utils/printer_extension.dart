import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_exception.dart';

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
      switch (exception.type) {
        LocalizationInspectorExceptionType.keySame =>
          'Key ${e(exception.key)} is duplicated',
        LocalizationInspectorExceptionType.valueSame =>
          'Value ${e(exception.value?.sample())} is duplicated',
        LocalizationInspectorExceptionType.keyAndValueSame =>
          'Key ${e(exception.key)} and Value are duplicated',
        LocalizationInspectorExceptionType.keyMissed =>
          'Key ${e(exception.key)} is missed',
      },
    );
  }

  void exceptionAsGroupItem(LocalizationInspectorException exception) {
    c1(
      'file ${exception.asLink()} '
      '(${exception.key}: ${exception.value?.sample()})',
    );
  }
}
