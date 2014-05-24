part of graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../util/util.dart' show Constants;
import '../util/util.dart' show Point2d;
import '../util/util.dart' show Utils;
import '../view/view.dart' show CellState;

class LineShape extends BasicShape
{

	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		if (_configureGraphics(canvas, state, false))
		{
			bool rounded = Utils.isTrue(state.getStyle(),
					Constants.STYLE_ROUNDED, false)
					&& canvas.getScale() > Constants.MIN_SCALE_FOR_ROUNDED_LINES;

			canvas.paintPolyline(createPoints(canvas, state), rounded);
		}
	}

	/**
	 * 
	 */
	Point2d[] createPoints(Graphics2DCanvas canvas, CellState state)
	{
		String direction = Utils.getString(state.getStyle(),
				Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);

		Point2d p0, pe;

		if (direction.equals(Constants.DIRECTION_EAST)
				|| direction.equals(Constants.DIRECTION_WEST))
		{
			double mid = state.getCenterY();
			p0 = new Point2d(state.getX(), mid);
			pe = new Point2d(state.getX() + state.getWidth(), mid);
		}
		else
		{
			double mid = state.getCenterX();
			p0 = new Point2d(mid, state.getY());
			pe = new Point2d(mid, state.getY() + state.getHeight());
		}

		Point2d[] points = new Point2d[2];
		points[0] = p0;
		points[1] = pe;

		return points;
	}

}
