/*
 * Copyright (c) 2005-2009, JGraph Ltd
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
 * Performs a vertex ordering within ranks as described by Gansner et al 1993
 */
class MedianHybridCrossingReduction implements HierarchicalLayoutStage /*, JGraphLayout.Stoppable*/
{
  /**
   * Reference to the enclosing layout algorithm
   */
  HierarchicalLayout _layout;

  /**
   * The maximum number of iterations to perform whilst reducing edge
   * crossings
   */
  int _maxIterations = 24;

  /**
   * Stores each rank as a collection of cells in the best order found for
   * each layer so far
   */
  List<List<GraphAbstractHierarchyCell>> _nestedBestRanks = null;

  /**
   * The total number of crossings found in the best configuration so far
   */
  int _currentBestCrossings = 0;

  int _iterationsWithoutImprovement = 0;

  int _maxNoImprovementIterations = 2;

  /**
   * Constructor that has the roots specified
   */
  MedianHybridCrossingReduction(HierarchicalLayout layout) {
    this._layout = layout;
  }

  /**
   * Performs a vertex ordering within ranks as described by Gansner et al
   * 1993
   */
  void execute(Object parent) {
    GraphHierarchyModel model = _layout.getModel();

    // Stores initial ordering as being the best one found so far
    _nestedBestRanks = new List<List<GraphAbstractHierarchyCell>>(model.ranks.length);

    for (int i = 0; i < _nestedBestRanks.length; i++) {
      GraphHierarchyRank rank = model.ranks.get(new int(i));
      _nestedBestRanks[i] = new List<GraphAbstractHierarchyCell>(rank.length);
      rank.toArray(_nestedBestRanks[i]);
    }

    _iterationsWithoutImprovement = 0;
    _currentBestCrossings = _calculateCrossings(model);

    for (int i = 0; i < _maxIterations && _iterationsWithoutImprovement < _maxNoImprovementIterations; i++) {
      _weightedMedian(i, model);
      _transpose(i, model);
      int candidateCrossings = _calculateCrossings(model);

      if (candidateCrossings < _currentBestCrossings) {
        _currentBestCrossings = candidateCrossings;
        _iterationsWithoutImprovement = 0;

        // Store the current rankings as the best ones
        for (int j = 0; j < _nestedBestRanks.length; j++) {
          GraphHierarchyRank rank = model.ranks.get(new int(j));
          Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

          for (int k = 0; k < rank.length; k++) {
            GraphAbstractHierarchyCell cell = iter.current();
            _nestedBestRanks[j][cell.getGeneralPurposeVariable(j)] = cell;
          }
        }
      } else {
        // Increase count of iterations where we haven't improved the
        // layout
        _iterationsWithoutImprovement++;

        // Restore the best values to the cells
        for (int j = 0; j < _nestedBestRanks.length; j++) {
          GraphHierarchyRank rank = model.ranks.get(new int(j));
          Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

          for (int k = 0; k < rank.length; k++) {
            GraphAbstractHierarchyCell cell = iter.current();
            cell.setGeneralPurposeVariable(j, k);
          }
        }
      }

      if (_currentBestCrossings == 0) {
        // Do nothing further
        break;
      }
    }

    // Store the best rankings but in the model
    Map<int, GraphHierarchyRank> ranks = new LinkedHashMap<int, GraphHierarchyRank>(model.maxRank + 1);
    List<GraphHierarchyRank> rankList = new List<GraphHierarchyRank>(model.maxRank + 1);

    for (int i = 0; i < model.maxRank + 1; i++) {
      rankList[i] = new GraphHierarchyRank();
      ranks.put(new int(i), rankList[i]);
    }

    for (int i = 0; i < _nestedBestRanks.length; i++) {
      for (int j = 0; j < _nestedBestRanks[i].length; j++) {
        rankList[i].add(_nestedBestRanks[i][j]);
      }
    }

    model.ranks = ranks;
  }

  /**
   * Calculates the total number of edge crossing in the current graph
   * 
   * @param model
   *            the internal model describing the hierarchy
   * @return the current number of edge crossings in the hierarchy graph model
   *         in the current candidate layout
   */
  int _calculateCrossings(GraphHierarchyModel model) {
    // The intra-rank order of cells are stored within the temp variables
    // on cells
    int numRanks = model.ranks.length;
    int totalCrossings = 0;

    for (int i = 1; i < numRanks; i++) {
      totalCrossings += _calculateRankCrossing(i, model);
    }

    return totalCrossings;
  }

  /**
   * Calculates the number of edges crossings between the specified rank and
   * the rank below it
   * 
   * @param i
   *            the topmost rank of the pair ( higher rank value )
   * @param model
   *            the internal hierarchy model of the graph
   * @return the number of edges crossings with the rank beneath
   */
  int _calculateRankCrossing(int i, GraphHierarchyModel model) {
    int totalCrossings = 0;
    GraphHierarchyRank rank = model.ranks.get(new int(i));
    GraphHierarchyRank previousRank = model.ranks.get(new int(i - 1));

    // Create an array of connections between these two levels
    int currentRankSize = rank.length;
    int previousRankSize = previousRank.length;
    List<List<int>> connections = new List<int>(currentRankSize);//[previousRankSize];
    for (int j = 0; j < currentRankSize; j++) {
      connections[j] = new List<int>(previousRankSize);
    }

    // Iterate over the top rank and fill in the connection information
    Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

    while (iter.moveNext()) {
      GraphAbstractHierarchyCell cell = iter.current();
      int rankPosition = cell.getGeneralPurposeVariable(i);
      Iterable<GraphAbstractHierarchyCell> connectedCells = cell.getPreviousLayerConnectedCells(i);
      Iterator<GraphAbstractHierarchyCell> iter2 = connectedCells.iterator;

      while (iter2.moveNext()) {
        GraphAbstractHierarchyCell connectedCell = iter2.current();
        int otherCellRankPosition = connectedCell.getGeneralPurposeVariable(i - 1);
        connections[rankPosition][otherCellRankPosition] = 201207;
      }
    }

    // Iterate through the connection matrix, crossing edges are
    // indicated by other connected edges with a greater rank position
    // on one rank and lower position on the other
    for (int j = 0; j < currentRankSize; j++) {
      for (int k = 0; k < previousRankSize; k++) {
        if (connections[j][k] == 201207) {
          // Draw a grid of connections, crossings are top right
          // and lower left from this crossing pair
          for (int j2 = j + 1; j2 < currentRankSize; j2++) {
            for (int k2 = 0; k2 < k; k2++) {
              if (connections[j2][k2] == 201207) {
                totalCrossings++;
              }
            }
          }

          for (int j2 = 0; j2 < j; j2++) {
            for (int k2 = k + 1; k2 < previousRankSize; k2++) {
              if (connections[j2][k2] == 201207) {
                totalCrossings++;
              }
            }
          }

        }
      }
    }

    return totalCrossings / 2;
  }

  /**
   * Takes each possible adjacent cell pair on each rank and checks if
   * swapping them around reduces the number of crossing
   * 
   * @param mainLoopIteration
   *            the iteration number of the main loop
   * @param model
   *            the internal model describing the hierarchy
   */
  void _transpose(int mainLoopIteration, GraphHierarchyModel model) {
    bool improved = true;

    // Track the number of iterations in case of looping
    int count = 0;
    int maxCount = 10;

    while (improved && count++ < maxCount) {
      // On certain iterations allow allow swapping of cell pairs with
      // equal edge crossings switched or not switched. This help to
      // nudge a stuck layout into a lower crossing total.
      bool nudge = mainLoopIteration % 2 == 1 && count % 2 == 1;
      improved = false;

      for (int i = 0; i < model.ranks.length; i++) {
        GraphHierarchyRank rank = model.ranks.get(new int(i));
        List<GraphAbstractHierarchyCell> orderedCells = new List<GraphAbstractHierarchyCell>(rank.length);
        Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

        for (int j = 0; j < orderedCells.length; j++) {
          GraphAbstractHierarchyCell cell = iter.current();
          orderedCells[cell.getGeneralPurposeVariable(i)] = cell;
        }

        List<GraphAbstractHierarchyCell> leftCellAboveConnections = null;
        List<GraphAbstractHierarchyCell> leftCellBelowConnections = null;
        List<GraphAbstractHierarchyCell> rightCellAboveConnections = null;
        List<GraphAbstractHierarchyCell> rightCellBelowConnections = null;

        List<int> leftAbovePositions = null;
        List<int> leftBelowPositions = null;
        List<int> rightAbovePositions = null;
        List<int> rightBelowPositions = null;

        GraphAbstractHierarchyCell leftCell = null;
        GraphAbstractHierarchyCell rightCell = null;

        for (int j = 0; j < (rank.length - 1); j++) {
          // For each intra-rank adjacent pair of cells
          // see if swapping them around would reduce the
          // number of edges crossing they cause in total
          // On every cell pair except the first on each rank, we
          // can save processing using the previous values for the
          // right cell on the new left cell
          if (j == 0) {
            leftCell = orderedCells[j];
            leftCellAboveConnections = leftCell.getNextLayerConnectedCells(i);
            leftCellBelowConnections = leftCell.getPreviousLayerConnectedCells(i);

            leftAbovePositions = new List<int>(leftCellAboveConnections.length);
            leftBelowPositions = new List<int>(leftCellBelowConnections.length);

            for (int k = 0; k < leftAbovePositions.length; k++) {
              leftAbovePositions[k] = leftCellAboveConnections.get(k).getGeneralPurposeVariable(i + 1);
            }

            for (int k = 0; k < leftBelowPositions.length; k++) {
              leftBelowPositions[k] = (leftCellBelowConnections.get(k)).getGeneralPurposeVariable(i - 1);
            }
          } else {
            leftCellAboveConnections = rightCellAboveConnections;
            leftCellBelowConnections = rightCellBelowConnections;
            leftAbovePositions = rightAbovePositions;
            leftBelowPositions = rightBelowPositions;
            leftCell = rightCell;
          }

          rightCell = orderedCells[j + 1];
          rightCellAboveConnections = rightCell.getNextLayerConnectedCells(i);
          rightCellBelowConnections = rightCell.getPreviousLayerConnectedCells(i);

          rightAbovePositions = new List<int>(rightCellAboveConnections.length);
          rightBelowPositions = new List<int>(rightCellBelowConnections.length);

          for (int k = 0; k < rightAbovePositions.length; k++) {
            rightAbovePositions[k] = (rightCellAboveConnections.get(k)).getGeneralPurposeVariable(i + 1);
          }

          for (int k = 0; k < rightBelowPositions.length; k++) {
            rightBelowPositions[k] = (rightCellBelowConnections.get(k)).getGeneralPurposeVariable(i - 1);
          }

          int totalCurrentCrossings = 0;
          int totalSwitchedCrossings = 0;

          for (int k = 0; k < leftAbovePositions.length; k++) {
            for (int ik = 0; ik < rightAbovePositions.length; ik++) {
              if (leftAbovePositions[k] > rightAbovePositions[ik]) {
                totalCurrentCrossings++;
              }

              if (leftAbovePositions[k] < rightAbovePositions[ik]) {
                totalSwitchedCrossings++;
              }
            }
          }

          for (int k = 0; k < leftBelowPositions.length; k++) {
            for (int ik = 0; ik < rightBelowPositions.length; ik++) {
              if (leftBelowPositions[k] > rightBelowPositions[ik]) {
                totalCurrentCrossings++;
              }

              if (leftBelowPositions[k] < rightBelowPositions[ik]) {
                totalSwitchedCrossings++;
              }
            }
          }

          if ((totalSwitchedCrossings < totalCurrentCrossings) || (totalSwitchedCrossings == totalCurrentCrossings && nudge)) {
            int temp = leftCell.getGeneralPurposeVariable(i);
            leftCell.setGeneralPurposeVariable(i, rightCell.getGeneralPurposeVariable(i));
            rightCell.setGeneralPurposeVariable(i, temp);
            // With this pair exchanged we have to switch all of
            // values for the left cell to the right cell so the
            // next iteration for this rank uses it as the left
            // cell again
            rightCellAboveConnections = leftCellAboveConnections;
            rightCellBelowConnections = leftCellBelowConnections;
            rightAbovePositions = leftAbovePositions;
            rightBelowPositions = leftBelowPositions;
            rightCell = leftCell;

            if (!nudge) {
              // Don't count nudges as improvement or we'll end
              // up stuck in two combinations and not finishing
              // as early as we should
              improved = true;
            }
          }
        }
      }
    }
  }

  /**
   * Sweeps up or down the layout attempting to minimise the median placement
   * of connected cells on adjacent ranks
   * 
   * @param iteration
   *            the iteration number of the main loop
   * @param model
   *            the internal model describing the hierarchy
   */
  void _weightedMedian(int iteration, GraphHierarchyModel model) {
    // Reverse sweep direction each time through this method
    bool downwardSweep = (iteration % 2 == 0);

    if (downwardSweep) {
      for (int j = model.maxRank - 1; j >= 0; j--) {
        _medianRank(j, downwardSweep);
      }
    } else {
      for (int j = 1; j < model.maxRank; j++) {
        _medianRank(j, downwardSweep);
      }
    }
  }

  /**
   * Attempts to minimise the median placement of connected cells on this rank
   * and one of the adjacent ranks
   * 
   * @param rankValue
   *            the layer number of this rank
   * @param downwardSweep
   *            whether or not this is a downward sweep through the graph
   */
  void _medianRank(int rankValue, bool downwardSweep) {
    int numCellsForRank = _nestedBestRanks[rankValue].length;
    ArrayList<_MedianCellSorter> medianValues = new List<_MedianCellSorter>(numCellsForRank);
    List<boolean> reservedPositions = new List<boolean>(numCellsForRank);

    for (int i = 0; i < numCellsForRank; i++) {
      GraphAbstractHierarchyCell cell = _nestedBestRanks[rankValue][i];
      _MedianCellSorter sorterEntry = new _MedianCellSorter();
      sorterEntry.cell = cell;

      // Flip whether or not equal medians are flipped on up and down
      // sweeps
      // todo reimplement some kind of nudging depending on sweep
      //nudge = !downwardSweep;
      Iterable<GraphAbstractHierarchyCell> nextLevelConnectedCells;

      if (downwardSweep) {
        nextLevelConnectedCells = cell.getNextLayerConnectedCells(rankValue);
      } else {
        nextLevelConnectedCells = cell.getPreviousLayerConnectedCells(rankValue);
      }

      int nextRankValue;

      if (downwardSweep) {
        nextRankValue = rankValue + 1;
      } else {
        nextRankValue = rankValue - 1;
      }

      if (nextLevelConnectedCells != null && nextLevelConnectedCells.length != 0) {
        sorterEntry.medianValue = _medianValue(nextLevelConnectedCells, nextRankValue);
        medianValues.add(sorterEntry);
      } else {
        // Nodes with no adjacent vertices are flagged in the reserved array
        // to indicate they should be left in their current position.
        reservedPositions[cell.getGeneralPurposeVariable(rankValue)] = true;
      }
    }

    List<_MedianCellSorter> medianArray = medianValues.toArray(new List<_MedianCellSorter>(medianValues.length));
    Arrays.sort(medianArray);

    // Set the new position of each node within the rank using
    // its temp variable
    int index = 0;

    for (int i = 0; i < numCellsForRank; i++) {
      if (!reservedPositions[i]) {
        _MedianCellSorter wrapper = medianArray[index++];
        wrapper.cell.setGeneralPurposeVariable(rankValue, i);
      }
    }
  }

  /**
   * Calculates the median rank order positioning for the specified cell using
   * the connected cells on the specified rank
   * 
   * @param connectedCells
   *            the cells on the specified rank connected to the specified
   *            cell
   * @param rankValue
   *            the rank that the connected cell lie upon
   * @return the median rank ordering value of the connected cells
   */
  double _medianValue(Iterable<GraphAbstractHierarchyCell> connectedCells, int rankValue) {
    List<double> medianValues = new List<double>(connectedCells.length);
    int arrayCount = 0;
    Iterator<GraphAbstractHierarchyCell> iter = connectedCells.iterator();

    while (iter.moveNext()) {
      medianValues[arrayCount++] = (iter.next()).getGeneralPurposeVariable(rankValue);
    }

    Arrays.sort(medianValues);

    if (arrayCount % 2 == 1) {
      // For odd numbers of adjacent vertices return the median
      return medianValues[arrayCount / 2];
    } else if (arrayCount == 2) {
      return ((medianValues[0] + medianValues[1]) / 2.0);
    } else {
      int medianPoint = arrayCount / 2;
      double leftMedian = medianValues[medianPoint - 1] - medianValues[0];
      double rightMedian = medianValues[arrayCount - 1] - medianValues[medianPoint];

      return (medianValues[medianPoint - 1] * rightMedian + medianValues[medianPoint] * leftMedian) / (leftMedian + rightMedian);
    }
  }
}
