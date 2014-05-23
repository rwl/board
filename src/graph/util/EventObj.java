/**
 * $Id: EventObj.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.util;

import java.util.Hashtable;
import java.util.Map;

/**
 * Base class for objects that dispatch named events.
 */
public class EventObj
{

	/**
	 * Holds the name of the event.
	 */
	protected String _name;
	
	/**
	 * Holds the properties of the event.
	 */
	protected Map<String, Object> _properties;
	
	/**
	 * Holds the consumed state of the event. Default is false.
	 */
	protected boolean _consumed = false;

	/**
	 * Constructs a new event for the given name.
	 */
	public EventObj(String name)
	{
		this(name, (Object[]) null);
	}

	/**
	 * Constructs a new event for the given name and properties. The optional
	 * properties are specified using a sequence of keys and values, eg.
	 * <code>new EventObj("eventName", key1, val1, .., keyN, valN))</code>
	 */
	public EventObj(String name, Object... args)
	{
		this._name = name;
		_properties = new Hashtable<String, Object>();
		
		if (args != null)
		{
			for (int i = 0; i < args.length; i += 2)
			{
				if (args[i + 1] != null)
				{
					_properties.put(String.valueOf(args[i]), args[i + 1]);
				}
			}
		}
	}

	/**
	 * Returns the name of the event.
	 */
	public String getName()
	{
		return _name;
	}
	
	/**
	 * 
	 */
	public Map<String, Object> getProperties()
	{
		return _properties;
	}

	/**
	 * 
	 */
	public Object getProperty(String key)
	{
		return _properties.get(key);
	}

	/**
	 * Returns true if the event has been consumed.
	 */
	public boolean isConsumed()
	{
		return _consumed;
	}

	/**
	 * Consumes the event.
	 */
	public void consume()
	{
		_consumed = true;
	}

}
