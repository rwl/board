/**
 * $Id: Point2d.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
package graph.util;

import java.awt.Point;
import java.awt.geom.Point2D;
import java.io.Serializable;

/**
 * Implements a 2-dimensional point with double precision coordinates.
 */
public class Point2d implements Serializable, Cloneable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 6554231393215892186L;

	/**
	 * Holds the x- and y-coordinates of the point. Default is 0.
	 */
	protected double _x, _y;

	/**
	 * Constructs a new point at (0, 0).
	 */
	public Point2d()
	{
		this(0, 0);
	}

	/**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
	public Point2d(Point2D point)
	{
		this(point.getX(), point.getY());
	}

	/**
	 * Constructs a new point at the location of the given point.
	 * 
	 * @param point Point that specifies the location.
	 */
	public Point2d(Point2d point)
	{
		this(point.getX(), point.getY());
	}

	/**
	 * Constructs a new point at (x, y).
	 * 
	 * @param x X-coordinate of the point to be created.
	 * @param y Y-coordinate of the point to be created.
	 */
	public Point2d(double x, double y)
	{
		setX(x);
		setY(y);
	}

	/**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
	public double getX()
	{
		return _x;
	}

	/**
	 * Sets the x-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
	public void setX(double value)
	{
		_x = value;
	}

	/**
	 * Returns the x-coordinate of the point.
	 * 
	 * @return Returns the x-coordinate.
	 */
	public double getY()
	{
		return _y;
	}

	/**
	 * Sets the y-coordinate of the point.
	 * 
	 * @param value Double that specifies the new x-coordinate.
	 */
	public void setY(double value)
	{
		_y = value;
	}

	/**
	 * Returns the coordinates as a new point.
	 * 
	 * @return Returns a new point for the location.
	 */
	public Point getPoint()
	{
		return new Point((int) Math.round(_x), (int) Math.round(_y));
	}

	/**
	 * 
	 * Returns true if the given object equals this rectangle.
	 */
	public boolean equals(Object obj)
	{
		if (obj instanceof Point2d)
		{
			Point2d pt = (Point2d) obj;

			return pt.getX() == getX() && pt.getY() == getY();
		}

		return false;
	}

	/**
	 * Returns a new instance of the same point.
	 */
	public Object clone()
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
	public String toString()
	{
		return getClass().getName() + "[" + _x + ", " + _y + "]";
	}
}
