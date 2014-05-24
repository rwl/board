part of graph.generatorfunction;

import '../view/view.dart' show CellState;

/**
 * @author Mate
 * A constant cost function that can be used during graph generation
 * All generated edges will have the weight <b>cost</b> 
 */
class GeneratorConstFunction extends GeneratorFunction
{
	private double _cost;
	
	GeneratorConstFunction(double cost)
	{
		this._cost = cost;
	};
	
	double getCost(CellState state)
	{
		return _cost;
	};
}
