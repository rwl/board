/**
 * Copyright (c) 2012, JGraph Ltd
 */
part of graph.analysis;


/**
 * Implements a collection of utility methods abstracting the graph structure
 * taking into account graph properties such as visible/non-visible traversal
 */
class AnalysisGraph {
  // contains various filters, like visibility and direction
  Map<String, Object> _properties = new HashMap<String, Object>();

  // contains various data that is used for graph generation and analysis
  GraphGenerator _generator;

  Graph _graph;

  /**
   * Returns the incoming and/or outgoing edges for the given cell.
   * If the optional parent argument is specified, then only edges are returned
   * where the opposite is in the given parent cell.
   *
   * @param cell Cell whose edges should be returned.
   * @param parent Optional parent. If specified the opposite end of any edge
   * must be a child of that parent in order for the edge to be returned. The
   * recurse parameter specifies whether or not it must be the direct child
   * or the parent just be an ancestral parent.
   * @param incoming Specifies if incoming edges should be included in the
   * result.
   * @param outgoing Specifies if outgoing edges should be included in the
   * result.
   * @param includeLoops Specifies if loops should be included in the result.
   * @param recurse Specifies if the parent specified only need be an ancestral
   * parent, <code>true</code>, or the direct parent, <code>false</code>
   * @return Returns the edges connected to the given cell.
   */
  List<Object> getEdges(Object cell, Object parent, [bool incoming = null, bool outgoing = true, bool includeLoops = null, bool recurse = null]) {
    if (incoming == null) {
      incoming = !GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED);
    }
    if (!GraphProperties.isTraverseVisible(_properties, GraphProperties.DEFAULT_TRAVERSE_VISIBLE)) {
      return _graph.getEdges(cell, parent, incoming, outgoing, includeLoops, recurse);
    } else {
      List<Object> edges = _graph.getEdges(cell, parent, incoming, outgoing, includeLoops, recurse);
      List<Object> result = new List<Object>(edges.length);

      IGraphModel model = _graph.getModel();

      for (int i = 0; i < edges.length; i++) {
        Object source = model.getTerminal(edges[i], true);
        Object target = model.getTerminal(edges[i], false);

        if (((includeLoops && source == target) || ((source != target) && ((incoming && target == cell) || (outgoing && source == cell)))) && model.isVisible(edges[i])) {
          result.add(edges[i]);
        }
      }

      return result;
    }
  }

  /**
   * Returns the incoming and/or outgoing edges for the given cell.
   * If the optional parent argument is specified, then only edges are returned
   * where the opposite is in the given parent cell.
   *
   * @param cell Cell whose edges should be returned.
   * @param parent Optional parent. If specified the opposite end of any edge
   * must be a child of that parent in order for the edge to be returned. The
   * recurse parameter specifies whether or not it must be the direct child
   * or the parent just be an ancestral parent.
   * @param includeLoops Specifies if loops should be included in the result.
   * @param recurse Specifies if the parent specified only need be an ancestral
   * parent, <code>true</code>, or the direct parent, <code>false</code>
   * @return Returns the edges connected to the given cell.
   */
  /*List<Object> getEdges(Object cell, Object parent, bool includeLoops, bool recurse)
	{
		if (GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED))
		{
			return getEdges(cell, parent, false, true, includeLoops, recurse);
		}
		else
		{
			return getEdges(cell, parent, true, true, includeLoops, recurse);
		}
	}*/

  /**
   * Returns all vertices of the given <b>parent</b>
   */
  List<Object> getChildVertices(Object parent) {
    return _graph.getChildVertices(parent);
  }

  /**
   * Returns all edges of the given <b>parent</b>
   */
  List<Object> getChildEdges(Object parent) {
    return _graph.getChildEdges(parent);
  }

  Object getTerminal(Object edge, bool isSource) {
    return _graph.getModel().getTerminal(edge, isSource);
  }

  List<Object> getChildCells(Object parent, bool vertices, bool edges) {
    return _graph.getChildCells(parent, vertices, edges);
  }

  /**
   * Returns all distinct opposite cells for the specified terminal
   * on the given edges.
   *
   * @param edges Edges whose opposite terminals should be returned.
   * @param terminal Terminal that specifies the end whose opposite should be
   * returned.
   * @param sources Specifies if source terminals should be included in the
   * result.
   * @param targets Specifies if target terminals should be included in the
   * result.
   * @return Returns the cells at the opposite ends of the given edges.
   */
  List<Object> getOpposites(List<Object> edges, Object terminal, [bool sources = null, bool targets = true]) {
    if (sources == null) {
      sources = !GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED);
    }
    // TODO needs non-visible graph version

    return _graph.getOpposites(edges, terminal, sources, targets);
  }

  /**
   * Returns all distinct opposite cells for the specified terminal
   * on the given edges.
   *
   * @param edges Edges whose opposite terminals should be returned.
   * @param terminal Terminal that specifies the end whose opposite should be
   * returned.
   * @return Returns the cells at the opposite ends of the given edges.
   */
  /*List<Object> getOpposites(List<Object> edges, Object terminal)
	{
		if (GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED))
		{
			return getOpposites(edges, terminal, false, true);
		}
		else
		{
			return getOpposites(edges, terminal, true, true);
		}
	}*/

  Map<String, Object> getProperties() {
    return _properties;
  }

  void setProperties(Map<String, Object> properties) {
    this._properties = properties;
  }

  Graph getGraph() {
    return _graph;
  }

  void setGraph(Graph graph) {
    this._graph = graph;
  }

  GraphGenerator getGenerator() {
    if (_generator != null) {
      return _generator;
    } else {
      return new GraphGenerator(null, new DoubleValCostFunction());
    }
  }

  void setGenerator(GraphGenerator generator) {
    this._generator = generator;
  }
}
