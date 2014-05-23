/**
 * $Id: ConstantCostFunction.java,v 1.2 2012/11/21 14:16:01 mate Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.analysis;

import graph.view.CellState;

/**
 * Implements a cost function for a constant cost per traversed cell.
 */
public class ConstantCostFunction implements ICostFunction
{

	/**
	 * 
	 */
	protected double cost = 0;

	/**
	 * 
	 * @param cost
	 */
	public ConstantCostFunction(double cost)
	{
		this.cost = cost;
	}

	/**
	 *
	 */
	public double getCost(CellState state)
	{
		return cost;
	}

}