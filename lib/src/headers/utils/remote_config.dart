import 'package:flutter_code_organizer/src/common/common.dart';
import 'package:meta/meta.dart';

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

// class RemoteConfigEnumOption<T extends Enum> extends RemoteConfigMultiOption {
//   factory RemoteConfigEnumOption({
//     required String name,
//     required String description,
//     required List<T> defaultValue,
//     required List<T> allEnumValues,
//   }) {
//     return RemoteConfigEnumOption.private(
//       name: name,
//       description: description,
//       defaultValue: defaultValue.map((e) => e.name).toList(),
//       allEnumValues: allEnumValues,
//     );
//   }
//
//   @visibleForTesting
//   RemoteConfigEnumOption.private({
//     required super.name,
//     required super.description,
//     required super.defaultValue,
//     required this.allEnumValues,
//   });
//
//   final List<T> allEnumValues;
//
//   List<T> get enumValues {
//     return defaultValue
//         .map((e) => allEnumValues.firstWhere((element) => element.name == e))
//         .toList();
//   }
// }
