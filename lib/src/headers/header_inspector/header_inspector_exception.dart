import 'package:flutter_code_organizer/src/common/common.dart';

class HeaderInspectorException extends CommonException {
  const HeaderInspectorException({
    required super.file,
    required super.source,
    required this.type,
    required super.line,
    super.row,
  });

  final HeaderInspectorExceptionType type;

  @override
  String toString() {
    return '$HeaderInspectorException{'
        'type:${type.name}, source: $source, '
        'link: ${asLink()}}';
  }
}

enum HeaderInspectorExceptionType {
  themselfPackageImport,
  otherFeaturesPackageImport,
  relativeImport,
  packageExport,
  otherFeaturesRelativeExport,
}

extension GroupHeaderInspectorExceptionListExtension
    on List<HeaderInspectorException> {
  List<List<HeaderInspectorException>> groupByFile() {
    final grouped = <String, List<HeaderInspectorException>>{};
    for (final exception in this) {
      (grouped[exception.file.path] ??= []).add(exception);
    }
    return grouped.values.toList();
  }
}
