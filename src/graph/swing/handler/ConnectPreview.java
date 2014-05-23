/**
 * $Id: ConnectPreview.java,v 1.2 2014/02/19 09:41:00 gaudenz Exp $
 * Copyright (c) 2008-2010, Gaudenz Alder, David Benson
 */
package graph.swing.handler;

import graph.canvas.Graphics2DCanvas;
import graph.model.Cell;
import graph.model.Geometry;
import graph.model.ICell;
import graph.model.IGraphModel;
import graph.swing.GraphComponent;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource;
import graph.util.Point2d;
import graph.util.Rect;
import graph.util.Utils;
import graph.view.CellState;
import graph.view.Graph;

import java.awt.AlphaComposite;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;

/**
 * Connection handler creates new connections between cells. This control is used to display the connector
 * icon, while the preview is used to draw the line.
 */
public class ConnectPreview extends EventSource
{
	/**
	 * 
	 */
	protected GraphComponent _graphComponent;

	/**
	 * 
	 */
	protected CellState _previewState;

	/**
	 * 
	 */
	protected CellState _sourceState;

	/**
	 * 
	 */
	protected Point2d _startPoint;

	/**
	 * 
	 * @param graphComponent
	 */
	public ConnectPreview(GraphComponent graphComponent)
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
	 * Creates a new instance of mxShape for previewing the edge.
	 */
	protected Object _createCell(CellState startState, String style)
	{
		Graph graph = _graphComponent.getGraph();
		ICell cell = ((ICell) graph
				.createEdge(null, null, "",
						(startState != null) ? startState.getCell() : null,
						null, style));
		((ICell) startState.getCell()).insertEdge(cell, true);

		return cell;
	}
	
	/**
	 * 
	 */
	public boolean isActive()
	{
		return _sourceState != null;
	}

	/**
	 * 
	 */
	public CellState getSourceState()
	{
		return _sourceState;
	}

	/**
	 * 
	 */
	public CellState getPreviewState()
	{
		return _previewState;
	}

	/**
	 * 
	 */
	public Point2d getStartPoint()
	{
		return _startPoint;
	}

	/**
	 * Updates the style of the edge preview from the incoming edge
	 */
	public void start(MouseEvent e, CellState startState, String style)
	{
		Graph graph = _graphComponent.getGraph();
		_sourceState = startState;
		_startPoint = _transformScreenPoint(startState.getCenterX(),
				startState.getCenterY());
		Object cell = _createCell(startState, style);
		graph.getView().validateCell(cell);
		_previewState = graph.getView().getState(cell);
		
		fireEvent(new EventObj(Event.START, "event", e, "state",
				_previewState));
	}

	/**
	 * 
	 */
	public void update(MouseEvent e, CellState targetState, double x, double y)
	{
		Graph graph = _graphComponent.getGraph();
		ICell cell = (ICell) _previewState.getCell();

		Rect dirty = _graphComponent.getGraph().getPaintBounds(
				new Object[] { _previewState.getCell() });

		if (cell.getTerminal(false) != null)
		{
			cell.getTerminal(false).removeEdge(cell, false);
		}

		if (targetState != null)
		{
			((ICell) targetState.getCell()).insertEdge(cell, false);
		}

		Geometry geo = graph.getCellGeometry(_previewState.getCell());

		geo.setTerminalPoint(_startPoint, true);
		geo.setTerminalPoint(_transformScreenPoint(x, y), false);

		revalidate(_previewState);
		fireEvent(new EventObj(Event.CONTINUE, "event", e, "x", x, "y",
				y));

		// Repaints the dirty region
		// TODO: Cache the new dirty region for next repaint
		Rectangle tmp = _getDirtyRect(dirty);

		if (tmp != null)
		{
			_graphComponent.getGraphControl().repaint(tmp);
		}
		else
		{
			_graphComponent.getGraphControl().repaint();
		}
	}

	/**
	 * 
	 */
	protected Rectangle _getDirtyRect()
	{
		return _getDirtyRect(null);
	}

	/**
	 * 
	 */
	protected Rectangle _getDirtyRect(Rect dirty)
	{
		if (_previewState != null)
		{
			Rect tmp = _graphComponent.getGraph().getPaintBounds(
					new Object[] { _previewState.getCell() });

			if (dirty != null)
			{
				dirty.add(tmp);
			}
			else
			{
				dirty = tmp;
			}

			if (dirty != null)
			{
				// TODO: Take arrow size into account
				dirty.grow(2);

				return dirty.getRectangle();
			}
		}

		return null;
	}

	/**
	 * 
	 */
	protected Point2d _transformScreenPoint(double x, double y)
	{
		Graph graph = _graphComponent.getGraph();
		Point2d tr = graph.getView().getTranslate();
		double scale = graph.getView().getScale();

		return new Point2d(graph.snap(x / scale - tr.getX()), graph.snap(y
				/ scale - tr.getY()));
	}

	/**
	 * 
	 */
	public void revalidate(CellState state)
	{
		state.getView().invalidate(state.getCell());
		state.getView().validateCellState(state.getCell());
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		if (_previewState != null)
		{
			Graphics2DCanvas canvas = _graphComponent.getCanvas();

			if (_graphComponent.isAntiAlias())
			{
				Utils.setAntiAlias((Graphics2D) g, true, false);
			}

			float alpha = _graphComponent.getPreviewAlpha();

			if (alpha < 1)
			{
				((Graphics2D) g).setComposite(AlphaComposite.getInstance(
						AlphaComposite.SRC_OVER, alpha));
			}

			Graphics2D previousGraphics = canvas.getGraphics();
			Point previousTranslate = canvas.getTranslate();
			double previousScale = canvas.getScale();

			try
			{
				canvas.setScale(_graphComponent.getGraph().getView().getScale());
				canvas.setTranslate(0, 0);
				canvas.setGraphics((Graphics2D) g);

				_paintPreview(canvas);
			}
			finally
			{
				canvas.setScale(previousScale);
				canvas.setTranslate(previousTranslate.x, previousTranslate.y);
				canvas.setGraphics(previousGraphics);
			}
		}
	}

	/**
	 * Draws the preview using the graphics canvas.
	 */
	protected void _paintPreview(Graphics2DCanvas canvas)
	{
		_graphComponent.getGraphControl().drawCell(_graphComponent.getCanvas(),
				_previewState.getCell());
	}

	/**
	 *
	 */
	public Object stop(boolean commit)
	{
		return stop(commit, null);
	}

	/**
	 *
	 */
	public Object stop(boolean commit, MouseEvent e)
	{
		Object result = (_sourceState != null) ? _sourceState.getCell() : null;

		if (_previewState != null)
		{
			Graph graph = _graphComponent.getGraph();

			graph.getModel().beginUpdate();
			try
			{
				ICell cell = (ICell) _previewState.getCell();
				Object src = cell.getTerminal(true);
				Object trg = cell.getTerminal(false);

				if (src != null)
				{
					((ICell) src).removeEdge(cell, true);
				}

				if (trg != null)
				{
					((ICell) trg).removeEdge(cell, false);
				}

				if (commit)
				{
					result = graph.addCell(cell, null, null, src, trg);
				}

				fireEvent(new EventObj(Event.STOP, "event", e, "commit",
						commit, "cell", (commit) ? result : null));

				// Clears the state before the model commits
				if (_previewState != null)
				{
					Rectangle dirty = _getDirtyRect();
					graph.getView().clear(cell, false, true);
					_previewState = null;

					if (!commit && dirty != null)
					{
						_graphComponent.getGraphControl().repaint(dirty);
					}
				}
			}
			finally
			{
				graph.getModel().endUpdate();
			}
		}

		_sourceState = null;
		_startPoint = null;

		return result;
	}

}
