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
class GraphMlPort
{
	private String _name;

	private HashMap<String, GraphMlData> _portDataMap = new HashMap<String, GraphMlData>();

	/**
	 * Construct a Port with name.
	 * @param name Port Name
	 */
	GraphMlPort(String name)
	{
		this._name = name;
	}

	/**
	 * Construct a Port from a xml port Element.
	 * @param portElement Xml port Element.
	 */
	GraphMlPort(Element portElement)
	{
		this._name = portElement.getAttribute(GraphMlConstants.PORT_NAME);

		//Add data elements
		List<Element> dataList = GraphMlUtils.childsTags(portElement,
				GraphMlConstants.DATA);

		for (Element dataElem : dataList)
		{
			GraphMlData data = new GraphMlData(dataElem);
			String key = data.getDataKey();
			_portDataMap.put(key, data);
		}
	}

	String getName()
	{
		return _name;
	}

	void setName(String name)
	{
		this._name = name;
	}

	HashMap<String, GraphMlData> getPortDataMap()
	{
		return _portDataMap;
	}

	void setPortDataMap(HashMap<String, GraphMlData> nodeDataMap)
	{
		this._portDataMap = nodeDataMap;
	}

	/**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	Element generateElement(Document document)
	{
		Element node = document.createElement(GraphMlConstants.PORT);

		node.setAttribute(GraphMlConstants.PORT_NAME, _name);

		for (GraphMlData data : _portDataMap.values())
		{
			Element dataElement = data.generateNodeElement(document);
			node.appendChild(dataElement);
		}

		return node;
	}
}
