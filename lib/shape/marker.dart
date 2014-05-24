part of graph.shape;

public interface IMarker
{
	/**
	 * 
	 */
	Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type,
			Point2d pe, double nx, double ny, double size, bool source);

}
