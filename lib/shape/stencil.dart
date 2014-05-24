/**
 * Copyright (c) 2010-2012, JGraph Ltd
 */
part of graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../canvas/canvas.dart' show GraphicsCanvas2D;
import '../util/util.dart' show Constants;
import '../util/util.dart' show Point2d;
import '../util/util.dart' show Rect;
import '../util/util.dart' show Utils;
import '../view/view.dart' show CellState;

//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Implements a stencil for the given XML definition. This class implements the Graph
 * stencil schema.
 */
class Stencil implements IShape
{
	/**
	 * Holds the top-level node of the stencil definition.
	 */
	Element _desc;

	/**
	 * Holds the aspect of the shape. Default is "auto".
	 */
	String _aspect = null;

	/**
	 * Holds the width of the shape. Default is 100.
	 */
	double _w0 = 100;

	/**
	 * Holds the height of the shape. Default is 100.
	 */
	double _h0 = 100;

	/**
	 * Holds the XML node with the stencil description.
	 */
	Element _bgNode = null;

	/**
	 * Holds the XML node with the stencil description.
	 */
	Element _fgNode = null;

	/**
	 * Holds the strokewidth direction from the description.
	 */
	String _strokewidth = null;

	/**
	 * Holds the last x-position of the cursor.
	 */
	double _lastMoveX = 0;

	/**
	 * Holds the last y-position of the cursor.
	 */
	double _lastMoveY = 0;

	/**
	 * Constructs a new stencil for the given Graph shape description.
	 */
	Stencil(Element description)
	{
		setDescription(description);
	}
	
	/**
	 * Returns the description.
	 */
	Element getDescription()
	{
		return _desc;
	}
	
	/**
	 * Sets the description.
	 */
	void setDescription(Element value)
	{
		_desc = value;
		_parseDescription();
	}

	/**
	 * Creates the canvas for rendering the stencil.
	 */
	GraphicsCanvas2D _createCanvas(Graphics2DCanvas gc)
	{
		return new GraphicsCanvas2D(gc.getGraphics());
	}
	
	/**
	 * Paints the stencil for the given state.
	 */
	void paintShape(Graphics2DCanvas gc, CellState state)
	{
		Map<String, Object> style = state.getStyle();
		GraphicsCanvas2D canvas = _createCanvas(gc);

		double rotation = Utils.getDouble(style, Constants.STYLE_ROTATION,
				0);
		String direction = Utils.getString(style,
				Constants.STYLE_DIRECTION, null);

		// Default direction is east (ignored if rotation exists)
		if (direction != null)
		{
			if (direction.equals("north"))
			{
				rotation += 270;
			}
			else if (direction.equals("west"))
			{
				rotation += 180;
			}
			else if (direction.equals("south"))
			{
				rotation += 90;
			}
		}

		// New styles for shape flipping the stencil
		bool flipH = Utils.isTrue(style, Constants.STYLE_STENCIL_FLIPH,
				false);
		bool flipV = Utils.isTrue(style, Constants.STYLE_STENCIL_FLIPV,
				false);

		if (flipH && flipV)
		{
			rotation += 180;
			flipH = false;
			flipV = false;
		}

		// Saves the global state for each cell
		canvas.save();

		// Adds rotation and horizontal/vertical flipping
		rotation = rotation % 360;

		if (rotation != 0 || flipH || flipV)
		{
			canvas.rotate(rotation, flipH, flipV, state.getCenterX(),
					state.getCenterY());
		}

		// Note: Overwritten in Stencil.paintShape (can depend on aspect)
		double scale = state.getView().getScale();
		double sw = Utils.getDouble(style, Constants.STYLE_STROKEWIDTH, 1)
				* scale;
		canvas.setStrokeWidth(sw);

		double alpha = Utils.getDouble(style, Constants.STYLE_OPACITY, 100) / 100;
		String gradientColor = Utils.getString(style,
				Constants.STYLE_GRADIENTCOLOR, null);

		// Converts colors with special keyword none to null
		if (gradientColor != null && gradientColor.equals(Constants.NONE))
		{
			gradientColor = null;
		}

		String fillColor = Utils.getString(style,
				Constants.STYLE_FILLCOLOR, null);

		if (fillColor != null && fillColor.equals(Constants.NONE))
		{
			fillColor = null;
		}

		String strokeColor = Utils.getString(style,
				Constants.STYLE_STROKECOLOR, null);

		if (strokeColor != null && strokeColor.equals(Constants.NONE))
		{
			strokeColor = null;
		}

		// Draws the shadow if the fillColor is not transparent
		if (Utils.isTrue(style, Constants.STYLE_SHADOW, false))
		{
			_drawShadow(canvas, state, rotation, flipH, flipV, state, alpha, fillColor != null);
		}

		canvas.setAlpha(alpha);

		// Sets the dashed state
		if (Utils.isTrue(style, Constants.STYLE_DASHED, false))
		{
			canvas.setDashed(true);
		}

		// Draws background and foreground
		if (strokeColor != null || fillColor != null)
		{
			if (strokeColor != null)
			{
				canvas.setStrokeColor(strokeColor);
			}

			if (fillColor != null)
			{
				if (gradientColor != null
						&& !gradientColor.equals("transparent"))
				{
					canvas.setGradient(fillColor, gradientColor, state.getX(),
							state.getY(), state.getWidth(), state.getHeight(),
							direction, 1, 1);
				}
				else
				{
					canvas.setFillColor(fillColor);
				}
			}

			// Draws background and foreground of shape
			drawShape(canvas, state, state, true);
			drawShape(canvas, state, state, false);
		}
	}
	
	/**
	 * Draws the shadow.
	 */
	void _drawShadow(GraphicsCanvas2D canvas, CellState state, double rotation, bool flipH,
			bool flipV, Rect bounds, double alpha, bool filled)
	{
		// Requires background in generic shape for shadow, looks like only one
		// fillAndStroke is allowed per current path, try working around that
		// Computes rotated shadow offset
		double rad = rotation * Math.PI / 180;
		double cos = Math.cos(-rad);
		double sin = Math.sin(-rad);
		Point2d offset = Utils.getRotatedPoint(new Point2d(Constants.SHADOW_OFFSETX, Constants.SHADOW_OFFSETY), cos, sin);
		
		if (flipH)
		{
			offset.setX(offset.getX() * -1);
		}
		
		if (flipV)
		{
			offset.setY(offset.getY() * -1);
		}
		
		// TODO: Use save/restore instead of negative offset to restore (requires fix for HTML canvas)
		canvas.translate(offset.getX(), offset.getY());
		
		// Returns true if a shadow has been painted (path has been created)
		if (drawShape(canvas, state, bounds, true))
		{
			canvas.setAlpha(Constants.STENCIL_SHADOW_OPACITY * alpha);
			// TODO: Implement new shadow
			//canvas.shadow(Constants.STENCIL_SHADOWCOLOR, filled);
		}

		canvas.translate(-offset.getX(), -offset.getY());
	}
			
	/**
	 * Draws this stencil inside the given bounds.
	 */
	bool drawShape(GraphicsCanvas2D canvas, CellState state,
			Rect bounds, bool background)
	{
		Element elt = (background) ? _bgNode : _fgNode;

		if (elt != null)
		{
			String direction = Utils.getString(state.getStyle(),
					Constants.STYLE_DIRECTION, null);
			Rect aspect = _computeAspect(state, bounds, direction);
			double minScale = Math.min(aspect.getWidth(), aspect.getHeight());
			double sw = _strokewidth.equals("inherit") ? Utils.getDouble(
					state.getStyle(), Constants.STYLE_STROKEWIDTH, 1)
					* state.getView().getScale() : Double
					.parseDouble(_strokewidth) * minScale;
			_lastMoveX = 0;
			_lastMoveY = 0;
			canvas.setStrokeWidth(sw);

			Node tmp = elt.getFirstChild();

			while (tmp != null)
			{
				if (tmp.getNodeType() == Node.ELEMENT_NODE)
				{
					_drawElement(canvas, state, (Element) tmp, aspect);
				}

				tmp = tmp.getNextSibling();
			}

			return true;
		}

		return false;
	}

	/**
	 * Returns a rectangle that contains the offset in x and y and the horizontal
	 * and vertical scale in width and height used to draw this shape inside the
	 * given rectangle.
	 */
	Rect _computeAspect(CellState state, Rect bounds,
			String direction)
	{
		double x0 = bounds.getX();
		double y0 = bounds.getY();
		double sx = bounds.getWidth() / _w0;
		double sy = bounds.getHeight() / _h0;

		bool inverse = (direction != null && (direction.equals("north") || direction
				.equals("south")));

		if (inverse)
		{
			sy = bounds.getWidth() / _h0;
			sx = bounds.getHeight() / _w0;

			double delta = (bounds.getWidth() - bounds.getHeight()) / 2;

			x0 += delta;
			y0 -= delta;
		}

		if (_aspect.equals("fixed"))
		{
			sy = Math.min(sx, sy);
			sx = sy;

			// Centers the shape inside the available space
			if (inverse)
			{
				x0 += (bounds.getHeight() - this._w0 * sx) / 2;
				y0 += (bounds.getWidth() - this._h0 * sy) / 2;
			}
			else
			{
				x0 += (bounds.getWidth() - this._w0 * sx) / 2;
				y0 += (bounds.getHeight() - this._h0 * sy) / 2;
			}
		}

		return new Rect(x0, y0, sx, sy);
	}

	/**
	 * Drawsthe given element.
	 */
	void _drawElement(GraphicsCanvas2D canvas, CellState state,
			Element node, Rect aspect)
	{
		String name = node.getNodeName();
		double x0 = aspect.getX();
		double y0 = aspect.getY();
		double sx = aspect.getWidth();
		double sy = aspect.getHeight();
		double minScale = Math.min(sx, sy);

		// LATER: Move to lookup table
		if (name.equals("save"))
		{
			canvas.save();
		}
		else if (name.equals("restore"))
		{
			canvas.restore();
		}
		else if (name.equals("path"))
		{
			canvas.begin();

			// Renders the elements inside the given path
			Node childNode = node.getFirstChild();

			while (childNode != null)
			{
				if (childNode.getNodeType() == Node.ELEMENT_NODE)
				{
					_drawElement(canvas, state, (Element) childNode, aspect);
				}

				childNode = childNode.getNextSibling();
			}
		}
		else if (name.equals("close"))
		{
			canvas.close();
		}
		else if (name.equals("move"))
		{
			_lastMoveX = x0 + _getDouble(node, "x") * sx;
			_lastMoveY = y0 + _getDouble(node, "y") * sy;
			canvas.moveTo(_lastMoveX, _lastMoveY);
		}
		else if (name.equals("line"))
		{
			_lastMoveX = x0 + _getDouble(node, "x") * sx;
			_lastMoveY = y0 + _getDouble(node, "y") * sy;
			canvas.lineTo(_lastMoveX, _lastMoveY);
		}
		else if (name.equals("quad"))
		{
			_lastMoveX = x0 + _getDouble(node, "x2") * sx;
			_lastMoveY = y0 + _getDouble(node, "y2") * sy;
			canvas.quadTo(x0 + _getDouble(node, "x1") * sx,
					y0 + _getDouble(node, "y1") * sy, _lastMoveX, _lastMoveY);
		}
		else if (name.equals("curve"))
		{
			_lastMoveX = x0 + _getDouble(node, "x3") * sx;
			_lastMoveY = y0 + _getDouble(node, "y3") * sy;
			canvas.curveTo(x0 + _getDouble(node, "x1") * sx,
					y0 + _getDouble(node, "y1") * sy, x0 + _getDouble(node, "x2")
							* sx, y0 + _getDouble(node, "y2") * sy, _lastMoveX,
					_lastMoveY);
		}
		else if (name.equals("arc"))
		{
			// Arc from stencil is turned into curves in image output
			double r1 = _getDouble(node, "rx") * sx;
			double r2 = _getDouble(node, "ry") * sy;
			double angle = _getDouble(node, "x-axis-rotation");
			double largeArcFlag = _getDouble(node, "large-arc-flag");
			double sweepFlag = _getDouble(node, "sweep-flag");
			double x = x0 + _getDouble(node, "x") * sx;
			double y = y0 + _getDouble(node, "y") * sy;

			double[] curves = Utils.arcToCurves(this._lastMoveX,
					this._lastMoveY, r1, r2, angle, largeArcFlag, sweepFlag, x,
					y);

			for (int i = 0; i < curves.length; i += 6)
			{
				canvas.curveTo(curves[i], curves[i + 1], curves[i + 2],
						curves[i + 3], curves[i + 4], curves[i + 5]);

				_lastMoveX = curves[i + 4];
				_lastMoveY = curves[i + 5];
			}
		}
		else if (name.equals("rect"))
		{
			canvas.rect(x0 + _getDouble(node, "x") * sx,
					y0 + _getDouble(node, "y") * sy, _getDouble(node, "w") * sx,
					_getDouble(node, "h") * sy);
		}
		else if (name.equals("roundrect"))
		{
			double arcsize = _getDouble(node, "arcsize");

			if (arcsize == 0)
			{
				arcsize = Constants.RECTANGLE_ROUNDING_FACTOR * 100;
			}

			double w = _getDouble(node, "w") * sx;
			double h = _getDouble(node, "h") * sy;
			double factor = arcsize / 100;
			double r = Math.min(w * factor, h * factor);

			canvas.roundrect(x0 + _getDouble(node, "x") * sx,
					y0 + _getDouble(node, "y") * sy, _getDouble(node, "w") * sx,
					_getDouble(node, "h") * sy, r, r);
		}
		else if (name.equals("ellipse"))
		{
			canvas.ellipse(x0 + _getDouble(node, "x") * sx,
					y0 + _getDouble(node, "y") * sy, _getDouble(node, "w") * sx,
					_getDouble(node, "h") * sy);
		}
		else if (name.equals("image"))
		{
			String src = evaluateAttribute(node, "src", state);

			canvas.image(x0 + _getDouble(node, "x") * sx,
					y0 + _getDouble(node, "y") * sy, _getDouble(node, "w") * sx,
					_getDouble(node, "h") * sy, src, false,
					_getString(node, "flipH", "0").equals("1"),
					_getString(node, "flipV", "0").equals("1"));
		}
		else if (name.equals("text"))
		{
			String str = evaluateAttribute(node, "str", state);
			double rotation = _getString(node, "vertical", "0").equals("1") ? -90 : 0;
			
			canvas.text(x0 + _getDouble(node, "x") * sx,
					y0 + _getDouble(node, "y") * sy, 0, 0, str,
					node.getAttribute("align"), node.getAttribute("valign"),
					false, "", null, false, rotation);
		}
		else if (name.equals("include-shape"))
		{
			Stencil stencil = StencilRegistry.getStencil(node
					.getAttribute("name"));

			if (stencil != null)
			{
				double x = x0 + _getDouble(node, "x") * sx;
				double y = y0 + _getDouble(node, "y") * sy;
				double w = _getDouble(node, "w") * sx;
				double h = _getDouble(node, "h") * sy;

				Rect tmp = new Rect(x, y, w, h);
				stencil.drawShape(canvas, state, tmp, true);
				stencil.drawShape(canvas, state, tmp, false);
			}
		}
		else if (name.equals("fillstroke"))
		{
			canvas.fillAndStroke();
		}
		else if (name.equals("fill"))
		{
			canvas.fill();
		}
		else if (name.equals("stroke"))
		{
			canvas.stroke();
		}
		else if (name.equals("strokewidth"))
		{
			canvas.setStrokeWidth(_getDouble(node, "width") * minScale);
		}
		else if (name.equals("dashed"))
		{
			canvas.setDashed(node.getAttribute("dashed") == "1");
		}
		else if (name.equals("dashpattern"))
		{
			String value = node.getAttribute("pattern");

			if (value != null)
			{
				String[] tmp = value.split(" ");
				StringBuffer pat = new StringBuffer();

				for (int i = 0; i < tmp.length; i++)
				{
					if (tmp[i].length() > 0)
					{
						pat.append(Double.parseDouble(tmp[i]) * minScale);
						pat.append(" ");
					}
				}

				value = pat.toString();
			}

			canvas.setDashPattern(value);
		}
		else if (name.equals("strokecolor"))
		{
			canvas.setStrokeColor(node.getAttribute("color"));
		}
		else if (name.equals("linecap"))
		{
			canvas.setLineCap(node.getAttribute("cap"));
		}
		else if (name.equals("linejoin"))
		{
			canvas.setLineJoin(node.getAttribute("join"));
		}
		else if (name.equals("miterlimit"))
		{
			canvas.setMiterLimit(_getDouble(node, "limit"));
		}
		else if (name.equals("fillcolor"))
		{
			canvas.setFillColor(node.getAttribute("color"));
		}
		else if (name.equals("fontcolor"))
		{
			canvas.setFontColor(node.getAttribute("color"));
		}
		else if (name.equals("fontstyle"))
		{
			canvas.setFontStyle(_getInt(node, "style", 0));
		}
		else if (name.equals("fontfamily"))
		{
			canvas.setFontFamily(node.getAttribute("family"));
		}
		else if (name.equals("fontsize"))
		{
			canvas.setFontSize(_getDouble(node, "size") * minScale);
		}
	}

	/**
	 * Returns the given attribute or the default value.
	 */
	int _getInt(Element elt, String attribute, int defaultValue)
	{
		String value = elt.getAttribute(attribute);

		if (value != null && value.length() > 0)
		{
			try
			{
				defaultValue = (int) Math.floor(Float.parseFloat(value));
			}
			catch (NumberFormatException e)
			{
				// ignore
			}
		}

		return defaultValue;
	}

	/**
	 * Returns the given attribute or 0.
	 */
	double _getDouble(Element elt, String attribute)
	{
		return _getDouble(elt, attribute, 0);
	}

	/**
	 * Returns the given attribute or the default value.
	 */
	double _getDouble(Element elt, String attribute,
			double defaultValue)
	{
		String value = elt.getAttribute(attribute);

		if (value != null && value.length() > 0)
		{
			try
			{
				defaultValue = Double.parseDouble(value);
			}
			catch (NumberFormatException e)
			{
				// ignore
			}
		}

		return defaultValue;
	}

	/**
	 * Returns the given attribute or the default value.
	 */
	String _getString(Element elt, String attribute,
			String defaultValue)
	{
		String value = elt.getAttribute(attribute);

		if (value != null && value.length() > 0)
		{
			defaultValue = value;
		}

		return defaultValue;
	}

	/**
	 * Parses the description of this shape.
	 */
	void _parseDescription()
	{
		// LATER: Preprocess nodes for faster painting
		_fgNode = (Element) _desc.getElementsByTagName("foreground").item(0);
		_bgNode = (Element) _desc.getElementsByTagName("background").item(0);
		_w0 = _getDouble(_desc, "w", _w0);
		_h0 = _getDouble(_desc, "h", _h0);

		// Possible values for aspect are: variable and fixed where
		// variable means fill the available space and fixed means
		// use w0 and h0 to compute the aspect.
		_aspect = _getString(_desc, "aspect", "variable");

		// Possible values for strokewidth are all numbers and "inherit"
		// where the inherit means take the value from the style (ie. the
		// user-defined stroke-width). Note that the strokewidth is scaled
		// by the minimum scaling that is used to draw the shape (sx, sy).
		_strokewidth = _getString(_desc, "strokewidth", "1");
	}

	/**
	 * Gets the attribute for the given name from the given node. If the attribute
	 * does not exist then the text content of the node is evaluated and if it is
	 * a function it is invoked with <state> as the only argument and the return
	 * value is used as the attribute value to be returned.
	 */
	String evaluateAttribute(Element elt, String attribute,
			CellState state)
	{
		String result = elt.getAttribute(attribute);

		if (result == null)
		{
			// JS functions as text content are currently not supported in Java
		}

		return result;
	}

}
