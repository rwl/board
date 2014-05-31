/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.HashMap;
//import java.util.Hashtable;
//import java.util.List;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Represents a Data element in the GML Structure.
 */
class GraphMlEdge {
  String _edgeId;

  String _edgeSource;

  String _edgeSourcePort;

  String _edgeTarget;

  String _edgeTargetPort;

  String _edgeDirected;

  GraphMlData _edgeData;

  /**
	 * Map with the data. The key is the key attribute
	 */
  HashMap<String, GraphMlData> _edgeDataMap = new HashMap<String, GraphMlData>();

  /**
	 * Construct an edge with source and target.
	 * @param edgeSource Source Node's ID.
	 * @param edgeTarget Target Node's ID.
	 */
  GraphMlEdge(this._edgeSource, this_edgeTarget, this._edgeSourcePort, this._edgeTargetPort) {
    this._edgeId = "";
    this._edgeDirected = "";
  }

  /**
	 * Construct an edge from a xml edge element.
	 * @param edgeElement Xml edge element.
	 */
  factory GraphMlEdge.from(Element edgeElement) {
    final edgeSource = edgeElement.getAttribute(GraphMlConstants.EDGE_SOURCE);
    final edgeSourcePort = edgeElement.getAttribute(GraphMlConstants.EDGE_SOURCE_PORT);
    final edgeTarget = edgeElement.getAttribute(GraphMlConstants.EDGE_TARGET);
    final edgeTargetPort = edgeElement.getAttribute(GraphMlConstants.EDGE_TARGET_PORT);
    
    final edge = new GraphMlEdge(edgeSource, edgeTarget, edgeSourcePort, edgeTargetPort);
    
    edge._edgeId = edgeElement.getAttribute(GraphMlConstants.ID);
    edge._edgeDirected = edgeElement.getAttribute(GraphMlConstants.EDGE_DIRECTED);

    List<Element> dataList = GraphMlUtils.childsTags(edgeElement, GraphMlConstants.DATA);

    for (Element dataElem in dataList) {
      GraphMlData data = new GraphMlData.from(dataElem);
      String key = data.getDataKey();
      edge._edgeDataMap[key] = data;
    }
    return edge;
  }

  String getEdgeDirected() {
    return _edgeDirected;
  }

  void setEdgeDirected(String edgeDirected) {
    this._edgeDirected = edgeDirected;
  }

  String getEdgeId() {
    return _edgeId;
  }

  void setEdgeId(String edgeId) {
    this._edgeId = edgeId;
  }

  String getEdgeSource() {
    return _edgeSource;
  }

  void setEdgeSource(String edgeSource) {
    this._edgeSource = edgeSource;
  }

  String getEdgeSourcePort() {
    return _edgeSourcePort;
  }

  void setEdgeSourcePort(String edgeSourcePort) {
    this._edgeSourcePort = edgeSourcePort;
  }

  String getEdgeTarget() {
    return _edgeTarget;
  }

  void setEdgeTarget(String edgeTarget) {
    this._edgeTarget = edgeTarget;
  }

  String getEdgeTargetPort() {
    return _edgeTargetPort;
  }

  void setEdgeTargetPort(String edgeTargetPort) {
    this._edgeTargetPort = edgeTargetPort;
  }

  HashMap<String, GraphMlData> getEdgeDataMap() {
    return _edgeDataMap;
  }

  void setEdgeDataMap(HashMap<String, GraphMlData> nodeEdgeMap) {
    this._edgeDataMap = nodeEdgeMap;
  }

  GraphMlData getEdgeData() {
    return _edgeData;
  }

  void setEdgeData(GraphMlData egdeData) {
    this._edgeData = egdeData;
  }

  /**
	 * Generates a Edge Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element edge = document.createElement(GraphMlConstants.EDGE);

    if (_edgeId != "") {
      edge.setAttribute(GraphMlConstants.ID, _edgeId);
    }
    edge.setAttribute(GraphMlConstants.EDGE_SOURCE, _edgeSource);
    edge.setAttribute(GraphMlConstants.EDGE_TARGET, _edgeTarget);

    if (_edgeSourcePort != "") {
      edge.setAttribute(GraphMlConstants.EDGE_SOURCE_PORT, _edgeSourcePort);
    }

    if (_edgeTargetPort != "") {
      edge.setAttribute(GraphMlConstants.EDGE_TARGET_PORT, _edgeTargetPort);
    }

    if (_edgeDirected != "") {
      edge.setAttribute(GraphMlConstants.EDGE_DIRECTED, _edgeDirected);
    }

    Element dataElement = _edgeData.generateEdgeElement(document);
    edge.append(dataElement);

    return edge;
  }

  /**
	 * Returns if the edge has end arrow.
	 * @return style that indicates the end arrow type(CLASSIC or NONE).
	 */
  String getEdgeStyle() {
    String style = "";
    Map<String, Object> styleMap = new Map<String, Object>();

    //Defines style of the edge.
    if (_edgeDirected == "true") {
      styleMap[Constants.STYLE_ENDARROW] = Constants.ARROW_CLASSIC;

      style = GraphMlUtils.getStyleString(styleMap, "=");
    } else if (_edgeDirected == "false") {
      styleMap[Constants.STYLE_ENDARROW] = Constants.NONE;

      style = GraphMlUtils.getStyleString(styleMap, "=");
    }

    return style;
  }
}
