import 'dart:io';

import 'package:meta/meta.dart';

class Printer {
  @visibleForTesting
  static void Function([String? message]) output = stdout.writeln;

  static const Printer instance = Printer._();

  factory Printer() => instance;

  const Printer._();

  // header1
  static const String _header1 = '''
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';

  // body1
  static const String _body1 = '''
┃                                           ''';

  // divider1
  static const String _divider1 = '''
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';

  // footer1
  static const String _footer1 = '''
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';

  // connector1
  static const String _connector1 = '''
┃    ┗━                                     ''';

  // footer2
  static const String _footer2 = '''
┃    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';

  /// Header 1
  void h1(String? message) {
    raw(merge(_header1, 3, message));
  }

  /// Body 1
  void b1(String? message) {
    raw(merge(_body1, 1, message));
  }

  /// Connector 1
  void c1(String? message) {
    raw(merge(_connector1, 8, message));
  }

  /// Divider 1
  void d1(String? message) {
    raw(merge(_divider1, 3, message));
  }

  /// Footer 1
  void f1(String? message) {
    raw(merge(_footer1, 3, message));
  }

  /// Footer 2
  void f2(String? message) {
    raw(merge(_footer2, 8, message));
  }

  /// RAW string
  void raw(String? message) {
    output(message);
  }

  @visibleForTesting
  String merge(String pattern, int shift, String? message) {
    final String extendedPattern = () {
      if (pattern.length > 2 &&
          pattern[pattern.length - 1] == pattern[pattern.length - 2]) {
        return pattern.padRight(120, pattern[pattern.length - 1]);
      }
      return pattern;
    }();

    if (message == null || message.trim().isEmpty) {
      return extendedPattern;
    }
    final result = '${extendedPattern.substring(0, shift)} $message ';
    if (result.length >= extendedPattern.length) {
      return result;
    }

    return result + extendedPattern.substring(result.unColorize().length);
  }
}

extension UnColorizeString on String {
  String unColorize() {
    return replaceAll(RegExp(r'\x1B\[\d+m'), '')
        .replaceAll(RegExp(r'\x20\[m\]'), '');
  }
}
