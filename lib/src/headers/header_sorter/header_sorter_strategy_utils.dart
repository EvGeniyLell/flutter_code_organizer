import 'package:flutter_code_organizer/src/common/common.dart';

/// This function is used to remove lines from the list of [lines]
/// that match the [pattern].
/// It also calls the [onRemove] function on each removed line.
/// All removed lines are returned in a sorted list.
List<String> removeLines(
  List<String> lines, {
  required String pattern,
  required void Function(int index, String line)? onRemove,
}) {
  final result = <String>[];
  final exp = RegExp(pattern, dotAll: true);
  int lineNumber = 0;
  lines.removeWhere((line) {
    lineNumber++;
    final hasMatch = exp.hasMatch(line);
    if (hasMatch) {
      result.add(line);
      onRemove?.call(lineNumber - 1, line);
    }
    return hasMatch;
  });
  return result..sort((a, b) => a.compareTo(b));
}

void mergeMultilineLines(
  List<String> lines, {
  required String startPattern,
  required String endPattern,
}) {
  final result = <String>[];
  final multiline = <String>[];
  final start = RegExp(startPattern, dotAll: true);
  final end = RegExp(endPattern, dotAll: true);
  bool inMultiline = false;
  for (final line in lines) {
    final hasStart = start.hasMatch(line);
    if (hasStart) {
      inMultiline = true;
    }
    multiline.add(line);
    final hasEnd = end.hasMatch(line);
    if (hasEnd) {
      inMultiline = false;
    }
    if (!inMultiline) {
      result.add(multiline.join('\n'));
      multiline.clear();
    }
  }
  lines
    ..clear()
    ..addAll(result);

  Printer().debug(() => 'lines after $startPattern: ${lines.join('\n')}');
  return;
}
