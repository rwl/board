/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;

//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.Map;

/**
 * Singleton class that acts as a global converter from string to object values
 * in a style. This is currently only used to perimeters and edge styles.
 */
class StyleRegistry {

  /**
	 * Maps from strings to objects.
	 */
  static Map<String, Object> _values = new Map<String, Object>();

  // Registers the known object styles
  static init() {
    putValue(Constants.EDGESTYLE_ELBOW, EdgeStyle.ElbowConnector);
    putValue(Constants.EDGESTYLE_ENTITY_RELATION, EdgeStyle.EntityRelation);
    putValue(Constants.EDGESTYLE_LOOP, EdgeStyle.Loop);
    putValue(Constants.EDGESTYLE_SIDETOSIDE, EdgeStyle.SideToSide);
    putValue(Constants.EDGESTYLE_TOPTOBOTTOM, EdgeStyle.TopToBottom);
    putValue(Constants.EDGESTYLE_ORTHOGONAL, EdgeStyle.OrthConnector);
    putValue(Constants.EDGESTYLE_SEGMENT, EdgeStyle.SegmentConnector);

    putValue(Constants.PERIMETER_ELLIPSE, Perimeter.EllipsePerimeter);
    putValue(Constants.PERIMETER_RECTANGLE, Perimeter.RectanglePerimeter);
    putValue(Constants.PERIMETER_RHOMBUS, Perimeter.RhombusPerimeter);
    putValue(Constants.PERIMETER_TRIANGLE, Perimeter.TrianglePerimeter);
    putValue(Constants.PERIMETER_HEXAGON, Perimeter.HexagonPerimeter);
  }

  /**
	 * Puts the given object into the registry under the given name.
	 */
  static void putValue(String name, Object value) {
    _values[name] = value;
  }

  /**
	 * Returns the value associated with the given name.
	 */
  static Object getValue(String name) {
    return _values[name];
  }

  /**
	 * Returns the name for the given value.
	 */
  static String getName(Object value) {
    _values.forEach((String k, Object v) {
      if (v == value) {
        return k;
      }
    });

    return null;
  }

}
