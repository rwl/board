/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import java.awt.Graphics2D;
//import java.awt.Rectangle;

//import javax.swing.CellRendererPane;

/**
 * To set global CSS for all HTML labels, use the following code:
 * 
 * <pre>
 * Graphics2DCanvas.putTextShape(Graphics2DCanvas.TEXT_SHAPE_HTML,
 *   new HtmlTextShape()
 *   {
 *     protected String createHtmlDocument(Map<String, Object> style, String text)
 *     {
 *       return Utils.createHtmlDocument(style, text, 1, 0,
 *           "<style type=\"text/css\">.selectRef { " +
 *           "font-size:9px;font-weight:normal; }</style>");
 *     }
 *   }
 * );
 * </pre> 
 */
class HtmlTextShape implements ITextShape {

  /**
   * Specifies if linefeeds should be replaced with breaks in HTML markup.
   * Default is true.
   */
  bool _replaceHtmlLinefeeds = true;

  /**
   * Returns replaceHtmlLinefeeds
   */
  bool isReplaceHtmlLinefeeds() {
    return _replaceHtmlLinefeeds;
  }

  /**
   * Returns replaceHtmlLinefeeds
   */
  void setReplaceHtmlLinefeeds(bool value) {
    _replaceHtmlLinefeeds = value;
  }

  String _createHtmlDocument(Map<String, Object> style, String text, int w, int h) {
    String overflow = Utils.getString(style, Constants.STYLE_OVERFLOW, "");

    if (overflow == "fill") {
      return Utils.createHtmlDocument(style, text, 1.0, w, null, "height:${h}pt;");
    } else if (overflow == "width") {
      return Utils.createHtmlDocument(style, text, 1.0, w);
    } else {
      return Utils.createHtmlDocument(style, text);
    }
  }

  void paintShape(Graphics2DCanvas canvas, String text, CellState state, Map<String, Object> style) {
    LightweightLabel textRenderer = LightweightLabel.getSharedInstance();
    CellRendererPane rendererPane = canvas.getRendererPane();
    awt.Rectangle rect = state.getLabelBounds().getRectangle();
    Graphics2D g = canvas.getGraphics();

    if (textRenderer != null && rendererPane != null && (g.getClipBounds() == null || g.getClipBounds().intersects(rect))) {
      double scale = canvas.getScale();
      int x = rect.x;
      int y = rect.y;
      int w = rect.width;
      int h = rect.height;

      if (!Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
        g.rotate(-Math.PI / 2, x + w / 2, y + h / 2);
        g.translate(w / 2 - h / 2, h / 2 - w / 2);

        int tmp = w;
        w = h;
        h = tmp;
      }

      // Replaces the linefeeds with BR tags
      if (isReplaceHtmlLinefeeds()) {
        text = text.replaceAll("\n", "<br>");
      }

      // Renders the scaled text
      textRenderer.setText(_createHtmlDocument(style, text, math.round(w / state.getView().getScale()) as int, math.round(h / state.getView().getScale()) as int));
      textRenderer.setFont(Utils.getFont(style, canvas.getScale()));
      g.scale(scale, scale);
      rendererPane.paintComponent(g, textRenderer, rendererPane, (x / scale) + Constants.LABEL_INSET as int, (y / scale) + Constants.LABEL_INSET as int, (w / scale) as int, (h / scale) as int, true);
    }
  }

}
