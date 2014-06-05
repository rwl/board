part of graph.shape;

//import java.awt.Polygon;
//import java.awt.Rectangle;
//import java.awt.Shape;

class RhombusShape extends BasicShape {

  /**
   * 
   */
  Shape createShape(Graphics2DCanvas canvas, CellState state) {
    awt.Rectangle temp = state.getRectangle();
    int x = temp.x;
    int y = temp.y;
    int w = temp.width;
    int h = temp.height;
    int halfWidth = (w / 2) as int;
    int halfHeight = (h / 2) as int;

    Polygon rhombus = new Polygon();
    rhombus.addPoint(x + halfWidth, y);
    rhombus.addPoint(x + w, y + halfHeight);
    rhombus.addPoint(x + halfWidth, y + h);
    rhombus.addPoint(x, y + halfHeight);

    return rhombus;
  }

}
