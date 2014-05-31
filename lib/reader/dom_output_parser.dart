part of graph.reader;

//import java.util.Hashtable;
//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;
//import org.xml.sax.Attributes;

typedef void IElementHandler(Element elt);

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
			int width = int.parseInt(root.getAttribute("width"));
			int height = int.parseInt(root.getAttribute("height"));

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
class DomOutputParser {
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
  DomOutputParser(ICanvas2D canvas) {
    this._canvas = canvas;
    _initHandlers();
  }

  /**
	 * 
	 */
  void read(Node node) {
    while (node != null) {
      if (node is Element) {
        Element elt = node as Element;
        IElementHandler handler = _handlers[elt.nodeName];

        if (handler != null) {
          handler(elt);
        }
      }

      node = node.nextNode;
    }
  }

  /**
	 * 
	 */
  void _initHandlers() {
    _handlers["save"] = (Element elt) {
      _canvas.save();
    };

    _handlers["restore"] = (Element elt) {
      _canvas.restore();
    }; 

    _handlers["scale"] = (Element elt) {
      _canvas.scale(double.parse(elt.getAttribute("scale")));
    }; 

    _handlers["translate"] = (Element elt) {
      _canvas.translate(double.parse(elt.getAttribute("dx")), double.parse(elt.getAttribute("dy")));
    }; 

    _handlers["rotate"] = (Element elt) {
      _canvas.rotate(double.parse(elt.getAttribute("theta")), elt.getAttribute("flipH") == "1", elt.getAttribute("flipV") == "1", double.parse(elt.getAttribute("cx")), double.parse(elt.getAttribute("cy")));
    }; 

    _handlers["strokewidth"] = (Element elt) {
      _canvas.setStrokeWidth(double.parse(elt.getAttribute("width")));
    }; 

    _handlers["strokecolor"] = (Element elt) {
      _canvas.setStrokeColor(elt.getAttribute("color"));
    }; 

    _handlers["dashed"] = (Element elt) {
      _canvas.setDashed(elt.getAttribute("dashed") == "1");
    }; 

    _handlers["dashpattern"] = (Element elt) {
      _canvas.setDashPattern(elt.getAttribute("pattern"));
    }; 

    _handlers["linecap"] = (Element elt) {
      _canvas.setLineCap(elt.getAttribute("cap"));
    }; 

    _handlers["linejoin"] = (Element elt) {
      _canvas.setLineJoin(elt.getAttribute("join"));
    }; 

    _handlers["miterlimit"] = (Element elt) {
      _canvas.setMiterLimit(double.parse(elt.getAttribute("limit")));
    }; 

    _handlers["fontsize"] = (Element elt) {
      _canvas.setFontSize(double.parse(elt.getAttribute("size")));
    }; 

    _handlers["fontcolor"] = (Element elt) {
      _canvas.setFontColor(elt.getAttribute("color"));
    }; 

    _handlers["fontbackgroundcolor"] = (Element elt) {
      _canvas.setFontBackgroundColor(elt.getAttribute("color"));
    }; 

    _handlers["fontbordercolor"] = (Element elt) {
      _canvas.setFontBorderColor(elt.getAttribute("color"));
    }; 

    _handlers["fontfamily"] = (Element elt) {
      _canvas.setFontFamily(elt.getAttribute("family"));
    }; 

    _handlers["fontstyle"] = (Element elt) {
      _canvas.setFontStyle(int.parse(elt.getAttribute("style")));
    }; 

    _handlers["alpha"] = (Element elt) {
      _canvas.setAlpha(double.parse(elt.getAttribute("alpha")));
    }; 

    _handlers["fillcolor"] = (Element elt) {
      _canvas.setFillColor(elt.getAttribute("color"));
    }; 

    _handlers["shadowcolor"] = (Element elt) {
      _canvas.setShadowColor(elt.getAttribute("color"));
    }; 

    _handlers["shadowalpha"] = (Element elt) {
      _canvas.setShadowAlpha(double.parse(elt.getAttribute("alpha")));
    }; 

    _handlers["shadowoffset"] = (Element elt) {
      _canvas.setShadowOffset(double.parse(elt.getAttribute("dx")), double.parse(elt.getAttribute("dy")));
    }; 

    _handlers["shadow"] = (Element elt) {
      _canvas.setShadow(elt.getAttribute("enabled") == "1");
    }; 

    _handlers["gradient"] = (Element elt) {
      _canvas.setGradient(elt.getAttribute("c1"), elt.getAttribute("c2"), double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")), elt.getAttribute("direction"), double.parse(_getValue(elt, "alpha1", "1")), double.parse(_getValue(elt, "alpha2", "1")));
    }; 

    _handlers["rect"] = (Element elt) {
      _canvas.rect(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")));
    }; 

    _handlers["roundrect"] = (Element elt) {
      _canvas.roundrect(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")), double.parse(elt.getAttribute("dx")), double.parse(elt.getAttribute("dy")));
    }; 

    _handlers["ellipse"] = (Element elt) {
      _canvas.ellipse(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")));
    }; 

    _handlers["image"] = (Element elt) {
      _canvas.image(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")), elt.getAttribute("src"), elt.getAttribute("aspect") == "1", elt.getAttribute("flipH") == "1", elt.getAttribute("flipV") == "1");
    }; 

    _handlers["text"] = (Element elt) {
      _canvas.text(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")), double.parse(elt.getAttribute("w")), double.parse(elt.getAttribute("h")), elt.getAttribute("str"), elt.getAttribute("align"), elt.getAttribute("valign"), _getValue(elt, "wrap", "") == "1", elt.getAttribute("format"), elt.getAttribute("overflow"), _getValue(elt, "clip", "") == "1", double.parse(_getValue(elt, "rotation", "0")));
    }; 

    _handlers["begin"] = (Element elt) {
      _canvas.begin();
    }; 

    _handlers["move"] = (Element elt) {
      _canvas.moveTo(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")));
    }; 

    _handlers["line"] = (Element elt) {
      _canvas.lineTo(double.parse(elt.getAttribute("x")), double.parse(elt.getAttribute("y")));
    }; 

    _handlers["quad"] = (Element elt) {
      _canvas.quadTo(double.parse(elt.getAttribute("x1")), double.parse(elt.getAttribute("y1")), double.parse(elt.getAttribute("x2")), double.parse(elt.getAttribute("y2")));
    }; 

    _handlers["curve"] = (Element elt) {
      _canvas.curveTo(double.parse(elt.getAttribute("x1")), double.parse(elt.getAttribute("y1")), double.parse(elt.getAttribute("x2")), double.parse(elt.getAttribute("y2")), double.parse(elt.getAttribute("x3")), double.parse(elt.getAttribute("y3")));
    }; 

    _handlers["close"] = (Element elt) {
      _canvas.close();
    }; 

    _handlers["stroke"] = (Element elt) {
      _canvas.stroke();
    }; 

    _handlers["fill"] = (Element elt) {
      _canvas.fill();
    }; 

    _handlers["fillstroke"] = (Element elt) {
      _canvas.fillAndStroke();
    }; 
  }

  /**
	 * Returns the given attribute value or an empty string.
	 */
  String _getValue(Element elt, String name, String defaultValue) {
    String value = elt.getAttribute(name);

    if (value == null) {
      value = defaultValue;
    }

    return value;
  }

}
