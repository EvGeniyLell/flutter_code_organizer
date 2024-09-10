import 'dart:io';

class Printer {
  static const Printer instance = Printer._();

  factory Printer() => instance;

  const Printer._();

  // header1
  static const String _l1 = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  // header1
  static const String _h1 = '┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  // body1
  static const String _b1 = '┃                                           ';

  // divider1
  static const String _d1 = '┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  // footer1
  static const String _f1 = '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  // connector1
  static const String _c1 = '┃    ┗━                                     ';

  // footer2
  static const String _f2 = '┃    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  /// Header 1
  void h1(String? message) {
    stdout.writeln(_merge(_h1 + _l1, 3, message));
  }

  /// Body 1
  void b1(String? message) {
    stdout.writeln(_merge(_b1, 1, message));
  }

  /// Connector 1
  void c1(String? message) {
    stdout.writeln(_merge(_c1, 8, message));
  }

  /// Divider 1
  void d1(String? message) {
    stdout.writeln(_merge(_d1 + _l1, 3, message));
  }

  /// Footer 1
  void f1(String? message) {
    stdout.writeln(_merge(_f1 + _l1, 3, message));
  }

  /// Footer 2
  void f2(String? message) {
    stdout.writeln(_merge(_f2 + _l1, 8, message));
  }

  String _merge(String pattern, int shift, String? message) {
    final String extendedPattern = () {
      if (pattern.length > 2 &&
          pattern[pattern.length - 1] == pattern[pattern.length - 2]) {
        return pattern.padRight(40, pattern[pattern.length - 1]);
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
    return result + extendedPattern.substring(result.length);
  }
}
