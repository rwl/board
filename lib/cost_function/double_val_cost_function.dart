/**
 * Copyright (c) 2012, JGraph Ltd
 * Returns the value of a cell, which is assumed a Double
 */
part of graph.costfunction;

/**
 * A cost function that assumes that edge value is of type "double" or "String" and returns that value. Default edge weight is 1.0 (if no double value can be retrieved)
 */
class DoubleValCostFunction extends CostFunction
{
	double getCost(CellState state)
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
