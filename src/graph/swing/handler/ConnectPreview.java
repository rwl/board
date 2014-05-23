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
	protected GraphComponent graphComponent;

	/**
	 * 
	 */
	protected CellState previewState;

	/**
	 * 
	 */
	protected CellState sourceState;

	/**
	 * 
	 */
	protected Point2d startPoint;

	/**
	 * 
	 * @param graphComponent
	 */
	public ConnectPreview(GraphComponent graphComponent)
	{
		this.graphComponent = graphComponent;

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
	protected Object createCell(CellState startState, String style)
	{
		Graph graph = graphComponent.getGraph();
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
		return sourceState != null;
	}

	/**
	 * 
	 */
	public CellState getSourceState()
	{
		return sourceState;
	}

	/**
	 * 
	 */
	public CellState getPreviewState()
	{
		return previewState;
	}

	/**
	 * 
	 */
	public Point2d getStartPoint()
	{
		return startPoint;
	}

	/**
	 * Updates the style of the edge preview from the incoming edge
	 */
	public void start(MouseEvent e, CellState startState, String style)
	{
		Graph graph = graphComponent.getGraph();
		sourceState = startState;
		startPoint = transformScreenPoint(startState.getCenterX(),
				startState.getCenterY());
		Object cell = createCell(startState, style);
		graph.getView().validateCell(cell);
		previewState = graph.getView().getState(cell);
		
		fireEvent(new EventObj(Event.START, "event", e, "state",
				previewState));
	}

	/**
	 * 
	 */
	public void update(MouseEvent e, CellState targetState, double x, double y)
	{
		Graph graph = graphComponent.getGraph();
		ICell cell = (ICell) previewState.getCell();

		Rect dirty = graphComponent.getGraph().getPaintBounds(
				new Object[] { previewState.getCell() });

		if (cell.getTerminal(false) != null)
		{
			cell.getTerminal(false).removeEdge(cell, false);
		}

		if (targetState != null)
		{
			((ICell) targetState.getCell()).insertEdge(cell, false);
		}

		Geometry geo = graph.getCellGeometry(previewState.getCell());

		geo.setTerminalPoint(startPoint, true);
		geo.setTerminalPoint(transformScreenPoint(x, y), false);

		revalidate(previewState);
		fireEvent(new EventObj(Event.CONTINUE, "event", e, "x", x, "y",
				y));

		// Repaints the dirty region
		// TODO: Cache the new dirty region for next repaint
		Rectangle tmp = getDirtyRect(dirty);

		if (tmp != null)
		{
			graphComponent.getGraphControl().repaint(tmp);
		}
		else
		{
			graphComponent.getGraphControl().repaint();
		}
	}

	/**
	 * 
	 */
	protected Rectangle getDirtyRect()
	{
		return getDirtyRect(null);
	}

	/**
	 * 
	 */
	protected Rectangle getDirtyRect(Rect dirty)
	{
		if (previewState != null)
		{
			Rect tmp = graphComponent.getGraph().getPaintBounds(
					new Object[] { previewState.getCell() });

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
	protected Point2d transformScreenPoint(double x, double y)
	{
		Graph graph = graphComponent.getGraph();
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
		if (previewState != null)
		{
			Graphics2DCanvas canvas = graphComponent.getCanvas();

			if (graphComponent.isAntiAlias())
			{
				Utils.setAntiAlias((Graphics2D) g, true, false);
			}

			float alpha = graphComponent.getPreviewAlpha();

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
				canvas.setScale(graphComponent.getGraph().getView().getScale());
				canvas.setTranslate(0, 0);
				canvas.setGraphics((Graphics2D) g);

				paintPreview(canvas);
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
	protected void paintPreview(Graphics2DCanvas canvas)
	{
		graphComponent.getGraphControl().drawCell(graphComponent.getCanvas(),
				previewState.getCell());
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
		Object result = (sourceState != null) ? sourceState.getCell() : null;

		if (previewState != null)
		{
			Graph graph = graphComponent.getGraph();

			graph.getModel().beginUpdate();
			try
			{
				ICell cell = (ICell) previewState.getCell();
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
				if (previewState != null)
				{
					Rectangle dirty = getDirtyRect();
					graph.getView().clear(cell, false, true);
					previewState = null;

					if (!commit && dirty != null)
					{
						graphComponent.getGraphControl().repaint(dirty);
					}
				}
			}
			finally
			{
				graph.getModel().endUpdate();
			}
		}

		sourceState = null;
		startPoint = null;

		return result;
	}

}
