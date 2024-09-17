import 'dart:io';

import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';
import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_handler.dart';
import 'package:flutter_code_organizer/src/headers/utils/printer_extension.dart';
import 'package:flutter_code_organizer/src/headers/utils/remote_config.dart';

class HeadersInspectorModule extends CommonModule {
  static const yamlConfigName = 'headers_inspector';

  HeadersInspectorModule({required super.remoteArguments});

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
  final forbidThemselfPackageImports = RemoteInspectorForbidConfig(
    name: 'forbid_themself_package_imports',
    description: 'forbid package imports themself: settings',
  );
  final forbidOtherFeaturesPackageImports = RemoteInspectorForbidConfig(
    name: 'forbid_other_features_package_imports',
    description: 'forbid package imports to other features: settings',
  );
  final forbidRelativeImports = RemoteInspectorForbidConfig(
    name: 'forbid_relative_imports',
    description: 'forbid relative imports: settings',
  );
  final forbidPackageExports = RemoteInspectorForbidConfig(
    name: 'forbid_package_exports',
    description: 'forbid package exports: settings',
  );
  final forbidOtherFeaturesRelativeExports = RemoteInspectorForbidConfig(
    name: 'forbid_other_features_relative_exports',
    description: 'forbid relative exports: settings',
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
      forbidThemselfPackageImports,
      forbidOtherFeaturesPackageImports,
      forbidRelativeImports,
      forbidPackageExports,
      forbidOtherFeaturesRelativeExports,
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
            forbidThemselfPackageImports: forbidThemselfPackageImports,
            forbidOtherFeaturesPackageImports:
                forbidOtherFeaturesPackageImports,
            forbidRelativeImports: forbidRelativeImports,
            forbidPackageExports: forbidPackageExports,
            forbidOtherFeaturesRelativeExports:
                forbidOtherFeaturesRelativeExports,
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
      ..b1('Welcome to the localizations inspector')
      ..b1('the tool allow you keep your localizations in order')
      ..d1('')
      ..b1('Options:')
      ..remoteConfig(help)
      ..b1('')
      ..remoteConfig(allowedDirectories)
      ..remoteConfig(allowedExtensions)
      ..remoteConfig(forbidThemselfPackageImports)
      ..remoteConfig(forbidOtherFeaturesPackageImports)
      ..remoteConfig(forbidRelativeImports)
      ..remoteConfig(forbidPackageExports)
      ..remoteConfig(forbidOtherFeaturesRelativeExports)
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
