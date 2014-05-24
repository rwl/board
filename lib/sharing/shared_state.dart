/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.sharing;

//import java.util.ArrayList;
//import java.util.Iterator;
//import java.util.List;

//import org.w3c.dom.Node;

/**
 * Implements a diagram that may be shared among multiple sessions. This
 * implementation is based only on string, it does not have a model instance.
 * The diagram is represented by its initial state and the sequence of edits
 * as applied to the diagram.
 */
class SharedState extends EventSource
{

	/**
	 * Defines the requirements for an object that listens to changes on the
	 * shared diagram.
	 */
	interface DiagramChangeListener
	{

		/**
		 * Fires when the shared diagram was changed.
		 * 
		 * @param sender Session where the change was received from.
		 * @param edits String that represents the edits.
		 */
		void diagramChanged(Object sender, String edits);
	}

	/**
	 * Holds a list of diagram change listeners.
	 */
	List<DiagramChangeListener> _diagramChangeListeners;

	/**
	 * Holds the initial state of the diagram.
	 */
	String _state;

	/**
	 * Holds the history of all changes of initial state.
	 */
	StringBuffer _delta = new StringBuffer();

	/**
	 * Constructs a new diagram with the given state.
	 * 
	 * @param state Initial state of the diagram.
	 */
	SharedState(String state)
	{
		this._state = state;
	}

	/**
	 * Returns the initial state of the diagram.
	 */
	String getState()
	{
		return _state;
	}

	/**
	 * Returns the history of all changes as a string.
	 */
	synchronized String getDelta()
	{
		return _delta.toString();
	}

	/**
	 * Appends the given string to the history and dispatches the change to all
	 * sessions that are listening to this shared diagram.
	 * 
	 * @param sender Session where the change originated from.
	 * @param delta XML that represents the change.
	 */
	void processDelta(Object sender, Node delta)
	{
		StringBuffer edits = new StringBuffer();

		synchronized (this)
		{
			Node edit = delta.getFirstChild();

			while (edit != null)
			{
				if (edit.getNodeName().equals("edit"))
				{
					edits.append(_processEdit(edit));
				}

				edit = edit.getNextSibling();
			}
		}

		String xml = edits.toString();
		addDelta(xml);
		dispatchDiagramChangeEvent(sender, xml);
	}

	/**
	 * 
	 */
	String _processEdit(Node node)
	{
		return XmlUtils.getXml(node);
	}

	/**
	 * 
	 */
	synchronized void addDelta(String xml)
	{
		// TODO: Clear delta if xml contains RootChange
		_delta.append(xml);
	}

	/**
	 * Clears the history of all changes.
	 */
	synchronized void resetDelta()
	{
		_delta = new StringBuffer();
	}

	/**
	 * Adds the given listener to the list of diagram change listeners.
	 * 
	 * @param listener Diagram change listener to be added.
	 */
	void addDiagramChangeListener(DiagramChangeListener listener)
	{
		if (_diagramChangeListeners == null)
		{
			_diagramChangeListeners = new List<DiagramChangeListener>();
		}

		_diagramChangeListeners.add(listener);
	}

	/**
	 * Removes the given listener from the list of diagram change listeners.
	 * 
	 * @param listener Diagram change listener to be removed.
	 */
	void removeDiagramChangeListener(DiagramChangeListener listener)
	{
		if (_diagramChangeListeners != null)
		{
			_diagramChangeListeners.remove(listener);
		}
	}

	/**
	 * Dispatches the given event information to all diagram change listeners.
	 * 
	 * @param sender Session where the change was received from.
	 * @param xml XML string that represents the change.
	 */
	void dispatchDiagramChangeEvent(Object sender, String edits)
	{
		if (_diagramChangeListeners != null)
		{
			Iterator<DiagramChangeListener> it = _diagramChangeListeners
					.iterator();

			while (it.hasNext())
			{
				DiagramChangeListener listener = it.next();
				listener.diagramChanged(sender, edits);
			}
		}
	}

}
