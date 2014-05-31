part of graph.generatorfunction;

/**
 * @author Mate
 * A generator random cost function
 * It will generate random (type "double") edge weights in the range of (<b>minWeight</b>, <b>maxWeight</b>) and rounds the values to <b>roundToDecimals</b>
 */
class GeneratorRandomFunction extends GeneratorFunction {
  double _maxWeight = 1.0;

  double _minWeight = 0.0;

  int _roundToDecimals = 2;

  GeneratorRandomFunction(double minWeight, double maxWeight, int roundToDecimals) {
    setWeightRange(minWeight, maxWeight);
    setRoundToDecimals(roundToDecimals);
  }

  double getCost(CellState state) {
    double edgeWeight = null;

    edgeWeight = math.random() * (_maxWeight - _minWeight) + _minWeight;
    edgeWeight = math.round(edgeWeight * Math.pow(10, getRoundToDecimals())) / Math.pow(10, getRoundToDecimals()) as double;

    return edgeWeight;
  }

  double getMaxWeight() {
    return _maxWeight;
  }

  void setWeightRange(double minWeight, double maxWeight) {
    this._maxWeight = Math.max(minWeight, maxWeight);
    this._minWeight = Math.min(minWeight, maxWeight);
  }

  double getMinWeight() {
    return _minWeight;
  }

  int getRoundToDecimals() {
    return _roundToDecimals;
  }

  void setRoundToDecimals(int roundToDecimals) {
    this._roundToDecimals = roundToDecimals;
  }
}
