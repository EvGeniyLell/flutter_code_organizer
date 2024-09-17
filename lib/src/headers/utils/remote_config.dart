import 'package:meta/meta.dart';

import 'package:flutter_code_organizer/src/common/common.dart';

class RemoteInspectorForbidConfig extends RemoteConfigMap {
  factory RemoteInspectorForbidConfig({
    required String name,
    required String description,
    bool enabled = true,
    List<String> ignoreFiles = const [],
  }) {
    final enabledConfig = RemoteConfigFlag(
      name: 'enabled',
      defaultValue: enabled,
      description: 'forbid enable flag',
    );

    final ignoreFilesConfig = RemoteConfigMultiOption(
      name: 'ignore_files',
      defaultValue: ignoreFiles,
      description: 'forbid will be ignored files by this patterns',
    );

    return RemoteInspectorForbidConfig.private(
      name: name,
      description: description,
      enabled: enabledConfig,
      ignoreFiles: ignoreFilesConfig,
    );
  }

  @visibleForTesting
  RemoteInspectorForbidConfig.private({
    required super.name,
    required super.description,
    required this.enabled,
    required this.ignoreFiles,
  }) : super(items: [enabled, ignoreFiles]);

  final RemoteConfigFlag enabled;
  final RemoteConfigMultiOption ignoreFiles;
}
