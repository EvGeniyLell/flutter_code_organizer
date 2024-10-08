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
      HeaderInspectorExceptionType.themselfPackageImport => e('Self imports'),
      HeaderInspectorExceptionType.otherFeaturesPackageImport =>
        e('Other features import'),
      HeaderInspectorExceptionType.relativeImport => e('Relative import'),
      HeaderInspectorExceptionType.packageExport => e('Package export'),
      HeaderInspectorExceptionType.otherFeaturesRelativeExport =>
        e('Other feature relative export'),
    };

    c1('file ${exception.asLink()} ($description)');
  }
}

extension PrinterHeaderSorterExceptionExtension on Printer {
  void savedFiles(List<File> files, {String? currentPath}) {
    if (files.isNotEmpty) {
      d1('sorted files:');
      for (final file in files) {
        c1('file ${file.path}');
      }
    }
  }
}
