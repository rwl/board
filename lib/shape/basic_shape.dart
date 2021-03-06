/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import java.awt.Color;
//import java.awt.Paint;
//import java.awt.Shape;

class BasicShape implements IShape {

  void paintShape(Graphics2DCanvas canvas, CellState state) {
    awt.Shape shape = createShape(canvas, state);

    if (shape != null) {
      // Paints the background
      if (_configureGraphics(canvas, state, true)) {
        canvas.fillShape(shape, hasShadow(canvas, state));
      }

      // Paints the foreground
      if (_configureGraphics(canvas, state, false)) {
        canvas.getGraphics().draw(shape);
      }
    }
  }

  awt.Shape createShape(Graphics2DCanvas canvas, CellState state) {
    return null;
  }

  /**
   * Configures the graphics object ready to paint.
   * @param canvas the canvas to be painted to
   * @param state the state of cell to be painted
   * @param background whether or not this is the background stage of 
   * 			the shape paint
   * @return whether or not the shape is ready to be drawn
   */
  bool _configureGraphics(Graphics2DCanvas canvas, CellState state, bool background) {
    Map<String, Object> style = state.getStyle();

    if (background) {
      // Paints the background of the shape
      awt.Paint fillPaint = hasGradient(canvas, state) ? canvas.createFillPaint(_getGradientBounds(canvas, state), style) : null;

      if (fillPaint != null) {
        canvas.getGraphics().setPaint(fillPaint);

        return true;
      } else {
        awt.Color color = getFillColor(canvas, state);
        canvas.getGraphics().setColor(color);

        return color != null;
      }
    } else {
      canvas.getGraphics().setPaint(null);
      awt.Color color = getStrokeColor(canvas, state);
      canvas.getGraphics().setColor(color);
      canvas.getGraphics().setStroke(canvas.createStroke(style));

      return color != null;
    }
  }

  Rect _getGradientBounds(Graphics2DCanvas canvas, CellState state) {
    return state;
  }

  bool hasGradient(Graphics2DCanvas canvas, CellState state) {
    return true;
  }

  bool hasShadow(Graphics2DCanvas canvas, CellState state) {
    return Utils.isTrue(state.getStyle(), Constants.STYLE_SHADOW, false);
  }

  awt.Color getFillColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_FILLCOLOR);
  }

  awt.Color getStrokeColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_STROKECOLOR);
  }

}
