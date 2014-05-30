/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;
//import org.w3c.dom.NodeList;

/**
 * This class implements several GML utility methods.
 */
class GraphMlUtils {
  /**
	 * Checks if the NodeList has a Node with name = tag.
	 * @param nl NodeList
	 * @param tag Name of the node.
	 * @return Returns <code>true</code> if the Node List has a Node with name = tag.
	 */
  static bool nodeListHasTag(NodeList nl, String tag) {
    bool has = false;

    if (nl != null) {
      int length = nl.length;

      for (int i = 0; (i < length) && !has; i++) {
        has = nl[i].nodeName == tag;
      }
    }

    return has;
  }

  /**
	 * Returns the first Element that has name = tag in Node List.
	 * @param nl NodeList
	 * @param tag Name of the Element
	 * @return Element with name = 'tag'.
	 */
  static Element nodeListTag(NodeList nl, String tag) {
    if (nl != null) {
      int length = nl.length;
      bool has = false;

      for (int i = 0; (i < length) && !has; i++) {
        has = nl[i].nodeName == tag;

        if (has) {
          return nl[i] as Element;
        }
      }
    }

    return null;
  }

  /**
	 * Returns a list with the elements included in the Node List that have name = tag.
	 * @param nl NodeList
	 * @param tag name of the Element.
	 * @return List with the indicated elements.
	 */
  static List<Element> nodeListTags(NodeList nl, String tag) {
    List<Element> ret = new List<Element>();

    if (nl != null) {
      int length = nl.length;

      for (int i = 0; i < length; i++) {
        if (tag == nl[i].nodeName) {
          ret.add(nl[i] as Element);
        }
      }
    }
    return ret;
  }

  /**
	 * Checks if the childrens of element has a Node with name = tag.
	 * @param element Element
	 * @param tag Name of the node.
	 * @return Returns <code>true</code> if the childrens of element has a Node with name = tag.
	 */
  static bool childsHasTag(Element element, String tag) {
    NodeList nl = element.childNodes;

    bool has = false;

    if (nl != null) {
      int length = nl.length;

      for (int i = 0; (i < length) && !has; i++) {
        has = nl[i].nodeName == tag;
      }
    }
    return has;
  }

  /**
	 * Returns the first Element that has name = tag in the childrens of element.
	 * @param element Element
	 * @param tag Name of the Element
	 * @return Element with name = 'tag'.
	 */
  static Element childsTag(Element element, String tag) {
    NodeList nl = element.childNodes;

    if (nl != null) {
      int length = nl.length;
      bool has = false;

      for (int i = 0; (i < length) && !has; i++) {
        has = nl[i].nodeName == tag;

        if (has) {
          return nl[i] as Element;
        }
      }
    }

    return null;
  }

  /**
	 * Returns a list with the elements included in the childrens of element
	 * that have name = tag.
	 * @param element Element
	 * @param tag name of the Element.
	 * @return List with the indicated elements.
	 */
  static List<Element> childsTags(Element element, String tag) {
    NodeList nl = element.childNodes;

    List<Element> ret = new List<Element>();

    if (nl != null) {
      int length = nl.length;

      for (int i = 0; i < length; i++) {
        if (tag == nl[i].nodeName) {
          ret.add(nl[i] as Element);
        }
      }
    }
    return ret;
  }

  /**
	 * Copy a given NodeList into a List<Element>
	 * @param nodeList Node List.
	 * @return List with the elements of nodeList.
	 */
  static List<Node> copyNodeList(NodeList nodeList) {
    List<Node> copy = new List<Node>();
    int length = nodeList.length;

    for (int i = 0; i < length; i++) {
      copy.add(nodeList[i] as Node);
    }

    return copy;
  }

  /**
	 * Create a style map from a String with style definitions.
	 * @param style Definition of the style.
	 * @param asig Asignation simbol used in 'style'.
	 * @return Map with the style properties.
	 */
  static HashMap<String, Object> getStyleMap(String style, String asig) {
    HashMap<String, Object> styleMap = new HashMap<String, Object>();
    String key = "";
    String value = "";
    int index = 0;

    if (style != "") {
      List<String> entries = style.split(";");

      for (String entry in entries) {
        index = entry.indexOf(asig);

        if (index == -1) {
          key = "";
          value = entry;
          styleMap[key] = value;
        } else {
          key = entry.substring(0, index);
          value = entry.substring(index + 1);
          styleMap[key] = value;
        }
      }
    }
    return styleMap;
  }

  /**
	 * Returns the string that represents the content of a given style map.
	 * @param styleMap Map with the styles values
	 * @return string that represents the style.
	 */
  static String getStyleString(Map<String, Object> styleMap, String asig) {
    String style = "";
    Iterator<Object> it = styleMap.values.iterator;
    Iterator<String> kit = styleMap.keys.iterator;

    while (kit.moveNext()) {
      String key = kit.current;
      Object value = it.current;
      style = style + key + asig + value + ";";
    }
    return style;
  }
}
