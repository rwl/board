/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.sharing;

//import graph.io.Codec;
//import graph.model.ChildChange;
//import graph.model.GraphModel;
//import graph.model.ICell;
//import graph.model.IGraphModel.AtomicGraphModelChange;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.UndoableEdit;
//import graph.util.XmlUtils;

//import java.util.LinkedList;

//import org.w3c.dom.Node;

/**
 * Implements a diagram that may be shared among multiple sessions.
 */
public class SharedGraphModel extends SharedState
{

	/**
	 * 
	 */
	protected GraphModel _model;

	/**
	 * 
	 */
	protected Codec _codec = new Codec()
	{
		public Object lookup(String id)
		{
			return _model.getCell(id);
		}
	};

	/**
	 * Whether remote changes should be significant in the
	 * local command history. Default is true.
	 */
	protected boolean _significantRemoteChanges = true;

	/**
	 * Constructs a new diagram with the given model.
	 * 
	 * @param model Initial model of the diagram.
	 */
	public SharedGraphModel(GraphModel model)
	{
		super(null); // Overrides getState
		this._model = model;
	}

	/**
	 * @return the model
	 */
	public GraphModel getModel()
	{
		return _model;
	}

	/**
	 * @return the significantRemoteChanges
	 */
	public boolean isSignificantRemoteChanges()
	{
		return _significantRemoteChanges;
	}

	/**
	 * @param significantRemoteChanges the significantRemoteChanges to set
	 */
	public void setSignificantRemoteChanges(boolean significantRemoteChanges)
	{
		this._significantRemoteChanges = significantRemoteChanges;
	}

	/**
	 * Returns the initial state of the diagram.
	 */
	public String getState()
	{
		return XmlUtils.getXml(_codec.encode(_model));
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
	protected String _processEdit(Node node)
	{
		AtomicGraphModelChange[] changes = _decodeChanges(node.getFirstChild());

		if (changes.length > 0)
		{
			UndoableEdit edit = _createUndoableEdit(changes);

			// No notify event here to avoid the edit from being encoded and transmitted
			// LATER: Remove changes property (deprecated)
			_model.fireEvent(new EventObj(Event.CHANGE, "edit", edit,
					"changes", changes));
			_model.fireEvent(new EventObj(Event.UNDO, "edit", edit));
			fireEvent(new EventObj(Event.FIRED, "edit", edit));
		}

		return super._processEdit(node);
	}

	/**
	 * Creates a new UndoableEdit that implements the notify function to fire
	 * a change and notify event via the model.
	 */
	protected UndoableEdit _createUndoableEdit(
			AtomicGraphModelChange[] changes)
	{
		UndoableEdit edit = new UndoableEdit(this, _significantRemoteChanges)
		{
			public void dispatch()
			{
				// LATER: Remove changes property (deprecated)
				((GraphModel) _source).fireEvent(new EventObj(
						Event.CHANGE, "edit", this, "changes", _changes));
				((GraphModel) _source).fireEvent(new EventObj(
						Event.NOTIFY, "edit", this, "changes", _changes));
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
	protected AtomicGraphModelChange[] _decodeChanges(Node node)
	{
		// Updates the document in the existing codec
		_codec.setDocument(node.getOwnerDocument());

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
				change = _codec.decode(node);
			}

			if (change instanceof AtomicGraphModelChange)
			{
				AtomicGraphModelChange ac = (AtomicGraphModelChange) change;

				ac.setModel(_model);
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
		_codec.putObject(((ICell) cell).getId(), cell);

		int childCount = _model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			cellRemoved(_model.getChildAt(cell, i));
		}
	}

}