/**
 * Copyright (c) 2005-2010, David Benson, Gaudenz Alder
 */
part of graph.layout.hierarchical.model;


/**
 * An abstraction of an internal hierarchy node or edge
 */
abstract class GraphAbstractHierarchyCell {

  /**
   * The maximum rank this cell occupies
   */
  int maxRank = -1;

  /**
   * The minimum rank this cell occupies
   */
  int minRank = -1;

  /**
   * The x position of this cell for each layer it occupies
   */
  List<double> x = new List<double>(1);

  /**
   * The y position of this cell for each layer it occupies
   */
  List<double> y = new List<double>(1);

  /**
   * The width of this cell
   */
  double width = 0.0;

  /**
   * The height of this cell
   */
  double height = 0.0;

  /**
   * A cached version of the cells this cell connects to on the next layer up
   */
  List<List<GraphAbstractHierarchyCell>> _nextLayerConnectedCells = null;

  /**
   * A cached version of the cells this cell connects to on the next layer down
   */
  List<List<GraphAbstractHierarchyCell>> _previousLayerConnectedCells = null;

  /**
   * Temporary variable for general use. Generally, try to avoid
   * carrying information between stages. Currently, the longest
   * path layering sets temp to the rank position in fixRanks()
   * and the crossing reduction uses this. This meant temp couldn't
   * be used for hashing the nodes in the model dfs and so hashCode
   * was created
   */
  List<List<int>> temp = new List<int>(1);

  /**
   * Returns the cells this cell connects to on the next layer up
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer up
   */
  List<GraphAbstractHierarchyCell> getNextLayerConnectedCells(int layer);

  /**
   * Returns the cells this cell connects to on the next layer down
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer down
   */
  List<GraphAbstractHierarchyCell> getPreviousLayerConnectedCells(int layer);

  /**
   * 
   * @return whether or not this cell is an edge
   */
  bool isEdge();

  /**
   * 
   * @return whether or not this cell is a node
   */
  bool isVertex();

  /**
   * Gets the value of temp for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into temp
   * @return the value for that layer
   */
  int getGeneralPurposeVariable(int layer);

  /**
   * Set the value of temp for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into temp
   * @param value
   *            the value for that layer
   */
  void setGeneralPurposeVariable(int layer, int value);

  /**
   * Set the value of x for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into x[]
   * @param value
   *            the x value for that layer
   */
  void setX(int layer, double value) {
    if (isVertex()) {
      x[0] = value;
    } else if (isEdge()) {
      x[layer - minRank - 1] = value;
    }
  }

  /**
   * Gets the value of x on the specified layer
   * @param layer the layer to obtain x for
   * @return the value of x on the specified layer
   */
  double getX(int layer) {
    if (isVertex()) {
      return x[0];
    } else if (isEdge()) {
      return x[layer - minRank - 1];
    }

    return 0.0;
  }

  /**
   * Set the value of y for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into y[]
   * @param value
   *            the y value for that layer
   */
  void setY(int layer, double value) {
    if (isVertex()) {
      y[0] = value;
    } else if (isEdge()) {
      y[layer - minRank - 1] = value;
    }
  }

}
