import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data_strategy_utils.dart';

class HeaderSorterDataPartsStrategy {
  factory HeaderSorterDataPartsStrategy(List<String> lines) {
    int? firstRemoveIndex;
    void onRemove(int index, String line) {
      firstRemoveIndex ??= index;
    }

    return HeaderSorterDataPartsStrategy._(
      parts: _parts(lines, onRemove: onRemove),
      firstRemoveIndex: firstRemoveIndex,
    );
  }

  HeaderSorterDataPartsStrategy._({
    required this.parts,
    required this.firstRemoveIndex,
  });

  final List<String> parts;

  final int? firstRemoveIndex;

  static List<String> _parts(
    List<String> lines, {
    required void Function(int index, String line) onRemove,
  }) =>
      removeLines(lines, pattern: r"^part '.*;$", onRemove: onRemove);
}
