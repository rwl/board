/**
 * $Id: DoubleValCostFunction.java,v 1.2 2012/11/21 14:16:01 mate Exp $
 * Copyright (c) 2012, JGraph Ltd
 * Returns the value of a cell, which is assumed a Double
 */
package graph.costfunction;

import graph.view.CellState;
import graph.view.Graph;

/**
 * A cost function that assumes that edge value is of type "double" or "String" and returns that value. Default edge weight is 1.0 (if no double value can be retrieved)
 */
public class DoubleValCostFunction extends CostFunction
{
	public double getCost(CellState state)
	{
		//assumed future parameters
		if (state == null || state.getView() == null || state.getView().getGraph() == null)
		{
			return 1.0;
		}
		
		Graph graph = state.getView().getGraph();
		Object cell = state.getCell();
		
		Double edgeWeight = null;

		if(graph.getModel().getValue(cell) == null || graph.getModel().getValue(cell) == "")
		{
			return 1.0;
		}
		else if (graph.getModel().getValue(cell) instanceof String)
		{
			edgeWeight = Double.parseDouble((String) graph.getModel().getValue(cell));
		}
		else
		{
			edgeWeight = (Double) graph.getModel().getValue(cell);
		}

		return edgeWeight;
	};
};
