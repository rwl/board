/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;

/**
 * Defines an object that contains the constraints about how to connect one
 * side of an edge to its terminal.
 */
class ConnectionConstraint
{
	/**
	 * Point that specifies the fixed location of the connection point.
	 */
	Point2d _point;

	/**
	 * Boolean that specifies if the point should be projected onto the perimeter
	 * of the terminal.
	 */
	bool _perimeter;

	/**
	 * Constructs an empty connection constraint.
	 */
	ConnectionConstraint()
	{
		this(null);
	}

	/**
	 * Constructs a connection constraint for the given point.
	 */
	ConnectionConstraint(Point2d point)
	{
		this(point, true);
	}

	/**
	 * Constructs a new connection constraint for the given point and boolean
	 * arguments.
	 * 
	 * @param point Optional Point2d that specifies the fixed location of the point
	 * in relative coordinates. Default is null.
	 * @param perimeter Optional bool that specifies if the fixed point should be
	 * projected onto the perimeter of the terminal. Default is true.
	 */
	ConnectionConstraint(Point2d point, bool perimeter)
	{
		setPoint(point);
		setPerimeter(perimeter);
	}

	/**
	 * Returns the point.
	 */
	Point2d getPoint()
	{
		return _point;
	}

	/**
	 * Sets the point.
	 */
	void setPoint(Point2d value)
	{
		_point = value;
	}

	/**
	 * Returns perimeter.
	 */
	bool isPerimeter()
	{
		return _perimeter;
	}

	/**
	 * Sets perimeter.
	 */
	void setPerimeter(bool value)
	{
		_perimeter = value;
	}

}
