typedef ArgumentsMap = Map<String, List<String>>;

extension RemoteArgumentsExtension on List<String> {
  ArgumentsMap toArgumentsMap() {
    final ArgumentsMap result = {};
    String? currentKey;
    List<String> currentList = [];

    void applyNewKey(String newKey) {
      final oldKey = currentKey;
      if (oldKey != null) {
        result[oldKey] = currentList;
      }
      currentList = [];
      currentKey = newKey;
    }

    for (final argument in this) {
      if (argument.startsWith('--')) {
        applyNewKey(argument.substring(2));
        continue;
      }
      if (argument.startsWith('-')) {
        applyNewKey(argument.substring(1));
        continue;
      }
      currentList.add(argument);
    }
    applyNewKey('#end#');
    return result;
  }
}
