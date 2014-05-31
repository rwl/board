/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.HashMap;
//import java.util.List;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Represents a Port element in the GML Structure.
 */
class GraphMlPort {
  String _name;

  HashMap<String, GraphMlData> _portDataMap = new HashMap<String, GraphMlData>();

  /**
	 * Construct a Port with name.
	 * @param name Port Name
	 */
  GraphMlPort(this._name);

  /**
	 * Construct a Port from a xml port Element.
	 * @param portElement Xml port Element.
	 */
  factory GraphMlPort.from(Element portElement) {
    final name = portElement.getAttribute(GraphMlConstants.PORT_NAME);
    final port = new GraphMlPort(name);

    //Add data elements
    List<Element> dataList = GraphMlUtils.childsTags(portElement, GraphMlConstants.DATA);

    for (Element dataElem in dataList) {
      GraphMlData data = new GraphMlData.from(dataElem);
      String key = data.getDataKey();
      _portDataMap[key] = data;
    }
    return port;
  }

  String getName() {
    return _name;
  }

  void setName(String name) {
    this._name = name;
  }

  HashMap<String, GraphMlData> getPortDataMap() {
    return _portDataMap;
  }

  void setPortDataMap(HashMap<String, GraphMlData> nodeDataMap) {
    this._portDataMap = nodeDataMap;
  }

  /**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element node = document.createElement(GraphMlConstants.PORT);

    node.setAttribute(GraphMlConstants.PORT_NAME, _name);

    for (GraphMlData data in _portDataMap.values) {
      Element dataElement = data.generateNodeElement(document);
      node.append(dataElement);
    }

    return node;
  }
}
