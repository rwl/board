/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import graph.util.Constants;

//import java.util.HashMap;
//import java.util.Hashtable;
//import java.util.List;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Represents a Data element in the GML Structure.
 */
public class GraphMlEdge
{
	private String _edgeId;

	private String _edgeSource;

	private String _edgeSourcePort;

	private String _edgeTarget;

	private String _edgeTargetPort;

	private String _edgeDirected;

	private GraphMlData _edgeData;

	/**
	 * Map with the data. The key is the key attribute
	 */
	private HashMap<String, GraphMlData> _edgeDataMap = new HashMap<String, GraphMlData>();

	/**
	 * Construct an edge with source and target.
	 * @param edgeSource Source Node's ID.
	 * @param edgeTarget Target Node's ID.
	 */
	public GraphMlEdge(String edgeSource, String edgeTarget,
			String edgeSourcePort, String edgeTargetPort)
	{
		this._edgeId = "";
		this._edgeSource = edgeSource;
		this._edgeSourcePort = edgeSourcePort;
		this._edgeTarget = edgeTarget;
		this._edgeTargetPort = edgeTargetPort;
		this._edgeDirected = "";
	}

	/**
	 * Construct an edge from a xml edge element.
	 * @param edgeElement Xml edge element.
	 */
	public GraphMlEdge(Element edgeElement)
	{
		this._edgeId = edgeElement.getAttribute(GraphMlConstants.ID);
		this._edgeSource = edgeElement.getAttribute(GraphMlConstants.EDGE_SOURCE);
		this._edgeSourcePort = edgeElement
				.getAttribute(GraphMlConstants.EDGE_SOURCE_PORT);
		this._edgeTarget = edgeElement.getAttribute(GraphMlConstants.EDGE_TARGET);
		this._edgeTargetPort = edgeElement
				.getAttribute(GraphMlConstants.EDGE_TARGET_PORT);
		this._edgeDirected = edgeElement
				.getAttribute(GraphMlConstants.EDGE_DIRECTED);

		List<Element> dataList = GraphMlUtils.childsTags(edgeElement,
				GraphMlConstants.DATA);

		for (Element dataElem : dataList)
		{
			GraphMlData data = new GraphMlData(dataElem);
			String key = data.getDataKey();
			_edgeDataMap.put(key, data);
		}
	}

	public String getEdgeDirected()
	{
		return _edgeDirected;
	}

	public void setEdgeDirected(String edgeDirected)
	{
		this._edgeDirected = edgeDirected;
	}

	public String getEdgeId()
	{
		return _edgeId;
	}

	public void setEdgeId(String edgeId)
	{
		this._edgeId = edgeId;
	}

	public String getEdgeSource()
	{
		return _edgeSource;
	}

	public void setEdgeSource(String edgeSource)
	{
		this._edgeSource = edgeSource;
	}

	public String getEdgeSourcePort()
	{
		return _edgeSourcePort;
	}

	public void setEdgeSourcePort(String edgeSourcePort)
	{
		this._edgeSourcePort = edgeSourcePort;
	}

	public String getEdgeTarget()
	{
		return _edgeTarget;
	}

	public void setEdgeTarget(String edgeTarget)
	{
		this._edgeTarget = edgeTarget;
	}

	public String getEdgeTargetPort()
	{
		return _edgeTargetPort;
	}

	public void setEdgeTargetPort(String edgeTargetPort)
	{
		this._edgeTargetPort = edgeTargetPort;
	}

	public HashMap<String, GraphMlData> getEdgeDataMap()
	{
		return _edgeDataMap;
	}

	public void setEdgeDataMap(HashMap<String, GraphMlData> nodeEdgeMap)
	{
		this._edgeDataMap = nodeEdgeMap;
	}

	public GraphMlData getEdgeData()
	{
		return _edgeData;
	}

	public void setEdgeData(GraphMlData egdeData)
	{
		this._edgeData = egdeData;
	}

	/**
	 * Generates a Edge Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element edge = document.createElement(GraphMlConstants.EDGE);
		
		if (!_edgeId.equals(""))
		{
			edge.setAttribute(GraphMlConstants.ID, _edgeId);
		}
		edge.setAttribute(GraphMlConstants.EDGE_SOURCE, _edgeSource);
		edge.setAttribute(GraphMlConstants.EDGE_TARGET, _edgeTarget);

		if (!_edgeSourcePort.equals(""))
		{
			edge.setAttribute(GraphMlConstants.EDGE_SOURCE_PORT, _edgeSourcePort);
		}
		
		if (!_edgeTargetPort.equals(""))
		{
			edge.setAttribute(GraphMlConstants.EDGE_TARGET_PORT, _edgeTargetPort);
		}
		
		if (!_edgeDirected.equals(""))
		{
			edge.setAttribute(GraphMlConstants.EDGE_DIRECTED, _edgeDirected);
		}

		Element dataElement = _edgeData.generateEdgeElement(document);
		edge.appendChild(dataElement);

		return edge;
	}

	/**
	 * Returns if the edge has end arrow.
	 * @return style that indicates the end arrow type(CLASSIC or NONE).
	 */
	public String getEdgeStyle()
	{
		String style = "";
		Hashtable<String, Object> styleMap = new Hashtable<String, Object>();

		//Defines style of the edge.
		if (_edgeDirected.equals("true"))
		{
			styleMap.put(Constants.STYLE_ENDARROW, Constants.ARROW_CLASSIC);

			style = GraphMlUtils.getStyleString(styleMap, "=");
		}
		else if (_edgeDirected.equals("false"))
		{
			styleMap.put(Constants.STYLE_ENDARROW, Constants.NONE);

			style = GraphMlUtils.getStyleString(styleMap, "=");
		}

		return style;
	}
}