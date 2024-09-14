import 'package:colorize/colorize.dart';
import 'package:flutter_code_inspector/src/common/printer/printer.dart';
import 'package:flutter_code_inspector/src/common/remote_config/remote_config.dart';

extension PrinterCommonExtension on Printer {
  void remoteConfig(
    RemoteConfig config, {
    required String description,
  }) {
    final name = config.abbr != null
        ? '--${config.name}, -${config.abbr}'
        : '--${config.name}';

    this
      ..b1('  $name: $description')
      ..b1('      by defaults uses "${config.defaultValue}"');
  }
}

extension ColorizePrinter on Printer {
  String colorizeError(String message, {bool when = true}) {
    return Colorize(message).red().toString();
  }

  String colorizeOk(String message, {bool when = true}) {
    return Colorize(message).green().toString();
  }

  String colorizeWarning(String message, {bool when = true}) {
    return Colorize(message).yellow().toString();
  }

  String colorizeInfo(String message, {bool when = true}) {
    return Colorize(message).cyan().toString();
  }
}
