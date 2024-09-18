import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';

extension ArbLinesExtension on List<String> {
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
  @visibleForTesting
  void forEachTopLevelItemIndexed(
    void Function(int lineIndex, String line) onTopLevelLine,
  ) {
    final deepIncreaseExp = RegExp(r'\{');
    final deepDecreaseExp = RegExp(r'\}');

    int deep = 0;
    forEachIndexed((index, line) {
      deepIncreaseExp.allMatches(line).forEach((_) {
        deep += 1;
      });
      deepDecreaseExp.allMatches(line).forEach((_) {
        deep -= 1;
      });

      if (deep > 1) {
        return;
      }

      onTopLevelLine(index, line);
    });
  }

  /// Map for [forEachTopLevelItemIndexed].
  List<T> topLevelCompactMapIndexed<T>(
    T? Function(int lineIndex, String line) callback,
  ) {
    final result = <T>[];
    forEachTopLevelItemIndexed((lineIndex, line) {
      final r = callback(lineIndex, line);
      if (r != null) {
        result.add(r);
      }
    });
    return result;
  }
}
