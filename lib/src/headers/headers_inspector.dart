import 'dart:io';

import 'package:flutter_code_organizer/src/common/common.dart';

import 'package:flutter_code_organizer/src/headers/utils/printer_extension.dart';

import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:meta/meta.dart';

class HeadersInspectorModule extends CommonModule {
  static const yamlConfigName = 'headers_inspector';

  HeadersInspectorModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['^lib/src/.*'],
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.dart'],
  );
  final forbidThemselfPackageImports = RemoteConfigFlag(
    name: 'forbid_themself_package_imports',
    defaultValue: false,
  );
  final forbidOtherFeaturesPackageImports = RemoteConfigFlag(
    name: 'forbid_other_features_package_imports',
    defaultValue: true,
  );
  final forbidRelativeImports = RemoteConfigFlag(
    name: 'forbid_relative_imports',
    defaultValue: true,
  );
  final forbidPackageExports = RemoteConfigFlag(
    name: 'forbid_package_exports',
    defaultValue: true,
  );
  final forbidPackageExportsEnabled = RemoteConfigFlag(
    name: 'enabled',
    defaultValue: false,
  );
  final forbidPackageExportsIgnoreFiles = RemoteConfigMultiOption(
    name: 'ignore_files',
    defaultValue: [],
  );
  late final forbidPackageExports2 = RemoteConfigMap(
    name: 'forbid_package_exports',
    items: [
      forbidPackageExportsEnabled,
      forbidPackageExportsIgnoreFiles,
    ],
  );
  final forbidOtherFeaturesRelativeExports = RemoteConfigFlag(
    name: 'forbid_other_features_relative_exports',
    defaultValue: true,
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
      forbidThemselfPackageImports,
      forbidOtherFeaturesPackageImports,
      forbidRelativeImports,
      forbidPackageExports,
      forbidOtherFeaturesRelativeExports,
      forbidPackageExports2,
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
        final handler = HeaderInspectorHandler(
          file: file,
          projectDir: currentPath,
          projectName: projectName,
        );

        exceptions.addAll(
          handler.findAllExceptions(
            forbidThemselfPackageImports: forbidThemselfPackageImports.value,
            forbidOtherFeaturesPackageImports:
                forbidOtherFeaturesPackageImports.value,
            forbidRelativeImports: forbidRelativeImports.value,
            forbidPackageExports: forbidPackageExports.value,
            forbidOtherFeaturesRelativeExports:
                forbidOtherFeaturesRelativeExports.value,
          ),
        );
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
      // ..b1('Welcome to the localizations inspector')
      // ..b1('the tool allow you keep your localizations in order')
      // ..d1('')
      ..b1('Options:')
      // ..remoteConfig(
      //   help,
      //   description: 'show this help message',
      // )
      // ..b1('')
      // ..remoteConfig(
      //   allowedDirectories,
      //   description: 'directories to search for files',
      // )
      // ..remoteConfig(
      //   allowedExtensions,
      //   description: 'extensions to search for files',
      // )
      ..remoteConfig(
        forbidPackageExports2,
        description: 'test',
      )
      ..remoteConfig(
        forbidPackageExportsEnabled,
        description: 'enable',
      )
      ..remoteConfig(
        forbidPackageExportsIgnoreFiles,
        description: 'ignore files',
      )


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

  final List<List<HeaderInspectorException>> exceptionsGroups;
  final int filesCount;
}
