/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.util;

//import java.awt.harmony.Rectangle;
//import java.awt.geom.Rectangle2D;

/**
 * Implements a 2-dimensional rectangle with double precision coordinates.
 */
class Rect extends Point2d {

  /**
	 * 
	 */
  //	private static final long serialVersionUID = -3793966043543578946L;

  /**
	 * Holds the width and the height. Default is 0.
	 */
  double _width, _height;

  /**
	 * Constructs a new rectangle at (0, 0) with the width and height set to 0.
	 */
  //	Rect()
  //	{
  //		this(0, 0, 0, 0);
  //	}

  /**
	 * Constructs a copy of the given rectangle.
	 * 
	 * @param rect harmony.Rectangle to construct a copy of.
	 */
  /*Rect(Rectangle2D rect)
	{
		this(rect.getX(), rect.getY(), rect.getWidth(), rect.getHeight());
	}*/

  /**
	 * Constructs a copy of the given rectangle.
	 * 
	 * @param rect harmony.Rectangle to construct a copy of.
	 */
  factory Rect.from(Rect rect) {
    new Rect(rect.getX(), rect.getY(), rect.getWidth(), rect.getHeight());
  }

  /**
	 * Constructs a rectangle using the given parameters.
	 * 
	 * @param x X-coordinate of the new rectangle.
	 * @param y Y-coordinate of the new rectangle.
	 * @param width Width of the new rectangle.
	 * @param height Height of the new rectangle.
	 */
  Rect([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0]) : super(x, y) {
    setWidth(width);
    setHeight(height);
  }

  /**
	 * Returns the width of the rectangle.
	 * 
	 * @return Returns the width.
	 */
  double getWidth() {
    return _width;
  }

  double get width => _width;

  /**
	 * Sets the width of the rectangle.
	 * 
	 * @param value Double that specifies the new width.
	 */
  void setWidth(double value) {
    _width = value;
  }

  void set width (double w) {
    _width = w;
  }

  /**
	 * Returns the height of the rectangle.
	 * 
	 * @return Returns the height.
	 */
  double getHeight() {
    return _height;
  }

  double get height => _height;

  /**
	 * Sets the height of the rectangle.
	 * 
	 * @param value Double that specifies the new height.
	 */
  void setHeight(double value) {
    _height = value;
  }

  void set height (double h) {
    _height = h;
  }

  /**
	 * Sets this rectangle to the specified values
	 * 
	 * @param x the new x-axis position
	 * @param y the new y-axis position
	 * @param w the new width of the rectangle
	 * @param h the new height of the rectangle
	 */
  void setRect(double x, double y, double w, double h) {
    this._x = x;
    this._y = y;
    this._width = w;
    this._height = h;
  }

  /**
	 * Adds the given rectangle to this rectangle.
	 */
  void add(Rect rect) {
    if (rect != null) {
      double minX = Math.min(_x, rect._x);
      double minY = Math.min(_y, rect._y);
      double maxX = Math.max(_x + _width, rect._x + rect._width);
      double maxY = Math.max(_y + _height, rect._y + rect._height);

      _x = minX;
      _y = minY;
      _width = maxX - minX;
      _height = maxY - minY;
    }
  }

  /**
	 * Returns the x-coordinate of the center.
	 * 
	 * @return Returns the x-coordinate of the center.
	 */
  double getCenterX() {
    return getX() + getWidth() / 2;
  }

  /**
	 * Returns the y-coordinate of the center.
	 * 
	 * @return Returns the y-coordinate of the center.
	 */
  double getCenterY() {
    return getY() + getHeight() / 2;
  }

  /**
	 * Grows the rectangle by the given amount, that is, this method subtracts
	 * the given amount from the x- and y-coordinates and adds twice the amount
	 * to the width and height.
	 *
	 * @param amount Amount by which the rectangle should be grown.
	 */
  void grow(double amount) {
    _x -= amount;
    _y -= amount;
    _width += 2 * amount;
    _height += 2 * amount;
  }

  /**
	 * Returns true if the given point is contained in the rectangle.
	 * 
	 * @param x X-coordinate of the point.
	 * @param y Y-coordinate of the point.
	 * @return Returns true if the point is contained in the rectangle.
	 */
  bool contains(double x, double y) {
    return (this._x <= x && this._x + _width >= x && this._y <= y && this._y + _height >= y);
  }

  /**
	 * Returns the point at which the specified point intersects the perimeter 
	 * of this rectangle or null if there is no intersection.
	 * 
	 * @param x0 the x co-ordinate of the first point of the line
	 * @param y0 the y co-ordinate of the first point of the line
	 * @param x1 the x co-ordinate of the second point of the line
	 * @param y1 the y co-ordinate of the second point of the line
	 * @return the point at which the line intersects this rectangle, or null
	 * 			if there is no intersection
	 */
  Point2d intersectLine(double x0, double y0, double x1, double y1) {
    Point2d result = null;

    result = Utils.intersection(_x, _y, _x + _width, _y, x0, y0, x1, y1);

    if (result == null) {
      result = Utils.intersection(_x + _width, _y, _x + _width, _y + _height, x0, y0, x1, y1);
    }

    if (result == null) {
      result = Utils.intersection(_x + _width, _y + _height, _x, _y + _height, x0, y0, x1, y1);
    }

    if (result == null) {
      result = Utils.intersection(_x, _y, _x, _y + _height, x0, y0, x1, y1);
    }

    return result;
  }

  /**
	 * Returns the bounds as a new rectangle.
	 * 
	 * @return Returns a new rectangle for the bounds.
	 */
  svg.Rect getRectangle() {
    int ix = math.round(_x) as int;
    int iy = math.round(_y) as int;
    int iw = math.round(_width - ix + _x) as int;
    int ih = math.round(_height - iy + _y) as int;

    return new svg.Rect()
      ..x = ix
      ..y = iy
      ..width = iw
      ..height = ih;
  }

  /**
	 * 
	 * Returns true if the given object equals this rectangle.
	 */
  bool equals(Object obj) {
    if (obj is Rect) {
      Rect rect = obj;

      return rect.getX() == getX() && rect.getY() == getY() && rect.getWidth() == getWidth() && rect.getHeight() == getHeight();
    }

    return false;
  }

  /**
	 * Returns a new instance of the same rectangle.
	 */
  Object clone() {
    Rect clone = super.clone() as Rect;

    clone.setWidth(getWidth());
    clone.setHeight(getHeight());

    return clone;
  }

  /**
	 * Returns the <code>String</code> representation of this
	 * <code>Rect</code>.
	 * @return a <code>String</code> representing this
	 * <code>Rect</code>.
	 */
  String toString() {
    return /*getClass().getName() + */"Rect[x=$_x,y=$_y,w=$_width,h=$_height]";
  }
}
