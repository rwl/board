part of graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.util.Constants;
//import graph.util.Utils;
//import graph.view.CellState;

//import java.awt.Polygon;
//import java.awt.Rectangle;
//import java.awt.Shape;

public class HexagonShape extends BasicShape
{

	/**
	 * 
	 */
	public Shape createShape(Graphics2DCanvas canvas, CellState state)
	{
		Rectangle temp = state.getRectangle();
		int x = temp.x;
		int y = temp.y;
		int w = temp.width;
		int h = temp.height;
		String direction = Utils.getString(state.getStyle(),
				Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);
		Polygon hexagon = new Polygon();

		if (direction.equals(Constants.DIRECTION_NORTH)
				|| direction.equals(Constants.DIRECTION_SOUTH))
		{
			hexagon.addPoint(x + (int) (0.5 * w), y);
			hexagon.addPoint(x + w, y + (int) (0.25 * h));
			hexagon.addPoint(x + w, y + (int) (0.75 * h));
			hexagon.addPoint(x + (int) (0.5 * w), y + h);
			hexagon.addPoint(x, y + (int) (0.75 * h));
			hexagon.addPoint(x, y + (int) (0.25 * h));
		}
		else
		{
			hexagon.addPoint(x + (int) (0.25 * w), y);
			hexagon.addPoint(x + (int) (0.75 * w), y);
			hexagon.addPoint(x + w, y + (int) (0.5 * h));
			hexagon.addPoint(x + (int) (0.75 * w), y + h);
			hexagon.addPoint(x + (int) (0.25 * w), y + h);
			hexagon.addPoint(x, y + (int) (0.5 * h));
		}

		return hexagon;
	}

}
