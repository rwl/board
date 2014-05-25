part of graph.reader;

//import java.util.Hashtable;
//import java.util.Map;

//import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
//import org.xml.sax.helpers.DefaultHandler;

/**
	XMLReader reader = SAXParserFactory.newInstance().newSAXParser()
			.getXMLReader();
	reader.setContentHandler(new mxSaxExportHandler(
			new mxGraphicsExportCanvas(g2)));
	reader.parse(new InputSource(new StringReader(xml)));
 */
class SaxOutputHandler extends DefaultHandler
{
	/**
	 * 
	 */
	ICanvas2D _canvas;

	/**
	 * 
	 */
	/*transient*/ Map<String, IElementHandler> _handlers = new Hashtable<String, IElementHandler>();

	/**
	 * 
	 */
	SaxOutputHandler(ICanvas2D canvas)
	{
		setCanvas(canvas);
		_initHandlers();
	}

	/**
	 * Sets the canvas for rendering.
	 */
	void setCanvas(ICanvas2D value)
	{
		_canvas = value;
	}

	/**
	 * Returns the canvas for rendering.
	 */
	ICanvas2D getCanvas()
	{
		return _canvas;
	}

	/**
	 * 
	 */
	void startElement(String uri, String localName, String qName,
			Attributes atts) //throws SAXException
	{
		IElementHandler handler = _handlers.get(qName.toLowerCase());

		if (handler != null)
		{
			handler.parseElement(atts);
		}
	}

	/**
	 * 
	 */
	void _initHandlers()
	{
		_handlers.put("save", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.save();
			}
		});

		_handlers.put("restore", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.restore();
			}
		});

		_handlers.put("scale", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.scale(Double.parseDouble(atts.getValue("scale")));
			}
		});

		_handlers.put("translate", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.translate(Double.parseDouble(atts.getValue("dx")),
						Double.parseDouble(atts.getValue("dy")));
			}
		});

		_handlers.put("rotate", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.rotate(Double.parseDouble(atts.getValue("theta")), atts
						.getValue("flipH").equals("1"), atts.getValue("flipV")
						.equals("1"), Double.parseDouble(atts.getValue("cx")),
						Double.parseDouble(atts.getValue("cy")));
			}
		});

		_handlers.put("strokewidth", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setStrokeWidth(Double.parseDouble(atts.getValue("width")));
			}
		});

		_handlers.put("strokecolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setStrokeColor(atts.getValue("color"));
			}
		});

		_handlers.put("dashed", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setDashed(atts.getValue("dashed").equals("1"));
			}
		});

		_handlers.put("dashpattern", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setDashPattern(atts.getValue("pattern"));
			}
		});

		_handlers.put("linecap", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setLineCap(atts.getValue("cap"));
			}
		});

		_handlers.put("linejoin", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setLineJoin(atts.getValue("join"));
			}
		});

		_handlers.put("miterlimit", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setMiterLimit(Double.parseDouble(atts.getValue("limit")));
			}
		});

		_handlers.put("fontsize", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontSize(Double.parseDouble(atts.getValue("size")));
			}
		});

		_handlers.put("fontcolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontColor(atts.getValue("color"));
			}
		});

		_handlers.put("fontbackgroundcolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontBackgroundColor(atts.getValue("color"));
			}
		});

		_handlers.put("fontbordercolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontBorderColor(atts.getValue("color"));
			}
		});

		_handlers.put("fontfamily", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontFamily(atts.getValue("family"));
			}
		});

		_handlers.put("fontstyle", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFontStyle(Integer.parseInt(atts.getValue("style")));
			}
		});

		_handlers.put("alpha", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setAlpha(Double.parseDouble(atts.getValue("alpha")));
			}
		});

		_handlers.put("fillcolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setFillColor(atts.getValue("color"));
			}
		});
		
		_handlers.put("shadowcolor", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setShadowColor(atts.getValue("color"));
			}
		});
		
		_handlers.put("shadowalpha", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setShadowAlpha(Double.parseDouble(atts.getValue("alpha")));
			}
		});
		
		_handlers.put("shadowoffset", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setShadowOffset(Double.parseDouble(atts.getValue("dx")),
						Double.parseDouble(atts.getValue("dy")));
			}
		});

		_handlers.put("shadow", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setShadow(_getValue(atts, "enabled", "1").equals("1"));
			}
		});
		
		_handlers.put("gradient", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.setGradient(atts.getValue("c1"), atts.getValue("c2"),
						Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")),
						atts.getValue("direction"),
						Double.parseDouble(_getValue(atts, "alpha1", "1")),
						Double.parseDouble(_getValue(atts, "alpha2", "1")));
			}
		});

		_handlers.put("rect", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.rect(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")));
			}
		});

		_handlers.put("roundrect", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.roundrect(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")),
						Double.parseDouble(atts.getValue("dx")),
						Double.parseDouble(atts.getValue("dy")));
			}
		});

		_handlers.put("ellipse", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.ellipse(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")));
			}
		});

		_handlers.put("image", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.image(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")),
						atts.getValue("src"),
						atts.getValue("aspect").equals("1"),
						atts.getValue("flipH").equals("1"),
						atts.getValue("flipV").equals("1"));
			}
		});

		_handlers.put("text", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.text(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")),
						Double.parseDouble(atts.getValue("w")),
						Double.parseDouble(atts.getValue("h")),
						atts.getValue("str"),
						atts.getValue("align"),
						atts.getValue("valign"),
						_getValue(atts, "wrap", "").equals("1"),
						atts.getValue("format"),
						atts.getValue("overflow"),
						_getValue(atts, "clip", "").equals("1"),
						Double.parseDouble(_getValue(atts, "rotation", "0")));
			}
		});

		_handlers.put("begin", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.begin();
			}
		});

		_handlers.put("move", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.moveTo(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")));
			}
		});

		_handlers.put("line", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.lineTo(Double.parseDouble(atts.getValue("x")),
						Double.parseDouble(atts.getValue("y")));
			}
		});

		_handlers.put("quad", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.quadTo(Double.parseDouble(atts.getValue("x1")),
						Double.parseDouble(atts.getValue("y1")),
						Double.parseDouble(atts.getValue("x2")),
						Double.parseDouble(atts.getValue("y2")));
			}
		});

		_handlers.put("curve", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.curveTo(Double.parseDouble(atts.getValue("x1")),
						Double.parseDouble(atts.getValue("y1")),
						Double.parseDouble(atts.getValue("x2")),
						Double.parseDouble(atts.getValue("y2")),
						Double.parseDouble(atts.getValue("x3")),
						Double.parseDouble(atts.getValue("y3")));
			}
		});

		_handlers.put("close", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.close();
			}
		});

		_handlers.put("stroke", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.stroke();
			}
		});

		_handlers.put("fill", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.fill();
			}
		});

		_handlers.put("fillstroke", new IElementHandler()
		{
			public void parseElement(Attributes atts)
			{
				_canvas.fillAndStroke();
			}
		});
	}

	/**
	 * Returns the given attribute value or an empty string.
	 */
	String _getValue(Attributes atts, String name, String defaultValue)
	{
		String value = atts.getValue(name);

		if (value == null)
		{
			value = defaultValue;
		}

		return value;
	};

	/**
	 * 
	 */
	interface IElementHandler
	{
		void parseElement(Attributes atts);
	}

}
