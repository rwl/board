/**
 * Copyright (c) 2011-2012, JGraph Ltd
 */
part of graph.analysis;


/**
 * Implements a collection of utility methods for traversing the
 * graph structure. This does not include tree traversal methods.
 */
class Traversal {

  /**
   * Implements a recursive depth first search starting from the specified
   * cell. Process on the cell is performing by the visitor class passed in.
   * The visitor has access to the current cell and the edge traversed to
   * find this cell. Every cell is processed once only.
   * <pre>
   * Traversal.bfs(analysisGraph, startVertex, new ICellVisitor()
   * {
   * 	public bool visit(Object vertex, Object edge)
   * 	{
   * 		// perform your processing on each cell here
   *		return false;
   *	}
   * });
   * </pre>
   * @param aGraph the graph 
   * @param startVertex
   * @param visitor
   */
  static void dfs(AnalysisGraph aGraph, Object startVertex, ICellVisitor visitor) {
    _dfsRec(aGraph, startVertex, null, new HashSet<Object>(), visitor);
  }

  /**
   * Core recursive DFS - for internal use
   * @param aGraph
   * @param cell
   * @param edge
   * @param seen
   * @param visitor
   */
  static void _dfsRec(AnalysisGraph aGraph, Object cell, Object edge, Set<Object> seen, ICellVisitor visitor) {
    if (cell != null) {
      if (!seen.contains(cell)) {
        visitor(cell, edge);
        seen.add(cell);

        final List<Object> edges = aGraph.getEdges(cell, null, false, true);
        final List<Object> opposites = aGraph.getOpposites(edges, cell);

        for (int i = 0; i < opposites.length; i++) {
          _dfsRec(aGraph, opposites[i], edges[i], seen, visitor);
        }
      }
    }
  }

  /**
   * Implements a recursive breadth first search starting from the specified
   * cell. Process on the cell is performing by the visitor class passed in.
   * The visitor has access to the current cell and the edge traversed to
   * find this cell. Every cell is processed once only.
   * <pre>
   * Traversal.bfs(analysisGraph, startVertex, new ICellVisitor()
   * {
   * 	public bool visit(Object vertex, Object edge)
   * 	{
   * 		// perform your processing on each cell here
   *		return false;
   *	}
   * });
   * </pre>
   * @param aGraph the graph 
   * @param startVertex
   * @param visitor
   */
  static void bfs(AnalysisGraph aGraph, Object startVertex, ICellVisitor visitor) {
    if (aGraph != null && startVertex != null && visitor != null) {
      Set<Object> queued = new HashSet<Object>();
//      LinkedList<List<Object>> queue = new LinkedList<List<Object>>();
      Queue<List<Object>> queue = new Queue<List<Object>>();
      List<Object> q = [startVertex, null];
      queue.add(q);
      queued.add(startVertex);

      _bfsRec(aGraph, queued, queue, visitor);
    }
  }

  /**
   * Core recursive BFS - for internal use
   * @param aGraph
   * @param queued
   * @param queue
   * @param visitor
   */
  static void _bfsRec(AnalysisGraph aGraph, Set<Object> queued, Queue<List<Object>> queue, ICellVisitor visitor) {
    if (queue.length > 0) {
      List<Object> q = queue.removeFirst();
      Object cell = q[0];
      Object incomingEdge = q[1];

      visitor(cell, incomingEdge);

      final List<Object> edges = aGraph.getEdges(cell, null, false, false);

      for (int i = 0; i < edges.length; i++) {
        List<Object> currEdge = [edges[i]];
        Object opposite = aGraph.getOpposites(currEdge, cell)[0];

        if (!queued.contains(opposite)) {
          List<Object> current = [opposite, edges[i]];
          queue.addLast(current);
          queued.add(opposite);
        }
      }

      _bfsRec(aGraph, queued, queue, visitor);
    }
  }

  /**
   * Implements the Dijkstra's shortest path from startVertex to endVertex.
   * Process on the cell is performing by the visitor class passed in.
   * The visitor has access to the current cell and the edge traversed to
   * find this cell. Every cell is processed once only.
   * <pre>
   * Traversal.dijkstra(analysisGraph, startVertex, endVertex, new ICellVisitor()
   * {
   * 	public bool visit(Object vertex, Object edge)
   * 	{
   * 		// perform your processing on each cell here
   *		return false;
   *	}
   * });
   * </pre>
   * 
   * @param aGraph
   * @param startVertex
   * @param endVertex
   * @param visitor
   * @throws StructuralException - The current Dijkstra algorithm only works for connected graphs
   */
  static void dijkstra(AnalysisGraph aGraph, Object startVertex, Object endVertex, ICellVisitor visitor) //throws StructuralException
  {
    if (!GraphStructure.isConnected(aGraph)) {
      throw new StructuralException("The current Dijkstra algorithm only works for connected graphs and this graph isn't connected");
    }

    Object parent = aGraph.getGraph().getDefaultParent();
    List<Object> vertexes = aGraph.getChildVertices(parent);
    int vertexCount = vertexes.length;
    List<double> distances = new List<double>(vertexCount);
    //		parents[][0] is the traveled vertex
    //		parents[][1] is the traveled outgoing edge
    List<List<Object>> parents = new List<List<Object>>(vertexCount);//[2];
    List<Object> vertexList = new List<Object>();
    List<Object> vertexListStatic = new List<Object>();

    for (int i = 0; i < vertexCount; i++) {
      distances[i] = (1 << 32).toDouble();
      vertexList.add(vertexes[i]);
      vertexListStatic.add(vertexes[i]);
    }

    distances[vertexListStatic.indexOf(startVertex)] = 0.0;
    CostFunction costFunction = aGraph.getGenerator().getCostFunction();
    GraphView view = aGraph.getGraph().getView();

    while (vertexList.length > 0) {
      //find closest vertex
      double minDistance;
      Object currVertex;
      Object closestVertex;
      currVertex = vertexList[0];
      int currIndex = vertexListStatic.indexOf(currVertex);
      double currDistance = distances[currIndex];
      minDistance = currDistance;
      closestVertex = currVertex;

      if (vertexList.length > 1) {
        for (int i = 1; i < vertexList.length; i++) {
          currVertex = vertexList[i];
          currIndex = vertexListStatic.indexOf(currVertex);
          currDistance = distances[currIndex];

          if (currDistance < minDistance) {
            minDistance = currDistance;
            closestVertex = currVertex;
          }
        }
      }

      // we found the closest vertex
      vertexList.remove(closestVertex);

      Object currEdge = new Object();
      List<Object> neighborVertices = aGraph.getOpposites(aGraph.getEdges(closestVertex, null, true, true, false, true), closestVertex, true, true);

      for (int j = 0; j < neighborVertices.length; j++) {
        Object currNeighbor = neighborVertices[j];

        if (vertexList.contains(currNeighbor)) {
          //find edge that connects to the current vertex
          List<Object> neighborEdges = aGraph.getEdges(currNeighbor, null, true, true, false, true);
          Object connectingEdge = null;

          for (int k = 0; k < neighborEdges.length; k++) {
            currEdge = neighborEdges[k];

            if (aGraph.getTerminal(currEdge, true) == closestVertex || aGraph.getTerminal(currEdge, false) == closestVertex) {
              connectingEdge = currEdge;
            }
          }

          // check for new distance
          int neighborIndex = vertexListStatic.indexOf(currNeighbor);
          double oldDistance = distances[neighborIndex];
          double currEdgeWeight;

          currEdgeWeight = costFunction.getCost(new CellState(view, connectingEdge, null));

          double newDistance = minDistance + currEdgeWeight;

          //final part - updating the structure
          if (newDistance < oldDistance) {
            distances[neighborIndex] = newDistance;
            parents[neighborIndex] = [closestVertex, connectingEdge];
          }
        }
      }
    }

    List<List<Object>> resultList = new List<List<Object>>();
    Object currVertex = endVertex;

    while (currVertex != startVertex) {
      int currIndex = vertexListStatic.indexOf(currVertex);
      currVertex = parents[currIndex][0];
      resultList.insert(0, parents[currIndex]);
    }

    resultList.insert(resultList.length, [endVertex, null]);

    for (int i = 0; i < resultList.length; i++) {
      visitor(resultList[i][0], resultList[i][1]);
    }
  }

  /**
   * Implements the Bellman-Ford shortest path from startVertex to all vertices.
   * 
   * @param aGraph
   * @param startVertex
   * @return a List where List(0) is the distance map and List(1) is the parent map. See the example in GraphConfigDialog.java
   * @throws StructuralException - The Bellman-Ford algorithm only works for graphs without negative cycles
   */
  static List<Map<Object, Object>> bellmanFord(AnalysisGraph aGraph, Object startVertex) //throws StructuralException
  {
    Graph graph = aGraph.getGraph();
    List<Object> vertices = aGraph.getChildVertices(graph.getDefaultParent());
    List<Object> edges = aGraph.getChildEdges(graph.getDefaultParent());
    int vertexNum = vertices.length;
    int edgeNum = edges.length;
    Map<Object, Object> distanceMap = new HashMap<Object, Object>();
    Map<Object, Object> parentMap = new HashMap<Object, Object>();
    CostFunction costFunction = aGraph.getGenerator().getCostFunction();
    GraphView view = graph.getView();

    for (int i = 0; i < vertexNum; i++) {
      Object currVertex = vertices[i];
      distanceMap[currVertex] = double.MAX_FINITE;
    }

    distanceMap[startVertex] = 0.0;
    parentMap[startVertex] = startVertex;

    for (int i = 0; i < vertexNum; i++) {
      for (int j = 0; j < edgeNum; j++) {
        Object currEdge = edges[j];
        Object source = aGraph.getTerminal(currEdge, true);
        Object target = aGraph.getTerminal(currEdge, false);

        double dist = (distanceMap[source] as double) + costFunction.getCost(new CellState(view, currEdge, null));

        if (dist < (distanceMap[target] as double)) {
          distanceMap[target] = dist;
          parentMap[target] = source;
        }

        //for undirected graphs, check the reverse direction too
        if (!GraphProperties.isDirected(aGraph.getProperties(), GraphProperties.DEFAULT_DIRECTED)) {
          dist = (distanceMap[target] as double) + costFunction.getCost(new CellState(view, currEdge, null));

          if (dist < (distanceMap[source] as double)) {
            distanceMap[source] = dist;
            parentMap[source] = target;
          }
        }

      }
    }

    for (int i = 0; i < edgeNum; i++) {
      Object currEdge = edges[i];
      Object source = aGraph.getTerminal(currEdge, true);
      Object target = aGraph.getTerminal(currEdge, false);

      double dist = (distanceMap[source] as double) + costFunction.getCost(new CellState(view, currEdge, null));

      if (dist < (distanceMap[target] as double)) {
        throw new StructuralException("The graph contains a negative cycle, so Bellman-Ford can't be completed.");
      }
    }

    List<Map<Object, Object>> result = new List<Map<Object, Object>>();
    result.add(distanceMap);
    result.add(parentMap);

    return result;
  }

  /**
   * Implements the Floyd-Roy-Warshall (aka WFI) shortest path algorithm between all vertices.
   * 
   * @param aGraph
   * @return an ArrayList where ArrayList(0) is the distance map and List(1) is the path map. See the example in GraphConfigDialog.java
   * @throws StructuralException - The Floyd-Roy-Warshall algorithm only works for graphs without negative cycles
   */
  static List<List<List<Object>>> floydRoyWarshall(AnalysisGraph aGraph) //throws StructuralException
  {

    List<Object> vertices = aGraph.getChildVertices(aGraph.getGraph().getDefaultParent());
    List<List<double>> dist = new List<List<double>>(vertices.length);//][vertices.length];
    List<List<Object>> paths = new List<List<Object>>(vertices.length);//][vertices.length];
    for (int k = 0; k < vertices.length; k++) {
      dist[k] = new List<Object>(vertices.length);
      paths[k] = new List<Object>(vertices.length);
    }
    Map<Object, int> indexMap = new HashMap<Object, int>();

    for (int i = 0; i < vertices.length; i++) {
      indexMap[vertices[i]] = i;
    }

    List<Object> edges = aGraph.getChildEdges(aGraph.getGraph().getDefaultParent());
    dist = _initializeWeight(aGraph, vertices, edges, indexMap);

    for (int k = 0; k < vertices.length; k++) {
      for (int i = 0; i < vertices.length; i++) {
        for (int j = 0; j < vertices.length; j++) {
          if (dist[i][j] > dist[i][k] + dist[k][j]) {
            paths[i][j] = GraphStructure.getVertexWithValue(aGraph, k);
            dist[i][j] = dist[i][k] + dist[k][j];
          }
        }
      }
    }

    for (int i = 0; i < dist[0].length; i++) {
      if (dist[i][i] < 0) {
        throw new StructuralException("The graph has negative cycles");
      }
    }

    List<List<List<Object>>> result = new List<List<List<Object>>>();
    result.add(dist);
    result.add(paths);
    return result;
  }

  /**
   * A helper function for the Floyd-Roy-Warshall algorithm - for internal use
   * @param aGraph
   * @param nodes
   * @param edges
   * @param indexMap
   * @return
   */
  static List<List<double>> _initializeWeight(AnalysisGraph aGraph, List<Object> nodes, List<Object> edges, Map<Object, int> indexMap) {
    List<List<double>> weight = new List<List<double>>(nodes.length);//][nodes.length];
//    for (int k = 0; k < nodes.length; k++) {
//      weight[k] = new List<double>(nodes.length);
//    }

    for (int i = 0; i < nodes.length; i++) {
      weight[i] = new List<double>.generate(nodes.length, (int i) => double.MAX_FINITE);
    }

    bool isDirected = GraphProperties.isDirected(aGraph.getProperties(), GraphProperties.DEFAULT_DIRECTED);
    CostFunction costFunction = aGraph.getGenerator().getCostFunction();
    GraphView view = aGraph.getGraph().getView();

    for (Object currEdge in edges) {
      Object source = aGraph.getTerminal(currEdge, true);
      Object target = aGraph.getTerminal(currEdge, false);

      weight[indexMap[source]][indexMap[target]] = costFunction.getCost(view.getState(currEdge));

      if (!isDirected) {
        weight[indexMap[target]][indexMap[source]] = costFunction.getCost(view.getState(currEdge));
      }
    }

    for (int i = 0; i < nodes.length; i++) {
      weight[i][i] = 0.0;
    }

    return weight;
  }

  /**
   * This method helps the user to get the desired data from the result of the Floyd-Roy-Warshall algorithm. 
   * @param aGraph
   * @param FWIresult - the result of the Floyd-Roy-Warhall algorithm
   * @param startVertex
   * @param targetVertex
   * @return returns the shortest path from <b>startVertex</b> to <b>endVertex</b>
   * @throws StructuralException - The Floyd-Roy-Warshall algorithm only works for graphs without negative cycles
   */
  static List<Object> getWFIPath(AnalysisGraph aGraph, List<List<List<Object>>> FWIresult, Object startVertex, Object targetVertex) //throws StructuralException
  {
    List<List<Object>> dist = FWIresult[0];
    List<List<Object>> paths = FWIresult[1];
    List<Object> result = null;

    if (aGraph == null || paths == null || startVertex == null || targetVertex == null) {
      throw new ArgumentError();
    }

    for (int i = 0; i < dist[0].length; i++) {
      if ((dist[i][i] as double) < 0) {
        throw new StructuralException("The graph has negative cycles");
      }
    }

    if (startVertex != targetVertex) {
      CostFunction cf = aGraph.getGenerator().getCostFunction();
      GraphView view = aGraph.getGraph().getView();
      List<Object> currPath = new List<Object>();
      currPath.add(startVertex);

      while (startVertex != targetVertex) {
        result = _getWFIPathRec(aGraph, paths, startVertex, targetVertex, currPath, cf, view);
        startVertex = result[result.length - 1];
      }
    }

    if (result == null) {
      result = new List<Object>();
    }

    return result;
  }

  /**
   * Helper method for getWFIPath - for internal use
   * @param aGraph
   * @param paths
   * @param startVertex
   * @param targetVertex
   * @param currPath
   * @param cf
   * @param view
   * @return
   * @throws StructuralException
   */
  static List<Object> _getWFIPathRec(AnalysisGraph aGraph, List<List<Object>> paths, Object startVertex, Object targetVertex, List<Object> currPath, CostFunction cf, GraphView view) //throws StructuralException
  {
    double sourceIndexD = cf.getCost(view.getState(startVertex));
    List<Object> parents = paths[sourceIndexD.toInt()];
    double targetIndexD = cf.getCost(view.getState(targetVertex));
    int tIndex = targetIndexD.toInt();

    if (parents[tIndex] != null) {
      currPath = _getWFIPathRec(aGraph, paths, startVertex, parents[tIndex], currPath, cf, view);
    } else {
      if (GraphStructure.areConnected(aGraph, startVertex, targetVertex) || startVertex == targetVertex) {
        currPath.add(targetVertex);
      } else {
        throw new StructuralException("The two vertices aren't connected");
      }
    }

    return currPath;
  }
}
