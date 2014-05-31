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
 * Represents a Data element in the GML Structure.
 */
class GraphMlNode {
  String _nodeId;

  GraphMlData _nodeData;

  List<GraphMlGraph> _nodeGraphList = new List<GraphMlGraph>();

  HashMap<String, GraphMlData> _nodeDataMap = new HashMap<String, GraphMlData>();

  HashMap<String, GraphMlPort> _nodePortMap = new HashMap<String, GraphMlPort>();

  /**
	 * Construct a node with Id and one data element
	 * @param nodeId Node`s ID
	 * @param nodeData Gml Data.
	 */
  GraphMlNode([String this._nodeId=null, GraphMlData this._nodeData=null]);

  /**
	 * Construct a Node from a xml Node Element.
	 * @param nodeElement Xml Node Element.
	 */
  factory GraphMlNode.from(Element nodeElement) {
    final node = new GraphMlNode();
    node._nodeId = nodeElement.getAttribute(GraphMlConstants.ID);

    //Add data elements
    List<Element> dataList = GraphMlUtils.childsTags(nodeElement, GraphMlConstants.DATA);

    for (Element dataElem in dataList) {
      GraphMlData data = new GraphMlData.from(dataElem);
      String key = data.getDataKey();
      node._nodeDataMap[key] = data;
    }

    //Add graph elements
    List<Element> graphList = GraphMlUtils.childsTags(nodeElement, GraphMlConstants.GRAPH);

    for (Element graphElem in graphList) {
      GraphMlGraph graph = new GraphMlGraph.from(graphElem);
      node._nodeGraphList.add(graph);
    }

    //Add port elements
    List<Element> portList = GraphMlUtils.childsTags(nodeElement, GraphMlConstants.PORT);

    for (Element portElem in portList) {
      GraphMlPort port = new GraphMlPort.from(portElem);
      String name = port.getName();
      node._nodePortMap[name] = port;
    }
    return node;
  }

  String getNodeId() {
    return _nodeId;
  }

  void setNodeId(String nodeId) {
    this._nodeId = nodeId;
  }

  HashMap<String, GraphMlData> getNodeDataMap() {
    return _nodeDataMap;
  }

  void setNodeDataMap(HashMap<String, GraphMlData> nodeDataMap) {
    this._nodeDataMap = nodeDataMap;
  }

  List<GraphMlGraph> getNodeGraph() {
    return _nodeGraphList;
  }

  void setNodeGraph(List<GraphMlGraph> nodeGraph) {
    this._nodeGraphList = nodeGraph;
  }

  HashMap<String, GraphMlPort> getNodePort() {
    return _nodePortMap;
  }

  void setNodePort(HashMap<String, GraphMlPort> nodePort) {
    this._nodePortMap = nodePort;
  }

  /**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element node = document.createElement(GraphMlConstants.NODE);

    node.setAttribute(GraphMlConstants.ID, _nodeId);

    Element dataElement = _nodeData.generateNodeElement(document);
    node.append(dataElement);

    for (GraphMlPort port in _nodePortMap.values) {
      Element portElement = port.generateElement(document);
      node.append(portElement);
    }

    for (GraphMlGraph graph in _nodeGraphList) {
      Element graphElement = graph.generateElement(document);
      node.append(graphElement);
    }

    return node;
  }

  GraphMlData getNodeData() {
    return _nodeData;
  }

  void setNodeData(GraphMlData nodeData) {
    this._nodeData = nodeData;
  }

}
