import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_strategy_utils.dart';

class HeaderSorterPartsStrategy {
  factory HeaderSorterPartsStrategy(List<String> lines) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
      if (index < (firstRemoveIndex ?? 0)) {
        firstRemoveIndex = index;
      }
    }

    mergeMultilineLines(lines, startPattern: "^part '", endPattern: ';\$');
    return HeaderSorterPartsStrategy._(
      parts: _parts(lines, onRemove: onRemove),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterPartsStrategy._({
    required this.parts,
    required this.firstRemoveIndex,
  });

  final List<String> parts;

  final int? firstRemoveIndex;

  static List<String> _parts(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(lines, pattern: "^part '.*;\$", onRemove: onRemove);
}
