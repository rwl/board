/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import org.w3c.dom.Document;
//import org.w3c.dom.Element;

/**
 * This class represents the properties of a JGraph edge.
 */
class GraphMlShapeEdge {
  String _text = "";

  String _style = "";

  String _edgeSource;

  String _edgeTarget;

  /**
	 * Construct a Shape Edge with text and style.
	 * @param text
	 * @param style
	 */
  GraphMlShapeEdge([String this._text="", String this._style=""]);

  /**
	 * Constructs a ShapeEdge from a xml shapeEdgeElement.
	 * @param shapeEdgeElement
	 */
  factory GraphMlShapeEdge.from(Element shapeEdgeElement) {
    Element labelElement = GraphMlUtils.childsTag(shapeEdgeElement, GraphMlConstants.JGRAPH + GraphMlConstants.LABEL);

    if (labelElement != null) {
      this._text = labelElement.getAttribute(GraphMlConstants.TEXT);
    }

    Element styleElement = GraphMlUtils.childsTag(shapeEdgeElement, GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);

    if (styleElement != null) {
      this._style = styleElement.getAttribute(GraphMlConstants.PROPERTIES);

    }
  }

  /**
	 * Construct an empty Shape Edge Element.
	 */
//  GraphMlShapeEdge() {
//  }

  /**
	 * Generates a ShapeEdge Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
  Element generateElement(Document document) {
    Element dataEdge = document.createElementNS(GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH + GraphMlConstants.SHAPEEDGE);

    if (this._text != "") {
      Element dataEdgeLabel = document.createElementNS(GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH + GraphMlConstants.LABEL);
      dataEdgeLabel.setAttribute(GraphMlConstants.TEXT, this._text);
      dataEdge.append(dataEdgeLabel);
    }

    if (this._style != "") {
      Element dataEdgeStyle = document.createElementNS(GraphMlConstants.JGRAPH_URL, GraphMlConstants.JGRAPH + GraphMlConstants.STYLE);

      dataEdgeStyle.setAttribute(GraphMlConstants.PROPERTIES, this._style);
      dataEdge.append(dataEdgeStyle);
    }

    return dataEdge;
  }

  String getText() {
    return _text;
  }

  void setText(String text) {
    this._text = text;
  }

  String getStyle() {
    return _style;
  }

  void setStyle(String style) {
    this._style = style;
  }

  String getEdgeSource() {
    return _edgeSource;
  }

  void setEdgeSource(String edgeSource) {
    this._edgeSource = edgeSource;
  }

  String getEdgeTarget() {
    return _edgeTarget;
  }

  void setEdgeTarget(String edgeTarget) {
    this._edgeTarget = edgeTarget;
  }
}
