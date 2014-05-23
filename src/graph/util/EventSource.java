/**
 * $Id: EventSource.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.util;

import java.util.ArrayList;
import java.util.List;

/**
 * Base class for objects that dispatch named events.
 */
public class EventSource
{

	/**
	 * Defines the requirements for an object that listens to an event source.
	 */
	public interface IEventListener
	{

		/**
		 * Called when the graph model has changed.
		 * 
		 * @param sender Reference to the source of the event.
		 * @param evt Event object to be dispatched.
		 */
		void invoke(Object sender, EventObj evt);

	}

	/**
	 * Holds the event names and associated listeners in an array. The array
	 * contains the event name followed by the respective listener for each
	 * registered listener.
	 */
	protected transient List<Object> _eventListeners = null;

	/**
	 * Holds the source object for this event source.
	 */
	protected Object _eventSource;

	/**
	 * Specifies if events can be fired. Default is true.
	 */
	protected boolean _eventsEnabled = true;

	/**
	 * Constructs a new event source using this as the source object.
	 */
	public EventSource()
	{
		this(null);
	}

	/**
	 * Constructs a new event source for the given source object.
	 */
	public EventSource(Object source)
	{
		setEventSource(source);
	}

	/**
	 * 
	 */
	public Object getEventSource()
	{
		return _eventSource;
	}

	/**
	 * 
	 */
	public void setEventSource(Object value)
	{
		this._eventSource = value;
	}

	/**
	 * 
	 */
	public boolean isEventsEnabled()
	{
		return _eventsEnabled;
	}

	/**
	 * 
	 */
	public void setEventsEnabled(boolean eventsEnabled)
	{
		this._eventsEnabled = eventsEnabled;
	}

	/**
	 * Binds the specified function to the given event name. If no event name
	 * is given, then the listener is registered for all events.
	 */
	public void addListener(String eventName, IEventListener listener)
	{
		if (_eventListeners == null)
		{
			_eventListeners = new ArrayList<Object>();
		}

		_eventListeners.add(eventName);
		_eventListeners.add(listener);
	}

	/**
	 * Function: removeListener
	 *
	 * Removes all occurances of the given listener from the list of listeners.
	 */
	public void removeListener(IEventListener listener)
	{
		removeListener(listener, null);
	}

	/**
	 * Function: removeListener
	 *
	 * Removes all occurances of the given listener from the list of listeners.
	 */
	public void removeListener(IEventListener listener, String eventName)
	{
		if (_eventListeners != null)
		{
			for (int i = _eventListeners.size() - 2; i > -1; i -= 2)
			{
				if (_eventListeners.get(i + 1) == listener
						&& (eventName == null || String.valueOf(
								_eventListeners.get(i)).equals(eventName)))
				{
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
	public void fireEvent(EventObj evt)
	{
		fireEvent(evt, null);
	}

	/**
	 * Dispatches the given event name, passing all arguments after the given
	 * name to the registered listeners for the event.
	 */
	public void fireEvent(EventObj evt, Object sender)
	{
		if (_eventListeners != null && !_eventListeners.isEmpty()
				&& isEventsEnabled())
		{
			if (sender == null)
			{
				sender = getEventSource();
			}

			if (sender == null)
			{
				sender = this;
			}

			for (int i = 0; i < _eventListeners.size(); i += 2)
			{
				String listen = (String) _eventListeners.get(i);

				if (listen == null || listen.equals(evt.getName()))
				{
					((IEventListener) _eventListeners.get(i + 1)).invoke(
							sender, evt);
				}
			}
		}
	}

}
