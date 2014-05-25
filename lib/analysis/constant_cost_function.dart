/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.analysis;


/**
 * Implements a cost function for a constant cost per traversed cell.
 */
class ConstantCostFunction implements ICostFunction
{

	/**
	 * 
	 */
	double _cost = 0;

	/**
	 * 
	 * @param cost
	 */
	ConstantCostFunction(double cost)
	{
		this._cost = cost;
	}

	/**
	 *
	 */
	double getCost(CellState state)
	{
		return _cost;
	}

}