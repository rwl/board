/**
 * Copyright (c) 2010, David Benson
 */
part of graph.util;

//import java.util.List;

class Spline
{
	/** 
	 *	Array representing the relative proportion of the total distance
	 *	of each point in the line ( i.e. first point is 0.0, end point is
	 *	1.0, a point halfway on line is 0.5 ).
	 */
	private double[] _t;

	private Spline1D _splineX;

	private Spline1D _splineY;

	/**
	 * Total length tracing the points on the spline
	 */
	private double _length;

	Spline(List<Point2d> points)
	{
		if (points != null)
		{
			double[] x = new double[points.size()];
			double[] y = new double[points.size()];
			int i = 0;

			for (Point2d point : points)
			{
				x[i] = point.getX();
				y[i++] = point.getY();
			}

			_init(x, y);
		}
	}

	/**
	 * Creates a new Spline.
	 * @param x
	 * @param y
	 */
	void Spline2D(double[] x, double[] y)
	{
		_init(x, y);
	}

	void _init(double[] x, double[] y)
	{
		if (x.length != y.length)
		{
			// Arrays must have the same length
			// TODO log something
			return;
		}

		if (x.length < 2)
		{
			// Spline edges must have at least two points
			// TODO log something
			return;
		}

		_t = new double[x.length];
		_t[0] = 0.0; // start point is always 0.0
		_length = 0.0;

		// Calculate the partial proportions of each section between each set
		// of points and the total length of sum of all sections
		for (int i = 1; i < _t.length; i++)
		{
			double lx = x[i] - x[i - 1];
			double ly = y[i] - y[i - 1];

			// If either diff is zero there is no point performing the square root
			if (0.0 == lx)
			{
				_t[i] = Math.abs(ly);
			}
			else if (0.0 == ly)
			{
				_t[i] = Math.abs(lx);
			}
			else
			{
				_t[i] = Math.sqrt(lx * lx + ly * ly);
			}

			_length += _t[i];
			_t[i] += _t[i - 1];
		}

		for (int j = 1; j < (_t.length) - 1; j++)
		{
			_t[j] = _t[j] / _length;
		}

		_t[(_t.length) - 1] = 1.0; // end point is always 1.0

		_splineX = new Spline1D(_t, x);
		_splineY = new Spline1D(_t, y);
	}

	/**
	 * @param t 0 <= t <= 1
	 */
	Point2d getPoint(double t)
	{
		Point2d result = new Point2d(_splineX.getValue(t), _splineY.getValue(t));

		return result;
	}

	/**
	 * Used to check the correctness of this spline
	 */
	bool checkValues()
	{
		return (_splineX._len.length > 1 && _splineY._len.length > 1);
	}

	double getDx(double t)
	{
		return _splineX.getDx(t);
	}

	double getDy(double t)
	{
		return _splineY.getDx(t);
	}

	Spline1D getSplineX()
	{
		return _splineX;
	}

	Spline1D getSplineY()
	{
		return _splineY;
	}

	double getLength()
	{
		return _length;
	}
}
