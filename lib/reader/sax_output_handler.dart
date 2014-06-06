part of graph.reader;


//import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
//import org.xml.sax.helpers.DefaultHandler;

typedef void SaxElementHandler(Map<String, String> atts);

/**
	XMLReader reader = SAXParserFactory.newInstance().newSAXParser()
			.getXMLReader();
	reader.setContentHandler(new SaxExportHandler(
			new GraphicsExportCanvas(g2)));
	reader.parse(new InputSource(new StringReader(xml)));
 */
class SaxOutputHandler extends xml.DefaultHandler {

  ICanvas2D _canvas;

  /*transient*/ Map<String, SaxElementHandler> _handlers = new Map<String, SaxElementHandler>();

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
  void startElement(String qName, Map<String, String> atts) //throws SAXException
  {
    SaxElementHandler handler = _handlers[qName.toLowerCase()];

    if (handler != null) {
      handler(atts);
    }
  }

  /**
   * 
   */
  void _initHandlers() {
    _handlers["save"] = (Map<String, String> atts) {
      _canvas.save();
    };

    _handlers["restore"] = (Map<String, String> atts) {
      _canvas.restore();
    };

    _handlers["scale"] = (Map<String, String> atts) {
      _canvas.scale(double.parse(atts["scale"]));
    };

    _handlers["translate"] = (Map<String, String> atts) {
      _canvas.translate(double.parse(atts["dx"]), double.parse(atts["dy"]));
    };

    _handlers["rotate"] = (Map<String, String> atts) {
      _canvas.rotate(double.parse(atts["theta"]), atts["flipH"] == "1", atts["flipV"] == "1", double.parse(atts["cx"]), double.parse(atts["cy"]));
    };

    _handlers["strokewidth"] = (Map<String, String> atts) {
      _canvas.setStrokeWidth(double.parse(atts["width"]));
    };

    _handlers["strokecolor"] = (Map<String, String> atts) {
      _canvas.setStrokeColor(atts["color"]);
    };

    _handlers["dashed"] = (Map<String, String> atts) {
      _canvas.setDashed(atts["dashed"] == "1");
    };

    _handlers["dashpattern"] = (Map<String, String> atts) {
      _canvas.setDashPattern(atts["pattern"]);
    };

    _handlers["linecap"] = (Map<String, String> atts) {
      _canvas.setLineCap(atts["cap"]);
    };

    _handlers["linejoin"] = (Map<String, String> atts) {
      _canvas.setLineJoin(atts["join"]);
    };

    _handlers["miterlimit"] = (Map<String, String> atts) {
      _canvas.setMiterLimit(double.parse(atts["limit"]));
    };

    _handlers["fontsize"] = (Map<String, String> atts) {
      _canvas.setFontSize(double.parse(atts["size"]));
    };

    _handlers["fontcolor"] = (Map<String, String> atts) {
      _canvas.setFontColor(atts["color"]);
    };

    _handlers["fontbackgroundcolor"] = (Map<String, String> atts) {
      _canvas.setFontBackgroundColor(atts["color"]);
    };

    _handlers["fontbordercolor"] = (Map<String, String> atts) {
      _canvas.setFontBorderColor(atts["color"]);
    };

    _handlers["fontfamily"] = (Map<String, String> atts) {
      _canvas.setFontFamily(atts["family"]);
    };

    _handlers["fontstyle"] = (Map<String, String> atts) {
      _canvas.setFontStyle(int.parse(atts["style"]));
    };

    _handlers["alpha"] = (Map<String, String> atts) {
      _canvas.setAlpha(double.parse(atts["alpha"]));
    };

    _handlers["fillcolor"] = (Map<String, String> atts) {
      _canvas.setFillColor(atts["color"]);
    };

    _handlers["shadowcolor"] = (Map<String, String> atts) {
      _canvas.setShadowColor(atts["color"]);
    };

    _handlers["shadowalpha"] = (Map<String, String> atts) {
      _canvas.setShadowAlpha(double.parse(atts["alpha"]));
    };

    _handlers["shadowoffset"] = (Map<String, String> atts) {
      _canvas.setShadowOffset(double.parse(atts["dx"]), double.parse(atts["dy"]));
    };

    _handlers["shadow"] = (Map<String, String> atts) {
      _canvas.setShadow(_getValue(atts, "enabled", "1") == "1");
    };

    _handlers["gradient"] = (Map<String, String> atts) {
      _canvas.setGradient(atts["c1"], atts["c2"], double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]), atts["direction"], double.parse(_getValue(atts, "alpha1", "1")), double.parse(_getValue(atts, "alpha2", "1")));
    };

    _handlers["rect"] = (Map<String, String> atts) {
      _canvas.rect(double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]));
    };

    _handlers["roundrect"] = (Map<String, String> atts) {
      _canvas.roundrect(double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]), double.parse(atts["dx"]), double.parse(atts["dy"]));
    };

    _handlers["ellipse"] = (Map<String, String> atts) {
      _canvas.ellipse(double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]));
    };

    _handlers["image"] = (Map<String, String> atts) {
      _canvas.image(double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]), atts["src"], atts["aspect"] == "1", atts["flipH"] == "1", atts["flipV"] == "1");
    };

    _handlers["text"] = (Map<String, String> atts) {
      _canvas.text(double.parse(atts["x"]), double.parse(atts["y"]), double.parse(atts["w"]), double.parse(atts["h"]), atts["str"], atts["align"], atts["valign"], _getValue(atts, "wrap", "") == "1", atts["format"], atts["overflow"], _getValue(atts, "clip", "") == "1", double.parse(_getValue(atts, "rotation", "0")));
    };

    _handlers["begin"] = (Map<String, String> atts) {
      _canvas.begin();
    };

    _handlers["move"] = (Map<String, String> atts) {
      _canvas.moveTo(double.parse(atts["x"]), double.parse(atts["y"]));
    };

    _handlers["line"] = (Map<String, String> atts) {
      _canvas.lineTo(double.parse(atts["x"]), double.parse(atts["y"]));
    };

    _handlers["quad"] = (Map<String, String> atts) {
      _canvas.quadTo(double.parse(atts["x1"]), double.parse(atts["y1"]), double.parse(atts["x2"]), double.parse(atts["y2"]));
    };

    _handlers["curve"] = (Map<String, String> atts) {
      _canvas.curveTo(double.parse(atts["x1"]), double.parse(atts["y1"]), double.parse(atts["x2"]), double.parse(atts["y2"]), double.parse(atts["x3"]), double.parse(atts["y3"]));
    };

    _handlers["close"] = (Map<String, String> atts) {
      _canvas.close();
    };

    _handlers["stroke"] = (Map<String, String> atts) {
      _canvas.stroke();
    };

    _handlers["fill"] = (Map<String, String> atts) {
      _canvas.fill();
    };

    _handlers["fillstroke"] = (Map<String, String> atts) {
      _canvas.fillAndStroke();
    };
  }

  /**
   * Returns the given attribute value or an empty string.
   */
  String _getValue(Map<String, String> atts, String name, String defaultValue) {
    String value = atts[name];

    if (value == null) {
      value = defaultValue;
    }

    return value;
  }

}
