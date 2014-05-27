part of graph.canvas;

//import java.awt.AlphaComposite;
//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Composite;
//import java.awt.Dimension;
//import java.awt.Font;
//import java.awt.FontMetrics;
//import java.awt.GradientPaint;
//import java.awt.Graphics2D;
//import java.awt.Image;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.font.TextAttribute;
//import java.awt.geom.AffineTransform;
//import java.awt.geom.Ellipse2D;
//import java.awt.geom.GeneralPath;
//import java.awt.geom.Point2D;
//import java.awt.geom.Rectangle2D;
//import java.text.AttributedString;
//import java.util.LinkedHashMap;
//import java.util.Map;
//import java.util.Stack;

//import javax.swing.CellRendererPane;
//import javax.swing.JLabel;

/**
 * Used for exporting images. To render to an image from a given XML string,
 * graph size and background color, the following code is used:
 * 
 * <code>
 * BufferedImage image = Utils.createBufferedImage(width, height, background);
 * Graphics2D g2 = image.createGraphics();
 * Utils.setAntiAlias(g2, true, true);
 * XMLReader reader = SAXParserFactory.newInstance().newSAXParser().getXMLReader();
 * reader.setContentHandler(new SaxOutputHandler(new GraphicsCanvas2D(g2)));
 * reader.parse(new InputSource(new StringReader(xml)));
 * </code>
 * 
 * Text rendering is available for plain text and HTML markup, the latter with optional
 * word wrapping. CSS support is limited to the following:
 * http://docs.oracle.com/javase/6/docs/api/index.html?javax/swing/text/html/CSS.html
 */
class GraphicsCanvas2D implements ICanvas2D
{

	/**
	 * Specifies the image scaling quality. Default is Image.SCALE_SMOOTH.
	 * See {@link #_scaleImage(Image, int, int)}
	 */
	static int IMAGE_SCALING = Image.SCALE_SMOOTH;

	/**
	 * Specifies the size of the cache used to store parsed colors
	 */
	static int COLOR_CACHE_SIZE = 100;

	/**
	 * Reference to the graphics instance for painting.
	 */
	Graphics2D _graphics;

	/**
	 * Specifies if text output should be rendered. Default is true.
	 */
	bool _textEnabled = true;

	/**
	 * Represents the current state of the canvas.
	 */
	/*transient*/ _CanvasState _state = new _CanvasState();

	/**
	 * Stack of states for save/restore.
	 */
	/*transient*/ Stack<_CanvasState> _stack = new Stack<_CanvasState>();

	/**
	 * Holds the current path.
	 */
	/*transient*/ GeneralPath _currentPath;

	/**
	 * Optional renderer pane to be used for HTML label rendering.
	 */
	CellRendererPane _rendererPane;

	/**
	 * Font caching.
	 */
	/*transient*/ Font _lastFont = null;

	/**
	 * Font caching.
	 */
	/*transient*/ int _lastFontStyle = 0;

	/**
	 * Font caching.
	 */
	/*transient*/ int _lastFontSize = 0;

	/**
	 * Font caching.
	 */
	/*transient*/ String _lastFontFamily = "";

	/**
	 * Stroke caching.
	 */
	/*transient*/ Stroke _lastStroke = null;

	/**
	 * Stroke caching.
	 */
	/*transient*/ float _lastStrokeWidth = 0;

	/**
	 * Stroke caching.
	 */
	/*transient*/ int _lastCap = 0;

	/**
	 * Stroke caching.
	 */
	/*transient*/ int _lastJoin = 0;

	/**
	 * Stroke caching.
	 */
	/*transient*/ float _lastMiterLimit = 0;

	/**
	 * Stroke caching.
	 */
	/*transient*/ bool _lastDashed = false;

	/**
	 * Stroke caching.
	 */
	/*transient*/ Object _lastDashPattern = "";

	/**
	 * Caches parsed colors.
	 */
//	@SuppressWarnings("serial")
	/*transient*/ /*LinkedHashMap<String, Color> _colorCache = new LinkedHashMap<String, Color>()
	{
		@Override
		protected bool removeEldestEntry(Map.Entry<String, Color> eldest)
		{
			return size() > COLOR_CACHE_SIZE;
		}
	};*/

	/**
	 * Constructs a new graphics export canvas.
	 */
	GraphicsCanvas2D(Graphics2D g)
	{
		setGraphics(g);
		_state.g = g;

		// Initializes the cell renderer pane for drawing HTML markup
		try
		{
			_rendererPane = new CellRendererPane();
		}
		on Exception catch (e)
		{
			// ignore
		}
	}

	/**
	 * Sets the graphics instance.
	 */
	void setGraphics(Graphics2D value)
	{
		_graphics = value;
	}

	/**
	 * Returns the graphics instance.
	 */
	Graphics2D getGraphics()
	{
		return _graphics;
	}

	/**
	 * Returns true if text should be rendered.
	 */
	bool isTextEnabled()
	{
		return _textEnabled;
	}

	/**
	 * Disables or enables text rendering.
	 */
	void setTextEnabled(bool value)
	{
		_textEnabled = value;
	}

	/**
	 * Saves the current canvas state.
	 */
	void save()
	{
		_stack.push(_state);
		_state = _cloneState(_state);
		_state.g = _state.g.create() as Graphics2D;
	}

	/**
	 * Restores the last canvas state.
	 */
	void restore()
	{
		_state = _stack.pop();
	}

	/**
	 * Returns a clone of thec given state.
	 */
	_CanvasState _cloneState(_CanvasState state)
	{
		try
		{
			return state.clone() as _CanvasState;
		}
		on CloneNotSupportedException catch (e)
		{
			e.printStackTrace();
		}

		return null;
	}

	/**
	 * 
	 */
	void scale(double value)
	{
		// This implementation uses custom scale/translate and built-in rotation
		_state.scale = _state.scale * value;
	}

	/**
	 * 
	 */
	void translate(double dx, double dy)
	{
		// This implementation uses custom scale/translate and built-in rotation
		_state.dx += dx;
		_state.dy += dy;
	}

	/**
	 * 
	 */
	void rotate(double theta, bool flipH, bool flipV, double cx, double cy)
	{
		cx += _state.dx;
		cy += _state.dy;
		cx *= _state.scale;
		cy *= _state.scale;
		_state.g.rotate(Math.toRadians(theta), cx, cy);

		// This implementation uses custom scale/translate and built-in rotation
		// Rotation state is part of the AffineTransform in state.transform
		if (flipH && flipV)
		{
			theta += 180;
		}
		else if (flipH ^ flipV)
		{
			double tx = (flipH) ? cx : 0;
			int sx = (flipH) ? -1 : 1;

			double ty = (flipV) ? cy : 0;
			int sy = (flipV) ? -1 : 1;

			_state.g.translate(tx, ty);
			_state.g.scale(sx, sy);
			_state.g.translate(-tx, -ty);
		}

		_state.theta = theta;
		_state.rotationCx = cx;
		_state.rotationCy = cy;
		_state.flipH = flipH;
		_state.flipV = flipV;
	}

	/**
	 * 
	 */
	void setStrokeWidth(double value)
	{
		// Lazy and cached instantiation strategy for all stroke properties
		if (value != _state.strokeWidth)
		{
			_state.strokeWidth = value;
		}
	}

	/**
	 * Caches color conversion as it is expensive.
	 */
	void setStrokeColor(String value)
	{
		// Lazy and cached instantiation strategy for all stroke properties
		if (_state.strokeColorValue == null || !_state.strokeColorValue.equals(value))
		{
			_state.strokeColorValue = value;
			_state.strokeColor = null;
		}
	}

	/**
	 * 
	 */
	void setDashed(bool value)
	{
		// Lazy and cached instantiation strategy for all stroke properties
		if (value != _state.dashed)
		{
			_state.dashed = value;
		}
	}

	/**
	 * 
	 */
	void setDashPattern(String value)
	{
		if (value != null && value.length() > 0)
		{
			List<String> tokens = value.split(" ");
			List<float> dashpattern = new List<float>(tokens.length);

			for (int i = 0; i < tokens.length; i++)
			{
				dashpattern[i] = (float) (Float.parseFloat(tokens[i]));
			}

			_state.dashPattern = dashpattern;
		}
	}

	/**
	 * 
	 */
	void setLineCap(String value)
	{
		if (!_state.lineCap.equals(value))
		{
			_state.lineCap = value;
		}
	}

	/**
	 * 
	 */
	void setLineJoin(String value)
	{
		if (!_state.lineJoin.equals(value))
		{
			_state.lineJoin = value;
		}
	}

	/**
	 * 
	 */
	void setMiterLimit(double value)
	{
		if (value != _state.miterLimit)
		{
			_state.miterLimit = value;
		}
	}

	/**
	 * 
	 */
	void setFontSize(double value)
	{
		if (value != _state.fontSize)
		{
			_state.fontSize = value;
		}
	}

	/**
	 * 
	 */
	void setFontColor(String value)
	{
		if (_state.fontColorValue == null || !_state.fontColorValue.equals(value))
		{
			_state.fontColorValue = value;
			_state.fontColor = null;
		}
	}

	/**
	 * 
	 */
	void setFontBackgroundColor(String value)
	{
		if (_state.fontBackgroundColorValue == null || !_state.fontBackgroundColorValue.equals(value))
		{
			_state.fontBackgroundColorValue = value;
			_state.fontBackgroundColor = null;
		}
	}

	/**
	 * 
	 */
	void setFontBorderColor(String value)
	{
		if (_state.fontBorderColorValue == null || !_state.fontBorderColorValue.equals(value))
		{
			_state.fontBorderColorValue = value;
			_state.fontBorderColor = null;
		}
	}

	/**
	 * 
	 */
	void setFontFamily(String value)
	{
		if (!_state.fontFamily.equals(value))
		{
			_state.fontFamily = value;
		}
	}

	/**
	 * 
	 */
	void setFontStyle(int value)
	{
		if (value != _state.fontStyle)
		{
			_state.fontStyle = value;
		}
	}

	/**
	 * 
	 */
	void setAlpha(double value)
	{
		if (_state.alpha != value)
		{
			_state.g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, (float) (value)));
			_state.alpha = value;
		}
	}

	/**
	 * 
	 */
	void setFillColor(String value)
	{
		if (_state.fillColorValue == null || !_state.fillColorValue.equals(value))
		{
			_state.fillColorValue = value;
			_state.fillColor = null;

			// Setting fill color resets gradient paint
			_state.gradientPaint = null;
		}
	}

	/**
	 * 
	 */
	void setGradient(String color1, String color2, double x, double y, double w, double h, String direction, double alpha1,
			double alpha2)
	{
		// LATER: Add lazy instantiation and check if paint already created
		float x1 = ((_state.dx + x) * _state.scale) as float;
		float y1 = ((_state.dy + y) * _state.scale) as float;
		float x2 = x1 as float;
		float y2 = y1 as float;
		h *= _state.scale;
		w *= _state.scale;

		if (direction == null || direction.length() == 0 || direction.equals(Constants.DIRECTION_SOUTH))
		{
			y2 = (float) (y1 + h);
		}
		else if (direction.equals(Constants.DIRECTION_EAST))
		{
			x2 = (float) (x1 + w);
		}
		else if (direction.equals(Constants.DIRECTION_NORTH))
		{
			y1 = (float) (y1 + h);
		}
		else if (direction.equals(Constants.DIRECTION_WEST))
		{
			x1 = (float) (x1 + w);
		}

		Color c1 = _parseColor(color1);

		if (alpha1 != 1)
		{
			c1 = new Color(c1.getRed(), c1.getGreen(), c1.getBlue(), (int) (alpha1 * 255));
		}

		Color c2 = _parseColor(color2);

		if (alpha2 != 1)
		{
			c2 = new Color(c2.getRed(), c2.getGreen(), c2.getBlue(), (int) (alpha2 * 255));
		}

		_state.gradientPaint = new GradientPaint(x1, y1, c1, x2, y2, c2, true);
		
		// Resets fill color
		_state.fillColorValue = null;
	}

	/**
	 * Helper method that uses {@link Utils#parseColor(String)}.
	 */
	Color _parseColor(String hex)
	{
		Color result = _colorCache.get(hex);

		if (result == null)
		{
			result = Utils.parseColor(hex);
			_colorCache.put(hex, result);
		}

		return result;
	}

	/**
	 *
	 */
	void rect(double x, double y, double w, double h)
	{
		_currentPath = new GeneralPath();
		_currentPath.append(new Rectangle2D.Double((_state.dx + x) * _state.scale, (_state.dy + y) * _state.scale, w * _state.scale, h
				* _state.scale), false);
	}

	/**
	 * Implements a rounded rectangle using a path.
	 */
	void roundrect(double x, double y, double w, double h, double dx, double dy)
	{
		// LATER: Use arc here or quad in VML/SVG for exact match
		begin();
		moveTo(x + dx, y);
		lineTo(x + w - dx, y);
		quadTo(x + w, y, x + w, y + dy);
		lineTo(x + w, y + h - dy);
		quadTo(x + w, y + h, x + w - dx, y + h);
		lineTo(x + dx, y + h);
		quadTo(x, y + h, x, y + h - dy);
		lineTo(x, y + dy);
		quadTo(x, y, x + dx, y);
	}

	/**
	 * 
	 */
	void ellipse(double x, double y, double w, double h)
	{
		_currentPath = new GeneralPath();
		_currentPath.append(new Ellipse2D.Double((_state.dx + x) * _state.scale, (_state.dy + y) * _state.scale, w * _state.scale, h
				* _state.scale), false);
	}

	/**
	 * 
	 */
	void image(double x, double y, double w, double h, String src, bool aspect, bool flipH, bool flipV)
	{
		if (src != null && w > 0 && h > 0)
		{
			Image img = _loadImage(src);

			if (img != null)
			{
				Rectangle bounds = _getImageBounds(img, x, y, w, h, aspect);
				img = _scaleImage(img, bounds.width, bounds.height);

				if (img != null)
				{
					_drawImage(_createImageGraphics(bounds.x, bounds.y, bounds.width, bounds.height, flipH, flipV), img, bounds.x, bounds.y);
				}
			}
		}
	}

	/**
	 * 
	 */
	void _drawImage(Graphics2D graphics, Image image, int x, int y)
	{
		graphics.drawImage(image, x, y, null);
	}

	/**
	 * Hook for image caching.
	 */
	Image _loadImage(String src)
	{
		return Utils.loadImage(src);
	}

	/**
	 * 
	 */
	/*final*/ Rectangle _getImageBounds(Image img, double x, double y, double w, double h, bool aspect)
	{
		x = (_state.dx + x) * _state.scale;
		y = (_state.dy + y) * _state.scale;
		w *= _state.scale;
		h *= _state.scale;

		if (aspect)
		{
			Dimension size = _getImageSize(img);
			double s = Math.min(w / size.width, h / size.height);
			int sw = Math.round(size.width * s) as int;
			int sh = Math.round(size.height * s) as int;
			x += (w - sw) / 2;
			y += (h - sh) / 2;
			w = sw;
			h = sh;
		}
		else
		{
			w = Math.round(w);
			h = Math.round(h);
		}

		return new Rectangle(x as int, y as int, w as int, h as int);
	}

	/**
	 * Returns the size for the given image.
	 */
	Dimension _getImageSize(Image image)
	{
		return new Dimension(image.getWidth(null), image.getHeight(null));
	}

	/**
	 * Uses {@link #IMAGE_SCALING} to scale the given image.
	 */
	Image _scaleImage(Image img, int w, int h)
	{
		Dimension size = _getImageSize(img);

		if (w == size.width && h == size.height)
		{
			return img;
		}
		else
		{
			return img.getScaledInstance(w, h, IMAGE_SCALING);
		}
	}

	/**
	 * Creates a graphic instance for rendering an image.
	 */
	/*final*/ Graphics2D _createImageGraphics(double x, double y, double w, double h, bool flipH, bool flipV)
	{
		Graphics2D g2 = _state.g;

		if (flipH || flipV)
		{
			g2 = g2.create() as Graphics2D;
			
			if (flipV && flipH)
			{
				g2.rotate(Math.toRadians(180), x + w / 2, y + h / 2);
			}
			else
			{
				int sx = 1;
				int sy = 1;
				int dx = 0;
				int dy = 0;

				if (flipH)
				{
					sx = -1;
					dx = (-w - 2 * x) as int;
				}
	
				if (flipV)
				{
					sy = -1;
					dy = (-h - 2 * y) as int;
				}
	
				g2.scale(sx, sy);
				g2.translate(dx, dy);
			}
		}

		return g2;
	}

	/**
	 * Creates a HTML document around the given markup.
	 */
	String _createHtmlDocument(String text, String align, String valign, int w, int h, bool wrap, String overflow, bool clip)
	{
		StringBuffer css = new StringBuffer();
		css.append("display:inline;");
		css.append("font-family:" + _state.fontFamily + ";");
		css.append("font-size:" + Math.round(_state.fontSize) + " pt;");
		css.append("color:" + _state.fontColorValue + ";");
		// KNOWN: Line-height ignored in JLabel
		css.append("line-height:" + ((Constants.ABSOLUTE_LINE_HEIGHT) ? Math.round(_state.fontSize * Constants.LINE_HEIGHT) + " pt" : Constants.LINE_HEIGHT));
		
		bool setWidth = false;
		
		if ((_state.fontStyle & Constants.FONT_BOLD) == Constants.FONT_BOLD)
		{
			css.append("font-weight:bold;");
		}

		if ((_state.fontStyle & Constants.FONT_ITALIC) == Constants.FONT_ITALIC)
		{
			css.append("font-style:italic;");
		}

		if ((_state.fontStyle & Constants.FONT_UNDERLINE) == Constants.FONT_UNDERLINE)
		{
			css.append("text-decoration:underline;");
		}

		if (align != null)
		{
			if (align.equals(Constants.ALIGN_CENTER))
			{
				css.append("text-align:center;");
			}
			else if (align.equals(Constants.ALIGN_RIGHT))
			{
				css.append("text-align:right;");
			}
		}

		if (_state.fontBackgroundColorValue != null)
		{
			css.append("background-color:" + _state.fontBackgroundColorValue + ";");
		}

		// KNOWN: Border ignored in JLabel
		if (_state.fontBorderColorValue != null)
		{
			css.append("border:1pt solid " + _state.fontBorderColorValue + ";");
		}

		// KNOWN: max-width/-height ignored in JLabel
		if (clip)
		{
			css.append("overflow:hidden;");
			setWidth = true;
		}
		else if (overflow != null)
		{
			if (overflow.equals("fill"))
			{
				css.append("height:" + Math.round(h) + "pt;");
				setWidth = true;
			}
			else if (overflow.equals("width"))
			{
				setWidth = true;
	
				if (h > 0)
				{
					css.append("height:" + Math.round(h) + "pt;");
				}
			}
		}

		if (wrap)
		{
			if (!clip)
			{
				// NOTE: Max-width not available in Java
				setWidth = true;
			}

			css.append("white-space:normal;");
		}
		else
		{
			css.append("white-space:nowrap;");
		}

		if (setWidth && w > 0)
		{
			css.append("width:" + Math.round(w) + "pt;");
		}
		
		return "<html><div style=\"" + css.toString() + "\">" + text + "</div></html>";
	}

	/**
	 * Hook to return the renderer for HTML formatted text. This implementation returns
	 * the shared instance of mxLighweightLabel.
	 */
	JLabel _getTextRenderer()
	{
		return LightweightLabel.getSharedInstance();
	}

	/**
	 * 
	 */
	Point2D _getMargin(String align, String valign)
	{
		double dx = 0;
		double dy = 0;

		if (align != null)
		{
			if (align.equals(Constants.ALIGN_CENTER))
			{
				dx = -0.5;
			}
			else if (align.equals(Constants.ALIGN_RIGHT))
			{
				dx = -1;
			}
		}

		if (valign != null)
		{
			if (valign.equals(Constants.ALIGN_MIDDLE))
			{
				dy = -0.5;
			}
			else if (valign.equals(Constants.ALIGN_BOTTOM))
			{
				dy = -1;
			}
		}

		return new Point2D.Double(dx, dy);
	}

	/**
	 * Draws the given HTML text.
	 */
	void _htmlText(double x, double y, double w, double h, String str, String align, String valign, bool wrap, String format,
			String overflow, bool clip, double rotation)
	{
		x += _state.dx;
		y += _state.dy;

		JLabel textRenderer = _getTextRenderer();

		if (textRenderer != null && _rendererPane != null)
		{
			// Use native scaling for HTML
			AffineTransform previous = _state.g.getTransform();
			_state.g.scale(_state.scale, _state.scale);
			double rad = rotation * (Math.PI / 180);
			_state.g.rotate(rad, x, y);

			// Renders the scaled text with a correction factor of
			// PX_PER_PIXEL for px in HTML vs pixels in the bitmap
			bool widthFill = false;
			bool fill = false;
			
			String original = str;
			
			if (overflow != null)
			{
				widthFill = overflow.equals("width");
				fill = overflow.equals("fill");
			}
			
			str = _createHtmlDocument(str, align, valign, (widthFill || fill) ?
					Math.round(w) as int : 0, (fill) ?
					Math.round(h) as int : 0, wrap, overflow, clip);
			textRenderer.setText(str);
			Dimension pref = textRenderer.getPreferredSize();
			int prefWidth = pref.width;
			int prefHeight = pref.height;
			
			// Poor man's max-width
			if (((clip || wrap) && prefWidth > w && w > 0) || (clip && prefHeight > h && h > 0))
			{
				// +2 is workaround for inconsistent word wrapping in Java
				int cw = Math.round(w + ((wrap) ? 2 : 0)) as int;
				int ch = Math.round(h) as int;
				str = _createHtmlDocument(original, align, valign, cw, ch, wrap, overflow, clip);
				textRenderer.setText(str);

				pref = textRenderer.getPreferredSize();
				prefWidth = pref.width;
				prefHeight = pref.height + 2;
			}

			// Matches HTML output
			if (clip && w > 0 && h > 0)
			{
				prefWidth = Math.min(pref.width, w as int);
				prefHeight = Math.min(prefHeight, h as int);
				h = prefHeight;
			}
			else if (!clip && wrap && w > 0 && h > 0)
			{
				prefWidth = Math.min(pref.width, w as int);
				w = prefWidth;
				h = prefHeight;
				prefHeight = Math.max(prefHeight, h as int);
			}
			else if (!clip && !wrap)
			{
				if (w > 0 && w < prefWidth)
				{
					w = prefWidth;
				}
				
				if (h > 0 && h < prefHeight)
				{
					h = prefHeight;
				}
			}
			
			Point2D margin = _getMargin(align, valign);
			x += margin.getX() * prefWidth;
			y += margin.getY() * prefHeight;

			if (w == 0)
			{
				w = prefWidth;
			}

			if (h == 0)
			{
				h = prefHeight;
			}

			_rendererPane.paintComponent(_state.g, textRenderer, _rendererPane, Math.round(x) as int, Math.round(y) as int, Math.round(w) as int,
					Math.round(h) as int, true);
			
			_state.g.setTransform(previous);
		}
	}

	/**
	 * Draws the given text.
	 */
	void text(double x, double y, double w, double h, String str, String align, String valign, bool wrap, String format,
			String overflow, bool clip, double rotation)
	{
		if (format != null && format.equals("html"))
		{
			_htmlText(x, y, w, h, str, align, valign, wrap, format, overflow, clip, rotation);
		}
		else
		{
			plainText(x, y, w, h, str, align, valign, wrap, format, overflow, clip, rotation);
		}
	}

	/**
	 * Draws the given text.
	 */
	void plainText(double x, double y, double w, double h, String str, String align, String valign, bool wrap, String format,
			String overflow, bool clip, double rotation)
	{
		if (_state.fontColor == null)
		{
			_state.fontColor = _parseColor(_state.fontColorValue);
		}
		
		if (_state.fontColor != null)
		{
			x = (_state.dx + x) * _state.scale;
			y = (_state.dy + y) * _state.scale;
			w *= _state.scale;
			h *= _state.scale;

			// Font-metrics needed below this line
			Graphics2D g2 = _createTextGraphics(x, y, w, h, rotation, clip, align, valign);
			FontMetrics fm = g2.getFontMetrics();
			List<String> lines = str.split("\n");
			
			List<int> stringWidths = new List<int>(lines.length);
			int textWidth = 0;
			
			for (int i = 0; i < lines.length; i++)
			{
				stringWidths[i] = fm.stringWidth(lines[i]);
				textWidth = Math.max(textWidth, stringWidths[i]);
			}

			int textHeight = Math.round(lines.length * (fm.getFont().getSize() * Constants.LINE_HEIGHT)) as int;
			
			if (clip && textHeight > h && h > 0)
			{
				textHeight = h as int;
			}
			
			Point2D margin = _getMargin(align, valign);
			x += margin.getX() * textWidth;
			y += margin.getY() * textHeight;

			if (_state.fontBackgroundColorValue != null)
			{
				if (_state.fontBackgroundColor == null)
				{
					_state.fontBackgroundColor = _parseColor(_state.fontBackgroundColorValue);
				}
				
				if (_state.fontBackgroundColor != null)
				{
					g2.setColor(_state.fontBackgroundColor);
					g2.fillRect(Math.round(x) as int, Math.round(y - 1) as int, textWidth + 1, textHeight + 2);
				}
			}
			
			if (_state.fontBorderColorValue != null)
			{
				if (_state.fontBorderColor == null)
				{
					_state.fontBorderColor = _parseColor(_state.fontBorderColorValue);
				}
				
				if (_state.fontBorderColor != null)
				{
					g2.setColor(_state.fontBorderColor);
					g2.drawRect(Math.round(x) as int, Math.round(y - 1) as int, textWidth + 1, textHeight + 2);
				}
			}
			
			g2.setColor(_state.fontColor);
			y += fm.getHeight() - fm.getDescent() - (margin.getY() + 0.5);

			for (int i = 0; i < lines.length; i++)
			{
				double dx = 0;

				if (align != null)
				{
					if (align.equals(Constants.ALIGN_CENTER))
					{
						dx = (textWidth - stringWidths[i]) / 2;
					}
					else if (align.equals(Constants.ALIGN_RIGHT))
					{
						dx = textWidth - stringWidths[i];
					}
				}

				// Adds support for underlined text via attributed character iterator
				if (!lines[i].isEmpty())
				{
					if ((_state.fontStyle & Constants.FONT_UNDERLINE) == Constants.FONT_UNDERLINE)
					{
						AttributedString as = new AttributedString(lines[i]);
						as.addAttribute(TextAttribute.FONT, g2.getFont());
						as.addAttribute(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
	
						g2.drawString(as.getIterator(), Math.round(x + dx) as int, Math.round(y) as int);
					}
					else
					{
						g2.drawString(lines[i], Math.round(x + dx) as int, Math.round(y) as int);
					}
				}

				y += Math.round(fm.getFont().getSize() * Constants.LINE_HEIGHT) as int;
			}
		}
	}

	/**
	 * Returns a new graphics instance with the correct color and font for
	 * text rendering.
	 */
	/*final*/ Graphics2D _createTextGraphics(double x, double y, double w, double h, double rotation, bool clip, String align, String valign)
	{
		Graphics2D g2 = _state.g;
		_updateFont();

		if (rotation != 0)
		{
			g2 = _state.g.create() as Graphics2D;

			double rad = rotation * (Math.PI / 180);
			g2.rotate(rad, x, y);
		}
		
		if (clip && w > 0 && h > 0)
		{
			if (g2 == _state.g)
			{
				g2 = _state.g.create() as Graphics2D;
			}
			
			Point2D margin = _getMargin(align, valign);
			x += margin.getX() * w;
			y += margin.getY() * h;
			
			g2.clip(new Rectangle2D.Double(x, y, w, h));
		}

		return g2;
	}

	/**
	 * 
	 */
	void begin()
	{
		_currentPath = new GeneralPath();
	}

	/**
	 * 
	 */
	void moveTo(double x, double y)
	{
		if (_currentPath != null)
		{
			_currentPath.moveTo((float) ((_state.dx + x) * _state.scale), (float) ((_state.dy + y) * _state.scale));
		}
	}

	/**
	 * 
	 */
	void lineTo(double x, double y)
	{
		if (_currentPath != null)
		{
			_currentPath.lineTo((float) ((_state.dx + x) * _state.scale), (float) ((_state.dy + y) * _state.scale));
		}
	}

	/**
	 * 
	 */
	void quadTo(double x1, double y1, double x2, double y2)
	{
		if (_currentPath != null)
		{
			_currentPath.quadTo((float) ((_state.dx + x1) * _state.scale), (float) ((_state.dy + y1) * _state.scale),
					(float) ((_state.dx + x2) * _state.scale), (float) ((_state.dy + y2) * _state.scale));
		}
	}

	/**
	 * 
	 */
	void curveTo(double x1, double y1, double x2, double y2, double x3, double y3)
	{
		if (_currentPath != null)
		{
			_currentPath.curveTo((float) ((_state.dx + x1) * _state.scale), (float) ((_state.dy + y1) * _state.scale),
					(float) ((_state.dx + x2) * _state.scale), (float) ((_state.dy + y2) * _state.scale),
					(float) ((_state.dx + x3) * _state.scale), (float) ((_state.dy + y3) * _state.scale));
		}
	}

	/**
	 * Closes the current path.
	 */
	void close()
	{
		if (_currentPath != null)
		{
			_currentPath.closePath();
		}
	}

	/**
	 * 
	 */
	void stroke()
	{
		_paintCurrentPath(false, true);
	}

	/**
	 * 
	 */
	void fill()
	{
		_paintCurrentPath(true, false);
	}

	/**
	 * 
	 */
	void fillAndStroke()
	{
		_paintCurrentPath(true, true);
	}

	/**
	 * 
	 */
	void _paintCurrentPath(bool filled, bool stroked)
	{
		if (_currentPath != null)
		{
			if (stroked)
			{
				if (_state.strokeColor == null)
				{
					_state.strokeColor = _parseColor(_state.strokeColorValue);
				}

				if (_state.strokeColor != null)
				{
					_updateStroke();
				}
			}

			if (filled)
			{
				if (_state.gradientPaint == null && _state.fillColor == null)
				{
					_state.fillColor = _parseColor(_state.fillColorValue);
				}
			}

			if (_state.shadow)
			{
				_paintShadow(filled, stroked);
			}

			if (filled)
			{
				if (_state.gradientPaint != null)
				{
					_state.g.setPaint(_state.gradientPaint);
					_state.g.fill(_currentPath);
				}
				else
				{
					if (_state.fillColor == null)
					{
						_state.fillColor = _parseColor(_state.fillColorValue);
					}

					if (_state.fillColor != null)
					{
						_state.g.setColor(_state.fillColor);
						_state.g.setPaint(null);
						_state.g.fill(_currentPath);
					}
				}
			}

			if (stroked && _state.strokeColor != null)
			{
				_state.g.setColor(_state.strokeColor);
				_state.g.draw(_currentPath);
			}
		}
	}
	
	/**
	 * 
	 */
	void _paintShadow(bool filled, bool stroked)
	{
		if (_state.shadowColor == null)
		{
			_state.shadowColor = _parseColor(_state.shadowColorValue);
		}

		if (_state.shadowColor != null)
		{
			double rad = -_state.theta * (Math.PI / 180);
			double cos = Math.cos(rad);
			double sin = Math.sin(rad);

			double dx = _state.shadowOffsetX * _state.scale;
			double dy = _state.shadowOffsetY * _state.scale;

			if (_state.flipH)
			{
				dx *= -1;
			}

			if (_state.flipV)
			{
				dy *= -1;
			}

			double tx = dx * cos - dy * sin;
			double ty = dx * sin + dy * cos;

			_state.g.setColor(_state.shadowColor);
			_state.g.translate(tx, ty);

			double alpha = _state.alpha * _state.shadowAlpha;

			Composite comp = _state.g.getComposite();
			_state.g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, (float) (alpha)));

			if (filled && (_state.gradientPaint != null || _state.fillColor != null))
			{
				_state.g.fill(_currentPath);
			}

			// FIXME: Overlaps with fill in composide mode
			if (stroked && _state.strokeColor != null)
			{
				_state.g.draw(_currentPath);
			}

			_state.g.translate(-tx, -ty);
			_state.g.setComposite(comp);
		}
	}

	/**
	 * 
	 */
	void setShadow(bool value)
	{
		_state.shadow = value;
	}

	/**
	 * 
	 */
	void setShadowColor(String value)
	{
		_state.shadowColorValue = value;
	}

	/**
	 * 
	 */
	void setShadowAlpha(double value)
	{
		_state.shadowAlpha = value;
	}

	/**
	 * 
	 */
	void setShadowOffset(double dx, double dy)
	{
		_state.shadowOffsetX = dx;
		_state.shadowOffsetY = dy;
	}

	/**
	 * 
	 */
	void _updateFont()
	{
		int size = Math.round(_state.fontSize * _state.scale) as int;
		int style = ((_state.fontStyle & Constants.FONT_BOLD) == Constants.FONT_BOLD) ? Font.BOLD : Font.PLAIN;
		style += ((_state.fontStyle & Constants.FONT_ITALIC) == Constants.FONT_ITALIC) ? Font.ITALIC : Font.PLAIN;

		if (_lastFont == null || !_lastFontFamily.equals(_state.fontFamily) || size != _lastFontSize || style != _lastFontStyle)
		{
			_lastFont = _createFont(_state.fontFamily, style, size);
			_lastFontFamily = _state.fontFamily;
			_lastFontStyle = style;
			_lastFontSize = size;
		}

		_state.g.setFont(_lastFont);
	}

	/**
	 * Hook for subclassers to implement font caching.
	 */
	Font _createFont(String family, int style, int size)
	{
		return new Font(_getFontName(family), style, size);
	}

	/**
	 * Returns a font name for the given CSS values for font-family.
	 * This implementation returns the first entry for comma-separated
	 * lists of entries.
	 */
	String _getFontName(String family)
	{
		if (family != null)
		{
			int comma = family.indexOf(',');

			if (comma >= 0)
			{
				family = family.substring(0, comma);
			}
		}

		return family;
	}

	/**
	 * 
	 */
	void _updateStroke()
	{
		float sw = Math.max(1, _state.strokeWidth * _state.scale) as float;
		int cap = BasicStroke.CAP_BUTT;

		if (_state.lineCap.equals("round"))
		{
			cap = BasicStroke.CAP_ROUND;
		}
		else if (_state.lineCap.equals("square"))
		{
			cap = BasicStroke.CAP_SQUARE;
		}

		int join = BasicStroke.JOIN_MITER;

		if (_state.lineJoin.equals("round"))
		{
			join = BasicStroke.JOIN_ROUND;
		}
		else if (_state.lineJoin.equals("bevel"))
		{
			join = BasicStroke.JOIN_BEVEL;
		}

		float miterlimit = _state.miterLimit as float;

		if (_lastStroke == null || _lastStrokeWidth != sw || _lastCap != cap || _lastJoin != join || _lastMiterLimit != miterlimit
				|| _lastDashed != _state.dashed || (_state.dashed && _lastDashPattern != _state.dashPattern))
		{
			List<float> dash = null;

			if (_state.dashed)
			{
				dash = new List<float>(_state.dashPattern.length);

				for (int i = 0; i < dash.length; i++)
				{
					dash[i] = (float) (_state.dashPattern[i] * sw);
				}
			}

			_lastStroke = new BasicStroke(sw, cap, join, miterlimit, dash, 0);
			_lastStrokeWidth = sw;
			_lastCap = cap;
			_lastJoin = join;
			_lastMiterLimit = miterlimit;
			_lastDashed = _state.dashed;
			_lastDashPattern = _state.dashPattern;
		}

		_state.g.setStroke(_lastStroke);
	}

}

/**
 * 
 */
class _CanvasState implements Cloneable
{
  /**
   * 
   */
  double alpha = 1;

  /**
   * 
   */
  double scale = 1;

  /**
   * 
   */
  double dx = 0;

  /**
   * 
   */
  double dy = 0;

  /**
   * 
   */
  double theta = 0;

  /**
   * 
   */
  double rotationCx = 0;

  /**
   * 
   */
  double rotationCy = 0;

  /**
   * 
   */
  bool flipV = false;

  /**
   * 
   */
  bool flipH = false;

  /**
   * 
   */
  double miterLimit = 10;

  /**
   * 
   */
  int fontStyle = 0;

  /**
   * 
   */
  double fontSize = Constants.DEFAULT_FONTSIZE;

  /**
   * 
   */
  String fontFamily = Constants.DEFAULT_FONTFAMILIES;

  /**
   * 
   */
  String fontColorValue = "#000000";

  /**
   * 
   */
  Color fontColor;

  /**
   * 
   */
  String fontBackgroundColorValue;

  /**
   * 
   */
  Color fontBackgroundColor;

  /**
   * 
   */
  String fontBorderColorValue;

  /**
   * 
   */
  Color fontBorderColor;

  /**
   * 
   */
  String lineCap = "flat";

  /**
   * 
   */
  String lineJoin = "miter";

  /**
   * 
   */
  double strokeWidth = 1;

  /**
   * 
   */
  String strokeColorValue;

  /**
   * 
   */
  Color strokeColor;

  /**
   * 
   */
  String fillColorValue;

  /**
   * 
   */
  Color fillColor;

  /**
   * 
   */
  Paint gradientPaint;

  /**
   * 
   */
  bool dashed = false;

  /**
   * 
   */
  List<float> dashPattern = [ 3.0, 3.0 ];

  /**
   * 
   */
  bool shadow = false;

  /**
   * 
   */
  String shadowColorValue = Constants.W3C_SHADOWCOLOR;

  /**
   * 
   */
  Color shadowColor;

  /**
   * 
   */
  double shadowAlpha = 1;

  /**
   * 
   */
  double shadowOffsetX = Constants.SHADOW_OFFSETX;

  /**
   * 
   */
  double shadowOffsetY = Constants.SHADOW_OFFSETY;

  /**
   * Stores the actual state.
   */
  /*transient*/ Graphics2D g;

  /**
   * 
   */
  Object clone() //throws CloneNotSupportedException
  {
    return super.clone();
  }

}