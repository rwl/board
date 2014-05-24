package graph.examples.swing.editor;

import java.awt.Component;

import javax.swing.JTable;
import javax.swing.JViewport;

import graph.swing.GraphComponent;
import graph.util.Point;
import graph.util.Utils;
import graph.view.CellState;
import graph.view.Graph;
import graph.view.GraphView;

public class SchemaGraphComponent extends GraphComponent
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -1152655782652932774L;

	/**
	 * 
	 * @param graph
	 */
	public SchemaGraphComponent(Graph graph)
	{
		super(graph);

		GraphView graphView = new GraphView(graph)
		{

			/**
			 * 
			 */
			public void updateFloatingTerminalPoint(CellState edge,
					CellState start, CellState end, boolean isSource)
			{
				int col = getColumn(edge, isSource);

				if (col >= 0)
				{
					double y = getColumnLocation(edge, start, col);
					boolean left = start.getX() > end.getX();

					if (isSource)
					{
						double diff = Math.abs(start.getCenterX()
								- end.getCenterX())
								- start.getWidth() / 2 - end.getWidth() / 2;

						if (diff < 40)
						{
							left = !left;
						}
					}

					double x = (left) ? start.getX() : start.getX()
							+ start.getWidth();
					double x2 = (left) ? start.getX() - 20 : start.getX()
							+ start.getWidth() + 20;

					int index2 = (isSource) ? 1
							: edge.getAbsolutePointCount() - 1;
					edge.getAbsolutePoints().add(index2, new Point(x2, y));

					int index = (isSource) ? 0
							: edge.getAbsolutePointCount() - 1;
					edge.setAbsolutePoint(index, new Point(x, y));
				}
				else
				{
					super.updateFloatingTerminalPoint(edge, start, end,
							isSource);
				}
			}
		};

		graph.setView(graphView);
	}

	/**
	 * 
	 * @param edge
	 * @param isSource
	 * @return the column number the edge is attached to
	 */
	public int getColumn(CellState state, boolean isSource)
	{
		if (state != null)
		{
			if (isSource)
			{
				return Utils.getInt(state.getStyle(), "sourceRow", -1);
			}
			else
			{
				return Utils.getInt(state.getStyle(), "targetRow", -1);
			}
		}

		return -1;
	}

	/**
	 * 
	 */
	public int getColumnLocation(CellState edge, CellState terminal,
			int column)
	{
		Component[] c = components.get(terminal.getCell());
		int y = 0;

		if (c != null)
		{
			for (int i = 0; i < c.length; i++)
			{
				if (c[i] instanceof JTableRenderer)
				{
					JTableRenderer vertex = (JTableRenderer) c[i];

					JTable table = vertex.table;
					JViewport viewport = (JViewport) table.getParent();
					double dy = -viewport.getViewPosition().getY();
					y = (int) Math.max(terminal.getY() + 22, terminal.getY()
							+ Math.min(terminal.getHeight() - 20, 30 + dy
									+ column * 16));
				}
			}
		}

		return y;
	}

	/**
	 * 
	 */
	public Component[] createComponents(CellState state)
	{
		if (getGraph().getModel().isVertex(state.getCell()))
		{
			return new Component[] { new JTableRenderer(state.getCell(), this) };
		}

		return null;
	}
}
