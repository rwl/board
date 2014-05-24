/**
 * Copyright (c) 2011-2012, JGraph Ltd
 */
part of graph.analysis;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.HashMap;
//import java.util.HashSet;
//import java.util.LinkedList;
//import java.util.List;
//import java.util.Map;
//import java.util.Set;

/**
 * Implements a collection of utility methods for traversing the
 * graph structure. This does not include tree traversal methods.
 */
class Traversal
{

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
	static void dfs(AnalysisGraph aGraph, Object startVertex, ICellVisitor visitor)
	{
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
	private static void _dfsRec(AnalysisGraph aGraph, Object cell, Object edge, Set<Object> seen, ICellVisitor visitor)
	{
		if (cell != null)
		{
			if (!seen.contains(cell))
			{
				visitor.visit(cell, edge);
				seen.add(cell);

				final List<Object> edges = aGraph.getEdges(cell, null, false, true);
				final List<Object> opposites = aGraph.getOpposites(edges, cell);

				for (int i = 0; i < opposites.length; i++)
				{
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
	static void bfs(AnalysisGraph aGraph, Object startVertex, ICellVisitor visitor)
	{
		if (aGraph != null && startVertex != null && visitor != null)
		{
			Set<Object> queued = new HashSet<Object>();
			LinkedList<List<Object>> queue = new LinkedList<List<Object>>();
			List<Object> q = { startVertex, null };
			queue.addLast(q);
			queued.add(startVertex);

			_bfsRec(aGraph, queued, queue, visitor);
		}
	};

	/**
	 * Core recursive BFS - for internal use
	 * @param aGraph
	 * @param queued
	 * @param queue
	 * @param visitor
	 */
	private static void _bfsRec(AnalysisGraph aGraph, Set<Object> queued, LinkedList<List<Object>> queue, ICellVisitor visitor)
	{
		if (queue.size() > 0)
		{
			List<Object> q = queue.removeFirst();
			Object cell = q[0];
			Object incomingEdge = q[1];

			visitor.visit(cell, incomingEdge);

			final List<Object> edges = aGraph.getEdges(cell, null, false, false);

			for (int i = 0; i < edges.length; i++)
			{
				List<Object> currEdge = { edges[i] };
				Object opposite = aGraph.getOpposites(currEdge, cell)[0];

				if (!queued.contains(opposite))
				{
					List<Object> current = { opposite, edges[i] };
					queue.addLast(current);
					queued.add(opposite);
				}
			}

			_bfsRec(aGraph, queued, queue, visitor);
		}
	};

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
	static void dijkstra(AnalysisGraph aGraph, Object startVertex, Object endVertex, ICellVisitor visitor)
			throws StructuralException
	{
		if (!GraphStructure.isConnected(aGraph))
		{
			throw new StructuralException("The current Dijkstra algorithm only works for connected graphs and this graph isn't connected");
		}

		Object parent = aGraph.getGraph().getDefaultParent();
		List<Object> vertexes = aGraph.getChildVertices(parent);
		int vertexCount = vertexes.length;
		double[] distances = new double[vertexCount];
		//		parents[][0] is the traveled vertex
		//		parents[][1] is the traveled outgoing edge
		List<Object>[] parents = new Object[vertexCount][2];
		ArrayList<Object> vertexList = new List<Object>();
		ArrayList<Object> vertexListStatic = new List<Object>();

		for (int i = 0; i < vertexCount; i++)
		{
			distances[i] = Integer.MAX_VALUE;
			vertexList.add((Object) vertexes[i]);
			vertexListStatic.add((Object) vertexes[i]);
		}

		distances[vertexListStatic.indexOf(startVertex)] = 0;
		CostFunction costFunction = aGraph.getGenerator().getCostFunction();
		GraphView view = aGraph.getGraph().getView();

		while (vertexList.size() > 0)
		{
			//find closest vertex
			double minDistance;
			Object currVertex;
			Object closestVertex;
			currVertex = vertexList.get(0);
			int currIndex = vertexListStatic.indexOf(currVertex);
			double currDistance = distances[currIndex];
			minDistance = currDistance;
			closestVertex = currVertex;

			if (vertexList.size() > 1)
			{
				for (int i = 1; i < vertexList.size(); i++)
				{
					currVertex = vertexList.get(i);
					currIndex = vertexListStatic.indexOf(currVertex);
					currDistance = distances[currIndex];

					if (currDistance < minDistance)
					{
						minDistance = currDistance;
						closestVertex = currVertex;
					}
				}
			}

			// we found the closest vertex
			vertexList.remove(closestVertex);

			Object currEdge = new Object();
			List<Object> neighborVertices = aGraph.getOpposites(aGraph.getEdges(closestVertex, null, true, true, false, true), closestVertex,
					true, true);

			for (int j = 0; j < neighborVertices.length; j++)
			{
				Object currNeighbor = neighborVertices[j];

				if (vertexList.contains(currNeighbor))
				{
					//find edge that connects to the current vertex
					List<Object> neighborEdges = aGraph.getEdges(currNeighbor, null, true, true, false, true);
					Object connectingEdge = null;

					for (int k = 0; k < neighborEdges.length; k++)
					{
						currEdge = neighborEdges[k];

						if (aGraph.getTerminal(currEdge, true).equals(closestVertex)
								|| aGraph.getTerminal(currEdge, false).equals(closestVertex))
						{
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
					if (newDistance < oldDistance)
					{
						distances[neighborIndex] = newDistance;
						parents[neighborIndex][0] = closestVertex;
						parents[neighborIndex][1] = connectingEdge;
					}
				}
			}
		}

		ArrayList<List<Object>> resultList = new List<List<Object>>();
		Object currVertex = endVertex;

		while (currVertex != startVertex)
		{
			int currIndex = vertexListStatic.indexOf(currVertex);
			currVertex = parents[currIndex][0];
			resultList.add(0, parents[currIndex]);
		}

		resultList.add(resultList.size(), new List<Object> { endVertex, null });

		for (int i = 0; i < resultList.size(); i++)
		{
			visitor.visit(resultList.get(i)[0], resultList.get(i)[1]);
		}
	};

	/**
	 * Implements the Bellman-Ford shortest path from startVertex to all vertices.
	 * 
	 * @param aGraph
	 * @param startVertex
	 * @return a List where List(0) is the distance map and List(1) is the parent map. See the example in GraphConfigDialog.java
	 * @throws StructuralException - The Bellman-Ford algorithm only works for graphs without negative cycles
	 */
	static List<Map<Object, Object>> bellmanFord(AnalysisGraph aGraph, Object startVertex) throws StructuralException
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

		for (int i = 0; i < vertexNum; i++)
		{
			Object currVertex = vertices[i];
			distanceMap.put(currVertex, Double.MAX_VALUE);
		}

		distanceMap.put(startVertex, 0.0);
		parentMap.put(startVertex, startVertex);

		for (int i = 0; i < vertexNum; i++)
		{
			for (int j = 0; j < edgeNum; j++)
			{
				Object currEdge = edges[j];
				Object source = aGraph.getTerminal(currEdge, true);
				Object target = aGraph.getTerminal(currEdge, false);

				double dist = (Double) distanceMap.get(source) + costFunction.getCost(new CellState(view, currEdge, null));

				if (dist < (Double) distanceMap.get(target))
				{
					distanceMap.put(target, dist);
					parentMap.put(target, source);
				}

				//for undirected graphs, check the reverse direction too
				if (!GraphProperties.isDirected(aGraph.getProperties(), GraphProperties.DEFAULT_DIRECTED))
				{
					dist = (Double) distanceMap.get(target) + costFunction.getCost(new CellState(view, currEdge, null));

					if (dist < (Double) distanceMap.get(source))
					{
						distanceMap.put(source, dist);
						parentMap.put(source, target);
					}
				}

			}
		}

		for (int i = 0; i < edgeNum; i++)
		{
			Object currEdge = edges[i];
			Object source = aGraph.getTerminal(currEdge, true);
			Object target = aGraph.getTerminal(currEdge, false);

			double dist = (Double) distanceMap.get(source) + costFunction.getCost(new CellState(view, currEdge, null));

			if (dist < (Double) distanceMap.get(target))
			{
				throw new StructuralException("The graph contains a negative cycle, so Bellman-Ford can't be completed.");
			}
		}

		List<Map<Object, Object>> result = new List<Map<Object, Object>>();
		result.add(distanceMap);
		result.add(parentMap);

		return result;
	};

	/**
	 * Implements the Floyd-Roy-Warshall (aka WFI) shortest path algorithm between all vertices.
	 * 
	 * @param aGraph
	 * @return an ArrayList where ArrayList(0) is the distance map and List(1) is the path map. See the example in GraphConfigDialog.java
	 * @throws StructuralException - The Floyd-Roy-Warshall algorithm only works for graphs without negative cycles
	 */
	static ArrayList<List<Object>[]> floydRoyWarshall(AnalysisGraph aGraph) throws StructuralException
	{

		List<Object> vertices = aGraph.getChildVertices(aGraph.getGraph().getDefaultParent());
		Double[][] dist = new Double[vertices.length][vertices.length];
		List<Object>[] paths = new Object[vertices.length][vertices.length];
		Map<Object, Integer> indexMap = new HashMap<Object, Integer>();

		for (int i = 0; i < vertices.length; i++)
		{
			indexMap.put(vertices[i], i);
		}

		List<Object> edges = aGraph.getChildEdges(aGraph.getGraph().getDefaultParent());
		dist = _initializeWeight(aGraph, vertices, edges, indexMap);

		for (int k = 0; k < vertices.length; k++)
		{
			for (int i = 0; i < vertices.length; i++)
			{
				for (int j = 0; j < vertices.length; j++)
				{
					if (dist[i][j] > dist[i][k] + dist[k][j])
					{
						paths[i][j] = GraphStructure.getVertexWithValue(aGraph, k);
						dist[i][j] = dist[i][k] + dist[k][j];
					}
				}
			}
		}

		for (int i = 0; i < dist[0].length; i++)
		{
			if ((Double) dist[i][i] < 0)
			{
				throw new StructuralException("The graph has negative cycles");
			}
		}

		ArrayList<List<Object>[]> result = new List<List<Object>[]>();
		result.add(dist);
		result.add(paths);
		return result;
	};

	/**
	 * A helper function for the Floyd-Roy-Warshall algorithm - for internal use
	 * @param aGraph
	 * @param nodes
	 * @param edges
	 * @param indexMap
	 * @return
	 */
	private static Double[][] _initializeWeight(AnalysisGraph aGraph, List<Object> nodes, List<Object> edges, Map<Object, Integer> indexMap)
	{
		Double[][] weight = new Double[nodes.length][nodes.length];

		for (int i = 0; i < nodes.length; i++)
		{
			Arrays.fill(weight[i], Double.MAX_VALUE);
		}

		bool isDirected = GraphProperties.isDirected(aGraph.getProperties(), GraphProperties.DEFAULT_DIRECTED);
		CostFunction costFunction = aGraph.getGenerator().getCostFunction();
		GraphView view = aGraph.getGraph().getView();

		for (Object currEdge : edges)
		{
			Object source = aGraph.getTerminal(currEdge, true);
			Object target = aGraph.getTerminal(currEdge, false);

			weight[indexMap.get(source)][indexMap.get(target)] = costFunction.getCost(view.getState(currEdge));

			if (!isDirected)
			{
				weight[indexMap.get(target)][indexMap.get(source)] = costFunction.getCost(view.getState(currEdge));
			}
		}

		for (int i = 0; i < nodes.length; i++)
		{
			weight[i][i] = 0.0;
		}

		return weight;
	};

	/**
	 * This method helps the user to get the desired data from the result of the Floyd-Roy-Warshall algorithm. 
	 * @param aGraph
	 * @param FWIresult - the result of the Floyd-Roy-Warhall algorithm
	 * @param startVertex
	 * @param targetVertex
	 * @return returns the shortest path from <b>startVertex</b> to <b>endVertex</b>
	 * @throws StructuralException - The Floyd-Roy-Warshall algorithm only works for graphs without negative cycles
	 */
	static List<Object> getWFIPath(AnalysisGraph aGraph, ArrayList<List<Object>[]> FWIresult, Object startVertex, Object targetVertex)
			throws StructuralException
	{
		List<Object>[] dist = FWIresult.get(0);
		List<Object>[] paths = FWIresult.get(1);
		ArrayList<Object> result = null;

		if (aGraph == null || paths == null || startVertex == null || targetVertex == null)
		{
			throw new IllegalArgumentException();
		}

		for (int i = 0; i < dist[0].length; i++)
		{
			if ((Double) dist[i][i] < 0)
			{
				throw new StructuralException("The graph has negative cycles");
			}
		}

		if (startVertex != targetVertex)
		{
			CostFunction cf = aGraph.getGenerator().getCostFunction();
			GraphView view = aGraph.getGraph().getView();
			ArrayList<Object> currPath = new List<Object>();
			currPath.add(startVertex);

			while (startVertex != targetVertex)
			{
				result = _getWFIPathRec(aGraph, paths, startVertex, targetVertex, currPath, cf, view);
				startVertex = result.get(result.size() - 1);
			}
		}

		if (result == null)
		{
			result = new List<Object>();
		}

		return result.toArray();
	};

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
	private static ArrayList<Object> _getWFIPathRec(AnalysisGraph aGraph, List<Object>[] paths, Object startVertex, Object targetVertex,
			ArrayList<Object> currPath, CostFunction cf, GraphView view) throws StructuralException
	{
		Double sourceIndexD = (Double) cf.getCost(view.getState(startVertex));
		List<Object> parents = paths[sourceIndexD.intValue()];
		Double targetIndexD = (Double) cf.getCost(view.getState(targetVertex));
		int tIndex = targetIndexD.intValue();

		if (parents[tIndex] != null)
		{
			currPath = _getWFIPathRec(aGraph, paths, startVertex, parents[tIndex], currPath, cf, view);
		}
		else
		{
			if (GraphStructure.areConnected(aGraph, startVertex, targetVertex) || startVertex == targetVertex)
			{
				currPath.add(targetVertex);
			}
			else
			{
				throw new StructuralException("The two vertices aren't connected");
			}
		}

		return currPath;
	}
};
