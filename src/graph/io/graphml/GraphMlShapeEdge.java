/**
 * $Id: GraphMlShapeEdge.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
package graph.io.graphml;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * This class represents the properties of a JGraph edge.
 */
public class GraphMlShapeEdge
{
	private String text = "";

	private String style = "";

	private String edgeSource;

	private String edgeTarget;

	/**
	 * Construct a Shape Edge with text and style.
	 * @param text
	 * @param style
	 */
	public GraphMlShapeEdge(String text, String style)
	{
		this.text = text;
		this.style = style;
	}

	/**
	 * Constructs a ShapeEdge from a xml shapeEdgeElement.
	 * @param shapeEdgeElement
	 */
	public GraphMlShapeEdge(Element shapeEdgeElement)
	{
		Element labelElement = GraphMlUtils.childsTag(shapeEdgeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.LABEL);
		
		if (labelElement != null)
		{
			this.text = labelElement.getAttribute(GraphMlConstants.TEXT);
		}

		Element styleElement = GraphMlUtils.childsTag(shapeEdgeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);
		
		if (styleElement != null)
		{
			this.style = styleElement.getAttribute(GraphMlConstants.PROPERTIES);

		}
	}

	/**
	 * Construct an empty Shape Edge Element.
	 */
	public GraphMlShapeEdge()
	{
	}

	/**
	 * Generates a ShapeEdge Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element dataEdge = document.createElementNS(GraphMlConstants.JGRAPH_URL,
				GraphMlConstants.JGRAPH + GraphMlConstants.SHAPEEDGE);

		if (!this.text.equals(""))
		{
			Element dataEdgeLabel = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.LABEL);
			dataEdgeLabel.setAttribute(GraphMlConstants.TEXT, this.text);
			dataEdge.appendChild(dataEdgeLabel);
		}
		
		if (!this.style.equals(""))
		{
			Element dataEdgeStyle = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.STYLE);

			dataEdgeStyle.setAttribute(GraphMlConstants.PROPERTIES, this.style);
			dataEdge.appendChild(dataEdgeStyle);
		}

		return dataEdge;
	}

	public String getText()
	{
		return text;
	}

	public void setText(String text)
	{
		this.text = text;
	}

	public String getStyle()
	{
		return style;
	}

	public void setStyle(String style)
	{
		this.style = style;
	}

	public String getEdgeSource()
	{
		return edgeSource;
	}

	public void setEdgeSource(String edgeSource)
	{
		this.edgeSource = edgeSource;
	}

	public String getEdgeTarget()
	{
		return edgeTarget;
	}

	public void setEdgeTarget(String edgeTarget)
	{
		this.edgeTarget = edgeTarget;
	}
}
