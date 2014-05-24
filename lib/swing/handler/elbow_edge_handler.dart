/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;
//import java.util.List;

/**
 * @author Administrator
 * 
 */
class ElbowEdgeHandler extends EdgeHandler
{

	/**
	 * 
	 * @param graphComponent
	 * @param state
	 */
	ElbowEdgeHandler(GraphComponent graphComponent, CellState state)
	{
		super(graphComponent, state);
	}

	/**
	 * Hook for subclassers to return tooltip texts for certain points on the
	 * handle.
	 */
	String getToolTipText(MouseEvent e)
	{
		int index = getIndexAt(e.getX(), e.getY());

		if (index == 1)
		{
			return Resources.get("doubleClickOrientation");
		}

		return null;
	}

	/**
	 * 
	 */
	bool _isFlipEvent(MouseEvent e)
	{
		return e.getClickCount() == 2 && _index == 1;
	}

	/**
	 * Returns true if the given index is the index of the last handle.
	 */
	bool isLabel(int index)
	{
		return index == 3;
	}

	/**
	 * 
	 */
	Rectangle[] _createHandles()
	{
		_p = _createPoints(_state);
		Rectangle[] h = new Rectangle[4];

		Point2d p0 = _state.getAbsolutePoint(0);
		Point2d pe = _state.getAbsolutePoint(_state.getAbsolutePointCount() - 1);

		h[0] = _createHandle(p0.getPoint());
		h[2] = _createHandle(pe.getPoint());

		// Creates the middle green edge handle
		Geometry geometry = _graphComponent.getGraph().getModel().getGeometry(
				_state.getCell());
		List<Point2d> points = geometry.getPoints();
		Point pt = null;

		if (points == null || points.isEmpty())
		{
			pt = new Point((int) (Math.round(p0.getX()) + Math
					.round((pe.getX() - p0.getX()) / 2)), (int) (Math.round(p0
					.getY()) + Math.round((pe.getY() - p0.getY()) / 2)));
		}
		else
		{
			GraphView view = _graphComponent.getGraph().getView();
			pt = view.transformControlPoint(_state, points.get(0))
					.getPoint();
		}

		// Create the green middle handle
		h[1] = _createHandle(pt);

		// Creates the yellow label handle
		h[3] = _createHandle(_state.getAbsoluteOffset().getPoint(),
				Constants.LABEL_HANDLE_SIZE);

		// Makes handle slightly bigger if the yellow label handle
		// exists and intersects this green handle
		if (_isHandleVisible(3) && h[1].intersects(h[3]))
		{
			h[1] = _createHandle(pt, Constants.HANDLE_SIZE + 3);
		}

		return h;
	}

}
