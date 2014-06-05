part of graph.shape;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.geom.Ellipse2D;

class EllipseShape extends BasicShape {

  /**
   * 
   */
  Shape createShape(Graphics2DCanvas canvas, CellState state) {
    awt.Rectangle temp = state.getRectangle();

    return new Ellipse2D.Float(temp.x, temp.y, temp.width, temp.height);
  }

}
