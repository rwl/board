/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.util;

//import java.awt.Point;
//import java.awt.geom.Point2D;
//import java.io.Serializable;

/**
 * Implements a 2-dimensional point with double precision coordinates.
 */
class Point2d // implements Serializable, Cloneable
{

  /**
	 * 
	 */
  //	private static final long serialVersionUID = 6554231393215892186L;

  /**
	 * Holds the x- and y-coordinates of the point. Default is 0.
	 */
  double _x, _y;

  /**
	 * Constructs a new point at (0, 0).
	 */
  //	Point2d()
  //	{
  //		this(0, 0);
  //	}

  /**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
  /*Point2d(Point2D point)
	{
		this(point.getX(), point.getY());
	}*/

  /**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
  factory Point2d.from(Point2d point) {
    return new Point2d(point.getX(), point.getY());
  }

  /**
	 * Constructs a new point at (x, y).
	 * 
	 * @param x X-coordinate of the point to be created.
	 * @param y Y-coordinate of the point to be created.
	 */
  Point2d([double x = 0.0, double y = 0.0]) {
    setX(x);
    setY(y);
  }

  /**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
  double getX() {
    return _x;
  }

  double get x => _x;

  /**
	 * Sets the x-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
  void setX(double value) {
    _x = value;
  }

  void set x (double xx) {
    _x = xx;
  }

  /**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
  double getY() {
    return _y;
  }

  double get y => _y;

  /**
	 * Sets the y-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
  void setY(double value) {
    _y = value;
  }

  void set y (double y) {
    _y = y;
  }

  /**
	 * Returns the coordinates as a new point.
	 * 
	 * @return Returns a new point for the location.
	 */
  awt.Point getPoint() {
    return new awt.Point(_x.round() as int, _y.round() as int);
  }

  /**
	 * 
	 * Returns true if the given object equals this rectangle.
	 */
  bool equals(Object obj) {
    if (obj is Point2d) {
      Point2d pt = obj;// as Point2d;

      return pt.getX() == getX() && pt.getY() == getY();
    }

    return false;
  }

  /**
	 * Returns a new instance of the same point.
	 */
  Object clone() {
    Point2d clone;

//    try {
//      clone = super.clone() as Point2d;
//    } on CloneNotSupportedException catch (e) {
      clone = new Point2d();
//    }

    clone.setX(getX());
    clone.setY(getY());

    return clone;
  }

  /**
	 * Returns a <code>String</code> that represents the value
	 * of this <code>Point2d</code>.
	 * @return a string representation of this <code>Point2d</code>.
	 */
  String toString() {
    return /*getClass().getName() + */"Point2d[$_x, $_y]";
  }
}
