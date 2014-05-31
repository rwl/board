part of graph.shape;

//import java.awt.Polygon;
//import java.awt.Rectangle;
//import java.awt.Shape;

class TriangleShape extends BasicShape {

  /**
	 * 
	 */
  Shape createShape(Graphics2DCanvas canvas, CellState state) {
    harmony.Rectangle temp = state.getRectangle();
    int x = temp.x;
    int y = temp.y;
    int w = temp.width;
    int h = temp.height;
    String direction = Utils.getString(state.getStyle(), Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);
    Polygon triangle = new Polygon();

    if (direction.equals(Constants.DIRECTION_NORTH)) {
      triangle.addPoint(x, y + h);
      triangle.addPoint(x + w / 2, y);
      triangle.addPoint(x + w, y + h);
    } else if (direction.equals(Constants.DIRECTION_SOUTH)) {
      triangle.addPoint(x, y);
      triangle.addPoint(x + w / 2, y + h);
      triangle.addPoint(x + w, y);
    } else if (direction.equals(Constants.DIRECTION_WEST)) {
      triangle.addPoint(x + w, y);
      triangle.addPoint(x, y + h / 2);
      triangle.addPoint(x + w, y + h);
    } else // EAST
    {
      triangle.addPoint(x, y);
      triangle.addPoint(x + w, y + h / 2);
      triangle.addPoint(x, y + h);
    }

    return triangle;
  }

}
