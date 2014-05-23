/**
 * $Id: SharedState.java,v 1.1 2012/11/15 13:26:50 gaudenz Exp $
 * Copyright (c) 2007-2012, JGraph Ltd
 */
package graph.sharing;

import graph.util.EventSource;
import graph.util.XmlUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.w3c.dom.Node;

/**
 * Implements a diagram that may be shared among multiple sessions. This
 * implementation is based only on string, it does not have a model instance.
 * The diagram is represented by its initial state and the sequence of edits
 * as applied to the diagram.
 */
public class SharedState extends EventSource
{

	/**
	 * Defines the requirements for an object that listens to changes on the
	 * shared diagram.
	 */
	public interface DiagramChangeListener
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
	protected List<DiagramChangeListener> diagramChangeListeners;

	/**
	 * Holds the initial state of the diagram.
	 */
	protected String state;

	/**
	 * Holds the history of all changes of initial state.
	 */
	protected StringBuffer delta = new StringBuffer();

	/**
	 * Constructs a new diagram with the given state.
	 * 
	 * @param state Initial state of the diagram.
	 */
	public SharedState(String state)
	{
		this.state = state;
	}

	/**
	 * Returns the initial state of the diagram.
	 */
	public String getState()
	{
		return state;
	}

	/**
	 * Returns the history of all changes as a string.
	 */
	public synchronized String getDelta()
	{
		return delta.toString();
	}

	/**
	 * Appends the given string to the history and dispatches the change to all
	 * sessions that are listening to this shared diagram.
	 * 
	 * @param sender Session where the change originated from.
	 * @param delta XML that represents the change.
	 */
	public void processDelta(Object sender, Node delta)
	{
		StringBuffer edits = new StringBuffer();

		synchronized (this)
		{
			Node edit = delta.getFirstChild();

			while (edit != null)
			{
				if (edit.getNodeName().equals("edit"))
				{
					edits.append(processEdit(edit));
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
	protected String processEdit(Node node)
	{
		return XmlUtils.getXml(node);
	}

	/**
	 * 
	 */
	public synchronized void addDelta(String xml)
	{
		// TODO: Clear delta if xml contains RootChange
		delta.append(xml);
	}

	/**
	 * Clears the history of all changes.
	 */
	public synchronized void resetDelta()
	{
		delta = new StringBuffer();
	}

	/**
	 * Adds the given listener to the list of diagram change listeners.
	 * 
	 * @param listener Diagram change listener to be added.
	 */
	public void addDiagramChangeListener(DiagramChangeListener listener)
	{
		if (diagramChangeListeners == null)
		{
			diagramChangeListeners = new ArrayList<DiagramChangeListener>();
		}

		diagramChangeListeners.add(listener);
	}

	/**
	 * Removes the given listener from the list of diagram change listeners.
	 * 
	 * @param listener Diagram change listener to be removed.
	 */
	public void removeDiagramChangeListener(DiagramChangeListener listener)
	{
		if (diagramChangeListeners != null)
		{
			diagramChangeListeners.remove(listener);
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
		if (diagramChangeListeners != null)
		{
			Iterator<DiagramChangeListener> it = diagramChangeListeners
					.iterator();

			while (it.hasNext())
			{
				DiagramChangeListener listener = it.next();
				listener.diagramChanged(sender, edits);
			}
		}
	}

}
