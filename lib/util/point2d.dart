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
class Point2d implements Serializable, Cloneable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 6554231393215892186L;

	/**
	 * Holds the x- and y-coordinates of the point. Default is 0.
	 */
	double _x, _y;

	/**
	 * Constructs a new point at (0, 0).
	 */
	Point2d()
	{
		this(0, 0);
	}

	/**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
	Point2d(Point2D point)
	{
		this(point.getX(), point.getY());
	}

	/**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
	Point2d(Point2d point)
	{
		this(point.getX(), point.getY());
	}

	/**
	 * Constructs a new point at (x, y).
	 * 
	 * @param x X-coordinate of the point to be created.
	 * @param y Y-coordinate of the point to be created.
	 */
	Point2d(double x, double y)
	{
		setX(x);
		setY(y);
	}

	/**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
	double getX()
	{
		return _x;
	}

	/**
	 * Sets the x-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
	void setX(double value)
	{
		_x = value;
	}

	/**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
	double getY()
	{
		return _y;
	}

	/**
	 * Sets the y-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
	void setY(double value)
	{
		_y = value;
	}

	/**
	 * Returns the coordinates as a new point.
	 * 
	 * @return Returns a new point for the location.
	 */
	Point getPoint()
	{
		return new Point((int) Math.round(_x), (int) Math.round(_y));
	}

	/**
	 * 
	 * Returns true if the given object equals this rectangle.
	 */
	bool equals(Object obj)
	{
		if (obj is Point2d)
		{
			Point2d pt = (Point2d) obj;

			return pt.getX() == getX() && pt.getY() == getY();
		}

		return false;
	}

	/**
	 * Returns a new instance of the same point.
	 */
	Object clone()
	{
		Point2d clone;

		try
		{
			clone = (Point2d) super.clone();
		}
		catch (CloneNotSupportedException e)
		{
			clone = new Point2d();
		}

		clone.setX(getX());
		clone.setY(getY());

		return clone;
	}

	/**
	 * Returns a <code>String</code> that represents the value
	 * of this <code>Point2d</code>.
	 * @return a string representation of this <code>Point2d</code>.
	 */
	String toString()
	{
		return getClass().getName() + "[" + _x + ", " + _y + "]";
	}
}
