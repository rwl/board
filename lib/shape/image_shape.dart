/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import java.awt.Color;
//import java.awt.Rectangle;

/**
 * A rectangular shape that contains a single image. See ImageBundle for
 * creating a lookup table with images which can then be referenced by key.
 */
class ImageShape extends RectangleShape {

  /**
	 * 
	 */
  void paintShape(Graphics2DCanvas canvas, CellState state) {
    super.paintShape(canvas, state);

    bool flipH = Utils.isTrue(state.getStyle(), Constants.STYLE_IMAGE_FLIPH, false);
    bool flipV = Utils.isTrue(state.getStyle(), Constants.STYLE_IMAGE_FLIPV, false);

    canvas.drawImage(getImageBounds(canvas, state), getImageForStyle(canvas, state), Graphics2DCanvas.PRESERVE_IMAGE_ASPECT, flipH, flipV);
  }

  /**
	 * 
	 */
  Rectangle getImageBounds(Graphics2DCanvas canvas, CellState state) {
    return state.getRectangle();
  }

  /**
	 * 
	 */
  bool hasGradient(Graphics2DCanvas canvas, CellState state) {
    return false;
  }

  /**
	 * 
	 */
  String getImageForStyle(Graphics2DCanvas canvas, CellState state) {
    return canvas.getImageForStyle(state.getStyle());
  }

  /**
	 * 
	 */
  Color getFillColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_IMAGE_BACKGROUND);
  }

  /**
	 * 
	 */
  Color getStrokeColor(Graphics2DCanvas canvas, CellState state) {
    return Utils.getColor(state.getStyle(), Constants.STYLE_IMAGE_BORDER);
  }

}
