/**
 * Copyright (c) 2007-2009, JGraph Ltd
 */
part of graph.analysis;

import '../util/util.dart' show Point2d;
import '../view/view.dart' show CellState;

/**
 * Implements a cost function for the Euclidean length of an edge.
 */
class DistanceCostFunction implements ICostFunction
{

	/**
	 * Returns the Euclidean length of the edge defined by the absolute
	 * points in the given state or 0 if no points are defined.
	 */
	double getCost(CellState state)
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
