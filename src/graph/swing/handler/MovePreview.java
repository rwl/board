/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import graph.swing.GraphComponent;
//import graph.swing.util.SwingConstants;
//import graph.swing.view.CellStatePreview;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Rect;
//import graph.view.CellState;
//import graph.view.Graph;

//import java.awt.Graphics;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;
//import java.util.Collection;
//import java.util.LinkedList;

/**
 * Connection handler creates new connections between cells. This control is used to display the connector
 * icon, while the preview is used to draw the line.
 */
public class MovePreview extends EventSource
{
	/**
	 * 
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Maximum number of cells to preview individually. Default is 200.
	 */
	protected int _threshold = 200;

	/**
	 * Specifies if the placeholder rectangle should be used for all
	 * previews. Default is false. This overrides all other preview
	 * settings if true.
	 */
	protected boolean _placeholderPreview = false;

	/**
	 * Specifies if the preview should use clones of the original shapes.
	 * Default is true.
	 */
	protected boolean _clonePreview = true;

	/**
	 * Specifies if connected, unselected edges should be included in the
	 * preview. Default is true. This should not be used if cloning is
	 * enabled.
	 */
	protected boolean _contextPreview = true;

	/**
	 * Specifies if the selection cells handler should be hidden while the
	 * preview is visible. Default is false.
	 */
	protected boolean _hideSelectionHandler = false;

	/**
	 * 
	 */
	protected transient CellState _startState;

	/**
	 * 
	 */
	protected transient CellState[] _previewStates;

	/**
	 * 
	 */
	protected transient Object[] _movingCells;

	/**
	 * 
	 */
	protected transient Rectangle _initialPlaceholder;

	/**
	 * 
	 */
	protected transient Rectangle _placeholder;

	/**
	 * 
	 */
	protected transient Rect _lastDirty;

	/**
	 * 
	 */
	protected transient CellStatePreview _preview;

	/**
	 * Constructs a new rubberband selection for the given graph component.
	 * 
	 * @param graphComponent Component that contains the rubberband.
	 */
	public MovePreview(GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;

		// Installs the paint handler
		graphComponent.addListener(Event.AFTER_PAINT, new IEventListener()
		{
			public void invoke(Object sender, EventObj evt)
			{
				Graphics g = (Graphics) evt.getProperty("g");
				paint(g);
			}
		});
	}

	/**
	 * 
	 */
	public int getThreshold()
	{
		return _threshold;
	}

	/**
	 * 
	 */
	public void setThreshold(int value)
	{
		_threshold = value;
	}

	/**
	 * 
	 */
	public boolean isPlaceholderPreview()
	{
		return _placeholderPreview;
	}

	/**
	 * 
	 */
	public void setPlaceholderPreview(boolean value)
	{
		_placeholderPreview = value;
	}

	/**
	 * 
	 */
	public boolean isClonePreview()
	{
		return _clonePreview;
	}

	/**
	 * 
	 */
	public void setClonePreview(boolean value)
	{
		_clonePreview = value;
	}

	/**
	 * 
	 */
	public boolean isContextPreview()
	{
		return _contextPreview;
	}

	/**
	 * 
	 */
	public void setContextPreview(boolean value)
	{
		_contextPreview = value;
	}

	/**
	 * 
	 */
	public boolean isHideSelectionHandler()
	{
		return _hideSelectionHandler;
	}

	/**
	 * 
	 */
	public void setHideSelectionHandler(boolean value)
	{
		_hideSelectionHandler = value;
	}

	/**
	 * 
	 */
	public boolean isActive()
	{
		return _startState != null;
	}

	/**
	 * FIXME: Cells should be assigned outside of getPreviewStates
	 */
	public Object[] getMovingCells()
	{
		return _movingCells;
	}

	/**
	 * 
	 */
	public Object[] getCells(CellState initialState)
	{
		Graph graph = _graphComponent.getGraph();

		return graph.getMovableCells(graph.getSelectionCells());
	}

	/**
	 * Returns the states that are affected by the move operation.
	 */
	protected CellState[] _getPreviewStates()
	{
		Graph graph = _graphComponent.getGraph();
		Collection<CellState> result = new LinkedList<CellState>();

		for (Object cell : _movingCells)
		{
			CellState cellState = graph.getView().getState(cell);

			if (cellState != null)
			{
				result.add(cellState);

				// Terminates early if too many cells
				if (result.size() >= _threshold)
				{
					return null;
				}

				if (isContextPreview())
				{
					Object[] edges = graph.getAllEdges(new Object[] { cell });

					for (Object edge : edges)
					{
						if (!graph.isCellSelected(edge))
						{
							CellState edgeState = graph.getView().getState(
									edge);

							if (edgeState != null)
							{
								// Terminates early if too many cells
								if (result.size() >= _threshold)
								{
									return null;
								}

								result.add(edgeState);
							}
						}
					}
				}
			}
		}

		return result.toArray(new CellState[result.size()]);
	}

	/**
	 * 
	 */
	protected boolean _isCellOpaque(Object cell)
	{
		return _startState != null && _startState.getCell() == cell;
	}

	/**
	 * Sets the translation of the preview.
	 */
	public void start(MouseEvent e, CellState state)
	{
		_startState = state;
		_movingCells = getCells(state);
		_previewStates = (!_placeholderPreview) ? _getPreviewStates() : null;

		if (_previewStates == null || _previewStates.length >= _threshold)
		{
			_placeholder = _getPlaceholderBounds(_startState).getRectangle();
			_initialPlaceholder = new Rectangle(_placeholder);
			_graphComponent.getGraphControl().repaint(_placeholder);
		}

		fireEvent(new EventObj(Event.START, "event", e, "state",
				_startState));
	}

	/**
	 * 
	 */
	protected Rect _getPlaceholderBounds(CellState startState)
	{
		Graph graph = _graphComponent.getGraph();

		return graph.getView().getBounds(graph.getSelectionCells());
	}

	/**
	 * 
	 */
	public CellStatePreview createCellStatePreview()
	{
		return new CellStatePreview(_graphComponent, isClonePreview())
		{
			protected float _getOpacityForCell(Object cell)
			{
				if (_isCellOpaque(cell))
				{
					return 1;
				}

				return super._getOpacityForCell(cell);
			}
		};
	}

	/**
	 * Sets the translation of the preview.
	 */
	public void update(MouseEvent e, double dx, double dy, boolean clone)
	{
		Graph graph = _graphComponent.getGraph();

		if (_placeholder != null)
		{
			Rectangle tmp = new Rectangle(_placeholder);
			_placeholder.x = _initialPlaceholder.x + (int) dx;
			_placeholder.y = _initialPlaceholder.x + (int) dy;
			tmp.add(_placeholder);
			_graphComponent.getGraphControl().repaint(tmp);
		}
		else if (_previewStates != null)
		{
			_preview = createCellStatePreview();
			_preview.setOpacity(_graphComponent.getPreviewAlpha());

			// Combines the layout result with the move preview
			for (CellState previewState : _previewStates)
			{
				_preview.moveState(previewState, dx, dy, false, false);

				// FIXME: Move into show-handler?
				boolean visible = true;

				if ((dx != 0 || dy != 0) && clone && isContextPreview())
				{
					visible = false;
					Object tmp = previewState.getCell();

					while (!visible && tmp != null)
					{
						visible = graph.isCellSelected(tmp);
						tmp = graph.getModel().getParent(tmp);
					}
				}
			}

			Rect dirty = _lastDirty;

			_lastDirty = _preview.show();

			if (dirty != null)
			{
				dirty.add(_lastDirty);
			}
			else
			{
				dirty = _lastDirty;
			}

			if (dirty != null)
			{
				_repaint(dirty);
			}
		}

		if (isHideSelectionHandler())
		{
			_graphComponent.getSelectionCellsHandler().setVisible(false);
		}

		fireEvent(new EventObj(Event.CONTINUE, "event", e, "dx", dx,
				"dy", dy));
	}

	/**
	 * 
	 */
	protected void _repaint(Rect dirty)
	{
		if (dirty != null)
		{
			_graphComponent.getGraphControl().repaint(dirty.getRectangle());
		}
		else
		{
			_graphComponent.getGraphControl().repaint();
		}
	}

	/**
	 * 
	 */
	protected void _reset()
	{
		Graph graph = _graphComponent.getGraph();

		if (_placeholder != null)
		{
			Rectangle tmp = _placeholder;
			_placeholder = null;
			_graphComponent.getGraphControl().repaint(tmp);
		}

		if (isHideSelectionHandler())
		{
			_graphComponent.getSelectionCellsHandler().setVisible(true);
		}

		// Revalidates the screen
		// TODO: Should only revalidate moved cells
		if (!isClonePreview() && _previewStates != null)
		{
			graph.getView().revalidate();
		}

		_previewStates = null;
		_movingCells = null;
		_startState = null;
		_preview = null;

		if (_lastDirty != null)
		{
			_graphComponent.getGraphControl().repaint(_lastDirty.getRectangle());
			_lastDirty = null;
		}
	}

	/**
	 *
	 */
	public Object[] stop(boolean commit, MouseEvent e, double dx, double dy,
			boolean clone, Object target)
	{
		Object[] cells = _movingCells;
		_reset();

		Graph graph = _graphComponent.getGraph();
		graph.getModel().beginUpdate();
		try
		{
			if (commit)
			{
				double s = graph.getView().getScale();
				cells = graph.moveCells(cells, dx / s, dy / s, clone, target,
						e.getPoint());
			}

			fireEvent(new EventObj(Event.STOP, "event", e, "commit",
					commit));
		}
		finally
		{
			graph.getModel().endUpdate();
		}

		return cells;
	}

	/**
	 *
	 */
	public void paint(Graphics g)
	{
		if (_placeholder != null)
		{
			SwingConstants.PREVIEW_BORDER.paintBorder(_graphComponent, g,
					_placeholder.x, _placeholder.y, _placeholder.width,
					_placeholder.height);
		}

		if (_preview != null)
		{
			_preview.paint(g);
		}
	}

}
