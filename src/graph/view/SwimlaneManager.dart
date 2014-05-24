/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;

//import graph.model.Geometry;
//import graph.model.IGraphModel;
//import graph.util.Constants;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Rect;
//import graph.util.Utils;

//import java.util.Map;

/**
 * Manager for swimlanes and nested swimlanes that sets the size of newly added
 * swimlanes to that of their siblings, and propagates changes to the size of a
 * swimlane to its siblings, if siblings is true, and its ancestors, if
 * bubbling is true.
 */
public class SwimlaneManager extends EventSource
{

	/**
	 * Defines the type of the source or target terminal. The type is a string
	 * passed to Cell.is to check if the rule applies to a cell.
	 */
	protected Graph _graph;

	/**
	 * Optional string that specifies the value of the attribute to be passed
	 * to Cell.is to check if the rule applies to a cell.
	 */
	protected boolean _enabled;

	/**
	 * Optional string that specifies the attributename to be passed to
	 * Cell.is to check if the rule applies to a cell.
	 */
	protected boolean _horizontal;

	/**
	 * Specifies if newly added cells should be resized to match the size of their
	 * existing siblings. Default is true.
	 */
	protected boolean _addEnabled;

	/**
	 * Specifies if resizing of swimlanes should be handled. Default is true.
	 */
	protected boolean _resizeEnabled;

	/**
	 * 
	 */
	protected IEventListener _addHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled() && isAddEnabled())
			{
				_cellsAdded((Object[]) evt.getProperty("cells"));
			}
		}
	};

	/**
	 * 
	 */
	protected IEventListener _resizeHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled() && isResizeEnabled())
			{
				_cellsResized((Object[]) evt.getProperty("cells"));
			}
		}
	};

	/**
	 * 
	 */
	public SwimlaneManager(Graph graph)
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
	public boolean isHorizontal()
	{
		return _horizontal;
	}

	/**
	 * @param value the bubbling to set
	 */
	public void setHorizontal(boolean value)
	{
		_horizontal = value;
	}

	/**
	 * @return the addEnabled
	 */
	public boolean isAddEnabled()
	{
		return _addEnabled;
	}

	/**
	 * @param value the addEnabled to set
	 */
	public void setAddEnabled(boolean value)
	{
		_addEnabled = value;
	}

	/**
	 * @return the resizeEnabled
	 */
	public boolean isResizeEnabled()
	{
		return _resizeEnabled;
	}

	/**
	 * @param value the resizeEnabled to set
	 */
	public void setResizeEnabled(boolean value)
	{
		_resizeEnabled = value;
	}

	/**
	 * @return the graph
	 */
	public Graph getGraph()
	{
		return _graph;
	}

	/**
	 * @param graph the graph to set
	 */
	public void setGraph(Graph graph)
	{
		if (this._graph != null)
		{
			this._graph.removeListener(_addHandler);
			this._graph.removeListener(_resizeHandler);
		}

		this._graph = graph;

		if (this._graph != null)
		{
			this._graph.addListener(Event.ADD_CELLS, _addHandler);
			this._graph.addListener(Event.CELLS_RESIZED, _resizeHandler);
		}
	}

	/**
	 *  Returns true if the given swimlane should be ignored.
	 */
	protected boolean _isSwimlaneIgnored(Object swimlane)
	{
		return !getGraph().isSwimlane(swimlane);
	}

	/**
	 * Returns true if the given cell is horizontal. If the given cell is not a
	 * swimlane, then the <horizontal> value is returned.
	 */
	protected boolean _isCellHorizontal(Object cell)
	{
		if (_graph.isSwimlane(cell))
		{
			CellState state = _graph.getView().getState(cell);
			Map<String, Object> style = (state != null) ? state.getStyle()
					: _graph.getCellStyle(cell);

			return Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true);
		}

		return !isHorizontal();
	}

	/**
	 * Called if any cells have been added. Calls swimlaneAdded for all swimlanes
	 * where isSwimlaneIgnored returns false.
	 */
	protected void _cellsAdded(Object[] cells)
	{
		if (cells != null)
		{
			IGraphModel model = getGraph().getModel();

			model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					if (!_isSwimlaneIgnored(cells[i]))
					{
						_swimlaneAdded(cells[i]);
					}
				}
			}
			finally
			{
				model.endUpdate();
			}
		}
	}

	/**
	 * Called for each swimlane which has been added. This finds a reference
	 * sibling swimlane and applies its size to the newly added swimlane. If no
	 * sibling can be found then the parent swimlane is resized so that the
	 * new swimlane fits into the parent swimlane.
	 */
	protected void _swimlaneAdded(Object swimlane)
	{
		IGraphModel model = getGraph().getModel();
		Object parent = model.getParent(swimlane);
		int childCount = model.getChildCount(parent);
		Geometry geo = null;

		// Finds the first valid sibling swimlane as reference
		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(parent, i);

			if (child != swimlane && !this._isSwimlaneIgnored(child))
			{
				geo = model.getGeometry(child);

				if (geo != null)
				{
					break;
				}
			}
		}

		// Applies the size of the refernece to the newly added swimlane
		if (geo != null)
		{
			boolean parentHorizontal = (parent != null) ? _isCellHorizontal(parent) : _horizontal;
			_resizeSwimlane(swimlane, geo.getWidth(), geo.getHeight(), parentHorizontal);
		}
	}

	/**
	 * Called if any cells have been resizes. Calls swimlaneResized for all
	 * swimlanes where isSwimlaneIgnored returns false.
	 */
	protected void _cellsResized(Object[] cells)
	{
		if (cells != null)
		{
			IGraphModel model = this.getGraph().getModel();
			
			model.beginUpdate();
			try
			{
				// Finds the top-level swimlanes and adds offsets
				for (int i = 0; i < cells.length; i++)
				{
					if (!this._isSwimlaneIgnored(cells[i]))
					{
						Geometry geo = model.getGeometry(cells[i]);
						
						if (geo != null)
						{
							Rect size = new Rect(0, 0, geo.getWidth(), geo.getHeight());
							Object top = cells[i];
							Object current = top;
							
							while (current != null)
							{
								top = current;
								current = model.getParent(current);
								Rect tmp = (_graph.isSwimlane(current)) ?
										_graph.getStartSize(current) :
										new Rect();
								size.setWidth(size.getWidth() + tmp.getWidth());
								size.setHeight(size.getHeight() + tmp.getHeight());
							}
							
							boolean parentHorizontal = (current != null) ? _isCellHorizontal(current) : _horizontal;
							_resizeSwimlane(top, size.getWidth(), size.getHeight(), parentHorizontal);
						}
					}
				}
			}
			finally
			{
				model.endUpdate();
			}
		}
	}

	/**
	 * Sets the width or height of the given swimlane to the given value depending
	 * on <horizontal>. If <horizontal> is true, then the width is set, otherwise,
	 * the height is set.
	 */
	protected void _resizeSwimlane(Object swimlane, double w, double h, boolean parentHorizontal)
	{
		IGraphModel model = getGraph().getModel();

		model.beginUpdate();
		try
		{
			boolean horizontal = this._isCellHorizontal(swimlane);
			
			if (!this._isSwimlaneIgnored(swimlane))
			{
				Geometry geo = model.getGeometry(swimlane);

				if (geo != null)
				{

					if ((parentHorizontal && geo.getHeight() != h)
							|| (!parentHorizontal && geo.getWidth() != w))
					{
						geo = (Geometry) geo.clone();

						if (parentHorizontal)
						{
							geo.setHeight(h);
						}
						else
						{
							geo.setWidth(w);
						}

						model.setGeometry(swimlane, geo);
					}
				}
			}

			Rect tmp = (_graph.isSwimlane(swimlane)) ? _graph
					.getStartSize(swimlane) : new Rect();
			w -= tmp.getWidth();
			h -= tmp.getHeight();

			int childCount = model.getChildCount(swimlane);

			for (int i = 0; i < childCount; i++)
			{
				Object child = model.getChildAt(swimlane, i);
				_resizeSwimlane(child, w, h, horizontal);
			}
		}
		finally
		{
			model.endUpdate();
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