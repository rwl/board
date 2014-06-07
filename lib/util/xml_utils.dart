/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.util;

//import java.io.StringReader;
//import java.io.StringWriter;

//import javax.xml.parsers.DocumentBuilder;
//import javax.xml.parsers.DocumentBuilderFactory;
//import javax.xml.transform.OutputKeys;
//import javax.xml.transform.Transformer;
//import javax.xml.transform.TransformerFactory;
//import javax.xml.transform.dom.DOMSource;
//import javax.xml.transform.stream.StreamResult;

//import org.w3c.dom.Document;
//import org.w3c.dom.Node;

//import org.xml.sax.InputSource;

/**
 * Contains various XML helper methods for use with Graph.
 */
class XmlUtils {
  /**
   * Returns a new document for the given XML string.
   * 
   * @param xmlData
   *            String that represents the XML data.
   * @return Returns a new XML document.
   */
  static xml.XmlElement parseXml(String xmlData) {
    /*try {
      DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
      DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();

      return docBuilder.parse(new InputSource(new StringReader(xml)));
    } on Exception catch (e) {
      e.printStackTrace();
    }*/
    try {
      return xml.XML.parse(xmlData);
    } on xml.XmlException catch (e, st) {
      print(st);
    }

    return null;
  }

  /**
   * Returns a string that represents the given node.
   * 
   * @param node
   *            Node to return the XML for.
   * @return Returns an XML string.
   */
  static String getXml(Node node) {
    try {
      /*Transformer tf = TransformerFactory.newInstance().newTransformer();

      tf.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
      tf.setOutputProperty(OutputKeys.ENCODING, "UTF-8");

      StreamResult dest = new StreamResult(new StringWriter());
      tf.transform(new DOMSource(node), dest);

      return dest.getWriter().toString();*/
      return node.toString(); // FIXME
    } on Exception catch (e) {
      // ignore
    }

    return "";
  }
}
