/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.util;

//import java.awt.Color;
//import java.awt.Point;
//import java.awt.awt.Rectangle;
//import java.awt.image.BufferedImage;

//import org.w3c.dom.Document;


/**
 * Separates the creation of the canvas from its initialization, when the
 * size of the required graphics buffer / document / container is known.
 */
typedef ICanvas CanvasFactory(int width, int height);

class CellRenderer {
  factory CellRenderer() {
    // static class
    return null;
  }

  /**
   * Draws the given cells using a Graphics2D canvas and returns the buffered image
   * that represents the cells.
   * 
   * @param graph Graph to be painted onto the canvas.
   * @return Returns the image that represents the canvas.
   */
  static ICanvas drawCells(Graph graph, List<Object> cells, double scale, Rect clip, CanvasFactory factory) {
    ICanvas canvas = null;

    if (cells == null) {
      cells = [graph.getModel().getRoot()];
    }

    // Gets the current state of the view
    GraphView view = graph.getView();

    // Keeps the existing translation as the cells might
    // be aligned to the grid in a different way in a graph
    // that has a translation other than zero
    bool eventsEnabled = view.isEventsEnabled();

    // Disables firing of scale events so that there is no
    // repaint or update of the original graph
    view.setEventsEnabled(false);

    // Uses the view to create temporary cell states for each cell
    TemporaryCellStates temp = new TemporaryCellStates(view, scale, cells);

    try {
      if (clip == null) {
        clip = graph.getPaintBounds(cells);
      }

      if (clip != null && clip.getWidth() > 0 && clip.getHeight() > 0) {
        awt.Rectangle rect = clip.getRectangle();
        canvas = factory(rect.width + 1, rect.height + 1);

        if (canvas != null) {
          double previousScale = canvas.getScale();
          awt.Point previousTranslate = canvas.getTranslate();

          try {
            canvas.setTranslate(-rect.x, -rect.y);
            canvas.setScale(view.getScale());

            for (int i = 0; i < cells.length; i++) {
              graph.drawCell(canvas, cells[i]);
            }
          } finally {
            canvas.setScale(previousScale);
            canvas.setTranslate(previousTranslate.x, previousTranslate.y);
          }
        }
      }
    } finally {
      temp.destroy();
      view.setEventsEnabled(eventsEnabled);
    }

    return canvas;
  }

  //	static BufferedImage createBufferedImage(Graph graph,
  //			List<Object> cells, double scale, Color background, bool antiAlias,
  //			Rect clip)
  //	{
  //		return createBufferedImage(graph, cells, scale, background, antiAlias,
  //				clip, new Graphics2DCanvas());
  //	}

  static image.Image createBufferedImage(Graph graph, List<Object> cells, double scale, final awt.Color background, final bool antiAlias, Rect clip, [/*final*/ Graphics2DCanvas graphicsCanvas = null]) {
    if (graphicsCanvas == null) {
      graphicsCanvas = new Graphics2DCanvas();
    }
    ImageCanvas canvas = drawCells(graph, cells, scale, clip, (int width, int height) {
      return new ImageCanvas(graphicsCanvas, width, height, background, antiAlias);
    }) as ImageCanvas;

    return (canvas != null) ? canvas.destroy() : null;
  }

  static Document createHtmlDocument(Graph graph, List<Object> cells, double scale, awt.Color background, Rect clip) {
    HtmlCanvas canvas = drawCells(graph, cells, scale, clip, (int width, int height) {
      return new HtmlCanvas(DomUtils.createHtmlDocument());
    }) as HtmlCanvas;

    return canvas.getDocument();
  }

  static Document createSvgDocument(Graph graph, List<Object> cells, double scale, awt.Color background, Rect clip) {
    SvgCanvas canvas = drawCells(graph, cells, scale, clip, (int width, int height) {
      return new SvgCanvas(DomUtils.createSvgDocument(width, height));
    }) as SvgCanvas;

    return canvas.getDocument();
  }

  static Document createVmlDocument(Graph graph, List<Object> cells, double scale, awt.Color background, Rect clip) {
    VmlCanvas canvas = drawCells(graph, cells, scale, clip, (int width, int height) {
      return new VmlCanvas(DomUtils.createVmlDocument());
    }) as VmlCanvas;

    return canvas.getDocument();
  }

  //	static abstract class CanvasFactory
  //	{
  //
  //		/**
  //	   * Separates the creation of the canvas from its initialization, when the
  //	   * size of the required graphics buffer / document / container is known.
  //	   */
  //		public abstract ICanvas createCanvas(int width, int height);
  //
  //	}

}
