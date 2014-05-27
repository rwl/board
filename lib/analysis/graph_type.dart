part of graph.analysis;

class GraphType {
    final _value;
    const GraphType._internal(this._value);
    toString() => '$_value';

    static const FULLY_CONNECTED  = const GraphType._internal('FULLY_CONNECTED');
    static const RANDOM_CONNECTED = const GraphType._internal('RANDOM_CONNECTED');
    static const TREE = const GraphType._internal('TREE');
    static const FLOW = const GraphType._internal('FLOW');
    static const NULL = const GraphType._internal('NULL');
    static const COMPLETE = const GraphType._internal('COMPLETE');
    static const NREGULAR = const GraphType._internal('NREGULAR');
    static const GRID = const GraphType._internal('GRID');
    static const BIPARTITE = const GraphType._internal('BIPARTITE');
    static const COMPLETE_BIPARTITE = const GraphType._internal('COMPLETE_BIPARTITE');
    static const BASIC_TREE = const GraphType._internal('BASIC_TREE');
    static const SIMPLE_RANDOM = const GraphType._internal('SIMPLE_RANDOM');
    static const BFS_DIR = const GraphType._internal('BFS_DIR');
    static const BFS_UNDIR = const GraphType._internal('BFS_UNDIR');
    static const DFS_DIR = const GraphType._internal('DFS_DIR');
    static const DFS_UNDIR = const GraphType._internal('DFS_UNDIR');
    static const DIJKSTRA = const GraphType._internal('DIJKSTRA');
    static const MAKE_TREE_DIRECTED = const GraphType._internal('MAKE_TREE_DIRECTED');
    static const SIMPLE_RANDOM_TREE = const GraphType._internal('SIMPLE_RANDOM_TREE');
    static const KNIGHT_TOUR = const GraphType._internal('KNIGHT_TOUR');
    static const KNIGHT = const GraphType._internal('KNIGHT');
    static const GET_ADJ_MATRIX = const GraphType._internal('GET_ADJ_MATRIX');
    static const FROM_ADJ_MATRIX = const GraphType._internal('FROM_ADJ_MATRIX');
    static const PETERSEN = const GraphType._internal('PETERSEN');
    static const WHEEL = const GraphType._internal('WHEEL');
    static const STAR = const GraphType._internal('STAR');
    static const PATH = const GraphType._internal('PATH');
    static const FRIENDSHIP_WINDMILL = const GraphType._internal('FRIENDSHIP_WINDMILL');
    static const FULL_WINDMILL = const GraphType._internal('FULL_WINDMILL');
    static const INDEGREE = const GraphType._internal('INDEGREE');
    static const OUTDEGREE = const GraphType._internal('OUTDEGREE');
    static const IS_CUT_VERTEX = const GraphType._internal('IS_CUT_VERTEX');
    static const IS_CUT_EDGE = const GraphType._internal('IS_CUT_EDGE');
    static const RESET_STYLE = const GraphType._internal('RESET_STYLE');
    static const KING = const GraphType._internal('KING');
    static const BELLMAN_FORD = const GraphType._internal('BELLMAN_FORD');
}