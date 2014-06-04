/**
 * Copyright (c) 2001-2005, Gaudenz Alder
 */
part of graph.analysis;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Collections;
//import java.util.Comparator;
//import java.util.Hashtable;
//import java.util.List;

/**
 * A singleton class that provides algorithms for graphs. Assume these
 * variables for the following examples:<br>
 * <code>
 * ICostFunction cf = DistanceCostFunction();
 * List<Object> v = graph.getChildVertices(graph.getDefaultParent());
 * List<Object> e = graph.getChildEdges(graph.getDefaultParent());
 * GraphAnalysis mga = GraphAnalysis.getInstance();
 * </code>
 * 
 * <h3>Shortest Path (Dijkstra)</h3>
 * 
 * For example, to find the shortest path between the first and the second
 * selected cell in a graph use the following code: <br>
 * <br>
 * <code>List<Object> path = mga.getShortestPath(graph, from, to, cf, v.length, true);</code>
 * 
 * <h3>Minimum Spanning Tree</h3>
 * 
 * This algorithm finds the set of edges with the minimal length that connect
 * all vertices. This algorithm can be used as follows:
 * <h5>Prim</h5>
 * <code>mga.getMinimumSpanningTree(graph, v, cf, true))</code>
 * <h5>Kruskal</h5>
 * <code>mga.getMinimumSpanningTree(graph, v, e, cf))</code>
 * 
 * <h3>Connection Components</h3>
 * 
 * The union find may be used as follows to determine whether two cells are
 * connected: <code>bool connected = uf.differ(vertex1, vertex2)</code>.
 * 
 * @see ICostFunction
 */
class GraphAnalysis {

  /**
	 * Holds the shared instance of this class.
	 */
  static GraphAnalysis _instance = new GraphAnalysis();

  /**
	 *
	 */
  GraphAnalysis() {
    // empty
  }

  /**
	 * @return Returns the sharedInstance.
	 */
  static GraphAnalysis getInstance() {
    return _instance;
  }

  /**
	 * Sets the shared instance of this class.
	 * 
	 * @param instance The instance to set.
	 */
  static void setInstance(GraphAnalysis instance) {
    GraphAnalysis._instance = instance;
  }

  /**
	 * Returns the shortest path between two cells or their descendants
	 * represented as an array of edges in order of traversal. <br>
	 * This implementation is based on the Dijkstra algorithm.
	 * 
	 * @param graph The object that defines the graph structure
	 * @param from The source cell.
	 * @param to The target cell (aka sink).
	 * @param cf The cost function that defines the edge length.
	 * @param steps The maximum number of edges to traverse.
	 * @param directed If edge directions should be taken into account.
	 * @return Returns the shortest path as an alternating array of vertices
	 * and edges, starting with <code>from</code> and ending with
	 * <code>to</code>.
	 * 
	 * @see #_createPriorityQueue()
	 */
  List<Object> getShortestPath(Graph graph, Object from, Object to, ICostFunction cf, int steps, bool directed) {
    // Sets up a pqueue and a hashtable to store the predecessor for each
    // cell in tha graph traversal. The pqueue is initialized
    // with the from element at prio 0.
    GraphView view = graph.getView();
    FibonacciHeap q = _createPriorityQueue();
    Map<Object, Object> pred = new Map<Object, Object>();
    q.decreaseKey(q.getNode(from, true), 0.0); // Inserts automatically

    // The main loop of the dijkstra algorithm is based on the pqueue being
    // updated with the actual shortest distance to the source vertex.
    for (int j = 0; j < steps; j++) {
      _FibonacciHeapNode node = q.removeMin();
      double prio = node.getKey();
      Object obj = node.getUserObject();

      // Exits the loop if the target node or vertex has been reached
      if (obj == to) {
        break;
      }

      // Gets all outgoing edges of the closest cell to the source
      List<Object> e = (directed) ? graph.getOutgoingEdges(obj) : graph.getConnections(obj);

      if (e != null) {
        for (int i = 0; i < e.length; i++) {
          List<Object> opp = graph.getOpposites([e[i]], obj);

          if (opp != null && opp.length > 0) {
            Object neighbour = opp[0];

            // Updates the priority in the pqueue for the opposite node
            // to be the distance of this step plus the cost to
            // traverese the edge to the neighbour. Note that the
            // priority queue will make sure that in the next step the
            // node with the smallest prio will be traversed.
            if (neighbour != null && neighbour != obj && neighbour != from) {
              double newPrio = prio + ((cf != null) ? cf.getCost(view.getState(e[i])) : 1);
              node = q.getNode(neighbour, true);
              double oldPrio = node.getKey();

              if (newPrio < oldPrio) {
                pred[neighbour] = e[i];
                q.decreaseKey(node, newPrio);
              }
            }
          }
        }
      }

      if (q.isEmpty()) {
        break;
      }
    }

    // Constructs a path array by walking backwards through the predessecor
    // map and filling up a list of edges, which is subsequently returned.
    List<Object> list = new List<Object>(2 * steps);
    Object obj = to;
    Object edge = pred[obj];

    if (edge != null) {
      list.add(obj);

      while (edge != null) {
        list.insert(0, edge);

        CellState state = view.getState(edge);
        Object source = (state != null) ? state.getVisibleTerminal(true) : view.getVisibleTerminal(edge, true);
        bool isSource = source == obj;
        obj = (state != null) ? state.getVisibleTerminal(!isSource) : view.getVisibleTerminal(edge, !isSource);
        list.insert(0, obj);

        edge = pred[obj];
      }
    }

    return list;
  }

  /**
	 * Returns the minimum spanning tree (MST) for the graph defined by G=(E,V).
	 * The MST is defined as the set of all vertices with minimal lengths that
	 * forms no cycles in G.<br>
	 * This implementation is based on the algorihm by Prim-Jarnik. It uses
	 * O(|E|+|V|log|V|) time when used with a Fibonacci heap and a graph whith a
	 * double linked-list datastructure, as is the case with the default
	 * implementation.
	 * 
	 * @param graph
	 *            the object that describes the graph
	 * @param v
	 *            the vertices of the graph
	 * @param cf
	 *            the cost function that defines the edge length
	 * 
	 * @return Returns the MST as an array of edges
	 * 
	 * @see #_createPriorityQueue()
	 */
  List<Object> getMinimumSpanningTree(Graph graph, List<Object> v, ICostFunction cf, bool directed) {
    List<Object> mst = new List<Object>(v.length);

    // Sets up a pqueue and a hashtable to store the predecessor for each
    // cell in tha graph traversal. The pqueue is initialized
    // with the from element at prio 0.
    FibonacciHeap q = _createPriorityQueue();
    Map<Object, Object> pred = new Map<Object, Object>();
    Object u = v[0];
    q.decreaseKey(q.getNode(u, true), 0.0);

    for (int i = 1; i < v.length; i++) {
      q.getNode(v[i], true);
    }

    // The main loop of the dijkstra algorithm is based on the pqueue being
    // updated with the actual shortest distance to the source vertex.
    while (!q.isEmpty()) {
      _FibonacciHeapNode node = q.removeMin();
      u = node.getUserObject();
      Object edge = pred[u];

      if (edge != null) {
        mst.add(edge);
      }

      // Gets all outgoing edges of the closest cell to the source
      List<Object> e = (directed) ? graph.getOutgoingEdges(u) : graph.getConnections(u);
      List<Object> opp = graph.getOpposites(e, u);

      if (e != null) {
        for (int i = 0; i < e.length; i++) {
          Object neighbour = opp[i];

          // Updates the priority in the pqueue for the opposite node
          // to be the distance of this step plus the cost to
          // traverese the edge to the neighbour. Note that the
          // priority queue will make sure that in the next step the
          // node with the smallest prio will be traversed.
          if (neighbour != null && neighbour != u) {
            node = q.getNode(neighbour, false);

            if (node != null) {
              double newPrio = cf.getCost(graph.getView().getState(e[i]));
              double oldPrio = node.getKey();

              if (newPrio < oldPrio) {
                pred[neighbour] = e[i];
                q.decreaseKey(node, newPrio);
              }
            }
          }
        }
      }
    }

    return mst;
  }

  /**
	 * Returns the minimum spanning tree (MST) for the graph defined by G=(E,V).
	 * The MST is defined as the set of all vertices with minimal lenths that
	 * forms no cycles in G.<br>
	 * This implementation is based on the algorihm by Kruskal. It uses
	 * O(|E|log|E|)=O(|E|log|V|) time for sorting the edges, O(|V|) create sets,
	 * O(|E|) find and O(|V|) union calls on the union find structure, thus
	 * yielding no more than O(|E|log|V|) steps. For a faster implementatin
	 * 
	 * @see #getMinimumSpanningTree(Graph, List<Object>, ICostFunction,
	 *      boolean)
	 * 
	 * @param graph The object that contains the graph.
	 * @param v The vertices of the graph.
	 * @param e The edges of the graph.
	 * @param cf The cost function that defines the edge length.
	 * 
	 * @return Returns the MST as an array of edges.
	 * 
	 * @see #_createUnionFind(List<Object>)
	 */
  List<Object> getMinimumSpanningTreeKruskal(Graph graph, List<Object> v, List<Object> e, ICostFunction cf) {
    // Sorts all edges according to their lengths, then creates a union
    // find structure for all vertices. Then walks through all edges by
    // increasing length and tries adding to the MST. Only edges are added
    // that do not form cycles in the graph, that is, where the source
    // and target are in different sets in the union find structure.
    // Whenever an edge is added to the MST, the two different sets are
    // unified.
    GraphView view = graph.getView();
    UnionFind uf = _createUnionFind(v);
    List<Object> result = new List<Object>(e.length);
    List<CellState> edgeStates = sort(view.getCellStates(e), cf);

    for (int i = 0; i < edgeStates.length; i++) {
      Object source = edgeStates[i].getVisibleTerminal(true);
      Object target = edgeStates[i].getVisibleTerminal(false);

      _UnionFindNode setA = uf.find(uf.getNode(source));
      _UnionFindNode setB = uf.find(uf.getNode(target));

      if (setA == null || setB == null || setA != setB) {
        uf.union(setA, setB);
        result.add(edgeStates[i].getCell());
      }
    }

    return result;
  }

  /**
	 * Returns a union find structure representing the connection components of
	 * G=(E,V).
	 * 
	 * @param graph The object that contains the graph.
	 * @param v The vertices of the graph.
	 * @param e The edges of the graph.
	 * @return Returns the connection components in G=(E,V)
	 * 
	 * @see #_createUnionFind(List<Object>)
	 */
  UnionFind getConnectionComponents(Graph graph, List<Object> v, List<Object> e) {
    GraphView view = graph.getView();
    UnionFind uf = _createUnionFind(v);

    for (int i = 0; i < e.length; i++) {
      CellState state = view.getState(e[i]);
      Object source = (state != null) ? state.getVisibleTerminal(true) : view.getVisibleTerminal(e[i], true);
      Object target = (state != null) ? state.getVisibleTerminal(false) : view.getVisibleTerminal(e[i], false);

      uf.union(uf.find(uf.getNode(source)), uf.find(uf.getNode(target)));
    }

    return uf;
  }

  /**
	 * Returns a sorted set for <code>cells</code> with respect to
	 * <code>cf</code>.
	 * 
	 * @param states
	 *            the cell states to sort
	 * @param cf
	 *            the cost function that defines the order
	 * 
	 * @return Returns an ordered set of <code>cells</code> wrt.
	 *         <code>cf</code>
	 */
  List<CellState> sort(List<CellState> states, final ICostFunction cf) {
    List<CellState> result = new List<CellState>.from(states);

    result.sort((CellState o1, CellState o2) {
      double d1 = cf.getCost(o1);
      double d2 = cf.getCost(o2);

      return d1.compareTo(d2);
    });

    return result;// as List<CellState>;
  }

  /**
	 * Returns the sum of all cost for <code>cells</code> with respect to
	 * <code>cf</code>.
	 * 
	 * @param states
	 *            the cell states to use for the sum
	 * @param cf
	 *            the cost function that defines the costs
	 * 
	 * @return Returns the sum of all cell cost
	 */
  double sum(List<CellState> states, ICostFunction cf) {
    double sum = 0.0;

    for (int i = 0; i < states.length; i++) {
      sum += cf.getCost(states[i]);
    }

    return sum;
  }

  /**
	 * Hook for subclassers to provide a custom union find structure.
	 * 
	 * @param v
	 *            the array of all elements
	 * 
	 * @return Returns a union find structure for <code>v</code>
	 */
  UnionFind _createUnionFind(List<Object> v) {
    return new UnionFind(v);
  }

  /**
	 * Hook for subclassers to provide a custom fibonacci heap.
	 */
  FibonacciHeap _createPriorityQueue() {
    return new FibonacciHeap();
  }

}
