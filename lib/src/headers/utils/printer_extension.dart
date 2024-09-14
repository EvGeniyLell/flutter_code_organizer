import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/headers/header_inspector_data/header_inspector_exception.dart';

extension PrinterHeaderInspectorExceptionExtension on Printer {
  void exceptionsGroups(List<List<HeaderInspectorException>> groups) {
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

  void exceptionAsGroupHeader(HeaderInspectorException exception) {
    d1('file ${exception.file.path.split('/').last}');
  }

  void exceptionAsGroupItem(HeaderInspectorException exception) {
    String e(String? message) => colorizeError(message ?? 'null');

    final description = switch (exception.type) {
      HeaderInspectorExceptionType.themselfImports => e('Self imports'),
      HeaderInspectorExceptionType.relativeImports => e('Relative imports'),
      HeaderInspectorExceptionType.packageExports => e('Package exports'),
      HeaderInspectorExceptionType.relativeExports => e('Relative exports'),
    };

    c1('file ${exception.asLink()} ($description)');
  }
}
