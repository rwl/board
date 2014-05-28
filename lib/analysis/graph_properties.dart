part of graph.analysis;


//import java.util.Map;

/**
 * Constants for graph structure properties
 */
class GraphProperties {

  /**
	 * Whether or not to navigate the graph raw graph structure or 
	 * the visible structure. The value associated with this key
	 * should evaluate as a string to <code>1</code> or 
	 * <code>0</code>
	 */
  static String TRAVERSE_VISIBLE = "traverseVisible";

  static bool DEFAULT_TRAVERSE_VISIBLE = false;

  /**
	 * Whether or not to take into account the direction on edges. 
	 * The value associated with this key should evaluate as a 
	 * string to <code>1</code> or <code>0</code>
	 */
  static String DIRECTED = "directed";

  static bool DEFAULT_DIRECTED = false;

  /**
	 * @param properties
	 * @param defaultValue
	 * @return
	 */
  static bool isTraverseVisible(Map<String, Object> properties, bool defaultValue) {
    if (properties != null) {
      return Utils.isTrue(properties, TRAVERSE_VISIBLE, defaultValue);
    }

    return false;
  }

  /**
	 * 
	 * @param properties
	 * @param isTraverseVisible
	 */
  static void setTraverseVisible(Map<String, Object> properties, bool isTraverseVisible) {
    if (properties != null) {
      properties.put(TRAVERSE_VISIBLE, isTraverseVisible);
    }
  }

  /**
	 * 
	 * @param properties
	 * @return
	 */
  static bool isDirected(Map<String, Object> properties, bool defaultValue) {
    if (properties != null) {
      return Utils.isTrue(properties, DIRECTED, defaultValue);
    }

    return false;
  }

  /**
	 * 
	 * @param properties
	 * @param isTraverseVisible
	 */
  static void setDirected(Map<String, Object> properties, bool isDirected) {
    if (properties != null) {
      properties.put(DIRECTED, isDirected);
    }
  }

}
