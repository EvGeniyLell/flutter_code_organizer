import 'dart:io';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';

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
      HeaderInspectorExceptionType.themselfPackageImports => e('Self imports'),
      HeaderInspectorExceptionType.otherFeaturesPackageImports =>
        e('Other features imports'),
      HeaderInspectorExceptionType.relativeImports => e('Relative imports'),
      HeaderInspectorExceptionType.packageExports => e('Package exports'),
      HeaderInspectorExceptionType.relativeExports => e('Relative exports'),
    };

    c1('file ${exception.asLink()} ($description)');
  }
}

extension PrinterHeaderSorterExceptionExtension on Printer {
  void savedFiles(List<File> files, {required String currentPath}) {
    for (final file in files) {
      d1('file ${file.getRelativePath(currentPath)}:0');
    }
  }
}
