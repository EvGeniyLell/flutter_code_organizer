import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:flutter_code_organizer/src/headers/utils/remote_config.dart';

typedef ItemBuilder = Item Function({
  required List<String> features,
  required File file,
  required int index,
  required String projectDir,
  required String projectName,
  required String source,
});

class HeaderInspectorHandler {
  factory HeaderInspectorHandler({
    required File file,
    required String projectDir,
    required String projectName,
    ItemBuilder? itemBuilder,
  }) {
    final features = file.getProjectSrcFeaturesByPath(projectDir);
    final items =
        IOManager().readFile(file).split('\n').mapIndexed((index, line) {
      return (itemBuilder ?? Item.new)(
        file: file,
        projectName: projectName,
        projectDir: projectDir,
        source: line,
        index: index,
        features: features,
      );
    });

    return HeaderInspectorHandler.private(
      file: file,
      items: items,
      projectDir: projectDir,
      projectName: projectName,
    );
  }

  @visibleForTesting
  HeaderInspectorHandler.private({
    required this.file,
    required this.items,
    required this.projectDir,
    required this.projectName,
  });

  final File file;
  final Iterable<Item> items;
  final String projectDir;
  final String projectName;

  List<HeaderInspectorException> findAllExceptions({
    required RemoteInspectorForbidConfig forbidThemselfPackageImports,
    required RemoteInspectorForbidConfig forbidOtherFeaturesPackageImports,
    required RemoteInspectorForbidConfig forbidRelativeImports,
    required RemoteInspectorForbidConfig forbidPackageExports,
    required RemoteInspectorForbidConfig forbidOtherFeaturesRelativeExports,
  }) {
    final List<HeaderInspectorException> results = [];

    for (final item in items) {
      final exception = item.findException(
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
  const Item({
    required this.file,
    required this.projectName,
    required this.projectDir,
    required this.source,
    required this.index,
    required this.features,
  });

  final File file;
  final String projectName;
  final String projectDir;
  final String source;
  final int index;
  final List<String> features;

  HeaderInspectorException? findException({
    required RemoteInspectorForbidConfig forbidThemselfPackageImports,
    required RemoteInspectorForbidConfig forbidOtherFeaturesPackageImports,
    required RemoteInspectorForbidConfig forbidRelativeImports,
    required RemoteInspectorForbidConfig forbidPackageExports,
    required RemoteInspectorForbidConfig forbidOtherFeaturesRelativeExports,
  }) {
    final actionsMap = {
      forbiddenThemselfPackageImports: forbidThemselfPackageImports,
      forbiddenRelativeImports: forbidRelativeImports,
      forbiddenOtherFeaturesPackageImports: forbidOtherFeaturesPackageImports,
      forbiddenPackageExports: forbidPackageExports,
      forbiddenOtherFeaturesRelativeExports: forbidOtherFeaturesRelativeExports,
    };

    for (final entry in actionsMap.entries) {
      final forbid = entry.value;
      final action = entry.key;

      // skip if forbid disabled
      if (!forbid.enabled.value) {
        continue;
      }

      // skip file if it in ignore list.
      if (forbid.ignoreFiles.value.any((pattern) {
        return RegExp(pattern).hasMatch(file.getRelativePath(projectDir));
      })) {
        continue;
      }

      final exception = action();
      if (exception != null) {
        return exception;
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
        HeaderInspectorExceptionType.themselfPackageImport,
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
      HeaderInspectorExceptionType.otherFeaturesPackageImport,
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
      HeaderInspectorExceptionType.relativeImport,
    );
  }

  /// Forbidden package exports
  /// Example:
  ///   export 'package:app/src/feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenPackageExports() {
    return findExceptionByCondition(
      Condition.pattern("^export 'package:$projectName/src"),
      HeaderInspectorExceptionType.packageExport,
    );
  }

  /// Forbidden relative exports for other features
  /// Example:
  ///   export '../feature/sub_feature/file.dart';
  HeaderInspectorException? forbiddenOtherFeaturesRelativeExports() {
    return findExceptionByCondition(
      Condition.pattern("^export '\\.\\./"),
      HeaderInspectorExceptionType.otherFeaturesRelativeExport,
    );
  }
}
