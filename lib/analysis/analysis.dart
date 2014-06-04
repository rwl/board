library graph.analysis;

/**
 * This package provides various algorithms for graph analysis, such as
 * shortest path and minimum spanning tree.
 */

import 'dart:html' show window;
import 'dart:collection' show HashSet, LinkedList, Queue;
import 'dart:math' as Math;
import 'dart:collection' show HashMap;

import '../util/java/math.dart' as math;

import '../cost_function/cost_function.dart' show CostFunction, DoubleValCostFunction;
import '../generator_function/generator_function.dart' show GeneratorFunction, GeneratorRandomFunction;
import '../model/model.dart' show IGraphModel, GraphModel, Geometry, Cell;
import '../view/view.dart' show Graph, GraphView, CellState, ICellVisitor;
import '../util/util.dart' show Point2d, Utils;

part 'analysis_graph.dart';
part 'constant_cost_function.dart';
part 'distance_cost_function.dart';
part 'fibonacci_heap.dart';
part 'graph_analysis.dart';
part 'graph_generator.dart';
part 'graph_properties.dart';
part 'graph_structure.dart';
part 'graph_type.dart';
part 'cost_function.dart';
part 'traversal.dart';
part 'union_find.dart';


/**
 * A custom exception for irregular graph structure for certain algorithms.
 */
class StructuralException extends Error {

  String message;

  StructuralException(this.message);
  
}
