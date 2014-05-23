package graph.examples.swing;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JFrame;

import graph.swing.GraphComponent;
import graph.view.Graph;

public class ClickHandler extends JFrame
{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -2764911804288120883L;

	public ClickHandler()
	{
		super("Hello, World!");
		
		final Graph graph = new Graph();
		Object parent = graph.getDefaultParent();

		graph.getModel().beginUpdate();
		try
		{
		   Object v1 = graph.insertVertex(parent, null, "Hello", 20, 20, 80,
		         30);
		   Object v2 = graph.insertVertex(parent, null, "World!",
		         240, 150, 80, 30);
		   graph.insertEdge(parent, null, "Edge", v1, v2);
		}
		finally
		{
		   graph.getModel().endUpdate();
		}
		
		final GraphComponent graphComponent = new GraphComponent(graph);
		getContentPane().add(graphComponent);
		
		graphComponent.getGraphControl().addMouseListener(new MouseAdapter()
		{
		
			public void mouseReleased(MouseEvent e)
			{
				Object cell = graphComponent.getCellAt(e.getX(), e.getY());
				
				if (cell != null)
				{
					System.out.println("cell="+graph.getLabel(cell));
				}
			}
		});
	}

	public static void main(String[] args)
	{
		ClickHandler frame = new ClickHandler();
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setSize(400, 320);
		frame.setVisible(true);
	}

}
