part of graph.layout;

//import java.awt.Rectangle;
//import java.util.ArrayList;
//import java.util.List;

class EdgeLabelLayout extends GraphLayout
{

	/**
	 * Constructs a new stack layout layout for the specified graph,
	 * spacing, orientation and offset.
	 */
	EdgeLabelLayout(Graph graph)
	{
		super(graph);
	}

	/*
	 * (non-Javadoc)
	 * @see graph.layout.IGraphLayout#execute(java.lang.Object)
	 */
	void execute(Object parent)
	{
		GraphView view = graph.getView();
		IGraphModel model = graph.getModel();

		// Gets all vertices and edges inside the parent
		List<Object> edges = new ArrayList<Object>();
		List<Object> vertices = new ArrayList<Object>();
		int childCount = model.getChildCount(parent);

		for (int i = 0; i < childCount; i++)
		{
			Object cell = model.getChildAt(parent, i);
			CellState state = view.getState(cell);

			if (state != null)
			{
				if (!isVertexIgnored(cell))
				{
					vertices.add(state);
				}
				else if (!isEdgeIgnored(cell))
				{
					edges.add(state);
				}
			}
		}

		placeLabels(vertices.toArray(), edges.toArray());
	}

	/**
	 * 
	 */
	void placeLabels(Object[] v, Object[] e)
	{
		IGraphModel model = graph.getModel();

		// Moves the vertices to build a circle. Makes sure the
		// radius is large enough for the vertices to not
		// overlap
		model.beginUpdate();
		try
		{
			for (int i = 0; i < e.length; i++)
			{
				CellState edge = (CellState) e[i];

				if (edge != null && edge.getLabelBounds() != null)
				{
					for (int j = 0; j < v.length; j++)
					{
						CellState vertex = (CellState) v[j];

						if (vertex != null)
						{
							avoid(edge, vertex);
						}
					}
				}
			}
		}
		finally
		{
			model.endUpdate();
		}
	}

	/**
	 * 
	 */
	void avoid(CellState edge, CellState vertex)
	{
		IGraphModel model = graph.getModel();
		Rectangle labRect = edge.getLabelBounds().getRectangle();
		Rectangle vRect = vertex.getRectangle();

		if (labRect.intersects(vRect))
		{
			int dy1 = -labRect.y - labRect.height + vRect.y;
			int dy2 = -labRect.y + vRect.y + vRect.height;

			int dy = (Math.abs(dy1) < Math.abs(dy2)) ? dy1 : dy2;

			int dx1 = -labRect.x - labRect.width + vRect.x;
			int dx2 = -labRect.x + vRect.x + vRect.width;

			int dx = (Math.abs(dx1) < Math.abs(dx2)) ? dx1 : dx2;

			if (Math.abs(dx) < Math.abs(dy))
			{
				dy = 0;
			}
			else
			{
				dx = 0;
			}

			Geometry g = model.getGeometry(edge.getCell());

			if (g != null)
			{
				g = (Geometry) g.clone();

				if (g.getOffset() != null)
				{
					g.getOffset().setX(g.getOffset().getX() + dx);
					g.getOffset().setY(g.getOffset().getY() + dy);
				}
				else
				{
					g.setOffset(new Point2d(dx, dy));
				}

				model.setGeometry(edge.getCell(), g);
			}
		}
	}

}
