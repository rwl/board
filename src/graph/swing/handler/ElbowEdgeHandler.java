/**
 * $Id: ElbowEdgeHandler.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2008, Gaudenz Alder
 */
package graph.swing.handler;

import graph.model.Geometry;
import graph.swing.GraphComponent;
import graph.util.Constants;
import graph.util.Point2d;
import graph.util.Resources;
import graph.view.CellState;
import graph.view.GraphView;

import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.util.List;

/**
 * @author Administrator
 * 
 */
public class ElbowEdgeHandler extends EdgeHandler
{

	/**
	 * 
	 * @param graphComponent
	 * @param state
	 */
	public ElbowEdgeHandler(GraphComponent graphComponent, CellState state)
	{
		super(graphComponent, state);
	}

	/**
	 * Hook for subclassers to return tooltip texts for certain points on the
	 * handle.
	 */
	public String getToolTipText(MouseEvent e)
	{
		int index = getIndexAt(e.getX(), e.getY());

		if (index == 1)
		{
			return Resources.get("doubleClickOrientation");
		}

		return null;
	}

	/**
	 * 
	 */
	protected boolean isFlipEvent(MouseEvent e)
	{
		return e.getClickCount() == 2 && index == 1;
	}

	/**
	 * Returns true if the given index is the index of the last handle.
	 */
	public boolean isLabel(int index)
	{
		return index == 3;
	}

	/**
	 * 
	 */
	protected Rectangle[] createHandles()
	{
		p = createPoints(state);
		Rectangle[] h = new Rectangle[4];

		Point2d p0 = state.getAbsolutePoint(0);
		Point2d pe = state.getAbsolutePoint(state.getAbsolutePointCount() - 1);

		h[0] = createHandle(p0.getPoint());
		h[2] = createHandle(pe.getPoint());

		// Creates the middle green edge handle
		Geometry geometry = graphComponent.getGraph().getModel().getGeometry(
				state.getCell());
		List<Point2d> points = geometry.getPoints();
		Point pt = null;

		if (points == null || points.isEmpty())
		{
			pt = new Point((int) (Math.round(p0.getX()) + Math
					.round((pe.getX() - p0.getX()) / 2)), (int) (Math.round(p0
					.getY()) + Math.round((pe.getY() - p0.getY()) / 2)));
		}
		else
		{
			GraphView view = graphComponent.getGraph().getView();
			pt = view.transformControlPoint(state, points.get(0))
					.getPoint();
		}

		// Create the green middle handle
		h[1] = createHandle(pt);

		// Creates the yellow label handle
		h[3] = createHandle(state.getAbsoluteOffset().getPoint(),
				Constants.LABEL_HANDLE_SIZE);

		// Makes handle slightly bigger if the yellow label handle
		// exists and intersects this green handle
		if (isHandleVisible(3) && h[1].intersects(h[3]))
		{
			h[1] = createHandle(pt, Constants.HANDLE_SIZE + 3);
		}

		return h;
	}

}
