/*
 * Copyright (c) 2005, David Benson
 *
 * All rights reserved.
 *
 * This file is licensed under the JGraph software license, a copy of which
 * will have been provided to you in the file LICENSE at the root of your
 * installation directory. If you are unable to locate this file please
 * contact JGraph sales for another copy.
 */
part of graph.layout.hierarchical.model;


/**
 * An abstraction of an internal node in the hierarchy layout
 */
class GraphHierarchyNode extends GraphAbstractHierarchyCell {

  /**
   * Shared empty connection map to return instead of null in applyMap.
   */
  static Iterable<GraphHierarchyEdge> emptyConnectionMap = new List<GraphHierarchyEdge>(0);

  /**
   * The graph cell this object represents.
   */
  Object cell = null;

  /**
   * Collection of hierarchy edges that have this node as a target
   */
  Iterable<GraphHierarchyEdge> connectsAsTarget = emptyConnectionMap;

  /**
   * Collection of hierarchy edges that have this node as a source
   */
  Iterable<GraphHierarchyEdge> connectsAsSource = emptyConnectionMap;

  /**
   * Assigns a unique hashcode for each node. Used by the model dfs instead
   * of copying HashSets
   */
  List<int> hashCode;

  /**
   * Constructs an internal node to represent the specified real graph cell
   * @param cell the real graph cell this node represents
   */
  GraphHierarchyNode(Object cell) {
    this.cell = cell;
  }

  /**
   * Returns the integer value of the layer that this node resides in
   * @return the integer value of the layer that this node resides in
   */
  int getRankValue() {
    return maxRank;
  }

  /**
   * Returns the cells this cell connects to on the next layer up
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer up
   */
  //	@SuppressWarnings("unchecked")
  List<GraphAbstractHierarchyCell> getNextLayerConnectedCells(int layer) {
    if (_nextLayerConnectedCells == null) {
      _nextLayerConnectedCells = new List<ArrayList>(1);
      _nextLayerConnectedCells[0] = new List<GraphAbstractHierarchyCell>(connectsAsTarget.length);
      Iterator<GraphHierarchyEdge> iter = connectsAsTarget.iterator();

      while (iter.moveNext()) {
        GraphHierarchyEdge edge = iter.current();

        if (edge.maxRank == -1 || edge.maxRank == layer + 1) {
          // Either edge is not in any rank or
          // no dummy nodes in edge, add node of other side of edge
          _nextLayerConnectedCells[0].add(edge.source);
        } else {
          // Edge spans at least two layers, add edge
          _nextLayerConnectedCells[0].add(edge);
        }
      }
    }

    return _nextLayerConnectedCells[0];
  }

  /**
   * Returns the cells this cell connects to on the next layer down
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer down
   */
  //	@SuppressWarnings("unchecked")
  List<GraphAbstractHierarchyCell> getPreviousLayerConnectedCells(int layer) {
    if (_previousLayerConnectedCells == null) {
      _previousLayerConnectedCells = new List<ArrayList>(1);
      _previousLayerConnectedCells[0] = new List<GraphAbstractHierarchyCell>(connectsAsSource.length);
      Iterator<GraphHierarchyEdge> iter = connectsAsSource.iterator();

      while (iter.moveNext()) {
        GraphHierarchyEdge edge = iter.current();

        if (edge.minRank == -1 || edge.minRank == layer - 1) {
          // No dummy nodes in edge, add node of other side of edge
          _previousLayerConnectedCells[0].add(edge.target);
        } else {
          // Edge spans at least two layers, add edge
          _previousLayerConnectedCells[0].add(edge);
        }
      }
    }

    return _previousLayerConnectedCells[0];
  }

  /**
   * 
   * @return whether or not this cell is an edge
   */
  bool isEdge() {
    return false;
  }

  /**
   * 
   * @return whether or not this cell is a node
   */
  bool isVertex() {
    return true;
  }

  /**
   * Gets the value of temp for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into temp
   * @return the value for that layer
   */
  int getGeneralPurposeVariable(int layer) {
    return temp[0];
  }

  /**
   * Set the value of temp for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into temp
   * @param value
   *            the value for that layer
   */
  void setGeneralPurposeVariable(int layer, int value) {
    temp[0] = value;
  }

  bool isAncestor(GraphHierarchyNode otherNode) {
    // Firstly, the hash code of this node needs to be shorter than the
    // other node
    if (otherNode != null && hashCode != null && otherNode.hashCode != null && hashCode.length < otherNode.hashCode.length) {
      if (hashCode == otherNode.hashCode) {
        return true;
      }

      if (hashCode == null) {
        return false;
      }

      // Secondly, this hash code must match the start of the other
      // node's hash code. Arrays.equals cannot be used here since
      // the arrays are different length, and we do not want to
      // perform another array copy.
      for (int i = 0; i < hashCode.length; i++) {
        if (hashCode[i] != otherNode.hashCode[i]) {
          return false;
        }
      }

      return true;
    }

    return false;
  }

}
