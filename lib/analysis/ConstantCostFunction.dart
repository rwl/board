/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.analysis;

//import graph.view.CellState;

/**
 * Implements a cost function for a constant cost per traversed cell.
 */
public class ConstantCostFunction implements ICostFunction
{

	/**
	 * 
	 */
	protected double _cost = 0;

	/**
	 * 
	 * @param cost
	 */
	public ConstantCostFunction(double cost)
	{
		this._cost = cost;
	}

	/**
	 *
	 */
	public double getCost(CellState state)
	{
		return _cost;
	}

}