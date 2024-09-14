import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_strategy_utils.dart';

class HeaderSorterDataImportsStrategy {
  factory HeaderSorterDataImportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterDataImportsStrategy._(
      dartImports: _dartImports(lines, onRemove: onRemove),
      flutterImports: _flutterImports(lines, onRemove: onRemove),
      packageImports: _packageImports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      projectImports: _projectImports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterDataImportsStrategy._({
    required this.dartImports,
    required this.flutterImports,
    required this.packageImports,
    required this.projectImports,
    required this.firstRemoveIndex,
  });

  final List<String> dartImports;
  final List<String> flutterImports;
  final List<String> packageImports;
  final List<String> projectImports;

  final int? firstRemoveIndex;

  static List<String> _dartImports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^import 'dart:.*;$",
        onRemove: onRemove,
      );

  static List<String> _flutterImports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^import 'package:flutter/.*;$",
        onRemove: onRemove,
      );

  static List<String> _packageImports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^import 'package:(?:(?!$projectName).).*;$",
        onRemove: onRemove,
      );

  static List<String> _projectImports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^import 'package:$projectName/.*;$",
        onRemove: onRemove,
      );
}
