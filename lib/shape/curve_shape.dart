/**
 * Copyright (c) 2009-2010, David Benson, Gaudenz Alder
 */
part of graph.shape;

//import java.awt.RenderingHints;

class CurveShape extends ConnectorShape {
  /**
   * Cache of the points between which drawing straight lines views as a
   * curve
   */
  Curve _curve;

  //	CurveShape()
  //	{
  //		this(new Curve());
  //	}

  CurveShape([Curve curve = null]) {
    if (curve == null) {
      curve = new Curve();
    }
    this._curve = curve;
  }

  Curve getCurve() {
    return _curve;
  }

  void paintShape(Graphics2DCanvas canvas, CellState state) {
    //Object keyStrokeHint = canvas.getGraphics().getRenderingHint(RenderingHints.KEY_STROKE_CONTROL);
    //canvas.getGraphics().setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE);

    super.paintShape(canvas, state);

    //canvas.getGraphics().setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, keyStrokeHint);
  }

  void _paintPolyline(Graphics2DCanvas canvas, List<Point2d> points, Map<String, Object> style) {
    double scale = canvas.getScale();
    validateCurve(points, scale, style);

    canvas.paintPolyline(_curve.getCurvePoints(Curve.CORE_CURVE), false);
  }

  /**
   * Forces underlying curve to a valid state
   * @param points
   */
  void validateCurve(List<Point2d> points, double scale, Map<String, Object> style) {
    if (_curve == null) {
      _curve = new Curve(points);
    } else {
      _curve.updateCurve(points);
    }

    _curve.setLabelBuffer(scale * Constants.DEFAULT_LABEL_BUFFER);
  }

  /**
   * Hook to override creation of the vector that the marker is drawn along
   * since it may not be the same as the vector between any two control
   * points
   * @param points the guide points of the connector
   * @param source whether the marker is at the source end
   * @param markerSize the scaled maximum length of the marker
   * @return a line describing the vector the marker should be drawn along
   */
  Line _getMarkerVector(List<Point2d> points, bool source, double markerSize) {
    double curveLength = _curve.getCurveLength(Curve.CORE_CURVE);
    double markerRatio = markerSize / curveLength;
    if (markerRatio >= 1.0) {
      markerRatio = 1.0;
    }

    if (source) {
      Line sourceVector = _curve.getCurveParallel(Curve.CORE_CURVE, markerRatio);
      return new Line(sourceVector.getX(), sourceVector.getY(), points[0]);
    } else {
      Line targetVector = _curve.getCurveParallel(Curve.CORE_CURVE, 1.0 - markerRatio);
      int pointCount = points.length;
      return new Line(targetVector.getX(), targetVector.getY(), points[pointCount - 1]);
    }
  }
}
