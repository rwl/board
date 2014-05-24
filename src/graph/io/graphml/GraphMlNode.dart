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
public class GraphMlNode
{
	private String _nodeId;

	private GraphMlData _nodeData;

	private List<GraphMlGraph> _nodeGraphList = new ArrayList<GraphMlGraph>();

	private HashMap<String, GraphMlData> _nodeDataMap = new HashMap<String, GraphMlData>();

	private HashMap<String, GraphMlPort> _nodePortMap = new HashMap<String, GraphMlPort>();

	/**
	 * Construct a node with Id and one data element
	 * @param nodeId Node`s ID
	 * @param nodeData Gml Data.
	 */
	public GraphMlNode(String nodeId, GraphMlData nodeData)
	{
		this._nodeId = nodeId;
		this._nodeData = nodeData;
	}

	/**
	 * Construct a Node from a xml Node Element.
	 * @param nodeElement Xml Node Element.
	 */
	public GraphMlNode(Element nodeElement)
	{
		this._nodeId = nodeElement.getAttribute(GraphMlConstants.ID);

		//Add data elements
		List<Element> dataList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.DATA);

		for (Element dataElem : dataList)
		{
			GraphMlData data = new GraphMlData(dataElem);
			String key = data.getDataKey();
			_nodeDataMap.put(key, data);
		}

		//Add graph elements
		List<Element> graphList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.GRAPH);

		for (Element graphElem : graphList)
		{
			GraphMlGraph graph = new GraphMlGraph(graphElem);
			_nodeGraphList.add(graph);
		}

		//Add port elements
		List<Element> portList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.PORT);

		for (Element portElem : portList)
		{
			GraphMlPort port = new GraphMlPort(portElem);
			String name = port.getName();
			_nodePortMap.put(name, port);
		}
	}

	public String getNodeId()
	{
		return _nodeId;
	}

	public void setNodeId(String nodeId)
	{
		this._nodeId = nodeId;
	}

	public HashMap<String, GraphMlData> getNodeDataMap()
	{
		return _nodeDataMap;
	}

	public void setNodeDataMap(HashMap<String, GraphMlData> nodeDataMap)
	{
		this._nodeDataMap = nodeDataMap;
	}

	public List<GraphMlGraph> getNodeGraph()
	{
		return _nodeGraphList;
	}

	public void setNodeGraph(List<GraphMlGraph> nodeGraph)
	{
		this._nodeGraphList = nodeGraph;
	}

	public HashMap<String, GraphMlPort> getNodePort()
	{
		return _nodePortMap;
	}

	public void setNodePort(HashMap<String, GraphMlPort> nodePort)
	{
		this._nodePortMap = nodePort;
	}

	/**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element node = document.createElement(GraphMlConstants.NODE);

		node.setAttribute(GraphMlConstants.ID, _nodeId);

		Element dataElement = _nodeData.generateNodeElement(document);
		node.appendChild(dataElement);

		for (GraphMlPort port : _nodePortMap.values())
		{
			Element portElement = port.generateElement(document);
			node.appendChild(portElement);
		}

		for (GraphMlGraph graph : _nodeGraphList)
		{
			Element graphElement = graph.generateElement(document);
			node.appendChild(graphElement);
		}

		return node;
	}

	public GraphMlData getNodeData()
	{
		return _nodeData;
	}

	public void setNodeData(GraphMlData nodeData)
	{
		this._nodeData = nodeData;
	}

}
