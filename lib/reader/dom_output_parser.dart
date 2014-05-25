part of graph.reader;

//import java.util.Hashtable;
//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;
//import org.xml.sax.Attributes;

/**
 *
	static void main(List<String> args)
	{
		try
		{
			String filename = Test.class.getResource(
					"/com/mxgraph/online/exported.xml").getPath();
			String xml = Utils.readFile(filename);
			System.out.println("xml=" + xml);

			Document doc = Utils.parseXml(xml);
			Element root = doc.getDocumentElement();
			int width = Integer.parseInt(root.getAttribute("width"));
			int height = Integer.parseInt(root.getAttribute("height"));

			System.out.println("width=" + width + " height=" + height);

			BufferedImage img = Utils.createBufferedImage(width, height,
					Color.WHITE);
			Graphics2D g2 = img.createGraphics();
			Utils.setAntiAlias(g2, true, true);
			DomOutputParser reader = new DomOutputParser(
					new mxGraphicsExportCanvas(g2));
			reader.read((Element) root.getFirstChild().getNextSibling());

			ImageIO.write(img, "PNG", new File(
					"C:\\Users\\Gaudenz\\Desktop\\test.png"));
		}
		on Exception catch (e)
		{
			e.printStackTrace();
		}
	}
	
	// -------------
	
	Document doc = Utils.parseXml(xml);
	Element root = doc.getDocumentElement();
	DomOutputParser reader = new DomOutputParser(canvas);
	reader.read(root.getFirstChild());
 */
class DomOutputParser
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
	DomOutputParser(ICanvas2D canvas)
	{
		this._canvas = canvas;
		_initHandlers();
	}

	/**
	 * 
	 */
	void read(Node node)
	{
		while (node != null)
		{
			if (node is Element)
			{
				Element elt = (Element) node;
				IElementHandler handler = _handlers.get(elt.getNodeName());

				if (handler != null)
				{
					handler.parseElement(elt);
				}
			}

			node = node.getNextSibling();
		}
	}

	/**
	 * 
	 */
	void _initHandlers()
	{
		_handlers.put("save", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.save();
			}
		});

		_handlers.put("restore", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.restore();
			}
		});

		_handlers.put("scale", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.scale(Double.parseDouble(elt.getAttribute("scale")));
			}
		});

		_handlers.put("translate", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.translate(Double.parseDouble(elt.getAttribute("dx")),
						Double.parseDouble(elt.getAttribute("dy")));
			}
		});

		_handlers.put("rotate", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.rotate(Double.parseDouble(elt.getAttribute("theta")),
						elt.getAttribute("flipH").equals("1"), elt
								.getAttribute("flipV").equals("1"), Double
								.parseDouble(elt.getAttribute("cx")), Double
								.parseDouble(elt.getAttribute("cy")));
			}
		});

		_handlers.put("strokewidth", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setStrokeWidth(Double.parseDouble(elt
						.getAttribute("width")));
			}
		});

		_handlers.put("strokecolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setStrokeColor(elt.getAttribute("color"));
			}
		});

		_handlers.put("dashed", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setDashed(elt.getAttribute("dashed").equals("1"));
			}
		});

		_handlers.put("dashpattern", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setDashPattern(elt.getAttribute("pattern"));
			}
		});

		_handlers.put("linecap", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setLineCap(elt.getAttribute("cap"));
			}
		});

		_handlers.put("linejoin", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setLineJoin(elt.getAttribute("join"));
			}
		});

		_handlers.put("miterlimit", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setMiterLimit(Double.parseDouble(elt
						.getAttribute("limit")));
			}
		});

		_handlers.put("fontsize", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontSize(Double.parseDouble(elt.getAttribute("size")));
			}
		});

		_handlers.put("fontcolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontColor(elt.getAttribute("color"));
			}
		});

		_handlers.put("fontbackgroundcolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontBackgroundColor(elt.getAttribute("color"));
			}
		});

		_handlers.put("fontbordercolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontBorderColor(elt.getAttribute("color"));
			}
		});

		_handlers.put("fontfamily", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontFamily(elt.getAttribute("family"));
			}
		});

		_handlers.put("fontstyle", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFontStyle(Integer.parseInt(elt.getAttribute("style")));
			}
		});

		_handlers.put("alpha", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setAlpha(Double.parseDouble(elt.getAttribute("alpha")));
			}
		});

		_handlers.put("fillcolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setFillColor(elt.getAttribute("color"));
			}
		});
		
		_handlers.put("shadowcolor", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setShadowColor(elt.getAttribute("color"));
			}
		});
		
		_handlers.put("shadowalpha", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setShadowAlpha(Double.parseDouble(elt.getAttribute("alpha")));
			}
		});
		
		_handlers.put("shadowoffset", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setShadowOffset(Double.parseDouble(elt.getAttribute("dx")),
						Double.parseDouble(elt.getAttribute("dy")));
			}
		});

		_handlers.put("shadow", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setShadow(elt.getAttribute("enabled").equals("1"));
			}
		});
		
		_handlers.put("gradient", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.setGradient(elt.getAttribute("c1"),
						elt.getAttribute("c2"),
						Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")),
						Double.parseDouble(elt.getAttribute("w")),
						Double.parseDouble(elt.getAttribute("h")),
						elt.getAttribute("direction"),
						Double.parseDouble(_getValue(elt, "alpha1", "1")),
						Double.parseDouble(_getValue(elt, "alpha2", "1")));
			}
		});

		_handlers.put("rect", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.rect(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")),
						Double.parseDouble(elt.getAttribute("w")),
						Double.parseDouble(elt.getAttribute("h")));
			}
		});

		_handlers.put("roundrect", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.roundrect(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")),
						Double.parseDouble(elt.getAttribute("w")),
						Double.parseDouble(elt.getAttribute("h")),
						Double.parseDouble(elt.getAttribute("dx")),
						Double.parseDouble(elt.getAttribute("dy")));
			}
		});

		_handlers.put("ellipse", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.ellipse(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")),
						Double.parseDouble(elt.getAttribute("w")),
						Double.parseDouble(elt.getAttribute("h")));
			}
		});

		_handlers.put("image", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.image(Double.parseDouble(elt.getAttribute("x")), Double
						.parseDouble(elt.getAttribute("y")), Double
						.parseDouble(elt.getAttribute("w")), Double
						.parseDouble(elt.getAttribute("h")), elt
						.getAttribute("src"), elt.getAttribute("aspect")
						.equals("1"), elt.getAttribute("flipH").equals("1"),
						elt.getAttribute("flipV").equals("1"));
			}
		});

		_handlers.put("text", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.text(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")),
						Double.parseDouble(elt.getAttribute("w")),
						Double.parseDouble(elt.getAttribute("h")),
						elt.getAttribute("str"),
						elt.getAttribute("align"),
						elt.getAttribute("valign"),
						_getValue(elt, "wrap", "").equals("1"),
						elt.getAttribute("format"),
						elt.getAttribute("overflow"),
						_getValue(elt, "clip", "").equals("1"),
						Double.parseDouble(_getValue(elt, "rotation", "0")));
			}
		});

		_handlers.put("begin", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.begin();
			}
		});

		_handlers.put("move", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.moveTo(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")));
			}
		});

		_handlers.put("line", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.lineTo(Double.parseDouble(elt.getAttribute("x")),
						Double.parseDouble(elt.getAttribute("y")));
			}
		});

		_handlers.put("quad", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.quadTo(Double.parseDouble(elt.getAttribute("x1")),
						Double.parseDouble(elt.getAttribute("y1")),
						Double.parseDouble(elt.getAttribute("x2")),
						Double.parseDouble(elt.getAttribute("y2")));
			}
		});

		_handlers.put("curve", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.curveTo(Double.parseDouble(elt.getAttribute("x1")),
						Double.parseDouble(elt.getAttribute("y1")),
						Double.parseDouble(elt.getAttribute("x2")),
						Double.parseDouble(elt.getAttribute("y2")),
						Double.parseDouble(elt.getAttribute("x3")),
						Double.parseDouble(elt.getAttribute("y3")));
			}
		});

		_handlers.put("close", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.close();
			}
		});

		_handlers.put("stroke", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.stroke();
			}
		});

		_handlers.put("fill", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.fill();
			}
		});

		_handlers.put("fillstroke", new IElementHandler()
		{
			public void parseElement(Element elt)
			{
				_canvas.fillAndStroke();
			}
		});
	}

	/**
	 * Returns the given attribute value or an empty string.
	 */
	String _getValue(Element elt, String name, String defaultValue)
	{
		String value = elt.getAttribute(name);

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
		void parseElement(Element elt);
	}

}
