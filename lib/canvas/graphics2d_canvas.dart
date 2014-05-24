/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.canvas;

import '../shape/shape.dart' show ActorShape;
import '../shape/shape.dart' show ArrowShape;
import '../shape/shape.dart' show CloudShape;
import '../shape/shape.dart' show ConnectorShape;
import '../shape/shape.dart' show CurveShape;
import '../shape/shape.dart' show CylinderShape;
import '../shape/shape.dart' show DefaultTextShape;
import '../shape/shape.dart' show DoubleEllipseShape;
import '../shape/shape.dart' show DoubleRectangleShape;
import '../shape/shape.dart' show EllipseShape;
import '../shape/shape.dart' show HexagonShape;
import '../shape/shape.dart' show HtmlTextShape;
import '../shape/shape.dart' show IShape;
import '../shape/shape.dart' show ITextShape;
import '../shape/shape.dart' show ImageShape;
import '../shape/shape.dart' show LabelShape;
import '../shape/shape.dart' show LineShape;
import '../shape/shape.dart' show RectangleShape;
import '../shape/shape.dart' show RhombusShape;
import '../shape/shape.dart' show StencilRegistry;
import '../shape/shape.dart' show SwimlaneShape;
import '../shape/shape.dart' show TriangleShape;
import '../swing/util/util.dart' show SwingConstants;
import '../util/util.dart' show Constants;
import '../util/util.dart' show Point2d;
import '../util/util.dart' show Rect;
import '../util/util.dart' show Utils;
import '../view/view.dart' show CellState;

//import java.awt.AlphaComposite;
//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Dimension;
//import java.awt.GradientPaint;
//import java.awt.Graphics2D;
//import java.awt.Image;
//import java.awt.Paint;
//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.Stroke;
//import java.awt.geom.AffineTransform;
//import java.awt.geom.GeneralPath;
//import java.util.HashMap;
//import java.util.Map;

//import javax.swing.CellRendererPane;

/**
 * An implementation of a canvas that uses Graphics2D for painting.
 */
class Graphics2DCanvas extends BasicCanvas
{
	/**
	 * 
	 */
	static final String TEXT_SHAPE_DEFAULT = "default";

	/**
	 * 
	 */
	static final String TEXT_SHAPE_HTML = "html";

	/**
	 * Specifies the image scaling quality. Default is Image.SCALE_SMOOTH.
	 */
	static int IMAGE_SCALING = Image.SCALE_SMOOTH;

	/**
	 * Maps from names to mxIVertexShape instances.
	 */
	static Map<String, IShape> _shapes = new HashMap<String, IShape>();

	/**
	 * Maps from names to ITextShape instances. There are currently three different
	 * hardcoded text shapes available here: default, html and wrapped.
	 */
	static Map<String, ITextShape> _textShapes = new HashMap<String, ITextShape>();

	/**
	 * Static initializer.
	 */
	static
	{
		putShape(Constants.SHAPE_ACTOR, new ActorShape());
		putShape(Constants.SHAPE_ARROW, new ArrowShape());
		putShape(Constants.SHAPE_CLOUD, new CloudShape());
		putShape(Constants.SHAPE_CONNECTOR, new ConnectorShape());
		putShape(Constants.SHAPE_CYLINDER, new CylinderShape());
		putShape(Constants.SHAPE_CURVE, new CurveShape());
		putShape(Constants.SHAPE_DOUBLE_RECTANGLE, new DoubleRectangleShape());
		putShape(Constants.SHAPE_DOUBLE_ELLIPSE, new DoubleEllipseShape());
		putShape(Constants.SHAPE_ELLIPSE, new EllipseShape());
		putShape(Constants.SHAPE_HEXAGON, new HexagonShape());
		putShape(Constants.SHAPE_IMAGE, new ImageShape());
		putShape(Constants.SHAPE_LABEL, new LabelShape());
		putShape(Constants.SHAPE_LINE, new LineShape());
		putShape(Constants.SHAPE_RECTANGLE, new RectangleShape());
		putShape(Constants.SHAPE_RHOMBUS, new RhombusShape());
		putShape(Constants.SHAPE_SWIMLANE, new SwimlaneShape());
		putShape(Constants.SHAPE_TRIANGLE, new TriangleShape());
		putTextShape(TEXT_SHAPE_DEFAULT, new DefaultTextShape());
		putTextShape(TEXT_SHAPE_HTML, new HtmlTextShape());
	}

	/**
	 * Optional renderer pane to be used for HTML label rendering.
	 */
	CellRendererPane _rendererPane;

	/**
	 * Global graphics handle to the image.
	 */
	Graphics2D _g;

	/**
	 * Constructs a new graphics canvas with an empty graphics object.
	 */
	Graphics2DCanvas()
	{
		this(null);
	}

	/**
	 * Constructs a new graphics canvas for the given graphics object.
	 */
	Graphics2DCanvas(Graphics2D g)
	{
		this._g = g;

		// Initializes the cell renderer pane for drawing HTML markup
		try
		{
			_rendererPane = new CellRendererPane();
		}
		catch (Exception e)
		{
			// ignore
		}
	}

	/**
	 * 
	 */
	static void putShape(String name, IShape shape)
	{
		_shapes.put(name, shape);
	}

	/**
	 * 
	 */
	IShape getShape(Map<String, Object> style)
	{
		String name = Utils.getString(style, Constants.STYLE_SHAPE, null);
		IShape shape = _shapes.get(name);

		if (shape == null && name != null)
		{
			shape = StencilRegistry.getStencil(name);
		}

		return shape;
	}

	/**
	 * 
	 */
	static void putTextShape(String name, ITextShape shape)
	{
		_textShapes.put(name, shape);
	}

	/**
	 * 
	 */
	ITextShape getTextShape(Map<String, Object> style, bool html)
	{
		String name;

		if (html)
		{
			name = TEXT_SHAPE_HTML;
		}
		else
		{
			name = TEXT_SHAPE_DEFAULT;
		}

		return _textShapes.get(name);
	}

	/**
	 * 
	 */
	CellRendererPane getRendererPane()
	{
		return _rendererPane;
	}

	/**
	 * Returns the graphics object for this canvas.
	 */
	Graphics2D getGraphics()
	{
		return _g;
	}

	/**
	 * Sets the graphics object for this canvas.
	 */
	void setGraphics(Graphics2D g)
	{
		this._g = g;
	}

	/*
	 * (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawCell()
	 */
	Object drawCell(CellState state)
	{
		Map<String, Object> style = state.getStyle();
		IShape shape = getShape(style);

		if (_g != null && shape != null)
		{
			// Creates a temporary graphics instance for drawing this shape
			float opacity = Utils.getFloat(style, Constants.STYLE_OPACITY,
					100);
			Graphics2D previousGraphics = _g;
			_g = createTemporaryGraphics(style, opacity, state);

			// Paints the shape and restores the graphics object
			shape.paintShape(this, state);
			_g.dispose();
			_g = previousGraphics;
		}

		return shape;
	}

	/*
	 * (non-Javadoc)
	 * @see graph.canvas.ICanvas#drawLabel()
	 */
	Object drawLabel(String text, CellState state, bool html)
	{
		Map<String, Object> style = state.getStyle();
		ITextShape shape = getTextShape(style, html);

		if (_g != null && shape != null && _drawLabels && text != null
				&& text.length() > 0)
		{
			// Creates a temporary graphics instance for drawing this shape
			float opacity = Utils.getFloat(style,
					Constants.STYLE_TEXT_OPACITY, 100);
			Graphics2D previousGraphics = _g;
			_g = createTemporaryGraphics(style, opacity, null);

			// Draws the label background and border
			Color bg = Utils.getColor(style,
					Constants.STYLE_LABEL_BACKGROUNDCOLOR);
			Color border = Utils.getColor(style,
					Constants.STYLE_LABEL_BORDERCOLOR);
			paintRectangle(state.getLabelBounds().getRectangle(), bg, border);

			// Paints the label and restores the graphics object
			shape.paintShape(this, text, state, style);
			_g.dispose();
			_g = previousGraphics;
		}

		return shape;
	}

	/**
	 * 
	 */
	void drawImage(Rectangle bounds, String imageUrl)
	{
		drawImage(bounds, imageUrl, PRESERVE_IMAGE_ASPECT, false, false);
	}

	/**
	 * 
	 */
	void drawImage(Rectangle bounds, String imageUrl,
			bool preserveAspect, bool flipH, bool flipV)
	{
		if (imageUrl != null && bounds.getWidth() > 0 && bounds.getHeight() > 0)
		{
			Image img = loadImage(imageUrl);

			if (img != null)
			{
				int w, h;
				int x = bounds.x;
				int y = bounds.y;
				Dimension size = _getImageSize(img);

				if (preserveAspect)
				{
					double s = Math.min(bounds.width / (double) size.width,
							bounds.height / (double) size.height);
					w = (int) (size.width * s);
					h = (int) (size.height * s);
					x += (bounds.width - w) / 2;
					y += (bounds.height - h) / 2;
				}
				else
				{
					w = bounds.width;
					h = bounds.height;
				}

				Image scaledImage = (w == size.width && h == size.height) ? img
						: img.getScaledInstance(w, h, IMAGE_SCALING);

				if (scaledImage != null)
				{
					AffineTransform af = null;

					if (flipH || flipV)
					{
						af = _g.getTransform();
						int sx = 1;
						int sy = 1;
						int dx = 0;
						int dy = 0;

						if (flipH)
						{
							sx = -1;
							dx = -w - 2 * x;
						}

						if (flipV)
						{
							sy = -1;
							dy = -h - 2 * y;
						}

						_g.scale(sx, sy);
						_g.translate(dx, dy);
					}

					_drawImageImpl(scaledImage, x, y);

					// Restores the previous transform
					if (af != null)
					{
						_g.setTransform(af);
					}
				}
			}
		}
	}

	/**
	 * Implements the actual graphics call.
	 */
	void _drawImageImpl(Image image, int x, int y)
	{
		_g.drawImage(image, x, y, null);
	}

	/**
	 * Returns the size for the given image.
	 */
	Dimension _getImageSize(Image image)
	{
		return new Dimension(image.getWidth(null), image.getHeight(null));
	}

	/**
	 * 
	 */
	void paintPolyline(Point2d[] points, bool rounded)
	{
		if (points != null && points.length > 1)
		{
			Point2d pt = points[0];
			Point2d pe = points[points.length - 1];

			double arcSize = Constants.LINE_ARCSIZE * _scale;

			GeneralPath path = new GeneralPath();
			path.moveTo((float) pt.getX(), (float) pt.getY());

			// Draws the line segments
			for (int i = 1; i < points.length - 1; i++)
			{
				Point2d tmp = points[i];
				double dx = pt.getX() - tmp.getX();
				double dy = pt.getY() - tmp.getY();

				if ((rounded && i < points.length - 1) && (dx != 0 || dy != 0))
				{
					// Draws a line from the last point to the current
					// point with a spacing of size off the current point
					// into direction of the last point
					double dist = Math.sqrt(dx * dx + dy * dy);
					double nx1 = dx * Math.min(arcSize, dist / 2) / dist;
					double ny1 = dy * Math.min(arcSize, dist / 2) / dist;

					double x1 = tmp.getX() + nx1;
					double y1 = tmp.getY() + ny1;
					path.lineTo((float) x1, (float) y1);

					// Draws a curve from the last point to the current
					// point with a spacing of size off the current point
					// into direction of the next point
					Point2d next = points[i + 1];

					// Uses next non-overlapping point
					while (i < points.length - 2 && Math.round(next.getX() - tmp.getX()) == 0 && Math.round(next.getY() - tmp.getY()) == 0)
					{
						next = points[i + 2];
						i++;
					}
					
					dx = next.getX() - tmp.getX();
					dy = next.getY() - tmp.getY();

					dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
					double nx2 = dx * Math.min(arcSize, dist / 2) / dist;
					double ny2 = dy * Math.min(arcSize, dist / 2) / dist;

					double x2 = tmp.getX() + nx2;
					double y2 = tmp.getY() + ny2;

					path.quadTo((float) tmp.getX(), (float) tmp.getY(),
							(float) x2, (float) y2);
					tmp = new Point2d(x2, y2);
				}
				else
				{
					path.lineTo((float) tmp.getX(), (float) tmp.getY());
				}

				pt = tmp;
			}

			path.lineTo((float) pe.getX(), (float) pe.getY());
			_g.draw(path);
		}
	}

	/**
	 *
	 */
	void paintRectangle(Rectangle bounds, Color background, Color border)
	{
		if (background != null)
		{
			_g.setColor(background);
			fillShape(bounds);
		}

		if (border != null)
		{
			_g.setColor(border);
			_g.draw(bounds);
		}
	}

	/**
	 *
	 */
	void fillShape(Shape shape)
	{
		fillShape(shape, false);
	}

	/**
	 *
	 */
	void fillShape(Shape shape, bool shadow)
	{
		int shadowOffsetX = (shadow) ? Constants.SHADOW_OFFSETX : 0;
		int shadowOffsetY = (shadow) ? Constants.SHADOW_OFFSETY : 0;

		if (shadow)
		{
			// Saves the state and configures the graphics object
			Paint p = _g.getPaint();
			Color previousColor = _g.getColor();
			_g.setColor(SwingConstants.SHADOW_COLOR);
			_g.translate(shadowOffsetX, shadowOffsetY);

			// Paints the shadow
			fillShape(shape, false);

			// Restores the state of the graphics object
			_g.translate(-shadowOffsetX, -shadowOffsetY);
			_g.setColor(previousColor);
			_g.setPaint(p);
		}

		_g.fill(shape);
	}

	/**
	 * 
	 */
	Stroke createStroke(Map<String, Object> style)
	{
		double width = Utils
				.getFloat(style, Constants.STYLE_STROKEWIDTH, 1) * _scale;
		bool dashed = Utils.isTrue(style, Constants.STYLE_DASHED);
		if (dashed)
		{
			float[] dashPattern = Utils.getFloatArray(style,
					Constants.STYLE_DASH_PATTERN,
					Constants.DEFAULT_DASHED_PATTERN, " ");
			float[] scaledDashPattern = new float[dashPattern.length];

			for (int i = 0; i < dashPattern.length; i++)
			{
				scaledDashPattern[i] = (float) (dashPattern[i] * _scale * width);
			}

			return new BasicStroke((float) width, BasicStroke.CAP_BUTT,
					BasicStroke.JOIN_MITER, 10.0f, scaledDashPattern, 0.0f);
		}
		else
		{
			return new BasicStroke((float) width);
		}
	}

	/**
	 * 
	 */
	Paint createFillPaint(Rect bounds, Map<String, Object> style)
	{
		Color fillColor = Utils.getColor(style, Constants.STYLE_FILLCOLOR);
		Paint fillPaint = null;

		if (fillColor != null)
		{
			Color gradientColor = Utils.getColor(style,
					Constants.STYLE_GRADIENTCOLOR);

			if (gradientColor != null)
			{
				String gradientDirection = Utils.getString(style,
						Constants.STYLE_GRADIENT_DIRECTION);

				float x1 = (float) bounds.getX();
				float y1 = (float) bounds.getY();
				float x2 = (float) bounds.getX();
				float y2 = (float) bounds.getY();

				if (gradientDirection == null
						|| gradientDirection
								.equals(Constants.DIRECTION_SOUTH))
				{
					y2 = (float) (bounds.getY() + bounds.getHeight());
				}
				else if (gradientDirection.equals(Constants.DIRECTION_EAST))
				{
					x2 = (float) (bounds.getX() + bounds.getWidth());
				}
				else if (gradientDirection.equals(Constants.DIRECTION_NORTH))
				{
					y1 = (float) (bounds.getY() + bounds.getHeight());
				}
				else if (gradientDirection.equals(Constants.DIRECTION_WEST))
				{
					x1 = (float) (bounds.getX() + bounds.getWidth());
				}

				fillPaint = new GradientPaint(x1, y1, fillColor, x2, y2,
						gradientColor, true);
			}
		}

		return fillPaint;
	}

	/**
	 * 
	 */
	Graphics2D createTemporaryGraphics(Map<String, Object> style,
			float opacity, Rect bounds)
	{
		Graphics2D temporaryGraphics = (Graphics2D) _g.create();

		// Applies the default translate
		temporaryGraphics.translate(_translate.x, _translate.y);

		// Applies the rotation on the graphics object
		if (bounds != null)
		{
			double rotation = Utils.getDouble(style,
					Constants.STYLE_ROTATION, 0);

			if (rotation != 0)
			{
				temporaryGraphics.rotate(Math.toRadians(rotation),
						bounds.getCenterX(), bounds.getCenterY());
			}
		}

		// Applies the opacity to the graphics object
		if (opacity != 100)
		{
			temporaryGraphics.setComposite(AlphaComposite.getInstance(
					AlphaComposite.SRC_OVER, opacity / 100));
		}

		return temporaryGraphics;
	}

}
