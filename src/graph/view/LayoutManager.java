package graph.view;

import graph.layout.IGraphLayout;
import graph.model.ChildChange;
import graph.model.GeometryChange;
import graph.model.GraphModel;
import graph.model.IGraphModel;
import graph.model.RootChange;
import graph.model.TerminalChange;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource;
import graph.util.UndoableEdit;
import graph.util.Utils;
import graph.util.UndoableEdit.UndoableChange;

import java.awt.Point;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Implements a layout manager that updates the layout for a given transaction.
 * The following example installs an automatic tree layout in a graph:
 * 
 * <code>
 * new LayoutManager(graph) {
 * 
 *   CompactTreeLayout layout = new CompactTreeLayout(graph);
 *   
 *   public IGraphLayout getLayout(Object parent)
 *   {
 *     if (graph.getModel().getChildCount(parent) > 0) {
 *       return layout;
 *     }
 *     return null;
 *   }
 * };
 * </code>
 * 
 * This class fires the following event:
 * 
 * Event.LAYOUT_CELLS fires between begin- and endUpdate after all cells have
 * been layouted in layoutCells. The <code>cells</code> property contains all
 * cells that have been passed to layoutCells.
 */
public class LayoutManager extends EventSource
{

	/**
	 * Defines the type of the source or target terminal. The type is a string
	 * passed to Cell.is to check if the rule applies to a cell.
	 */
	protected Graph _graph;

	/**
	 * Optional string that specifies the value of the attribute to be passed
	 * to Cell.is to check if the rule applies to a cell. Default is true.
	 */
	protected boolean _enabled = true;

	/**
	 * Optional string that specifies the attributename to be passed to
	 * Cell.is to check if the rule applies to a cell. Default is true.
	 */
	protected boolean _bubbling = true;

	/**
	 * 
	 */
	protected IEventListener _undoHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled())
			{
				_beforeUndo((UndoableEdit) evt.getProperty("edit"));
			}
		}
	};

	/**
	 * 
	 */
	protected IEventListener _moveHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled())
			{
				_cellsMoved((Object[]) evt.getProperty("cells"), (Point) evt
						.getProperty("location"));
			}
		}
	};

	/**
	 * 
	 */
	public LayoutManager(Graph graph)
	{
		setGraph(graph);
	}

	/**
	 * @return the enabled
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * @param value the enabled to set
	 */
	public void setEnabled(boolean value)
	{
		_enabled = value;
	}

	/**
	 * @return the bubbling
	 */
	public boolean isBubbling()
	{
		return _bubbling;
	}

	/**
	 * @param value the bubbling to set
	 */
	public void setBubbling(boolean value)
	{
		_bubbling = value;
	}

	/**
	 * @return the graph
	 */
	public Graph getGraph()
	{
		return _graph;
	}

	/**
	 * @param value the graph to set
	 */
	public void setGraph(Graph value)
	{
		if (_graph != null)
		{
			IGraphModel model = _graph.getModel();
			model.removeListener(_undoHandler);
			_graph.removeListener(_moveHandler);
		}

		_graph = value;

		if (_graph != null)
		{
			IGraphModel model = _graph.getModel();
			model.addListener(Event.BEFORE_UNDO, _undoHandler);
			_graph.addListener(Event.MOVE_CELLS, _moveHandler);
		}
	}

	/**
	 * 
	 */
	protected IGraphLayout _getLayout(Object parent)
	{
		return null;
	}

	/**
	 * 
	 */
	protected void _cellsMoved(Object[] cells, Point location)
	{
		if (cells != null && location != null)
		{
			IGraphModel model = getGraph().getModel();

			// Checks if a layout exists to take care of the moving
			for (int i = 0; i < cells.length; i++)
			{
				IGraphLayout layout = _getLayout(model.getParent(cells[i]));

				if (layout != null)
				{
					layout.moveCell(cells[i], location.x, location.y);
				}
			}
		}
	}

	/**
	 * 
	 */
	protected void _beforeUndo(UndoableEdit edit)
	{
		Collection<Object> cells = _getCellsForChanges(edit.getChanges());
		IGraphModel model = getGraph().getModel();

		if (isBubbling())
		{
			Object[] tmp = GraphModel.getParents(model, cells.toArray());

			while (tmp.length > 0)
			{
				cells.addAll(Arrays.asList(tmp));
				tmp = GraphModel.getParents(model, tmp);
			}
		}

		_layoutCells(Utils.sortCells(cells, false).toArray());
	}

	/**
	 * 
	 */
	protected Collection<Object> _getCellsForChanges(
			List<UndoableChange> changes)
	{
		Set<Object> result = new HashSet<Object>();
		Iterator<UndoableChange> it = changes.iterator();

		while (it.hasNext())
		{
			UndoableChange change = it.next();

			if (change instanceof RootChange)
			{
				return new HashSet<Object>();
			}
			else
			{
				result.addAll(_getCellsForChange(change));
			}
		}

		return result;
	}

	/**
	 * 
	 */
	protected Collection<Object> _getCellsForChange(UndoableChange change)
	{
		IGraphModel model = getGraph().getModel();
		Set<Object> result = new HashSet<Object>();

		if (change instanceof ChildChange)
		{
			ChildChange cc = (ChildChange) change;
			Object parent = model.getParent(cc.getChild());

			if (cc.getChild() != null)
			{
				result.add(cc.getChild());
			}

			if (parent != null)
			{
				result.add(parent);
			}

			if (cc.getPrevious() != null)
			{
				result.add(cc.getPrevious());
			}
		}
		else if (change instanceof TerminalChange
				|| change instanceof GeometryChange)
		{
			Object cell = (change instanceof TerminalChange) ? ((TerminalChange) change)
					.getCell()
					: ((GeometryChange) change).getCell();

			if (cell != null)
			{
				result.add(cell);
				Object parent = model.getParent(cell);

				if (parent != null)
				{
					result.add(parent);
				}
			}
		}

		return result;
	}

	/**
	 * 
	 */
	protected void _layoutCells(Object[] cells)
	{
		if (cells.length > 0)
		{
			// Invokes the layouts while removing duplicates
			IGraphModel model = getGraph().getModel();

			model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					if (cells[i] != model.getRoot())
					{
						_executeLayout(_getLayout(cells[i]), cells[i]);
					}
				}

				fireEvent(new EventObj(Event.LAYOUT_CELLS, "cells",
						cells));
			}
			finally
			{
				model.endUpdate();
			}
		}
	}

	/**
	 * 
	 */
	protected void _executeLayout(IGraphLayout layout, Object parent)
	{
		if (layout != null && parent != null)
		{
			layout.execute(parent);
		}
	}

	/**
	 * 
	 */
	public void destroy()
	{
		setGraph(null);
	}

}
