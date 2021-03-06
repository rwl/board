/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.canvas;

//import java.awt.AlphaComposite;
//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Dimension;
//import java.awt.GradientPaint;
//import java.awt.Graphics2D;
//import java.awt.Image;
//import java.awt.Paint;
//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.Stroke;
//import java.awt.geom.AffineTransform;
//import java.awt.geom.GeneralPath;

//import javax.swing.CellRendererPane;

/**
 * An implementation of a canvas that uses Graphics2D for painting.
 */
class Graphics2DCanvas extends BasicCanvas {
  
  static final String TEXT_SHAPE_DEFAULT = "default";

  static final String TEXT_SHAPE_HTML = "html";

  /**
   * Specifies the image scaling quality. Default is Image.SCALE_SMOOTH.
   */
  //static int IMAGE_SCALING = Image.SCALE_SMOOTH;
  static bool IMAGE_SCALING = true;

  /**
   * Maps from names to mxIVertexShape instances.
   */
  static Map<String, IShape> _shapes = new HashMap<String, IShape>();

  /**
   * Maps from names to ITextShape instances. There are currently three different
   * hardcoded text shapes available here: default, html and wrapped.
   */
  static Map<String, ITextShape> _textShapes = new HashMap<String, ITextShape>();

  /**
   * Static initializer.
   */
  static init() {
    putShape(Constants.SHAPE_ACTOR, new ActorShape());
    putShape(Constants.SHAPE_ARROW, new ArrowShape());
    putShape(Constants.SHAPE_CLOUD, new CloudShape());
    putShape(Constants.SHAPE_CONNECTOR, new ConnectorShape());
    putShape(Constants.SHAPE_CYLINDER, new CylinderShape());
    putShape(Constants.SHAPE_CURVE, new CurveShape());
    putShape(Constants.SHAPE_DOUBLE_RECTANGLE, new DoubleRectangleShape());
    putShape(Constants.SHAPE_DOUBLE_ELLIPSE, new DoubleEllipseShape());
    putShape(Constants.SHAPE_ELLIPSE, new EllipseShape());
    putShape(Constants.SHAPE_HEXAGON, new HexagonShape());
    putShape(Constants.SHAPE_IMAGE, new ImageShape());
    putShape(Constants.SHAPE_LABEL, new LabelShape());
    putShape(Constants.SHAPE_LINE, new LineShape());
    putShape(Constants.SHAPE_RECTANGLE, new RectangleShape());
    putShape(Constants.SHAPE_RHOMBUS, new RhombusShape());
    putShape(Constants.SHAPE_SWIMLANE, new SwimlaneShape());
    putShape(Constants.SHAPE_TRIANGLE, new TriangleShape());
    putTextShape(TEXT_SHAPE_DEFAULT, new DefaultTextShape());
    putTextShape(TEXT_SHAPE_HTML, new HtmlTextShape());
  }

  /**
   * Optional renderer pane to be used for HTML label rendering.
   */
  //CellRendererPane _rendererPane;

  /**
   * Global graphics handle to the image.
   */
  CanvasRenderingContext2D _g;

  /**
   * Constructs a new graphics canvas with an empty graphics object.
   */
//  Graphics2DCanvas() {
//    this(null);
//  }

  /**
   * Constructs a new graphics canvas for the given graphics object.
   */
  Graphics2DCanvas([CanvasRenderingContext2D g=null]) {
    this._g = g;

    // Initializes the cell renderer pane for drawing HTML markup
    /*try {
      _rendererPane = new CellRendererPane();
    } on Exception catch (e) {
      // ignore
    }*/
  }

  static void putShape(String name, IShape shape) {
    _shapes[name] = shape;
  }

  IShape getShape(Map<String, Object> style) {
    String name = Utils.getString(style, Constants.STYLE_SHAPE, null);
    IShape shape = _shapes[name];

    if (shape == null && name != null) {
      shape = StencilRegistry.getStencil(name);
    }

    return shape;
  }

  static void putTextShape(String name, ITextShape shape) {
    _textShapes[name] = shape;
  }

  ITextShape getTextShape(Map<String, Object> style, bool html) {
    String name;

    if (html) {
      name = TEXT_SHAPE_HTML;
    } else {
      name = TEXT_SHAPE_DEFAULT;
    }

    return _textShapes[name];
  }

  /*CellRendererPane getRendererPane() {
    return _rendererPane;
  }*/

  /**
   * Returns the graphics object for this canvas.
   */
  CanvasRenderingContext2D getGraphics() {
    return _g;
  }

  /**
   * Sets the graphics object for this canvas.
   */
  void setGraphics(CanvasRenderingContext2D g) {
    this._g = g;
  }

  /*
   * (non-Javadoc)
   * @see graph.canvas.ICanvas#drawCell()
   */
  Object drawCell(CellState state) {
    Map<String, Object> style = state.getStyle();
    IShape shape = getShape(style);

    if (_g != null && shape != null) {
      // Creates a temporary graphics instance for drawing this shape
      double opacity = Utils.getFloat(style, Constants.STYLE_OPACITY, 100.0);
      CanvasRenderingContext2D previousGraphics = _g;
      _g = createTemporaryGraphics(style, opacity, state);

      // Paints the shape and restores the graphics object
      shape.paintShape(this, state);
      _g.restore();
      _g = previousGraphics;
    }

    return shape;
  }

  /*
   * (non-Javadoc)
   * @see graph.canvas.ICanvas#drawLabel()
   */
  Object drawLabel(String text, CellState state, bool html) {
    Map<String, Object> style = state.getStyle();
    ITextShape shape = getTextShape(style, html);

    if (_g != null && shape != null && _drawLabels && text != null && text.length > 0) {
      // Creates a temporary graphics instance for drawing this shape
      double opacity = Utils.getFloat(style, Constants.STYLE_TEXT_OPACITY, 100.0);
      CanvasRenderingContext2D previousGraphics = _g;
      _g = createTemporaryGraphics(style, opacity, null);

      // Draws the label background and border
      awt.Color bg = Utils.getColor(style, Constants.STYLE_LABEL_BACKGROUNDCOLOR);
      awt.Color border = Utils.getColor(style, Constants.STYLE_LABEL_BORDERCOLOR);
      paintRectangle(state.getLabelBounds().getRectangle(), bg, border);

      // Paints the label and restores the graphics object
      shape.paintShape(this, text, state, style);
      _g.restore();
      _g = previousGraphics;
    }

    return shape;
  }

  //	void drawImage(awt.Rectangle bounds, String imageUrl)
  //	{
  //		drawImage(bounds, imageUrl, PRESERVE_IMAGE_ASPECT, false, false);
  //	}

  void drawImage(awt.Rectangle bounds, String imageUrl, [bool preserveAspect = null, bool flipH = false, bool flipV = false]) {
    if (imageUrl != null && bounds.getWidth() > 0 && bounds.getHeight() > 0) {
      image.Image img = loadImage(imageUrl);

      if (img != null) {
        int w, h;
        int x = bounds.x;
        int y = bounds.y;
        awt.Dimension size = _getImageSize(img);

        if (preserveAspect == null) {
          preserveAspect = BasicCanvas.PRESERVE_IMAGE_ASPECT;
        }
        if (preserveAspect) {
          double s = Math.min(bounds.width / (size.width as double), bounds.height / (size.height as double));
          w = (size.width * s) as int;
          h = (size.height * s) as int;
          x += (bounds.width - w) / 2;
          y += (bounds.height - h) / 2;
        } else {
          w = bounds.width;
          h = bounds.height;
        }

        image.Image scaledImage = (w == size.width && h == size.height) ? img : img.getScaledInstance(w, h, IMAGE_SCALING);

        if (scaledImage != null) {
          Matrix af = null;

          if (flipH || flipV) {
            af = _g.currentTransform;
            int sx = 1;
            int sy = 1;
            int dx = 0;
            int dy = 0;

            if (flipH) {
              sx = -1;
              dx = -w - 2 * x;
            }

            if (flipV) {
              sy = -1;
              dy = -h - 2 * y;
            }

            _g.scale(sx, sy);
            _g.translate(dx, dy);
          }

          _drawImageImpl(scaledImage, x, y);

          // Restores the previous transform
          if (af != null) {
            _g.setTransform(af.a, af.b, af.c, af.d, af.e, af.f);
          }
        }
      }
    }
  }

  /**
   * Implements the actual graphics call.
   */
  void _drawImageImpl(ImageElement image, int x, int y) {
    _g.drawImage(image, x, y);//, null);
  }

  /**
   * Returns the size for the given image.
   */
  awt.Dimension _getImageSize(image.Image image) {
    //return new awt.Dimension(image.getWidth(null), image.getHeight(null));
    return new awt.Dimension(image.width, image.height);
  }

  void paintPolyline(List<Point2d> points, bool rounded) {
    if (points != null && points.length > 1) {
      Point2d pt = points[0];
      Point2d pe = points[points.length - 1];

      double arcSize = Constants.LINE_ARCSIZE * _scale;

      awt.GeneralPath path = new awt.GeneralPath();
      path.moveTo(pt.getX(), pt.getY());

      // Draws the line segments
      for (int i = 1; i < points.length - 1; i++) {
        Point2d tmp = points[i];
        double dx = pt.getX() - tmp.getX();
        double dy = pt.getY() - tmp.getY();

        if ((rounded && i < points.length - 1) && (dx != 0 || dy != 0)) {
          // Draws a line from the last point to the current
          // point with a spacing of size off the current point
          // into direction of the last point
          double dist = Math.sqrt(dx * dx + dy * dy);
          double nx1 = dx * Math.min(arcSize, dist / 2) / dist;
          double ny1 = dy * Math.min(arcSize, dist / 2) / dist;

          double x1 = tmp.getX() + nx1;
          double y1 = tmp.getY() + ny1;
          path.lineTo(x1, y1);

          // Draws a curve from the last point to the current
          // point with a spacing of size off the current point
          // into direction of the next point
          Point2d next = points[i + 1];

          // Uses next non-overlapping point
          while (i < points.length - 2 && math.round(next.getX() - tmp.getX()) == 0 && math.round(next.getY() - tmp.getY()) == 0) {
            next = points[i + 2];
            i++;
          }

          dx = next.getX() - tmp.getX();
          dy = next.getY() - tmp.getY();

          dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
          double nx2 = dx * Math.min(arcSize, dist / 2) / dist;
          double ny2 = dy * Math.min(arcSize, dist / 2) / dist;

          double x2 = tmp.getX() + nx2;
          double y2 = tmp.getY() + ny2;

          path.quadTo(tmp.getX(), tmp.getY(), x2, y2);
          tmp = new Point2d(x2, y2);
        } else {
          path.lineTo(tmp.getX(), tmp.getY());
        }

        pt = tmp;
      }

      path.lineTo((pe.getX()), pe.getY());
      //_g.draw(path);
      path.draw(_g);
    }
  }

  void paintRectangle(awt.Rectangle bounds, awt.Color background, awt.Color border) {
    if (background != null) {
      background.setCanvasFillColor(_g);
      fillShape(bounds);
    }

    if (border != null) {
      border.setCanvasStrokeColor(_g);
      bounds.draw(_g);
    }
  }

  void fillShape(awt.Shape shape, [bool shadow = false]) {
    int shadowOffsetX = (shadow) ? Constants.SHADOW_OFFSETX : 0;
    int shadowOffsetY = (shadow) ? Constants.SHADOW_OFFSETY : 0;

    if (shadow) {
      // Saves the state and configures the graphics object
      //awt.Paint p = _g.getPaint();
      //awt.Color previousColor = new awt.Color.canvasFill(_g);
      _g.save();
      //_g.setColor(SwingConstants.SHADOW_COLOR);
      SwingConstants.SHADOW_COLOR.setCanvasFillColor(_g);
      _g.translate(shadowOffsetX, shadowOffsetY);

      // Paints the shadow
      fillShape(shape, false);

      // Restores the state of the graphics object
      _g.translate(-shadowOffsetX, -shadowOffsetY);
      //previousColor.setCanvasFillColor(_g);
      //_g.setPaint(p);
      _g.restore();
    }

    shape.fill(_g);
  }

  awt.Stroke createStroke(Map<String, Object> style) {
    double width = Utils.getFloat(style, Constants.STYLE_STROKEWIDTH, 1.0) * _scale;
    bool dashed = Utils.isTrue(style, Constants.STYLE_DASHED);
    if (dashed) {
      List<double> dashPattern = Utils.getFloatArray(style, Constants.STYLE_DASH_PATTERN, Constants.DEFAULT_DASHED_PATTERN, " ");
      List<double> scaledDashPattern = new List<double>(dashPattern.length);

      for (int i = 0; i < dashPattern.length; i++) {
        scaledDashPattern[i] = (dashPattern[i] * _scale * width);
      }

      return new awt.Stroke(width, awt.Stroke.CAP_BUTT, awt.Stroke.JOIN_MITER, 10.0, scaledDashPattern, 0.0);
    } else {
      return new awt.Stroke(width);
    }
  }

  awt.Paint createFillPaint(Rect bounds, Map<String, Object> style) {
    awt.Color fillColor = Utils.getColor(style, Constants.STYLE_FILLCOLOR);
    awt.Paint fillPaint = null;

    if (fillColor != null) {
      awt.Color gradientColor = Utils.getColor(style, Constants.STYLE_GRADIENTCOLOR);

      if (gradientColor != null) {
        String gradientDirection = Utils.getString(style, Constants.STYLE_GRADIENT_DIRECTION);

        double x1 = bounds.getX();
        double y1 = bounds.getY();
        double x2 = bounds.getX();
        double y2 = bounds.getY();

        if (gradientDirection == null || gradientDirection == Constants.DIRECTION_SOUTH) {
          y2 = (bounds.getY() + bounds.getHeight());
        } else if (gradientDirection == Constants.DIRECTION_EAST) {
          x2 = (bounds.getX() + bounds.getWidth());
        } else if (gradientDirection == Constants.DIRECTION_NORTH) {
          y1 = (bounds.getY() + bounds.getHeight());
        } else if (gradientDirection == Constants.DIRECTION_WEST) {
          x1 = (bounds.getX() + bounds.getWidth());
        }

        fillPaint = new awt.GradientPaint.at(x1, y1, fillColor, x2, y2, gradientColor, true);
      }
    }

    return fillPaint;
  }

  CanvasRenderingContext2D createTemporaryGraphics(Map<String, Object> style, double opacity, Rect bounds) {
    _g.save();
    CanvasRenderingContext2D temporaryGraphics = _g;//.create() as CanvasRenderingContext2D;

    // Applies the default translate
    temporaryGraphics.translate(_translate.x, _translate.y);

    // Applies the rotation on the graphics object
    if (bounds != null) {
      double rotation = Utils.getDouble(style, Constants.STYLE_ROTATION, 0.0);

      if (rotation != 0) {
        temporaryGraphics.rotate(math.toRadians(rotation));//, bounds.getCenterX(), bounds.getCenterY());
      }
    }

    // Applies the opacity to the graphics object
    if (opacity != 100) {
      //temporaryGraphics.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, opacity / 100));
      temporaryGraphics.globalAlpha = opacity / 100;
    }

    return temporaryGraphics;
  }

}
