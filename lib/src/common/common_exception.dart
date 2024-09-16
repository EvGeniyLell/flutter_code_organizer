import 'dart:io';

import 'package:meta/meta.dart';

@immutable
abstract class CommonException {
  const CommonException({
    required this.file,
    required this.source,
    required this.line,
    this.row,
  });

  final File file;
  final String source;
  final int line;
  final int? row;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommonException &&
          runtimeType == other.runtimeType &&
          file.path == other.file.path &&
          source == other.source &&
          line == other.line &&
          row == other.row;

  @override
  int get hashCode =>
      file.path.hashCode ^ source.hashCode ^ line.hashCode ^ row.hashCode;

  String asLink() {
    final row = this.row;
    return row != null
        ? '${file.path}:${line + 1}:$row'
        : '${file.path}:${line + 1}';
  }

  @override
  String toString() {
    return '$CommonException{link: ${asLink()}, source: $source}';
  }
}
