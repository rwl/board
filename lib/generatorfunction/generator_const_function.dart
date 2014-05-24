part of graph.generatorfunction;

//import graph.view.CellState;

/**
 * @author Mate
 * A constant cost function that can be used during graph generation
 * All generated edges will have the weight <b>cost</b> 
 */
public class GeneratorConstFunction extends GeneratorFunction
{
	private double _cost;
	
	public GeneratorConstFunction(double cost)
	{
		this._cost = cost;
	};
	
	public double getCost(CellState state)
	{
		return _cost;
	};
}
