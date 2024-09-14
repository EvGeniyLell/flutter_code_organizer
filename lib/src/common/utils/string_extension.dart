import 'dart:math';

extension StringExtension on String {
  String sample([int length = 10]) {
    return substring(0, min(length, this.length));
  }

  String fromFilePathToDirPath() {
    return substring(0, lastIndexOf('/'));
  }
}
