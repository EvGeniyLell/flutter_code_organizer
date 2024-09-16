import 'package:colorize/colorize.dart';
import 'package:flutter_code_organizer/src/common/printer/printer.dart';
import 'package:flutter_code_organizer/src/common/remote_config/remote_config.dart';

extension PrinterCommonExtension on Printer {
  void remoteConfig(
    RemoteConfig config, {
    required String description,
  }) {
    final name = config.abbr != null
        ? '--${config.name}, -${config.abbr}'
        : '--${config.name}';


    this
      ..b1('  ${colorizeInfo(name)}: $description')
      ..b1('      by defaults uses ${colorizeInfo('${config.defaultValue}')}')
      ..b1('      current value is ${colorizeInfo('${config.value}')}');
  }
}

extension ColorizePrinter on Printer {
  String colorize(
    String message,
    Colorize Function(Colorize) colorize, {
    required bool when,
  }) {
    if (!when) {
      return message;
    }
    return colorize(Colorize(message)).toString();
  }

  String colorizeError(String message, {bool when = true}) =>
      colorize(message, (c) => c.red(), when: when);

  String colorizeOk(String message, {bool when = true}) =>
      colorize(message, (c) => c.green(), when: when);

  String colorizeWarning(String message, {bool when = true}) =>
      colorize(message, (c) => c.yellow(), when: when);

  String colorizeInfo(String message, {bool when = true}) =>
      colorize(message, (c) => c.blue(), when: when);
}
