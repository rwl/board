/**
 * Copyright (c) 2010, David Benson
 */
part of graph.util;

//import java.util.Arrays;

/**
 * One dimension of a spline curve
 */
public class Spline1D
{
	protected double[] _len;
	protected double[] _pos1D;

	protected double[] _a;
	protected double[] _b;
	protected double[] _c;
	protected double[] _d;

	/** tracks the last index found since that is mostly commonly the next one used */
	private int _storageIndex = 0;
	
	/**
	 * Creates a new Spline.
	 * @param controlPointProportions the proportion along the curve, from 0->1
	 * 			that each control point lies on
	 * @param positions1D the co-ordinate position in the current dimension that
	 * 			each control point lies on
	 */
	public Spline1D(double[] controlPointProportions, double[] positions1D)
	{
		setValues(controlPointProportions, positions1D);
	}

	/**
	 * Set values for this Spline.
	 * @param controlPointProportions the proportion along the curve, from 0->1
	 * 			that each control point lies on
	 * @param positions1D the co-ordinate position in the current dimension that
	 * 			each control point lies on
	 */
	public void setValues(double[] controlPointProportions, double[] positions1D)
	{
		this._len = controlPointProportions;
		this._pos1D = positions1D;
		
		if (_len.length > 1)
		{
			_calculateCoefficients();
		}
	}

	/**
	 * Returns an interpolated value.
	 * @param x
	 * @return the interpolated value
	 */
	public double getValue(double x)
	{
		if (_len.length == 0)
		{
			return Double.NaN;
		}

		if (_len.length == 1)
		{
			if (_len[0] == x)
			{
				return _pos1D[0];
			}
			else
			{
				return Double.NaN;
			}
		}

		int index = Arrays.binarySearch(_len, x);
		if (index > 0)
		{
			return _pos1D[index];
		}

		index = - (index + 1) - 1;
		//TODO linear interpolation or extrapolation
		if (index < 0) {
			return _pos1D[0];
		}

		return _a[index]
			+ _b[index] * (x - _len[index])
			+ _c[index] * Math.pow(x - _len[index], 2)
			+ _d[index] * Math.pow(x - _len[index], 3);
	}

	/**
	 * Returns an interpolated value. To be used when a long sequence of values
	 * are required in order, but ensure checkValues() is called beforehand to
	 * ensure the boundary checks from getValue() are made
	 * @param x
	 * @return the interpolated value
	 */
	public double getFastValue(double x)
	{
		// Fast check to see if previous index is still valid
		if (_storageIndex > -1 && _storageIndex < _len.length-1 && x > _len[_storageIndex] && x < _len[_storageIndex + 1])
		{

		}
		else
		{
			int index = Arrays.binarySearch(_len, x);
			if (index > 0)
			{
				return _pos1D[index];
			}
			index = - (index + 1) - 1;
			_storageIndex = index;
		}
	
		//TODO linear interpolation or extrapolation
		if (_storageIndex < 0)
		{
			return _pos1D[0];
		}
		double value = x - _len[_storageIndex];
		return _a[_storageIndex]
					+ _b[_storageIndex] * value
					+ _c[_storageIndex] * (value * value)
					+ _d[_storageIndex] * (value * value * value);
	}

	/**
	 * Returns the first derivation at x.
	 * @param x
	 * @return the first derivation at x
	 */
	public double getDx(double x)
	{
		if (_len.length == 0 || _len.length == 1)
		{
			return 0;
		}

		int index = Arrays.binarySearch(_len, x);
		if (index < 0)
		{
			index = - (index + 1) - 1;
		}

		return _b[index]
			+ 2 * _c[index] * (x - _len[index])
			+ 3 * _d[index] * Math.pow(x - _len[index], 2);
	}

	/**
	 * Calculates the Spline coefficients.
	 */
	private void _calculateCoefficients()
	{
		int N = _pos1D.length;
		_a = new double[N];
		_b = new double[N];
		_c = new double[N];
		_d = new double[N];
		
		if (N == 2) {
			_a[0] = _pos1D[0];
			_b[0] = _pos1D[1] - _pos1D[0];
			return;
		}

		double[] h = new double[N - 1];
		
		for (int i = 0; i < N - 1; i++)
		{
			_a[i] = _pos1D[i];
			h[i] = _len[i + 1] - _len[i];
			
			// h[i] is used for division later, avoid a NaN
			if (h[i] == 0.0)
			{
				h[i] = 0.01;
			}
		}
		_a[N - 1] = _pos1D[N - 1];

		double[][] A = new double[N - 2][N - 2];
		double[] y = new double[N - 2];
		for (int i = 0; i < N - 2; i++)
		{
			y[i] =
				3
					* ((_pos1D[i + 2] - _pos1D[i + 1]) / h[i
						+ 1]
						- (_pos1D[i + 1] - _pos1D[i]) / h[i]);

			A[i][i] = 2 * (h[i] + h[i + 1]);

			if (i > 0)
			{
				A[i][i - 1] = h[i];
			}

			if (i < N - 3)
			{
				A[i][i + 1] = h[i + 1];
			}
		}
		
		solve(A, y);

		for (int i = 0; i < N - 2; i++)
		{
			_c[i + 1] = y[i];
			_b[i] = (_a[i + 1] - _a[i]) / h[i] - (2 * _c[i] + _c[i + 1]) / 3 * h[i];
			_d[i] = (_c[i + 1] - _c[i]) / (3 * h[i]);
		}
		
		_b[N - 2] =
			(_a[N - 1] - _a[N - 2]) / h[N
				- 2]
				- (2 * _c[N - 2] + _c[N - 1]) / 3 * h[N
				- 2];
		
		_d[N - 2] = (_c[N - 1] - _c[N - 2]) / (3 * h[N - 2]);
	}

	/**
	 * Solves Ax=b and stores the solution in b.
	 */
	public void solve(double[][] A, double[] b) {
		int n = b.length;
		
		for (int i = 1; i < n; i++)
		{
			A[i][i - 1] = A[i][i - 1] / A[i - 1][i - 1];
			A[i][i] = A[i][i] - A[i - 1][i] * A[i][i - 1];
			b[i] = b[i] - A[i][i - 1] * b[i - 1];
		}

		b[n - 1] = b[n - 1] / A[n - 1][n - 1];
		
		for (int i = b.length - 2; i >= 0; i--)
		{
			b[i] = (b[i] - A[i][i + 1] * b[i + 1]) / A[i][i];
		}
	}
}