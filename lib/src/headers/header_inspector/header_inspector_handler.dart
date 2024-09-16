import 'dart:io';
import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:meta/meta.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';

class HeaderInspectorHandler {
  @visibleForTesting
  static List<String> Function(File file) reader =
      (File file) => file.readAsLinesSync();

  factory HeaderInspectorHandler({
    required File file,
    required String projectDir,
    required String projectName,
  }) {
    final lines = reader(file);
    return HeaderInspectorHandler.private(
      file: file,
      lines: lines,
      projectDir: projectDir,
      projectName: projectName,
    );
  }

  @visibleForTesting
  HeaderInspectorHandler.private({
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

    int lineIndex = 0;
    for (final line in lines) {
      lineIndex += 1;

      final exception = Item(
        file: file,
        projectName: projectName,
        source: line,
        index: lineIndex - 1,
        features: file.getProjectSRCFeaturesByPath(projectDir),
      ).findException(
        forbidThemselfPackageImports: forbidThemselfPackageImports,
        forbidOtherFeaturesPackageImports: forbidOtherFeaturesPackageImports,
        forbidRelativeImports: forbidRelativeImports,
        forbidPackageExports: forbidPackageExports,
        forbidOtherFeaturesRelativeExports: forbidOtherFeaturesRelativeExports,
      );

      if (exception != null) {
        results.add(exception);
      }
    }

    return results;
  }
}

@visibleForTesting
class Item {
  Item({
    required this.file,
    required this.projectName,
    required this.source,
    required this.index,
    required this.features,
  });

  final File file;
  final String projectName;
  final String source;
  final int index;
  final List<String> features;

  HeaderInspectorException? findException({
    required bool forbidThemselfPackageImports,
    required bool forbidOtherFeaturesPackageImports,
    required bool forbidRelativeImports,
    required bool forbidPackageExports,
    required bool forbidOtherFeaturesRelativeExports,
  }) {
    final actionsMap = {
      forbiddenThemselfPackageImports: forbidThemselfPackageImports,
      forbiddenRelativeImports: forbidRelativeImports,
      forbiddenOtherFeaturesPackageImports: forbidOtherFeaturesPackageImports,
      forbiddenPackageExports: forbidPackageExports,
      forbiddenOtherFeaturesRelativeExports: forbidOtherFeaturesRelativeExports,
    };

    for (final entry in actionsMap.entries) {
      final flag = entry.value;
      final action = entry.key;
      if (flag) {
        final exception = action();
        if (exception != null) {
          return exception;
        }
      }
    }

    return null;
  }
}

@visibleForTesting
extension ActionItemExtension on Item {
  HeaderInspectorException? findExceptionByCondition(
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

  /// Forbidden imports from the same feature
  /// Example:
  ///   for file: lib/src/feature/sub_feature/file.dart
  ///   forbidden:
  ///     import 'package:app/src/feature/sub_feature/file.dart';
  ///     import 'package:app/src/feature/sub_feature/sub_feature.dart';
  ///     import 'package:app/src/feature/feature.dart';
  HeaderInspectorException? forbiddenThemselfPackageImports() {
    for (int i = 0; i < features.length; i += 1) {
      final subFeatures = features.sublist(0, i + 1);
      final subPath = '${subFeatures.join('/')}/${subFeatures.last}';
      final result = findExceptionByCondition(
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
  HeaderInspectorException? forbiddenOtherFeaturesPackageImports() {
    final feature = features.firstOrNull;
    return findExceptionByCondition(
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
  HeaderInspectorException? forbiddenRelativeImports() {
    return findExceptionByCondition(
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
  HeaderInspectorException? forbiddenPackageExports() {
    final r =  findExceptionByCondition(
      Condition.pattern("^export 'package:$projectName/src"),
      HeaderInspectorExceptionType.packageExports,
    );
    if(r != null) {
      print('###');
      print(r);
      print(features.join('/'));
    }

    return findExceptionByCondition(
      Condition.pattern("^export 'package:$projectName/src"),
      HeaderInspectorExceptionType.packageExports,
    );
  }

  /// Forbidden relative exports for other features
  /// Example:
  ///   export '../feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesRelativeExports() {
    return findExceptionByCondition(
      Condition.pattern("^export '\\.\\./"),
      HeaderInspectorExceptionType.relativeExports,
    );
  }
}
