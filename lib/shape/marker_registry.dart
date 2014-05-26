part of graph.shape;

//import java.awt.Polygon;
//import java.awt.Shape;
//import java.awt.geom.Ellipse2D;
//import java.awt.geom.Line2D;
//import java.util.Hashtable;
//import java.util.Map;

class MarkerRegistry
{
	/**
	 * 
	 */
	static Map<String, IMarker> _markers = new Hashtable<String, IMarker>();

	static init()
	{
		IMarker tmp = (Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, bool source)
			{
				Polygon poly = new Polygon();
				poly.addPoint(Math.round(pe.getX()) as int,
						Math.round(pe.getY()) as int);
				poly.addPoint(Math.round(pe.getX() - nx - ny / 2) as int,
						Math.round(pe.getY() - ny + nx / 2) as int);

				if (type.equals(Constants.ARROW_CLASSIC))
				{
					poly.addPoint(Math.round(pe.getX() - nx * 3 / 4) as int,
							Math.round(pe.getY() - ny * 3 / 4) as int);
				}

				poly.addPoint(Math.round(pe.getX() + ny / 2 - nx) as int,
						Math.round(pe.getY() - ny - nx / 2) as int);

				if (Utils.isTrue(state.getStyle(), (source) ? "startFill" : "endFill", true))
				{
					canvas.fillShape(poly);
				}
				
				canvas.getGraphics().draw(poly);

				return new Point2d(-nx, -ny);
			};

		registerMarker(Constants.ARROW_CLASSIC, tmp);
		registerMarker(Constants.ARROW_BLOCK, tmp);

		registerMarker(Constants.ARROW_OPEN, (Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, bool source)
			{
				canvas.getGraphics().draw(
						new Line2D.Float(Math.round(pe.getX() - nx - ny
								/ 2) as int,
								Math.round(pe.getY() - ny + nx / 2) as int,
								Math.round(pe.getX() - nx / 6) as int,
								Math.round(pe.getY() - ny / 6) as int));
				canvas.getGraphics().draw(
						new Line2D.Float(Math.round(pe.getX() - nx / 6) as int,
								Math.round(pe.getY() - ny / 6) as int,
								Math.round(pe.getX() + ny / 2 - nx) as int,
								Math.round(pe.getY() - ny - nx / 2) as int));

				return new Point2d(-nx / 2, -ny / 2);
			});
		
		registerMarker(Constants.ARROW_OVAL, (Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, bool source)
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
			});
		
		
		registerMarker(Constants.ARROW_DIAMOND, (Graphics2DCanvas canvas,
					CellState state, String type, Point2d pe, double nx,
					double ny, double size, bool source)
			{
				Polygon poly = new Polygon();
				poly.addPoint(Math.round(pe.getX()) as int,
						Math.round(pe.getY())) as int;
				poly.addPoint(Math.round(pe.getX() - nx / 2 - ny / 2) as int,
						Math.round(pe.getY() + nx / 2 - ny / 2) as int);
				poly.addPoint(Math.round(pe.getX() - nx) as int,
						Math.round(pe.getY() - ny) as int);
				poly.addPoint(Math.round(pe.getX() - nx / 2 + ny / 2) as int,
						Math.round(pe.getY() - ny / 2 - nx / 2) as int);

				if (Utils.isTrue(state.getStyle(), (source) ? "startFill" : "endFill", true))
				{
					canvas.fillShape(poly);
				}
				
				canvas.getGraphics().draw(poly);

				return new Point2d(-nx / 2, -ny / 2);
			});
	}

	/**
	 * 
	 */
	static IMarker getMarker(String name)
	{
		return _markers.get(name);
	}

	/**
	 * 
	 */
	static void registerMarker(String name, IMarker marker)
	{
		_markers.put(name, marker);
	}

}
