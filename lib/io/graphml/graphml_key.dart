/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Possibles values for the keyFor Attribute
 */
class keyForValues {
  final _value;

  const keyForValues._internal(this._value);

  toString() => '$_value';

  static const GRAPH = const keyForValues._internal('GRAPH');
  static const NODE = const keyForValues._internal('NODE');
  static const EDGE = const keyForValues._internal('EDGE');
  static const HYPEREDGE = const keyForValues._internal('HYPEREDGE');
  static const PORT = const keyForValues._internal('PORT');
  static const ENDPOINT = const keyForValues._internal('ENDPOINT');
  static const ALL = const keyForValues._internal('ALL');
}

/**
 * Possibles values for the keyType Attribute.
 */
class keyTypeValues {
  final _value;

  const keyTypeValues._internal(this._value);

  toString() => '$_value';

  static const BOOLEAN = const keyTypeValues._internal('BOOLEAN');
  static const INT = const keyTypeValues._internal('INT');
  static const LONG = const keyTypeValues._internal('LONG');
  static const FLOAT = const keyTypeValues._internal('FLOAT');
  static const DOUBLE = const keyTypeValues._internal('DOUBLE');
  static const STRING = const keyTypeValues._internal('STRING');
}


/**
 * Represents a Key element in the GML Structure.
 */
class GraphMlKey {
  String _keyDefault;

  String _keyId;

  keyForValues _keyFor;

  String _keyName;

  keyTypeValues _keyType;

  /**
	 * Construct a key with the given parameters.
	 * @param keyId Key's ID
	 * @param keyFor Scope of the key.
	 * @param keyName Key Name
	 * @param keyType Type of the values represented for this key.
	 */
  GraphMlKey(String keyId, keyForValues keyFor, String keyName, keyTypeValues keyType) {
    this._keyId = keyId;
    this._keyFor = keyFor;
    this._keyName = keyName;
    this._keyType = keyType;
    this._keyDefault = _defaultValue();
  }

  /**
	 * Construct a key from a xml key element.
	 * @param keyElement Xml key element.
	 */
  GraphMlKey(Element keyElement) {
    this._keyId = keyElement.getAttribute(GraphMlConstants.ID);
    this._keyFor = enumForValue(keyElement.getAttribute(GraphMlConstants.KEY_FOR));
    this._keyName = keyElement.getAttribute(GraphMlConstants.KEY_NAME);
    this._keyType = enumTypeValue(keyElement.getAttribute(GraphMlConstants.KEY_TYPE));
    this._keyDefault = _defaultValue();
  }

  String getKeyDefault() {
    return _keyDefault;
  }

  void setKeyDefault(String keyDefault) {
    this._keyDefault = keyDefault;
  }

  keyForValues getKeyFor() {
    return _keyFor;
  }

  void setKeyFor(keyForValues keyFor) {
    this._keyFor = keyFor;
  }

  String getKeyId() {
    return _keyId;
  }

  void setKeyId(String keyId) {
    this._keyId = keyId;
  }

  String getKeyName() {
    return _keyName;
  }

  void setKeyName(String keyName) {
    this._keyName = keyName;
  }

  keyTypeValues getKeyType() {
    return _keyType;
  }

  void setKeyType(keyTypeValues keyType) {
    this._keyType = keyType;
  }

  /**
	 * Returns the default value of the keyDefault attribute according
	 * the keyType.
	 */
  String _defaultValue() {
    String val = "";
    switch (this._keyType) {
      case BOOLEAN:
        {
          val = "false";
          break;
        }
      case DOUBLE:
        {
          val = "0";
          break;
        }
      case FLOAT:
        {
          val = "0";
          break;
        }
      case INT:
        {
          val = "0";
          break;
        }
      case LONG:
        {
          val = "0";
          break;
        }
      case STRING:
        {
          val = "";
          break;
        }
    }
    return val;
  }

  /**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element key = document.createElement(GraphMlConstants.KEY);

    if (!_keyName.equals("")) {
      key.setAttribute(GraphMlConstants.KEY_NAME, _keyName);
    }
    key.setAttribute(GraphMlConstants.ID, _keyId);

    if (!_keyName.equals("")) {
      key.setAttribute(GraphMlConstants.KEY_FOR, stringForValue(_keyFor));
    }

    if (!_keyName.equals("")) {
      key.setAttribute(GraphMlConstants.KEY_TYPE, stringTypeValue(_keyType));
    }

    if (!_keyName.equals("")) {
      key.setTextContent(_keyDefault);
    }

    return key;
  }

  /**
	 * Converts a String value in its corresponding enum value for the
	 * keyFor attribute.
	 * @param value Value in String representation.
	 * @return Returns the value in its enum representation.
	 */
  keyForValues enumForValue(String value) {
    keyForValues enumVal = keyForValues.ALL;

    if (value.equals(GraphMlConstants.GRAPH)) {
      enumVal = keyForValues.GRAPH;
    } else if (value.equals(GraphMlConstants.NODE)) {
      enumVal = keyForValues.NODE;
    } else if (value.equals(GraphMlConstants.EDGE)) {
      enumVal = keyForValues.EDGE;
    } else if (value.equals(GraphMlConstants.HYPEREDGE)) {
      enumVal = keyForValues.HYPEREDGE;
    } else if (value.equals(GraphMlConstants.PORT)) {
      enumVal = keyForValues.PORT;
    } else if (value.equals(GraphMlConstants.ENDPOINT)) {
      enumVal = keyForValues.ENDPOINT;
    } else if (value.equals(GraphMlConstants.ALL)) {
      enumVal = keyForValues.ALL;
    }

    return enumVal;
  }

  /**
	 * Converts a enum value in its corresponding String value for the
	 * keyFor attribute.
	 * @param value Value in enum representation.
	 * @return Returns the value in its String representation.
	 */
  String stringForValue(keyForValues value) {

    String val = GraphMlConstants.ALL;

    switch (value) {
      case GRAPH:
        {
          val = GraphMlConstants.GRAPH;
          break;
        }
      case NODE:
        {
          val = GraphMlConstants.NODE;
          break;
        }
      case EDGE:
        {
          val = GraphMlConstants.EDGE;
          break;
        }
      case HYPEREDGE:
        {
          val = GraphMlConstants.HYPEREDGE;
          break;
        }
      case PORT:
        {
          val = GraphMlConstants.PORT;
          break;
        }
      case ENDPOINT:
        {
          val = GraphMlConstants.ENDPOINT;
          break;
        }
      case ALL:
        {
          val = GraphMlConstants.ALL;
          break;
        }
    }

    return val;
  }

  /**
	 * Converts a String value in its corresponding enum value for the
	 * keyType attribute.
	 * @param value Value in String representation.
	 * @return Returns the value in its enum representation.
	 */
  keyTypeValues enumTypeValue(String value) {
    keyTypeValues enumVal = keyTypeValues.STRING;

    if (value.equals("boolean")) {
      enumVal = keyTypeValues.BOOLEAN;
    } else if (value.equals("double")) {
      enumVal = keyTypeValues.DOUBLE;
    } else if (value.equals("float")) {
      enumVal = keyTypeValues.FLOAT;
    } else if (value.equals("int")) {
      enumVal = keyTypeValues.INT;
    } else if (value.equals("long")) {
      enumVal = keyTypeValues.LONG;
    } else if (value.equals("string")) {
      enumVal = keyTypeValues.STRING;
    }

    return enumVal;
  }

  /**
	 * Converts a enum value in its corresponding string value for the
	 * keyType attribute.
	 * @param value Value in enum representation.
	 * @return Returns the value in its String representation.
	 */
  String stringTypeValue(keyTypeValues value) {
    String val = "string";

    switch (value) {
      case BOOLEAN:
        {
          val = "boolean";
          break;
        }
      case DOUBLE:
        {
          val = "double";
          break;
        }
      case FLOAT:
        {
          val = "float";
          break;
        }
      case INT:
        {
          val = "int";
          break;
        }
      case LONG:
        {
          val = "long";
          break;
        }
      case STRING:
        {
          val = "string";
          break;
        }
    }

    return val;
  }
}
