import 'dart:io';


import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/localizations/localization_inspector/localization_inspector_data.dart';
import 'package:flutter_code_inspector/src/localizations/localization_inspector/localization_inspector_exception.dart';
import 'package:flutter_code_inspector/src/localizations/utils/printer_extension.dart';

class LocalizationsInspectorModule extends CommonModule {
  static const yamlConfigName = 'flutter_localizations_inspector';

  LocalizationsInspectorModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['translation/.*'],
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.arb'],
  );
  final localePattern = RemoteConfigOption(
    name: 'locale_pattern',
    defaultValue: r'.*/(\w+).arb',
  );
  final findKeyDuplicates = RemoteConfigFlag(
    name: 'find_key_duplicates',
    defaultValue: false,
  );
  final findValueDuplicates = RemoteConfigFlag(
    name: 'find_value_duplicates',
    defaultValue: true,
  );
  final findKeyAndValueDuplicates = RemoteConfigFlag(
    name: 'find_key_and_value_duplicates',
    defaultValue: true,
  );
  final findMissedKeys = RemoteConfigFlag(
    name: 'find_missed_keys',
    defaultValue: true,
  );
  final help = RemoteConfigFlag(
    name: 'help',
    abbr: 'h',
    defaultValue: false,
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

      final localizationDataList = files.map((file) {
        return LocalizationInspectorData(
          file: file,
          localePattern: localePattern.value,
        );
      }).toList();

      final Set<LocalizationInspectorException> exceptions = {
        ..._findDuplicates(localizationDataList),
        ..._findMissed(localizationDataList),
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

  // Finders ------------------------------------------------------------------

  Set<LocalizationInspectorException> _findDuplicates(
    List<LocalizationInspectorData> localizationFiles,
  ) {
    final exceptions = <LocalizationInspectorException>{};
    if (findKeyDuplicates.value ||
        findValueDuplicates.value ||
        findKeyAndValueDuplicates.value) {
      localizationFiles.groupByLocale().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = aIndex + 1; bIndex < group.length; bIndex += 1) {
            final aLFile = group[aIndex];
            final bLFile = group[bIndex];
            exceptions.addAll(
              aLFile.findIntersections(
                bLFile,
                findKeyDuplicates: findKeyDuplicates.value,
                findValueDuplicates: findValueDuplicates.value,
                findKeyAndValueDuplicates: findKeyAndValueDuplicates.value,
              ),
            );
          }
        }
      });
    }
    return exceptions;
  }

  Set<LocalizationInspectorException> _findMissed(
    List<LocalizationInspectorData> localizationFiles,
  ) {
    final exceptions = <LocalizationInspectorException>{};
    if (findMissedKeys.value) {
      localizationFiles.groupByFolder().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = 0; bIndex < group.length; bIndex += 1) {
            if (aIndex == bIndex) {
              continue;
            }
            final aLFile = group[aIndex];
            final bLFile = group[bIndex];
            exceptions.addAll(aLFile.findMissedKeys(bLFile));
          }
        }
      });
    }
    return exceptions;
  }

  // Printer ------------------------------------------------------------------

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
      ..remoteConfig(
        localePattern,
        description: 'pattern to extract locale from file path',
      )
      ..b1('')
      ..remoteConfig(
        findKeyDuplicates,
        description: 'find keys duplicates',
      )
      ..remoteConfig(
        findValueDuplicates,
        description: 'find values duplicates',
      )
      ..remoteConfig(
        findKeyAndValueDuplicates,
        description: 'find keys and values duplicates',
      )
      ..remoteConfig(
        findMissedKeys,
        description: 'find missed keys',
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

  final List<List<LocalizationInspectorException>> exceptionsGroups;
  final int filesCount;
}
