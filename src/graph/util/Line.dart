/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.util;

//import java.awt.geom.Line2D;

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
	protected Point2d _endPoint;

	/**
	 * Creates a new line
	 */
	public Line(Point2d startPt, Point2d endPt)
	{
		this.setX(startPt.getX());
		this.setY(startPt.getY());
		this._endPoint = endPt;
	}
	
	/**
	 * Creates a new line
	 */
	public Line(double startPtX, double startPtY, Point2d endPt)
	{
		_x = startPtX;
		_y = startPtY;
		this._endPoint = endPt;
	}

	/**
	 * Returns the end point of the line.
	 * 
	 * @return Returns the end point of the line.
	 */
	public Point2d getEndPoint()
	{
		return this._endPoint;
	}

	/**
	 * Sets the end point of the rectangle.
	 * 
	 * @param value The new end point of the line
	 */
	public void setEndPoint(Point2d value)
	{
		this._endPoint = value;
	}

	/**
	 * Sets the start and end points.
	 */
	public void setPoints(Point2d startPt, Point2d endPt)
	{
		this.setX(startPt.getX());
		this.setY(startPt.getY());
		this._endPoint = endPt;
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
		return new Line2D.Double(getX(), getY(), _endPoint.getX(), _endPoint
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
		return new Line2D.Double(getX(), getY(), _endPoint.getX(), _endPoint
				.getY()).ptSegDistSq(pt.getX(), pt.getY());
	}

}
