import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_strategy_utils.dart';

class HeaderSorterDataExportsStrategy {
  factory HeaderSorterDataExportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterDataExportsStrategy._(
      dartExports: _dartExports(lines, onRemove: onRemove),
      flutterExports: _flutterExports(lines, onRemove: onRemove),
      packageExports: _packageExports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      projectExports: _projectExports(
        lines,
        projectName: projectName,
        onRemove: onRemove,
      ),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterDataExportsStrategy._({
    required this.dartExports,
    required this.flutterExports,
    required this.packageExports,
    required this.projectExports,
    required this.firstRemoveIndex,
  });

  final List<String> dartExports;
  final List<String> flutterExports;
  final List<String> packageExports;
  final List<String> projectExports;

  final int? firstRemoveIndex;

  static List<String> _dartExports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^export 'dart:.*;$",
        onRemove: onRemove,
      );

  static List<String> _flutterExports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^export 'package:flutter/.*;$",
        onRemove: onRemove,
      );

  static List<String> _packageExports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^export 'package:(?:(?!$projectName).).*;$",
        onRemove: onRemove,
      );

  static List<String> _projectExports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: r"^export 'package:$projectName/.*;$",
        onRemove: onRemove,
      );
}
