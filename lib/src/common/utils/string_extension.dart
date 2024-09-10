import 'dart:math';

extension StringExtension on String {
  String sample(int length) {
    return substring(0, min(length, this.length));
  }

  String fromFilePathToDirPath() {
    return substring(0, lastIndexOf('/'));
  }

}
