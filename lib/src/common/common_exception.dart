import 'dart:io';

import 'package:meta/meta.dart';

@immutable
abstract class CommonException<T extends Object> {
  const CommonException({
    required this.file,
    required this.description,
    required this.line,
    this.row,
  });

  final File file;
  final T description;
  final int line;
  final int? row;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommonException &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          line == other.line &&
          row == other.row &&
          description == other.description;

  @override
  int get hashCode =>
      file.hashCode ^ line.hashCode ^ row.hashCode ^ description.hashCode;

  String asLink({String? base}) {
    final path = file.path;
    final relativePath = base != null ? path.replaceFirst(base, '') : path;
    final row = this.row;
    return row != null
        ? '$relativePath:${line + 1}:$row'
        : '$relativePath:${line + 1}';
  }

  @override
  String toString() {
    return '$CommonException{link: ${asLink()}, $description}';
  }
}

