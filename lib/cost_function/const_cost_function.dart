part of graph.costfunction;

import '../view/view.dart' show CellState;

/**
 * @author Mate
 * A constant cost function that returns <b>const</b> regardless of edge value
 */
class ConstCostFunction extends CostFunction
{
	private double _cost;
	
	ConstCostFunction(double cost)
	{
		this._cost = cost;
	};
	
	double getCost(CellState state)
	{
		return _cost;
	};
}
