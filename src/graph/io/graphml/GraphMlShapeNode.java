/**
 * $Id: GraphMlShapeNode.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
package graph.io.graphml;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class GraphMlShapeNode
{
	private String dataHeight = "";

	private String dataWidth = "";

	private String dataX = "";

	private String dataY = "";

	private String dataLabel = "";

	private String dataStyle = "";

	/**
	 * Construct a shape Node with the given parameters
	 * @param dataHeight Node's Height
	 * @param dataWidth Node's Width
	 * @param dataX Node's X coordinate.
	 * @param dataY Node's Y coordinate.
	 * @param dataStyle Node's style.
	 */
	public GraphMlShapeNode(String dataHeight, String dataWidth, String dataX,
			String dataY, String dataStyle)
	{
		this.dataHeight = dataHeight;
		this.dataWidth = dataWidth;
		this.dataX = dataX;
		this.dataY = dataY;
		this.dataStyle = dataStyle;
	}

	/**
	 * Construct an empty shape Node
	 */
	public GraphMlShapeNode()
	{
	}

	/**
	 * Construct a Shape Node from a xml Shape Node Element.
	 * @param shapeNodeElement Xml Shape Node Element.
	 */
	public GraphMlShapeNode(Element shapeNodeElement)
	{
		//Defines Geometry
		Element geometryElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.GEOMETRY);
		this.dataHeight = geometryElement.getAttribute(GraphMlConstants.HEIGHT);
		this.dataWidth = geometryElement.getAttribute(GraphMlConstants.WIDTH);
		this.dataX = geometryElement.getAttribute(GraphMlConstants.X);
		this.dataY = geometryElement.getAttribute(GraphMlConstants.Y);

		Element styleElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);
		
		if (styleElement != null)
		{
			this.dataStyle = styleElement
					.getAttribute(GraphMlConstants.PROPERTIES);
		}
		//Defines Label
		Element labelElement = GraphMlUtils.childsTag(shapeNodeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.LABEL);
		
		if (labelElement != null)
		{
			this.dataLabel = labelElement.getAttribute(GraphMlConstants.TEXT);
		}
	}

	/**
	 * Generates a Shape Node Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element dataShape = document.createElementNS(GraphMlConstants.JGRAPH_URL,
				GraphMlConstants.JGRAPH + GraphMlConstants.SHAPENODE);

		Element dataShapeGeometry = document.createElementNS(
				GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
						+ GraphMlConstants.GEOMETRY);
		dataShapeGeometry.setAttribute(GraphMlConstants.HEIGHT, dataHeight);
		dataShapeGeometry.setAttribute(GraphMlConstants.WIDTH, dataWidth);
		dataShapeGeometry.setAttribute(GraphMlConstants.X, dataX);
		dataShapeGeometry.setAttribute(GraphMlConstants.Y, dataY);

		dataShape.appendChild(dataShapeGeometry);

		if (!this.dataStyle.equals(""))
		{
			Element dataShapeStyle = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.STYLE);
			dataShapeStyle.setAttribute(GraphMlConstants.PROPERTIES, dataStyle);
			dataShape.appendChild(dataShapeStyle);
		}

		//Sets Label
		if (!this.dataLabel.equals(""))
		{

			Element dataShapeLabel = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.LABEL);
			dataShapeLabel.setAttribute(GraphMlConstants.TEXT, dataLabel);

			dataShape.appendChild(dataShapeLabel);
		}
		
		return dataShape;
	}

	public String getDataHeight()
	{
		return dataHeight;
	}

	public void setDataHeight(String dataHeight)
	{
		this.dataHeight = dataHeight;
	}

	public String getDataWidth()
	{
		return dataWidth;
	}

	public void setDataWidth(String dataWidth)
	{
		this.dataWidth = dataWidth;
	}

	public String getDataX()
	{
		return dataX;
	}

	public void setDataX(String dataX)
	{
		this.dataX = dataX;
	}

	public String getDataY()
	{
		return dataY;
	}

	public void setDataY(String dataY)
	{
		this.dataY = dataY;
	}

	public String getDataLabel()
	{
		return dataLabel;
	}

	public void setDataLabel(String dataLabel)
	{
		this.dataLabel = dataLabel;
	}

	public String getDataStyle()
	{
		return dataStyle;
	}

	public void setDataStyle(String dataStyle)
	{
		this.dataStyle = dataStyle;
	}
}
