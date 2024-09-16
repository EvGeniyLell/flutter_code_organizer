library remote_config;

import 'dart:io';

import 'package:flutter_code_organizer/src/common/remote_config/extensions/arguments_map_extension.dart';
import 'package:flutter_code_organizer/src/common/remote_config/extensions/yaml_map_extension.dart';

enum RemoteConfigSource {
  argument,
  yaml,
  defaultValue,
}

abstract class RemoteConfig<T extends Object> {
  RemoteConfig({
    required this.name,
    required this.defaultValue,
    this.abbr,
  });

  final String name;
  final String? abbr;
  final T defaultValue;

  late final T value;
  late final RemoteConfigSource source;

  void init(YamlMap? yaml, ArgumentsMap arguments) {
    final yamlValue = readYamlValue(yaml);
    if (yamlValue != null) {
      value = yamlValue;
      source = RemoteConfigSource.yaml;
      return;
    }

    final argumentValue = readArgumentValue(arguments);
    if (argumentValue != null) {
      value = argumentValue;
      source = RemoteConfigSource.argument;
      return;
    }

    value = defaultValue;
    source = RemoteConfigSource.defaultValue;
  }

  T? readYamlValue(YamlMap? yaml);

  T? readArgumentValue(ArgumentsMap arguments);
}

class RemoteConfigFlag extends RemoteConfig<bool> {
  RemoteConfigFlag({
    required super.name,
    required super.defaultValue,
    super.abbr,
  });

  @override
  bool? readYamlValue(YamlMap? yaml) {
    return yaml?.readFlag(name);
  }

  @override
  bool? readArgumentValue(ArgumentsMap arguments) {
    final value = arguments[name] ?? arguments[abbr];
    if (value != null) {
      if (value.isEmpty) {
        return true;
      } else {
        switch (value.first.toLowerCase()) {
          case 't':
          case 'true':
          case 'enabled':
          case 'yes':
          case '1':
            return true;
          case 'f':
          case 'false':
          case 'disabled':
          case 'no':
          case '0':
            return false;
        }
      }
    }
    return null;
  }
}

class RemoteConfigOption extends RemoteConfig<String> {
  RemoteConfigOption({
    required super.name,
    required super.defaultValue,
    super.abbr,
  });

  @override
  String? readYamlValue(YamlMap? yaml) {
    return yaml?.readScalar(name);
  }

  @override
  String? readArgumentValue(ArgumentsMap arguments) {
    final value = arguments[name] ?? arguments[abbr];
    if (value != null && value.isNotEmpty) {
      return value.first;
    }
    return null;
  }
}

class RemoteConfigMultiOption extends RemoteConfig<List<String>> {
  RemoteConfigMultiOption({
    required super.name,
    required super.defaultValue,
    super.abbr,
    this.separator = ',',
  });

  String separator;

  @override
  List<String>? readYamlValue(YamlMap? yaml) {
    return yaml?.readList(name);
  }

  @override
  List<String>? readArgumentValue(ArgumentsMap arguments) {
    final value = arguments[name] ?? arguments[abbr];
    if (value != null && value.isNotEmpty) {
      if (value.length == 1) {
        return value.first.split(separator);
      } else {
        return value;
      }
    }
    return null;
  }
}

extension ListRemoteConfigExtension on List<RemoteConfig> {
  void initWith({
    required String yamlConfigName,
    required List<String> remoteArguments,
    void Function(String)? projectNameCallback,
  }) {
    final currentPath = Directory.current.path;

    YamlMap? getYaml() {
      try {
        final yamlFile = File('$currentPath/pubspec.yaml');
        final yamlRoot = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
        final projectName = yamlRoot['name'].toString();
        projectNameCallback?.call(projectName);
        return yamlRoot[yamlConfigName] as YamlMap;
      } on Object catch (_) {
        return null;
      }
    }

    final yaml = getYaml();
    final arguments = remoteArguments.toArgumentsMap();
    for (final config in this) {
      config.init(yaml, arguments);
    }
  }
}
