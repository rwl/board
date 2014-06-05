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
 * An abstraction of a hierarchical edge for the hierarchy layout
 */
class GraphHierarchyEdge extends GraphAbstractHierarchyCell {

  /**
   * The graph edge(s) this object represents. Parallel edges are all grouped
   * together within one hierarchy edge.
   */
  List<Object> edges;

  /**
   * The node this edge is sourced at
   */
  GraphHierarchyNode source;

  /**
   * The node this edge targets
   */
  GraphHierarchyNode target;

  /**
   * Whether or not the direction of this edge has been reversed
   * internally to create a DAG for the hierarchical layout
   */
  bool _isReversed = false;

  /**
   * Constructs a hierarchy edge
   * @param edges a list of real graph edges this abstraction represents
   */
  GraphHierarchyEdge(List<Object> edges) {
    this.edges = edges;
  }

  /**
   * Inverts the direction of this internal edge(s)
   */
  void invert() {
    GraphHierarchyNode temp = source;
    source = target;
    target = temp;
    _isReversed = !_isReversed;
  }

  /**
   * @return Returns the isReversed.
   */
  bool isReversed() {
    return _isReversed;
  }

  /**
   * @param isReversed The isReversed to set.
   */
  void setReversed(bool isReversed) {
    this._isReversed = isReversed;
  }

  /**
   * Returns the cells this cell connects to on the next layer up
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer up
   */
  //	@SuppressWarnings("unchecked")
  List<GraphAbstractHierarchyCell> getNextLayerConnectedCells(int layer) {
    if (_nextLayerConnectedCells == null) {
      _nextLayerConnectedCells = new List<ArrayList>(temp.length);

      for (int i = 0; i < _nextLayerConnectedCells.length; i++) {
        _nextLayerConnectedCells[i] = new List<GraphAbstractHierarchyCell>(2);

        if (i == _nextLayerConnectedCells.length - 1) {
          _nextLayerConnectedCells[i].add(source);
        } else {
          _nextLayerConnectedCells[i].add(this);
        }
      }
    }

    return _nextLayerConnectedCells[layer - minRank - 1];
  }

  /**
   * Returns the cells this cell connects to on the next layer down
   * @param layer the layer this cell is on
   * @return the cells this cell connects to on the next layer down
   */
  //	@SuppressWarnings("unchecked")
  List<GraphAbstractHierarchyCell> getPreviousLayerConnectedCells(int layer) {
    if (_previousLayerConnectedCells == null) {
      _previousLayerConnectedCells = new List<ArrayList>(temp.length);

      for (int i = 0; i < _previousLayerConnectedCells.length; i++) {
        _previousLayerConnectedCells[i] = new List<GraphAbstractHierarchyCell>(2);

        if (i == 0) {
          _previousLayerConnectedCells[i].add(target);
        } else {
          _previousLayerConnectedCells[i].add(this);
        }
      }
    }

    return _previousLayerConnectedCells[layer - minRank - 1];
  }

  /**
   * 
   * @return whether or not this cell is an edge
   */
  bool isEdge() {
    return true;
  }

  /**
   * 
   * @return whether or not this cell is a node
   */
  bool isVertex() {
    return false;
  }

  /**
   * Gets the value of temp for the specified layer
   * 
   * @param layer
   *            the layer relating to a specific entry into temp
   * @return the value for that layer
   */
  int getGeneralPurposeVariable(int layer) {
    return temp[layer - minRank - 1];
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
    temp[layer - minRank - 1] = value;
  }

}
