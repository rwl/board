/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.util;


/**
 * Base class for objects that dispatch named events.
 */
class EventObj {

  /**
   * Holds the name of the event.
   */
  String _name;

  /**
   * Holds the properties of the event.
   */
  Map<String, Object> _properties;

  /**
   * Holds the consumed state of the event. Default is false.
   */
  bool _consumed = false;

  /**
   * Constructs a new event for the given name.
   */
  //	EventObj(String name)
  //	{
  //		this(name, (List<Object>) null);
  //	}

  /**
   * Constructs a new event for the given name and properties. The optional
   * properties are specified using a sequence of keys and values, eg.
   * <code>new EventObj("eventName", key1, val1, .., keyN, valN))</code>
   */
  EventObj(String name, [List<Object> args=null]) {
    this._name = name;
    _properties = new Map<String, Object>();

    if (args != null) {
      for (int i = 0; i < args.length; i += 2) {
        if (args[i + 1] != null) {
          _properties[args[i].toString()] = args[i + 1];
        }
      }
    }
  }

  /**
   * Returns the name of the event.
   */
  String getName() {
    return _name;
  }

  /**
   * 
   */
  Map<String, Object> getProperties() {
    return _properties;
  }

  /**
   * 
   */
  Object getProperty(String key) {
    return _properties[key];
  }

  /**
   * Returns true if the event has been consumed.
   */
  bool isConsumed() {
    return _consumed;
  }

  /**
   * Consumes the event.
   */
  void consume() {
    _consumed = true;
  }

}
