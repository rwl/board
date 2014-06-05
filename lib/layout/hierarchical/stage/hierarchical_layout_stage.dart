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
part of graph.layout.hierarchical.stage;

/**
 * The specific layout interface for hierarchical layouts. It adds a
 * <code>run</code> method with a parameter for the hierarchical layout model
 * that is shared between the layout stages.
 */
abstract class HierarchicalLayoutStage {

  /**
   * Takes the graph detail and configuration information within the facade
   * and creates the resulting laid out graph within that facade for further
   * use.
   */
  void execute(Object parent);

}


/**
 * Utility class that stores a collection of vertices and edge points within
 * a certain area. This area includes the buffer lengths of cells.
 */
class _AreaSpatialCache extends Rectangle2D.Double {
  Set<Object> cells = new HashSet<Object>();
}

/**
 * A utility class used to track cells whilst sorting occurs on the median
 * values. Does not violate (x.compareTo(y)==0) == (x.equals(y))
 */
class _MedianCellSorter implements Comparable<Object> {

  /**
   * The median value of the cell stored
   */
  double medianValue = 0.0;

  /**
   * The cell whose median value is being calculated
   */
  GraphAbstractHierarchyCell cell = null;

  /**
   * comparator on the medianValue
   * 
   * @param arg0
   *            the object to be compared to
   * @return the standard return you would expect when comparing two
   *         double
   */
  int compareTo(Object arg0) {
    if (arg0 is _MedianCellSorter) {
      if (medianValue < (arg0 as _MedianCellSorter).medianValue) {
        return -1;
      } else if (medianValue > (arg0 as _MedianCellSorter).medianValue) {
        return 1;
      }
    }

    return 0;
  }
}

/**
 * A utility class used to track cells whilst sorting occurs on the weighted
 * sum of their connected edges. Does not violate (x.compareTo(y)==0) ==
 * (x.equals(y))
 */
class _WeightedCellSorter implements Comparable<Object> {

  /**
   * The weighted value of the cell stored
   */
  int weightedValue = 0;

  /**
   * Whether or not to flip equal weight values.
   */
  bool nudge = false;

  /**
   * Whether or not this cell has been visited in the current assignment
   */
  bool visited = false;

  /**
   * The index this cell is in the model rank
   */
  int rankIndex;

  /**
   * The cell whose median value is being calculated
   */
  GraphAbstractHierarchyCell cell = null;

  //  _WeightedCellSorter()
  //  {
  //    this(null, 0);
  //  }

  _WeightedCellSorter([GraphAbstractHierarchyCell cell = null, int weightedValue = 0]) {
    this.cell = cell;
    this.weightedValue = weightedValue;
  }

  /**
   * comparator on the medianValue
   * 
   * @param arg0
   *            the object to be compared to
   * @return the standard return you would expect when comparing two
   *         double
   */
  int compareTo(Object arg0) {
    if (arg0 is _WeightedCellSorter) {
      if (weightedValue > (arg0 as _WeightedCellSorter).weightedValue) {
        return -1;
      } else if (weightedValue < (arg0 as _WeightedCellSorter).weightedValue) {
        return 1;
      }
    }

    return 0;
  }
}
