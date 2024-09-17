import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';
import 'package:meta/meta.dart';

import 'header_sorter_order_item_type.dart';

class HeaderSorterImportsStrategy {
  factory HeaderSorterImportsStrategy(
    List<String> lines, {
    required String projectName,
  }) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterImportsStrategy.private(
      dart: getDartImports(lines, onRemove: onRemove),
      flutter: getFlutter(lines, onRemove: onRemove),
      package: getPackage(lines, projectName: projectName, onRemove: onRemove),
      project: getProject(lines, projectName: projectName, onRemove: onRemove),
      relative: getRelative(lines, onRemove: onRemove),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  @visibleForTesting
  HeaderSorterImportsStrategy.private({
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
  static List<String> getFlutter(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import 'package:flutter/.*;\$",
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
        pattern: "^import 'package:(?:(?!$projectName).).*;\$",
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
        pattern: "^import 'package:$projectName/.*;\$",
        onRemove: onRemove,
      );

  @visibleForTesting
  static List<String> getRelative(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(
        lines,
        pattern: "^import '.*;\$",
        onRemove: onRemove,
      );

}
