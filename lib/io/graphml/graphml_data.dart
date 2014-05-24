/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.List;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;
//import org.w3c.dom.NodeList;

/**
 * Represents a Data element in the GML Structure.
 */
class GraphMlData
{
	private String _dataId = "";

	private String _dataKey = "";

	private String _dataValue = "";//not using

	private GraphMlShapeNode _dataShapeNode;

	private GraphMlShapeEdge _dataShapeEdge;

	/**
	 * Construct a data with the params values.
	 * @param dataId Data's ID
	 * @param dataKey Reference to a Key Element ID
	 * @param dataValue Value of the data Element
	 * @param dataShapeEdge JGraph specific edge properties.
	 * @param dataShapeNode JGraph specific node properties.
	 */
	GraphMlData(String dataId, String dataKey, String dataValue,
			GraphMlShapeEdge dataShapeEdge, GraphMlShapeNode dataShapeNode)
	{
		this._dataId = dataId;
		this._dataKey = dataKey;
		this._dataValue = dataValue;
		this._dataShapeNode = dataShapeNode;
		this._dataShapeEdge = dataShapeEdge;
	}

	/**
	 * Construct a data from one xml data element.
	 * @param dataElement Xml Data Element.
	 */
	GraphMlData(Element dataElement)
	{
		this._dataId = dataElement.getAttribute(GraphMlConstants.ID);
		this._dataKey = dataElement.getAttribute(GraphMlConstants.KEY);

		this._dataValue = "";

		Element shapeNodeElement = GraphMlUtils.childsTag(dataElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.SHAPENODE);
		Element shapeEdgeElement = GraphMlUtils.childsTag(dataElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.SHAPEEDGE);
		
		if (shapeNodeElement != null)
		{
			this._dataShapeNode = new GraphMlShapeNode(shapeNodeElement);
		}
		else if (shapeEdgeElement != null)
		{
			this._dataShapeEdge = new GraphMlShapeEdge(shapeEdgeElement);
		}
		else
		{
			NodeList childs = dataElement.getChildNodes();
			List<Node> childrens = GraphMlUtils.copyNodeList(childs);
			
			for (Node n : childrens)
			{
				if (n.getNodeName().equals("#text"))
				{

					this._dataValue += n.getNodeValue();
				}
			}
			this._dataValue = this._dataValue.trim();
		}
	}

	/**
	 * Construct an empty data.
	 */
	GraphMlData()
	{
	}

	String getDataId()
	{
		return _dataId;
	}

	void setDataId(String dataId)
	{
		this._dataId = dataId;
	}

	String getDataKey()
	{
		return _dataKey;
	}

	void setDataKey(String dataKey)
	{
		this._dataKey = dataKey;
	}

	String getDataValue()
	{
		return _dataValue;
	}

	void setDataValue(String dataValue)
	{
		this._dataValue = dataValue;
	}

	GraphMlShapeNode getDataShapeNode()
	{
		return _dataShapeNode;
	}

	void setDataShapeNode(GraphMlShapeNode dataShapeNode)
	{
		this._dataShapeNode = dataShapeNode;
	}

	GraphMlShapeEdge getDataShapeEdge()
	{
		return _dataShapeEdge;
	}

	void setDataShapeEdge(GraphMlShapeEdge dataShapeEdge)
	{
		this._dataShapeEdge = dataShapeEdge;
	}

	/**
	 * Generates an Node Data Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	Element generateNodeElement(Document document)
	{
		Element data = document.createElement(GraphMlConstants.DATA);
		data.setAttribute(GraphMlConstants.KEY, _dataKey);

		Element shapeNodeElement = _dataShapeNode.generateElement(document);
		data.appendChild(shapeNodeElement);

		return data;
	}

	/**
	 * Generates an Edge Data Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	Element generateEdgeElement(Document document)
	{
		Element data = document.createElement(GraphMlConstants.DATA);
		data.setAttribute(GraphMlConstants.KEY, _dataKey);

		Element shapeEdgeElement = _dataShapeEdge.generateElement(document);
		data.appendChild(shapeEdgeElement);

		return data;
	}
}
