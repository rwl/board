part of graph.shape;

/*abstract class IMarker
{
	/**
	 * 
	 */
	Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type,
			Point2d pe, double nx, double ny, double size, bool source);

}*/

typedef Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type, Point2d pe, double nx, double ny, double size, bool source);
