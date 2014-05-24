part of graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../util/util.dart' show Point2d;
import '../view/view.dart' show CellState;

public interface IMarker
{
	/**
	 * 
	 */
	Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type,
			Point2d pe, double nx, double ny, double size, bool source);

}
