package graph.generatorfunction;

//import graph.view.CellState;

/**
 * @author Mate
 * A generator random cost function
 * It will generate random (type "double") edge weights in the range of (<b>minWeight</b>, <b>maxWeight</b>) and rounds the values to <b>roundToDecimals</b>
 */
public class GeneratorRandomFunction extends GeneratorFunction
{
	private double _maxWeight = 1;

	private double _minWeight = 0;

	private int _roundToDecimals = 2;

	public GeneratorRandomFunction(double minWeight, double maxWeight, int roundToDecimals)
	{
		setWeightRange(minWeight, maxWeight);
		setRoundToDecimals(roundToDecimals);
	};

	public double getCost(CellState state)
	{
		Double edgeWeight = null;

		edgeWeight = Math.random() * (_maxWeight - _minWeight) + _minWeight;
		edgeWeight = (double) Math.round(edgeWeight * Math.pow(10, getRoundToDecimals())) / Math.pow(10, getRoundToDecimals());

		return edgeWeight;
	};

	public double getMaxWeight()
	{
		return _maxWeight;
	};

	public void setWeightRange(double minWeight, double maxWeight)
	{
		this._maxWeight = Math.max(minWeight, maxWeight);
		this._minWeight = Math.min(minWeight, maxWeight);
	};

	public double getMinWeight()
	{
		return _minWeight;
	};

	public int getRoundToDecimals()
	{
		return _roundToDecimals;
	};

	public void setRoundToDecimals(int roundToDecimals)
	{
		this._roundToDecimals = roundToDecimals;
	};
};
