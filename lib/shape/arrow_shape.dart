part of graph.shape;

//import java.awt.Polygon;
//import java.awt.Shape;

class ArrowShape extends BasicShape {

  /**
   *
   */
  Shape createShape(Graphics2DCanvas canvas, CellState state) {
    double scale = canvas.getScale();
    Point2d p0 = state.getAbsolutePoint(0);
    Point2d pe = state.getAbsolutePoint(state.getAbsolutePointCount() - 1);

    // Geometry of arrow
    double spacing = Constants.ARROW_SPACING * scale;
    double width = Constants.ARROW_WIDTH * scale;
    double arrow = Constants.ARROW_SIZE * scale;

    double dx = pe.getX() - p0.getX();
    double dy = pe.getY() - p0.getY();
    double dist = Math.sqrt(dx * dx + dy * dy);
    double length = dist - 2 * spacing - arrow;

    // Computes the norm and the inverse norm
    double nx = dx / dist;
    double ny = dy / dist;
    double basex = length * nx;
    double basey = length * ny;
    double floorx = width * ny / 3;
    double floory = -width * nx / 3;

    // Computes points
    double p0x = p0.getX() - floorx / 2 + spacing * nx;
    double p0y = p0.getY() - floory / 2 + spacing * ny;
    double p1x = p0x + floorx;
    double p1y = p0y + floory;
    double p2x = p1x + basex;
    double p2y = p1y + basey;
    double p3x = p2x + floorx;
    double p3y = p2y + floory;
    // p4 not required
    double p5x = p3x - 3 * floorx;
    double p5y = p3y - 3 * floory;

    Polygon poly = new Polygon();
    poly.addPoint(math.round(p0x) as int, math.round(p0y) as int);
    poly.addPoint(math.round(p1x) as int, math.round(p1y) as int);
    poly.addPoint(math.round(p2x) as int, math.round(p2y) as int);
    poly.addPoint(math.round(p3x) as int, math.round(p3y) as int);
    poly.addPoint(math.round(pe.getX() - spacing * nx) as int, math.round(pe.getY() - spacing * ny) as int);
    poly.addPoint(math.round(p5x) as int, math.round(p5y) as int);
    poly.addPoint(math.round(p5x + floorx) as int, math.round(p5y + floory) as int);

    return poly;
  }

}
