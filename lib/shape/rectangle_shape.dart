/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.shape;

//import java.awt.Rectangle;

class RectangleShape extends BasicShape {

  void paintShape(Graphics2DCanvas canvas, CellState state) {
    Map<String, Object> style = state.getStyle();

    if (Utils.isTrue(style, Constants.STYLE_ROUNDED, false)) {
      awt.Rectangle tmp = state.getRectangle();

      int x = tmp.x;
      int y = tmp.y;
      int w = tmp.width;
      int h = tmp.height;
      int radius = getArcSize(w, h);

      bool shadow = hasShadow(canvas, state);
      int shadowOffsetX = (shadow) ? Constants.SHADOW_OFFSETX : 0;
      int shadowOffsetY = (shadow) ? Constants.SHADOW_OFFSETY : 0;

      if (canvas.getGraphics().hitClip(x, y, w + shadowOffsetX, h + shadowOffsetY)) {
        // Paints the optional shadow
        if (shadow) {
          canvas.getGraphics().setColor(SwingConstants.SHADOW_COLOR);
          canvas.getGraphics().fillRoundRect(x + Constants.SHADOW_OFFSETX, y + Constants.SHADOW_OFFSETY, w, h, radius, radius);
        }

        // Paints the background
        if (_configureGraphics(canvas, state, true)) {
          canvas.getGraphics().fillRoundRect(x, y, w, h, radius, radius);
        }

        // Paints the foreground
        if (_configureGraphics(canvas, state, false)) {
          canvas.getGraphics().drawRoundRect(x, y, w, h, radius, radius);
        }
      }
    } else {
      awt.Rectangle rect = state.getRectangle();

      // Paints the background
      if (_configureGraphics(canvas, state, true)) {
        canvas.fillShape(rect, hasShadow(canvas, state));
      }

      // Paints the foreground
      if (_configureGraphics(canvas, state, false)) {
        canvas.getGraphics().drawRect(rect.x, rect.y, rect.width, rect.height);
      }
    }
  }

  /**
   * Computes the arc size for the given dimension.
   * 
   * @param w Width of the rectangle.
   * @param h Height of the rectangle.
   * @return Returns the arc size for the given dimension.
   */
  int getArcSize(int w, int h) {
    int arcSize;

    if (w <= h) {
      arcSize = math.round(h * Constants.RECTANGLE_ROUNDING_FACTOR) as int;

      if (arcSize > (w / 2)) {
        arcSize = (w / 2) as int;
      }
    } else {
      arcSize = math.round(w * Constants.RECTANGLE_ROUNDING_FACTOR) as int;

      if (arcSize > (h / 2)) {
        arcSize = (h / 2) as int;
      }
    }
    return arcSize;
  }

}
