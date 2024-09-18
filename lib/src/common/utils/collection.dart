extension CollectionList<E> on List<E> {
  void removeWhereIndexed(bool Function(int index, E element) test) {
    int index = 0;
    return removeWhere((element) => test(index++, element));
  }

  void forEachWithEach(
    void Function(E a, E b) action, {
    bool includeSame = false,
  }) {
    for (int aIndex = 0; aIndex < length; aIndex += 1) {
      for (int bIndex = 0; bIndex < length; bIndex += 1) {
        if (aIndex != bIndex || includeSame) {
          action(this[aIndex], this[bIndex]);
        }
      }
    }
  }

  void forEachWithEachNext(void Function(E a, E b) action) {
    for (int aIndex = 0; aIndex < length; aIndex += 1) {
      for (int bIndex = aIndex + 1; bIndex < length; bIndex += 1) {
        action(this[aIndex], this[bIndex]);
      }
    }
  }
}

extension CollectionIterable<E> on Iterable<E> {
  void forEachIndexed(void Function(int index, E element) action) {
    int index = 0;
    return forEach((element) => action(index++, element));
  }

  Iterable<T> mapIndexed<T>(T Function(int index, E element) toElement) {
    int index = 0;
    return map((element) => toElement(index++, element));
  }

  List<List<E>> groupBy(bool Function(List<E> group, E element) test) {
    final result = <List<E>>[];
    for (final element in this) {
      final index = result.indexWhere((group) => test(group, element));
      if (index == -1) {
        result.add([element]);
      } else {
        result[index].add(element);
      }
    }
    return result;
  }
}
