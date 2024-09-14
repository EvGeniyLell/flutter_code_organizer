// import 'dart:io';
//
// class HeaderInspector {
//   factory HeaderInspector(File file) {
//     final lines = file.readAsLinesSync();
//     return HeaderInspector._(file, lines);
//   }
//
//   HeaderInspector._(this.file, this.lines);
//
//   final File file;
//   final List<String> lines;
//   final String projectDir;
//   final String projectName;
//
//   List<String> call() {
//     final List<String> results = [];
//
//     for (final line in lines) {
//       _forbiddenThemselfImports(line);
//     }
//
//     return results;
//   }
//
//   void _forbiddenThemselfImports(String line) {
//     final features = file.features(projectDir);
//     for (int i = 0; i < features.length; i += 1) {
//       final subFeatures = features.sublist(0, i + 1);
//
//       final subPath = '${subFeatures.join('/')}/${subFeatures.last}';
//       final exp =
//           RegExp('^import \'package:$projectName/src/$subPath.dart\';\$');
//       final hasMatch = exp.hasMatch(line);
//       if (hasMatch) {
//         print('File: ${file.path}');
//         print('Forbidden: $line');
//       }
//     }
//   }
//
//   void forbiddenThemself(String projectDir, String projectName) {
//     final needPrint = file.path.contains('analytics_cubit.dart');
//     final features = file.features(projectDir);
//     if (needPrint) {
//       print('------------------------------------');
//       print('file: ${file.path}');
//       print('features: ${features}');
//     }
//     for (int i = 0; i < features.length; i += 1) {
//       final subFeatures = features.sublist(0, i + 1);
//
//       final subPath = '${subFeatures.join('/')}/${subFeatures.last}';
//       final exp =
//           RegExp('^import \'package:$projectName/src/$subPath.dart\';\$');
//       if (needPrint) {
//         print('exp: ${exp.pattern}');
//       }
//       for (final line in lines) {
//         final hasMatch = exp.hasMatch(line);
//         if (hasMatch) {
//           print('File: ${file.path}');
//           print('Forbidden: $line');
//         }
//       }
//     }
//   }
//
//   void test() {
//     const projectName = 'projectName';
//     const featureName = 'featureName';
//
//     const featurePath = 'lib/src/($featureName)/[a-z_].dart';
//
//     final allowOuterFeatures = [
//       'package:$projectName/src/$featureName.dart',
//       'package:$projectName/src/$featureName/$featureName.dart',
//     ];
//
//     final forbiddenOuterFeatures = [
//       'package:$projectName/src/$featureName/$featureName.dart',
//     ];
//     print('Test');
//   }
// }
//
// extension on File {
//   List<String> features(String projectDir) {
//     // print('File: $path');
//     // print('    : $projectDir/lib/src/(.*)/[a-z_].dart');
//     return RegExp('^$projectDir/lib/src/(.*)/[a-z_]+.dart\$')
//             .firstMatch(path)
//             ?.group(1)
//             ?.split('/') ??
//         [];
//   }
// }
