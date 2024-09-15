
import 'package:flutter_code_inspector/src/common/common_exception.dart';


class HeaderInspectorException extends CommonException {
  const HeaderInspectorException({
    required super.file,
    required super.source,
    required this.type,
    required super.line,
    super.row,
  });

  final HeaderInspectorExceptionType type;
}

enum HeaderInspectorExceptionType {
  themselfPackageImports,
  otherFeaturesPackageImports,
  relativeImports,
  packageExports,
  relativeExports,
}
