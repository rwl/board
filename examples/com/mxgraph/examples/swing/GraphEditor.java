/**
 * $Id: GraphEditor.java,v 1.3 2014/02/08 14:05:58 gaudenz Exp $
 * Copyright (c) 2006-2012, JGraph Ltd */
package graph.examples.swing;

import java.awt.Color;
import java.awt.Point;
import java.net.URL;
import java.text.NumberFormat;
import java.util.Iterator;
import java.util.List;
import javax.swing.ImageIcon;
import javax.swing.UIManager;

import org.w3c.dom.Document;

import graph.examples.swing.editor.BasicGraphEditor;
import graph.examples.swing.editor.EditorMenuBar;
import graph.examples.swing.editor.EditorPalette;
import graph.io.Codec;
import graph.model.Cell;
import graph.model.Geometry;
import graph.model.ICell;
import graph.model.IGraphModel;
import graph.swing.GraphComponent;
import graph.swing.util.GraphTransferable;
import graph.swing.util.SwingConstants;
import graph.util.Constants;
import graph.util.Event;
import graph.util.EventObject;
import graph.util.EventSource.IEventListener;
import graph.util.Point;
import graph.util.Resources;
import graph.util.Utils;
import graph.view.CellState;
import graph.view.Graph;

public class GraphEditor extends BasicGraphEditor
{
	/**
	 * 
	 */
	private static final long serialVersionUID = -4601740824088314699L;

	/**
	 * Holds the shared number formatter.
	 * 
	 * @see NumberFormat#getInstance()
	 */
	public static final NumberFormat numberFormat = NumberFormat.getInstance();

	/**
	 * Holds the URL for the icon to be used as a handle for creating new
	 * connections. This is currently unused.
	 */
	public static URL url = null;

	//GraphEditor.class.getResource("/com/graph/examples/swing/images/connector.gif");

	public GraphEditor()
	{
		this("Graph Editor", new CustomGraphComponent(new CustomGraph()));
	}

	/**
	 * 
	 */
	public GraphEditor(String appTitle, GraphComponent component)
	{
		super(appTitle, component);
		final Graph graph = graphComponent.getGraph();

		// Creates the shapes palette
		EditorPalette shapesPalette = insertPalette(Resources.get("shapes"));
		EditorPalette imagesPalette = insertPalette(Resources.get("images"));
		EditorPalette symbolsPalette = insertPalette(Resources.get("symbols"));

		// Sets the edge template to be used for creating new edges if an edge
		// is clicked in the shape palette
		shapesPalette.addListener(Event.SELECT, new IEventListener()
		{
			public void invoke(Object sender, EventObject evt)
			{
				Object tmp = evt.getProperty("transferable");

				if (tmp instanceof GraphTransferable)
				{
					GraphTransferable t = (GraphTransferable) tmp;
					Object cell = t.getCells()[0];

					if (graph.getModel().isEdge(cell))
					{
						((CustomGraph) graph).setEdgeTemplate(cell);
					}
				}
			}

		});

		// Adds some template cells for dropping into the graph
		shapesPalette
				.addTemplate(
						"Container",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/swimlane.png")),
						"swimlane", 280, 280, "Container");
		shapesPalette
				.addTemplate(
						"Icon",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rounded.png")),
						"icon;image=/com/graph/examples/swing/images/wrench.png",
						70, 70, "Icon");
		shapesPalette
				.addTemplate(
						"Label",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rounded.png")),
						"label;image=/com/graph/examples/swing/images/gear.png",
						130, 50, "Label");
		shapesPalette
				.addTemplate(
						"Rectangle",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rectangle.png")),
						null, 160, 120, "");
		shapesPalette
				.addTemplate(
						"Rounded Rectangle",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rounded.png")),
						"rounded=1", 160, 120, "");
		shapesPalette
				.addTemplate(
						"Double Rectangle",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/doublerectangle.png")),
						"rectangle;shape=doubleRectangle", 160, 120, "");
		shapesPalette
				.addTemplate(
						"Ellipse",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/ellipse.png")),
						"ellipse", 160, 160, "");
		shapesPalette
				.addTemplate(
						"Double Ellipse",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/doubleellipse.png")),
						"ellipse;shape=doubleEllipse", 160, 160, "");
		shapesPalette
				.addTemplate(
						"Triangle",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/triangle.png")),
						"triangle", 120, 160, "");
		shapesPalette
				.addTemplate(
						"Rhombus",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rhombus.png")),
						"rhombus", 160, 160, "");
		shapesPalette
				.addTemplate(
						"Horizontal Line",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/hline.png")),
						"line", 160, 10, "");
		shapesPalette
				.addTemplate(
						"Hexagon",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/hexagon.png")),
						"shape=hexagon", 160, 120, "");
		shapesPalette
				.addTemplate(
						"Cylinder",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/cylinder.png")),
						"shape=cylinder", 120, 160, "");
		shapesPalette
				.addTemplate(
						"Actor",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/actor.png")),
						"shape=actor", 120, 160, "");
		shapesPalette
				.addTemplate(
						"Cloud",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/cloud.png")),
						"ellipse;shape=cloud", 160, 120, "");

		shapesPalette
				.addEdgeTemplate(
						"Straight",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/straight.png")),
						"straight", 120, 120, "");
		shapesPalette
				.addEdgeTemplate(
						"Horizontal Connector",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/connect.png")),
						null, 100, 100, "");
		shapesPalette
				.addEdgeTemplate(
						"Vertical Connector",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/vertical.png")),
						"vertical", 100, 100, "");
		shapesPalette
				.addEdgeTemplate(
						"Entity Relation",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/entity.png")),
						"entity", 100, 100, "");
		shapesPalette
				.addEdgeTemplate(
						"Arrow",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/arrow.png")),
						"arrow", 120, 120, "");

		imagesPalette
				.addTemplate(
						"Bell",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/bell.png")),
						"image;image=/com/graph/examples/swing/images/bell.png",
						50, 50, "Bell");
		imagesPalette
				.addTemplate(
						"Box",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/box.png")),
						"image;image=/com/graph/examples/swing/images/box.png",
						50, 50, "Box");
		imagesPalette
				.addTemplate(
						"Cube",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/cube_green.png")),
						"image;image=/com/graph/examples/swing/images/cube_green.png",
						50, 50, "Cube");
		imagesPalette
				.addTemplate(
						"User",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/dude3.png")),
						"roundImage;image=/com/graph/examples/swing/images/dude3.png",
						50, 50, "User");
		imagesPalette
				.addTemplate(
						"Earth",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/earth.png")),
						"roundImage;image=/com/graph/examples/swing/images/earth.png",
						50, 50, "Earth");
		imagesPalette
				.addTemplate(
						"Gear",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/gear.png")),
						"roundImage;image=/com/graph/examples/swing/images/gear.png",
						50, 50, "Gear");
		imagesPalette
				.addTemplate(
						"Home",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/house.png")),
						"image;image=/com/graph/examples/swing/images/house.png",
						50, 50, "Home");
		imagesPalette
				.addTemplate(
						"Package",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/package.png")),
						"image;image=/com/graph/examples/swing/images/package.png",
						50, 50, "Package");
		imagesPalette
				.addTemplate(
						"Printer",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/printer.png")),
						"image;image=/com/graph/examples/swing/images/printer.png",
						50, 50, "Printer");
		imagesPalette
				.addTemplate(
						"Server",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/server.png")),
						"image;image=/com/graph/examples/swing/images/server.png",
						50, 50, "Server");
		imagesPalette
				.addTemplate(
						"Workplace",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/workplace.png")),
						"image;image=/com/graph/examples/swing/images/workplace.png",
						50, 50, "Workplace");
		imagesPalette
				.addTemplate(
						"Wrench",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/wrench.png")),
						"roundImage;image=/com/graph/examples/swing/images/wrench.png",
						50, 50, "Wrench");

		symbolsPalette
				.addTemplate(
						"Cancel",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/cancel_end.png")),
						"roundImage;image=/com/graph/examples/swing/images/cancel_end.png",
						80, 80, "Cancel");
		symbolsPalette
				.addTemplate(
						"Error",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/error.png")),
						"roundImage;image=/com/graph/examples/swing/images/error.png",
						80, 80, "Error");
		symbolsPalette
				.addTemplate(
						"Event",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/event.png")),
						"roundImage;image=/com/graph/examples/swing/images/event.png",
						80, 80, "Event");
		symbolsPalette
				.addTemplate(
						"Fork",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/fork.png")),
						"rhombusImage;image=/com/graph/examples/swing/images/fork.png",
						80, 80, "Fork");
		symbolsPalette
				.addTemplate(
						"Inclusive",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/inclusive.png")),
						"rhombusImage;image=/com/graph/examples/swing/images/inclusive.png",
						80, 80, "Inclusive");
		symbolsPalette
				.addTemplate(
						"Link",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/link.png")),
						"roundImage;image=/com/graph/examples/swing/images/link.png",
						80, 80, "Link");
		symbolsPalette
				.addTemplate(
						"Merge",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/merge.png")),
						"rhombusImage;image=/com/graph/examples/swing/images/merge.png",
						80, 80, "Merge");
		symbolsPalette
				.addTemplate(
						"Message",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/message.png")),
						"roundImage;image=/com/graph/examples/swing/images/message.png",
						80, 80, "Message");
		symbolsPalette
				.addTemplate(
						"Multiple",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/multiple.png")),
						"roundImage;image=/com/graph/examples/swing/images/multiple.png",
						80, 80, "Multiple");
		symbolsPalette
				.addTemplate(
						"Rule",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rule.png")),
						"roundImage;image=/com/graph/examples/swing/images/rule.png",
						80, 80, "Rule");
		symbolsPalette
				.addTemplate(
						"Terminate",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/terminate.png")),
						"roundImage;image=/com/graph/examples/swing/images/terminate.png",
						80, 80, "Terminate");
		symbolsPalette
				.addTemplate(
						"Timer",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/timer.png")),
						"roundImage;image=/com/graph/examples/swing/images/timer.png",
						80, 80, "Timer");
	}

	/**
	 * 
	 */
	public static class CustomGraphComponent extends GraphComponent
	{

		/**
		 * 
		 */
		private static final long serialVersionUID = -6833603133512882012L;

		/**
		 * 
		 * @param graph
		 */
		public CustomGraphComponent(Graph graph)
		{
			super(graph);

			// Sets switches typically used in an editor
			setPageVisible(true);
			setGridVisible(true);
			setToolTips(true);
			getConnectionHandler().setCreateTarget(true);

			// Loads the defalt stylesheet from an external file
			Codec codec = new Codec();
			Document doc = Utils.loadDocument(GraphEditor.class.getResource(
					"/com/graph/examples/swing/resources/default-style.xml")
					.toString());
			codec.decode(doc.getDocumentElement(), graph.getStylesheet());

			// Sets the background to white
			getViewport().setOpaque(true);
			getViewport().setBackground(Color.WHITE);
		}

		/**
		 * Overrides drop behaviour to set the cell style if the target
		 * is not a valid drop target and the cells are of the same
		 * type (eg. both vertices or both edges). 
		 */
		public Object[] importCells(Object[] cells, double dx, double dy,
				Object target, Point location)
		{
			if (target == null && cells.length == 1 && location != null)
			{
				target = getCellAt(location.x, location.y);

				if (target instanceof ICell && cells[0] instanceof ICell)
				{
					ICell targetCell = (ICell) target;
					ICell dropCell = (ICell) cells[0];

					if (targetCell.isVertex() == dropCell.isVertex()
							|| targetCell.isEdge() == dropCell.isEdge())
					{
						IGraphModel model = graph.getModel();
						model.setStyle(target, model.getStyle(cells[0]));
						graph.setSelectionCell(target);

						return null;
					}
				}
			}

			return super.importCells(cells, dx, dy, target, location);
		}

	}

	/**
	 * A graph that creates new edges from a given template edge.
	 */
	public static class CustomGraph extends Graph
	{
		/**
		 * Holds the edge to be used as a template for inserting new edges.
		 */
		protected Object edgeTemplate;

		/**
		 * Custom graph that defines the alternate edge style to be used when
		 * the middle control point of edges is double clicked (flipped).
		 */
		public CustomGraph()
		{
			setAlternateEdgeStyle("edgeStyle=EdgeStyle.ElbowConnector;elbow=vertical");
		}

		/**
		 * Sets the edge template to be used to inserting edges.
		 */
		public void setEdgeTemplate(Object template)
		{
			edgeTemplate = template;
		}

		/**
		 * Prints out some useful information about the cell in the tooltip.
		 */
		public String getToolTipForCell(Object cell)
		{
			String tip = "<html>";
			Geometry geo = getModel().getGeometry(cell);
			CellState state = getView().getState(cell);

			if (getModel().isEdge(cell))
			{
				tip += "points={";

				if (geo != null)
				{
					List<Point> points = geo.getPoints();

					if (points != null)
					{
						Iterator<Point> it = points.iterator();

						while (it.hasNext())
						{
							Point point = it.next();
							tip += "[x=" + numberFormat.format(point.getX())
									+ ",y=" + numberFormat.format(point.getY())
									+ "],";
						}

						tip = tip.substring(0, tip.length() - 1);
					}
				}

				tip += "}<br>";
				tip += "absPoints={";

				if (state != null)
				{

					for (int i = 0; i < state.getAbsolutePointCount(); i++)
					{
						Point point = state.getAbsolutePoint(i);
						tip += "[x=" + numberFormat.format(point.getX())
								+ ",y=" + numberFormat.format(point.getY())
								+ "],";
					}

					tip = tip.substring(0, tip.length() - 1);
				}

				tip += "}";
			}
			else
			{
				tip += "geo=[";

				if (geo != null)
				{
					tip += "x=" + numberFormat.format(geo.getX()) + ",y="
							+ numberFormat.format(geo.getY()) + ",width="
							+ numberFormat.format(geo.getWidth()) + ",height="
							+ numberFormat.format(geo.getHeight());
				}

				tip += "]<br>";
				tip += "state=[";

				if (state != null)
				{
					tip += "x=" + numberFormat.format(state.getX()) + ",y="
							+ numberFormat.format(state.getY()) + ",width="
							+ numberFormat.format(state.getWidth())
							+ ",height="
							+ numberFormat.format(state.getHeight());
				}

				tip += "]";
			}

			Point trans = getView().getTranslate();

			tip += "<br>scale=" + numberFormat.format(getView().getScale())
					+ ", translate=[x=" + numberFormat.format(trans.getX())
					+ ",y=" + numberFormat.format(trans.getY()) + "]";
			tip += "</html>";

			return tip;
		}

		/**
		 * Overrides the method to use the currently selected edge template for
		 * new edges.
		 * 
		 * @param graph
		 * @param parent
		 * @param id
		 * @param value
		 * @param source
		 * @param target
		 * @param style
		 * @return
		 */
		public Object createEdge(Object parent, String id, Object value,
				Object source, Object target, String style)
		{
			if (edgeTemplate != null)
			{
				Cell edge = (Cell) cloneCells(new Object[] { edgeTemplate })[0];
				edge.setId(id);

				return edge;
			}

			return super.createEdge(parent, id, value, source, target, style);
		}

	}

	/**
	 * 
	 * @param args
	 */
	public static void main(String[] args)
	{
		try
		{
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		}
		catch (Exception e1)
		{
			e1.printStackTrace();
		}

		SwingConstants.SHADOW_COLOR = Color.LIGHT_GRAY;
		Constants.W3C_SHADOWCOLOR = "#D3D3D3";

		GraphEditor editor = new GraphEditor();
		editor.createFrame(new EditorMenuBar(editor)).setVisible(true);
	}
}
