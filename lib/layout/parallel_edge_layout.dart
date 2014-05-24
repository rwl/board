part of graph.layout;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;

class ParallelEdgeLayout extends GraphLayout
{

	/**
	 * Specifies the spacing between the edges. Default is 20.
	 */
	int spacing;

	/**
	 * Constructs a new stack layout layout for the specified graph,
	 * spacing, orientation and offset.
	 */
	ParallelEdgeLayout(Graph graph)
	{
		this(graph, 20);
	}

	/**
	 * Constructs a new stack layout layout for the specified graph,
	 * spacing, orientation and offset.
	 */
	ParallelEdgeLayout(Graph graph, int spacing)
	{
		super(graph);
		this.spacing = spacing;
	}

	/*
	 * (non-Javadoc)
	 * @see graph.layout.IGraphLayout#execute(java.lang.Object)
	 */
	void execute(Object parent)
	{
		Map<String, List<Object>> lookup = findParallels(parent);

		graph.getModel().beginUpdate();
		try
		{
			Iterator<List<Object>> it = lookup.values().iterator();

			while (it.hasNext())
			{
				List<Object> parallels = it.next();

				if (parallels.size() > 1)
				{
					layout(parallels);
				}
			}
		}
		finally
		{
			graph.getModel().endUpdate();
		}
	}

	/**
	 * 
	 */
	Map<String, List<Object>> findParallels(Object parent)
	{
		Map<String, List<Object>> lookup = new Hashtable<String, List<Object>>();
		IGraphModel model = graph.getModel();
		int childCount = model.getChildCount(parent);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(parent, i);

			if (!isEdgeIgnored(child))
			{
				String id = getEdgeId(child);

				if (id != null)
				{
					if (!lookup.containsKey(id))
					{
						lookup.put(id, new ArrayList<Object>());
					}

					lookup.get(id).add(child);
				}
			}
		}

		return lookup;
	}

	/**
	 * 
	 */
	String getEdgeId(Object edge)
	{
		GraphView view = graph.getView();
		CellState state = view.getState(edge);
		Object src = (state != null) ? state.getVisibleTerminal(true) : view
				.getVisibleTerminal(edge, true);
		Object trg = (state != null) ? state.getVisibleTerminal(false) : view
				.getVisibleTerminal(edge, false);

		if (src instanceof ICell && trg instanceof ICell)
		{
			String srcId = CellPath.create((ICell) src);
			String trgId = CellPath.create((ICell) trg);

			return (srcId.compareTo(trgId) > 0) ? trgId + "-" + srcId : srcId
					+ "-" + trgId;
		}

		return null;
	}

	/**
	 * 
	 */
	void layout(List<Object> parallels)
	{
		Object edge = parallels.get(0);
		IGraphModel model = graph.getModel();
		Geometry src = model.getGeometry(model.getTerminal(edge, true));
		Geometry trg = model.getGeometry(model.getTerminal(edge, false));

		// Routes multiple loops
		if (src == trg)
		{
			double x0 = src.getX() + src.getWidth() + this.spacing;
			double y0 = src.getY() + src.getHeight() / 2;

			for (int i = 0; i < parallels.size(); i++)
			{
				route(parallels.get(i), x0, y0);
				x0 += spacing;
			}
		}
		else if (src != null && trg != null)
		{
			// Routes parallel edges
			double scx = src.getX() + src.getWidth() / 2;
			double scy = src.getY() + src.getHeight() / 2;

			double tcx = trg.getX() + trg.getWidth() / 2;
			double tcy = trg.getY() + trg.getHeight() / 2;

			double dx = tcx - scx;
			double dy = tcy - scy;

			double len = Math.sqrt(dx * dx + dy * dy);

			double x0 = scx + dx / 2;
			double y0 = scy + dy / 2;

			double nx = dy * spacing / len;
			double ny = dx * spacing / len;

			x0 += nx * (parallels.size() - 1) / 2;
			y0 -= ny * (parallels.size() - 1) / 2;

			for (int i = 0; i < parallels.size(); i++)
			{
				route(parallels.get(i), x0, y0);
				x0 -= nx;
				y0 += ny;
			}
		}
	}

	/**
	 * 
	 */
	void route(Object edge, double x, double y)
	{
		if (graph.isCellMovable(edge))
		{
			setEdgePoints(edge,
					Arrays.asList(new Point2d[] { new Point2d(x, y) }));
		}
	}

}
