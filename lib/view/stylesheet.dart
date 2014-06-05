/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;


/**
 * Defines the appearance of the cells in a graph. The following example
 * changes the font size for all vertices by changing the default vertex
 * style in-place:
 * <code>
 * getDefaultVertexStyle().put(Constants.STYLE_FONTSIZE, 16);
 * </code>
 * 
 * To change the default font size for all cells, set
 * Constants.DEFAULT_FONTSIZE.
 */
class Stylesheet {

  /**
   * Shared immutable empty hashtable (for undefined cell styles).
   */
  static final Map<String, Object> EMPTY_STYLE = new Map<String, Object>();

  /**
   * Maps from names to styles.
   */
  Map<String, Map<String, Object>> _styles = new Map<String, Map<String, Object>>();

  /**
   * Constructs a new stylesheet and assigns default styles.
   */
  Stylesheet() {
    setDefaultVertexStyle(_createDefaultVertexStyle());
    setDefaultEdgeStyle(_createDefaultEdgeStyle());
  }

  /**
   * Returns all styles as map of name, hashtable pairs.
   * 
   * @return All styles in this stylesheet.
   */
  Map<String, Map<String, Object>> getStyles() {
    return _styles;
  }

  /**
   * Sets all styles in the stylesheet.
   */
  void setStyles(Map<String, Map<String, Object>> styles) {
    this._styles = styles;
  }

  /**
   * Creates and returns the default vertex style.
   * 
   * @return Returns the default vertex style.
   */
  Map<String, Object> _createDefaultVertexStyle() {
    Map<String, Object> style = new Map<String, Object>();

    style[Constants.STYLE_SHAPE] = Constants.SHAPE_RECTANGLE;
    style[Constants.STYLE_PERIMETER] = Perimeter.RectanglePerimeter;
    style[Constants.STYLE_VERTICAL_ALIGN] = Constants.ALIGN_MIDDLE;
    style[Constants.STYLE_ALIGN] = Constants.ALIGN_CENTER;
    style[Constants.STYLE_FILLCOLOR] = "#C3D9FF";
    style[Constants.STYLE_STROKECOLOR] = "#6482B9";
    style[Constants.STYLE_FONTCOLOR] = "#774400";

    return style;
  }

  /**
   * Creates and returns the default edge style.
   * 
   * @return Returns the default edge style.
   */
  Map<String, Object> _createDefaultEdgeStyle() {
    Map<String, Object> style = new Map<String, Object>();

    style[Constants.STYLE_SHAPE] = Constants.SHAPE_CONNECTOR;
    style[Constants.STYLE_ENDARROW] = Constants.ARROW_CLASSIC;
    style[Constants.STYLE_VERTICAL_ALIGN] = Constants.ALIGN_MIDDLE;
    style[Constants.STYLE_ALIGN] = Constants.ALIGN_CENTER;
    style[Constants.STYLE_STROKECOLOR] = "#6482B9";
    style[Constants.STYLE_FONTCOLOR] = "#446299";

    return style;
  }

  /**
   * Returns the default style for vertices.
   * 
   * @return Returns the default vertex style.
   */
  Map<String, Object> getDefaultVertexStyle() {
    return _styles["defaultVertex"];
  }

  /**
   * Sets the default style for vertices.
   * 
   * @param value Style to be used for vertices.
   */
  void setDefaultVertexStyle(Map<String, Object> value) {
    putCellStyle("defaultVertex", value);
  }

  /**
   * Returns the default style for edges.
   * 
   * @return Returns the default edge style.
   */
  Map<String, Object> getDefaultEdgeStyle() {
    return _styles["defaultEdge"];
  }

  /**
   * Sets the default style for edges.
   * 
   * @param value Style to be used for edges.
   */
  void setDefaultEdgeStyle(Map<String, Object> value) {
    putCellStyle("defaultEdge", value);
  }

  /**
   * Stores the specified style under the given name.
   * 
   * @param name Name for the style to be stored.
   * @param style Key, value pairs that define the style.
   */
  void putCellStyle(String name, Map<String, Object> style) {
    _styles[name] = style;
  }

  /**
   * Returns the cell style for the specified cell or the given defaultStyle
   * if no style can be found for the given stylename.
   * 
   * @param name String of the form [(stylename|key=value);] that represents the
   * style.
   * @param defaultStyle Default style to be returned if no style can be found.
   * @return Returns the style for the given formatted cell style.
   */
  Map<String, Object> getCellStyle(String name, Map<String, Object> defaultStyle) {
    Map<String, Object> style = defaultStyle;

    if (name != null && name.length > 0) {
      List<String> pairs = name.split(";");

      if (style != null && !name.startsWith(";")) {
        style = new Map<String, Object>.from(style);
      } else {
        style = new Map<String, Object>();
      }

      for (int i = 0; i < pairs.length; i++) {
        String tmp = pairs[i];
        int c = tmp.indexOf('=');

        if (c >= 0) {
          String key = tmp.substring(0, c);
          String value = tmp.substring(c + 1);

          if (value == Constants.NONE) {
            style.remove(key);
          } else {
            style[key] = value;
          }
        } else {
          Map<String, Object> tmpStyle = _styles[tmp];

          if (tmpStyle != null) {
            style.addAll(tmpStyle);
          }
        }
      }
    }

    return style;
  }

}
