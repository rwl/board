part of graph.shape;

//import java.awt.Color;
//import java.awt.GradientPaint;
//import java.awt.Rectangle;
//import java.awt.geom.GeneralPath;

class LabelShape extends ImageShape {

  void paintShape(Graphics2DCanvas canvas, CellState state) {
    super.paintShape(canvas, state);

    if (Utils.isTrue(state.getStyle(), Constants.STYLE_GLASS, false)) {
      drawGlassEffect(canvas, state);
    }
  }

  /**
   * Draws the glass effect
   */
  static void drawGlassEffect(Graphics2DCanvas canvas, CellState state) {
    double size = 0.4;
    canvas.getGraphics().setPaint(new GradientPaint(state.getX() as double, state.getY() as double,
        new awt.Color.double(1.0, 1.0, 1.0, 0.9), (state.getX()) as double, (state.getY() + state.getHeight() * size) as double, new awt.Color(1, 1, 1, 0.3)));

    double sw = (Utils.getFloat(state.getStyle(), Constants.STYLE_STROKEWIDTH, 1.0) * canvas.getScale() / 2);

    awt.GeneralPath path = new awt.GeneralPath();
    path.moveTo(state.getX() - sw, state.getY() - sw);
    path.lineTo(state.getX() - sw, (state.getY() + state.getHeight() * size));
    path.quadTo((state.getX() + state.getWidth() * 0.5), (state.getY() + state.getHeight() * 0.7),
        (state.getX() + state.getWidth() + sw), (state.getY() + state.getHeight() * size));
    path.lineTo((state.getX() + state.getWidth() + sw), state.getY() - sw);
    path.closePath();

    canvas.getGraphics().fill(path);
  }

  awt.Rectangle getImageBounds(Graphics2DCanvas canvas, CellState state) {
    Map<String, Object> style = state.getStyle();
    double scale = canvas.getScale();
    String imgAlign = Utils.getString(style, Constants.STYLE_IMAGE_ALIGN, Constants.ALIGN_LEFT);
    String imgValign = Utils.getString(style, Constants.STYLE_IMAGE_VERTICAL_ALIGN, Constants.ALIGN_MIDDLE);
    int imgWidth = (Utils.getInt(style, Constants.STYLE_IMAGE_WIDTH, Constants.DEFAULT_IMAGESIZE) * scale) as int;
    int imgHeight = (Utils.getInt(style, Constants.STYLE_IMAGE_HEIGHT, Constants.DEFAULT_IMAGESIZE) * scale) as int;
    int spacing = (Utils.getInt(style, Constants.STYLE_SPACING, 2) * scale) as int;

    Rect imageBounds = new Rect.from(state);

    if (imgAlign == Constants.ALIGN_CENTER) {
      imageBounds.setX(imageBounds.getX() + (imageBounds.getWidth() - imgWidth) / 2);
    } else if (imgAlign == Constants.ALIGN_RIGHT) {
      imageBounds.setX(imageBounds.getX() + imageBounds.getWidth() - imgWidth - spacing - 2);
    } else // LEFT
    {
      imageBounds.setX(imageBounds.getX() + spacing + 4);
    }

    if (imgValign == Constants.ALIGN_TOP) {
      imageBounds.setY(imageBounds.getY() + spacing);
    } else if (imgValign == Constants.ALIGN_BOTTOM) {
      imageBounds.setY(imageBounds.getY() + imageBounds.getHeight() - imgHeight - spacing);
    } else // MIDDLE
    {
      imageBounds.setY(imageBounds.getY() + (imageBounds.getHeight() - imgHeight) / 2);
    }

    imageBounds.setWidth(imgWidth.toDouble());
    imageBounds.setHeight(imgHeight.toDouble());

    return imageBounds.getRectangle();
  }

  awt.Color getFillColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_FILLCOLOR);
  }

  awt.Color getStrokeColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_STROKECOLOR);
  }

  bool hasGradient(Graphics2DCanvas canvas, CellState state) {
    return true;
  }

}
