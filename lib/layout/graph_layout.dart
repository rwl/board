/**
 * Copyright (c) 2008-2009, JGraph Ltd
 */
part of graph.layout;

//import graph.model.Geometry;
//import graph.model.IGraphModel;
//import graph.util.Constants;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.view.CellState;
//import graph.view.Graph;
//import graph.view.GraphView;
//import graph.view.Graph.ICellVisitor;

//import java.util.HashSet;
//import java.util.List;
//import java.util.Map;
//import java.util.Set;

/**
 * Defines the requirements for an object that implements a graph layout.
 */
public interface IGraphLayout
{

  /**
   * Executes the layout for the children of the specified parent.
   * 
   * @param parent Parent cell that contains the children to be layed out.
   */
  void execute(Object parent);

  /**
   * Notified when a cell is being moved in a parent that has automatic
   * layout to update the cell state (eg. index) so that the outcome of the
   * layout will position the vertex as close to the point (x, y) as
   * possible.
   * 
   * @param cell Cell which is being moved.
   * @param x X-coordinate of the new cell location.
   * @param y Y-coordinate of the new cell location.
   */
  void moveCell(Object cell, double x, double y);

}

/**
 * Abstract bass class for layouts
 */
public abstract class GraphLayout implements IGraphLayout
{

	/**
	 * Holds the enclosing graph.
	 */
	protected Graph graph;

	/**
	 * The parent cell of the layout, if any
	 */
	protected Object parent;

	/**
	 * Boolean indicating if the bounding box of the label should be used if
	 * its available. Default is true.
	 */
	protected boolean useBoundingBox = true;

	/**
	 * Constructs a new fast organic layout for the specified graph.
	 */
	public GraphLayout(Graph graph)
	{
		this.graph = graph;
	}

	public void execute(Object parent)
	{
		this.parent = parent;
	}

	/* (non-Javadoc)
	 * @see graph.layout.IGraphLayout#move(java.lang.Object, double, double)
	 */
	public void moveCell(Object cell, double x, double y)
	{
		// TODO: Map the position to a child index for
		// the cell to be placed closest to the position
	}

	/**
	 * Returns the associated graph.
	 */
	public Graph getGraph()
	{
		return graph;
	}

	/**
	 * Returns the constraint for the given key and cell. This implementation
	 * always returns the value for the given key in the style of the given
	 * cell.
	 * 
	 * @param key Key of the constraint to be returned.
	 * @param cell Cell whose constraint should be returned.
	 */
	public Object getConstraint(Object key, Object cell)
	{
		return getConstraint(key, cell, null, false);
	}

	/**
	 * Returns the constraint for the given key and cell. The optional edge and
	 * source arguments are used to return inbound and outgoing routing-
	 * constraints for the given edge and vertex. This implementation always
	 * returns the value for the given key in the style of the given cell.
	 * 
	 * @param key Key of the constraint to be returned.
	 * @param cell Cell whose constraint should be returned.
	 * @param edge Optional cell that represents the connection whose constraint
	 * should be returned. Default is null.
	 * @param source Optional boolean that specifies if the connection is incoming
	 * or outgoing. Default is false.
	 */
	public Object getConstraint(Object key, Object cell, Object edge,
			boolean source)
	{
		CellState state = graph.getView().getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle() : graph
				.getCellStyle(cell);

		return (style != null) ? style.get(key) : null;
	}

	/**
	 * @return the useBoundingBox
	 */
	public boolean isUseBoundingBox()
	{
		return useBoundingBox;
	}

	/**
	 * @param useBoundingBox the useBoundingBox to set
	 */
	public void setUseBoundingBox(boolean useBoundingBox)
	{
		this.useBoundingBox = useBoundingBox;
	}

	/**
	 * Returns true if the given vertex may be moved by the layout.
	 * 
	 * @param vertex Object that represents the vertex to be tested.
	 * @return Returns true if the vertex can be moved.
	 */
	public boolean isVertexMovable(Object vertex)
	{
		return graph.isCellMovable(vertex);
	}

	/**
	 * Returns true if the given vertex has no connected edges.
	 * 
	 * @param vertex Object that represents the vertex to be tested.
	 * @return Returns true if the vertex should be ignored.
	 */
	public boolean isVertexIgnored(Object vertex)
	{
		return !graph.getModel().isVertex(vertex)
				|| !graph.isCellVisible(vertex);
	}

	/**
	 * Returns true if the given edge has no source or target terminal.
	 * 
	 * @param edge Object that represents the edge to be tested.
	 * @return Returns true if the edge should be ignored.
	 */
	public boolean isEdgeIgnored(Object edge)
	{
		IGraphModel model = graph.getModel();

		return !model.isEdge(edge) || !graph.isCellVisible(edge)
				|| model.getTerminal(edge, true) == null
				|| model.getTerminal(edge, false) == null;
	}

	/**
	 * Disables or enables the edge style of the given edge.
	 */
	public void setEdgeStyleEnabled(Object edge, boolean value)
	{
		graph.setCellStyles(Constants.STYLE_NOEDGESTYLE, (value) ? "0" : "1",
				new Object[] { edge });
	}

	/**
	 * Disables or enables orthogonal end segments of the given edge
	 */
	public void setOrthogonalEdge(Object edge, boolean value)
	{
		graph.setCellStyles(Constants.STYLE_ORTHOGONAL, (value) ? "1" : "0",
				new Object[] { edge });
	}

	public Point2d getParentOffset(Object parent)
	{
		Point2d result = new Point2d();

		if (parent != null && parent != this.parent)
		{
			IGraphModel model = graph.getModel();

			if (model.isAncestor(this.parent, parent))
			{
				Geometry parentGeo = model.getGeometry(parent);

				while (parent != this.parent)
				{
					result.setX(result.getX() + parentGeo.getX());
					result.setY(result.getY() + parentGeo.getY());

					parent = model.getParent(parent);;
					parentGeo = model.getGeometry(parent);
				}
			}
		}

		return result;
	}

	/**
	 * Sets the control points of the given edge to the given
	 * list of mxPoints. Set the points to null to remove all
	 * existing points for an edge.
	 */
	public void setEdgePoints(Object edge, List<Point2d> points)
	{
		IGraphModel model = graph.getModel();
		Geometry geometry = model.getGeometry(edge);

		if (geometry == null)
		{
			geometry = new Geometry();
			geometry.setRelative(true);
		}
		else
		{
			geometry = (Geometry) geometry.clone();
		}

		if (this.parent != null && points != null)
		{
			Object parent = graph.getModel().getParent(edge);

				Point2d parentOffset = getParentOffset(parent);

				for (Point2d point : points)
				{
					point.setX(point.getX() - parentOffset.getX());
					point.setY(point.getY() - parentOffset.getY());
				}

		}

		geometry.setPoints(points);
		model.setGeometry(edge, geometry);
	}

	/**
	 * Returns an <Rect> that defines the bounds of the given cell
	 * or the bounding box if <useBoundingBox> is true.
	 */
	public Rect getVertexBounds(Object vertex)
	{
		Rect geo = graph.getModel().getGeometry(vertex);

		// Checks for oversize label bounding box and corrects
		// the return value accordingly
		if (useBoundingBox)
		{
			CellState state = graph.getView().getState(vertex);

			if (state != null)
			{
				double scale = graph.getView().getScale();
				Rect tmp = state.getBoundingBox();

				double dx0 = (tmp.getX() - state.getX()) / scale;
				double dy0 = (tmp.getY() - state.getY()) / scale;
				double dx1 = (tmp.getX() + tmp.getWidth() - state.getX() - state
						.getWidth()) / scale;
				double dy1 = (tmp.getY() + tmp.getHeight() - state.getY() - state
						.getHeight()) / scale;

				geo = new Rect(geo.getX() + dx0, geo.getY() + dy0,
						geo.getWidth() - dx0 + dx1, geo.getHeight() + -dy0
								+ dy1);
			}
		}

		if (this.parent != null)
		{
			Object parent = graph.getModel().getParent(vertex);
			geo = (Rect) geo.clone();

			if (parent != null && parent != this.parent)
			{
				Point2d parentOffset = getParentOffset(parent);
				geo.setX(geo.getX() + parentOffset.getX());
				geo.setY(geo.getY() + parentOffset.getY());
			}
		}

		return new Rect(geo);
	}

	/**
	 * Sets the new position of the given cell taking into account the size of
	 * the bounding box if <useBoundingBox> is true. The change is only carried
	 * out if the new location is not equal to the existing location, otherwise
	 * the geometry is not replaced with an updated instance. The new or old
	 * bounds are returned (including overlapping labels).
	 * 
	 * Parameters:
	 * 
	 * cell - <Cell> whose geometry is to be set.
	 * x - Integer that defines the x-coordinate of the new location.
	 * y - Integer that defines the y-coordinate of the new location.
	 */
	public Rect setVertexLocation(Object vertex, double x, double y)
	{
		IGraphModel model = graph.getModel();
		Geometry geometry = model.getGeometry(vertex);
		Rect result = null;

		if (geometry != null)
		{
			result = new Rect(x, y, geometry.getWidth(),
					geometry.getHeight());

			GraphView graphView = graph.getView();

			// Checks for oversize labels and offset the result
			if (useBoundingBox)
			{
				CellState state = graphView.getState(vertex);

				if (state != null)
				{
					double scale = graph.getView().getScale();
					Rect box = state.getBoundingBox();

					if (state.getBoundingBox().getX() < state.getX())
					{
						x += (state.getX() - box.getX()) / scale;
						result.setWidth(box.getWidth());
					}
					if (state.getBoundingBox().getY() < state.getY())
					{
						y += (state.getY() - box.getY()) / scale;
						result.setHeight(box.getHeight());
					}
				}
			}

			if (this.parent != null)
			{
				Object parent = model.getParent(vertex);

				if (parent != null && parent != this.parent)
				{
					Point2d parentOffset = getParentOffset(parent);

					x = x - parentOffset.getX();
					y = y - parentOffset.getY();
				}
			}

			if (geometry.getX() != x || geometry.getY() != y)
			{
				geometry = (Geometry) geometry.clone();
				geometry.setX(x);
				geometry.setY(y);

				model.setGeometry(vertex, geometry);
			}
		}

		return result;
	}
	
	/**
	 * Updates the bounds of the given groups to include all children. Call
	 * this with the groups in parent to child order, top-most group first, eg.
	 * 
	 * arrangeGroups(graph, Utils.sortCells(Arrays.asList(
	 *   new Object[] { v1, v3 }), true).toArray(), 10);
	 * @param groups the groups to adjust
	 * @param border the border applied to the adjusted groups
	 */
	public void arrangeGroups(Object[] groups, int border)
	{
		graph.getModel().beginUpdate();
		try
		{
			for (int i = groups.length - 1; i >= 0; i--)
			{
				Object group = groups[i];
				Object[] children = graph.getChildVertices(group);
				Rect bounds = graph.getBoundingBoxFromGeometry(children);

				Geometry geometry = graph.getCellGeometry(group);
				double left = 0;
				double top = 0;
				
				// Adds the size of the title area for swimlanes
				if (this.graph.isSwimlane(group))
				{
					Rect size = graph.getStartSize(group);
					left = size.getWidth();
					top = size.getHeight();
				}
				
				if (bounds != null && geometry != null)
				{
					geometry = (Geometry) geometry.clone();
					geometry.setX(geometry.getX() + bounds.getX() - border - left);
					geometry.setY(geometry.getY() + bounds.getY() - border - top);
					geometry.setWidth(bounds.getWidth() + 2 * border + left);
					geometry.setHeight(bounds.getHeight() + 2 * border + top);
					graph.getModel().setGeometry(group, geometry);
					graph.moveCells(children, border + left - bounds.getX(),
							border + top - bounds.getY());
				}
			}
		}
		finally
		{
			graph.getModel().endUpdate();
		}
	}
}
