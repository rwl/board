part of graph.shape;

//import java.awt.Shape;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Map;

class _svgShape
{
	public Shape shape;

	/**
	 * Contains an array of key, value pairs that represent the style of the
	 * cell.
	 */
	protected Map<String, Object> style;

	public List<_svgShape> subShapes;

	/**
	 * Holds the current value to which the shape is scaled in X
	 */
	protected double currentXScale;

	/**
	 * Holds the current value to which the shape is scaled in Y
	 */
	protected double currentYScale;

	public _svgShape(Shape shape, Map<String, Object> style)
	{
		this.shape = shape;
		this.style = style;
		subShapes = new ArrayList<_svgShape>();
	}

	public double getCurrentXScale()
	{
		return currentXScale;
	}

	public void setCurrentXScale(double currentXScale)
	{
		this.currentXScale = currentXScale;
	}

	public double getCurrentYScale()
	{
		return currentYScale;
	}

	public void setCurrentYScale(double currentYScale)
	{
		this.currentYScale = currentYScale;
	}
}