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
  lines.removeWhereIndexed((index, line) {
    final hasMatch = exp.hasMatch(line);
    if (hasMatch) {
      result.add(line);
      onRemove?.call(index, line);
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
    int startIndex = 0;
    multiline.add(line);
    final startMatch = start.allMatches(line, startIndex).firstOrNull;
    if (startMatch != null && !inMultiline) {
      inMultiline = true;
      startIndex = startMatch.end;
    }
    final endMatch = end.allMatches(line, startIndex).firstOrNull;
    if (endMatch != null && inMultiline) {
      inMultiline = false;
      startIndex = endMatch.end;
    }
    if (!inMultiline) {
      result.add(multiline.join('\n'));
      multiline.clear();
    }
  }
  lines
    ..clear()
    ..addAll(result);
  return;
}
