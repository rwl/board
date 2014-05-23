/**
 * $Id: DistanceCostFunction.java,v 1.2 2012/11/21 14:16:01 mate Exp $
 * Copyright (c) 2007-2009, JGraph Ltd
 */
package graph.analysis;

import graph.util.Point2d;
import graph.view.CellState;

/**
 * Implements a cost function for the Euclidean length of an edge.
 */
public class DistanceCostFunction implements ICostFunction
{

	/**
	 * Returns the Euclidean length of the edge defined by the absolute
	 * points in the given state or 0 if no points are defined.
	 */
	public double getCost(CellState state)
	{
		double cost = 0;
		int pointCount = state.getAbsolutePointCount();

		if (pointCount > 0)
		{
			Point2d last = state.getAbsolutePoint(0);

			for (int i = 1; i < pointCount; i++)
			{
				Point2d point = state.getAbsolutePoint(i);
				cost += point.getPoint().distance(last.getPoint());
				last = point;
			}
		}

		return cost;
	}
}
