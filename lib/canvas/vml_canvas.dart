/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.canvas;

//import java.awt.Rectangle;
//import java.util.Hashtable;
//import java.util.List;
//import java.util.Map;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * An implementation of a canvas that uses VML for painting.
 */
class VmlCanvas extends BasicCanvas {

  /**
	 * Holds the HTML document that represents the canvas.
	 */
  Document _document;

  /**
	 * Constructs a new VML canvas for the specified dimension and scale.
	 */
//  VmlCanvas() {
//    this(null);
//  }

  /**
	 * Constructs a new VML canvas for the specified bounds, scale and
	 * background color.
	 */
  VmlCanvas([Document document=null]) {
    setDocument(document);
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

  /**
	 * 
	 */
  void appendVmlElement(Element node) {
    if (_document != null) {
      Node body = _document.documentElement.firstChild.nextNode;

      if (body != null) {
        body.append(node);
      }
    }

  }

  /* (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawCell()
	 */
  Object drawCell(CellState state) {
    Map<String, Object> style = state.getStyle();
    Element elem = null;

    if (state.getAbsolutePointCount() > 1) {
      List<Point2d> pts = state.getAbsolutePoints();

      // Transpose all points by cloning into a new array
      pts = Utils.translatePoints(pts, _translate.x, _translate.y);

      // Draws the line
      elem = drawLine(pts, style);
      Element strokeNode = _document.createElement("v:stroke");

      // Draws the markers
      String start = Utils.getString(style, Constants.STYLE_STARTARROW);
      String end = Utils.getString(style, Constants.STYLE_ENDARROW);

      if (start != null || end != null) {
        if (start != null) {
          strokeNode.setAttribute("startarrow", start);

          String startWidth = "medium";
          String startLength = "medium";
          double startSize = Utils.getFloat(style, Constants.STYLE_STARTSIZE, Constants.DEFAULT_MARKERSIZE) * _scale;

          if (startSize < 6) {
            startWidth = "narrow";
            startLength = "short";
          } else if (startSize > 10) {
            startWidth = "wide";
            startLength = "long";
          }

          strokeNode.setAttribute("startarrowwidth", startWidth);
          strokeNode.setAttribute("startarrowlength", startLength);
        }

        if (end != null) {
          strokeNode.setAttribute("endarrow", end);

          String endWidth = "medium";
          String endLength = "medium";
          double endSize = Utils.getFloat(style, Constants.STYLE_ENDSIZE, Constants.DEFAULT_MARKERSIZE) * _scale;

          if (endSize < 6) {
            endWidth = "narrow";
            endLength = "short";
          } else if (endSize > 10) {
            endWidth = "wide";
            endLength = "long";
          }

          strokeNode.setAttribute("endarrowwidth", endWidth);
          strokeNode.setAttribute("endarrowlength", endLength);
        }
      }

      if (Utils.isTrue(style, Constants.STYLE_DASHED)) {
        strokeNode.setAttribute("dashstyle", "2 2");
      }

      elem.append(strokeNode);
    } else {
      int x = (state.getX() as int) + _translate.x;
      int y = (state.getY() as int) + _translate.y;
      int w = (state.getWidth() as int);
      int h = (state.getHeight() as int);

      if (Utils.getString(style, Constants.STYLE_SHAPE, "") != Constants.SHAPE_SWIMLANE) {
        elem = drawShape(x, y, w, h, style);

        if (Utils.isTrue(style, Constants.STYLE_DASHED)) {
          Element strokeNode = _document.createElement("v:stroke");
          strokeNode.setAttribute("dashstyle", "2 2");
          elem.append(strokeNode);
        }
      } else {
        int start = math.round(Utils.getInt(style, Constants.STYLE_STARTSIZE, Constants.DEFAULT_STARTSIZE) * _scale) as int;

        // Removes some styles to draw the content area
        Map<String, Object> cloned = new Map<String, Object>.from(style);
        cloned.remove(Constants.STYLE_FILLCOLOR);
        cloned.remove(Constants.STYLE_ROUNDED);

        if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
          elem = drawShape(x, y, w, start, style);
          drawShape(x, y + start, w, h - start, cloned);
        } else {
          elem = drawShape(x, y, start, h, style);
          drawShape(x + start, y, w - start, h, cloned);
        }
      }
    }

    return elem;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawLabel()
	 */
  Object drawLabel(String label, CellState state, bool html) {
    Rect bounds = state.getLabelBounds();

    if (_drawLabels && bounds != null) {
      int x = (bounds.getX() as int) + _translate.x;
      int y = (bounds.getY() as int) + _translate.y;
      int w = (bounds.getWidth() as int);
      int h = (bounds.getHeight() as int);
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
    double strokeWidth = (Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale) as double;

    // Draws the shape
    String shape = Utils.getString(style, Constants.STYLE_SHAPE);
    Element elem = null;

    if (shape == Constants.SHAPE_IMAGE) {
      String img = getImageForStyle(style);

      if (img != null) {
        elem = _document.createElement("v:img");
        elem.setAttribute("src", img);
      }
    } else if (shape == Constants.SHAPE_LINE) {
      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);
      String points = null;

      if (direction == Constants.DIRECTION_EAST || direction == Constants.DIRECTION_WEST) {
        int mid = math.round(h / 2) as int;
        points = "m 0 $mid l $w $mid";
      } else {
        int mid = math.round(w / 2) as int;
        points = "m $mid 0 L $mid $h";
      }

      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", "$w $h");
      elem.setAttribute("path", "$points x e");
    } else if (shape == Constants.SHAPE_ELLIPSE) {
      elem = _document.createElement("v:oval");
    } else if (shape == Constants.SHAPE_DOUBLE_ELLIPSE) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", "$w $h");
      int inset = ((3 + strokeWidth) * _scale) as int;

      String points = "ar 0 0 " + w + " " + h + " 0 " + (h / 2) + " " + (w / 2) + " " + (h / 2) + " e ar " + inset + " " + inset + " " + (w - inset) + " " + (h - inset) + " 0 " + (h / 2) + " " + (w / 2) + " " + (h / 2);

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_RHOMBUS) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      String points = "m " + (w / 2) + " 0 l " + w + " " + (h / 2) + " l " + (w / 2) + " " + h + " l 0 " + (h / 2);

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_TRIANGLE) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, "");
      String points = null;

      if (direction == Constants.DIRECTION_NORTH) {
        points = "m 0 " + h + " l " + (w / 2) + " 0 " + " l " + w + " " + h;
      } else if (direction == Constants.DIRECTION_SOUTH) {
        points = "m 0 0 l " + (w / 2) + " " + h + " l " + w + " 0";
      } else if (direction == Constants.DIRECTION_WEST) {
        points = "m " + w + " 0 l " + w + " " + (h / 2) + " l " + w + " " + h;
      } else // east
      {
        points = "m 0 0 l " + w + " " + (h / 2) + " l 0 " + h;
      }

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_HEXAGON) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, "");
      String points = null;

      if (direction == Constants.DIRECTION_NORTH || direction == Constants.DIRECTION_SOUTH) {
        points = "m " + (int)(0.5 * w) + " 0 l " + w + " " + (int)(0.25 * h) + " l " + w + " " + (int)(0.75 * h) + " l " + (int)(0.5 * w) + " " + h + " l 0 " + (int)(0.75 * h) + " l 0 " + (int)(0.25 * h);
      } else {
        points = "m " + (int)(0.25 * w) + " 0 l " + (int)(0.75 * w) + " 0 l " + w + " " + (int)(0.5 * h) + " l " + (int)(0.75 * w) + " " + h + " l " + (int)(0.25 * w) + " " + h + " l 0 " + (int)(0.5 * h);
      }

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_CLOUD) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      String points = "m " + (int)(0.25 * w) + " " + (int)(0.25 * h) + " c " + (int)(0.05 * w) + " " + (int)(0.25 * h) + " 0 " + (int)(0.5 * h) + " " + (int)(0.16 * w) + " " + (int)(0.55 * h) + " c 0 " + (int)(0.66 * h) + " " + (int)(0.18 * w) + " " + (int)(0.9 * h) + " " + (int)(0.31 * w) + " " + (int)(0.8 * h) + " c " + (int)(0.4 * w) + " " + (h) + " " + (int)(0.7 * w) + " " + (h) + " " + (int)(0.8 * w) + " " + (int)(0.8 * h) + " c " + (w) + " " + (int)(0.8 * h) + " " + (w) + " " + (int)(0.6 * h) + " " + (int)(0.875 * w) + " " + (int)(0.5 * h) + " c " + (w) + " " + (int)(0.3 * h) + " " + (int)(0.8 * w) + " " + (int)(0.1 * h) + " " + (int)(0.625 * w) + " " + (int)(0.2 * h) + " c " + (int)(0.5 * w) + " " + (int)(0.05 * h) + " " + (int)(0.3 * w) + " " + (int)(0.05 * h) + " " + (int)(0.25 * w) + " " + (int)(0.25 * h);

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_ACTOR) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      double width3 = w / 3;
      String points = "m 0 " + (h) + " C 0 " + (3 * h / 5) + " 0 " + (2 * h / 5) + " " + (w / 2) + " " + (2 * h / 5) + " c " + (int)(w / 2 - width3) + " " + (2 * h / 5) + " " + (int)(w / 2 - width3) + " 0 " + (w / 2) + " 0 c " + (int)(w / 2 + width3) + " 0 " + (int)(w / 2 + width3) + " " + (2 * h / 5) + " " + (w / 2) + " " + (2 * h / 5) + " c " + (w) + " " + (2 * h / 5) + " " + (w) + " " + (3 * h / 5) + " " + (w) + " " + (h);

      elem.setAttribute("path", points + " x e");
    } else if (shape == Constants.SHAPE_CYLINDER) {
      elem = _document.createElement("v:shape");
      elem.setAttribute("coordsize", w + " " + h);

      double dy = Math.min(40, math.floor(h / 5));
      String points = "m 0 " + (int)(dy) + " C 0 " + (int)(dy / 3) + " " + (w) + " " + (int)(dy / 3) + " " + (w) + " " + (int)(dy) + " L " + (w) + " " + (int)(h - dy) + " C " + (w) + " " + (int)(h + dy / 3) + " 0 " + (int)(h + dy / 3) + " 0 " + (int)(h - dy) + " x e" + " m 0 " + (int)(dy) + " C 0 " + (int)(2 * dy) + " " + (w) + " " + (int)(2 * dy) + " " + (w) + " " + (int)(dy);

      elem.setAttribute("path", points + " e");
    } else {
      if (Utils.isTrue(style, Constants.STYLE_ROUNDED, false)) {
        elem = _document.createElement("v:roundrect");
        elem.setAttribute("arcsize", (Constants.RECTANGLE_ROUNDING_FACTOR * 100) + "%");
      } else {
        elem = _document.createElement("v:rect");
      }
    }

    String s = "position:absolute;left:${x}px;top:${y}px;width:${w}px;height:${h}px;";

    // Applies rotation
    double rotation = Utils.getDouble(style, Constants.STYLE_ROTATION);

    if (rotation != 0) {
      s += "rotation:" + rotation + ";";
    }

    elem.setAttribute("style", s);

    // Adds the shadow element
    if (Utils.isTrue(style, Constants.STYLE_SHADOW, false) && fillColor != null) {
      Element shadow = _document.createElement("v:shadow");
      shadow.setAttribute("on", "true");
      shadow.setAttribute("color", Constants.W3C_SHADOWCOLOR);
      elem.append(shadow);
    }

    double opacity = Utils.getFloat(style, Constants.STYLE_OPACITY, 100);

    // Applies opacity to fill
    if (fillColor != null) {
      Element fill = _document.createElement("v:fill");
      fill.setAttribute("color", fillColor);

      if (opacity != 100) {
        fill.setAttribute("opacity", (opacity / 100).toString());
      }

      elem.append(fill);
    } else {
      elem.setAttribute("filled", "false");
    }

    // Applies opacity to stroke
    if (strokeColor != null) {
      elem.setAttribute("strokecolor", strokeColor);
      Element stroke = _document.createElement("v:stroke");

      if (opacity != 100) {
        stroke.setAttribute("opacity", (opacity / 100).toString());
      }

      elem.append(stroke);
    } else {
      elem.setAttribute("stroked", "false");
    }

    elem.setAttribute("strokeweight", "${strokeWidth}px");
    appendVmlElement(elem);

    return elem;
  }

  /**
	 * Draws the given lines as segments between all points of the given list
	 * of mxPoints.
	 * 
	 * @param pts List of points that define the line.
	 * @param style Style to be used for painting the line.
	 */
  Element drawLine(List<Point2d> pts, Map<String, Object> style) {
    String strokeColor = Utils.getString(style, Constants.STYLE_STROKECOLOR);
    double strokeWidth = (Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale) as double;

    Element elem = _document.createElement("v:shape");

    if (strokeColor != null && strokeWidth > 0) {
      Point2d pt = pts[0];
      harmony.Rectangle r = new harmony.Rectangle(pt.getPoint());

      StringBuilder buf = new StringBuilder("m " + math.round(pt.getX()) + " " + math.round(pt.getY()));

      for (int i = 1; i < pts.length; i++) {
        pt = pts[i];
        buf.append(" l " + math.round(pt.getX()) + " " + math.round(pt.getY()));

        r = r.union(new harmony.Rectangle(pt.getPoint()));
      }

      String d = buf.toString();
      elem.setAttribute("path", d);
      elem.setAttribute("filled", "false");
      elem.setAttribute("strokecolor", strokeColor);
      elem.setAttribute("strokeweight", "${strokeWidth}px");

      String s = "position:absolute;left:${r.x}px;top:${r.y}px;width:${r.width}px;height:${r.height}px;";
      elem.setAttribute("style", s);

      elem.setAttribute("coordorigin", "${r.x} ${r.y}");
      elem.setAttribute("coordsize", "${r.width} ${r.height}");
    }

    appendVmlElement(elem);

    return elem;
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
    appendVmlElement(table);

    return table;
  }

}
