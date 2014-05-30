/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.canvas;

//import java.awt.Color;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.image.BufferedImage;

/**
 * An implementation of a canvas that uses Graphics2D for painting. To use an
 * image canvas for an existing graphics canvas and create an image the
 * following code is used:
 * 
 * <code>BufferedImage image = CellRenderer.createBufferedImage(graph, cells, 1, Color.white, true, null, canvas);</code> 
 */
class ImageCanvas implements ICanvas {

  /**
	 * 
	 */
  Graphics2DCanvas _canvas;

  /**
	 * 
	 */
  Graphics2D _previousGraphics;

  /**
	 * 
	 */
  image.Image _image;

  /**
	 * 
	 */
  ImageCanvas(Graphics2DCanvas canvas, int width, int height, color.Color background, bool antiAlias) {
    this._canvas = canvas;
    _previousGraphics = canvas.getGraphics();
    _image = Utils.createBufferedImage(width, height, background);

    if (_image != null) {
      Graphics2D g = _image.createGraphics();
      Utils.setAntiAlias(g, antiAlias, true);
      canvas.setGraphics(g);
    }
  }

  /**
	 * 
	 */
  Graphics2DCanvas getGraphicsCanvas() {
    return _canvas;
  }

  /**
	 * 
	 */
  image.Image getImage() {
    return _image;
  }

  /**
	 * 
	 */
  Object drawCell(CellState state) {
    return _canvas.drawCell(state);
  }

  /**
	 * 
	 */
  Object drawLabel(String label, CellState state, bool html) {
    return _canvas.drawLabel(label, state, html);
  }

  /**
	 * 
	 */
  double getScale() {
    return _canvas.getScale();
  }

  /**
	 * 
	 */
  Point getTranslate() {
    return _canvas.getTranslate();
  }

  /**
	 * 
	 */
  void setScale(double scale) {
    _canvas.setScale(scale);
  }

  /**
	 * 
	 */
  void setTranslate(int dx, int dy) {
    _canvas.setTranslate(dx, dy);
  }

  /**
	 * 
	 */
  image.Image destroy() {
    image.Image tmp = _image;

    if (_canvas.getGraphics() != null) {
      _canvas.getGraphics().dispose();
    }

    _canvas.setGraphics(_previousGraphics);

    _previousGraphics = null;
    _canvas = null;
    _image = null;

    return tmp;
  }

}
