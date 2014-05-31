/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Represents a Graph element in the GML Structure.
 */
class GraphMlGraph {
  /**
	 * Map with the vertex cells added in the addNode method.
	 */
  static HashMap<String, Object> _cellsMap = new HashMap<String, Object>();

  String _id = "";

  String _edgedefault = "";

  List<GraphMlNode> _nodes = new List<GraphMlNode>();

  List<GraphMlEdge> _edges = new List<GraphMlEdge>();

  /**
	 * Constructs a graph with id and edge default direction.
	 * @param id Graph's ID
	 * @param edgedefault Edge Default direction.("directed" or "undirected")
	 */
  GraphMlGraph([this._id="", this._edgedefault=""]);

  /**
	 * Constructs an empty graph.
	 */
//  GraphMlGraph() {
//  }

  /**
	 * Constructs a graph from a xml graph element.
	 * @param graphElement Xml graph element.
	 */
  factory GraphMlGraph.from(Element graphElement) {
    final id = graphElement.getAttribute(GraphMlConstants.ID);
    final edgedefault = graphElement.getAttribute(GraphMlConstants.EDGE_DEFAULT);
    final graph = new GraphMlGraph(id, edgedefault);

    //Adds node elements
    List<Element> nodeElements = GraphMlUtils.childsTags(graphElement, GraphMlConstants.NODE);

    for (Element nodeElem in nodeElements) {
      GraphMlNode node = new GraphMlNode.from(nodeElem);

      graph._nodes.add(node);
    }

    //Adds edge elements
    List<Element> edgeElements = GraphMlUtils.childsTags(graphElement, GraphMlConstants.EDGE);

    for (Element edgeElem in edgeElements) {
      GraphMlEdge edge = new GraphMlEdge.from(edgeElem);

      if (edge.getEdgeDirected() == "") {
        if (_edgedefault == GraphMlConstants.EDGE_DIRECTED) {
          edge.setEdgeDirected("true");
        } else if (_edgedefault == GraphMlConstants.EDGE_UNDIRECTED) {
          edge.setEdgeDirected("false");
        }
      }

      graph._edges.add(edge);
    }
    return graph;
  }

  /**
	 * Adds the elements represented for this graph model into the given graph.
	 * @param graph Graph where the elements will be located
	 * @param parent Parent of the cells to be added.
	 */
  void addGraph(Graph graph, Object parent) {
    List<GraphMlNode> nodeList = getNodes();

    for (GraphMlNode node in nodeList) {
      _addNode(graph, parent, node);
    }
    List<GraphMlEdge> edgeList = getEdges();

    for (GraphMlEdge edge in edgeList) {
      _addEdge(graph, parent, edge);
    }
  }

  /**
	 * Checks if the node has data elements inside.
	 * @param node Gml node element.
	 * @return Returns <code>true</code> if the node has data elements inside.
	 */
  static bool hasData(GraphMlNode node) {
    bool ret = false;
    if (node.getNodeDataMap() == null) {
      ret = false;
    } else {
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
  static GraphMlData dataNodeKey(GraphMlNode node) {
    String keyId = "";
    HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance().getKeyMap();

    for (GraphMlKey key in keyMap.values) {
      if (key.getKeyName() == GraphMlConstants.KEY_NODE_NAME) {
        keyId = key.getKeyId();
      }
    }

    GraphMlData data = null;
    HashMap<String, GraphMlData> nodeDataMap = node.getNodeDataMap();
    data = nodeDataMap[keyId];

    return data;
  }

  /**
	 * Returns the data element inside the edge that references to the key element
	 * with name = KEY_EDGE_NAME.
	 * @param edge Gml Edge element.
	 * @return The required data. null if not found.
	 */
  static GraphMlData dataEdgeKey(GraphMlEdge edge) {
    String keyId = "";
    HashMap<String, GraphMlKey> keyMap = GraphMlKeyManager.getInstance().getKeyMap();
    for (GraphMlKey key in keyMap.values) {
      if (key.getKeyName() == GraphMlConstants.KEY_EDGE_NAME) {
        keyId = key.getKeyId();
      }
    }

    GraphMlData data = null;
    HashMap<String, GraphMlData> nodeDataMap = edge.getEdgeDataMap();
    data = nodeDataMap[keyId];

    return data;
  }

  /**
	 * Adds the vertex represented for the gml node into the graph with the given parent.
	 * @param graph Graph where the vertex will be added.
	 * @param parent Parent's cell.
	 * @param node Gml Node
	 * @return The inserted Vertex cell.
	 */
  Cell _addNode(Graph graph, Object parent, GraphMlNode node) {
    Cell v1;
    String id = node.getNodeId();

    GraphMlData data = dataNodeKey(node);

    if (data != null && data.getDataShapeNode() != null) {
      double x = double.parse(data.getDataShapeNode().getDataX());
      double y = double.parse(data.getDataShapeNode().getDataY());
      double h = double.parse(data.getDataShapeNode().getDataHeight());
      double w = double.parse(data.getDataShapeNode().getDataWidth());
      String label = data.getDataShapeNode().getDataLabel();
      String style = data.getDataShapeNode().getDataStyle();
      v1 = graph.insertVertex(parent, id, label, x, y, w, h, style) as Cell;
    } else {
      v1 = graph.insertVertex(parent, id, "", 0.0, 0.0, 100.0, 100.0) as Cell;
    }

    _cellsMap[id] = v1;
    List<GraphMlGraph> graphs = node.getNodeGraph();

    for (GraphMlGraph gmlGraph in graphs) {
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
  static Point2d _portValue(String source) {
    Point2d fromConstraint = null;

    if (source != null && source != "") {

      if (source == "North") {
        fromConstraint = new Point2d(0.5, 0.0);
      } else if (source == "South") {
        fromConstraint = new Point2d(0.5, 10.0);

      } else if (source == "East") {
        fromConstraint = new Point2d(1.0, 0.5);

      } else if (source == "West") {
        fromConstraint = new Point2d(00.0, 0.5);

      } else if (source == "NorthWest") {
        fromConstraint = new Point2d(0.0, 0.0);
      } else if (source == "SouthWest") {
        fromConstraint = new Point2d(0.0, 1.0);
      } else if (source == "SouthEast") {
        fromConstraint = new Point2d(1.0, 1.0);
      } else if (source == "NorthEast") {
        fromConstraint = new Point2d(1.0, 0.0);
      } else {
        try {
          List<String> s = source.split(",");
          double x = double.parse(s[0]);
          double y = double.parse(s[1]);
          fromConstraint = new Point2d(x, y);
        } on Exception catch (e) {
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
  static Cell _addEdge(Graph graph, Object parent, GraphMlEdge edge) {
    //Get source and target vertex
    Point2d fromConstraint = null;
    Point2d toConstraint = null;
    Object source = _cellsMap[edge.getEdgeSource()];
    Object target = _cellsMap[edge.getEdgeTarget()];
    String sourcePort = edge.getEdgeSourcePort();
    String targetPort = edge.getEdgeTargetPort();

    fromConstraint = _portValue(sourcePort);

    toConstraint = _portValue(targetPort);

    GraphMlData data = dataEdgeKey(edge);

    String style = "";
    String label = "";

    if (data != null) {
      GraphMlShapeEdge shEdge = data.getDataShapeEdge();
      style = shEdge.getStyle();
      label = shEdge.getText();
    } else {
      style = edge.getEdgeStyle();
    }

    //Insert new edge.
    Cell e = graph.insertEdge(parent, null, label, source, target, style) as Cell;
    graph.setConnectionConstraint(e, source, true, new ConnectionConstraint(fromConstraint, false));
    graph.setConnectionConstraint(e, target, false, new ConnectionConstraint(toConstraint, false));
    return e;
  }

  String getEdgedefault() {
    return _edgedefault;
  }

  void setEdgedefault(String edgedefault) {
    this._edgedefault = edgedefault;
  }

  String getId() {
    return _id;
  }

  void setId(String id) {
    this._id = id;
  }

  List<GraphMlNode> getNodes() {
    return _nodes;
  }

  void setNodes(List<GraphMlNode> node) {
    this._nodes = node;
  }

  List<GraphMlEdge> getEdges() {
    return _edges;
  }

  void setEdges(List<GraphMlEdge> edge) {
    this._edges = edge;
  }

  /**
	 * Checks if the graph has child nodes or edges.
	 * @return Returns <code>true</code> if the graph hasn't child nodes or edges.
	 */
  bool isEmpty() {
    return _nodes.length == 0 && _edges.length == 0;
  }

  /**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element graph = document.createElement(GraphMlConstants.GRAPH);

    if (_id != "") {
      graph.setAttribute(GraphMlConstants.ID, _id);
    }
    if (_edgedefault !="") {
      graph.setAttribute(GraphMlConstants.EDGE_DEFAULT, _edgedefault);
    }

    for (GraphMlNode node in _nodes) {
      Element nodeElement = node.generateElement(document);
      graph.append(nodeElement);
    }

    for (GraphMlEdge edge in _edges) {
      Element edgeElement = edge.generateElement(document);
      graph.append(edgeElement);
    }

    return graph;
  }
}
