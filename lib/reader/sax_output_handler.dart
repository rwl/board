part of graph.reader;

//import java.util.Hashtable;
//import java.util.Map;

//import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
//import org.xml.sax.helpers.DefaultHandler;

//typedef void IElementHandler(Attributes atts);

/**
	XMLReader reader = SAXParserFactory.newInstance().newSAXParser()
			.getXMLReader();
	reader.setContentHandler(new mxSaxExportHandler(
			new mxGraphicsExportCanvas(g2)));
	reader.parse(new InputSource(new StringReader(xml)));
 */
class SaxOutputHandler extends DefaultHandler {
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
  SaxOutputHandler(ICanvas2D canvas) {
    setCanvas(canvas);
    _initHandlers();
  }

  /**
	 * Sets the canvas for rendering.
	 */
  void setCanvas(ICanvas2D value) {
    _canvas = value;
  }

  /**
	 * Returns the canvas for rendering.
	 */
  ICanvas2D getCanvas() {
    return _canvas;
  }

  /**
	 * 
	 */
  void startElement(String uri, String localName, String qName, Attributes atts) //throws SAXException
  {
    IElementHandler handler = _handlers.get(qName.toLowerCase());

    if (handler != null) {
      handler.parseElement(atts);
    }
  }

  /**
	 * 
	 */
  void _initHandlers() {
    _handlers.put("save", (Attributes atts) {
      _canvas.save();
    });

    _handlers.put("restore", (Attributes atts) {
      _canvas.restore();
    });

    _handlers.put("scale", (Attributes atts) {
      _canvas.scale(Double.parseDouble(atts.getValue("scale")));
    });

    _handlers.put("translate", (Attributes atts) {
      _canvas.translate(Double.parseDouble(atts.getValue("dx")), Double.parseDouble(atts.getValue("dy")));
    });

    _handlers.put("rotate", (Attributes atts) {
      _canvas.rotate(Double.parseDouble(atts.getValue("theta")), atts.getValue("flipH").equals("1"), atts.getValue("flipV").equals("1"), Double.parseDouble(atts.getValue("cx")), Double.parseDouble(atts.getValue("cy")));
    });

    _handlers.put("strokewidth", (Attributes atts) {
      _canvas.setStrokeWidth(Double.parseDouble(atts.getValue("width")));
    });

    _handlers.put("strokecolor", (Attributes atts) {
      _canvas.setStrokeColor(atts.getValue("color"));
    });

    _handlers.put("dashed", (Attributes atts) {
      _canvas.setDashed(atts.getValue("dashed").equals("1"));
    });

    _handlers.put("dashpattern", (Attributes atts) {
      _canvas.setDashPattern(atts.getValue("pattern"));
    });

    _handlers.put("linecap", (Attributes atts) {
      _canvas.setLineCap(atts.getValue("cap"));
    });

    _handlers.put("linejoin", (Attributes atts) {
      _canvas.setLineJoin(atts.getValue("join"));
    });

    _handlers.put("miterlimit", (Attributes atts) {
      _canvas.setMiterLimit(Double.parseDouble(atts.getValue("limit")));
    });

    _handlers.put("fontsize", (Attributes atts) {
      _canvas.setFontSize(Double.parseDouble(atts.getValue("size")));
    });

    _handlers.put("fontcolor", (Attributes atts) {
      _canvas.setFontColor(atts.getValue("color"));
    });

    _handlers.put("fontbackgroundcolor", (Attributes atts) {
      _canvas.setFontBackgroundColor(atts.getValue("color"));
    });

    _handlers.put("fontbordercolor", (Attributes atts) {
      _canvas.setFontBorderColor(atts.getValue("color"));
    });

    _handlers.put("fontfamily", (Attributes atts) {
      _canvas.setFontFamily(atts.getValue("family"));
    });

    _handlers.put("fontstyle", (Attributes atts) {
      _canvas.setFontStyle(int.parseInt(atts.getValue("style")));
    });

    _handlers.put("alpha", (Attributes atts) {
      _canvas.setAlpha(Double.parseDouble(atts.getValue("alpha")));
    });

    _handlers.put("fillcolor", (Attributes atts) {
      _canvas.setFillColor(atts.getValue("color"));
    });

    _handlers.put("shadowcolor", (Attributes atts) {
      _canvas.setShadowColor(atts.getValue("color"));
    });

    _handlers.put("shadowalpha", (Attributes atts) {
      _canvas.setShadowAlpha(Double.parseDouble(atts.getValue("alpha")));
    });

    _handlers.put("shadowoffset", (Attributes atts) {
      _canvas.setShadowOffset(Double.parseDouble(atts.getValue("dx")), Double.parseDouble(atts.getValue("dy")));
    });

    _handlers.put("shadow", (Attributes atts) {
      _canvas.setShadow(_getValue(atts, "enabled", "1").equals("1"));
    });

    _handlers.put("gradient", (Attributes atts) {
      _canvas.setGradient(atts.getValue("c1"), atts.getValue("c2"), Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")), atts.getValue("direction"), Double.parseDouble(_getValue(atts, "alpha1", "1")), Double.parseDouble(_getValue(atts, "alpha2", "1")));
    });

    _handlers.put("rect", (Attributes atts) {
      _canvas.rect(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")));
    });

    _handlers.put("roundrect", (Attributes atts) {
      _canvas.roundrect(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")), Double.parseDouble(atts.getValue("dx")), Double.parseDouble(atts.getValue("dy")));
    });

    _handlers.put("ellipse", (Attributes atts) {
      _canvas.ellipse(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")));
    });

    _handlers.put("image", (Attributes atts) {
      _canvas.image(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")), atts.getValue("src"), atts.getValue("aspect").equals("1"), atts.getValue("flipH").equals("1"), atts.getValue("flipV").equals("1"));
    });

    _handlers.put("text", (Attributes atts) {
      _canvas.text(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")), Double.parseDouble(atts.getValue("w")), Double.parseDouble(atts.getValue("h")), atts.getValue("str"), atts.getValue("align"), atts.getValue("valign"), _getValue(atts, "wrap", "").equals("1"), atts.getValue("format"), atts.getValue("overflow"), _getValue(atts, "clip", "").equals("1"), Double.parseDouble(_getValue(atts, "rotation", "0")));
    });

    _handlers.put("begin", (Attributes atts) {
      _canvas.begin();
    });

    _handlers.put("move", (Attributes atts) {
      _canvas.moveTo(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")));
    });

    _handlers.put("line", (Attributes atts) {
      _canvas.lineTo(Double.parseDouble(atts.getValue("x")), Double.parseDouble(atts.getValue("y")));
    });

    _handlers.put("quad", (Attributes atts) {
      _canvas.quadTo(Double.parseDouble(atts.getValue("x1")), Double.parseDouble(atts.getValue("y1")), Double.parseDouble(atts.getValue("x2")), Double.parseDouble(atts.getValue("y2")));
    });

    _handlers.put("curve", (Attributes atts) {
      _canvas.curveTo(Double.parseDouble(atts.getValue("x1")), Double.parseDouble(atts.getValue("y1")), Double.parseDouble(atts.getValue("x2")), Double.parseDouble(atts.getValue("y2")), Double.parseDouble(atts.getValue("x3")), Double.parseDouble(atts.getValue("y3")));
    });

    _handlers.put("close", (Attributes atts) {
      _canvas.close();
    });

    _handlers.put("stroke", (Attributes atts) {
      _canvas.stroke();
    });

    _handlers.put("fill", (Attributes atts) {
      _canvas.fill();
    });

    _handlers.put("fillstroke", (Attributes atts) {
      _canvas.fillAndStroke();
    });
  }

  /**
	 * Returns the given attribute value or an empty string.
	 */
  String _getValue(Attributes atts, String name, String defaultValue) {
    String value = atts.getValue(name);

    if (value == null) {
      value = defaultValue;
    }

    return value;
  }

}
