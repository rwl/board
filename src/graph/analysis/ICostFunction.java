/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.analysis;

//import graph.view.CellState;

/**
 * The cost function takes a cell and returns it's cost as a double. Two typical
 * examples of cost functions are the euclidian length of edges or a constant
 * number for each edge. To use one of the built-in cost functions, use either
 * <code>new DistanceCostFunction(graph)</code> or
 * <code>new ConstantCostFunction(1)</code>.
 */
public interface ICostFunction
{

	/**
	 * Evaluates the cost of the given cell state.
	 * 
	 * @param state The cell state to be evaluated
	 * @return Returns the cost to traverse the given cell state.
	 */
	double getCost(CellState state);

}
