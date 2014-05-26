part of graph.costfunction;

/**
 * @author Mate
 * A constant cost function that returns <b>const</b> regardless of edge value
 */
class ConstCostFunction extends CostFunction
{
	double _cost;
	
	ConstCostFunction(double cost)
	{
		this._cost = cost;
	}
	
	double getCost(CellState state)
	{
		return _cost;
	}
}
