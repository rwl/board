/**
 * $Id: SharedGraphModel.java,v 1.1 2012/11/15 13:26:50 gaudenz Exp $
 * Copyright (c) 2007-2012, JGraph Ltd
 */
package graph.sharing;

import graph.io.Codec;
import graph.model.GraphModel;
import graph.model.ICell;
import graph.model.GraphModel.ChildChange;
import graph.model.IGraphModel.AtomicGraphModelChange;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.UndoableEdit;
import graph.util.XmlUtils;

import java.util.LinkedList;

import org.w3c.dom.Node;

/**
 * Implements a diagram that may be shared among multiple sessions.
 */
public class SharedGraphModel extends SharedState
{

	/**
	 * 
	 */
	protected GraphModel model;

	/**
	 * 
	 */
	protected Codec codec = new Codec()
	{
		public Object lookup(String id)
		{
			return model.getCell(id);
		}
	};

	/**
	 * Whether remote changes should be significant in the
	 * local command history. Default is true.
	 */
	protected boolean significantRemoteChanges = true;

	/**
	 * Constructs a new diagram with the given model.
	 * 
	 * @param model Initial model of the diagram.
	 */
	public SharedGraphModel(GraphModel model)
	{
		super(null); // Overrides getState
		this.model = model;
	}

	/**
	 * @return the model
	 */
	public GraphModel getModel()
	{
		return model;
	}

	/**
	 * @return the significantRemoteChanges
	 */
	public boolean isSignificantRemoteChanges()
	{
		return significantRemoteChanges;
	}

	/**
	 * @param significantRemoteChanges the significantRemoteChanges to set
	 */
	public void setSignificantRemoteChanges(boolean significantRemoteChanges)
	{
		this.significantRemoteChanges = significantRemoteChanges;
	}

	/**
	 * Returns the initial state of the diagram.
	 */
	public String getState()
	{
		return XmlUtils.getXml(codec.encode(model));
	}

	/**
	 * 
	 */
	public synchronized void addDelta(String edits)
	{
		// Edits are not added to the history. They are sent straight out to
		// all sessions and the model is updated so the next session will get
		// these edits via the new state of the model in getState.
	}

	/**
	 * 
	 */
	protected String processEdit(Node node)
	{
		AtomicGraphModelChange[] changes = decodeChanges(node.getFirstChild());

		if (changes.length > 0)
		{
			UndoableEdit edit = createUndoableEdit(changes);

			// No notify event here to avoid the edit from being encoded and transmitted
			// LATER: Remove changes property (deprecated)
			model.fireEvent(new EventObj(Event.CHANGE, "edit", edit,
					"changes", changes));
			model.fireEvent(new EventObj(Event.UNDO, "edit", edit));
			fireEvent(new EventObj(Event.FIRED, "edit", edit));
		}

		return super.processEdit(node);
	}

	/**
	 * Creates a new UndoableEdit that implements the notify function to fire
	 * a change and notify event via the model.
	 */
	protected UndoableEdit createUndoableEdit(
			AtomicGraphModelChange[] changes)
	{
		UndoableEdit edit = new UndoableEdit(this, significantRemoteChanges)
		{
			public void dispatch()
			{
				// LATER: Remove changes property (deprecated)
				((GraphModel) source).fireEvent(new EventObj(
						Event.CHANGE, "edit", this, "changes", changes));
				((GraphModel) source).fireEvent(new EventObj(
						Event.NOTIFY, "edit", this, "changes", changes));
			}
		};

		for (int i = 0; i < changes.length; i++)
		{
			edit.add(changes[i]);
		}

		return edit;
	}

	/**
	 * Adds removed cells to the codec object lookup for references to the removed
	 * cells after this point in time.
	 */
	protected AtomicGraphModelChange[] decodeChanges(Node node)
	{
		// Updates the document in the existing codec
		codec.setDocument(node.getOwnerDocument());

		LinkedList<AtomicGraphModelChange> changes = new LinkedList<AtomicGraphModelChange>();

		while (node != null)
		{
			Object change;

			if (node.getNodeName().equals("RootChange"))
			{
				// Handles the special case were no ids should be
				// resolved in the existing model. This change will
				// replace all registered ids and cells from the
				// model and insert a new cell hierarchy instead.
				Codec tmp = new Codec(node.getOwnerDocument());
				change = tmp.decode(node);
			}
			else
			{
				change = codec.decode(node);
			}

			if (change instanceof AtomicGraphModelChange)
			{
				AtomicGraphModelChange ac = (AtomicGraphModelChange) change;

				ac.setModel(model);
				ac.execute();

				// Workaround for references not being resolved if cells have
				// been removed from the model prior to being referenced. This
				// adds removed cells in the codec object lookup table.
				if (ac instanceof ChildChange
						&& ((ChildChange) ac).getParent() == null)
				{
					cellRemoved(((ChildChange) ac).getChild());
				}

				changes.add(ac);
			}

			node = node.getNextSibling();
		}

		return changes.toArray(new AtomicGraphModelChange[changes.size()]);
	}

	/**
	 * Adds removed cells to the codec object lookup for references to the removed
	 * cells after this point in time.
	 */
	public void cellRemoved(Object cell)
	{
		codec.putObject(((ICell) cell).getId(), cell);

		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			cellRemoved(model.getChildAt(cell, i));
		}
	}

}
