import 'dart:io';

extension CommonFileExtension on File {
  // TODO(evg): consider to remove projectDir,
  //  it can be resolved of greedy regex.
  List<String> getProjectSrcFeaturesByPath(String projectDir) {
    return RegExp('^$projectDir/lib/src/(.*)/[a-z0-9_\\.]+.dart\$')
            .firstMatch(path)
            ?.group(1)
            ?.split('/') ??
        [];
  }

  String getRelativePath(String dir) {
    return path.replaceFirst('$dir/', '');
  }
}
