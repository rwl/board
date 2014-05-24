/**
 * Copyright (c) 2012, JGraph Ltd
 */
part of graph.analysis;

//import graph.costfunction.DoubleValCostFunction;
//import graph.model.IGraphModel;
//import graph.view.Graph;

//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;

/**
 * Implements a collection of utility methods abstracting the graph structure
 * taking into account graph properties such as visible/non-visible traversal
 */
public class AnalysisGraph
{
	// contains various filters, like visibility and direction
	protected Map<String, Object> _properties = new HashMap<String, Object>();

	// contains various data that is used for graph generation and analysis
	protected GraphGenerator _generator;

	protected Graph _graph;

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
	public Object[] getEdges(Object cell, Object parent, boolean incoming, boolean outgoing, boolean includeLoops, boolean recurse)
	{
		if (!GraphProperties.isTraverseVisible(_properties, GraphProperties.DEFAULT_TRAVERSE_VISIBLE))
		{
			return _graph.getEdges(cell, parent, incoming, outgoing, includeLoops, recurse);
		}
		else
		{
			Object[] edges = _graph.getEdges(cell, parent, incoming, outgoing, includeLoops, recurse);
			List<Object> result = new ArrayList<Object>(edges.length);

			IGraphModel model = _graph.getModel();

			for (int i = 0; i < edges.length; i++)
			{
				Object source = model.getTerminal(edges[i], true);
				Object target = model.getTerminal(edges[i], false);

				if (((includeLoops && source == target) || ((source != target) && ((incoming && target == cell) || (outgoing && source == cell))))
						&& model.isVisible(edges[i]))
				{
					result.add(edges[i]);
				}
			}

			return result.toArray();
		}
	};

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
	public Object[] getEdges(Object cell, Object parent, boolean includeLoops, boolean recurse)
	{
		if (GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED))
		{
			return getEdges(cell, parent, false, true, includeLoops, recurse);
		}
		else
		{
			return getEdges(cell, parent, true, true, includeLoops, recurse);
		}
	};

	/**
	 * 
	 * @param parent
	 * @return all vertices of the given <b>parent</b>
	 */
	public Object[] getChildVertices(Object parent)
	{
		return _graph.getChildVertices(parent);
	};

	/**
	 * 
	 * @param parent
	 * @return all edges of the given <b>parent</b>
	 */
	public Object[] getChildEdges(Object parent)
	{
		return _graph.getChildEdges(parent);
	};

	/**
	 * 
	 * @param edge
	 * @param isSource
	 * @return
	 */
	public Object getTerminal(Object edge, boolean isSource)
	{
		return _graph.getModel().getTerminal(edge, isSource);
	};

	public Object[] getChildCells(Object parent, boolean vertices, boolean edges)
	{
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
	public Object[] getOpposites(Object[] edges, Object terminal, boolean sources, boolean targets)
	{
		// TODO needs non-visible graph version

		return _graph.getOpposites(edges, terminal, sources, targets);
	};

	/**
	 * Returns all distinct opposite cells for the specified terminal
	 * on the given edges.
	 * 
	 * @param edges Edges whose opposite terminals should be returned.
	 * @param terminal Terminal that specifies the end whose opposite should be
	 * returned.
	 * @return Returns the cells at the opposite ends of the given edges.
	 */
	public Object[] getOpposites(Object[] edges, Object terminal)
	{
		if (GraphProperties.isDirected(_properties, GraphProperties.DEFAULT_DIRECTED))
		{
			return getOpposites(edges, terminal, false, true);
		}
		else
		{
			return getOpposites(edges, terminal, true, true);
		}
	};

	public Map<String, Object> getProperties()
	{
		return _properties;
	};

	public void setProperties(Map<String, Object> properties)
	{
		this._properties = properties;
	};

	public Graph getGraph()
	{
		return _graph;
	};

	public void setGraph(Graph graph)
	{
		this._graph = graph;
	}

	public GraphGenerator getGenerator()
	{
		if (_generator != null)
		{
			return _generator;
		}
		else
		{
			return new GraphGenerator(null, new DoubleValCostFunction());
		}
	}

	public void setGenerator(GraphGenerator generator)
	{
		this._generator = generator;
	};
};
