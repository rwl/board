/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.util;

//import javax.xml.parsers.DocumentBuilder;
//import javax.xml.parsers.DocumentBuilderFactory;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * Contains various DOM API helper methods for use with Graph.
 */
class DomUtils {
  /**
   * Returns a new, empty DOM document.
   * 
   * @return Returns a new DOM document.
   */
  static Document createDocument() {
    throw new Exception();
    Document result = null;//new Document();

    /*try {
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder parser = factory.newDocumentBuilder();

      result = parser.newDocument();
    } on Exception catch (e) {
      System.out.println(e.getMessage());
    }*/

    return result;
  }

  /**
   * Creates a new SVG document for the given width and height.
   */
  static Document createSvgDocument(int width, int height) {
    Document document = createDocument();
    Element root = document.createElement("svg");

    String w = width.toString();
    String h = height.toString();

    root.setAttribute("width", w);
    root.setAttribute("height", h);
    root.setAttribute("viewBox", "0 0 " + w + " " + h);
    root.setAttribute("version", "1.1");
    root.setAttribute("xmlns", Constants.NS_SVG);
    root.setAttribute("xmlns:xlink", Constants.NS_XLINK);

    document.append(root);

    return document;
  }

  static Document createVmlDocument() {
    Document document = createDocument();

    Element root = document.createElement("html");
    root.setAttribute("xmlns:v", "urn:schemas-microsoft-com:vml");
    root.setAttribute("xmlns:o", "urn:schemas-microsoft-com:office:office");

    document.append(root);

    Element head = document.createElement("head");

    Element style = document.createElement("style");
    style.setAttribute("type", "text/css");
    //style.append(document.createTextNode("<!-- v\\:* {behavior: url(#default#VML);} -->"));
    style.text = "<!-- v\\:* {behavior: url(#default#VML);} -->";

    head.append(style);
    root.append(head);

    Element body = document.createElement("body");
    root.append(body);

    return document;
  }

  /**
   * Returns a document with a HTML node containing a HEAD and BODY node.
   */
  static Document createHtmlDocument() {
    Document document = createDocument();

    Element root = document.createElement("html");

    document.append(root);

    Element head = document.createElement("head");
    root.append(head);

    Element body = document.createElement("body");
    root.append(body);

    return document;
  }
}
