part of graph.shape;

//import java.awt.Polygon;
//import java.awt.Rectangle;
//import java.awt.Shape;

class HexagonShape extends BasicShape
{

	/**
	 * 
	 */
	Shape createShape(Graphics2DCanvas canvas, CellState state)
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
			hexagon.addPoint(x + (0.5 * w) as int, y);
			hexagon.addPoint(x + w, y + (0.25 * h) as int);
			hexagon.addPoint(x + w, y + (0.75 * h) as int);
			hexagon.addPoint(x + (0.5 * w) as int, y + h);
			hexagon.addPoint(x, y + (0.75 * h) as int);
			hexagon.addPoint(x, y + (0.25 * h) as int);
		}
		else
		{
			hexagon.addPoint(x + (0.25 * w) as int, y);
			hexagon.addPoint(x + (0.75 * w) as int, y);
			hexagon.addPoint(x + w, y + (0.5 * h) as int);
			hexagon.addPoint(x + (0.75 * w) as int, y + h);
			hexagon.addPoint(x + (0.25 * w) as int, y + h);
			hexagon.addPoint(x, y + (0.5 * h) as int);
		}

		return hexagon;
	}

}
