usage:
add to pubspec.yaml
```yaml
flutter_code_organizer:
  headers_sorter:
    allowed_directories:
      - ^lib/src/.*
    allowed_extensions:
      - .dart
    sort_order:
      - import_dart
      - space
      - import_flutter
      - space
      - import_package
      - space
      - import_project
      - space
      - import_relative
      - space
      - export_dart
      - space
      - export_flutter
      - space
      - export_package
      - space
      - export_project
      - space
      - export_relative
      - space
      - part
  headers_inspector:
    allowed_directories:
      - ^lib/src/.*
    allowed_extensions:
      - .dart
    forbid_themself_package_imports:
      enabled: true
    forbid_other_features_package_imports:
      enabled: true
    forbid_relative_imports:
      enabled: true
    forbid_package_exports:
      enabled: true
      ignore_files:
        - ^lib/src/common/common.dart
    forbid_other_features_relative_exports:
      enabled: true
  localizations_inspector:
    allowed_directories:
      - ^translation/.*
    allowed_extensions:
      - .arb
    locale_pattern: .*/(\w+).arb$
    find_key_duplicates_enabled: true
    find_value_duplicates_enabled: true
    find_key_and_value_duplicates_enabled: true
    find_missed_keys_enabled: true
```