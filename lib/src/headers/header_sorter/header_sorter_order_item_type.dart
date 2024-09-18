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

  static List<HeaderSorterOrderItemType> mergeWithDefaultOrder(
    List<HeaderSorterOrderItemType> sortOrder,
  ) {
    final skipped = <HeaderSorterOrderItemType>[];
    for (final item in HeaderSorterOrderItemTypeExtension.defaultOrder()) {
      if (item == HeaderSorterOrderItemType.space) {
        if (skipped.isNotEmpty &&
            skipped.lastOrNull != HeaderSorterOrderItemType.space) {
          skipped.add(item);
        }
        continue;
      }
      if (sortOrder.contains(item)) {
        continue;
      }
      skipped.add(item);
    }
    final result = [
      ...sortOrder,
      if (skipped.isNotEmpty) HeaderSorterOrderItemType.space,
      ...skipped,
    ];

    void removeUniq(HeaderSorterOrderItemType type) {
      bool hasType = false;
      result.removeWhere((element) {
        if (element == type) {
          if (hasType) {
            return true;
          }
          hasType = true;
        }
        return false;
      });
    }

    void removeRepeat(HeaderSorterOrderItemType type) {
      HeaderSorterOrderItemType? previous;
      result.removeWhere((element) {
        if (element == type) {
          if (previous == type) {
            return true;
          }
        }
        previous = element;
        return false;
      });
    }

    for (final type in HeaderSorterOrderItemType.values) {
      if (type == HeaderSorterOrderItemType.space) {
        removeRepeat(type);
      } else {
        removeUniq(type);
      }
    }

    return result;
  }

  String get name => map[this]!;
}
