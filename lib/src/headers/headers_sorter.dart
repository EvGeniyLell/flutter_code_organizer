import 'dart:io';

import 'package:flutter_code_inspector/src/common/common.dart';

import 'package:flutter_code_inspector/src/headers/header_sorter_data/header_sorter_data.dart';

class HeadersSorterModule extends CommonModule {
  static const yamlConfigName = 'flutter_headers_sorter';

  HeadersSorterModule({required super.remoteArguments});

  final allowedDirectories = RemoteConfigMultiOption(
    name: 'allowed_directories',
    defaultValue: ['lib/.*', 'plugins/.*'],
  );
  final allowedExtensions = RemoteConfigMultiOption(
    name: 'allowed_extensions',
    defaultValue: ['.dart'],
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

    final stopwatch = Stopwatch()..start();

    final currentPath = Directory.current.path;

    final files = getFiles(
      currentPath,
      allowedDirectories: allowedDirectories.value,
      allowedExtensions: allowedExtensions.value,
    );

    print('files count: ${files.length}');
    final file = files.first;
    print('file: ${file.path}');
    final hFile = HeaderSorterData(
      file: file,
      projectName: projectName,
    );
    print('dartImports: ${hFile.imports.dartImports}');
    print('flutterImports: ${hFile.imports.flutterImports}');
    print('packageImports: ${hFile.imports.packageImports}');
    print('projectImports: ${hFile.imports.projectImports}');

    print('dartExports: ${hFile.exports.dartExports}');
    print('flutterExports: ${hFile.exports.flutterExports}');
    print('packageExports: ${hFile.exports.packageExports}');
    print('projectExports: ${hFile.exports.projectExports}');

    print('parts: ${hFile.parts.parts}');

    print('code: ${hFile.code}');

    print('firstRemoveIndex: ${hFile.firstRemoveIndex}');
    print('exports.firstRemoveIndex: ${hFile.exports.firstRemoveIndex}');
  }

  // Finders ------------------------------------------------------------------

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
}