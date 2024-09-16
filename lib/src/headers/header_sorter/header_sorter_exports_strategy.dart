import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:meta/meta.dart';

class HeaderSorterExportsStrategy {
  factory HeaderSorterExportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterExportsStrategy._(
      dartExports: _dartExports(lines, onRemove: onRemove),
      flutterExports: _flutterExports(lines, onRemove: onRemove),
      packageExports:
          _packageExports(lines, projectName: projectName, onRemove: onRemove),
      projectExports:
          _projectExports(lines, projectName: projectName, onRemove: onRemove),
      relativeExports: getRelative(lines, onRemove: onRemove),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterExportsStrategy._({
    required this.dartExports,
    required this.flutterExports,
    required this.packageExports,
    required this.projectExports,
    required this.firstRemoveIndex,
    required this.relativeExports,
  });

  final List<String> dartExports;
  final List<String> flutterExports;
  final List<String> packageExports;
  final List<String> projectExports;
  final List<String> relativeExports;

  final int? firstRemoveIndex;

  static List<String> _dartExports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'dart:.*;\$",
        onRemove: onRemove,
      );

  static List<String> _flutterExports(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'package:flutter/.*;\$",
        onRemove: onRemove,
      );

  static List<String> _packageExports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'package:(?:(?!$projectName).).*;\$",
        onRemove: onRemove,
      );

  static List<String> _projectExports(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'package:$projectName/.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getRelative(
      List<String> lines, {
        required void Function(int index, String line) onRemove,
      }) =>
      removeLines(
        lines,
        pattern: "^export '.*;\$",
        onRemove: onRemove,
      );


  List<String> sorted({
    required bool spaceDartFlutter,
    required bool spaceFlutterPackage,
    required bool spacePackageProject,
  }) {
    return [
      ...dartExports,
      if (spaceDartFlutter) ...[''],
      ...flutterExports,
      if (spaceDartFlutter) ...[''],
      ...packageExports,
      if (spaceDartFlutter) ...[''],
      ...projectExports,
    ];
  }
}
