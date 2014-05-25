/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

class GraphMlShapeNode
{
	String _dataHeight = "";

	String _dataWidth = "";

	String _dataX = "";

	String _dataY = "";

	String _dataLabel = "";

	String _dataStyle = "";

	/**
	 * Construct a shape Node with the given parameters
	 * @param dataHeight Node's Height
	 * @param dataWidth Node's Width
	 * @param dataX Node's X coordinate.
	 * @param dataY Node's Y coordinate.
	 * @param dataStyle Node's style.
	 */
	GraphMlShapeNode(String dataHeight, String dataWidth, String dataX,
			String dataY, String dataStyle)
	{
		this._dataHeight = dataHeight;
		this._dataWidth = dataWidth;
		this._dataX = dataX;
		this._dataY = dataY;
		this._dataStyle = dataStyle;
	}

	/**
	 * Construct an empty shape Node
	 */
	GraphMlShapeNode()
	{
	}

	/**
	 * Construct a Shape Node from a xml Shape Node Element.
	 * @param shapeNodeElement Xml Shape Node Element.
	 */
	GraphMlShapeNode(Element shapeNodeElement)
	{
		//Defines Geometry
		Element geometryElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.GEOMETRY);
		this._dataHeight = geometryElement.getAttribute(GraphMlConstants.HEIGHT);
		this._dataWidth = geometryElement.getAttribute(GraphMlConstants.WIDTH);
		this._dataX = geometryElement.getAttribute(GraphMlConstants.X);
		this._dataY = geometryElement.getAttribute(GraphMlConstants.Y);

		Element styleElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);
		
		if (styleElement != null)
		{
			this._dataStyle = styleElement
					.getAttribute(GraphMlConstants.PROPERTIES);
		}
		//Defines Label
		Element labelElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.LABEL);
		
		if (labelElement != null)
		{
			this._dataLabel = labelElement.getAttribute(GraphMlConstants.TEXT);
		}
	}

	/**
	 * Generates a Shape Node Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	Element generateElement(Document document)
	{
		Element dataShape = document.createElementNS(GraphMlConstants.JGRAPH_URL,
				GraphMlConstants.JGRAPH + GraphMlConstants.SHAPENODE);

		Element dataShapeGeometry = document.createElementNS(
				GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
						+ GraphMlConstants.GEOMETRY);
		dataShapeGeometry.setAttribute(GraphMlConstants.HEIGHT, _dataHeight);
		dataShapeGeometry.setAttribute(GraphMlConstants.WIDTH, _dataWidth);
		dataShapeGeometry.setAttribute(GraphMlConstants.X, _dataX);
		dataShapeGeometry.setAttribute(GraphMlConstants.Y, _dataY);

		dataShape.appendChild(dataShapeGeometry);

		if (!this._dataStyle.equals(""))
		{
			Element dataShapeStyle = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.STYLE);
			dataShapeStyle.setAttribute(GraphMlConstants.PROPERTIES, _dataStyle);
			dataShape.appendChild(dataShapeStyle);
		}

		//Sets Label
		if (!this._dataLabel.equals(""))
		{

			Element dataShapeLabel = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.LABEL);
			dataShapeLabel.setAttribute(GraphMlConstants.TEXT, _dataLabel);

			dataShape.appendChild(dataShapeLabel);
		}
		
		return dataShape;
	}

	String getDataHeight()
	{
		return _dataHeight;
	}

	void setDataHeight(String dataHeight)
	{
		this._dataHeight = dataHeight;
	}

	String getDataWidth()
	{
		return _dataWidth;
	}

	void setDataWidth(String dataWidth)
	{
		this._dataWidth = dataWidth;
	}

	String getDataX()
	{
		return _dataX;
	}

	void setDataX(String dataX)
	{
		this._dataX = dataX;
	}

	String getDataY()
	{
		return _dataY;
	}

	void setDataY(String dataY)
	{
		this._dataY = dataY;
	}

	String getDataLabel()
	{
		return _dataLabel;
	}

	void setDataLabel(String dataLabel)
	{
		this._dataLabel = dataLabel;
	}

	String getDataStyle()
	{
		return _dataStyle;
	}

	void setDataStyle(String dataStyle)
	{
		this._dataStyle = dataStyle;
	}
}