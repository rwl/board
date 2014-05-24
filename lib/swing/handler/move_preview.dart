/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import java.awt.Graphics;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;
//import java.util.Collection;
//import java.util.LinkedList;

/**
 * Connection handler creates new connections between cells. This control is used to display the connector
 * icon, while the preview is used to draw the line.
 */
class MovePreview extends EventSource
{
	/**
	 * 
	 */
	GraphComponent _graphComponent;

	/**
	 * Maximum number of cells to preview individually. Default is 200.
	 */
	int _threshold = 200;

	/**
	 * Specifies if the placeholder rectangle should be used for all
	 * previews. Default is false. This overrides all other preview
	 * settings if true.
	 */
	bool _placeholderPreview = false;

	/**
	 * Specifies if the preview should use clones of the original shapes.
	 * Default is true.
	 */
	bool _clonePreview = true;

	/**
	 * Specifies if connected, unselected edges should be included in the
	 * preview. Default is true. This should not be used if cloning is
	 * enabled.
	 */
	bool _contextPreview = true;

	/**
	 * Specifies if the selection cells handler should be hidden while the
	 * preview is visible. Default is false.
	 */
	bool _hideSelectionHandler = false;

	/**
	 * 
	 */
	/*transient*/ CellState _startState;

	/**
	 * 
	 */
	/*transient*/ List<CellState> _previewStates;

	/**
	 * 
	 */
	/*transient*/ List<Object> _movingCells;

	/**
	 * 
	 */
	/*transient*/ Rectangle _initialPlaceholder;

	/**
	 * 
	 */
	/*transient*/ Rectangle _placeholder;

	/**
	 * 
	 */
	/*transient*/ Rect _lastDirty;

	/**
	 * 
	 */
	/*transient*/ CellStatePreview _preview;

	/**
	 * Constructs a new rubberband selection for the given graph component.
	 * 
	 * @param graphComponent Component that contains the rubberband.
	 */
	MovePreview(GraphComponent graphComponent)
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
	int getThreshold()
	{
		return _threshold;
	}

	/**
	 * 
	 */
	void setThreshold(int value)
	{
		_threshold = value;
	}

	/**
	 * 
	 */
	bool isPlaceholderPreview()
	{
		return _placeholderPreview;
	}

	/**
	 * 
	 */
	void setPlaceholderPreview(bool value)
	{
		_placeholderPreview = value;
	}

	/**
	 * 
	 */
	bool isClonePreview()
	{
		return _clonePreview;
	}

	/**
	 * 
	 */
	void setClonePreview(bool value)
	{
		_clonePreview = value;
	}

	/**
	 * 
	 */
	bool isContextPreview()
	{
		return _contextPreview;
	}

	/**
	 * 
	 */
	void setContextPreview(bool value)
	{
		_contextPreview = value;
	}

	/**
	 * 
	 */
	bool isHideSelectionHandler()
	{
		return _hideSelectionHandler;
	}

	/**
	 * 
	 */
	void setHideSelectionHandler(bool value)
	{
		_hideSelectionHandler = value;
	}

	/**
	 * 
	 */
	bool isActive()
	{
		return _startState != null;
	}

	/**
	 * FIXME: Cells should be assigned outside of getPreviewStates
	 */
	List<Object> getMovingCells()
	{
		return _movingCells;
	}

	/**
	 * 
	 */
	List<Object> getCells(CellState initialState)
	{
		Graph graph = _graphComponent.getGraph();

		return graph.getMovableCells(graph.getSelectionCells());
	}

	/**
	 * Returns the states that are affected by the move operation.
	 */
	List<CellState> _getPreviewStates()
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
					List<Object> edges = graph.getAllEdges(new List<Object> { cell });

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
	bool _isCellOpaque(Object cell)
	{
		return _startState != null && _startState.getCell() == cell;
	}

	/**
	 * Sets the translation of the preview.
	 */
	void start(MouseEvent e, CellState state)
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
	Rect _getPlaceholderBounds(CellState startState)
	{
		Graph graph = _graphComponent.getGraph();

		return graph.getView().getBounds(graph.getSelectionCells());
	}

	/**
	 * 
	 */
	CellStatePreview createCellStatePreview()
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
	void update(MouseEvent e, double dx, double dy, bool clone)
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
				bool visible = true;

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
	void _repaint(Rect dirty)
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
	void _reset()
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
	List<Object> stop(bool commit, MouseEvent e, double dx, double dy,
			bool clone, Object target)
	{
		List<Object> cells = _movingCells;
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
	void paint(Graphics g)
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
