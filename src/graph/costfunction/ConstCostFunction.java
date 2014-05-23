package graph.costfunction;

import graph.view.CellState;

/**
 * @author Mate
 * A constant cost function that returns <b>const</b> regardless of edge value
 */
public class ConstCostFunction extends CostFunction
{
	private double _cost;
	
	public ConstCostFunction(double cost)
	{
		this._cost = cost;
	};
	
	public double getCost(CellState state)
	{
		return _cost;
	};
}
