import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_organizer/src/localizations/localization_inspector/localization_inspector_handler.dart';
import 'package:flutter_code_organizer/src/localizations/utils/printer_extension.dart';

class LocalizationsInspectorModule extends CommonModule {
  static const yamlConfigName = 'localizations_inspector';

  LocalizationsInspectorModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['translation/.*'],
    description: 'directories to search for files',
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.arb'],
    description: 'files extensions to search for files',
  );
  final localePattern = RemoteConfigOption(
    name: 'locale_pattern',
    defaultValue: r'.*/(\w+).arb',
    description: 'pattern to extract locale from file path',
  );
  final findKeyDuplicates = RemoteConfigFlag(
    name: 'find_key_duplicates_enabled',
    defaultValue: false,
    description: 'find keys duplicates',
  );
  final findValueDuplicates = RemoteConfigFlag(
    name: 'find_value_duplicates_enabled',
    defaultValue: true,
    description: 'find values duplicates',
  );
  final findKeyAndValueDuplicates = RemoteConfigFlag(
    name: 'find_key_and_value_duplicates_enabled',
    defaultValue: true,
    description: 'find keys and values duplicates',
  );
  final findMissedKeys = RemoteConfigFlag(
    name: 'find_missed_keys_enabled',
    defaultValue: true,
    description: 'find missed keys',
  );
  final help = RemoteConfigFlag(
    name: 'help',
    abbr: 'h',
    defaultValue: false,
    description: 'show this help message',
  );

  @override
  void init({required List<String> remoteArguments}) {
    <RemoteConfig>[
      allowedDirectories,
      allowedExtensions,
      localePattern,
      findKeyDuplicates,
      findValueDuplicates,
      findKeyAndValueDuplicates,
      findMissedKeys,
      help,
    ].initWith(
      yamlConfigName: yamlConfigName,
      remoteArguments: remoteArguments,
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

      final handlers = files.map((file) {
        return LocalizationInspectorHandler(
          file: file,
          localePattern: localePattern.value,
        );
      });

      final Set<LocalizationInspectorException> exceptions = {
        ...handlers.findDuplicates(
          findKeyAndValueDuplicates: findKeyAndValueDuplicates.value,
          findKeyDuplicates: findKeyDuplicates.value,
          findValueDuplicates: findValueDuplicates.value,
        ),
        ...handlers.findMissed(
          findMissedKeys: findMissedKeys.value,
        ),
      };

      return InspectionResult(
        exceptionsGroups: exceptions.toList().groupByItem(),
        filesCount: files.length,
      );
    });

    final printer = Printer()
      ..h1('Localizations Inspector')
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

  // Printer ------------------------------------------------------------------

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
      ..remoteConfig(localePattern)
      ..b1('')
      ..remoteConfig(findKeyDuplicates)
      ..remoteConfig(findValueDuplicates)
      ..remoteConfig(findKeyAndValueDuplicates)
      ..remoteConfig(findMissedKeys)
      ..d1('')
      ..b1('  yaml config name: $yamlConfigName')
      ..f1('');
  }
}

@visibleForTesting
class InspectionResult {
  const InspectionResult({
    required this.exceptionsGroups,
    required this.filesCount,
  });

  final List<List<LocalizationInspectorException>> exceptionsGroups;
  final int filesCount;
}
