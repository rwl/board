part of graph.generatorfunction;

/**
 * @author Mate
 * A generator random cost function
 * It will generate random integer edge weights in the range of (<b>minWeight</b>, <b>maxWeight</b>) and rounds the values to <b>roundToDecimals</b>
 */
class GeneratorRandomIntFunction extends GeneratorFunction
{
	double _maxWeight = 10;

	double _minWeight = 0;

	GeneratorRandomIntFunction(double minWeight, double maxWeight)
	{
		setWeightRange(minWeight, maxWeight);
	};

	double getCost(CellState state)
	{
		//assumed future parameters
		//		Graph graph = state.getView().getGraph();
		//		Object cell = state.getCell();

		if (_minWeight == _maxWeight)
		{
			return _minWeight;
		}

		double currValue = _minWeight + Math.round((Math.random() * (_maxWeight - _minWeight)));
		return currValue;
	};

	double getMaxWeight()
	{
		return _maxWeight;
	};

	void setWeightRange(double minWeight, double maxWeight)
	{
		this._maxWeight = Math.round(Math.max(minWeight, maxWeight));
		this._minWeight = Math.round(Math.min(minWeight, maxWeight));
	};

	double getMinWeight()
	{
		return _minWeight;
	};
};
