/*
 * $Id: GraphSelectionModel.java,v 1.1 2012/11/15 13:26:46 gaudenz Exp $
 * Copyright (c) 2001-2005, Gaudenz Alder
 * 
 * All rights reserved.
 * 
 * See LICENSE file for license details. If you are unable to locate
 * this file please contact info (at) jgraph (dot) com.
 */
part of graph.view;

//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.UndoableEdit;
//import graph.util.UndoableEdit.UndoableChange;

//import java.util.ArrayList;
//import java.util.Collection;
//import java.util.Iterator;
//import java.util.LinkedHashSet;
//import java.util.List;
//import java.util.Set;

/**
 * Implements the selection model for a graph.
 * 
 * This class fires the following events:
 * 
 * Event.UNDO fires after the selection was changed in changeSelection. The
 * <code>edit</code> property contains the UndoableEdit which contains the
 * SelectionChange.
 * 
 * Event.CHANGE fires after the selection changes by executing an
 * SelectionChange. The <code>added</code> and <code>removed</code>
 * properties contain Collections of cells that have been added to or removed
 * from the selection, respectively.
 *  
 * To add a change listener to the graph selection model:
 * 
 * <code>
 * addListener(
 *   Event.CHANGE, new IEventListener()
 *   {
 *     public void invoke(Object sender, EventObj evt)
 *     {
 *       GraphSelectionModel model = (mxSelectionModel) sender;
 *       Collection added = (Collection) evt.getProperty("added");
 *       Collection removed = (Collection) evt.getProperty("removed");
 *       selectionChanged(model, added, removed);
 *     }
 *   });
 * </code>
 */
public class GraphSelectionModel extends EventSource
{

	/**
	 * Reference to the enclosing graph.
	 */
	protected Graph _graph;

	/**
	 * Specifies if only one selected item at a time is allowed.
	 * Default is false.
	 */
	protected boolean _singleSelection = false;

	/**
	 * Holds the selection cells.
	 */
	protected Set<Object> _cells = new LinkedHashSet<Object>();

	/**
	 * Constructs a new selection model for the specified graph.
	 * 
	 * @param graph
	 */
	public GraphSelectionModel(Graph graph)
	{
		this._graph = graph;
	}

	/**
	 * @return the singleSelection
	 */
	public boolean isSingleSelection()
	{
		return _singleSelection;
	}

	/**
	 * @param singleSelection the singleSelection to set
	 */
	public void setSingleSelection(boolean singleSelection)
	{
		this._singleSelection = singleSelection;
	}

	/**
	 * Returns true if the given cell is selected.
	 * 
	 * @param cell
	 * @return Returns true if the given cell is selected.
	 */
	public boolean isSelected(Object cell)
	{
		return (cell == null) ? false : _cells.contains(cell);
	}

	/**
	 * Returns true if no cells are selected.
	 */
	public boolean isEmpty()
	{
		return _cells.isEmpty();
	}

	/**
	 * Returns the number of selected cells.
	 */
	public int size()
	{
		return _cells.size();
	}

	/**
	 * Clears the selection.
	 */
	public void clear()
	{
		_changeSelection(null, _cells);
	}

	/**
	 * Returns the first selected cell.
	 */
	public Object getCell()
	{
		return (_cells.isEmpty()) ? null : _cells.iterator().next();
	}

	/**
	 * Returns the selection cells.
	 */
	public Object[] getCells()
	{
		return _cells.toArray();
	}

	/**
	 * Clears the selection and adds the given cell to the selection.
	 */
	public void setCell(Object cell)
	{
		if (cell != null)
		{
			setCells(new Object[] { cell });
		}
		else
		{
			clear();
		}
	}

	/**
	 * Clears the selection and adds the given cells.
	 */
	public void setCells(Object[] cells)
	{
		if (cells != null)
		{
			if (_singleSelection)
			{
				cells = new Object[] { _getFirstSelectableCell(cells) };
			}

			List<Object> tmp = new ArrayList<Object>(cells.length);

			for (int i = 0; i < cells.length; i++)
			{
				if (_graph.isCellSelectable(cells[i]))
				{
					tmp.add(cells[i]);
				}
			}

			_changeSelection(tmp, this._cells);
		}
		else
		{
			clear();
		}
	}

	/**
	 * Returns the first selectable cell in the given array of cells.
	 * 
	 * @param cells Array of cells to return the first selectable cell for.
	 * @return Returns the first cell that may be selected.
	 */
	protected Object _getFirstSelectableCell(Object[] cells)
	{
		if (cells != null)
		{
			for (int i = 0; i < cells.length; i++)
			{
				if (_graph.isCellSelectable(cells[i]))
				{
					return cells[i];
				}
			}
		}

		return null;
	}

	/**
	 * Adds the given cell to the selection.
	 */
	public void addCell(Object cell)
	{
		if (cell != null)
		{
			addCells(new Object[] { cell });
		}
	}

	/**
	 * 
	 */
	public void addCells(Object[] cells)
	{
		if (cells != null)
		{
			Collection<Object> remove = null;

			if (_singleSelection)
			{
				remove = this._cells;
				cells = new Object[] { _getFirstSelectableCell(cells) };
			}

			List<Object> tmp = new ArrayList<Object>(cells.length);

			for (int i = 0; i < cells.length; i++)
			{
				if (!isSelected(cells[i]) && _graph.isCellSelectable(cells[i]))
				{
					tmp.add(cells[i]);
				}
			}

			_changeSelection(tmp, remove);
		}
	}

	/**
	 * Removes the given cell from the selection.
	 */
	public void removeCell(Object cell)
	{
		if (cell != null)
		{
			removeCells(new Object[] { cell });
		}
	}

	/**
	 * 
	 */
	public void removeCells(Object[] cells)
	{
		if (cells != null)
		{
			List<Object> tmp = new ArrayList<Object>(cells.length);

			for (int i = 0; i < cells.length; i++)
			{
				if (isSelected(cells[i]))
				{
					tmp.add(cells[i]);
				}
			}

			_changeSelection(null, tmp);
		}
	}

	/**
	 * 
	 */
	protected void _changeSelection(Collection<Object> added,
			Collection<Object> removed)
	{
		if ((added != null && !added.isEmpty())
				|| (removed != null && !removed.isEmpty()))
		{
			SelectionChange change = new SelectionChange(this, added,
					removed);
			change.execute();
			UndoableEdit edit = new UndoableEdit(this, false);
			edit.add(change);
			fireEvent(new EventObj(Event.UNDO, "edit", edit));
		}
	}

	/**
	 * 
	 */
	protected void _cellAdded(Object cell)
	{
		if (cell != null)
		{
			_cells.add(cell);
		}
	}

	/**
	 * 
	 */
	protected void _cellRemoved(Object cell)
	{
		if (cell != null)
		{
			_cells.remove(cell);
		}
	}

	/**
	 *
	 */
	public static class SelectionChange implements UndoableChange
	{

		/**
		 * 
		 */
		protected GraphSelectionModel model;

		/**
		 * 
		 */
		protected Collection<Object> added, removed;

		/**
		 * 
		 * @param model
		 * @param added
		 * @param removed
		 */
		public SelectionChange(GraphSelectionModel model,
				Collection<Object> added, Collection<Object> removed)
		{
			this.model = model;
			this.added = (added != null) ? new ArrayList<Object>(added) : null;
			this.removed = (removed != null) ? new ArrayList<Object>(removed)
					: null;
		}

		/**
		 * 
		 */
		public void execute()
		{
			if (removed != null)
			{
				Iterator<Object> it = removed.iterator();

				while (it.hasNext())
				{
					model._cellRemoved(it.next());
				}
			}

			if (added != null)
			{
				Iterator<Object> it = added.iterator();

				while (it.hasNext())
				{
					model._cellAdded(it.next());
				}
			}

			Collection<Object> tmp = added;
			added = removed;
			removed = tmp;
			model.fireEvent(new EventObj(Event.CHANGE, "added", added,
					"removed", removed));
		}

	}

}