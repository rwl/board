part of graph.shape;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.geom.GeneralPath;

class CloudShape extends BasicShape {

  /**
   * 
   */
  Shape createShape(Graphics2DCanvas canvas, CellState state) {
    awt.Rectangle temp = state.getRectangle();
    int x = temp.x;
    int y = temp.y;
    int w = temp.width;
    int h = temp.height;
    GeneralPath path = new GeneralPath();

    path.moveTo((x + 0.25 * w) as float, (y + 0.25 * h) as float);
    path.curveTo((x + 0.05 * w) as float, (y + 0.25 * h) as float, x, (y + 0.5 * h) as float, (x + 0.16 * w) as float, (y + 0.55 * h) as float);
    path.curveTo(x, (y + 0.66 * h) as float, (x + 0.18 * w) as float, (y + 0.9 * h) as float, (x + 0.31 * w) as float, (y + 0.8 * h) as float);
    path.curveTo((x + 0.4 * w) as float, (y + h), (x + 0.7 * w) as float, (y + h), (x + 0.8 * w) as float, (y + 0.8 * h) as float);
    path.curveTo((x + w), (y + 0.8 * h) as float, (x + w), (y + 0.6 * h) as float, (x + 0.875 * w) as float, (y + 0.5 * h) as float);
    path.curveTo((x + w), (y + 0.3 * h) as float, (x + 0.8 * w) as float, (y + 0.1 * h) as float, (x + 0.625 * w) as float, (y + 0.2 * h) as float);
    path.curveTo((x + 0.5 * w) as float, (y + 0.05 * h) as float, (x + 0.3 * w) as float, (y + 0.05 * h) as float, (x + 0.25 * w) as float, (y + 0.25 * h) as float);
    path.closePath();

    return path;
  }

}
