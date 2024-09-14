import 'dart:io';

import 'package:flutter_code_inspector/src/common/common_exception.dart';
import 'package:meta/meta.dart';

class HeaderInspectorException
    extends CommonException<Object> {


  const HeaderInspectorException({
    required super.file,
    required this.type,
    required super.line,
    super.row,
    super.description = const Object(),
  });

  final HeaderInspectorExceptionType type;
}

enum HeaderInspectorExceptionType {
  themselfImports,
  relativeImports,
  packageExports,
  relativeExports,
}

