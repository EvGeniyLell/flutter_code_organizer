import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:meta/meta.dart';

class HeaderSorterImportsStrategy {
  factory HeaderSorterImportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterImportsStrategy._(
      dartImports: getDartImports(
        lines,
        onRemove: onRemove,
      ),
      flutterImports: getFlutterImports(
        lines,
        onRemove: onRemove,
      ),
      packageImports: getPackageImports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      projectImports: getProjectImports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      relativeImports: getRelativeImports(
        lines,
        onRemove: onRemove,
      ),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterImportsStrategy._({
    required this.dartImports,
    required this.flutterImports,
    required this.packageImports,
    required this.projectImports,
    required this.firstRemoveIndex,
    required this.relativeImports,
  });

  final List<String> dartImports;
  final List<String> flutterImports;
  final List<String> packageImports;
  final List<String> projectImports;
  final List<String> relativeImports;

  final int? firstRemoveIndex;

  @visibleForTesting
  static List<String> getDartImports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import 'dart:.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getFlutterImports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import 'package:flutter/.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getPackageImports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import 'package:(?:(?!$projectName).).*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getProjectImports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import 'package:$projectName/.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getRelativeImports(
      List<String> lines, {
        required void Function(int index, String line) onRemove,
      }) =>
      removeLines(
        lines,
        pattern: "^import '.*;\$",
        onRemove: onRemove,
      );

  List<String> sorted({
    required bool spaceDartFlutter,
    required bool spaceFlutterPackage,
    required bool spacePackageProject,
  }) {
    return [
      ...dartImports,
      if (spaceDartFlutter) ...[''],
      ...flutterImports,
      if (spaceDartFlutter) ...[''],
      ...packageImports,
      if (spaceDartFlutter) ...[''],
      ...projectImports,
    ];
  }
}
