import 'dart:math';

extension StringExtension on String {
  String sample([int length = 10]) {
    final result = substring(0, min(length, this.length));
    if (this.length > length) {
      return '$result…';
    }
    return result;
  }

  String fromFilePathToDirPath() {
    return substring(0, lastIndexOf('/'));
  }
}
