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
  return result;
}
