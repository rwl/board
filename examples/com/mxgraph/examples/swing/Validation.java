/**
 * $Id: Validation.java,v 1.1 2012/11/15 13:26:47 gaudenz Exp $
 * Copyright (c) 2007-2012, JGraph Ltd
 */
package graph.examples.swing;

import java.util.Arrays;

import javax.swing.JFrame;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import graph.swing.GraphComponent;
import graph.swing.handler.KeyboardHandler;
import graph.swing.handler.Rubberband;
import graph.util.DomUtils;
import graph.util.Event;
import graph.util.EventObject;
import graph.util.EventSource.IEventListener;
import graph.view.Graph;
import graph.view.Multiplicity;

public class Validation extends JFrame
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -8928982366041695471L;

	public Validation()
	{
		super("Hello, World!");

		Document xmlDocument = DomUtils.createDocument();
		Element sourceNode = xmlDocument.createElement("Source");
		Element targetNode = xmlDocument.createElement("Target");
		Element subtargetNode = xmlDocument.createElement("Subtarget");

		Graph graph = new Graph();
		Object parent = graph.getDefaultParent();

		graph.getModel().beginUpdate();
		try
		{
			Object v1 = graph.insertVertex(parent, null, sourceNode, 20, 20,
					80, 30);
			Object v2 = graph.insertVertex(parent, null, targetNode, 200, 20,
					80, 30);
			Object v3 = graph.insertVertex(parent, null, targetNode
					.cloneNode(true), 200, 80, 80, 30);
			Object v4 = graph.insertVertex(parent, null, targetNode
					.cloneNode(true), 200, 140, 80, 30);
			graph.insertVertex(parent, null, subtargetNode, 200,
					200, 80, 30);
			Object v6 = graph.insertVertex(parent, null, sourceNode
					.cloneNode(true), 20, 140, 80, 30);
			graph.insertEdge(parent, null, "", v1, v2);
			graph.insertEdge(parent, null, "", v1, v3);
			graph.insertEdge(parent, null, "", v6, v4);
			//Object e4 = graph.insertEdge(parent, null, "", v1, v4);
		}
		finally
		{
			graph.getModel().endUpdate();
		}

		Multiplicity[] multiplicities = new Multiplicity[3];

		// Source nodes needs 1..2 connected Targets
		multiplicities[0] = new Multiplicity(true, "Source", null, null, 1,
				"2", Arrays.asList(new String[] { "Target" }),
				"Source Must Have 1 or 2 Targets",
				"Source Must Connect to Target", true);

		// Source node does not want any incoming connections
		multiplicities[1] = new Multiplicity(false, "Source", null, null, 0,
				"0", null, "Source Must Have No Incoming Edge", null, true); // Type does not matter

		// Target needs exactly one incoming connection from Source
		multiplicities[2] = new Multiplicity(false, "Target", null, null, 1,
				"1", Arrays.asList(new String[] { "Source" }),
				"Target Must Have 1 Source", "Target Must Connect From Source",
				true);

		graph.setMultiplicities(multiplicities);

		final GraphComponent graphComponent = new GraphComponent(graph);
		graph.setMultigraph(false);
		graph.setAllowDanglingEdges(false);
		graphComponent.setConnectable(true);
		graphComponent.setToolTips(true);

		// Enables rubberband selection
		new Rubberband(graphComponent);
		new KeyboardHandler(graphComponent);

		// Installs automatic validation (use editor.validation = true
		// if you are using an Editor instance)
		graph.getModel().addListener(Event.CHANGE, new IEventListener()
		{
			public void invoke(Object sender, EventObject evt)
			{
				graphComponent.validateGraph();
			}
		});

		// Initial validation
		graphComponent.validateGraph();

		getContentPane().add(graphComponent);
	}

	public static void main(String[] args)
	{
		Validation frame = new Validation();
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setSize(400, 320);
		frame.setVisible(true);
	}

}
