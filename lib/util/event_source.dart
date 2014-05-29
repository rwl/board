/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.util;

//import java.util.ArrayList;
//import java.util.List;

/**
 * Defines the requirements for an object that listens to an event source.
 */
//interface IEventListener
//{
//
//  /**
//   * Called when the graph model has changed.
//   *
//   * @param sender Reference to the source of the event.
//   * @param evt Event object to be dispatched.
//   */
//  void invoke(Object sender, EventObj evt);
//
//}
typedef IEventListener(Object sender, EventObj evt);

/**
 * Base class for objects that dispatch named events.
 */
class EventSource {

  /**
	 * Holds the event names and associated listeners in an array. The array
	 * contains the event name followed by the respective listener for each
	 * registered listener.
	 */
  /*transient*/ List<Object> _eventListeners = null;

  /**
	 * Holds the source object for this event source.
	 */
  Object _eventSource;

  /**
	 * Specifies if events can be fired. Default is true.
	 */
  bool _eventsEnabled = true;

  /**
	 * Constructs a new event source using this as the source object.
	 */
  //	EventSource()
  //	{
  //		this(null);
  //	}

  /**
	 * Constructs a new event source for the given source object.
	 */
  EventSource([Object source = null]) {
    setEventSource(source);
  }

  /**
	 * 
	 */
  Object getEventSource() {
    return _eventSource;
  }

  Object get eventSource => _eventSource;

  /**
	 * 
	 */
  void setEventSource(Object value) {
    this._eventSource = value;
  }

  void set eventSource (Object s) {
    _eventSource = s;
  }

  /**
	 * 
	 */
  bool isEventsEnabled() {
    return _eventsEnabled;
  }

  /**
	 * 
	 */
  void setEventsEnabled(bool eventsEnabled) {
    this._eventsEnabled = eventsEnabled;
  }

  /**
	 * Binds the specified function to the given event name. If no event name
	 * is given, then the listener is registered for all events.
	 */
  void addListener(String eventName, IEventListener listener) {
    if (_eventListeners == null) {
      _eventListeners = new List<Object>();
    }

    _eventListeners.add(eventName);
    _eventListeners.add(listener);
  }

  /**
	 * Function: removeListener
	 *
	 * Removes all occurances of the given listener from the list of listeners.
	 */
  //	void removeListener(IEventListener listener)
  //	{
  //		removeListener(listener, null);
  //	}

  /**
	 * Function: removeListener
	 *
	 * Removes all occurances of the given listener from the list of listeners.
	 */
  void removeListener(IEventListener listener, [String eventName = null]) {
    if (_eventListeners != null) {
      for (int i = _eventListeners.length - 2; i > -1; i -= 2) {
        if (_eventListeners[i + 1] == listener && (eventName == null || _eventListeners[i].toString() == eventName)) {
          _eventListeners.remove(i + 1);
          _eventListeners.remove(i);
        }
      }
    }
  }

  /**
	 * Dispatches the given event name with this object as the event source.
	 * <code>fireEvent(new EventObj("eventName", key1, val1, .., keyN, valN))</code>
	 * 
	 */
  //	void fireEvent(EventObj evt)
  //	{
  //		fireEvent(evt, null);
  //	}

  /**
	 * Dispatches the given event name, passing all arguments after the given
	 * name to the registered listeners for the event.
	 */
  void fireEvent(EventObj evt, [Object sender = null]) {
    if (_eventListeners != null && _eventListeners != 0 && isEventsEnabled()) {
      if (sender == null) {
        sender = getEventSource();
      }

      if (sender == null) {
        sender = this;
      }

      for (int i = 0; i < _eventListeners.length; i += 2) {
        String listen = _eventListeners[i] as String;

        if (listen == null || listen == evt.getName()) {
          (_eventListeners[i + 1] as IEventListener)(sender, evt);
        }
      }
    }
  }

}
