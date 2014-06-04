/**
 * Copyright (c) 2010, David Benson, Gaudenz Alder
 */
part of graph.shape;

//import java.awt.Color;
//import java.awt.Font;
//import java.awt.FontMetrics;
//import java.awt.Graphics2D;
//import java.awt.Rectangle;
//import java.awt.RenderingHints;
//import java.awt.Shape;
//import java.awt.font.FontRenderContext;
//import java.awt.font.GlyphVector;
//import java.awt.geom.AffineTransform;
//import java.awt.geom.awt.Line2D;
//import java.text.Bidi;
//import java.text.BreakIterator;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Locale;
//import java.util.Map;

/**
 * Draws the edge label along a curve derived from the curve describing
 * the edge's path
 */
class CurveLabelShape implements ITextShape {
  /**
	 * Cache of the label text
	 */
  String _lastValue;

  /**
	 * Cache of the label font
	 */
  Font _lastFont;

  /**
	 * Cache of the last set of guide points that this label was calculated for
	 */
  List<Point2d> _lastPoints;

  /**
	 * Cache of the points between which drawing straight lines views as a
	 * curve
	 */
  Curve _curve;

  /**
	 * Cache the state associated with this shape
	 */
  CellState _state;

  /**
	 * Cache of information describing characteristics relating to drawing 
	 * each glyph of this label
	 */
  List<LabelGlyphCache> _labelGlyphs;

  /**
	 * Cache of the total length of the branch label
	 */
  double _labelSize;

  /**
	 * Cache of the bounds of the label
	 */
  Rect _labelBounds;

  /**
	 * ADT to encapsulate label positioning information
	 */
  LabelPosition _labelPosition = new LabelPosition();

  /**
	 * Buffer at both ends of the label
	 */
  static double LABEL_BUFFER = 30.0;

  /**
	 * Factor by which text on the inside of curve is stretched
	 */
  static double CURVE_TEXT_STRETCH_FACTOR = 20.0;

  /**
	 * Indicates that a glyph does not have valid drawing bounds, usually 
	 * because it is not visible
	 */
  static Rect INVALID_GLYPH_BOUNDS = new Rect(0.0, 0.0, 0.0, 0.0);

  /**
	 * The index of the central glyph of the label that is visible
	 */
  int centerVisibleIndex = 0;

  /**
	 * Specifies if image aspect should be preserved in drawImage. Default is true.
	 */
  static Object FONT_FRACTIONALMETRICS = RenderingHints.VALUE_FRACTIONALMETRICS_DEFAULT;

  /**
	 * Cache of BIDI glyph vectors
	 */
  List<GlyphVector> rtlGlyphVectors;

  /**
	 * Shared FRC for font size calculations
	 */
  static FontRenderContext frc = new FontRenderContext(null, false, false);

  /**
	 *
	 */
  bool _rotationEnabled = true;

  CurveLabelShape(CellState state, Curve value) {
    this._state = state;
    this._curve = value;
  }

  /**
	 *
	 */
  bool getRotationEnabled() {
    return _rotationEnabled;
  }

  /**
	 *
	 */
  void setRotationEnabled(bool value) {
    _rotationEnabled = value;
  }

  /**
	 * 
	 */
  void paintShape(Graphics2DCanvas canvas, String text, CellState state, Map<String, Object> style) {
    awt.Rectangle rect = state.getLabelBounds().getRectangle();
    Graphics2D g = canvas.getGraphics();

    if (_labelGlyphs == null) {
      updateLabelBounds(text, style);
    }

    if (_labelGlyphs != null && (g.getClipBounds() == null || g.getClipBounds().intersects(rect))) {
      // Creates a temporary graphics instance for drawing this shape
      float opacity = Utils.getFloat(style, Constants.STYLE_OPACITY, 100.0);
      Graphics2D previousGraphics = g;
      g = canvas.createTemporaryGraphics(style, opacity, state);

      Font font = Utils.getFont(style, canvas.getScale());
      g.setFont(font);

      awt.Color fontColor = Utils.getColor(style, Constants.STYLE_FONTCOLOR, awt.Color.black);
      g.setColor(fontColor);

      g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

      g.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, FONT_FRACTIONALMETRICS);

      for (int j = 0; j < _labelGlyphs.length; j++) {
        Line parallel = _labelGlyphs[j].glyphGeometry;

        if (_labelGlyphs[j].visible && parallel != null && parallel != Curve.INVALID_POSITION) {
          Point2d parallelEnd = parallel.getEndPoint();
          double x = parallelEnd.getX();
          double rotation = (Math.atan(parallelEnd.getY() / x));

          if (x < 0) {
            // atan only ranges from -PI/2 to PI/2, have to offset
            // for negative x values
            rotation += Math.PI;
          }

          final AffineTransform old = g.getTransform();
          g.translate(parallel.getX(), parallel.getY());
          g.rotate(rotation);
          Shape letter = _labelGlyphs[j].glyphShape;
          g.fill(letter);
          g.setTransform(old);
        }
      }

      g.dispose();
      g = previousGraphics;
    }
  }

  /**
	 * Updates the cached position and size of each glyph in the edge label. 
	 * @param label the entire string of the label.
	 * @param style the edge style
	 */
  Rect updateLabelBounds(String label, Map<String, Object> style) {
    double scale = _state.getView().getScale();
    Font font = Utils.getFont(style, scale);
    FontMetrics fm = Utils.getFontMetrics(font);
    int descent = 0;
    int ascent = 0;

    if (fm != null) {
      descent = fm.getDescent();
      ascent = fm.getAscent();
    }

    // Check that the size of the widths array matches
    // that of the label size
    if (_labelGlyphs == null || (label != _lastValue)) {
      _labelGlyphs = new List<LabelGlyphCache>(label.length);
    }

    if (label != _lastValue || font != _lastFont) {
      List<char> labelChars = label.toCharArray();
      ArrayList<LabelGlyphCache> glyphList = new List<LabelGlyphCache>();
      bool bidiRequired = Bidi.requiresBidi(labelChars, 0, labelChars.length);

      _labelSize = 0.0;

      if (bidiRequired) {
        Bidi bidi = new Bidi(label, Bidi.DIRECTION_DEFAULT_LEFT_TO_RIGHT);

        int runCount = bidi.getRunCount();

        if (rtlGlyphVectors == null || rtlGlyphVectors.length != runCount) {
          rtlGlyphVectors = new List<GlyphVector>(runCount);
        }

        for (int i = 0; i < bidi.getRunCount(); i++) {
          final String labelSection = label.substring(bidi.getRunStart(i), bidi.getRunLimit(i));
          rtlGlyphVectors[i] = font.layoutGlyphVector(CurveLabelShape.frc, labelSection.toCharArray(), 0, labelSection.length, Font.LAYOUT_RIGHT_TO_LEFT);
        }

        int charCount = 0;

        for (GlyphVector gv in rtlGlyphVectors) {
          double vectorOffset = 0.0;

          for (int j = 0; j < gv.getNumGlyphs(); j++) {
            Shape shape = gv.getGlyphOutline(j, -vectorOffset, 0);

            LabelGlyphCache qlyph = new LabelGlyphCache();
            glyphList.add(qlyph);
            qlyph.glyphShape = shape;
            Rect size = new Rect(gv.getGlyphLogicalBounds(j).getBounds2D());
            qlyph.labelGlyphBounds = size;
            _labelSize += size.getWidth();
            vectorOffset += size.getWidth();

            charCount++;
          }
        }
      } else {
        rtlGlyphVectors = null;
        //String locale = System.getProperty("user.language");
        // Character iterator required where character is split over
        // string elements
        BreakIterator it = BreakIterator.getCharacterInstance(Locale.getDefault());
        it.setText(label);

        for (int i = 0; i < label.length; ) {
          int next = it.current();
          int characterLen = 1;

          if (next != BreakIterator.DONE) {
            characterLen = next - i;
          }

          String glyph = label.substring(i, i + characterLen);

          LabelGlyphCache labelGlyph = new LabelGlyphCache();
          glyphList.add(labelGlyph);
          labelGlyph.glyph = glyph;
          GlyphVector vector = font.createGlyphVector(frc, glyph);
          labelGlyph.glyphShape = vector.getOutline();

          if (fm == null) {
            Rect size = new Rect(font.getStringBounds(glyph, CurveLabelShape.frc));
            labelGlyph.labelGlyphBounds = size;
            _labelSize += size.getWidth();
          } else {
            double width = fm.stringWidth(glyph);
            labelGlyph.labelGlyphBounds = new Rect(0.0, 0.0, width, ascent.toDouble());
            _labelSize += width;
          }

          i += characterLen;


        }
      }

      // Update values used to determine whether or not the label cache
      // is valid or not
      _lastValue = label;
      _lastFont = font;
      _lastPoints = _curve.getGuidePoints();
      this._labelGlyphs = glyphList.toArray(new List<LabelGlyphCache>(glyphList.length));
    }

    // Store the start/end buffers that pad out the ends of the branch so the label is
    // visible. We work initially as the start section being at the start of the
    // branch and the end at the end of the branch. Note that the actual label curve
    // might be reversed, so we allow for this after completing the buffer calculations,
    // otherwise they'd need to be constant isReversed() checks throughout
    _labelPosition.startBuffer = LABEL_BUFFER * scale;
    _labelPosition.endBuffer = LABEL_BUFFER * scale;

    _calculationLabelPosition(style, label);

    if (_curve.isLabelReversed()) {
      double temp = _labelPosition.startBuffer;
      _labelPosition.startBuffer = _labelPosition.endBuffer;
      _labelPosition.endBuffer = temp;
    }

    double curveLength = _curve.getCurveLength(Curve.LABEL_CURVE);
    double currentPos = _labelPosition.startBuffer / curveLength;
    double endPos = 1.0 - (_labelPosition.endBuffer / curveLength);

    Rect overallLabelBounds = null;
    centerVisibleIndex = 0;

    double currentCurveDelta = 0.0;
    double curveDeltaSignificant = 0.3;
    double curveDeltaMax = 0.5;
    Line nextParallel = null;

    // TODO on translation just move the points, don't recalculate
    // Might be better than the curve is the only thing updated and
    // the curve shapes listen to curve events
    // !lastPoints.equals(curve.getGuidePoints())
    for (int j = 0; j < _labelGlyphs.length; j++) {
      if (currentPos > endPos) {
        _labelGlyphs[j].visible = false;
        continue;
      }

      Line parallel = nextParallel;

      if (currentCurveDelta > curveDeltaSignificant || nextParallel == null) {
        parallel = _curve.getCurveParallel(Curve.LABEL_CURVE, currentPos);

        currentCurveDelta = 0.0;
        nextParallel = null;
      }

      _labelGlyphs[j].glyphGeometry = parallel;

      if (parallel == Curve.INVALID_POSITION) {
        continue;
      }

      // Get the four corners of the rotated rectangle bounding the glyph
      // The drawing bounds of the glyph is the unrotated rect that
      // just bounds those four corners
      final double w = _labelGlyphs[j].labelGlyphBounds.getWidth();
      final double h = _labelGlyphs[j].labelGlyphBounds.getHeight();
      final double x = parallel.getEndPoint().getX();
      final double y = parallel.getEndPoint().getY();
      // Bottom left
      double p1X = parallel.getX() - (descent * y);
      double minX = p1X,
          maxX = p1X;
      double p1Y = parallel.getY() + (descent * x);
      double minY = p1Y,
          maxY = p1Y;
      // Top left
      double p2X = p1X + ((h + descent) * y);
      double p2Y = p1Y - ((h + descent) * x);
      minX = Math.min(minX, p2X);
      maxX = Math.max(maxX, p2X);
      minY = Math.min(minY, p2Y);
      maxY = Math.max(maxY, p2Y);
      // Bottom right
      double p3X = p1X + (w * x);
      double p3Y = p1Y + (w * y);
      minX = Math.min(minX, p3X);
      maxX = Math.max(maxX, p3X);
      minY = Math.min(minY, p3Y);
      maxY = Math.max(maxY, p3Y);
      // Top right
      double p4X = p2X + (w * x);
      double p4Y = p2Y + (w * y);
      minX = Math.min(minX, p4X);
      maxX = Math.max(maxX, p4X);
      minY = Math.min(minY, p4Y);
      maxY = Math.max(maxY, p4Y);

      minX -= 2 * scale;
      minY -= 2 * scale;
      maxX += 2 * scale;
      maxY += 2 * scale;

      // Hook for sub-classers
      _postprocessGlyph(_curve, label, j, currentPos);

      // Need to allow for text on inside of curve bends. Need to get the
      // parallel for the next section, if there is an excessive
      // inner curve, advance the current position accordingly

      double currentPosCandidate = currentPos + (_labelGlyphs[j].labelGlyphBounds.getWidth() + _labelPosition.defaultInterGlyphSpace) / curveLength;

      nextParallel = _curve.getCurveParallel(Curve.LABEL_CURVE, currentPosCandidate);

      currentPos = currentPosCandidate;

      Point2d nextVector = nextParallel.getEndPoint();
      double end2X = nextVector.getX();
      double end2Y = nextVector.getY();

      if (nextParallel != Curve.INVALID_POSITION && j + 1 < label.length) {
        // Extend the current parallel line in its direction
        // by the length of the next parallel. Use the approximate
        // deviation to work out the angle change
        double deltaX = math.abs(x - end2X);
        double deltaY = math.abs(y - end2Y);

        // The difference as a proportion of the length of the next
        // vector. 1 means a variation of 60 degrees.
        currentCurveDelta = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      }

      if (currentCurveDelta > curveDeltaSignificant) {
        // Work out which direction the curve is going in
        int ccw = awt.Line2D.relativeCCW(0.0, 0.0, x, y, end2X, end2Y);

        if (ccw == 1) {
          // Text is on inside of curve
          if (currentCurveDelta > curveDeltaMax) {
            // Don't worry about excessive deltas, if they
            // are big the label curve will be screwed anyway
            currentCurveDelta = curveDeltaMax;
          }

          double textBuffer = currentCurveDelta * CURVE_TEXT_STRETCH_FACTOR / curveLength;
          currentPos += textBuffer;
          endPos += textBuffer;
        }
      }

      if (_labelGlyphs[j].drawingBounds != null) {
        _labelGlyphs[j].drawingBounds.setRect(minX, minY, maxX - minX, maxY - minY);
      } else {
        _labelGlyphs[j].drawingBounds = new Rect(minX, minY, maxX - minX, maxY - minY);
      }

      if (overallLabelBounds == null) {
        overallLabelBounds = _labelGlyphs[j].drawingBounds.clone() as Rect;
      } else {
        overallLabelBounds.add(_labelGlyphs[j].drawingBounds);
      }

      _labelGlyphs[j].visible = true;
      centerVisibleIndex++;
    }

    centerVisibleIndex = (centerVisibleIndex / 2) as int;

    if (overallLabelBounds == null) {
      // Return a small rectangle in the center of the label curve
      // Null label bounds causes NPE when editing
      Line labelCenter = _curve.getCurveParallel(Curve.LABEL_CURVE, 0.5);
      overallLabelBounds = new Rect(labelCenter.getX(), labelCenter.getY(), 1.0, 1.0);
    }

    this._labelBounds = overallLabelBounds;
    return overallLabelBounds;
  }

  /**
	 * Hook for sub-classers to perform additional processing on
	 * each glyph
	 * @param curve The curve object holding the label curve
	 * @param label the text label of the curve
	 * @param j the index of the label
	 * @param currentPos the distance along the label curve the glyph is
	 */
  void _postprocessGlyph(Curve curve, String label, int j, double currentPos) {
  }

  /**
	 * Returns whether or not the rectangle passed in hits any part of this
	 * curve.
	 * @param rect the rectangle to detect for a hit
	 * @return whether or not the rectangle hits this curve
	 */
  bool intersectsRect(awt.Rectangle rect) {
    // To save CPU, we can test if the rectangle intersects the entire
    // bounds of this label
    if ((_labelBounds != null && (!_labelBounds.getRectangle().intersects(rect))) || _labelGlyphs == null) {
      return false;
    }

    for (int i = 0; i < _labelGlyphs.length; i++) {
      if (_labelGlyphs[i].visible && rect.intersects(_labelGlyphs[i].drawingBounds.getRectangle())) {
        return true;
      }
    }

    return false;
  }

  /**
	 * Hook method to override how the label is positioned on the curve
	 * @param style the style of the curve
	 * @param label the string label to be displayed on the curve
	 */
  void _calculationLabelPosition(Map<String, Object> style, String label) {
    double curveLength = _curve.getCurveLength(Curve.LABEL_CURVE);
    double availableLabelSpace = curveLength - _labelPosition.startBuffer - _labelPosition.endBuffer;
    _labelPosition.startBuffer = Math.max(_labelPosition.startBuffer, _labelPosition.startBuffer + availableLabelSpace / 2 - _labelSize / 2);
    _labelPosition.endBuffer = Math.max(_labelPosition.endBuffer, _labelPosition.endBuffer + availableLabelSpace / 2 - _labelSize / 2);
  }

  /**
	 * @return the curve
	 */
  Curve getCurve() {
    return _curve;
  }

  /**
	 * @param curve the curve to set
	 */
  void setCurve(Curve curve) {
    this._curve = curve;
  }

  Rect getLabelBounds() {
    return _labelBounds;
  }
  
  /**
   * Returns the drawing bounds of the central indexed visible glyph
   * @return the centerVisibleIndex
   */
  Rect getCenterVisiblePosition() {
    return _labelGlyphs[centerVisibleIndex].drawingBounds;
  }

}


/**
 * Utility class to describe the characteristics of each glyph of a branch
 * branch label. Each instance represents one glyph
 *
 */
class LabelGlyphCache {
  /**
   * Cache of the bounds of the individual element of the label of this 
   * edge. Note that these are the unrotated values used to determine the 
   * width of each glyph.
   */
  Rect labelGlyphBounds;

  /**
   * The un-rotated rectangle that just bounds this character
   */
  Rect drawingBounds;

  /**
   * The glyph being drawn
   */
  String glyph;

  /**
   * A line parallel to the curve segment at which the element is to be
   * drawn
   */
  Line glyphGeometry;

  /**
   * The cached shape of the glyph
   */
  Shape glyphShape;

  /**
   * Whether or not the glyph should be drawn
   */
  bool visible;
}

/**
 * Utility class that stores details of how the label is positioned
 * on the curve
 */
class LabelPosition {
  double startBuffer = CurveLabelShape.LABEL_BUFFER;

  double endBuffer = CurveLabelShape.LABEL_BUFFER;

  double defaultInterGlyphSpace = 0.0;
}