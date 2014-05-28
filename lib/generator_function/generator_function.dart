library graph.generatorfunction;

import '../analysis/analysis.dart' show ICostFunction;
import '../view/view.dart' show CellState;

part 'generator_const_function.dart';
part 'generator_random_function.dart';
part 'generator_random_int_function.dart';

/**
 * @author Mate
 * A parent class for all generator cost functions that are used for generating edge weights during graph generation
 */
class GeneratorFunction implements ICostFunction {
}
