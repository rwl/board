part of graph.shape;

//import java.awt.Rectangle;

class DoubleRectangleShape extends RectangleShape {

  /**
	 * 
	 */
  void paintShape(Graphics2DCanvas canvas, CellState state) {
    super.paintShape(canvas, state);

    int inset = math.round((Utils.getFloat(state.getStyle(), Constants.STYLE_STROKEWIDTH, 1) + 3) * canvas.getScale()) as int;

    harmony.Rectangle rect = state.getRectangle();
    int x = rect.x + inset;
    int y = rect.y + inset;
    int w = rect.width - 2 * inset;
    int h = rect.height - 2 * inset;

    canvas.getGraphics().drawRect(x, y, w, h);
  }

}
