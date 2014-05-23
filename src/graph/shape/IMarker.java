package graph.shape;

import graph.canvas.Graphics2DCanvas;
import graph.util.Point2d;
import graph.view.CellState;

public interface IMarker
{
	/**
	 * 
	 */
	Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type,
			Point2d pe, double nx, double ny, double size, boolean source);

}
