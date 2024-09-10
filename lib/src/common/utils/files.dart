import 'dart:io';

/// Get files according to parameters.
/// - [currentPath] is the path to start the search.
/// - [allowedDirectories] is the list of directories to allow.
/// If empty all directories are allowed.
/// - [allowedExtensions] is the list of extensions to allow.
/// If empty all extensions are allowed.
Iterable<File> getFiles(
  String currentPath, {
  List<String> allowedDirectories = const [],
  List<String> allowedExtensions = const [],
}) {
  return Directory(currentPath)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) {
    bool fileAllowed = true;

    if (fileAllowed && allowedExtensions.isNotEmpty) {
      fileAllowed = allowedExtensions.any((ext) {
        return file.path.endsWith(ext);
      });
    }

    if (fileAllowed && allowedDirectories.isNotEmpty) {
      fileAllowed = allowedDirectories.any((pattern) {
        return RegExp(pattern).hasMatch(file.path);
      });
    }

    return fileAllowed;
  });
}
