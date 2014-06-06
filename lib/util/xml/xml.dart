library graph.util.xml;

import 'package:xmlstream/xmlstream.dart';

abstract class DefaultHandler {
  
  String tagName = null;

  Map<String, String> atts;
  
  void call(XmlEvent e) {
    switch (e.state) {
      case XmlState.Open:
        if (tagName != null) {
          _startElement();
        }
        tagName = e.value;
        atts = new Map<String, String>();
        break;
      case XmlState.Attribute:
        if (atts != null) {
          atts[e.key] = e.value;
        }
        break;
      case XmlState.Top:
      case XmlState.Text:
      case XmlState.Namespace:
      case XmlState.CDATA:
      case XmlState.Comment:
      case XmlState.StartDocument:
      case XmlState.EndDocument:
      case XmlState.Closed:
        _startElement();
    }
  }
  
  void _startElement() {
    startElement(tagName, atts);
    tagName = null;
    atts = null;
  }
  
  void startElement(String tagName, Map<String, String> atts);
}
