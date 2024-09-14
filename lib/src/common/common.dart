library common;

export 'utils/files.dart';
export 'remote_config/remote_config.dart';
export 'printer/printer.dart';
export 'utils/string_extension.dart';
export 'utils/printer_extension.dart';
export 'utils/measurable_block.dart';

abstract class CommonModule {
  CommonModule({required List<String> remoteArguments}) {
    init(remoteArguments: remoteArguments);
  }

  void init({required List<String> remoteArguments});

  void call();
}
