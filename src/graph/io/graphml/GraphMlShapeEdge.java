/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * This class represents the properties of a JGraph edge.
 */
public class GraphMlShapeEdge
{
	private String _text = "";

	private String _style = "";

	private String _edgeSource;

	private String _edgeTarget;

	/**
	 * Construct a Shape Edge with text and style.
	 * @param text
	 * @param style
	 */
	public GraphMlShapeEdge(String text, String style)
	{
		this._text = text;
		this._style = style;
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
			this._text = labelElement.getAttribute(GraphMlConstants.TEXT);
		}

		Element styleElement = GraphMlUtils.childsTag(shapeEdgeElement,
				GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);
		
		if (styleElement != null)
		{
			this._style = styleElement.getAttribute(GraphMlConstants.PROPERTIES);

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

		if (!this._text.equals(""))
		{
			Element dataEdgeLabel = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.LABEL);
			dataEdgeLabel.setAttribute(GraphMlConstants.TEXT, this._text);
			dataEdge.appendChild(dataEdgeLabel);
		}
		
		if (!this._style.equals(""))
		{
			Element dataEdgeStyle = document.createElementNS(
					GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH
							+ GraphMlConstants.STYLE);

			dataEdgeStyle.setAttribute(GraphMlConstants.PROPERTIES, this._style);
			dataEdge.appendChild(dataEdgeStyle);
		}

		return dataEdge;
	}

	public String getText()
	{
		return _text;
	}

	public void setText(String text)
	{
		this._text = text;
	}

	public String getStyle()
	{
		return _style;
	}

	public void setStyle(String style)
	{
		this._style = style;
	}

	public String getEdgeSource()
	{
		return _edgeSource;
	}

	public void setEdgeSource(String edgeSource)
	{
		this._edgeSource = edgeSource;
	}

	public String getEdgeTarget()
	{
		return _edgeTarget;
	}

	public void setEdgeTarget(String edgeTarget)
	{
		this._edgeTarget = edgeTarget;
	}
}
