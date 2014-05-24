/**
 * Copyright (c) 2010-2012, JGraph Ltd
 */
part of graph.io;

//import java.util.HashMap;
//import java.util.List;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;

/**
 * Parses a GraphML .graphml file and imports it in the given graph.<br/>
 * 
 * See wikipedia.org/wiki/GraphML for more on GraphML.
 * 
 * This class depends from the classes contained in
 * graph.io.gmlImplements.
 */
class GraphMlCodec
{
	/**
	 * Receives a GraphMl document and parses it generating a new graph that is inserted in graph.
	 * @param document XML to be parsed
	 * @param graph Graph where the parsed graph is included.
	 */
	static void decode(Document document, Graph graph)
	{
		Object parent = graph.getDefaultParent();

		graph.getModel().beginUpdate();

		// Initialise the key properties.
		GraphMlKeyManager.getInstance().initialise(document);

		NodeList graphs = document.getElementsByTagName(GraphMlConstants.GRAPH);
		if (graphs.getLength() > 0)
		{

			Element graphElement = (Element) graphs.item(0);

			//Create the graph model.
			GraphMlGraph gmlGraph = new GraphMlGraph(graphElement);

			gmlGraph.addGraph(graph, parent);
		}

		graph.getModel().endUpdate();
		_cleanMaps();
	}

	/**
	 * Remove all the elements in the Defined Maps.
	 */
	private static void _cleanMaps()
	{
		GraphMlKeyManager.getInstance().getKeyMap().clear();
	}

	/**
	 * Generates a Xml document with the gmlGraph.
	 * @param gmlGraph Graph model.
	 * @return The Xml document generated.
	 */
	static Document encodeXML(GraphMlGraph gmlGraph)
	{
		Document doc = DomUtils.createDocument();

		Element graphml = doc.createElement(GraphMlConstants.GRAPHML);

		graphml.setAttribute("xmlns", "http://graphml.graphdrawing.org/xmlns");
		graphml.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xsi",
				"http://www.w3.org/2001/XMLSchema-instance");
		graphml.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:jGraph",
				GraphMlConstants.JGRAPH_URL);
		graphml.setAttributeNS(
				"http://www.w3.org/2001/XMLSchema-instance",
				"xsi:schemaLocation",
				"http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd");

		HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance()
				.getKeyMap();

		for (GraphMlKey key : keyMap.values())
		{
			Element keyElement = key.generateElement(doc);
			graphml.appendChild(keyElement);
		}

		Element graphE = gmlGraph.generateElement(doc);
		graphml.appendChild(graphE);

		doc.appendChild(graphml);
		_cleanMaps();
		return doc;

	}

	/**
	 * Generates a Xml document with the cells in the graph.
	 * @param graph Graph with the cells.
	 * @return The Xml document generated.
	 */
	static Document encode(Graph graph)
	{
		GraphMlGraph gmlGraph = new GraphMlGraph();
		Object parent = graph.getDefaultParent();

		_createKeyElements();

		gmlGraph = decodeGraph(graph, parent, gmlGraph);
		gmlGraph.setEdgedefault(GraphMlConstants.EDGE_DIRECTED);

		Document document = encodeXML(gmlGraph);

		return document;
	}

	/**
	 * Creates the key elements for the encode.
	 */
	private static void _createKeyElements()
	{
		HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance()
				.getKeyMap();
		GraphMlKey keyNode = new GraphMlKey(GraphMlConstants.KEY_NODE_ID,
				GraphMlKey.keyForValues.NODE, GraphMlConstants.KEY_NODE_NAME,
				GraphMlKey.keyTypeValues.STRING);
		keyMap.put(GraphMlConstants.KEY_NODE_ID, keyNode);
		GraphMlKey keyEdge = new GraphMlKey(GraphMlConstants.KEY_EDGE_ID,
				GraphMlKey.keyForValues.EDGE, GraphMlConstants.KEY_EDGE_NAME,
				GraphMlKey.keyTypeValues.STRING);
		keyMap.put(GraphMlConstants.KEY_EDGE_ID, keyEdge);
		GraphMlKeyManager.getInstance().setKeyMap(keyMap);
	}

	/**
	 * Returns a Gml graph with the data of the vertexes and edges in the graph.
	 * @param gmlGraph Gml document where the elements are put.
	 * @param parent Parent cell of the vertexes and edges to be added.
	 * @param graph Graph that contains the vertexes and edges.
	 * @return Returns the document with the elements added.
	 */
	static GraphMlGraph decodeGraph(Graph graph, Object parent,
			GraphMlGraph gmlGraph)
	{
		List<Object> vertexes = graph.getChildVertices(parent);
		List<GraphMlEdge> gmlEdges = gmlGraph.getEdges();
		gmlEdges = _encodeEdges(gmlEdges, parent, graph);
		gmlGraph.setEdges(gmlEdges);

		for (Object vertex : vertexes)
		{
			List<GraphMlNode> Gmlnodes = gmlGraph.getNodes();

			Cell v = (Cell) vertex;
			String id = v.getId();

			GraphMlNode gmlNode = new GraphMlNode(id, null);
			addNodeData(gmlNode, v);
			Gmlnodes.add(gmlNode);
			gmlGraph.setNodes(Gmlnodes);
			GraphMlGraph gmlGraphx = new GraphMlGraph();

			gmlGraphx = decodeGraph(graph, vertex, gmlGraphx);

			if (!gmlGraphx.isEmpty())
			{
				List<GraphMlGraph> nodeGraphs = gmlNode.getNodeGraph();
				nodeGraphs.add(gmlGraphx);
				gmlNode.setNodeGraph(nodeGraphs);
			}
		}

		return gmlGraph;
	}

	/**
	 * Add the node data in the gmlNode.
	 * @param gmlNode Gml node where the data add.
	 * @param v Cell where data are obtained.
	 */
	static void addNodeData(GraphMlNode gmlNode, Cell v)
	{
		GraphMlData data = new GraphMlData();
		GraphMlShapeNode dataShapeNode = new GraphMlShapeNode();

		data.setDataKey(GraphMlConstants.KEY_NODE_ID);
		dataShapeNode
				.setDataHeight(String.valueOf(v.getGeometry().getHeight()));
		dataShapeNode.setDataWidth(String.valueOf(v.getGeometry().getWidth()));
		dataShapeNode.setDataX(String.valueOf(v.getGeometry().getX()));
		dataShapeNode.setDataY(String.valueOf(v.getGeometry().getY()));
		dataShapeNode.setDataLabel(v.getValue() != null ? v.getValue()
				.toString() : "");
		dataShapeNode.setDataStyle(v.getStyle() != null ? v.getStyle() : "");

		data.setDataShapeNode(dataShapeNode);
		gmlNode.setNodeData(data);
	}

	/**
	 * Add the edge data in the gmlEdge.
	 * @param gmlEdge Gml edge where the data add.
	 * @param v Cell where data are obtained.
	 */
	static void addEdgeData(GraphMlEdge gmlEdge, Cell v)
	{
		GraphMlData data = new GraphMlData();
		GraphMlShapeEdge dataShapeEdge = new GraphMlShapeEdge();

		data.setDataKey(GraphMlConstants.KEY_EDGE_ID);
		dataShapeEdge.setText(v.getValue() != null ? v.getValue().toString()
				: "");
		dataShapeEdge.setStyle(v.getStyle() != null ? v.getStyle() : "");

		data.setDataShapeEdge(dataShapeEdge);
		gmlEdge.setEdgeData(data);
	}

	/**
	 * Converts a connection point in the string representation of a port.
	 * The specials names North, NorthWest, NorthEast, East, West, South, SouthEast and SouthWest
	 * may be returned. Else, the values returned follows the pattern "double,double"
	 * where double must be in the range 0..1
	 * @param point Point2d
	 * @return Name of the port
	 */
	private static String _pointToPortString(Point2d point)
	{
		String port = "";
		if (point != null)
		{
			double x = point.getX();
			double y = point.getY();

			if (x == 0 && y == 0)
			{
				port = "NorthWest";
			}
			else if (x == 0.5 && y == 0)
			{
				port = "North";
			}
			else if (x == 1 && y == 0)
			{
				port = "NorthEast";
			}
			else if (x == 1 && y == 0.5)
			{
				port = "East";
			}
			else if (x == 1 && y == 1)
			{
				port = "SouthEast";
			}
			else if (x == 0.5 && y == 1)
			{
				port = "South";
			}
			else if (x == 0 && y == 1)
			{
				port = "SouthWest";
			}
			else if (x == 0 && y == 0.5)
			{
				port = "West";
			}
			else
			{
				port = "" + x + "," + y;
			}
		}
		return port;
	}

	/**
	 * Returns a list of mxGmlEdge with the data of the edges in the graph.
	 * @param Gmledges List where the elements are put.
	 * @param parent Parent cell of the edges to be added.
	 * @param graph Graph that contains the edges.
	 * @return Returns the list Gmledges with the elements added.
	 */
	private static List<GraphMlEdge> _encodeEdges(List<GraphMlEdge> Gmledges,
			Object parent, Graph graph)
	{
		List<Object> edges = graph.getChildEdges(parent);
		for (Object edge : edges)
		{
			Cell e = (Cell) edge;
			Cell source = (Cell) e.getSource();
			Cell target = (Cell) e.getTarget();

			String sourceName = "";
			String targetName = "";
			String sourcePort = "";
			String targetPort = "";
			sourceName = source != null ? source.getId() : "";
			targetName = target != null ? target.getId() : "";

			//Get the graph view that contains the states
			GraphView view = graph.getView();
			Point2d sourceConstraint = null;
			Point2d targetConstraint = null;
			if (view != null)
			{
				CellState edgeState = view.getState(edge);
				CellState sourceState = view.getState(source);
				ConnectionConstraint scc = graph.getConnectionConstraint(
						edgeState, sourceState, true);
				if (scc != null)
				{
					sourceConstraint = scc.getPoint();
				}

				CellState targetState = view.getState(target);
				ConnectionConstraint tcc = graph.getConnectionConstraint(
						edgeState, targetState, false);
				if (tcc != null)
				{
					targetConstraint = tcc.getPoint();
				}
			}

			//gets the port names
			targetPort = _pointToPortString(targetConstraint);
			sourcePort = _pointToPortString(sourceConstraint);

			GraphMlEdge Gmledge = new GraphMlEdge(sourceName, targetName,
					sourcePort, targetPort);

			String style = e.getStyle();

			if (style == null)
			{
				style = "horizontal";

			}

			HashMap<String, Object> styleMap = GraphMlUtils.getStyleMap(style,
					"=");
			String endArrow = (String) styleMap.get(Constants.STYLE_ENDARROW);
			if ((endArrow != null && !endArrow.equals(Constants.NONE))
					|| endArrow == null)
			{
				Gmledge.setEdgeDirected("true");
			}
			else
			{
				Gmledge.setEdgeDirected("false");
			}
			addEdgeData(Gmledge, e);
			Gmledges.add(Gmledge);
		}

		return Gmledges;
	}
}
