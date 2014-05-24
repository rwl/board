/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.model;

import '../util/util.dart' show Event;
import '../util/util.dart' show EventObj;
import '../util/util.dart' show EventSource;
import '../util/util.dart' show Point2d;
import '../util/util.dart' show UndoableEdit;

//import java.io.IOException;
//import java.io.ObjectInputStream;
//import java.io.Serializable;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Collection;
//import java.util.HashSet;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;
//import java.util.Set;

/**
 * Defines the requirements for a graph model to be used with Graph.
 */
public interface IGraphModel
{

  /**
   * Defines the interface for an atomic change of the graph model.
   */
  public abstract class AtomicGraphModelChange implements UndoableChange
  {
    /**
     * Holds the model where the change happened.
     */
    protected IGraphModel model;

    /**
     * Constructs an empty atomic graph model change.
     */
    public AtomicGraphModelChange()
    {
      this(null);
    }

    /**
     * Constructs an atomic graph model change for the given model.
     */
    public AtomicGraphModelChange(IGraphModel model)
    {
      this.model = model;
    }

    /**
     * Returns the model where the change happened.
     */
    public IGraphModel getModel()
    {
      return model;
    }

    /**
     * Sets the model where the change is to be carried out.
     */
    public void setModel(IGraphModel model)
    {
      this.model = model;
    }

    /**
     * Executes the change on the model.
     */
    public abstract void execute();

  }

  /**
   * Returns the root of the model or the topmost parent of the given cell.
   * 
   * @return Returns the root cell.
   */
  Object getRoot();

  /**
   * Sets the root of the model and resets all structures.
   * 
   * @param root Cell that specifies the new root.
   */
  Object setRoot(Object root);

  /**
   * Returns an array of clones for the given array of cells.
   * Depending on the value of includeChildren, a deep clone is created for
   * each cell. Connections are restored based if the corresponding
   * cell is contained in the passed in array.
   * 
   * @param cells Array of cells to be cloned.
   * @param includeChildren Boolean indicating if the cells should be cloned
   * with all descendants.
   * @return Returns a cloned array of cells.
   */
  Object[] cloneCells(Object[] cells, bool includeChildren);

  /**
   * Returns true if the given parent is an ancestor of the given child.
   * 
   * @param parent Cell that specifies the parent.
   * @param child Cell that specifies the child.
   * @return Returns true if child is an ancestor of parent.
   */
  bool isAncestor(Object parent, Object child);

  /**
   * Returns true if the model contains the given cell.
   * 
   * @param cell Cell to be checked.
   * @return Returns true if the cell is in the model.
   */
  bool contains(Object cell);

  /**
   * Returns the parent of the given cell.
   *
   * @param child Cell whose parent should be returned.
   * @return Returns the parent of the given cell.
   */
  Object getParent(Object child);

  /**
   * Adds the specified child to the parent at the given index. If no index
   * is specified then the child is appended to the parent's array of
   * children.
   * 
   * @param parent Cell that specifies the parent to contain the child.
   * @param child Cell that specifies the child to be inserted.
   * @param index Integer that specifies the index of the child.
   * @return Returns the inserted child.
   */
  Object add(Object parent, Object child, int index);

  /**
   * Removes the specified cell from the model. This operation will remove
   * the cell and all of its children from the model.
   * 
   * @param cell Cell that should be removed.
   * @return Returns the removed cell.
   */
  Object remove(Object cell);

  /**
   * Returns the number of children in the given cell.
   *
   * @param cell Cell whose number of children should be returned.
   * @return Returns the number of children in the given cell.
   */
  int getChildCount(Object cell);

  /**
   * Returns the child of the given parent at the given index.
   * 
   * @param parent Cell that represents the parent.
   * @param index Integer that specifies the index of the child to be
   * returned.
   * @return Returns the child at index in parent.
   */
  Object getChildAt(Object parent, int index);

  /**
   * Returns the source or target terminal of the given edge depending on the
   * value of the bool parameter.
   * 
   * @param edge Cell that specifies the edge.
   * @param isSource Boolean indicating which end of the edge should be
   * returned.
   * @return Returns the source or target of the given edge.
   */
  Object getTerminal(Object edge, bool isSource);

  /**
   * Sets the source or target terminal of the given edge using.
   * 
   * @param edge Cell that specifies the edge.
   * @param terminal Cell that specifies the new terminal.
   * @param isSource Boolean indicating if the terminal is the new source or
   * target terminal of the edge.
   * @return Returns the new terminal.
   */
  Object setTerminal(Object edge, Object terminal, bool isSource);

  /**
   * Returns the number of distinct edges connected to the given cell.
   * 
   * @param cell Cell that represents the vertex.
   * @return Returns the number of edges connected to cell.
   */
  int getEdgeCount(Object cell);

  /**
   * Returns the edge of cell at the given index.
   * 
   * @param cell Cell that specifies the vertex.
   * @param index Integer that specifies the index of the edge to return.
   * @return Returns the edge at the given index.
   */
  Object getEdgeAt(Object cell, int index);

  /**
   * Returns true if the given cell is a vertex.
   * 
   * @param cell Cell that represents the possible vertex.
   * @return Returns true if the given cell is a vertex.
   */
  bool isVertex(Object cell);

  /**
   * Returns true if the given cell is an edge.
   * 
   * @param cell Cell that represents the possible edge.
   * @return Returns true if the given cell is an edge.
   */
  bool isEdge(Object cell);

  /**
   * Returns true if the given cell is connectable.
   * 
   * @param cell Cell whose connectable state should be returned.
   * @return Returns the connectable state of the given cell.
   */
  bool isConnectable(Object cell);

  /**
   * Returns the user object of the given cell.
   * 
   * @param cell Cell whose user object should be returned.
   * @return Returns the user object of the given cell.
   */
  Object getValue(Object cell);

  /**
   * Sets the user object of then given cell.
   * 
   * @param cell Cell whose user object should be changed.
   * @param value Object that defines the new user object.
   * @return Returns the new value.
   */
  Object setValue(Object cell, Object value);

  /**
   * Returns the geometry of the given cell.
   * 
   * @param cell Cell whose geometry should be returned.
   * @return Returns the geometry of the given cell.
   */
  Geometry getGeometry(Object cell);

  /**
   * Sets the geometry of the given cell.
   * 
   * @param cell Cell whose geometry should be changed.
   * @param geometry Object that defines the new geometry.
   * @return Returns the new geometry.
   */
  Geometry setGeometry(Object cell, Geometry geometry);

  /**
   * Returns the style of the given cell.
   * 
   * @param cell Cell whose style should be returned.
   * @return Returns the style of the given cell.
   */
  String getStyle(Object cell);

  /**
   * Sets the style of the given cell.
   * 
   * @param cell Cell whose style should be changed.
   * @param style String of the form stylename[;key=value] to specify
   * the new cell style.
   * @return Returns the new style.
   */
  String setStyle(Object cell, String style);

  /**
   * Returns true if the given cell is collapsed.
   * 
   * @param cell Cell whose collapsed state should be returned.
   * @return Returns the collapsed state of the given cell.
   */
  bool isCollapsed(Object cell);

  /**
   * Sets the collapsed state of the given cell.
   * 
   * @param cell Cell whose collapsed state should be changed.
   * @param collapsed Boolean that specifies the new collpased state.
   * @return Returns the new collapsed state.
   */
  bool setCollapsed(Object cell, bool collapsed);

  /**
   * Returns true if the given cell is visible.
   * 
   * @param cell Cell whose visible state should be returned.
   * @return Returns the visible state of the given cell.
   */
  bool isVisible(Object cell);

  /**
   * Sets the visible state of the given cell.
   * 
   * @param cell Cell whose visible state should be changed.
   * @param visible Boolean that specifies the new visible state.
   * @return Returns the new visible state.
   */
  bool setVisible(Object cell, bool visible);

  /**
   * Increments the updateLevel by one. The event notification is queued
   * until updateLevel reaches 0 by use of endUpdate.
   */
  void beginUpdate();

  /**
   * Decrements the updateLevel by one and fires a notification event if the
   * updateLevel reaches 0.
   */
  void endUpdate();

  /**
   * Binds the specified function to the given event name. If no event name
   * is given, then the listener is registered for all events.
   */
  void addListener(String eventName, IEventListener listener);

  /**
   * Function: removeListener
   *
   * Removes the given listener from the list of listeners.
   */
  void removeListener(IEventListener listener);

  /**
   * Function: removeListener
   *
   * Removes the given listener from the list of listeners.
   */
  void removeListener(IEventListener listener, String eventName);

}

/**
 * Extends EventSource to implement a graph model. The graph model acts as
 * a wrapper around the cells which are in charge of storing the actual graph
 * datastructure. The model acts as a transactional wrapper with event
 * notification for all changes, whereas the cells contain the atomic
 * operations for updating the actual datastructure.
 * 
 * Layers:
 * 
 * The cell hierarchy in the model must have a top-level root cell which
 * contains the layers (typically one default layer), which in turn contain the
 * top-level cells of the layers. This means each cell is contained in a layer.
 * If no layers are required, then all new cells should be added to the default
 * layer.
 * 
 * Layers are useful for hiding and showing groups of cells, or for placing
 * groups of cells on top of other cells in the display. To identify a layer,
 * the <isLayer> function is used. It returns true if the parent of the given
 * cell is the root of the model.
 * 
 * This class fires the following events:
 * 
 * Event.CHANGE fires when an undoable edit is dispatched. The <code>edit</code>
 * property contains the UndoableEdit. The <code>changes</code> property
 * contains the list of undoable changes inside the undoable edit. The changes
 * property is deprecated, please use edit.getChanges() instead.
 * 
 * Event.EXECUTE fires between begin- and endUpdate and after an atomic
 * change was executed in the model. The <code>change</code> property contains
 * the atomic change that was executed.
 * 
 * Event.BEGIN_UPDATE fires after the updateLevel was incremented in
 * beginUpdate. This event contains no properties.
 * 
 * Event.END_UPDATE fires after the updateLevel was decreased in endUpdate
 * but before any notification or change dispatching. The <code>edit</code>
 * property contains the current UndoableEdit.
 * 
 * Event.BEFORE_UNDO fires before the change is dispatched after the update
 * level has reached 0 in endUpdate. The <code>edit</code> property contains
 * the current UndoableEdit.
 * 
 * Event.UNDO fires after the change was dispatched in endUpdate. The
 * <code>edit</code> property contains the current UndoableEdit.
 */
class GraphModel extends EventSource implements IGraphModel,
		Serializable
{

	/**
	 * Holds the root cell, which in turn contains the cells that represent the
	 * layers of the diagram as child cells. That is, the actual element of the
	 * diagram are supposed to live in the third generation of cells and below.
	 */
	ICell _root;

	/**
	 * Maps from Ids to cells.
	 */
	Map<String, Object> _cells;

	/**
	 * Specifies if edges should automatically be moved into the nearest common
	 * ancestor of their terminals. Default is true.
	 */
	bool _maintainEdgeParent = true;

	/**
	 * Specifies if the model should automatically create Ids for new cells.
	 * Default is true.
	 */
	bool _createIds = true;

	/**
	 * Specifies the next Id to be created. Initial value is 0.
	 */
	int _nextId = 0;

	/**
	 * Holds the changes for the current transaction. If the transaction is
	 * closed then a new object is created for this variable using
	 * createUndoableEdit.
	 */
	transient UndoableEdit _currentEdit;

	/**
	 * Counter for the depth of nested transactions. Each call to beginUpdate
	 * increments this counter and each call to endUpdate decrements it. When
	 * the counter reaches 0, the transaction is closed and the respective
	 * events are fired. Initial value is 0.
	 */
	transient int _updateLevel = 0;

	/**
	 * 
	 */
	transient bool _endingUpdate = false;

	/**
	 * Constructs a new empty graph model.
	 */
	GraphModel()
	{
		this(null);
	}

	/**
	 * Constructs a new graph model. If no root is specified
	 * then a new root Cell with a default layer is created.
	 * 
	 * @param root Cell that represents the root cell.
	 */
	GraphModel(Object root)
	{
		_currentEdit = _createUndoableEdit();

		if (root != null)
		{
			setRoot(root);
		}
		else
		{
			clear();
		}
	}

	/**
	 * Sets a new root using createRoot.
	 */
	void clear()
	{
		setRoot(createRoot());
	}

	/**
	 * 
	 */
	int getUpdateLevel()
	{
		return _updateLevel;
	}

	/**
	 * Creates a new root cell with a default layer (child 0).
	 */
	Object createRoot()
	{
		Cell root = new Cell();
		root.insert(new Cell());

		return root;
	}

	/**
	 * Returns the internal lookup table that is used to map from Ids to cells.
	 */
	Map<String, Object> getCells()
	{
		return _cells;
	}

	/**
	 * Returns the cell for the specified Id or null if no cell can be
	 * found for the given Id.
	 * 
	 * @param id A string representing the Id of the cell.
	 * @return Returns the cell for the given Id.
	 */
	Object getCell(String id)
	{
		Object result = null;

		if (_cells != null)
		{
			result = _cells.get(id);
		}
		return result;
	}

	/**
	 * Returns true if the model automatically update parents of edges so that
	 * the edge is contained in the nearest-common-ancestor of its terminals.
	 * 
	 * @return Returns true if the model maintains edge parents.
	 */
	bool isMaintainEdgeParent()
	{
		return _maintainEdgeParent;
	}

	/**
	 * Specifies if the model automatically updates parents of edges so that
	 * the edge is contained in the nearest-common-ancestor of its terminals.
	 * 
	 * @param maintainEdgeParent Boolean indicating if the model should
	 * maintain edge parents.
	 */
	void setMaintainEdgeParent(bool maintainEdgeParent)
	{
		this._maintainEdgeParent = maintainEdgeParent;
	}

	/**
	 * Returns true if the model automatically creates Ids and resolves Id
	 * collisions.
	 * 
	 * @return Returns true if the model creates Ids.
	 */
	bool isCreateIds()
	{
		return _createIds;
	}

	/**
	 * Specifies if the model automatically creates Ids for new cells and
	 * resolves Id collisions.
	 * 
	 * @param value Boolean indicating if the model should created Ids.
	 */
	void setCreateIds(bool value)
	{
		_createIds = value;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getRoot()
	 */
	Object getRoot()
	{
		return _root;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setRoot(Object)
	 */
	Object setRoot(Object root)
	{
		execute(new RootChange(this, root));

		return root;
	}

	/**
	 * Inner callback to change the root of the model and update the internal
	 * datastructures, such as cells and nextId. Returns the previous root.
	 */
	Object _rootChanged(Object root)
	{
		Object oldRoot = this._root;
		this._root = (ICell) root;

		// Resets counters and datastructures
		_nextId = 0;
		_cells = null;
		_cellAdded(root);

		return oldRoot;
	}

	/**
	 * Creates a new undoable edit.
	 */
	UndoableEdit _createUndoableEdit()
	{
		return new UndoableEdit(this)
		{
			public void dispatch()
			{
				// LATER: Remove changes property (deprecated)
				((GraphModel) _source).fireEvent(new EventObj(
						Event.CHANGE, "edit", this, "changes", _changes));
			}
		};
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#cloneCells(Object[], boolean)
	 */
	Object[] cloneCells(Object[] cells, bool includeChildren)
	{
		Map<Object, Object> mapping = new Hashtable<Object, Object>();
		Object[] clones = new Object[cells.length];

		for (int i = 0; i < cells.length; i++)
		{
			try
			{
				clones[i] = _cloneCell(cells[i], mapping, includeChildren);
			}
			catch (CloneNotSupportedException e)
			{
				// ignore
			}
		}

		for (int i = 0; i < cells.length; i++)
		{
			_restoreClone(clones[i], cells[i], mapping);
		}

		return clones;
	}

	/**
	 * Inner helper method for cloning cells recursively.
	 */
	Object _cloneCell(Object cell, Map<Object, Object> mapping,
			bool includeChildren) throws CloneNotSupportedException
	{
		if (cell instanceof ICell)
		{
			ICell mxc = (ICell) ((ICell) cell).clone();
			mapping.put(cell, mxc);

			if (includeChildren)
			{
				int childCount = getChildCount(cell);

				for (int i = 0; i < childCount; i++)
				{
					Object clone = _cloneCell(getChildAt(cell, i), mapping, true);
					mxc.insert((ICell) clone);
				}
			}

			return mxc;
		}

		return null;
	}

	/**
	 * Inner helper method for restoring the connections in
	 * a network of cloned cells.
	 */
	void _restoreClone(Object clone, Object cell,
			Map<Object, Object> mapping)
	{
		if (clone instanceof ICell)
		{
			ICell mxc = (ICell) clone;
			Object source = getTerminal(cell, true);

			if (source instanceof ICell)
			{
				ICell tmp = (ICell) mapping.get(source);

				if (tmp != null)
				{
					tmp.insertEdge(mxc, true);
				}
			}

			Object target = getTerminal(cell, false);

			if (target instanceof ICell)
			{
				ICell tmp = (ICell) mapping.get(target);

				if (tmp != null)
				{
					tmp.insertEdge(mxc, false);
				}
			}
		}

		int childCount = getChildCount(clone);

		for (int i = 0; i < childCount; i++)
		{
			_restoreClone(getChildAt(clone, i), getChildAt(cell, i), mapping);
		}
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isAncestor(Object, Object)
	 */
	bool isAncestor(Object parent, Object child)
	{
		while (child != null && child != parent)
		{
			child = getParent(child);
		}

		return child == parent;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#contains(Object)
	 */
	bool contains(Object cell)
	{
		return isAncestor(getRoot(), cell);
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getParent(Object)
	 */
	Object getParent(Object child)
	{
		return (child instanceof ICell) ? ((ICell) child).getParent()
				: null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#add(Object, Object, int)
	 */
	Object add(Object parent, Object child, int index)
	{
		if (child != parent && parent != null && child != null)
		{
			bool parentChanged = parent != getParent(child);
			execute(new ChildChange(this, parent, child, index));

			// Maintains the edges parents by moving the edges
			// into the nearest common ancestor of its
			// terminals
			if (_maintainEdgeParent && parentChanged)
			{
				updateEdgeParents(child);
			}
		}

		return child;
	}

	/**
	 * Invoked after a cell has been added to a parent. This recursively
	 * creates an Id for the new cell and/or resolves Id collisions.
	 * 
	 * @param cell Cell that has been added.
	 */
	void _cellAdded(Object cell)
	{
		if (cell instanceof ICell)
		{
			ICell mxc = (ICell) cell;

			if (mxc.getId() == null && isCreateIds())
			{
				mxc.setId(createId(cell));
			}

			if (mxc.getId() != null)
			{
				Object collision = getCell(mxc.getId());

				if (collision != cell)
				{
					while (collision != null)
					{
						mxc.setId(createId(cell));
						collision = getCell(mxc.getId());
					}

					if (_cells == null)
					{
						_cells = new Hashtable<String, Object>();
					}

					_cells.put(mxc.getId(), cell);
				}
			}

			// Makes sure IDs of deleted cells are not reused
			try
			{
				int id = Integer.parseInt(mxc.getId());
				_nextId = Math.max(_nextId, id + 1);
			}
			catch (NumberFormatException e)
			{
				// ignore
			}

			int childCount = mxc.getChildCount();

			for (int i = 0; i < childCount; i++)
			{
				_cellAdded(mxc.getChildAt(i));
			}
		}
	}

	/**
	 * Creates a new Id for the given cell and increments the global counter
	 * for creating new Ids.
	 * 
	 * @param cell Cell for which a new Id should be created.
	 * @return Returns a new Id for the given cell.
	 */
	String createId(Object cell)
	{
		String id = String.valueOf(_nextId);
		_nextId++;

		return id;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#remove(Object)
	 */
	Object remove(Object cell)
	{
		if (cell == _root)
		{
			setRoot(null);
		}
		else if (getParent(cell) != null)
		{
			execute(new ChildChange(this, null, cell));
		}

		return cell;
	}

	/**
	 * Invoked after a cell has been removed from the model. This recursively
	 * removes the cell from its terminals and removes the mapping from the Id
	 * to the cell.
	 * 
	 * @param cell Cell that has been removed.
	 */
	void _cellRemoved(Object cell)
	{
		if (cell instanceof ICell)
		{
			ICell mxc = (ICell) cell;
			int childCount = mxc.getChildCount();

			for (int i = 0; i < childCount; i++)
			{
				_cellRemoved(mxc.getChildAt(i));
			}

			if (_cells != null && mxc.getId() != null)
			{
				_cells.remove(mxc.getId());
			}
		}
	}

	/**
	 * Inner callback to update the parent of a cell using Cell.insert
	 * on the parent and return the previous parent.
	 */
	Object _parentForCellChanged(Object cell, Object parent, int index)
	{
		ICell child = (ICell) cell;
		ICell previous = (ICell) getParent(cell);

		if (parent != null)
		{
			if (parent != previous || previous.getIndex(child) != index)
			{
				((ICell) parent).insert(child, index);
			}
		}
		else if (previous != null)
		{
			int oldIndex = previous.getIndex(child);
			previous.remove(oldIndex);
		}

		// Checks if the previous parent was already in the
		// model and avoids calling cellAdded if it was.
		if (!contains(previous) && parent != null)
		{
			_cellAdded(cell);
		}
		else if (parent == null)
		{
			_cellRemoved(cell);
		}

		return previous;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getChildCount(Object)
	 */
	int getChildCount(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).getChildCount() : 0;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getChildAt(Object, int)
	 */
	Object getChildAt(Object parent, int index)
	{
		return (parent instanceof ICell) ? ((ICell) parent)
				.getChildAt(index) : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getTerminal(Object, boolean)
	 */
	Object getTerminal(Object edge, bool isSource)
	{
		return (edge instanceof ICell) ? ((ICell) edge)
				.getTerminal(isSource) : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setTerminal(Object, Object, boolean)
	 */
	Object setTerminal(Object edge, Object terminal, bool isSource)
	{
		bool terminalChanged = terminal != getTerminal(edge, isSource);
		execute(new TerminalChange(this, edge, terminal, isSource));

		if (_maintainEdgeParent && terminalChanged)
		{
			updateEdgeParent(edge, getRoot());
		}

		return terminal;
	}

	/**
	 * Inner helper function to update the terminal of the edge using
	 * Cell.insertEdge and return the previous terminal.
	 */
	Object _terminalForCellChanged(Object edge, Object terminal,
			bool isSource)
	{
		ICell previous = (ICell) getTerminal(edge, isSource);

		if (terminal != null)
		{
			((ICell) terminal).insertEdge((ICell) edge, isSource);
		}
		else if (previous != null)
		{
			previous.removeEdge((ICell) edge, isSource);
		}

		return previous;
	}

	/**
	 * Updates the parents of the edges connected to the given cell and all its
	 * descendants so that each edge is contained in the nearest common
	 * ancestor.
	 * 
	 * @param cell Cell whose edges should be checked and updated.
	 */
	void updateEdgeParents(Object cell)
	{
		updateEdgeParents(cell, getRoot());
	}

	/**
	 * Updates the parents of the edges connected to the given cell and all its
	 * descendants so that the edge is contained in the nearest-common-ancestor.
	 * 
	 * @param cell Cell whose edges should be checked and updated.
	 * @param root Root of the cell hierarchy that contains all cells.
	 */
	void updateEdgeParents(Object cell, Object root)
	{
		// Updates edges on children first
		int childCount = getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = getChildAt(cell, i);
			updateEdgeParents(child, root);
		}

		// Updates the parents of all connected edges
		int edgeCount = getEdgeCount(cell);
		List<Object> edges = new ArrayList<Object>(edgeCount);

		for (int i = 0; i < edgeCount; i++)
		{
			edges.add(getEdgeAt(cell, i));
		}

		Iterator<Object> it = edges.iterator();

		while (it.hasNext())
		{
			Object edge = it.next();

			// Updates edge parent if edge and child have
			// a common root node (does not need to be the
			// model root node)
			if (isAncestor(root, edge))
			{
				updateEdgeParent(edge, root);
			}
		}
	}

	/**
	 * Inner helper method to update the parent of the specified edge to the
	 * nearest-common-ancestor of its two terminals.
	 *
	 * @param edge Specifies the edge to be updated.
	 * @param root Current root of the model.
	 */
	void updateEdgeParent(Object edge, Object root)
	{
		Object source = getTerminal(edge, true);
		Object target = getTerminal(edge, false);
		Object cell = null;
		
		// Uses the first non-relative descendants of the source terminal
		while (source != null && !isEdge(source) &&
			getGeometry(source) != null && getGeometry(source).isRelative())
		{
			source = getParent(source);
		}
		
		// Uses the first non-relative descendants of the target terminal
		while (target != null && !isEdge(target) &&
			getGeometry(target) != null && getGeometry(target).isRelative())
		{
			target = getParent(target);
		}
		
		if (isAncestor(root, source) && isAncestor(root, target))
		{
			if (source == target)
			{
				cell = getParent(source);
			}
			else
			{
				cell = getNearestCommonAncestor(source, target);
			}

			// Keeps the edge in the same layer
			if (cell != null
					&& (getParent(cell) != root || isAncestor(cell, edge))
					&& getParent(edge) != cell)
			{
				Geometry geo = getGeometry(edge);

				if (geo != null)
				{
					Point2d origin1 = getOrigin(getParent(edge));
					Point2d origin2 = getOrigin(cell);

					double dx = origin2.getX() - origin1.getX();
					double dy = origin2.getY() - origin1.getY();

					geo = (Geometry) geo.clone();
					geo.translate(-dx, -dy);
					setGeometry(edge, geo);
				}

				add(cell, edge, getChildCount(cell));
			}
		}
	}

	/**
	 * Returns the absolute, accumulated origin for the children inside the
	 * given parent. 
	 */
	Point2d getOrigin(Object cell)
	{
		Point2d result = null;

		if (cell != null)
		{
			result = getOrigin(getParent(cell));

			if (!isEdge(cell))
			{
				Geometry geo = getGeometry(cell);

				if (geo != null)
				{
					result.setX(result.getX() + geo.getX());
					result.setY(result.getY() + geo.getY());
				}
			}
		}
		else
		{
			result = new Point2d();
		}

		return result;
	}

	/**
	 * Returns the nearest common ancestor for the specified cells.
	 *
	 * @param cell1 Cell that specifies the first cell in the tree.
	 * @param cell2 Cell that specifies the second cell in the tree.
	 * @return Returns the nearest common ancestor of the given cells.
	 */
	Object getNearestCommonAncestor(Object cell1, Object cell2)
	{
		if (cell1 != null && cell2 != null)
		{
			// Creates the cell path for the second cell
			String path = CellPath.create((ICell) cell2);

			if (path != null && path.length() > 0)
			{
				// Bubbles through the ancestors of the first
				// cell to find the nearest common ancestor.
				Object cell = cell1;
				String current = CellPath.create((ICell) cell);

				while (cell != null)
				{
					Object parent = getParent(cell);

					// Checks if the cell path is equal to the beginning
					// of the given cell path
					if (path.indexOf(current + CellPath.PATH_SEPARATOR) == 0
							&& parent != null)
					{
						return cell;
					}

					current = CellPath.getParentPath(current);
					cell = parent;
				}
			}
		}

		return null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getEdgeCount(Object)
	 */
	int getEdgeCount(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).getEdgeCount() : 0;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getEdgeAt(Object, int)
	 */
	Object getEdgeAt(Object parent, int index)
	{
		return (parent instanceof ICell) ? ((ICell) parent)
				.getEdgeAt(index) : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isVertex(Object)
	 */
	bool isVertex(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).isVertex() : false;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isEdge(Object)
	 */
	bool isEdge(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).isEdge() : false;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isConnectable(Object)
	 */
	bool isConnectable(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).isConnectable()
				: true;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getValue(Object)
	 */
	Object getValue(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).getValue() : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setValue(Object, Object)
	 */
	Object setValue(Object cell, Object value)
	{
		execute(new ValueChange(this, cell, value));

		return value;
	}

	/**
	 * Inner callback to update the user object of the given Cell
	 * using Cell.setValue and return the previous value,
	 * that is, the return value of Cell.getValue.
	 */
	Object _valueForCellChanged(Object cell, Object value)
	{
		Object oldValue = ((ICell) cell).getValue();
		((ICell) cell).setValue(value);

		return oldValue;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getGeometry(Object)
	 */
	Geometry getGeometry(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).getGeometry()
				: null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setGeometry(Object, Geometry)
	 */
	Geometry setGeometry(Object cell, Geometry geometry)
	{
		if (geometry != getGeometry(cell))
		{
			execute(new GeometryChange(this, cell, geometry));
		}

		return geometry;
	}

	/**
	 * Inner callback to update the Geometry of the given Cell using
	 * Cell.setGeometry and return the previous Geometry.
	 */
	Geometry _geometryForCellChanged(Object cell, Geometry geometry)
	{
		Geometry previous = getGeometry(cell);
		((ICell) cell).setGeometry(geometry);

		return previous;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#getStyle(Object)
	 */
	String getStyle(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).getStyle() : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setStyle(Object, String)
	 */
	String setStyle(Object cell, String style)
	{
		if (style == null || !style.equals(getStyle(cell)))
		{
			execute(new StyleChange(this, cell, style));
		}

		return style;
	}

	/**
	 * Inner callback to update the style of the given Cell
	 * using Cell.setStyle and return the previous style.
	 */
	String _styleForCellChanged(Object cell, String style)
	{
		String previous = getStyle(cell);
		((ICell) cell).setStyle(style);

		return previous;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isCollapsed(Object)
	 */
	bool isCollapsed(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).isCollapsed()
				: false;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setCollapsed(Object, boolean)
	 */
	bool setCollapsed(Object cell, bool collapsed)
	{
		if (collapsed != isCollapsed(cell))
		{
			execute(new CollapseChange(this, cell, collapsed));
		}

		return collapsed;
	}

	/**
	 * Inner callback to update the collapsed state of the
	 * given Cell using Cell.setCollapsed and return
	 * the previous collapsed state.
	 */
	bool _collapsedStateForCellChanged(Object cell,
			bool collapsed)
	{
		bool previous = isCollapsed(cell);
		((ICell) cell).setCollapsed(collapsed);

		return previous;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#isVisible(Object)
	 */
	bool isVisible(Object cell)
	{
		return (cell instanceof ICell) ? ((ICell) cell).isVisible() : false;
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#setVisible(Object, boolean)
	 */
	bool setVisible(Object cell, bool visible)
	{
		if (visible != isVisible(cell))
		{
			execute(new VisibleChange(this, cell, visible));
		}

		return visible;
	}

	/**
	 * Sets the visible state of the given Cell using VisibleChange and
	 * adds the change to the current transaction.
	 */
	bool _visibleStateForCellChanged(Object cell, bool visible)
	{
		bool previous = isVisible(cell);
		((ICell) cell).setVisible(visible);

		return previous;
	}

	/**
	 * Executes the given atomic change and adds it to the current edit.
	 * 
	 * @param change Atomic change to be executed.
	 */
	void execute(AtomicGraphModelChange change)
	{
		change.execute();
		beginUpdate();
		_currentEdit.add(change);
		fireEvent(new EventObj(Event.EXECUTE, "change", change));
		endUpdate();
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#beginUpdate()
	 */
	void beginUpdate()
	{
		_updateLevel++;
		fireEvent(new EventObj(Event.BEGIN_UPDATE));
	}

	/* (non-Javadoc)
	 * @see graph.model.IGraphModel#endUpdate()
	 */
	void endUpdate()
	{
		_updateLevel--;

		if (!_endingUpdate)
		{
			_endingUpdate = _updateLevel == 0;
			fireEvent(new EventObj(Event.END_UPDATE, "edit", _currentEdit));

			try
			{
				if (_endingUpdate && !_currentEdit.isEmpty())
				{
					fireEvent(new EventObj(Event.BEFORE_UNDO, "edit",
							_currentEdit));
					UndoableEdit tmp = _currentEdit;
					_currentEdit = _createUndoableEdit();
					tmp.dispatch();
					fireEvent(new EventObj(Event.UNDO, "edit", tmp));
				}
			}
			finally
			{
				_endingUpdate = false;
			}
		}
	}

	/**
	 * Merges the children of the given cell into the given target cell inside
	 * this model. All cells are cloned unless there is a corresponding cell in
	 * the model with the same id, in which case the source cell is ignored and
	 * all edges are connected to the corresponding cell in this model. Edges
	 * are considered to have no identity and are always cloned unless the
	 * cloneAllEdges flag is set to false, in which case edges with the same
	 * id in the target model are reconnected to reflect the terminals of the
	 * source edges.
	 * 
	 * @param from
	 * @param to
	 * @param cloneAllEdges
	 */
	void mergeChildren(ICell from, ICell to, bool cloneAllEdges)
			throws CloneNotSupportedException
	{
		beginUpdate();
		try
		{
			Hashtable<Object, Object> mapping = new Hashtable<Object, Object>();
			_mergeChildrenImpl(from, to, cloneAllEdges, mapping);

			// Post-processes all edges in the mapping and
			// reconnects the terminals to the corresponding
			// cells in the target model
			Iterator<Object> it = mapping.keySet().iterator();

			while (it.hasNext())
			{
				Object edge = it.next();
				Object cell = mapping.get(edge);
				Object terminal = getTerminal(edge, true);

				if (terminal != null)
				{
					terminal = mapping.get(terminal);
					setTerminal(cell, terminal, true);
				}

				terminal = getTerminal(edge, false);

				if (terminal != null)
				{
					terminal = mapping.get(terminal);
					setTerminal(cell, terminal, false);
				}
			}
		}
		finally
		{
			endUpdate();
		}
	}

	/**
	 * Clones the children of the source cell into the given target cell in
	 * this model and adds an entry to the mapping that maps from the source
	 * cell to the target cell with the same id or the clone of the source cell
	 * that was inserted into this model.
	 */
	void _mergeChildrenImpl(ICell from, ICell to,
			bool cloneAllEdges, Hashtable<Object, Object> mapping)
			throws CloneNotSupportedException
	{
		beginUpdate();
		try
		{
			int childCount = from.getChildCount();

			for (int i = 0; i < childCount; i++)
			{
				ICell cell = from.getChildAt(i);
				String id = cell.getId();
				ICell target = (ICell) ((id != null && (!isEdge(cell) || !cloneAllEdges)) ? getCell(id)
						: null);

				// Clones and adds the child if no cell exists for the id
				if (target == null)
				{
					Cell clone = (Cell) cell.clone();
					clone.setId(id);

					// Do *NOT* use model.add as this will move the edge away
					// from the parent in updateEdgeParent if maintainEdgeParent
					// is enabled in the target model
					target = to.insert(clone);
					_cellAdded(target);
				}

				// Stores the mapping for later reconnecting edges
				mapping.put(cell, target);

				// Recurses
				_mergeChildrenImpl(cell, target, cloneAllEdges, mapping);
			}
		}
		finally
		{
			endUpdate();
		}
	}

	/**
	 * Initializes the currentEdit field if the model is deserialized.
	 */
	private void _readObject(ObjectInputStream ois) throws IOException,
			ClassNotFoundException
	{
		ois.defaultReadObject();
		_currentEdit = _createUndoableEdit();
	}

	/**
	 * Returns the number of incoming or outgoing edges.
	 * 
	 * @param model Graph model that contains the connection data.
	 * @param cell Cell whose edges should be counted.
	 * @param outgoing Boolean that specifies if the number of outgoing or
	 * incoming edges should be returned.
	 * @return Returns the number of incoming or outgoing edges.
	 */
	static int getDirectedEdgeCount(IGraphModel model, Object cell,
			bool outgoing)
	{
		return getDirectedEdgeCount(model, cell, outgoing, null);
	}

	/**
	 * Returns the number of incoming or outgoing edges, ignoring the given
	 * edge.
	 *
	 * @param model Graph model that contains the connection data.
	 * @param cell Cell whose edges should be counted.
	 * @param outgoing Boolean that specifies if the number of outgoing or
	 * incoming edges should be returned.
	 * @param ignoredEdge Object that represents an edge to be ignored.
	 * @return Returns the number of incoming or outgoing edges.
	 */
	static int getDirectedEdgeCount(IGraphModel model, Object cell,
			bool outgoing, Object ignoredEdge)
	{
		int count = 0;
		int edgeCount = model.getEdgeCount(cell);

		for (int i = 0; i < edgeCount; i++)
		{
			Object edge = model.getEdgeAt(cell, i);

			if (edge != ignoredEdge
					&& model.getTerminal(edge, outgoing) == cell)
			{
				count++;
			}
		}

		return count;
	}

	/**
	 * Returns all edges connected to this cell including loops.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @return Returns the array of connected edges for the given cell.
	 */
	static Object[] getEdges(IGraphModel model, Object cell)
	{
		return getEdges(model, cell, true, true, true);
	}

	/**
	 * Returns all edges connected to this cell without loops.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @return Returns the connected edges for the given cell.
	 */
	static Object[] getConnections(IGraphModel model, Object cell)
	{
		return getEdges(model, cell, true, true, false);
	}

	/**
	 * Returns the incoming edges of the given cell without loops.
	 * 
	 * @param model Graphmodel that contains the edges.
	 * @param cell Cell whose incoming edges should be returned.
	 * @return Returns the incoming edges for the given cell.
	 */
	static Object[] getIncomingEdges(IGraphModel model, Object cell)
	{
		return getEdges(model, cell, true, false, false);
	}

	/**
	 * Returns the outgoing edges of the given cell without loops.
	 * 
	 * @param model Graphmodel that contains the edges.
	 * @param cell Cell whose outgoing edges should be returned.
	 * @return Returns the outgoing edges for the given cell.
	 */
	static Object[] getOutgoingEdges(IGraphModel model, Object cell)
	{
		return getEdges(model, cell, false, true, false);
	}

	/**
	 * Returns all distinct edges connected to this cell.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @param incoming Specifies if incoming edges should be returned.
	 * @param outgoing Specifies if outgoing edges should be returned.
	 * @param includeLoops Specifies if loops should be returned.
	 * @return Returns the array of connected edges for the given cell.
	 */
	static Object[] getEdges(IGraphModel model, Object cell,
			bool incoming, bool outgoing, bool includeLoops)
	{
		int edgeCount = model.getEdgeCount(cell);
		List<Object> result = new ArrayList<Object>(edgeCount);

		for (int i = 0; i < edgeCount; i++)
		{
			Object edge = model.getEdgeAt(cell, i);
			Object source = model.getTerminal(edge, true);
			Object target = model.getTerminal(edge, false);

			if ((includeLoops && source == target)
					|| ((source != target) && ((incoming && target == cell) || (outgoing && source == cell))))
			{
				result.add(edge);
			}
		}

		return result.toArray();
	}

	/**
	 * Returns all edges from the given source to the given target.
	 * 
	 * @param model The graph model that contains the graph.
	 * @param source Object that defines the source cell.
	 * @param target Object that defines the target cell.
	 * @return Returns all edges from source to target.
	 */
	static Object[] getEdgesBetween(IGraphModel model, Object source,
			Object target)
	{
		return getEdgesBetween(model, source, target, false);
	}

	/**
	 * Returns all edges between the given source and target pair. If directed
	 * is true, then only edges from the source to the target are returned,
	 * otherwise, all edges between the two cells are returned.
	 * 
	 * @param model The graph model that contains the graph.
	 * @param source Object that defines the source cell.
	 * @param target Object that defines the target cell.
	 * @param directed Boolean that specifies if the direction of the edge
	 * should be taken into account.
	 * @return Returns all edges between the given source and target.
	 */
	static Object[] getEdgesBetween(IGraphModel model, Object source,
			Object target, bool directed)
	{
		int tmp1 = model.getEdgeCount(source);
		int tmp2 = model.getEdgeCount(target);

		// Assumes the source has less connected edges
		Object terminal = source;
		int edgeCount = tmp1;

		// Uses the smaller array of connected edges
		// for searching the edge
		if (tmp2 < tmp1)
		{
			edgeCount = tmp2;
			terminal = target;
		}

		List<Object> result = new ArrayList<Object>(edgeCount);

		// Checks if the edge is connected to the correct
		// cell and returns the first match
		for (int i = 0; i < edgeCount; i++)
		{
			Object edge = model.getEdgeAt(terminal, i);
			Object src = model.getTerminal(edge, true);
			Object trg = model.getTerminal(edge, false);
			bool directedMatch = (src == source) && (trg == target);
			bool oppositeMatch = (trg == source) && (src == target);

			if (directedMatch || (!directed && oppositeMatch))
			{
				result.add(edge);
			}
		}

		return result.toArray();
	}

	/**
	 * Returns all opposite cells of terminal for the given edges.
	 * 
	 * @param model Model that contains the connection information.
	 * @param edges Array of edges to be examined.
	 * @param terminal Cell that specifies the known end of the edges.
	 * @return Returns the opposite cells of the given terminal.
	 */
	static Object[] getOpposites(IGraphModel model, Object[] edges,
			Object terminal)
	{
		return getOpposites(model, edges, terminal, true, true);
	}

	/**
	 * Returns all opposite vertices wrt terminal for the given edges, only
	 * returning sources and/or targets as specified. The result is returned as
	 * an array of mxCells.
	 * 
	 * @param model Model that contains the connection information.
	 * @param edges Array of edges to be examined.
	 * @param terminal Cell that specifies the known end of the edges.
	 * @param sources Boolean that specifies if source terminals should
	 * be contained in the result. Default is true.
	 * @param targets Boolean that specifies if target terminals should
	 * be contained in the result. Default is true.
	 * @return Returns the array of opposite terminals for the given edges.
	 */
	static Object[] getOpposites(IGraphModel model, Object[] edges,
			Object terminal, bool sources, bool targets)
	{
		List<Object> terminals = new ArrayList<Object>();

		if (edges != null)
		{
			for (int i = 0; i < edges.length; i++)
			{
				Object source = model.getTerminal(edges[i], true);
				Object target = model.getTerminal(edges[i], false);

				// Checks if the terminal is the source of
				// the edge and if the target should be
				// stored in the result
				if (targets && source == terminal && target != null
						&& target != terminal)
				{
					terminals.add(target);
				}

				// Checks if the terminal is the taget of
				// the edge and if the source should be
				// stored in the result
				else if (sources && target == terminal && source != null
						&& source != terminal)
				{
					terminals.add(source);
				}
			}
		}

		return terminals.toArray();
	}

	/**
	 * Sets the source and target of the given edge in a single atomic change.
	 * 
	 * @param edge Cell that specifies the edge.
	 * @param source Cell that specifies the new source terminal.
	 * @param target Cell that specifies the new target terminal.
	 */
	static void setTerminals(IGraphModel model, Object edge,
			Object source, Object target)
	{
		model.beginUpdate();
		try
		{
			model.setTerminal(edge, source, true);
			model.setTerminal(edge, target, false);
		}
		finally
		{
			model.endUpdate();
		}
	}

	/**
	 * Returns all children of the given cell regardless of their type.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices or edges should be returned.
	 * @return Returns the child vertices and/or edges of the given parent.
	 */
	static Object[] getChildren(IGraphModel model, Object parent)
	{
		return getChildCells(model, parent, false, false);
	}

	/**
	 * Returns the child vertices of the given parent.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices should be returned.
	 * @return Returns the child vertices of the given parent.
	 */
	static Object[] getChildVertices(IGraphModel model, Object parent)
	{
		return getChildCells(model, parent, true, false);
	}

	/**
	 * Returns the child edges of the given parent.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child edges should be returned.
	 * @return Returns the child edges of the given parent.
	 */
	static Object[] getChildEdges(IGraphModel model, Object parent)
	{
		return getChildCells(model, parent, false, true);
	}

	/**
	 * Returns the children of the given cell that are vertices and/or edges
	 * depending on the arguments. If both arguments are false then all
	 * children are returned regardless of their type.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices or edges should be returned.
	 * @param vertices Boolean indicating if child vertices should be returned.
	 * @param edges Boolean indicating if child edges should be returned.
	 * @return Returns the child vertices and/or edges of the given parent.
	 */
	static Object[] getChildCells(IGraphModel model, Object parent,
			bool vertices, bool edges)
	{
		int childCount = model.getChildCount(parent);
		List<Object> result = new ArrayList<Object>(childCount);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(parent, i);

			if ((!edges && !vertices) || (edges && model.isEdge(child))
					|| (vertices && model.isVertex(child)))
			{
				result.add(child);
			}
		}

		return result.toArray();
	}

	/**
	 * 
	 */
	static Object[] getParents(IGraphModel model, Object[] cells)
	{
		HashSet<Object> parents = new HashSet<Object>();

		if (cells != null)
		{
			for (int i = 0; i < cells.length; i++)
			{
				Object parent = model.getParent(cells[i]);

				if (parent != null)
				{
					parents.add(parent);
				}
			}
		}

		return parents.toArray();
	}

	/**
	 * 
	 */
	static Object[] filterCells(Object[] cells, Filter filter)
	{
		ArrayList<Object> result = null;

		if (cells != null)
		{
			result = new ArrayList<Object>(cells.length);

			for (int i = 0; i < cells.length; i++)
			{
				if (filter.filter(cells[i]))
				{
					result.add(cells[i]);
				}
			}
		}

		return (result != null) ? result.toArray() : null;
	}

	/**
	 * Returns a all descendants of the given cell and the cell itself
	 * as a collection.
	 */
	static Collection<Object> getDescendants(IGraphModel model,
			Object parent)
	{
		return filterDescendants(model, null, parent);
	}

	/**
	 * Creates a collection of cells using the visitor pattern.
	 */
	static Collection<Object> filterDescendants(IGraphModel model,
			Filter filter)
	{
		return filterDescendants(model, filter, model.getRoot());
	}

	/**
	 * Creates a collection of cells using the visitor pattern.
	 */
	static Collection<Object> filterDescendants(IGraphModel model,
			Filter filter, Object parent)
	{
		List<Object> result = new ArrayList<Object>();

		if (filter == null || filter.filter(parent))
		{
			result.add(parent);
		}

		int childCount = model.getChildCount(parent);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(parent, i);
			result.addAll(filterDescendants(model, filter, child));
		}

		return result;
	}

	/**
	 * Function: getTopmostCells
	 * 
	 * Returns the topmost cells of the hierarchy in an array that contains no
	 * desceandants for each <Cell> that it contains. Duplicates should be
	 * removed in the cells array to improve performance.
	 * 
	 * Parameters:
	 * 
	 * cells - Array of <mxCells> whose topmost ancestors should be returned.
	 */
	static Object[] getTopmostCells(IGraphModel model, Object[] cells)
	{
		Set<Object> hash = new HashSet<Object>();
		hash.addAll(Arrays.asList(cells));
		List<Object> result = new ArrayList<Object>(cells.length);

		for (int i = 0; i < cells.length; i++)
		{
			Object cell = cells[i];
			bool topmost = true;
			Object parent = model.getParent(cell);

			while (parent != null)
			{
				if (hash.contains(parent))
				{
					topmost = false;
					break;
				}

				parent = model.getParent(parent);
			}

			if (topmost)
			{
				result.add(cell);
			}
		}

		return result.toArray();
	}

	//
	// Visitor patterns
	//

	

	//
	// Atomic changes
	//


}
