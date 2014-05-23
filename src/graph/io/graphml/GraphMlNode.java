/**
 * $Id: GraphMlNode.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
package graph.io.graphml;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Represents a Data element in the GML Structure.
 */
public class GraphMlNode
{
	private String nodeId;

	private GraphMlData nodeData;

	private List<GraphMlGraph> nodeGraphList = new ArrayList<GraphMlGraph>();

	private HashMap<String, GraphMlData> nodeDataMap = new HashMap<String, GraphMlData>();

	private HashMap<String, GraphMlPort> nodePortMap = new HashMap<String, GraphMlPort>();

	/**
	 * Construct a node with Id and one data element
	 * @param nodeId Node`s ID
	 * @param nodeData Gml Data.
	 */
	public GraphMlNode(String nodeId, GraphMlData nodeData)
	{
		this.nodeId = nodeId;
		this.nodeData = nodeData;
	}

	/**
	 * Construct a Node from a xml Node Element.
	 * @param nodeElement Xml Node Element.
	 */
	public GraphMlNode(Element nodeElement)
	{
		this.nodeId = nodeElement.getAttribute(GraphMlConstants.ID);

		//Add data elements
		List<Element> dataList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.DATA);

		for (Element dataElem : dataList)
		{
			GraphMlData data = new GraphMlData(dataElem);
			String key = data.getDataKey();
			nodeDataMap.put(key, data);
		}

		//Add graph elements
		List<Element> graphList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.GRAPH);

		for (Element graphElem : graphList)
		{
			GraphMlGraph graph = new GraphMlGraph(graphElem);
			nodeGraphList.add(graph);
		}

		//Add port elements
		List<Element> portList = GraphMlUtils.childsTags(nodeElement,
				GraphMlConstants.PORT);

		for (Element portElem : portList)
		{
			GraphMlPort port = new GraphMlPort(portElem);
			String name = port.getName();
			nodePortMap.put(name, port);
		}
	}

	public String getNodeId()
	{
		return nodeId;
	}

	public void setNodeId(String nodeId)
	{
		this.nodeId = nodeId;
	}

	public HashMap<String, GraphMlData> getNodeDataMap()
	{
		return nodeDataMap;
	}

	public void setNodeDataMap(HashMap<String, GraphMlData> nodeDataMap)
	{
		this.nodeDataMap = nodeDataMap;
	}

	public List<GraphMlGraph> getNodeGraph()
	{
		return nodeGraphList;
	}

	public void setNodeGraph(List<GraphMlGraph> nodeGraph)
	{
		this.nodeGraphList = nodeGraph;
	}

	public HashMap<String, GraphMlPort> getNodePort()
	{
		return nodePortMap;
	}

	public void setNodePort(HashMap<String, GraphMlPort> nodePort)
	{
		this.nodePortMap = nodePort;
	}

	/**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element node = document.createElement(GraphMlConstants.NODE);

		node.setAttribute(GraphMlConstants.ID, nodeId);

		Element dataElement = nodeData.generateNodeElement(document);
		node.appendChild(dataElement);

		for (GraphMlPort port : nodePortMap.values())
		{
			Element portElement = port.generateElement(document);
			node.appendChild(portElement);
		}

		for (GraphMlGraph graph : nodeGraphList)
		{
			Element graphElement = graph.generateElement(document);
			node.appendChild(graphElement);
		}

		return node;
	}

	public GraphMlData getNodeData()
	{
		return nodeData;
	}

	public void setNodeData(GraphMlData nodeData)
	{
		this.nodeData = nodeData;
	}

}
