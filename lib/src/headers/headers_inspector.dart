import 'dart:io';

import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data.dart';
import 'package:flutter_code_inspector/src/headers/utils/printer_extension.dart';

import 'header_inspector_data/header_inspector_data.dart';
import 'header_inspector_data/header_inspector_exception.dart';

class HeadersInspectorModule extends CommonModule {
  static const yamlConfigName = 'flutter_headers_inspector';

  HeadersInspectorModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['lib/.*'],
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
    final result = measurableBlock<InspectionResult>(() {
      final currentPath = Directory.current.path;

      final files = getFiles(
        currentPath,
        allowedDirectories: allowedDirectories.value,
        allowedExtensions: allowedExtensions.value,
      );

      final exceptions = <HeaderInspectorException>[];

      for (final file in files) {
        final data = HeaderInspectorData(
          file: file,
          projectDir: currentPath,
          projectName: projectName,
        );

        exceptions.addAll(data.findAllExceptions());
      }

      return InspectionResult(
        exceptionsGroups: exceptions.groupByFile(),
        filesCount: files.length,
      );
    });

    final printer = Printer()
      ..h1('Headers Inspector')
      ..exceptionsGroups(result.data.exceptionsGroups);

    final errorCount = printer.colorizeError(
      '${result.data.exceptionsGroups.length} errors',
      when: result.data.exceptionsGroups.isNotEmpty,
    );

    final timeTitle = '${result.duration.inSeconds}'
        '.${result.duration.inMilliseconds % 1000} seconds';
    printer.f1('Reviewed ${result.data.filesCount} '
        'files with $errorCount in $timeTitle');
  }

  // Finders ------------------------------------------------------------------

  void _printHelp() {
    Printer()
      ..h1('Help')
      ..b1('Welcome to the localizations inspector')
      ..b1('the tool allow you keep your localizations in order')
      ..d1('')
      ..b1('Options:')
      ..remoteConfig(
        help,
        description: 'show this help message',
      )
      ..b1('')
      ..remoteConfig(
        allowedDirectories,
        description: 'directories to search for files',
      )
      ..remoteConfig(
        allowedExtensions,
        description: 'extensions to search for files',
      )
      ..d1('')
      ..b1('  yaml config name: $yamlConfigName')
      ..f1('');
  }
}

class InspectionResult {
  const InspectionResult({
    required this.exceptionsGroups,
    required this.filesCount,
  });

  final List<List<HeaderInspectorException>> exceptionsGroups;
  final int filesCount;
}

extension on List<HeaderInspectorException> {
  List<List<HeaderInspectorException>> groupByFile() {
    final grouped = <String, List<HeaderInspectorException>>{};

    for (final exception in this) {
      final key = exception.file.path;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(exception);
    }

    return grouped.values.toList();
  }
}
