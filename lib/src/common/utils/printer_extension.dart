import 'package:colorize/colorize.dart';

import 'package:flutter_code_organizer/src/common/printer/printer.dart';
import 'package:flutter_code_organizer/src/common/remote_config/remote_config.dart';

extension PrinterCommonExtension on Printer {
  static const deepShift = 4;

  void remoteConfig(
    RemoteConfig config, {
    int deep = 0,
  }) {
    final shift = ''.padRight(deep);
    final name = config.abbr != null
        ? '--${config.name}, -${config.abbr}'
        : '--${config.name}';

    b1('$shift  ${colorizeInfo(name)}: ${config.description}');
    if (config is! RemoteConfigMap) {
      b1(
        '$shift      by defaults uses '
        '${colorizeInfo('${config.defaultValue}')}',
      );
      if (config.source != RemoteConfigSource.defaultValue) {
        b1(
          '$shift      current value is '
          '${colorizeWarning('${config.value}')}',
        );
      }
    }

    if (config is RemoteConfigMap) {
      for (final subConfig in config.items) {
        remoteConfig(subConfig, deep: deep + deepShift);
      }
    }
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
