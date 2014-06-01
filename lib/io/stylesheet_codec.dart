/**
 * Copyright (c) 2006-2013, JGraph Ltd
 */
part of graph.io;

//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Codec for mxStylesheets. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
class StylesheetCodec extends ObjectCodec {

  /**
	 * Constructs a new model codec.
	 */
  //	StylesheetCodec()
  //	{
  //		this(new Stylesheet());
  //	}

  /**
	 * Constructs a new stylesheet codec for the given template.
	 */
  //	StylesheetCodec(Object template)
  //	{
  //		this(template, null, null, null);
  //	}

  /**
	 * Constructs a new model codec for the given arguments.
	 */
  StylesheetCodec([Object template=null, List<String> exclude = null, List<String> idrefs = null,
      Map<String, String> mapping = null]) : super(template, exclude, idrefs, mapping) {
    if (template == null) {
      this._template = new Stylesheet();
    }
  }

  /**
	 * Encodes the given Stylesheet.
	 */
  Node encode(Codec enc, Object obj) {
    Element node = enc._document.createElement(getName());

    if (obj is Stylesheet) {
      Stylesheet stylesheet = obj as Stylesheet;
//      Iterator<Map.Entry<String, Map<String, Object>>> it = stylesheet.getStyles().entrySet().iterator();

//      while (it.moveNext()) {
//        Map.Entry<String, Map<String, Object>> entry = it.current();

      stylesheet.getStyles().forEach((String stylename, Map<String, Object> style) {
        Element styleNode = enc._document.createElement("add");
        //String stylename = entry.getKey();
        styleNode.setAttribute("as", stylename);

        //Map<String, Object> style = entry.getValue();
        //Iterator<Map.Entry<String, Object>> it2 = style.entrySet().iterator();

        //while (it2.moveNext()) {
          //Map.Entry<String, Object> entry2 = it2.current();
        style.forEach((String k, Object v) {
          Element entryNode = enc._document.createElement("add");
          entryNode.setAttribute("as", k);
          entryNode.setAttribute("value", _getStringValue(v));
          styleNode.append(entryNode);
        });

        if (styleNode.childNodes.length > 0) {
          node.append(styleNode);
        }
      });
    }

    return node;
  }

  /**
	 * Returns the string for encoding the given value.
	 */
  String _getStringValue(Object v) {
    if (v is bool) {
      return v ? "1" : "0";
    }

    return v.toString();
  }

  /**
	 * Decodes the given Stylesheet.
	 */
  Object decode(Codec dec, Node node, [Object into=null]) {
    Object obj = null;

    if (node is Element) {
      String id = (node as Element).getAttribute("id");
      obj = dec._objects[id];

      if (obj == null) {
        obj = into;

        if (obj == null) {
          obj = _cloneTemplate(node);
        }

        if (id != null && id.length > 0) {
          dec.putObject(id, obj);
        }
      }

      node = node.firstChild;

      while (node != null) {
        if (!processInclude(dec, node, obj) && node.nodeName == "add" && node is Element) {
          String as = (node as Element).getAttribute("as");

          if (as != null && as.length > 0) {
            String extend = (node as Element).getAttribute("extend");
            Map<String, Object> style = (extend != null) ? (obj as Stylesheet).getStyles()[extend] : null;

            if (style == null) {
              style = new Map<String, Object>();
            } else {
              style = new Map<String, Object>.from(style);
            }

            Node entry = node.firstChild;

            while (entry != null) {
              if (entry is Element) {
                Element entryElement = entry as Element;
                String key = entryElement.getAttribute("as");

                if (entry.nodeName == "add") {
                  String text = entry.text;
                  Object value = null;

                  if (text != null && text.length > 0) {
                    value = Utils.eval(text);
                  } else {
                    value = entryElement.getAttribute("value");

                  }

                  if (value != null) {
                    style[key] = value;
                  }
                } else if (entry.nodeName == "remove") {
                  style.remove(key);
                }
              }

              entry = entry.nextNode;
            }

            (obj as Stylesheet).putCellStyle(as, style);
          }
        }

        node = node.nextNode;
      }
    }

    return obj;
  }

}
