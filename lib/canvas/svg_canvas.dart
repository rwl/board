/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.canvas;

//import java.awt.Font;
//import java.io.BufferedInputStream;
//import java.io.ByteArrayOutputStream;
//import java.io.IOException;
//import java.io.InputStream;
//import java.net.URL;
//import java.util.Hashtable;
//import java.util.List;
//import java.util.Map;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * An implementation of a canvas that uses SVG for painting. This canvas
 * ignores the STYLE_LABEL_BACKGROUNDCOLOR and
 * STYLE_LABEL_BORDERCOLOR styles due to limitations of SVG.
 */
class SvgCanvas extends BasicCanvas {

  /**
	 * Holds the HTML document that represents the canvas.
	 */
  Document _document;

  /**
	 * Used internally for looking up elements. Workaround for getElementById
	 * not working.
	 */
  Map<String, Element> _gradients = new Map<String, Element>();

  /**
	 * Used internally for looking up images.
	 */
  Map<String, Element> _images = new Map<String, Element>();

  /**
	 * 
	 */
  Element _defs = null;

  /**
	 * Specifies if images should be embedded as base64 encoded strings.
	 * Default is false.
	 */
  bool _embedded = false;

  /**
	 * Constructs a new SVG canvas for the specified dimension and scale.
	 */
//  SvgCanvas() {
//    this(null);
//  }

  /**
	 * Constructs a new SVG canvas for the specified bounds, scale and
	 * background color.
	 */
  SvgCanvas([Document document=null]) {
    setDocument(document);
  }

  /**
	 * 
	 */
  void appendSvgElement(Element node) {
    if (_document != null) {
      _document.documentElement.append(node);
    }
  }

  /**
	 * 
	 */
  Element _getDefsElement() {
    if (_defs == null) {
      _defs = _document.createElement("defs");

      Element svgNode = _document.documentElement;

      if (svgNode.hasChildNodes()) {
        svgNode.insertBefore(_defs, svgNode.firstChild);
      } else {
        svgNode.append(_defs);
      }
    }

    return _defs;
  }

  /**
	 * 
	 */
  Element getGradientElement(String start, String end, String direction) {
    String id = getGradientId(start, end, direction);
    Element gradient = _gradients[id];

    if (gradient == null) {
      gradient = _createGradientElement(start, end, direction);
      gradient.setAttribute("id", "g" + (_gradients.length + 1));
      _getDefsElement().append(gradient);
      _gradients[id] = gradient;
    }

    return gradient;
  }

  /**
	 * 
	 */
  Element getGlassGradientElement() {
    String id = "mx-glass-gradient";

    Element glassGradient = _gradients[id];

    if (glassGradient == null) {
      glassGradient = _document.createElement("linearGradient");
      glassGradient.setAttribute("x1", "0%");
      glassGradient.setAttribute("y1", "0%");
      glassGradient.setAttribute("x2", "0%");
      glassGradient.setAttribute("y2", "100%");

      Element stop1 = _document.createElement("stop");
      stop1.setAttribute("offset", "0%");
      stop1.setAttribute("style", "stop-color:#ffffff;stop-opacity:0.9");
      glassGradient.append(stop1);

      Element stop2 = _document.createElement("stop");
      stop2.setAttribute("offset", "100%");
      stop2.setAttribute("style", "stop-color:#ffffff;stop-opacity:0.1");
      glassGradient.append(stop2);

      glassGradient.setAttribute("id", "g" + (_gradients.length + 1));
      _getDefsElement().append(glassGradient);
      _gradients[id] = glassGradient;
    }

    return glassGradient;
  }

  /**
	 * 
	 */
  Element _createGradientElement(String start, String end, String direction) {
    Element gradient = _document.createElement("linearGradient");
    gradient.setAttribute("x1", "0%");
    gradient.setAttribute("y1", "0%");
    gradient.setAttribute("x2", "0%");
    gradient.setAttribute("y2", "0%");

    if (direction == null || direction == Constants.DIRECTION_SOUTH) {
      gradient.setAttribute("y2", "100%");
    } else if (direction == Constants.DIRECTION_EAST) {
      gradient.setAttribute("x2", "100%");
    } else if (direction == Constants.DIRECTION_NORTH) {
      gradient.setAttribute("y1", "100%");
    } else if (direction == Constants.DIRECTION_WEST) {
      gradient.setAttribute("x1", "100%");
    }

    Element stop = _document.createElement("stop");
    stop.setAttribute("offset", "0%");
    stop.setAttribute("style", "stop-color:" + start);
    gradient.append(stop);

    stop = _document.createElement("stop");
    stop.setAttribute("offset", "100%");
    stop.setAttribute("style", "stop-color:" + end);
    gradient.append(stop);

    return gradient;
  }

  /**
	 * 
	 */
  String getGradientId(String start, String end, String direction) {
    // Removes illegal characters from gradient ID
    if (start.startsWith("#")) {
      start = start.substring(1);
    }

    if (end.startsWith("#")) {
      end = end.substring(1);
    }

    // Workaround for gradient IDs not working in Safari 5 / Chrome 6
    // if they contain uppercase characters
    start = start.toLowerCase();
    end = end.toLowerCase();

    String dir = null;

    if (direction == null || direction == Constants.DIRECTION_SOUTH) {
      dir = "south";
    } else if (direction == Constants.DIRECTION_EAST) {
      dir = "east";
    } else {
      String tmp = start;
      start = end;
      end = tmp;

      if (direction == Constants.DIRECTION_NORTH) {
        dir = "south";
      } else if (direction == Constants.DIRECTION_WEST) {
        dir = "east";
      }
    }

    return "mx-gradient-" + start + "-" + end + "-" + dir;
  }

  /**
	 * Returns true if the given string ends with .png, .jpg or .gif.
	 */
  bool _isImageResource(String src) {
    return src != null && (src.toLowerCase().endsWith(".png") || src.toLowerCase().endsWith(".jpg") || src.toLowerCase().endsWith(".gif"));
  }

  /**
	 * 
	 */
  InputStream _getResource(String src) {
    InputStream stream = null;

    try {
      stream = new BufferedInputStream(new URL(src).openStream());
    } on Exception catch (e1) {
      stream = getClass().getResourceAsStream(src);
    }

    return stream;
  }

  /**
	 * @throws IOException 
	 * 
	 */
  String _createDataUrl(String src) //throws IOException
  {
    String result = null;
    InputStream inputStream = _isImageResource(src) ? _getResource(src) : null;

    if (inputStream != null) {
      ByteArrayOutputStream outputStream = new ByteArrayOutputStream(1024);
      List<byte> bytes = new List<byte>(512);

      // Read bytes from the input stream in bytes.length-sized chunks and write
      // them into the output stream
      int readBytes;
      while ((readBytes = inputStream.read(bytes)) > 0) {
        outputStream.write(bytes, 0, readBytes);
      }

      // Convert the contents of the output stream into a Data URL
      String format = "png";
      int dot = src.lastIndexOf('.');

      if (dot > 0 && dot < src.length) {
        format = src.substring(dot + 1);
      }

      result = "data:image/" + format + ";base64," + Base64.encodeToString(outputStream.toByteArray(), false);
    }

    return result;
  }

  /**
	 * 
	 */
  Element _getEmbeddedImageElement(String src) {
    Element img = _images[src];

    if (img == null) {
      img = _document.createElement("svg");
      img.setAttribute("width", "100%");
      img.setAttribute("height", "100%");

      Element inner = _document.createElement("image");
      inner.setAttribute("width", "100%");
      inner.setAttribute("height", "100%");

      // Store before transforming to DataURL
      _images[src] = img;

      if (!src.startsWith("data:image/")) {
        try {
          String tmp = _createDataUrl(src);

          if (tmp != null) {
            src = tmp;
          }
        } on IOException catch (e) {
          // ignore
        }
      }

      inner.setAttributeNS(Constants.NS_XLINK, "xlink:href", src);
      img.append(inner);
      img.setAttribute("id", "i" + (_images.length));
      _getDefsElement().append(img);
    }

    return img;
  }

  /**
	 * 
	 */
  Element _createImageElement(double x, double y, double w, double h, String src, bool aspect, bool flipH, bool flipV, bool embedded) {
    Element elem = null;

    if (embedded) {
      elem = _document.createElement("use");

      Element img = _getEmbeddedImageElement(src);
      elem.setAttributeNS(Constants.NS_XLINK, "xlink:href", "#" + img.getAttribute("id"));
    } else {
      elem = _document.createElement("image");

      elem.setAttributeNS(Constants.NS_XLINK, "xlink:href", src);
    }

    elem.setAttribute("x", x.toString());
    elem.setAttribute("y", y.toString());
    elem.setAttribute("width", w.toString());
    elem.setAttribute("height", h.toString());

    // FIXME: SVG element must be used for reference to image with
    // aspect but for images with no aspect this does not work.
    if (aspect) {
      elem.setAttribute("preserveAspectRatio", "xMidYMid");
    } else {
      elem.setAttribute("preserveAspectRatio", "none");
    }

    double sx = 1;
    double sy = 1;
    double dx = 0;
    double dy = 0;

    if (flipH) {
      sx *= -1;
      dx = -w - 2 * x;
    }

    if (flipV) {
      sy *= -1;
      dy = -h - 2 * y;
    }

    String transform = "";

    if (sx != 1 || sy != 1) {
      transform += "scale(" + sx + " " + sy + ") ";
    }

    if (dx != 0 || dy != 0) {
      transform += "translate(" + dx + " " + dy + ") ";
    }

    if (transform.length > 0) {
      elem.setAttribute("transform", transform);
    }

    return elem;
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
  void setEmbedded(bool value) {
    _embedded = value;
  }

  /**
	 * 
	 */
  bool isEmbedded() {
    return _embedded;
  }

  /*
	 * (non-Javadoc)
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

      // Applies opacity
      double opacity = Utils.getFloat(style, Constants.STYLE_OPACITY, 100);

      if (opacity != 100) {
        String value = (opacity / 100).toString();
        elem.setAttribute("fill-opacity", value);
        elem.setAttribute("stroke-opacity", value);
      }
    } else {
      int x = (state.getX() as int) + _translate.x;
      int y = (state.getY() as int) + _translate.y;
      int w = (state.getWidth() as int);
      int h = (state.getHeight() as int);

      if (Utils.getString(style, Constants.STYLE_SHAPE, "") != Constants.SHAPE_SWIMLANE) {
        elem = drawShape(x, y, w, h, style);
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
    String fillColor = Utils.getString(style, Constants.STYLE_FILLCOLOR, "none");
    String gradientColor = Utils.getString(style, Constants.STYLE_GRADIENTCOLOR, "none");
    String strokeColor = Utils.getString(style, Constants.STYLE_STROKECOLOR, "none");
    double strokeWidth = (Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale) as double;
    double opacity = Utils.getFloat(style, Constants.STYLE_OPACITY, 100);

    // Draws the shape
    String shape = Utils.getString(style, Constants.STYLE_SHAPE, "");
    Element elem = null;
    Element background = null;

    if (shape == Constants.SHAPE_IMAGE) {
      String img = getImageForStyle(style);

      if (img != null) {
        // Vertical and horizontal image flipping
        bool flipH = Utils.isTrue(style, Constants.STYLE_IMAGE_FLIPH, false);
        bool flipV = Utils.isTrue(style, Constants.STYLE_IMAGE_FLIPV, false);

        elem = _createImageElement(x, y, w, h, img, PRESERVE_IMAGE_ASPECT, flipH, flipV, isEmbedded());
      }
    } else if (shape == Constants.SHAPE_LINE) {
      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);
      String d = null;

      if (direction == Constants.DIRECTION_EAST || direction == Constants.DIRECTION_WEST) {
        int mid = (y + h / 2);
        d = "M " + x + " " + mid + " L " + (x + w) + " " + mid;
      } else {
        int mid = (x + w / 2);
        d = "M " + mid + " " + y + " L " + mid + " " + (y + h);
      }

      elem = _document.createElement("path");
      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_ELLIPSE) {
      elem = _document.createElement("ellipse");

      elem.setAttribute("cx", (x + w / 2).toString());
      elem.setAttribute("cy", (y + h / 2).toString());
      elem.setAttribute("rx", (w / 2).toString());
      elem.setAttribute("ry", (h / 2).toString());
    } else if (shape == Constants.SHAPE_DOUBLE_ELLIPSE) {
      elem = _document.createElement("g");
      background = _document.createElement("ellipse");
      background.setAttribute("cx", (x + w / 2).toString());
      background.setAttribute("cy", (y + h / 2).toString());
      background.setAttribute("rx", (w / 2).toString());
      background.setAttribute("ry", (h / 2).toString());
      elem.append(background);

      int inset = (int)((3 + strokeWidth) * _scale);

      Element foreground = _document.createElement("ellipse");
      foreground.setAttribute("fill", "none");
      foreground.setAttribute("stroke", strokeColor);
      foreground.setAttribute("stroke-width", strokeWidth.toString());

      foreground.setAttribute("cx", (x + w / 2).toString());
      foreground.setAttribute("cy", (y + h / 2).toString());
      foreground.setAttribute("rx", (w / 2 - inset).toString());
      foreground.setAttribute("ry", (h / 2 - inset).toString());
      elem.append(foreground);
    } else if (shape == Constants.SHAPE_RHOMBUS) {
      elem = _document.createElement("path");

      String d = "M " + (x + w / 2) + " " + y + " L " + (x + w) + " " + (y + h / 2) + " L " + (x + w / 2) + " " + (y + h) + " L " + x + " " + (y + h / 2);

      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_TRIANGLE) {
      elem = _document.createElement("path");
      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, "");
      String d = null;

      if (direction == Constants.DIRECTION_NORTH) {
        d = "M " + x + " " + (y + h) + " L " + (x + w / 2) + " " + y + " L " + (x + w) + " " + (y + h);
      } else if (direction == Constants.DIRECTION_SOUTH) {
        d = "M " + x + " " + y + " L " + (x + w / 2) + " " + (y + h) + " L " + (x + w) + " " + y;
      } else if (direction == Constants.DIRECTION_WEST) {
        d = "M " + (x + w) + " " + y + " L " + x + " " + (y + h / 2) + " L " + (x + w) + " " + (y + h);
      } else // east
      {
        d = "M " + x + " " + y + " L " + (x + w) + " " + (y + h / 2) + " L " + x + " " + (y + h);
      }

      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_HEXAGON) {
      elem = _document.createElement("path");
      String direction = Utils.getString(style, Constants.STYLE_DIRECTION, "");
      String d = null;

      if (direction == Constants.DIRECTION_NORTH || direction == Constants.DIRECTION_SOUTH) {
        d = "M " + (x + 0.5 * w) + " " + y + " L " + (x + w) + " " + (y + 0.25 * h) + " L " + (x + w) + " " + (y + 0.75 * h) + " L " + (x + 0.5 * w) + " " + (y + h) + " L " + x + " " + (y + 0.75 * h) + " L " + x + " " + (y + 0.25 * h);
      } else {
        d = "M " + (x + 0.25 * w) + " " + y + " L " + (x + 0.75 * w) + " " + y + " L " + (x + w) + " " + (y + 0.5 * h) + " L " + (x + 0.75 * w) + " " + (y + h) + " L " + (x + 0.25 * w) + " " + (y + h) + " L " + x + " " + (y + 0.5 * h);
      }

      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_CLOUD) {
      elem = _document.createElement("path");

      String d = "M " + (x + 0.25 * w) + " " + (y + 0.25 * h) + " C " + (x + 0.05 * w) + " " + (y + 0.25 * h) + " " + x + " " + (y + 0.5 * h) + " " + (x + 0.16 * w) + " " + (y + 0.55 * h) + " C " + x + " " + (y + 0.66 * h) + " " + (x + 0.18 * w) + " " + (y + 0.9 * h) + " " + (x + 0.31 * w) + " " + (y + 0.8 * h) + " C " + (x + 0.4 * w) + " " + (y + h) + " " + (x + 0.7 * w) + " " + (y + h) + " " + (x + 0.8 * w) + " " + (y + 0.8 * h) + " C " + (x + w) + " " + (y + 0.8 * h) + " " + (x + w) + " " + (y + 0.6 * h) + " " + (x + 0.875 * w) + " " + (y + 0.5 * h) + " C " + (x + w) + " " + (y + 0.3 * h) + " " + (x + 0.8 * w) + " " + (y + 0.1 * h) + " " + (x + 0.625 * w) + " " + (y + 0.2 * h) + " C " + (x + 0.5 * w) + " " + (y + 0.05 * h) + " " + (x + 0.3 * w) + " " + (y + 0.05 * h) + " " + (x + 0.25 * w) + " " + (y + 0.25 * h);

      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_ACTOR) {
      elem = _document.createElement("path");
      double width3 = w / 3;

      String d = " M " + x + " " + (y + h) + " C " + x + " " + (y + 3 * h / 5) + " " + x + " " + (y + 2 * h / 5) + " " + (x + w / 2) + " " + (y + 2 * h / 5) + " C " + (x + w / 2 - width3) + " " + (y + 2 * h / 5) + " " + (x + w / 2 - width3) + " " + y + " " + (x + w / 2) + " " + y + " C " + (x + w / 2 + width3) + " " + y + " " + (x + w / 2 + width3) + " " + (y + 2 * h / 5) + " " + (x + w / 2) + " " + (y + 2 * h / 5) + " C " + (x + w) + " " + (y + 2 * h / 5) + " " + (x + w) + " " + (y + 3 * h / 5) + " " + (x + w) + " " + (y + h);

      elem.setAttribute("d", d + " Z");
    } else if (shape == Constants.SHAPE_CYLINDER) {
      elem = _document.createElement("g");
      background = _document.createElement("path");

      double dy = Math.min(40, math.floor(h / 5));
      String d = " M " + x + " " + (y + dy) + " C " + x + " " + (y - dy / 3) + " " + (x + w) + " " + (y - dy / 3) + " " + (x + w) + " " + (y + dy) + " L " + (x + w) + " " + (y + h - dy) + " C " + (x + w) + " " + (y + h + dy / 3) + " " + x + " " + (y + h + dy / 3) + " " + x + " " + (y + h - dy);
      background.setAttribute("d", d + " Z");
      elem.append(background);

      Element foreground = _document.createElement("path");
      d = "M " + x + " " + (y + dy) + " C " + x + " " + (y + 2 * dy) + " " + (x + w) + " " + (y + 2 * dy) + " " + (x + w) + " " + (y + dy);

      foreground.setAttribute("d", d);
      foreground.setAttribute("fill", "none");
      foreground.setAttribute("stroke", strokeColor);
      foreground.setAttribute("stroke-width", strokeWidth.toString());

      elem.append(foreground);
    } else {
      background = _document.createElement("rect");
      elem = background;

      elem.setAttribute("x", x.toString());
      elem.setAttribute("y", y.toString());
      elem.setAttribute("width", w.toString());
      elem.setAttribute("height", h.toString());

      if (Utils.isTrue(style, Constants.STYLE_ROUNDED, false)) {
        String r = (Math.min(w * Constants.RECTANGLE_ROUNDING_FACTOR, h * Constants.RECTANGLE_ROUNDING_FACTOR)).toString();

        elem.setAttribute("rx", r);
        elem.setAttribute("ry", r);
      }

      // Paints the label image
      if (shape == Constants.SHAPE_LABEL) {
        String img = getImageForStyle(style);

        if (img != null) {
          String imgAlign = Utils.getString(style, Constants.STYLE_IMAGE_ALIGN, Constants.ALIGN_LEFT);
          String imgValign = Utils.getString(style, Constants.STYLE_IMAGE_VERTICAL_ALIGN, Constants.ALIGN_MIDDLE);
          int imgWidth = (Utils.getInt(style, Constants.STYLE_IMAGE_WIDTH, Constants.DEFAULT_IMAGESIZE) * _scale) as int;
          int imgHeight = (Utils.getInt(style, Constants.STYLE_IMAGE_HEIGHT, Constants.DEFAULT_IMAGESIZE) * _scale) as int;
          int spacing = (Utils.getInt(style, Constants.STYLE_SPACING, 2) * _scale) as int;

          Rect imageBounds = new Rect(x, y, w, h);

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

          imageBounds.setWidth(imgWidth);
          imageBounds.setHeight(imgHeight);

          elem = _document.createElement("g");
          elem.append(background);

          Element imageElement = _createImageElement(imageBounds.getX(), imageBounds.getY(), imageBounds.getWidth(), imageBounds.getHeight(), img, false, false, false, isEmbedded());

          if (opacity != 100) {
            String value = (opacity / 100).toString();
            imageElement.setAttribute("opacity", value);
          }

          elem.append(imageElement);
        }

        // Paints the glass effect
        if (Utils.isTrue(style, Constants.STYLE_GLASS, false)) {
          double size = 0.4;

          // TODO: Mask with rectangle or rounded rectangle of label
          // Creates glass overlay
          Element glassOverlay = _document.createElement("path");

          // LATER: Not sure what the behaviour is for mutiple SVG elements in page.
          // Probably its possible that this points to an element in another SVG
          // node which when removed will result in an undefined background.
          glassOverlay.setAttribute("fill", "url(#" + getGlassGradientElement().getAttribute("id") + ")");

          String d = "m " + (x - strokeWidth) + "," + (y - strokeWidth) + " L " + (x - strokeWidth) + "," + (y + h * size) + " Q " + (x + w * 0.5) + "," + (y + h * 0.7) + " " + (x + w + strokeWidth) + "," + (y + h * size) + " L " + (x + w + strokeWidth) + "," + (y - strokeWidth) + " z";
          glassOverlay.setAttribute("stroke-width", (strokeWidth / 2).toString());
          glassOverlay.setAttribute("d", d);
          elem.append(glassOverlay);
        }
      }
    }

    double rotation = Utils.getDouble(style, Constants.STYLE_ROTATION);
    int cx = x + w / 2;
    int cy = y + h / 2;

    Element bg = background;

    if (bg == null) {
      bg = elem;
    }

    if (bg.nodeName.toLowerCase() != "use" && bg.nodeName.toLowerCase() != "image")  {
      if (fillColor.toLowerCase() != "none" && gradientColor.toLowerCase() != "none") {
        String direction = Utils.getString(style, Constants.STYLE_GRADIENT_DIRECTION);
        Element gradient = getGradientElement(fillColor, gradientColor, direction);

        if (gradient != null) {
          bg.setAttribute("fill", "url(#" + gradient.getAttribute("id") + ")");
        }
      } else {
        bg.setAttribute("fill", fillColor);
      }

      bg.setAttribute("stroke", strokeColor);
      bg.setAttribute("stroke-width", strokeWidth.toString());

      // Adds the shadow element
      Element shadowElement = null;

      if (Utils.isTrue(style, Constants.STYLE_SHADOW, false) && fillColor != "none") {
        shadowElement = bg.clone(true) as Element;

        shadowElement.setAttribute("transform", Constants.SVG_SHADOWTRANSFORM);
        shadowElement.setAttribute("fill", Constants.W3C_SHADOWCOLOR);
        shadowElement.setAttribute("stroke", Constants.W3C_SHADOWCOLOR);
        shadowElement.setAttribute("stroke-width", strokeWidth.toString());

        if (rotation != 0) {
          shadowElement.setAttribute("transform", "rotate(" + rotation + "," + cx + "," + cy + ") " + Constants.SVG_SHADOWTRANSFORM);
        }

        if (opacity != 100) {
          String value = (opacity / 100).toString();
          shadowElement.setAttribute("fill-opacity", value);
          shadowElement.setAttribute("stroke-opacity", value);
        }

        appendSvgElement(shadowElement);
      }
    }

    if (rotation != 0) {
      elem.setAttribute("transform", elem.getAttribute("transform") + " rotate(" + rotation + "," + cx + "," + cy + ")");

    }

    if (opacity != 100) {
      String value = (opacity / 100).toString();
      elem.setAttribute("fill-opacity", value);
      elem.setAttribute("stroke-opacity", value);
    }

    if (Utils.isTrue(style, Constants.STYLE_DASHED)) {
      String pattern = Utils.getString(style, Constants.STYLE_DASH_PATTERN, "3, 3");
      elem.setAttribute("stroke-dasharray", pattern);
    }

    appendSvgElement(elem);

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
    Element group = _document.createElement("g");
    Element path = _document.createElement("path");

    bool rounded = Utils.isTrue(style, Constants.STYLE_ROUNDED, false);
    String strokeColor = Utils.getString(style, Constants.STYLE_STROKECOLOR);
    double tmpStroke = Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1);
    double strokeWidth = (tmpStroke * _scale) as double;

    if (strokeColor != null && strokeWidth > 0) {
      // Draws the start marker
      Object marker = style[Constants.STYLE_STARTARROW];

      Point2d pt = pts[1];
      Point2d p0 = pts[0];
      Point2d offset = null;

      if (marker != null) {
        double size = Utils.getFloat(style, Constants.STYLE_STARTSIZE, Constants.DEFAULT_MARKERSIZE);
        offset = drawMarker(group, marker, pt, p0, size, tmpStroke, strokeColor);
      } else {
        double dx = pt.getX() - p0.getX();
        double dy = pt.getY() - p0.getY();

        double dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
        double nx = dx * strokeWidth / dist;
        double ny = dy * strokeWidth / dist;

        offset = new Point2d(nx / 2, ny / 2);
      }

      // Applies offset to the point
      if (offset != null) {
        p0 = p0.clone() as Point2d;
        p0.setX(p0.getX() + offset.getX());
        p0.setY(p0.getY() + offset.getY());

        offset = null;
      }

      // Draws the end marker
      marker = style[Constants.STYLE_ENDARROW];

      pt = pts[pts.length - 2];
      Point2d pe = pts[pts.length - 1];

      if (marker != null) {
        double size = Utils.getFloat(style, Constants.STYLE_ENDSIZE, Constants.DEFAULT_MARKERSIZE);
        offset = drawMarker(group, marker, pt, pe, size, tmpStroke, strokeColor);
      } else {
        double dx = pt.getX() - p0.getX();
        double dy = pt.getY() - p0.getY();

        double dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
        double nx = dx * strokeWidth / dist;
        double ny = dy * strokeWidth / dist;

        offset = new Point2d(nx / 2, ny / 2);
      }

      // Applies offset to the point
      if (offset != null) {
        pe = pe.clone() as Point2d;
        pe.setX(pe.getX() + offset.getX());
        pe.setY(pe.getY() + offset.getY());

        offset = null;
      }

      // Draws the line segments
      double arcSize = Constants.LINE_ARCSIZE * _scale;
      pt = p0;
      String d = "M " + pt.getX() + " " + pt.getY();

      for (int i = 1; i < pts.length - 1; i++) {
        Point2d tmp = pts[i];
        double dx = pt.getX() - tmp.getX();
        double dy = pt.getY() - tmp.getY();

        if ((rounded && i < pts.length - 1) && (dx != 0 || dy != 0)) {
          // Draws a line from the last point to the current
          // point with a spacing of size off the current point
          // into direction of the last point
          double dist = Math.sqrt(dx * dx + dy * dy);
          double nx1 = dx * Math.min(arcSize, dist / 2) / dist;
          double ny1 = dy * Math.min(arcSize, dist / 2) / dist;

          double x1 = tmp.getX() + nx1;
          double y1 = tmp.getY() + ny1;
          d += " L " + x1 + " " + y1;

          // Draws a curve from the last point to the current
          // point with a spacing of size off the current point
          // into direction of the next point
          Point2d next = pts[i + 1];
          dx = next.getX() - tmp.getX();
          dy = next.getY() - tmp.getY();

          dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
          double nx2 = dx * Math.min(arcSize, dist / 2) / dist;
          double ny2 = dy * Math.min(arcSize, dist / 2) / dist;

          double x2 = tmp.getX() + nx2;
          double y2 = tmp.getY() + ny2;

          d += " Q " + tmp.getX() + " " + tmp.getY() + " " + x2 + " " + y2;
          tmp = new Point2d(x2, y2);
        } else {
          d += " L " + tmp.getX() + " " + tmp.getY();
        }

        pt = tmp;
      }

      d += " L " + pe.getX() + " " + pe.getY();

      path.setAttribute("d", d);
      path.setAttribute("stroke", strokeColor);
      path.setAttribute("fill", "none");
      path.setAttribute("stroke-width", strokeWidth.toString());

      if (Utils.isTrue(style, Constants.STYLE_DASHED)) {
        String pattern = Utils.getString(style, Constants.STYLE_DASH_PATTERN, "3, 3");
        path.setAttribute("stroke-dasharray", pattern);
      }

      group.append(path);
      appendSvgElement(group);
    }

    return group;
  }

  /**
	 * Draws the specified marker as a child path in the given parent.
	 */
  Point2d drawMarker(Element parent, Object type, Point2d p0, Point2d pe, double size, double strokeWidth, String color) {
    Point2d offset = null;

    // Computes the norm and the inverse norm
    double dx = pe.getX() - p0.getX();
    double dy = pe.getY() - p0.getY();

    double dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
    double absSize = size * _scale;
    double nx = dx * absSize / dist;
    double ny = dy * absSize / dist;

    pe = pe.clone() as Point2d;
    pe.setX(pe.getX() - nx * strokeWidth / (2 * size));
    pe.setY(pe.getY() - ny * strokeWidth / (2 * size));

    nx *= 0.5 + strokeWidth / 2;
    ny *= 0.5 + strokeWidth / 2;

    Element path = _document.createElement("path");
    path.setAttribute("stroke-width", (strokeWidth * _scale).toString());
    path.setAttribute("stroke", color);
    path.setAttribute("fill", color);

    String d = null;

    if (type == Constants.ARROW_CLASSIC || type == Constants.ARROW_BLOCK) {
      d = "M " + pe.getX() + " " + pe.getY() + " L " + (pe.getX() - nx - ny / 2) + " " + (pe.getY() - ny + nx / 2) + ((type != Constants.ARROW_CLASSIC) ? "" : " L " + (pe.getX() - nx * 3 / 4) + " " + (pe.getY() - ny * 3 / 4)) + " L " + (pe.getX() + ny / 2 - nx) + " " + (pe.getY() - ny - nx / 2) + " z";
    } else if (type == Constants.ARROW_OPEN) {
      nx *= 1.2;
      ny *= 1.2;

      d = "M " + (pe.getX() - nx - ny / 2) + " " + (pe.getY() - ny + nx / 2) + " L " + (pe.getX() - nx / 6) + " " + (pe.getY() - ny / 6) + " L " + (pe.getX() + ny / 2 - nx) + " " + (pe.getY() - ny - nx / 2) + " M " + pe.getX() + " " + pe.getY();
      path.setAttribute("fill", "none");
    } else if (type == Constants.ARROW_OVAL) {
      nx *= 1.2;
      ny *= 1.2;
      absSize *= 1.2;

      d = "M " + (pe.getX() - ny / 2) + " " + (pe.getY() + nx / 2) + " a " + (absSize / 2) + " " + (absSize / 2) + " 0  1,1 " + (nx / 8) + " " + (ny / 8) + " z";
    } else if (type == Constants.ARROW_DIAMOND) {
      d = "M " + (pe.getX() + nx / 2) + " " + (pe.getY() + ny / 2) + " L " + (pe.getX() - ny / 2) + " " + (pe.getY() + nx / 2) + " L " + (pe.getX() - nx / 2) + " " + (pe.getY() - ny / 2) + " L " + (pe.getX() + ny / 2) + " " + (pe.getY() - nx / 2) + " z";
    }

    if (d != null) {
      path.setAttribute("d", d);
      parent.append(path);
    }

    return offset;
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
  Object drawText(String text, int x, int y, int w, int h, Map<String, Object> style) {
    Element elem = null;
    String fontColor = Utils.getString(style, Constants.STYLE_FONTCOLOR, "black");
    String fontFamily = Utils.getString(style, Constants.STYLE_FONTFAMILY, Constants.DEFAULT_FONTFAMILIES);
    int fontSize = (int)(Utils.getInt(style, Constants.STYLE_FONTSIZE, Constants.DEFAULT_FONTSIZE) * _scale);

    if (text != null && text.length > 0) {
      double strokeWidth = (Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale) as double;

      // Applies the opacity
      double opacity = Utils.getFloat(style, Constants.STYLE_TEXT_OPACITY, 100);

      // Draws the label background and border
      String bg = Utils.getString(style, Constants.STYLE_LABEL_BACKGROUNDCOLOR);
      String border = Utils.getString(style, Constants.STYLE_LABEL_BORDERCOLOR);

      String transform = null;

      if (!Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
        double cx = x + w / 2;
        double cy = y + h / 2;
        transform = "rotate(270 " + cx + " " + cy + ")";
      }

      if (bg != null || border != null) {
        Element background = _document.createElement("rect");

        background.setAttribute("x", x.toString());
        background.setAttribute("y", y.toString());
        background.setAttribute("width", w.toString());
        background.setAttribute("height", h.toString());

        if (bg != null) {
          background.setAttribute("fill", bg);
        } else {
          background.setAttribute("fill", "none");
        }

        if (border != null) {
          background.setAttribute("stroke", border);
        } else {
          background.setAttribute("stroke", "none");
        }

        background.setAttribute("stroke-width", strokeWidth.toString());

        if (opacity != 100) {
          String value = (opacity / 100).toString();
          background.setAttribute("fill-opacity", value);
          background.setAttribute("stroke-opacity", value);
        }

        if (transform != null) {
          background.setAttribute("transform", transform);
        }

        appendSvgElement(background);
      }

      elem = _document.createElement("text");

      int fontStyle = Utils.getInt(style, Constants.STYLE_FONTSTYLE);
      String weight = ((fontStyle & Constants.FONT_BOLD) == Constants.FONT_BOLD) ? "bold" : "normal";
      elem.setAttribute("font-weight", weight);
      String uline = ((fontStyle & Constants.FONT_UNDERLINE) == Constants.FONT_UNDERLINE) ? "underline" : "none";
      elem.setAttribute("font-decoration", uline);

      if ((fontStyle & Constants.FONT_ITALIC) == Constants.FONT_ITALIC) {
        elem.setAttribute("font-style", "italic");
      }

      elem.setAttribute("font-size", (fontSize).toString());
      elem.setAttribute("font-family", fontFamily);
      elem.setAttribute("fill", fontColor);

      if (opacity != 100) {
        String value = (opacity / 100).toString();
        elem.setAttribute("fill-opacity", value);
        elem.setAttribute("stroke-opacity", value);
      }

      int swingFontStyle = ((fontStyle & Constants.FONT_BOLD) == Constants.FONT_BOLD) ? Font.BOLD : Font.PLAIN;
      swingFontStyle += ((fontStyle & Constants.FONT_ITALIC) == Constants.FONT_ITALIC) ? Font.ITALIC : Font.PLAIN;

      List<String> lines = text.split("\n");
      y += fontSize + (h - lines.length * (fontSize + Constants.LINESPACING)) / 2 - 2;

      String align = Utils.getString(style, Constants.STYLE_ALIGN, Constants.ALIGN_CENTER);
      String anchor = "start";

      if (align == Constants.ALIGN_RIGHT) {
        anchor = "end";
        x += w - Constants.LABEL_INSET * _scale;
      } else if (align == Constants.ALIGN_CENTER) {
        anchor = "middle";
        x += w / 2;
      } else {
        x += Constants.LABEL_INSET * _scale;
      }

      elem.setAttribute("text-anchor", anchor);

      for (int i = 0; i < lines.length; i++) {
        Element tspan = _document.createElement("tspan");

        tspan.setAttribute("x", x.toString());
        tspan.setAttribute("y", y.toString());

        tspan.append(_document.createTextNode(lines[i]));
        elem.append(tspan);

        y += fontSize + Constants.LINESPACING;
      }

      if (transform != null) {
        elem.setAttribute("transform", transform);
      }

      appendSvgElement(elem);
    }

    return elem;
  }

}
