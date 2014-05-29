/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.model;

//import java.util.ArrayList;
//import java.util.List;

/**
 * Represents the geometry of a cell. For vertices, the geometry consists
 * of the x- and y-location, as well as the width and height. For edges,
 * the geometry either defines the source- and target-terminal, or it
 * defines the respective terminal points.
 * 
 * For edges, if the geometry is relative (default), then the x-coordinate
 * is used to describe the distance from the center of the edge from -1 to 1
 * with 0 being the center of the edge and the default value, and the
 * y-coordinate is used to describe the absolute, orthogonal distance in
 * pixels from that point. In addition, the offset is used as an absolute
 * offset vector from the resulting point. 
 */
class Geometry extends Rect {

  /**
	 * 
	 */
  //	private static final long serialVersionUID = 2649828026610336589L;

  /**
	 * Global switch to translate the points in translate. Default is true.
	 */
  static /*transient*/ bool TRANSLATE_CONTROL_POINTS = true;

  /**
	 * Stores alternate values for x, y, width and height in a rectangle.
	 * Default is null.
	 */
  Rect _alternateBounds;

  /**
	 * Defines the source- and target-point of the edge. This is used if the
	 * corresponding edge does not have a source vertex. Otherwise it is
	 * ignored. Default is null.
	 */
  Point2d _sourcePoint, _targetPoint;

  /**
	 * List of mxPoints which specifies the control points along the edge.
	 * These points are the intermediate points on the edge, for the endpoints
	 * use targetPoint and sourcePoint or set the terminals of the edge to
	 * a non-null value. Default is null.
	 */
  List<Point2d> _points;

  /**
	 * Holds the offset of the label for edges. This is the absolute vector
	 * between the center of the edge and the top, left point of the label.
	 * Default is null.
	 */
  Point2d _offset;

  /**
	 * Specifies if the coordinates in the geometry are to be interpreted as
	 * relative coordinates. Default is false. This is used to mark a geometry
	 * with an x- and y-coordinate that is used to describe an edge label
	 * position, or a relative location with respect to a parent cell's
	 * width and height.
	 */
  bool _relative = false;

  /**
	 * Constructs a new geometry at (0, 0) with the width and height set to 0.
	 */
  //	Geometry()
  //	{
  //		this(0, 0, 0, 0);
  //	}

  /**
	 * Constructs a geometry using the given parameters.
	 * 
	 * @param x X-coordinate of the new geometry.
	 * @param y Y-coordinate of the new geometry.
	 * @param width Width of the new geometry.
	 * @param height Height of the new geometry.
	 */
  Geometry([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0]) : super(x, y, width, height);

  /**
	 * Returns the alternate bounds.
	 */
  Rect getAlternateBounds() {
    return _alternateBounds;
  }

  /**
	 * Sets the alternate bounds to the given rectangle.
	 * 
	 * @param rect Rectangle to be used for the alternate bounds.
	 */
  void setAlternateBounds(Rect rect) {
    _alternateBounds = rect;
  }

  /**
	 * Returns the source point.
	 * 
	 * @return Returns the source point.
	 */
  Point2d getSourcePoint() {
    return _sourcePoint;
  }

  /**
	 * Sets the source point.
	 * 
	 * @param sourcePoint Source point to be used.
	 */
  void setSourcePoint(Point2d sourcePoint) {
    this._sourcePoint = sourcePoint;
  }

  /**
	 * Returns the target point.
	 * 
	 * @return Returns the target point.
	 */
  Point2d getTargetPoint() {
    return _targetPoint;
  }

  /**
	 * Sets the target point.
	 * 
	 * @param targetPoint Target point to be used.
	 */
  void setTargetPoint(Point2d targetPoint) {
    this._targetPoint = targetPoint;
  }

  /**
	 * Returns the list of control points.
	 */
  List<Point2d> getPoints() {
    return _points;
  }

  /**
	 * Sets the list of control points to the given list.
	 * 
	 * @param value List that contains the new control points.
	 */
  void setPoints(List<Point2d> value) {
    _points = value;
  }

  /**
	 * Returns the offset.
	 */
  Point2d getOffset() {
    return _offset;
  }

  /**
	 * Sets the offset to the given point.
	 * 
	 * @param offset Point to be used for the offset.
	 */
  void setOffset(Point2d offset) {
    this._offset = offset;
  }

  /**
	 * Returns true of the geometry is relative.
	 */
  bool isRelative() {
    return _relative;
  }

  /**
	 * Sets the relative state of the geometry.
	 * 
	 * @param value bool value to be used as the new relative state.
	 */
  void setRelative(bool value) {
    _relative = value;
  }

  /**
	 * Swaps the x, y, width and height with the values stored in
	 * alternateBounds and puts the previous values into alternateBounds as
	 * a rectangle. This operation is carried-out in-place, that is, using the
	 * existing geometry instance. If this operation is called during a graph
	 * model transactional change, then the geometry should be cloned before
	 * calling this method and setting the geometry of the cell using
	 * GraphModel.setGeometry.
	 */
  void swap() {
    if (_alternateBounds != null) {
      Rect old = new Rect(getX(), getY(), getWidth(), getHeight());

      x = _alternateBounds.getX();
      y = _alternateBounds.getY();
      width = _alternateBounds.getWidth();
      height = _alternateBounds.getHeight();

      _alternateBounds = old;
    }
  }

  /**
	 * Returns the point representing the source or target point of this edge.
	 * This is only used if the edge has no source or target vertex.
	 * 
	 * @param isSource bool that specifies if the source or target point
	 * should be returned.
	 * @return Returns the source or target point.
	 */
  Point2d getTerminalPoint(bool isSource) {
    return (isSource) ? _sourcePoint : _targetPoint;
  }

  /**
	 * Sets the sourcePoint or targetPoint to the given point and returns the
	 * new point.
	 * 
	 * @param point Point to be used as the new source or target point.
	 * @param isSource bool that specifies if the source or target point
	 * should be set.
	 * @return Returns the new point.
	 */
  Point2d setTerminalPoint(Point2d point, bool isSource) {
    if (isSource) {
      _sourcePoint = point;
    } else {
      _targetPoint = point;
    }

    return point;
  }

  /**
	 * Translates the geometry by the specified amount. That is, x and y of the
	 * geometry, the sourcePoint, targetPoint and all elements of points are
	 * translated by the given amount. X and y are only translated if the
	 * geometry is not relative. If TRANSLATE_CONTROL_POINTS is false, then
	 * are not modified by this function.
	 * 
	 * @param dx int that specifies the x-coordinate of the translation.
	 * @param dy int that specifies the y-coordinate of the translation.
	 */
  void translate(double dx, double dy) {
    // Translates the geometry
    if (!isRelative()) {
      x += dx;
      y += dy;
    }

    // Translates the source point
    if (_sourcePoint != null) {
      _sourcePoint.setX(_sourcePoint.getX() + dx);
      _sourcePoint.setY(_sourcePoint.getY() + dy);
    }

    // Translates the target point
    if (_targetPoint != null) {
      _targetPoint.setX(_targetPoint.getX() + dx);
      _targetPoint.setY(_targetPoint.getY() + dy);
    }

    // Translate the control points
    if (TRANSLATE_CONTROL_POINTS && _points != null) {
      int count = _points.length;

      for (int i = 0; i < count; i++) {
        Point2d pt = _points[i];

        pt.setX(pt.getX() + dx);
        pt.setY(pt.getY() + dy);
      }
    }
  }

  /**
	 * Returns a clone of the cell.
	 */
  Object clone() {
    Geometry clone = super.clone() as Geometry;

    clone.setX(getX());
    clone.setY(getY());
    clone.setWidth(getWidth());
    clone.setHeight(getHeight());
    clone.setRelative(isRelative());

    List<Point2d> pts = getPoints();

    if (pts != null) {
      clone._points = new List<Point2d>(pts.length);

      for (int i = 0; i < pts.length; i++) {
        clone._points.add(pts[i].clone() as Point2d);
      }
    }

    Point2d tp = getTargetPoint();

    if (tp != null) {
      clone.setTargetPoint(tp.clone() as Point2d);
    }

    Point2d sp = getSourcePoint();

    if (sp != null) {
      setSourcePoint(sp.clone() as Point2d);
    }

    Point2d off = getOffset();

    if (off != null) {
      clone.setOffset(off.clone() as Point2d);
    }

    Rect alt = getAlternateBounds();

    if (alt != null) {
      setAlternateBounds(alt.clone() as Rect);
    }

    return clone;
  }

}
