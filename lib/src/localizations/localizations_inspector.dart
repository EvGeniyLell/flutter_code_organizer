import 'dart:io';

import 'package:colorize/colorize.dart';
import 'package:flutter_code_inspector/src/common/common.dart';
import 'package:flutter_code_inspector/src/localizations/localization_file/localization_file.dart';

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
    defaultValue: true,
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

    final stopwatch = Stopwatch()..start();

    final currentPath = Directory.current.path;

    final files = getFiles(
      currentPath,
      allowedDirectories: allowedDirectories.value,
      allowedExtensions: allowedExtensions.value,
    );

    final localizationFiles = files.map((file) {
      return LocalizationFile(file, localePattern: localePattern.value);
    }).toList();

    final Set<LocalizationFileException> searchResults = {};

    _findDuplicates(localizationFiles, searchResults);
    _findMissed(localizationFiles, searchResults);

    _printSearchResults(
      searchResults.toList(),
      filesCount: localizationFiles.length,
      stopwatch: stopwatch,
    );
  }

  // Finders ------------------------------------------------------------------

  void _findDuplicates(
    List<LocalizationFile> localizationFiles,
    Set<LocalizationFileException> searchResults,
  ) {
    if (findKeyDuplicates.value ||
        findValueDuplicates.value ||
        findKeyAndValueDuplicates.value) {
      localizationFiles.groupByLocale().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = aIndex + 1; bIndex < group.length; bIndex += 1) {
            final aLFile = group[aIndex];
            final bLFile = group[bIndex];

            searchResults.addAll(
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
  }

  void _findMissed(
    List<LocalizationFile> localizationFiles,
    Set<LocalizationFileException> searchResults,
  ) {
    if (findMissedKeys.value) {
      localizationFiles.groupByFolder().forEach((group) {
        for (int aIndex = 0; aIndex < group.length; aIndex += 1) {
          for (int bIndex = 0; bIndex < group.length; bIndex += 1) {
            if (aIndex == bIndex) {
              continue;
            }
            final aLFile = group[aIndex];
            final bLFile = group[bIndex];
            searchResults.addAll(aLFile.findMissedKeys(bLFile));
          }
        }
      });
    }
  }

  // Printer ------------------------------------------------------------------

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

  void _printSearchResults(
    List<LocalizationFileException> searchResults, {
    required int filesCount,
    required Stopwatch stopwatch,
  }) {
    Printer().h1('Localizations Inspector');

    final resultsGroups = searchResults.groupByItem();

    for (final group in resultsGroups) {
      final issue = group.firstOrNull;
      if (issue != null) {
        Printer().d1(issue.toIssue());
        for (final item in group) {
          Printer().c1('file ${item.toLink()}');
        }
      }
    }

    ///
    stopwatch.stop();
    final errorsTitle = Colorize('${searchResults.length} errors');
    if (searchResults.isNotEmpty) {
      errorsTitle.red();
    }

    final timeTitle = '${stopwatch.elapsed.inSeconds}'
        '.${stopwatch.elapsedMilliseconds} seconds';
    Printer().f1('Reviewed $filesCount files with $errorsTitle in $timeTitle');
  }
}
