extension ARBLinesExtension on List<String> {
  /// Call [onTopLevelLine] for each top level line
  ///
  /// For example for this lines
  ///
  ///    "headerTitle": "Some title",
  ///    "@headerTitle": {
  ///      "description": "Header displayed...",
  ///      "type": "text",
  ///      "placeholders": {}
  ///    }
  ///    "Body": "Some other text",
  ///
  /// [onTopLevelLine] will be called only for strings
  ///    "headerTitle": "Some title",
  ///    "Body": "Some other text",
  /// any other string is not top level strings.
  void forEachTopLevelItem(
    void Function(String line, int lineNumber) onTopLevelLine,
  ) {
    final deepIncreaseExp = RegExp(r'\{');
    final deepDecreaseExp = RegExp(r'\}');

    int lineNumber = 0;
    int deep = 0;
    for (final line in this) {
      lineNumber += 1;

      deepIncreaseExp.allMatches(line).forEach((_) {
        deep += 1;
      });
      deepDecreaseExp.allMatches(line).forEach((_) {
        deep -= 1;
      });

      if (deep > 1) {
        continue;
      }

      onTopLevelLine(line, lineNumber);
    }
  }

  /// Map or [forEachTopLevelItem].
  List<T> topLevelCompactMap<T>(
    T? Function(String line, int lineNumber) callback,
  ) {
    final result = <T>[];
    forEachTopLevelItem((line, lineNumber) {
      final r = callback(line, lineNumber);
      if (r != null) {
        result.add(r);
      }
    });
    return result;
  }
}
