/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.reader;


//import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
//import org.xml.sax.helpers.DefaultHandler;

/**
 * An abstract converter that renders display XML data onto a canvas.
 */
abstract class GraphViewReader extends xml.DefaultHandler {

  /**
   * Holds the canvas to be used for rendering the graph.
   */
  ICanvas _canvas;

  /**
   * Holds the global scale of the graph. This is set just before
   * createCanvas is called.
   */
  double _scale = 1.0;

  /**
   * Specifies if labels should be rendered as HTML markup.
   */
  bool _htmlLabels = false;

  /**
   * Sets the htmlLabels switch.
   */
  void setHtmlLabels(bool value) {
    _htmlLabels = value;
  }

  /**
   * Returns the htmlLabels switch.
   */
  bool isHtmlLabels() {
    return _htmlLabels;
  }

  /**
   * Returns the canvas to be used for rendering.
   * 
   * @param attrs Specifies the attributes of the new canvas.
   * @return Returns a new canvas.
   */
  ICanvas createCanvas(Map<String, Object> attrs);

  /**
   * Returns the canvas that is used for rendering the graph.
   * 
   * @return Returns the canvas.
   */
  ICanvas getCanvas() {
    return _canvas;
  }

  void startElement(String qName, Map<String, String> atts) //throws SAXException
  {
    String tagName = qName.toUpperCase();
    //Map<String, Object> attrs = new Map<String, Object>();

    /*for (int i = 0; i < atts.length; i++) {
      //String name = atts.getQName(i);
      String name = atts[i].local;

      // Workaround for possible null name
      /*if (name == null || name.length == 0) {
        name = atts.getLocalName(i);
      }*/

      attrs[name] = atts[i].value;
    }*/

    parseElement(tagName, atts);
  }

  /**
   * Parses the given element and paints it onto the canvas.
   * 
   * @param tagName Name of the node to be parsed.
   * @param attrs Attributes of the node to be parsed.
   */
  void parseElement(String tagName, Map<String, Object> attrs) {
    if (_canvas == null && tagName.toLowerCase() == "graph") {
      _scale = Utils.getDouble(attrs, "scale", 1.0);
      _canvas = createCanvas(attrs);

      if (_canvas != null) {
        _canvas.setScale(_scale);
      }
    } else if (_canvas != null) {
      bool edge = tagName.toLowerCase() == "edge";
      bool group = tagName.toLowerCase() == "group";
      bool vertex = tagName.toLowerCase() == "vertex";

      if ((edge && attrs.containsKey("points")) || ((vertex || group) && attrs.containsKey("x") && attrs.containsKey("y") && attrs.containsKey("width") && attrs.containsKey("height"))) {
        CellState state = new CellState(null, null, attrs);

        String label = parseState(state, edge);
        _canvas.drawCell(state);
        _canvas.drawLabel(label, state, isHtmlLabels());
      }
    }
  }

  /**
   * Parses the bounds, absolute points and label information from the style
   * of the state into its respective fields and returns the label of the
   * cell.
   */
  String parseState(CellState state, bool edge) {
    Map<String, Object> style = state.getStyle();

    // Parses the bounds
    state.setX(Utils.getDouble(style, "x"));
    state.setY(Utils.getDouble(style, "y"));
    state.setWidth(Utils.getDouble(style, "width"));
    state.setHeight(Utils.getDouble(style, "height"));

    // Parses the absolute points list
    List<Point2d> pts = parsePoints(Utils.getString(style, "points"));

    if (pts.length > 0) {
      state.setAbsolutePoints(pts);
    }

    // Parses the label and label bounds
    String label = Utils.getString(style, "label");

    if (label != null && label.length > 0) {
      Point2d offset = new Point2d(Utils.getDouble(style, "dx"), Utils.getDouble(style, "dy"));
      Rect vertexBounds = (!edge) ? state : null;
      state.setLabelBounds(Utils.getLabelPaintBounds(label, state.getStyle(), Utils.isTrue(style, "html", false), offset, vertexBounds, _scale));
    }

    return label;
  }

  /**
   * Parses the list of points into an object-oriented representation.
   * 
   * @param pts String containing a list of points.
   * @return Returns the points as a list of mxPoints.
   */
  static List<Point2d> parsePoints(String pts) {
    List<Point2d> result = new List<Point2d>();

    if (pts != null) {
      int len = pts.length;
      String tmp = "";
      String x = null;

      for (int i = 0; i < len; i++) {
        String c = pts[i];

        if (c == ',' || c == ' ') {
          if (x == null) {
            x = tmp;
          } else {
            result.add(new Point2d(double.parse(x), double.parse(tmp)));
            x = null;
          }
          tmp = "";
        } else {
          tmp += c;
        }
      }

      result.add(new Point2d(double.parse(x), double.parse(tmp)));
    }

    return result;
  }

}
