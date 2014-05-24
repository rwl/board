part of graph.view;

//import graph.model.Geometry;
//import graph.model.IGraphModel;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Point2d;

public class SpaceManager extends EventSource
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
	protected boolean _shiftRightwards;

	/**
	 * Optional string that specifies the attributename to be passed to
	 * Cell.is to check if the rule applies to a cell.
	 */
	protected boolean _shiftDownwards;

	/**
	 * Optional string that specifies the attributename to be passed to
	 * Cell.is to check if the rule applies to a cell.
	 */
	protected boolean _extendParents;

	/**
	 * 
	 */
	protected IEventListener _resizeHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled())
			{
				_cellsResized((Object[]) evt.getProperty("cells"));
			}
		}
	};

	/**
	 * 
	 */
	public SpaceManager(Graph graph)
	{
		setGraph(graph);
	}

	/**
	 * 
	 */
	public boolean isCellIgnored(Object cell)
	{
		return !getGraph().getModel().isVertex(cell);
	}

	/**
	 * 
	 */
	public boolean isCellShiftable(Object cell)
	{
		return getGraph().getModel().isVertex(cell)
				&& getGraph().isCellMovable(cell);
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
	 * @return the shiftRightwards
	 */
	public boolean isShiftRightwards()
	{
		return _shiftRightwards;
	}

	/**
	 * @param shiftRightwards the shiftRightwards to set
	 */
	public void setShiftRightwards(boolean shiftRightwards)
	{
		this._shiftRightwards = shiftRightwards;
	}

	/**
	 * @return the shiftDownwards
	 */
	public boolean isShiftDownwards()
	{
		return _shiftDownwards;
	}

	/**
	 * @param shiftDownwards the shiftDownwards to set
	 */
	public void setShiftDownwards(boolean shiftDownwards)
	{
		this._shiftDownwards = shiftDownwards;
	}

	/**
	 * @return the extendParents
	 */
	public boolean isExtendParents()
	{
		return _extendParents;
	}

	/**
	 * @param extendParents the extendParents to set
	 */
	public void setExtendParents(boolean extendParents)
	{
		this._extendParents = extendParents;
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
			this._graph.removeListener(_resizeHandler);
		}

		this._graph = graph;

		if (this._graph != null)
		{
			this._graph.addListener(Event.RESIZE_CELLS, _resizeHandler);
			this._graph.addListener(Event.FOLD_CELLS, _resizeHandler);
		}
	}

	/**
	 * 
	 */
	protected void _cellsResized(Object[] cells)
	{
		if (cells != null)
		{
			IGraphModel model = getGraph().getModel();

			model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					if (!isCellIgnored(cells[i]))
					{
						_cellResized(cells[i]);
						break;
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
	 * 
	 */
	protected void _cellResized(Object cell)
	{
		Graph graph = getGraph();
		GraphView view = graph.getView();
		IGraphModel model = graph.getModel();

		CellState state = view.getState(cell);
		CellState pstate = view.getState(model.getParent(cell));

		if (state != null && pstate != null)
		{
			Object[] cells = _getCellsToShift(state);
			Geometry geo = model.getGeometry(cell);

			if (cells != null && geo != null)
			{
				Point2d tr = view.getTranslate();
				double scale = view.getScale();

				double x0 = state.getX() - pstate.getOrigin().getX()
						- tr.getX() * scale;
				double y0 = state.getY() - pstate.getOrigin().getY()
						- tr.getY() * scale;
				double right = state.getX() + state.getWidth();
				double bottom = state.getY() + state.getHeight();

				double dx = state.getWidth() - geo.getWidth() * scale + x0
						- geo.getX() * scale;
				double dy = state.getHeight() - geo.getHeight() * scale + y0
						- geo.getY() * scale;

				double fx = 1 - geo.getWidth() * scale / state.getWidth();
				double fy = 1 - geo.getHeight() * scale / state.getHeight();

				model.beginUpdate();
				try
				{
					for (int i = 0; i < cells.length; i++)
					{
						if (cells[i] != cell && isCellShiftable(cells[i]))
						{
							_shiftCell(cells[i], dx, dy, x0, y0, right, bottom,
									fx, fy, isExtendParents()
											&& graph.isExtendParent(cells[i]));
						}
					}
				}
				finally
				{
					model.endUpdate();
				}
			}
		}
	}

	/**
	 * 
	 */
	protected void _shiftCell(Object cell, double dx, double dy, double x0,
			double y0, double right, double bottom, double fx, double fy,
			boolean extendParent)
	{
		Graph graph = getGraph();
		CellState state = graph.getView().getState(cell);

		if (state != null)
		{
			IGraphModel model = graph.getModel();
			Geometry geo = model.getGeometry(cell);

			if (geo != null)
			{
				model.beginUpdate();
				try
				{
					if (isShiftRightwards())
					{
						if (state.getX() >= right)
						{
							geo = (Geometry) geo.clone();
							geo.translate(-dx, 0);
						}
						else
						{
							double tmpDx = Math.max(0, state.getX() - x0);
							geo = (Geometry) geo.clone();
							geo.translate(-fx * tmpDx, 0);
						}
					}

					if (isShiftDownwards())
					{
						if (state.getY() >= bottom)
						{
							geo = (Geometry) geo.clone();
							geo.translate(0, -dy);
						}
						else
						{
							double tmpDy = Math.max(0, state.getY() - y0);
							geo = (Geometry) geo.clone();
							geo.translate(0, -fy * tmpDy);
						}

						if (geo != model.getGeometry(cell))
						{
							model.setGeometry(cell, geo);

							// Parent size might need to be updated if this
							// is seen as part of the resize
							if (extendParent)
							{
								graph.extendParent(cell);
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
	}

	/**
	 * 
	 */
	protected Object[] _getCellsToShift(CellState state)
	{
		Graph graph = this.getGraph();
		Object parent = graph.getModel().getParent(state.getCell());
		boolean down = isShiftDownwards();
		boolean right = isShiftRightwards();

		return graph.getCellsBeyond(state.getX()
				+ ((down) ? 0 : state.getWidth()), state.getY()
				+ ((down && right) ? 0 : state.getHeight()), parent, right,
				down);
	}

	/**
	 * 
	 */
	public void destroy()
	{
		setGraph(null);
	}

}
