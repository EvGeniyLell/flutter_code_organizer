import 'package:yaml/yaml.dart';

export 'package:yaml/yaml.dart';

extension YamlMapExtension on YamlMap {
  List<T>? readList<T extends Object>(String key) {
    final value = this[key];
    if (value == null) {
      return null;
    }
    return _decodeList<T>(value);
  }

  bool? readFlag(String key) {
    final value = this[key];
    if (value == null) {
      return null;
    }
    return _decodeFlag(value);
  }

  T? readScalar<T extends Object>(String key) {
    final value = this[key];
    if (value == null) {
      return null;
    }
    return _decodeScalar<T>(value);
  }

  List<T>? _decodeList<T extends Object>(dynamic value) {
    if (value != null) {
      if (value is YamlList) {
        return value.nodes
            .map<T?>((node) {
              final v = _decodeScalar<T>(node);
              if (v != null) {
                return v;
              }
              return null;
            })
            .nonNulls
            .toList();
      }
    }
    return null;
  }

  T? _decodeScalar<T>(dynamic value) {
    if (value != null) {
      if (value != null && value is YamlScalar) {
        if (value.value is T) {
          return value.value as T;
        }
      }
      if (value != null && value is T) {
        return value;
      }
    }
    return null;
  }

  bool _decodeFlag(dynamic value) {
    if (value != null) {
      if (value is bool) {
        return value;
      }
    }
    return false;
  }
}
