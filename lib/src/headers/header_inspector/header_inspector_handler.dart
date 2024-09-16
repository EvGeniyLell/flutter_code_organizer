import 'dart:io';
import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:meta/meta.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';

class HeaderInspectorHandler {
  factory HeaderInspectorHandler({
    required File file,
    required String projectDir,
    required String projectName,
  }) {
    final lines = file.readAsLinesSync();
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
    final actionsMap = {
      forbidThemselfPackageImports: forbiddenThemselfPackageImports,
      forbidRelativeImports: forbiddenRelativeImports,
      forbidOtherFeaturesPackageImports: forbiddenOtherFeaturesPackageImports,
      forbidPackageExports: forbiddenPackageExports,
      forbidOtherFeaturesRelativeExports: forbiddenOtherFeaturesRelativeExports,
    };

    int lineIndex = 0;
    for (final line in lines) {
      final item = Item(
        file: file,
        source: line,
        index: lineIndex,
        features: file.getProjectSRCFeaturesByPath(projectDir),
      );
      lineIndex += 1;

      for (final entry in actionsMap.entries) {
        final flag = entry.key;
        final action = entry.value;
        if (flag) {
          final exception = action(item);
          if (exception != null) {
            results.add(exception);
            break;
          }
        }
      }
    }

    return results;
  }
}

extension on HeaderInspectorHandler {
  /// Forbidden imports from the same feature
  /// Example:
  ///   for file: lib/src/feature/sub_feature/file.dart
  ///   forbidden:
  ///     import 'package:app/src/feature/sub_feature/file.dart';
  ///     import 'package:app/src/feature/sub_feature/sub_feature.dart';
  ///     import 'package:app/src/feature/feature.dart';
  HeaderInspectorException? forbiddenThemselfPackageImports(Item item) {
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
  HeaderInspectorException? forbiddenOtherFeaturesPackageImports(Item item) {
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
  HeaderInspectorException? forbiddenRelativeImports(Item item) {
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
  HeaderInspectorException? forbiddenPackageExports(Item item) {
    return item.findException(
      Condition.pattern("^export '(?!package:$projectName/src):"),
      HeaderInspectorExceptionType.packageExports,
    );
  }

  /// Forbidden relative exports for other features
  /// Example:
  ///   export '../feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesRelativeExports(Item item) {
    return item.findException(
      Condition.pattern("^export '\\.\\./"),
      HeaderInspectorExceptionType.relativeExports,
    );
  }
}

@visibleForTesting
class Item {
  Item({
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
