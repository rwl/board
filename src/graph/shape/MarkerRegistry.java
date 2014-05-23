package graph.shape;

import graph.canvas.Graphics2DCanvas;
import graph.util.Constants;
import graph.util.Point2d;
import graph.util.Utils;
import graph.view.CellState;

import java.awt.Polygon;
import java.awt.Shape;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.util.Hashtable;
import java.util.Map;

public class MarkerRegistry
{
	/**
	 * 
	 */
	protected static Map<String, IMarker> _markers = new Hashtable<String, IMarker>();

	static
	{
		IMarker tmp = new IMarker()
		{
			public Point2d paintMarker(Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, boolean source)
			{
				Polygon poly = new Polygon();
				poly.addPoint((int) Math.round(pe.getX()),
						(int) Math.round(pe.getY()));
				poly.addPoint((int) Math.round(pe.getX() - nx - ny / 2),
						(int) Math.round(pe.getY() - ny + nx / 2));

				if (type.equals(Constants.ARROW_CLASSIC))
				{
					poly.addPoint((int) Math.round(pe.getX() - nx * 3 / 4),
							(int) Math.round(pe.getY() - ny * 3 / 4));
				}

				poly.addPoint((int) Math.round(pe.getX() + ny / 2 - nx),
						(int) Math.round(pe.getY() - ny - nx / 2));

				if (Utils.isTrue(state.getStyle(), (source) ? "startFill" : "endFill", true))
				{
					canvas.fillShape(poly);
				}
				
				canvas.getGraphics().draw(poly);

				return new Point2d(-nx, -ny);
			}
		};

		registerMarker(Constants.ARROW_CLASSIC, tmp);
		registerMarker(Constants.ARROW_BLOCK, tmp);

		registerMarker(Constants.ARROW_OPEN, new IMarker()
		{
			public Point2d paintMarker(Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, boolean source)
			{
				canvas.getGraphics().draw(
						new Line2D.Float((int) Math.round(pe.getX() - nx - ny
								/ 2),
								(int) Math.round(pe.getY() - ny + nx / 2),
								(int) Math.round(pe.getX() - nx / 6),
								(int) Math.round(pe.getY() - ny / 6)));
				canvas.getGraphics().draw(
						new Line2D.Float((int) Math.round(pe.getX() - nx / 6),
								(int) Math.round(pe.getY() - ny / 6),
								(int) Math.round(pe.getX() + ny / 2 - nx),
								(int) Math.round(pe.getY() - ny - nx / 2)));

				return new Point2d(-nx / 2, -ny / 2);
			}
		});
		
		registerMarker(Constants.ARROW_OVAL, new IMarker()
		{
			public Point2d paintMarker(Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, boolean source)
			{
				double cx = pe.getX() - nx / 2;
				double cy = pe.getY() - ny / 2;
				double a = size / 2;
				Shape shape = new Ellipse2D.Double(cx - a, cy - a, size, size);

				if (Utils.isTrue(state.getStyle(), (source) ? "startFill" : "endFill", true))
				{
					canvas.fillShape(shape);
				}
				
				canvas.getGraphics().draw(shape);

				return new Point2d(-nx / 2, -ny / 2);
			}
		});
		
		
		registerMarker(Constants.ARROW_DIAMOND, new IMarker()
		{
			public Point2d paintMarker(Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, boolean source)
			{
				Polygon poly = new Polygon();
				poly.addPoint((int) Math.round(pe.getX()),
						(int) Math.round(pe.getY()));
				poly.addPoint((int) Math.round(pe.getX() - nx / 2 - ny / 2),
						(int) Math.round(pe.getY() + nx / 2 - ny / 2));
				poly.addPoint((int) Math.round(pe.getX() - nx),
						(int) Math.round(pe.getY() - ny));
				poly.addPoint((int) Math.round(pe.getX() - nx / 2 + ny / 2),
						(int) Math.round(pe.getY() - ny / 2 - nx / 2));

				if (Utils.isTrue(state.getStyle(), (source) ? "startFill" : "endFill", true))
				{
					canvas.fillShape(poly);
				}
				
				canvas.getGraphics().draw(poly);

				return new Point2d(-nx / 2, -ny / 2);
			}
		});
	}

	/**
	 * 
	 */
	public static IMarker getMarker(String name)
	{
		return _markers.get(name);
	}

	/**
	 * 
	 */
	public static void registerMarker(String name, IMarker marker)
	{
		_markers.put(name, marker);
	}

}
