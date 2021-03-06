part of graph.generatorfunction;

/**
 * @author Mate
 * A constant cost function that can be used during graph generation
 * All generated edges will have the weight <b>cost</b> 
 */
class GeneratorConstFunction extends GeneratorFunction {
  double _cost;

  GeneratorConstFunction(double cost) {
    this._cost = cost;
  }

  double getCost(CellState state) {
    return _cost;
  }
}
