import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';
import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_order_item_type.dart';
import 'package:flutter_code_organizer/src/headers/utils/printer_extension.dart';

class HeadersSorterModule extends CommonModule {
  static const yamlConfigName = 'headers_sorter';

  HeadersSorterModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['^lib/src/.*'],
    description: 'directories to search for files',
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.dart'],
    description: 'files extensions to search for files',
  );
  final sortOrder = RemoteConfigMultiOption(
    name: 'sort_order',
    defaultValue: [
      ...HeaderSorterOrderItemTypeExtension.defaultOrder().map((e) => e.name),
    ],
    description: 'files extensions to search for files',
  );

  final help = RemoteConfigFlag(
    name: 'help',
    abbr: 'h',
    defaultValue: false,
    description: 'show this help message',
  );
  late final String projectName;

  @override
  void init({required List<String> remoteArguments}) {
    <RemoteConfig>[
      allowedDirectories,
      allowedExtensions,
      sortOrder,
      help,
    ].initWith(
      yamlConfigName: yamlConfigName,
      remoteArguments: remoteArguments,
      projectNameCallback: (name) => projectName = name,
    );
  }

  @override
  void call() {
    if (help.value) {
      _printHelp();
      return;
    }

    _inspectAndPrintResults();
  }

  void _inspectAndPrintResults() {
    final currentPath = Directory.current.path;

    final result = measurableBlock<SortingResult>(() {
      final files = getFiles(
        currentPath,
        allowedDirectories: allowedDirectories.value,
        allowedExtensions: allowedExtensions.value,
      );

      final saved = <File>[];
      for (final file in files) {
        // Printer.debugMode = file.path.contains(
        //   'shared_preferences_dictionary_local_data_source_test.dart',
        // );
        final isSaved = HeaderSorterHandler(
          file: file,
          projectName: projectName,
        ).save(
          sortOrder: HeaderSorterOrderItemTypeExtension.enumListFromStrings(
            sortOrder.value,
          ),
        );
        if (isSaved) {
          saved.add(file);
        }
      }

      return SortingResult(
        saved: saved,
        filesCount: files.length,
      );
    });

    final printer = Printer()
      ..h1('Headers Sorter')
      ..savedFiles(result.data.saved, currentPath: currentPath);

    final sortedCount = printer.colorizeInfo(
      '${result.data.saved.length} sorted',
      when: result.data.saved.isNotEmpty,
    );

    final timeTitle = '${result.duration.inSeconds}'
        '.${result.duration.inMilliseconds % 1000} seconds';
    printer.f1('Reviewed ${result.data.filesCount} '
        'files with $sortedCount in $timeTitle');
  }

  // Finders ------------------------------------------------------------------

  void _printHelp() {
    Printer()
      ..h1('Help')
      ..b1('Welcome to the localizations inspector')
      ..b1('the tool allow you keep your localizations in order')
      ..d1('')
      ..b1('Options:')
      ..remoteConfig(help)
      ..b1('')
      ..remoteConfig(allowedDirectories)
      ..remoteConfig(allowedExtensions)
      ..remoteConfig(sortOrder)
      ..b1('      possible values:')
      ..b1('        - space')
      ..b1('        - import_[dart, flutter, package, project, relative]')
      ..b1('        - export_[dart, flutter, package, project, relative]')
      ..b1('        - part')
      ..b1('')
      ..b1('  yaml config name: $yamlConfigName')
      ..f1('');
  }
}

@visibleForTesting
class SortingResult {
  const SortingResult({
    required this.saved,
    required this.filesCount,
  });

  final List<File> saved;
  final int filesCount;
}
