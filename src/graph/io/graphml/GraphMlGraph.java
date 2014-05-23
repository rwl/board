/**
 * $Id: GraphMlGraph.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
package graph.io.graphml;

import graph.model.Cell;
import graph.util.Point2d;
import graph.view.ConnectionConstraint;
import graph.view.Graph;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Represents a Graph element in the GML Structure.
 */
public class GraphMlGraph
{
	/**
	 * Map with the vertex cells added in the addNode method.
	 */
	private static HashMap<String, Object> cellsMap = new HashMap<String, Object>();

	private String id = "";

	private String edgedefault = "";

	private List<GraphMlNode> nodes = new ArrayList<GraphMlNode>();

	private List<GraphMlEdge> edges = new ArrayList<GraphMlEdge>();

	/**
	 * Constructs a graph with id and edge default direction.
	 * @param id Graph's ID
	 * @param edgedefault Edge Default direction.("directed" or "undirected")
	 */
	public GraphMlGraph(String id, String edgedefault)
	{
		this.id = id;
		this.edgedefault = edgedefault;
	}

	/**
	 * Constructs an empty graph.
	 */
	public GraphMlGraph()
	{
	}

	/**
	 * Constructs a graph from a xml graph element.
	 * @param graphElement Xml graph element.
	 */
	public GraphMlGraph(Element graphElement)
	{
		this.id = graphElement.getAttribute(GraphMlConstants.ID);
		this.edgedefault = graphElement
				.getAttribute(GraphMlConstants.EDGE_DEFAULT);

		//Adds node elements
		List<Element> nodeElements = GraphMlUtils.childsTags(graphElement,
				GraphMlConstants.NODE);

		for (Element nodeElem : nodeElements)
		{
			GraphMlNode node = new GraphMlNode(nodeElem);

			nodes.add(node);
		}

		//Adds edge elements
		List<Element> edgeElements = GraphMlUtils.childsTags(graphElement,
				GraphMlConstants.EDGE);

		for (Element edgeElem : edgeElements)
		{
			GraphMlEdge edge = new GraphMlEdge(edgeElem);

			if (edge.getEdgeDirected().equals(""))
			{
				if (edgedefault.equals(GraphMlConstants.EDGE_DIRECTED))
				{
					edge.setEdgeDirected("true");
				}
				else if (edgedefault.equals(GraphMlConstants.EDGE_UNDIRECTED))
				{
					edge.setEdgeDirected("false");
				}
			}

			edges.add(edge);
		}
	}

	/**
	 * Adds the elements represented for this graph model into the given graph.
	 * @param graph Graph where the elements will be located
	 * @param parent Parent of the cells to be added.
	 */
	public void addGraph(Graph graph, Object parent)
	{
		List<GraphMlNode> nodeList = getNodes();

		for (GraphMlNode node : nodeList)
		{
			addNode(graph, parent, node);
		}
		List<GraphMlEdge> edgeList = getEdges();

		for (GraphMlEdge edge : edgeList)
		{
			addEdge(graph, parent, edge);
		}
	}

	/**
	 * Checks if the node has data elements inside.
	 * @param node Gml node element.
	 * @return Returns <code>true</code> if the node has data elements inside.
	 */
	public static boolean hasData(GraphMlNode node)
	{
		boolean ret = false;
		if (node.getNodeDataMap() == null)
		{
			ret = false;
		}
		else
		{
			ret = true;
		}
		return ret;
	}

	/**
	 * Returns the data element inside the node that references to the key element
	 * with name = KEY_NODE_NAME.
	 * @param node Gml Node element.
	 * @return The required data. null if not found.
	 */
	public static GraphMlData dataNodeKey(GraphMlNode node)
	{
		String keyId = "";
		HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance()
				.getKeyMap();
		
		for (GraphMlKey key : keyMap.values())
		{
			if (key.getKeyName().equals(GraphMlConstants.KEY_NODE_NAME))
			{
				keyId = key.getKeyId();
			}
		}

		GraphMlData data = null;
		HashMap<String, GraphMlData> nodeDataMap = node.getNodeDataMap();
		data = nodeDataMap.get(keyId);

		return data;
	}

	/**
	 * Returns the data element inside the edge that references to the key element
	 * with name = KEY_EDGE_NAME.
	 * @param edge Gml Edge element.
	 * @return The required data. null if not found.
	 */
	public static GraphMlData dataEdgeKey(GraphMlEdge edge)
	{
		String keyId = "";
		HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance()
				.getKeyMap();
		for (GraphMlKey key : keyMap.values())
		{
			if (key.getKeyName().equals(GraphMlConstants.KEY_EDGE_NAME))
			{
				keyId = key.getKeyId();
			}
		}

		GraphMlData data = null;
		HashMap<String, GraphMlData> nodeDataMap = edge.getEdgeDataMap();
		data = nodeDataMap.get(keyId);

		return data;
	}

	/**
	 * Adds the vertex represented for the gml node into the graph with the given parent.
	 * @param graph Graph where the vertex will be added.
	 * @param parent Parent's cell.
	 * @param node Gml Node
	 * @return The inserted Vertex cell.
	 */
	private Cell addNode(Graph graph, Object parent, GraphMlNode node)
	{
		Cell v1;
		String id = node.getNodeId();

		GraphMlData data = dataNodeKey(node);

		if (data != null && data.getDataShapeNode() != null)
		{
			Double x = Double.valueOf(data.getDataShapeNode().getDataX());
			Double y = Double.valueOf(data.getDataShapeNode().getDataY());
			Double h = Double.valueOf(data.getDataShapeNode().getDataHeight());
			Double w = Double.valueOf(data.getDataShapeNode().getDataWidth());
			String label = data.getDataShapeNode().getDataLabel();
			String style = data.getDataShapeNode().getDataStyle();
			v1 = (Cell) graph.insertVertex(parent, id, label, x, y, w, h,
					style);
		}
		else
		{
			v1 = (Cell) graph.insertVertex(parent, id, "", 0, 0, 100, 100);
		}

		cellsMap.put(id, v1);
		List<GraphMlGraph> graphs = node.getNodeGraph();

		for (GraphMlGraph gmlGraph : graphs)
		{
			gmlGraph.addGraph(graph, v1);
		}
		return v1;
	}

	/**
	 * Returns the point represented for the port name.
	 * The specials names North, NorthWest, NorthEast, East, West, South, SouthEast and SouthWest.
	 * are accepted. Else, the values acepted follow the pattern "double,double".
	 * where double must be in the range 0..1
	 * @param source Port Name.
	 * @return point that represent the port value.
	 */
	private static Point2d portValue(String source)
	{
		Point2d fromConstraint = null;

		if (source != null && !source.equals(""))
		{

			if (source.equals("North"))
			{
				fromConstraint = new Point2d(0.5, 0);
			}
			else if (source.equals("South"))
			{
				fromConstraint = new Point2d(0.5, 1);

			}
			else if (source.equals("East"))
			{
				fromConstraint = new Point2d(1, 0.5);

			}
			else if (source.equals("West"))
			{
				fromConstraint = new Point2d(0, 0.5);

			}
			else if (source.equals("NorthWest"))
			{
				fromConstraint = new Point2d(0, 0);
			}
			else if (source.equals("SouthWest"))
			{
				fromConstraint = new Point2d(0, 1);
			}
			else if (source.equals("SouthEast"))
			{
				fromConstraint = new Point2d(1, 1);
			}
			else if (source.equals("NorthEast"))
			{
				fromConstraint = new Point2d(1, 0);
			}
			else
			{
				try
				{
					String[] s = source.split(",");
					Double x = Double.valueOf(s[0]);
					Double y = Double.valueOf(s[1]);
					fromConstraint = new Point2d(x, y);
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
		return fromConstraint;
	}

	/**
	 * Adds the edge represented for the gml edge into the graph with the given parent.
	 * @param graph Graph where the vertex will be added.
	 * @param parent Parent's cell.
	 * @param edge Gml Edge
	 * @return The inserted edge cell.
	 */
	private static Cell addEdge(Graph graph, Object parent, GraphMlEdge edge)
	{
		//Get source and target vertex
		Point2d fromConstraint = null;
		Point2d toConstraint = null;
		Object source = cellsMap.get(edge.getEdgeSource());
		Object target = cellsMap.get(edge.getEdgeTarget());
		String sourcePort = edge.getEdgeSourcePort();
		String targetPort = edge.getEdgeTargetPort();

		fromConstraint = portValue(sourcePort);

		toConstraint = portValue(targetPort);

		GraphMlData data = dataEdgeKey(edge);

		String style = "";
		String label = "";

		if (data != null)
		{
			GraphMlShapeEdge shEdge = data.getDataShapeEdge();
			style = shEdge.getStyle();
			label = shEdge.getText();
		}
		else
		{
			style = edge.getEdgeStyle();
		}

		//Insert new edge.
		Cell e = (Cell) graph.insertEdge(parent, null, label, source,
				target, style);
		graph.setConnectionConstraint(e, source, true,
				new ConnectionConstraint(fromConstraint, false));
		graph.setConnectionConstraint(e, target, false,
				new ConnectionConstraint(toConstraint, false));
		return e;
	}

	public String getEdgedefault()
	{
		return edgedefault;
	}

	public void setEdgedefault(String edgedefault)
	{
		this.edgedefault = edgedefault;
	}

	public String getId()
	{
		return id;
	}

	public void setId(String id)
	{
		this.id = id;
	}

	public List<GraphMlNode> getNodes()
	{
		return nodes;
	}

	public void setNodes(List<GraphMlNode> node)
	{
		this.nodes = node;
	}

	public List<GraphMlEdge> getEdges()
	{
		return edges;
	}

	public void setEdges(List<GraphMlEdge> edge)
	{
		this.edges = edge;
	}

	/**
	 * Checks if the graph has child nodes or edges.
	 * @return Returns <code>true</code> if the graph hasn't child nodes or edges.
	 */
	public boolean isEmpty()
	{
		return nodes.size() == 0 && edges.size() == 0;
	}

	/**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element graph = document.createElement(GraphMlConstants.GRAPH);

		if (!id.equals(""))
		{
			graph.setAttribute(GraphMlConstants.ID, id);
		}
		if (!edgedefault.equals(""))
		{
			graph.setAttribute(GraphMlConstants.EDGE_DEFAULT, edgedefault);
		}

		for (GraphMlNode node : nodes)
		{
			Element nodeElement = node.generateElement(document);
			graph.appendChild(nodeElement);
		}

		for (GraphMlEdge edge : edges)
		{
			Element edgeElement = edge.generateElement(document);
			graph.appendChild(edgeElement);
		}

		return graph;
	}
}
