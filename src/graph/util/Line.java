/**
 * $Id: Line.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
package graph.util;

import java.awt.geom.Line2D;

/**
 * Implements a line with double precision coordinates.
 */

public class Line extends Point2d
{
	/**
	 * 
	 */
	private static final long serialVersionUID = -4730972599169158546L;
	/**
	 * The end point of the line
	 */
	protected Point2d endPoint;

	/**
	 * Creates a new line
	 */
	public Line(Point2d startPt, Point2d endPt)
	{
		this.setX(startPt.getX());
		this.setY(startPt.getY());
		this.endPoint = endPt;
	}
	
	/**
	 * Creates a new line
	 */
	public Line(double startPtX, double startPtY, Point2d endPt)
	{
		x = startPtX;
		y = startPtY;
		this.endPoint = endPt;
	}

	/**
	 * Returns the end point of the line.
	 * 
	 * @return Returns the end point of the line.
	 */
	public Point2d getEndPoint()
	{
		return this.endPoint;
	}

	/**
	 * Sets the end point of the rectangle.
	 * 
	 * @param value The new end point of the line
	 */
	public void setEndPoint(Point2d value)
	{
		this.endPoint = value;
	}

	/**
	 * Sets the start and end points.
	 */
	public void setPoints(Point2d startPt, Point2d endPt)
	{
		this.setX(startPt.getX());
		this.setY(startPt.getY());
		this.endPoint = endPt;
	}
	
	/**
	 * Returns the square of the shortest distance from a point to this line.
	 * The line is considered extrapolated infinitely in both directions for 
	 * the purposes of the calculation.
	 *
	 * @param pt the point whose distance is being measured
	 * @return the square of the distance from the specified point to this line.
	 */
	public double ptLineDistSq(Point2d pt)
	{
		return new Line2D.Double(getX(), getY(), endPoint.getX(), endPoint
				.getY()).ptLineDistSq(pt.getX(), pt.getY());
	}

	/**
	 * Returns the square of the shortest distance from a point to this 
	 * line segment.
	 *
	 * @param pt the point whose distance is being measured
	 * @return the square of the distance from the specified point to this segment.
	 */
	public double ptSegDistSq(Point2d pt)
	{
		return new Line2D.Double(getX(), getY(), endPoint.getX(), endPoint
				.getY()).ptSegDistSq(pt.getX(), pt.getY());
	}

}
