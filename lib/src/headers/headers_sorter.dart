import 'dart:io';

import 'package:flutter_code_organizer/src/common/common.dart';

import 'package:flutter_code_organizer/src/headers/header_sorter/header_sorter_handler.dart';

import 'package:flutter_code_organizer/src/headers/utils/printer_extension.dart';
import 'package:meta/meta.dart';

class HeadersSorterModule extends CommonModule {
  static const yamlConfigName = 'headers_sorter';

  HeadersSorterModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['^lib/src/.*'],
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.dart'],
  );
  final help = RemoteConfigFlag(
    name: 'help',
    abbr: 'h',
    defaultValue: false,
  );
  late final String projectName;

  @override
  void init({required List<String> remoteArguments}) {
    <RemoteConfig>[
      allowedDirectories,
      allowedExtensions,
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
        final isSaved = HeaderSorterHandler(
          file: file,
          projectName: projectName,
        ).save(
          spaceDartFlutter: true,
          spaceFlutterPackage: true,
          spacePackageProject: true,
          spaceProjectRelative: true,
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
      ..b1('  --help, -h: show this help message')
      ..b1('')
      ..b1('  --allowed_directories: directories to search for files')
      ..b1('      by defaults uses "translation/.*"')
      ..b1('  --allowed_extensions: extensions to search for files')
      ..b1('      by defaults uses ".arb"')
      ..b1('  --locale_pattern: pattern to extract locale from file path')
      ..b1('      by defaults uses ".*/localeName.arb"')
      ..b1('')
      ..b1('  --find_key_duplicates: find keys duplicates')
      ..b1('      by defaults uses "true"')
      ..b1('  --find_value_duplicates: find values duplicates')
      ..b1('      by defaults uses "true"')
      ..b1('  --find_key_and_value_duplicates: find keys and values duplicates')
      ..b1('      by defaults uses "true"')
      ..b1('  --find_missed_keys: find missed keys')
      ..b1('      by defaults uses "true"')
      ..d1('')
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
