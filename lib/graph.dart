library graph;

import 'dart:collection' show HashMap;

class Hashtable<K, V> extends HashMap<K, V> {

  factory Hashtable.from(Map<K, V> other) {
    return new HashMap<K, V>()..addAll(other);
  }
}
