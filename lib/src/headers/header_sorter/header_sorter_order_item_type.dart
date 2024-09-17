enum HeaderSorterOrderItemType {
  space,
  importDart,
  importFlutter,
  importPackage,
  importProject,
  importRelative,
  exportDart,
  exportFlutter,
  exportPackage,
  exportProject,
  exportRelative,
  part,
}

extension HeaderSorterOrderItemTypeExtension on HeaderSorterOrderItemType {
  static const Map<HeaderSorterOrderItemType, String> map = {
    HeaderSorterOrderItemType.space: 'space',
    HeaderSorterOrderItemType.importDart: 'import_dart',
    HeaderSorterOrderItemType.importFlutter: 'import_flutter',
    HeaderSorterOrderItemType.importPackage: 'import_package',
    HeaderSorterOrderItemType.importProject: 'import_project',
    HeaderSorterOrderItemType.importRelative: 'import_relative',
    HeaderSorterOrderItemType.exportDart: 'export_dart',
    HeaderSorterOrderItemType.exportFlutter: 'export_flutter',
    HeaderSorterOrderItemType.exportPackage: 'export_package',
    HeaderSorterOrderItemType.exportProject: 'export_project',
    HeaderSorterOrderItemType.exportRelative: 'export_relative',
    HeaderSorterOrderItemType.part: 'part',
  };

  static List<HeaderSorterOrderItemType> enumListFromStrings(
    List<String> strings,
  ) {
    final List<HeaderSorterOrderItemType> result = [];
    final entries = map.entries;
    for (final string in strings) {
      for (final entry in entries) {
        if (entry.value == string) {
          result.add(entry.key);
          break;
        }
      }
    }
    return result;
  }

  static List<HeaderSorterOrderItemType> defaultOrder() => [
        HeaderSorterOrderItemType.importDart,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.importFlutter,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.importPackage,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.importProject,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.importRelative,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.exportDart,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.exportFlutter,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.exportPackage,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.exportProject,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.exportRelative,
        HeaderSorterOrderItemType.space,
        HeaderSorterOrderItemType.part,
      ];

  String get name => map[this]!;
}
