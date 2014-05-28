/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.canvas;

//import java.util.Hashtable;
//import java.util.List;
//import java.util.Map;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * An implementation of a canvas that uses HTML for painting.
 */
class HtmlCanvas extends BasicCanvas {

  /**
	 * Holds the HTML document that represents the canvas.
	 */
  Document _document;

  /**
	 * Constructs a new HTML canvas for the specified dimension and scale.
	 */
  HtmlCanvas() {
    this(null);
  }

  /**
	 * Constructs a new HTML canvas for the specified bounds, scale and
	 * background color.
	 */
  HtmlCanvas(Document document) {
    setDocument(document);
  }

  /**
	 * 
	 */
  void appendHtmlElement(Element node) {
    if (_document != null) {
      Node body = _document.getDocumentElement().getFirstChild().getNextSibling();

      if (body != null) {
        body.appendChild(node);
      }
    }
  }

  /**
	 * 
	 */
  void setDocument(Document document) {
    this._document = document;
  }

  /**
	 * Returns a reference to the document that represents the canvas.
	 * 
	 * @return Returns the document.
	 */
  Document getDocument() {
    return _document;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawCell()
	 */
  Object drawCell(CellState state) {
    Map<String, Object> style = state.getStyle();

    if (state.getAbsolutePointCount() > 1) {
      List<Point2d> pts = state.getAbsolutePoints();

      // Transpose all points by cloning into a new array
      pts = Utils.translatePoints(pts, _translate.x, _translate.y);
      drawLine(pts, style);
    } else {
      int x = state.getX() + _translate.x as int;
      int y = state.getY() + _translate.y as int;
      int w = state.getWidth() as int;
      int h = state.getHeight() as int;

      if (!Utils.getString(style, Constants.STYLE_SHAPE, "").equals(Constants.SHAPE_SWIMLANE)) {
        drawShape(x, y, w, h, style);
      } else {
        int start = Math.round(Utils.getInt(style, Constants.STYLE_STARTSIZE, Constants.DEFAULT_STARTSIZE) * _scale) as int;

        // Removes some styles to draw the content area
        Map<String, Object> cloned = new Hashtable<String, Object>(style);
        cloned.remove(Constants.STYLE_FILLCOLOR);
        cloned.remove(Constants.STYLE_ROUNDED);

        if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
          drawShape(x, y, w, start, style);
          drawShape(x, y + start, w, h - start, cloned);
        } else {
          drawShape(x, y, start, h, style);
          drawShape(x + start, y, w - start, h, cloned);
        }
      }
    }

    return null;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawLabel()
	 */
  Object drawLabel(String label, CellState state, bool html) {
    Rect bounds = state.getLabelBounds();

    if (_drawLabels && bounds != null) {
      int x = bounds.getX() + _translate.x as int;
      int y = bounds.getY() + _translate.y as int;
      int w = bounds.getWidth() as int;
      int h = bounds.getHeight() as int;
      Map<String, Object> style = state.getStyle();

      return drawText(label, x, y, w, h, style);
    }

    return null;
  }

  /**
	 * Draws the shape specified with the STYLE_SHAPE key in the given style.
	 * 
	 * @param x X-coordinate of the shape.
	 * @param y Y-coordinate of the shape.
	 * @param w Width of the shape.
	 * @param h Height of the shape.
	 * @param style Style of the the shape.
	 */
  Element drawShape(int x, int y, int w, int h, Map<String, Object> style) {
    String fillColor = Utils.getString(style, Constants.STYLE_FILLCOLOR);
    String strokeColor = Utils.getString(style, Constants.STYLE_STROKECOLOR);
    float strokeWidth = (float)(Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale);

    // Draws the shape
    String shape = Utils.getString(style, Constants.STYLE_SHAPE);

    Element elem = _document.createElement("div");

    if (shape.equals(Constants.SHAPE_LINE)) {
      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);

      if (direction.equals(Constants.DIRECTION_EAST) || direction.equals(Constants.DIRECTION_WEST)) {
        y = Math.round(y + h / 2);
        h = 1;
      } else {
        x = Math.round(y + w / 2);
        w = 1;
      }
    }

    if (Utils.isTrue(style, Constants.STYLE_SHADOW, false) && fillColor != null) {
      Element shadow = elem.cloneNode(true) as Element;

      String s = "overflow:hidden;position:absolute;" + "left:" + String.valueOf(x + Constants.SHADOW_OFFSETX) + "px;" + "top:" + String.valueOf(y + Constants.SHADOW_OFFSETY) + "px;" + "width:" + String.valueOf(w) + "px;" + "height:" + String.valueOf(h) + "px;background:" + Constants.W3C_SHADOWCOLOR + ";border-style:solid;border-color:" + Constants.W3C_SHADOWCOLOR + ";border-width:" + String.valueOf(Math.round(strokeWidth)) + ";";
      shadow.setAttribute("style", s);

      appendHtmlElement(shadow);
    }

    if (shape.equals(Constants.SHAPE_IMAGE)) {
      String img = getImageForStyle(style);

      if (img != null) {
        elem = _document.createElement("img");
        elem.setAttribute("border", "0");
        elem.setAttribute("src", img);
      }
    }

    // TODO: Draw other shapes. eg. SHAPE_LINE here

    String s = "overflow:hidden;position:absolute;" + "left:" + String.valueOf(x) + "px;" + "top:" + String.valueOf(y) + "px;" + "width:" + String.valueOf(w) + "px;" + "height:" + String.valueOf(h) + "px;background:" + fillColor + ";" + ";border-style:solid;border-color:" + strokeColor + ";border-width:" + String.valueOf(Math.round(strokeWidth)) + ";";
    elem.setAttribute("style", s);

    appendHtmlElement(elem);

    return elem;
  }

  /**
	 * Draws the given lines as segments between all points of the given list
	 * of mxPoints.
	 * 
	 * @param pts List of points that define the line.
	 * @param style Style to be used for painting the line.
	 */
  void drawLine(List<Point2d> pts, Map<String, Object> style) {
    String strokeColor = Utils.getString(style, Constants.STYLE_STROKECOLOR);
    int strokeWidth = (int)(Utils.getInt(style, Constants.STYLE_STROKEWIDTH, 1) * _scale);

    if (strokeColor != null && strokeWidth > 0) {

      Point2d last = pts.get(0);

      for (int i = 1; i < pts.size(); i++) {
        Point2d pt = pts.get(i);

        _drawSegment(last.getX() as int, last.getY() as int, pt.getX() as int, pt.getY() as int, strokeColor, strokeWidth);

        last = pt;
      }
    }
  }

  /**
	 * Draws the specified segment of a line.
	 * 
	 * @param x0 X-coordinate of the start point.
	 * @param y0 Y-coordinate of the start point.
	 * @param x1 X-coordinate of the end point.
	 * @param y1 Y-coordinate of the end point.
	 * @param strokeColor Color of the stroke to be painted.
	 * @param strokeWidth Width of the stroke to be painted.
	 */
  void _drawSegment(int x0, int y0, int x1, int y1, String strokeColor, int strokeWidth) {
    int tmpX = Math.min(x0, x1);
    int tmpY = Math.min(y0, y1);

    int width = Math.max(x0, x1) - tmpX;
    int height = Math.max(y0, y1) - tmpY;

    x0 = tmpX;
    y0 = tmpY;

    if (width == 0 || height == 0) {
      String s = "overflow:hidden;position:absolute;" + "left:" + String.valueOf(x0) + "px;" + "top:" + String.valueOf(y0) + "px;" + "width:" + String.valueOf(width) + "px;" + "height:" + String.valueOf(height) + "px;" + "border-color:" + strokeColor + ";" + "border-style:solid;" + "border-width:1 1 0 0px;";

      Element elem = _document.createElement("div");
      elem.setAttribute("style", s);

      appendHtmlElement(elem);
    } else {
      int x = x0 + (x1 - x0) / 2;

      _drawSegment(x0, y0, x, y0, strokeColor, strokeWidth);
      _drawSegment(x, y0, x, y1, strokeColor, strokeWidth);
      _drawSegment(x, y1, x1, y1, strokeColor, strokeWidth);
    }
  }

  /**
	 * Draws the specified text either using drawHtmlString or using drawString.
	 * 
	 * @param text Text to be painted.
	 * @param x X-coordinate of the text.
	 * @param y Y-coordinate of the text.
	 * @param w Width of the text.
	 * @param h Height of the text.
	 * @param style Style to be used for painting the text.
	 */
  Element drawText(String text, int x, int y, int w, int h, Map<String, Object> style) {
    Element table = Utils.createTable(_document, text, x, y, w, h, _scale, style);
    appendHtmlElement(table);

    return table;
  }

}
