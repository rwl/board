/**
 * Copyright (c) 2009-2010, David Benson, Gaudenz Alder
 */
part of graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.util.Constants;
//import graph.util.Curve;
//import graph.util.Line;
//import graph.util.Point2d;
//import graph.view.CellState;

//import java.awt.RenderingHints;
//import java.util.List;
//import java.util.Map;

public class CurveShape extends ConnectorShape
{
	/**
	 * Cache of the points between which drawing straight lines views as a
	 * curve
	 */
	protected Curve _curve;

	/**
	 * 
	 */
	public CurveShape()
	{
		this(new Curve());
	}
	
	/**
	 * 
	 */
	public CurveShape(Curve curve)
	{
		this._curve = curve;
	}

	/**
	 * 
	 */
	public Curve getCurve()
	{
		return _curve;
	}

	/**
	 * 
	 */
	public void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		Object keyStrokeHint = canvas.getGraphics().getRenderingHint(
				RenderingHints.KEY_STROKE_CONTROL);
		canvas.getGraphics().setRenderingHint(
				RenderingHints.KEY_STROKE_CONTROL,
				RenderingHints.VALUE_STROKE_PURE);

		super.paintShape(canvas, state);

		canvas.getGraphics().setRenderingHint(
				RenderingHints.KEY_STROKE_CONTROL, keyStrokeHint);
	}

	/**
	 * 
	 */
	protected void _paintPolyline(Graphics2DCanvas canvas,
			List<Point2d> points, Map<String, Object> style)
	{
		double scale = canvas.getScale();
		validateCurve(points, scale, style);

		canvas.paintPolyline(_curve.getCurvePoints(Curve.CORE_CURVE), false);
	}

	/**
	 * Forces underlying curve to a valid state
	 * @param points
	 */
	public void validateCurve(List<Point2d> points, double scale,
			Map<String, Object> style)
	{
		if (_curve == null)
		{
			_curve = new Curve(points);
		}
		else
		{
			_curve.updateCurve(points);
		}

		_curve.setLabelBuffer(scale * Constants.DEFAULT_LABEL_BUFFER);
	}

	/**
	 * Hook to override creation of the vector that the marker is drawn along
	 * since it may not be the same as the vector between any two control
	 * points
	 * @param points the guide points of the connector
	 * @param source whether the marker is at the source end
	 * @param markerSize the scaled maximum length of the marker
	 * @return a line describing the vector the marker should be drawn along
	 */
	protected Line _getMarkerVector(List<Point2d> points, boolean source,
			double markerSize)
	{
		double curveLength = _curve.getCurveLength(Curve.CORE_CURVE);
		double markerRatio = markerSize / curveLength;
		if (markerRatio >= 1.0)
		{
			markerRatio = 1.0;
		}

		if (source)
		{
			Line sourceVector = _curve.getCurveParallel(Curve.CORE_CURVE,
					markerRatio);
			return new Line(sourceVector.getX(), sourceVector.getY(),
					points.get(0));
		}
		else
		{
			Line targetVector = _curve.getCurveParallel(Curve.CORE_CURVE,
					1.0 - markerRatio);
			int pointCount = points.size();
			return new Line(targetVector.getX(), targetVector.getY(),
					points.get(pointCount - 1));
		}
	}
}