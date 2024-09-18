library common;

export 'common_exception.dart';
export 'printer/printer.dart';
export 'remote_config/remote_config.dart';
export 'utils/collection.dart';
export 'utils/condition.dart';
export 'utils/files.dart';
export 'utils/io_manager.dart';
export 'utils/measurable_block.dart';
export 'utils/printer_extension.dart';
export 'utils/string_extension.dart';

abstract class CommonModule {
  CommonModule({required List<String> remoteArguments}) {
    init(remoteArguments: remoteArguments);
  }

  void init({required List<String> remoteArguments});

  void call();
}
