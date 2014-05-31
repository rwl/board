part of graph.shape;

//import java.awt.Rectangle;
//import java.awt.geom.Area;
//import java.awt.geom.Ellipse2D;

class CylinderShape extends BasicShape {

  /**
	 * Draws a cylinder for the given parameters.
	 */
  void paintShape(Graphics2DCanvas canvas, CellState state) {
    harmony.Rectangle rect = state.getRectangle();
    int x = rect.x;
    int y = rect.y;
    int w = rect.width;
    int h = rect.height;
    int h4 = (h / 4) as int;
    int h2 = (h4 / 2) as int;
    int r = w;

    // Paints the background
    if (_configureGraphics(canvas, state, true)) {
      Area area = new Area(new harmony.Rectangle(x, y + h4 / 2, r, h - h4));
      area.add(new Area(new harmony.Rectangle(x, y + h4 / 2, r, h - h4)));
      area.add(new Area(new Ellipse2D.Float(x, y, r, h4)));
      area.add(new Area(new Ellipse2D.Float(x, y + h - h4, r, h4)));

      canvas.fillShape(area, hasShadow(canvas, state));
    }

    // Paints the foreground
    if (_configureGraphics(canvas, state, false)) {
      canvas.getGraphics().drawOval(x, y, r, h4);
      canvas.getGraphics().drawLine(x, y + h2, x, y + h - h2);
      canvas.getGraphics().drawLine(x + w, y + h2, x + w, y + h - h2);
      // TODO: Use QuadCurve2D.Float() for painting the arc
      canvas.getGraphics().drawArc(x, y + h - h4, r, h4, 0, -180);
    }
  }

}
