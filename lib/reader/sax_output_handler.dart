part of graph.reader;


//import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
//import org.xml.sax.helpers.DefaultHandler;

//typedef void IElementHandler(Attributes atts);

/**
	XMLReader reader = SAXParserFactory.newInstance().newSAXParser()
			.getXMLReader();
	reader.setContentHandler(new SaxExportHandler(
			new GraphicsExportCanvas(g2)));
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
  /*transient*/ Map<String, IElementHandler> _handlers = new Map<String, IElementHandler>();

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
    IElementHandler handler = _handlers[qName.toLowerCase()];

    if (handler != null) {
      handler(atts);
    }
  }

  /**
   * 
   */
  void _initHandlers() {
    _handlers["save"] = (Attributes atts) {
      _canvas.save();
    };

    _handlers["restore"] = (Attributes atts) {
      _canvas.restore();
    };

    _handlers["scale"] = (Attributes atts) {
      _canvas.scale(double.parse(atts.getValue("scale")));
    };

    _handlers["translate"] = (Attributes atts) {
      _canvas.translate(double.parse(atts.getValue("dx")), double.parse(atts.getValue("dy")));
    };

    _handlers["rotate"] = (Attributes atts) {
      _canvas.rotate(double.parse(atts.getValue("theta")), atts.getValue("flipH") == "1", atts.getValue("flipV") == "1", double.parse(atts.getValue("cx")), double.parse(atts.getValue("cy")));
    };

    _handlers["strokewidth"] = (Attributes atts) {
      _canvas.setStrokeWidth(double.parse(atts.getValue("width")));
    };

    _handlers["strokecolor"] = (Attributes atts) {
      _canvas.setStrokeColor(atts.getValue("color"));
    };

    _handlers["dashed"] = (Attributes atts) {
      _canvas.setDashed(atts.getValue("dashed") == "1");
    };

    _handlers["dashpattern"] = (Attributes atts) {
      _canvas.setDashPattern(atts.getValue("pattern"));
    };

    _handlers["linecap"] = (Attributes atts) {
      _canvas.setLineCap(atts.getValue("cap"));
    };

    _handlers["linejoin"] = (Attributes atts) {
      _canvas.setLineJoin(atts.getValue("join"));
    };

    _handlers["miterlimit"] = (Attributes atts) {
      _canvas.setMiterLimit(double.parse(atts.getValue("limit")));
    };

    _handlers["fontsize"] = (Attributes atts) {
      _canvas.setFontSize(double.parse(atts.getValue("size")));
    };

    _handlers["fontcolor"] = (Attributes atts) {
      _canvas.setFontColor(atts.getValue("color"));
    };

    _handlers["fontbackgroundcolor"] = (Attributes atts) {
      _canvas.setFontBackgroundColor(atts.getValue("color"));
    };

    _handlers["fontbordercolor"] = (Attributes atts) {
      _canvas.setFontBorderColor(atts.getValue("color"));
    };

    _handlers["fontfamily"] = (Attributes atts) {
      _canvas.setFontFamily(atts.getValue("family"));
    };

    _handlers["fontstyle"] = (Attributes atts) {
      _canvas.setFontStyle(int.parse(atts.getValue("style")));
    };

    _handlers["alpha"] = (Attributes atts) {
      _canvas.setAlpha(double.parse(atts.getValue("alpha")));
    };

    _handlers["fillcolor"] = (Attributes atts) {
      _canvas.setFillColor(atts.getValue("color"));
    };

    _handlers["shadowcolor"] = (Attributes atts) {
      _canvas.setShadowColor(atts.getValue("color"));
    };

    _handlers["shadowalpha"] = (Attributes atts) {
      _canvas.setShadowAlpha(double.parse(atts.getValue("alpha")));
    };

    _handlers["shadowoffset"] = (Attributes atts) {
      _canvas.setShadowOffset(double.parse(atts.getValue("dx")), double.parse(atts.getValue("dy")));
    };

    _handlers["shadow"] = (Attributes atts) {
      _canvas.setShadow(_getValue(atts, "enabled", "1") == "1");
    };

    _handlers["gradient"] = (Attributes atts) {
      _canvas.setGradient(atts.getValue("c1"), atts.getValue("c2"), double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")), atts.getValue("direction"), double.parse(_getValue(atts, "alpha1", "1")), double.parse(_getValue(atts, "alpha2", "1")));
    };

    _handlers["rect"] = (Attributes atts) {
      _canvas.rect(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")));
    };

    _handlers["roundrect"] = (Attributes atts) {
      _canvas.roundrect(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")), double.parse(atts.getValue("dx")), double.parse(atts.getValue("dy")));
    };

    _handlers["ellipse"] = (Attributes atts) {
      _canvas.ellipse(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")));
    };

    _handlers["image"] = (Attributes atts) {
      _canvas.image(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")), atts.getValue("src"), atts.getValue("aspect") == "1", atts.getValue("flipH") == "1", atts.getValue("flipV") == "1");
    };

    _handlers["text"] = (Attributes atts) {
      _canvas.text(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")), double.parse(atts.getValue("w")), double.parse(atts.getValue("h")), atts.getValue("str"), atts.getValue("align"), atts.getValue("valign"), _getValue(atts, "wrap", "") == "1", atts.getValue("format"), atts.getValue("overflow"), _getValue(atts, "clip", "") == "1", double.parse(_getValue(atts, "rotation", "0")));
    };

    _handlers["begin"] = (Attributes atts) {
      _canvas.begin();
    };

    _handlers["move"] = (Attributes atts) {
      _canvas.moveTo(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")));
    };

    _handlers["line"] = (Attributes atts) {
      _canvas.lineTo(double.parse(atts.getValue("x")), double.parse(atts.getValue("y")));
    };

    _handlers["quad"] = (Attributes atts) {
      _canvas.quadTo(double.parse(atts.getValue("x1")), double.parse(atts.getValue("y1")), double.parse(atts.getValue("x2")), double.parse(atts.getValue("y2")));
    };

    _handlers["curve"] = (Attributes atts) {
      _canvas.curveTo(double.parse(atts.getValue("x1")), double.parse(atts.getValue("y1")), double.parse(atts.getValue("x2")), double.parse(atts.getValue("y2")), double.parse(atts.getValue("x3")), double.parse(atts.getValue("y3")));
    };

    _handlers["close"] = (Attributes atts) {
      _canvas.close();
    };

    _handlers["stroke"] = (Attributes atts) {
      _canvas.stroke();
    };

    _handlers["fill"] = (Attributes atts) {
      _canvas.fill();
    };

    _handlers["fillstroke"] = (Attributes atts) {
      _canvas.fillAndStroke();
    };
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
