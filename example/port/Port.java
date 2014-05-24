package graph.examples.swing;

import java.util.Map;

import javax.swing.JFrame;

import graph.model.Cell;
import graph.model.Geometry;
import graph.swing.GraphComponent;
import graph.util.Constants;
import graph.util.Point;
import graph.util.Rectangle;
import graph.view.EdgeStyle;
import graph.view.Graph;

public class Port extends JFrame
{
	/**
	 * 
	 */
	private static final long serialVersionUID = -464235672367772404L;

	final int PORT_DIAMETER = 20;

	final int PORT_RADIUS = PORT_DIAMETER / 2;

	public Port()
	{
		super("Hello, World!");

		Graph graph = new Graph() {
			
			// Ports are not used as terminals for edges, they are
			// only used to compute the graphical connection point
			public boolean isPort(Object cell)
			{
				Geometry geo = getCellGeometry(cell);
				
				return (geo != null) ? geo.isRelative() : false;
			}
			
			// Implements a tooltip that shows the actual
			// source and target of an edge
			public String getToolTipForCell(Object cell)
			{
				if (model.isEdge(cell))
				{
					return convertValueToString(model.getTerminal(cell, true)) + " -> " +
						convertValueToString(model.getTerminal(cell, false));
				}
				
				return super.getToolTipForCell(cell);
			}
			
			// Removes the folding icon and disables any folding
			public boolean isCellFoldable(Object cell, boolean collapse)
			{
				return false;
			}
		};
		
		// Sets the default edge style
		Map<String, Object> style = graph.getStylesheet().getDefaultEdgeStyle();
		style.put(Constants.STYLE_EDGE, EdgeStyle.ElbowConnector);
		
		Object parent = graph.getDefaultParent();

		graph.getModel().beginUpdate();
		try
		{
			Cell v1 = (Cell) graph.insertVertex(parent, null, "Hello", 20,
					20, 100, 100, "");
			v1.setConnectable(false);
			Geometry geo = graph.getModel().getGeometry(v1);
			// The size of the rectangle when the minus sign is clicked
			geo.setAlternateBounds(new Rectangle(20, 20, 100, 50));

			Geometry geo1 = new Geometry(0, 0.5, PORT_DIAMETER,
					PORT_DIAMETER);
			// Because the origin is at upper left corner, need to translate to
			// position the center of port correctly
			geo1.setOffset(new Point(-PORT_RADIUS, -PORT_RADIUS));
			geo1.setRelative(true);

			Cell port1 = new Cell(null, geo1,
					"shape=ellipse;perimter=ellipsePerimeter");
			port1.setVertex(true);

			Geometry geo2 = new Geometry(1.0, 0.5, PORT_DIAMETER,
					PORT_DIAMETER);
			geo2.setOffset(new Point(-PORT_RADIUS, -PORT_RADIUS));
			geo2.setRelative(true);

			Cell port2 = new Cell(null, geo2,
					"shape=ellipse;perimter=ellipsePerimeter");
			port2.setVertex(true);

			graph.addCell(port1, v1);
			graph.addCell(port2, v1);

			Object v2 = graph.insertVertex(parent, null, "World!", 240, 150, 80, 30);
			
			graph.insertEdge(parent, null, "Edge", port2, v2);
		}
		finally
		{
			graph.getModel().endUpdate();
		}

		GraphComponent graphComponent = new GraphComponent(graph);
		getContentPane().add(graphComponent);
		graphComponent.setToolTips(true);
	}

	public static void main(String[] args)
	{
		Port frame = new Port();
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setSize(400, 320);
		frame.setVisible(true);
	}

}
