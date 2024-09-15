// ignore_for_file: use_raw_strings

import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_inspector/src/headers/header_inspector_data/header_inspector_exception.dart';

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

  List<HeaderInspectorException> findAllExceptions({
    required bool forbidThemselfPackageImports,
    required bool forbidOtherFeaturesPackageImports,
    required bool forbidRelativeImports,
    required bool forbidPackageExports,
    required bool forbidOtherFeaturesRelativeExports,
  }) {
    final List<HeaderInspectorException> results = [];
    void addAll(List<HeaderInspectorException?> exceptions) {
      results.addAll(exceptions.whereType<HeaderInspectorException>());
    }

    int lineIndex = 0;
    for (final line in lines) {
      //lineIndex += 1;
      final item = _Item(
        file: file,
        source: line,
        index: lineIndex++,
        features: file.features(projectDir),
      );

      addAll([
        // imports
        if (forbidThemselfPackageImports) forbiddenThemselfPackageImports(item),
        if (forbidRelativeImports) forbiddenRelativeImports(item),
        if (forbidOtherFeaturesPackageImports)
          forbiddenOtherFeaturesPackageImports(item),
        // exports
        if (forbidPackageExports) forbiddenPackageExports(item),
        if (forbidOtherFeaturesRelativeExports)
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
  HeaderInspectorException? forbiddenThemselfPackageImports(_Item item) {
    for (int i = 0; i < item.features.length; i += 1) {
      final subFeatures = item.features.sublist(0, i + 1);
      final subPath = '${subFeatures.join('/')}/${subFeatures.last}';
      final result = item.findException(
        Condition.pattern(
          "^import 'package:$projectName/src/$subPath.dart';\$",
        ),
        HeaderInspectorExceptionType.themselfPackageImports,
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Forbidden imports from other features deep files
  /// Example:
  ///   for file: lib/src/feature/sub_feature/file.dart
  ///   forbidden:
  ///     import 'package:app/src/other_feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesPackageImports(_Item item) {
    final feature = item.features.firstOrNull;
    return item.findException(
      Condition.every([
        Condition.pattern("^import 'package:$projectName/src/(?!$feature)"),
        Condition.pattern(
          "^import 'package:$projectName/src/[a-z0-9_]+\\.dart'",
          expectation: false,
        ),
        Condition.pattern(
          "^import 'package:$projectName/src/([a-z0-9_]+/)*([a-z0-9_]+)/\\2\\.dart'",
          expectation: false,
        ),
      ]),
      HeaderInspectorExceptionType.otherFeaturesPackageImports,
    );
  }

  /// Forbidden relative imports
  /// Example:
  ///   import '../feature/sub_feature/file.dart';
  ///   import 'file.dart';
  HeaderInspectorException? forbiddenRelativeImports(_Item item) {
    return item.findException(
      Condition.every([
        Condition.pattern("^import '(?!package:)"),
        Condition.pattern("^import '(?!dart:)"),
      ]),
      HeaderInspectorExceptionType.relativeImports,
    );
  }

  /// Forbidden package exports
  /// Example:
  ///   export 'package:app/src/feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenPackageExports(_Item item) {
    return item.findException(
      Condition.pattern("^export '(?!package:$projectName/src):"),
      HeaderInspectorExceptionType.packageExports,
    );
  }

  /// Forbidden relative exports for other features
  /// Example:
  ///   export '../feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesRelativeExports(_Item item) {
    return item.findException(
      Condition.pattern("^export '\\.\\./"),
      HeaderInspectorExceptionType.relativeExports,
    );
  }
}

class _Item {
  _Item({
    required this.file,
    required this.source,
    required this.index,
    required this.features,
  });

  final File file;
  final String source;
  final int index;
  final List<String> features;

  HeaderInspectorException? findException(
    Condition condition,
    HeaderInspectorExceptionType type,
  ) {
    if (condition.test(source)) {
      return HeaderInspectorException(
        file: file,
        source: source,
        type: type,
        line: index,
      );
    }
    return null;
  }
}

abstract class Condition {
  const Condition();

  factory Condition.pattern(
    String pattern, {
    bool expectation = true,
  }) =>
      ConditionExp(exp: RegExp(pattern), expectation: expectation);

  factory Condition.exp(
    RegExp exp, {
    bool expectation = true,
  }) =>
      ConditionExp(exp: exp, expectation: expectation);

  factory Condition.any(List<Condition> subConditions) =>
      ConditionAny(subConditions);

  factory Condition.every(List<Condition> subConditions) =>
      ConditionEvery(subConditions);

  bool test(String source);
}

class ConditionExp extends Condition {
  const ConditionExp({
    required this.exp,
    this.expectation = true,
  });

  final RegExp exp;
  final bool expectation;

  @override
  bool test(String source) {
    return exp.hasMatch(source) == expectation;
  }
}

class ConditionAny extends Condition {
  const ConditionAny(this.subConditions);

  final List<Condition> subConditions;

  @override
  bool test(String source) {
    return subConditions.any((condition) => condition.test(source));
  }
}

class ConditionEvery extends Condition {
  const ConditionEvery(this.subConditions);

  final List<Condition> subConditions;

  @override
  bool test(String source) {
    return subConditions.every((condition) => condition.test(source));
  }
}

extension on File {
  List<String> features(String projectDir) {
    // print('File: $path');
    // print('    : $projectDir/lib/src/(.*)/[a-z_].dart');
    return RegExp('^$projectDir/lib/src/(.*)/[a-z_\\.]+.dart\$')
            .firstMatch(path)
            ?.group(1)
            ?.split('/') ??
        [];
  }
}
