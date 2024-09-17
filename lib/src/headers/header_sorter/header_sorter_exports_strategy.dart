import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';

class HeaderSorterExportsStrategy {
  factory HeaderSorterExportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterExportsStrategy.private(
      dart: getDart(lines, onRemove: onRemove),
      flutter: getFlutter(lines, onRemove: onRemove),
      package: getPackage(lines, projectName: projectName, onRemove: onRemove),
      project: getProject(lines, projectName: projectName, onRemove: onRemove),
      relative: getRelative(lines, onRemove: onRemove),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  @visibleForTesting
  HeaderSorterExportsStrategy.private({
    required this.dart,
    required this.flutter,
    required this.package,
    required this.project,
    required this.relative,
    required this.firstRemoveIndex,
  });

  final List<String> dart;
  final List<String> flutter;
  final List<String> package;
  final List<String> project;
  final List<String> relative;

  final int? firstRemoveIndex;

  static List<String> getDart(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'dart:.*;\$",
        onRemove: onRemove,
      );

  static List<String> getFlutter(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'package:flutter/.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getPackage(
    List<String> lines, {
    required String projectName,
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^export 'package:(?:(?!$projectName).).*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getProject(
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
}
