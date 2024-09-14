// ignore_for_file: use_raw_strings

import 'dart:io';

import 'package:meta/meta.dart';

import '../../common/common_exception.dart';
import 'header_inspector_exception.dart';

class HeaderInspectorData {
  factory HeaderInspectorData({
    required File file,
    required String projectDir,
    required String projectName,
  }) {
    final lines = file.readAsLinesSync();
    return HeaderInspectorData.private(
      file: file,
      lines: lines,
      projectDir: projectDir,
      projectName: projectName,
    );
  }

  @visibleForTesting
  HeaderInspectorData.private({
    required this.file,
    required this.lines,
    required this.projectDir,
    required this.projectName,
  });

  final File file;
  final List<String> lines;
  final String projectDir;
  final String projectName;

  List<HeaderInspectorException> findAllExceptions() {
    final List<HeaderInspectorException> results = [];
    void addAll(List<HeaderInspectorException?> exceptions) {
      results.addAll(exceptions.whereType<HeaderInspectorException>());
    }

    int lineIndex = 0;
    for (final line in lines) {
      lineIndex += 1;
      final item = _Item(file: file, source: line, index: lineIndex);
      addAll([
        // imports
        forbiddenThemselfImports(item),
        forbiddenThemselfImports(item),
        forbiddenRelativeImports(item),
        // exports
        forbiddenPackageExports(item),
        forbiddenOtherFeaturesRelativeExports(item),
      ]);
    }

    return results;
  }
}

extension on HeaderInspectorData {
  /// Forbidden imports from the same feature
  /// Example:
  ///   for file: lib/src/feature/sub_feature/file.dart
  ///   forbidden:
  ///     import 'package:app/src/feature/sub_feature/file.dart';
  ///     import 'package:app/src/feature/sub_feature/sub_feature.dart';
  ///     import 'package:app/src/feature/feature.dart';
  HeaderInspectorException? forbiddenThemselfImports(_Item item) {
    final features = file.features(projectDir);
    for (int i = 0; i < features.length; i += 1) {
      final subFeatures = features.sublist(0, i + 1);
      final subPath = '${subFeatures.join('/')}/${subFeatures.last}';

      return item.findException(
        RegExp("^import 'package:$projectName/src/$subPath.dart';\$"),
        HeaderInspectorExceptionType.themselfImports,
      );
    }
    return null;
  }

  /// Forbidden relative imports
  /// Example:
  ///   import '../feature/sub_feature/file.dart';
  ///   import 'file.dart';
  HeaderInspectorException? forbiddenRelativeImports(_Item item) {
    return item.findException(
      RegExp("^import '(?!package:)"),
      HeaderInspectorExceptionType.relativeImports,
    );
  }

  /// Forbidden package exports
  /// Example:
  ///   export 'package:app/src/feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenPackageExports(_Item item) {
    return item.findException(
      RegExp("^export 'package:"),
      HeaderInspectorExceptionType.packageExports,
    );
  }

  /// Forbidden relative exports for other features
  /// Example:
  ///   export '../feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesRelativeExports(_Item item) {
    return item.findException(
      RegExp("^export '\\.\\./"),
      HeaderInspectorExceptionType.packageExports,
    );
  }
}

class _Item {
  _Item({
    required this.file,
    required this.source,
    required this.index,
  });

  final File file;
  final String source;
  final int index;

  HeaderInspectorException? findException(
    RegExp exp,
    HeaderInspectorExceptionType type,
  ) {
    final hasMatch = exp.hasMatch(source);
    if (hasMatch) {
      return HeaderInspectorException(
        file: file,
        type: type,
        line: index,
      );
    }
    return null;
  }
}

extension on File {
  List<String> features(String projectDir) {
    // print('File: $path');
    // print('    : $projectDir/lib/src/(.*)/[a-z_].dart');
    return RegExp('^$projectDir/lib/src/(.*)/[a-z_]+.dart\$')
            .firstMatch(path)
            ?.group(1)
            ?.split('/') ??
        [];
  }
}
