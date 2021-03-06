/**
 * Copyright (c) 2007-2013, JGraph Ltd
 */

part of graph.layout;

//import java.awt.geom.awt.Line2D;
//import java.awt.geom.Point2D;
//import java.awt.geom.Rectangle2D;

/**
 * An implementation of a simulated annealing layout, based on "Drawing Graphs
 * Nicely Using Simulated Annealing" by Davidson and Harel (1996). This
 * paper describes these criteria as being favourable in a graph layout: (1)
 * distributing nodes evenly, (2) making edge-lengths uniform, (3)
 * minimizing cross-crossings, and (4) keeping nodes from coming too close
 * to edges. These criteria are translated into energy cost functions in the
 * layout. Nodes or edges breaking these criteria create a larger cost function
 * , the total cost they contribute related to the extent that they break it.
 * The idea of the algorithm is to minimise the total system energy. Factors
 * are assigned to each of the criteria describing how important that
 * criteria is. Higher factors mean that those criteria are deemed to be
 * relatively preferable in the final layout. Most of  the criteria conflict
 * with the others to some extent and so the setting of the factors determines
 * the general look of the resulting graph.
 * <p>
 * In addition to the four aesthetic criteria the concept of a border line
 * which induces an energy cost to nodes in proximity to the graph bounds is
 * introduced to attempt to restrain the graph. All of the 5 factors can be
 * switched on or off using the <code>isOptimize...</code> variables.
 * <p>
 * Simulated Annealing is a force-directed layout and is one of the more
 * expensive, but generally effective layouts of this type. Layouts like
 * the spring layout only really factor in edge length and inter-node
 * distance being the lowest CPU intensive for the most aesthetic gain. The
 * additional factors are more expensive but can have very attractive results.
 * <p>
 * The main loop of the algorithm consist of processing the nodes in a 
 * deterministic order. During the processing of each node a circle of radius
 * <code>moveRadius</code> is made around the node and split into
 * <code>triesPerCell</code> equal segments. Each point between neighbour
 * segments is determined and the new energy of the system if the node were
 * moved to that position calculated. Only the necessary nodes and edges are
 * processed new energy values resulting in quadratic performance, O(VE),
 * whereas calculating the total system energy would be cubic. The default
 * implementation only checks 8 points around the radius of the circle, as
 * opposed to the suggested 30 in the paper. Doubling the number of points
 * double the CPU load and 8 works almost as well as 30.
 * <p>
 * The <code>moveRadius</code> replaces the temperature as the influencing
 * factor in the way the graph settles in later iterations. If the user does
 * not set the initial move radius it is set to half the maximum dimension
 * of the graph. Thus, in 2 iterations a node may traverse the entire graph,
 * and it is more sensible to find minima this way that uphill moves, which
 * are little more than an expensive 'tilt' method. The factor by which
 * the radius is multiplied by after each iteration is important, lowering
 * it improves performance but raising it towards 1.0 can improve the
 * resulting graph aesthetics. When the radius hits the minimum move radius
 * defined, the layout terminates. The minimum move radius should be set
 * a value where the move distance is too minor to be of interest.
 * <p>
 * Also, the idea of a fine tuning phase is used, as described in the paper.
 * This involves only calculating the edge to node distance energy cost
 * at the end of the algorithm since it is an expensive calculation and
 * it really an 'optimizating' function. <code>fineTuningRadius</code>
 * defines the radius value that, when reached, causes the edge to node
 * distance to be calculated.
 * <p>
 * There are other special cases that are processed after each iteration.
 * <code>unchangedEnergyRoundTermination</code> defines the number of
 * iterations, after which the layout terminates. If nothing is being moved
 * it is assumed a good layout has been found. In addition to this if
 * no nodes are moved during an iteration the move radius is halved, presuming
 * that a finer granularity is required.
 * 
 */
class OrganicLayout extends GraphLayout {

  /**
   * Whether or not the distance between edge and nodes will be calculated
   * as an energy cost function. This function is CPU intensive and is best
   * only used in the fine tuning phase.
   */
  bool isOptimizeEdgeDistance = true;

  /**
   * Whether or not edges crosses will be calculated as an energy cost
   * function. This function is CPU intensive, though if some iterations
   * without it are required, it is best to have a few cycles at the start
   * of the algorithm using it, then use it intermittantly through the rest
   * of the layout.
   */
  bool isOptimizeEdgeCrossing = true;

  /**
   * Whether or not edge lengths will be calculated as an energy cost
   * function. This function not CPU intensive.
   */
  bool isOptimizeEdgeLength = true;

  /**
   * Whether or not nodes will contribute an energy cost as they approach
   * the bound of the graph. The cost increases to a limit close to the
   * border and stays constant outside the bounds of the graph. This function
   * is not CPU intensive
   */
  bool isOptimizeBorderLine = true;

  /**
   * Whether or not node distribute will contribute an energy cost where
   * nodes are close together. The function is moderately CPU intensive.
   */
  bool isOptimizeNodeDistribution = true;

  /**
   * when {@link #moveRadius}reaches this value, the algorithm is terminated
   */
  double minMoveRadius = 2.0;

  /**
   * The current radius around each node where the next position energy
   * values will be calculated for a possible move
   */
  double moveRadius;

  /**
   * The initial value of <code>moveRadius</code>. If this is set to zero
   * the layout will automatically determine a suitable value.
   */
  double initialMoveRadius = 0.0;

  /**
   * The factor by which the <code>moveRadius</code> is multiplied by after
   * every iteration. A value of 0.75 is a good balance between performance
   * and aesthetics. Increasing the value provides more chances to find
   * minimum energy positions and decreasing it causes the minimum radius
   * termination condition to occur more quickly.
   */
  double radiusScaleFactor = 0.75;

  /**
   * The average amount of area allocated per node. If <code> bounds</code>
   * is not set this value mutiplied by the number of nodes to find
   * the total graph area. The graph is assumed square.
   */
  double averageNodeArea = 160000.0;

  /**
   * The radius below which fine tuning of the layout should start
   * This involves allowing the distance between nodes and edges to be
   * taken into account in the total energy calculation. If this is set to
   * zero, the layout will automatically determine a suitable value
   */
  double fineTuningRadius = 40.0;

  /**
   * Limit to the number of iterations that may take place. This is only
   * reached if one of the termination conditions does not occur first.
   */
  int maxIterations = 1000;

  /**
   * Cost factor applied to energy calculations involving the distance
   * nodes and edges. Increasing this value tends to cause nodes to move away
   * from edges, at the partial cost of other graph aesthetics.
   * <code>isOptimizeEdgeDistance</code> must be true for edge to nodes
   * distances to be taken into account.
   */
  double edgeDistanceCostFactor = 3000.0;

  /**
   * Cost factor applied to energy calculations involving edges that cross
   * over one another. Increasing this value tends to result in fewer edge
   * crossings, at the partial cost of other graph aesthetics.
   * <code>isOptimizeEdgeCrossing</code> must be true for edge crossings
   * to be taken into account.
   */
  double edgeCrossingCostFactor = 6000.0;

  /**
   * Cost factor applied to energy calculations involving the general node
   * distribution of the graph. Increasing this value tends to result in
   * a better distribution of nodes across the available space, at the
   * partial cost of other graph aesthetics.
   * <code>isOptimizeNodeDistribution</code> must be true for this general
   * distribution to be applied.
   */
  double nodeDistributionCostFactor = 30000.0;

  /**
   * Cost factor applied to energy calculations for node promixity to the
   * notional border of the graph. Increasing this value results in
   * nodes tending towards the centre of the drawing space, at the
   * partial cost of other graph aesthetics.
   * <code>isOptimizeBorderLine</code> must be true for border
   * repulsion to be applied.
   */
  double borderLineCostFactor = 5.0;

  /**
   * Cost factor applied to energy calculations for the edge lengths.
   * Increasing this value results in the layout attempting to shorten all
   * edges to the minimum edge length, at the partial cost of other graph
   * aesthetics.
   * <code>isOptimizeEdgeLength</code> must be true for edge length
   * shortening to be applied.
   */
  double edgeLengthCostFactor = 0.02;

  /**
   * The x coordinate of the final graph
   */
  double boundsX = 0.0;

  /**
   * The y coordinate of the final graph
   */
  double boundsY = 0.0;

  /**
   * The width coordinate of the final graph
   */
  double boundsWidth = 0.0;

  /**
   * The height coordinate of the final graph
   */
  double boundsHeight = 0.0;

  /**
   * current iteration number of the layout
   */
  int iteration;

  /**
   * determines, in how many segments the circle around cells is divided, to
   * find a new position for the cell. Doubling this value doubles the CPU
   * load. Increasing it beyond 16 might mean a change to the
   * <code>performRound</code> method might further improve accuracy for a
   * small performance hit. The change is described in the method comment.
   */
  int triesPerCell = 8;

  /**
   * prevents from dividing with zero and from creating excessive energy
   * values
   */
  double minDistanceLimit = 2.0;

  /**
   * cached version of <code>minDistanceLimit</code> squared
   */
  double minDistanceLimitSquared;

  /**
   * distance limit beyond which energy costs due to object repulsive is
   * not calculated as it would be too insignificant
   */
  double maxDistanceLimit = 100.0;

  /**
   * cached version of <code>maxDistanceLimit</code> squared
   */
  double maxDistanceLimitSquared;

  /**
   * Keeps track of how many consecutive round have passed without any energy
   * changes 
   */
  int unchangedEnergyRoundCount;

  /**
   * The number of round of no node moves taking placed that the layout
   * terminates
   */
  int unchangedEnergyRoundTermination = 5;

  /**
   * Whether or not to use approximate node dimensions or not. Set to true
   * the radius squared of the smaller dimension is used. Set to false the
   * radiusSquared variable of the CellWrapper contains the width squared
   * and heightSquared is used in the obvious manner.
   */
  bool approxNodeDimensions = true;

  /**
   * Internal models collection of nodes ( vertices ) to be laid out
   */
  List<CellWrapper> v;

  /**
   * Internal models collection of edges to be laid out
   */
  List<CellWrapper> e;

  /**
   * Array of the x portion of the normalised test vectors that 
   * are tested for a lower energy around each vertex. The vector 
   * of the combined x and y normals are multipled by the current 
   * radius to obtain test points for each vector in the array.
   */
  List<double> xNormTry;

  /**
   * Array of the y portion of the normalised test vectors that 
   * are tested for a lower energy around each vertex. The vector 
   * of the combined x and y normals are multipled by the current 
   * radius to obtain test points for each vector in the array.
   */
  List<double> yNormTry;

  /**
   * Whether or not fine tuning is on. The determines whether or not
   * node to edge distances are calculated in the total system energy.
   * This cost function , besides detecting line intersection, is a
   * performance intensive component of this algorithm and best left
   * to optimization phase. <code>isFineTuning</code> is switched to
   * <code>true</code> if and when the <code>fineTuningRadius</code>
   * radius is reached. Switching this variable to <code>true</code>
   * before the algorithm runs mean the node to edge cost function
   * is always calculated.
   */
  bool isFineTuning = true;

  /**
   *  Specifies if the STYLE_NOEDGESTYLE flag should be set on edges that are
   * modified by the result. Default is true.
   */
  bool disableEdgeStyle = true;

  /**
   * Specifies if all edge points of traversed edges should be removed.
   * Default is true.
   */
  bool resetEdges = false;

  /**
   * Constructor for OrganicLayout.
   */
  //	OrganicLayout(Graph graph)
  //	{
  //		super(graph);
  //	}

  /**
   * Constructor for OrganicLayout.
   */
  OrganicLayout(Graph graph, [awt.Rectangle bounds = null]) : super(graph) {
    if (bounds != null) {
      boundsX = bounds.getX();
      boundsY = bounds.getY();
      boundsWidth = bounds.getWidth();
      boundsHeight = bounds.getHeight();
    }
  }

  /**
   * Returns true if the given vertex has no connected edges.
   * 
   * @param vertex Object that represents the vertex to be tested.
   * @return Returns true if the vertex should be ignored.
   */
  bool isVertexIgnored(Object vertex) {
    return false;
  }

  /**
   * Implements <GraphLayout.execute>.
   */
  void execute(Object parent) {
    IGraphModel model = graph.getModel();
    GraphView view = graph.getView();
    List<Object> vertices = graph.getChildVertices(parent);
    HashSet<Object> vertexSet = new HashSet<Object>.from(vertices);

    HashSet<Object> validEdges = new HashSet<Object>();

    // Remove edges that do not have both source and target terminals visible
    for (int i = 0; i < vertices.length; i++) {
      List<Object> edges = GraphModel.getEdges(model, vertices[i], false, true, false);

      for (int j = 0; j < edges.length; j++) {
        // Only deal with sources. To be valid in the layout, each edge must be attached
        // at both source and target to a vertex in the layout. Doing this avoids processing
        // each edge twice.
        if (view.getVisibleTerminal(edges[j], true) == vertices[i] && vertexSet.contains(view.getVisibleTerminal(edges[j], false))) {
          validEdges.add(edges[j]);
        }
      }

    }

    List<Object> edges = new List<Object>.from(validEdges);

    // If the bounds dimensions have not been set see if the average area
    // per node has been
    Rect totalBounds = null;
    Rect bounds = null;

    // Form internal model of nodes
    Map<Object, int> vertexMap = new Map<Object, int>();
    v = new List<CellWrapper>(vertices.length);
    for (int i = 0; i < vertices.length; i++) {
      v[i] = new CellWrapper(vertices[i]);
      vertexMap[vertices[i]] = i;
      bounds = getVertexBounds(vertices[i]);

      if (totalBounds == null) {
        totalBounds = bounds.clone() as Rect;
      } else {
        totalBounds.add(bounds);
      }

      // Set the X,Y value of the internal version of the cell to
      // the center point of the vertex for better positioning
      double width = bounds.getWidth();
      double height = bounds.getHeight();
      v[i].x = bounds.getX() + width / 2.0;
      v[i].y = bounds.getY() + height / 2.0;
      if (approxNodeDimensions) {
        v[i].radiusSquared = Math.min(width, height);
        v[i].radiusSquared *= v[i].radiusSquared;
      } else {
        v[i].radiusSquared = width * width;
        v[i].heightSquared = height * height;
      }
    }

    if (averageNodeArea == 0.0) {
      if (boundsWidth == 0.0 && totalBounds != null) {
        // Just use current bounds of graph
        boundsX = totalBounds.getX();
        boundsY = totalBounds.getY();
        boundsWidth = totalBounds.getWidth();
        boundsHeight = totalBounds.getHeight();
      }
    } else {
      // find the center point of the current graph
      // based the new graph bounds on the average node area set
      double newArea = averageNodeArea * vertices.length;
      double squareLength = Math.sqrt(newArea);
      if (bounds != null) {
        double centreX = totalBounds.getX() + totalBounds.getWidth() / 2.0;
        double centreY = totalBounds.getY() + totalBounds.getHeight() / 2.0;
        boundsX = centreX - squareLength / 2.0;
        boundsY = centreY - squareLength / 2.0;
      } else {
        boundsX = 0.0;
        boundsY = 0.0;
      }
      boundsWidth = squareLength;
      boundsHeight = squareLength;
      // Ensure x and y are 0 or positive
      if (boundsX < 0.0 || boundsY < 0.0) {
        double maxNegativeAxis = Math.min(boundsX, boundsY);
        double axisOffset = -maxNegativeAxis;
        boundsX += axisOffset;
        boundsY += axisOffset;
      }
    }

    // If the initial move radius has not been set find a suitable value.
    // A good value is half the maximum dimension of the final graph area
    if (initialMoveRadius == 0.0) {
      initialMoveRadius = Math.max(boundsWidth, boundsHeight) / 2.0;
    }

    moveRadius = initialMoveRadius;

    minDistanceLimitSquared = minDistanceLimit * minDistanceLimit;
    maxDistanceLimitSquared = maxDistanceLimit * maxDistanceLimit;

    unchangedEnergyRoundCount = 0;


    // Form internal model of edges
    e = new List<CellWrapper>(edges.length);

    for (int i = 0; i < e.length; i++) {
      e[i] = new CellWrapper(edges[i]);

      Object sourceCell = model.getTerminal(edges[i], true);
      Object targetCell = model.getTerminal(edges[i], false);
      int source = null;
      int target = null;
      // Check if either end of the edge is not connected
      if (sourceCell != null) {
        source = vertexMap[sourceCell];
      }
      if (targetCell != null) {
        target = vertexMap[targetCell];
      }
      if (source != null) {
        e[i].source = source;
      } else {
        // source end is not connected
        e[i].source = -1;
      }
      if (target != null) {
        e[i].target = target;
      } else {
        // target end is not connected
        e[i].target = -1;
      }
    }

    // Set up internal nodes with information about whether edges
    // are connected to them or not
    for (int i = 0; i < v.length; i++) {
      v[i].relevantEdges = getRelevantEdges(i);
      v[i].connectedEdges = getConnectedEdges(i);
    }

    // Setup the normal vectors for the test points to move each vertex to
    xNormTry = new List<double>(triesPerCell);
    yNormTry = new List<double>(triesPerCell);

    for (int i = 0; i < triesPerCell; i++) {
      double angle = i * ((2.0 * Math.PI) / triesPerCell);
      xNormTry[i] = Math.cos(angle);
      yNormTry[i] = Math.sin(angle);
    }


    int childCount = model.getChildCount(parent);

    for (int i = 0; i < childCount; i++) {
      Object cell = model.getChildAt(parent, i);

      if (!isEdgeIgnored(cell)) {
        if (isResetEdges()) {
          graph.resetEdge(cell);
        }

        if (isDisableEdgeStyle()) {
          setEdgeStyleEnabled(cell, false);
        }
      }
    }

    // The main layout loop
    for (iteration = 0; iteration < maxIterations; iteration++) {
      performRound();
    }

    // Obtain the final positions
    List<List<double>> result = new List<List<double>>(v.length);//[2];
    for (int i = 0; i < v.length; i++) {
      vertices[i] = v[i].cell;
      bounds = getVertexBounds(vertices[i]);

      result[i] = [v[i].x - bounds.getWidth() / 2, v[i].y - bounds.getHeight() / 2];
    }

    model.beginUpdate();
    try {
      for (int i = 0; i < vertices.length; i++) {
        setVertexLocation(vertices[i], result[i][0], result[i][1]);
      }
    } finally {
      model.endUpdate();
    }
  }

  /**
   * The main round of the algorithm. Firstly, a permutation of nodes
   * is created and worked through in that random order. Then, for each node
   * a number of point of a circle of radius <code>moveRadius</code> are
   * selected and the total energy of the system calculated if that node
   * were moved to that new position. If a lower energy position is found
   * this is accepted and the algorithm moves onto the next node. There
   * may be a slightly lower energy value yet to be found, but forcing
   * the loop to check all possible positions adds nearly the current
   * processing time again, and for little benefit. Another possible
   * strategy would be to take account of the fact that the energy values
   * around the circle decrease for half the loop and increase for the
   * other, as a general rule. If part of the decrease were seen, then
   * when the energy of a node increased, the previous node position was
   * almost always the lowest energy position. This adds about two loop
   * iterations to the inner loop and only makes sense with 16 tries or more.
   */
  void performRound() {
    // sequential order cells are computed (every round the same order)

    // bool to keep track of whether any moves were made in this round
    bool energyHasChanged = false;
    for (int i = 0; i < v.length; i++) {
      int index = i;

      // Obtain the energies for the node is its current position
      // TODO The energy could be stored from the last iteration
      // and used again, rather than re-calculate
      double oldNodeDistribution = getNodeDistribution(index);
      double oldEdgeDistance = getEdgeDistanceFromNode(index);
      oldEdgeDistance += getEdgeDistanceAffectedNodes(index);
      double oldEdgeCrossing = getEdgeCrossingAffectedEdges(index);
      double oldBorderLine = getBorderline(index);
      double oldEdgeLength = getEdgeLengthAffectedEdges(index);
      double oldAdditionFactors = getAdditionFactorsEnergy(index);

      for (int j = 0; j < triesPerCell; j++) {
        double movex = moveRadius * xNormTry[j];
        double movey = moveRadius * yNormTry[j];

        // applying new move
        double oldx = v[index].x;
        double oldy = v[index].y;
        v[index].x = v[index].x + movex;
        v[index].y = v[index].y + movey;

        // calculate the energy delta from this move
        double energyDelta = calcEnergyDelta(index, oldNodeDistribution, oldEdgeDistance, oldEdgeCrossing, oldBorderLine, oldEdgeLength, oldAdditionFactors);

        if (energyDelta < 0) {
          // energy of moved node is lower, finish tries for this
          // node
          energyHasChanged = true;
          break; // exits loop
        } else {
          // Revert node coordinates
          v[index].x = oldx;
          v[index].y = oldy;
        }
      }
    }
    // Check if we've hit the limit number of unchanged rounds that cause
    // a termination condition
    if (energyHasChanged) {
      unchangedEnergyRoundCount = 0;
    } else {
      unchangedEnergyRoundCount++;
      // Half the move radius in case assuming it's set too high for
      // what might be an optimisation case
      moveRadius /= 2.0;
    }
    if (unchangedEnergyRoundCount >= unchangedEnergyRoundTermination) {
      iteration = maxIterations;
    }

    // decrement radius in controlled manner
    double newMoveRadius = moveRadius * radiusScaleFactor;
    // Don't waste time on tiny decrements, if the final pixel resolution
    // is 50 then there's no point doing 55,54.1, 53.2 etc
    if (moveRadius - newMoveRadius < minMoveRadius) {
      newMoveRadius = moveRadius - minMoveRadius;
    }
    // If the temperature reaches its minimum temperature then finish
    if (newMoveRadius <= minMoveRadius) {
      iteration = maxIterations;
    }
    // Switch on fine tuning below the specified temperature
    if (newMoveRadius < fineTuningRadius) {
      isFineTuning = true;
    }

    moveRadius = newMoveRadius;

  }

  /**
   * Calculates the change in energy for the specified node. The new energy is
   * calculated from the cost function methods and the old energy values for
   * each cost function are passed in as parameters
   * 
   * @param index
   *            The index of the node in the <code>vertices</code> array
   * @param oldNodeDistribution
   *            The previous node distribution energy cost of this node
   * @param oldEdgeDistance
   *            The previous edge distance energy cost of this node
   * @param oldEdgeCrossing
   *            The previous edge crossing energy cost for edges connected to
   *            this node
   * @param oldBorderLine
   *            The previous border line energy cost for this node
   * @param oldEdgeLength
   *            The previous edge length energy cost for edges connected to
   *            this node
   * @param oldAdditionalFactorsEnergy
   *            The previous energy cost for additional factors from
   *            sub-classes
   * 
   * @return the delta of the new energy cost to the old energy cost
   * 
   */
  double calcEnergyDelta(int index, double oldNodeDistribution, double oldEdgeDistance, double oldEdgeCrossing, double oldBorderLine, double oldEdgeLength, double oldAdditionalFactorsEnergy) {
    double energyDelta = 0.0;
    energyDelta += getNodeDistribution(index) * 2.0;
    energyDelta -= oldNodeDistribution * 2.0;

    energyDelta += getBorderline(index);
    energyDelta -= oldBorderLine;

    energyDelta += getEdgeDistanceFromNode(index);
    energyDelta += getEdgeDistanceAffectedNodes(index);
    energyDelta -= oldEdgeDistance;

    energyDelta -= oldEdgeLength;
    energyDelta += getEdgeLengthAffectedEdges(index);

    energyDelta -= oldEdgeCrossing;
    energyDelta += getEdgeCrossingAffectedEdges(index);

    energyDelta -= oldAdditionalFactorsEnergy;
    energyDelta += getAdditionFactorsEnergy(index);

    return energyDelta;
  }

  /**
   * Calculates the energy cost of the specified node relative to all other
   * nodes. Basically produces a higher energy the closer nodes are together.
   * 
   * @param i the index of the node in the array <code>v</code>
   * @return the total node distribution energy of the specified node 
   */
  double getNodeDistribution(int i) {
    double energy = 0.0;

    // This check is placed outside of the inner loop for speed, even
    // though the code then has to be duplicated
    if (isOptimizeNodeDistribution == true) {
      if (approxNodeDimensions) {
        for (int j = 0; j < v.length; j++) {
          if (i != j) {
            double vx = v[i].x - v[j].x;
            double vy = v[i].y - v[j].y;
            double distanceSquared = vx * vx + vy * vy;
            distanceSquared -= v[i].radiusSquared;
            distanceSquared -= v[j].radiusSquared;

            // prevents from dividing with Zero.
            if (distanceSquared < minDistanceLimitSquared) {
              distanceSquared = minDistanceLimitSquared;
            }

            energy += nodeDistributionCostFactor / distanceSquared;
          }
        }
      } else {
        for (int j = 0; j < v.length; j++) {
          if (i != j) {
            double vx = v[i].x - v[j].x;
            double vy = v[i].y - v[j].y;
            double distanceSquared = vx * vx + vy * vy;
            distanceSquared -= v[i].radiusSquared;
            distanceSquared -= v[j].radiusSquared;
            // If the height separation indicates overlap, subtract
            // the widths from the distance. Same for width overlap
            // TODO						if ()

            // prevents from dividing with Zero.
            if (distanceSquared < minDistanceLimitSquared) {
              distanceSquared = minDistanceLimitSquared;
            }

            energy += nodeDistributionCostFactor / distanceSquared;
          }
        }
      }
    }
    return energy;
  }

  /**
   * This method calculates the energy of the distance of the specified
   * node to the notional border of the graph. The energy increases up to
   * a limited maximum close to the border and stays at that maximum
   * up to and over the border.
   * 
   * @param i the index of the node in the array <code>v</code>
   * @return the total border line energy of the specified node 
   */
  double getBorderline(int i) {
    double energy = 0.0;
    if (isOptimizeBorderLine) {
      // Avoid very small distances and convert negative distance (i.e
      // outside the border to small positive ones )
      double l = v[i].x - boundsX;
      if (l < minDistanceLimit) l = minDistanceLimit;
      double t = v[i].y - boundsY;
      if (t < minDistanceLimit) t = minDistanceLimit;
      double r = boundsX + boundsWidth - v[i].x;
      if (r < minDistanceLimit) r = minDistanceLimit;
      double b = boundsY + boundsHeight - v[i].y;
      if (b < minDistanceLimit) b = minDistanceLimit;
      energy += borderLineCostFactor * ((1000000.0 / (t * t)) + (1000000.0 / (l * l)) + (1000000.0 / (b * b)) + (1000000.0 / (r * r)));
    }
    return energy;
  }

  /**
   * Obtains the energy cost function for the specified node being moved.
   * This involves calling <code>getEdgeLength</code> for all
   * edges connected to the specified node
   * @param node
   * 				the node whose connected edges cost functions are to be
   * 				calculated
   * @return the total edge length energy of the connected edges 
   */
  double getEdgeLengthAffectedEdges(int node) {
    double energy = 0.0;
    for (int i = 0; i < v[node].connectedEdges.length; i++) {
      energy += getEdgeLength(v[node].connectedEdges[i]);
    }
    return energy;
  }

  /**
   * This method calculates the energy due to the length of the specified
   * edge. The energy is proportional to the length of the edge, making
   * shorter edges preferable in the layout.
   * 
   * @param i the index of the edge in the array <code>e</code>
   * @return the total edge length energy of the specified edge 
   */
  double getEdgeLength(int i) {
    if (isOptimizeEdgeLength) {
      double edgeLength = awt.Point.Distance(v[e[i].source].x, v[e[i].source].y, v[e[i].target].x, v[e[i].target].y);
      return (edgeLengthCostFactor * edgeLength * edgeLength);
    } else {
      return 0.0;
    }
  }

  /**
   * Obtains the energy cost function for the specified node being moved.
   * This involves calling <code>getEdgeCrossing</code> for all
   * edges connected to the specified node
   * @param node
   * 				the node whose connected edges cost functions are to be
   * 				calculated
   * @return the total edge crossing energy of the connected edges 
   */
  double getEdgeCrossingAffectedEdges(int node) {
    double energy = 0.0;
    for (int i = 0; i < v[node].connectedEdges.length; i++) {
      energy += getEdgeCrossing(v[node].connectedEdges[i]);
    }

    return energy;
  }

  /**
   * This method calculates the energy of the distance from the specified
   * edge crossing any other edges. Each crossing add a constant factor
   * to the total energy
   * 
   * @param i the index of the edge in the array <code>e</code>
   * @return the total edge crossing energy of the specified edge 
   */
  double getEdgeCrossing(int i) {
    // TODO Could have a cost function per edge
    int n = 0; // counts energy of edgecrossings through edge i

    // max and min variable for minimum bounding rectangles overlapping
    // checks
    double minjX, minjY, miniX, miniY, maxjX, maxjY, maxiX, maxiY;

    if (isOptimizeEdgeCrossing) {
      double iP1X = v[e[i].source].x;
      double iP1Y = v[e[i].source].y;
      double iP2X = v[e[i].target].x;
      double iP2Y = v[e[i].target].y;

      for (int j = 0; j < e.length; j++) {
        double jP1X = v[e[j].source].x;
        double jP1Y = v[e[j].source].y;
        double jP2X = v[e[j].target].x;
        double jP2Y = v[e[j].target].y;
        if (j != i) {
          // First check is to see if the minimum bounding rectangles
          // of the edges overlap at all. Since the layout tries
          // to separate nodes and shorten edges, the majority do not
          // overlap and this is a cheap way to avoid most of the
          // processing
          // Some long code to avoid a Math.max call...
          if (iP1X < iP2X) {
            miniX = iP1X;
            maxiX = iP2X;
          } else {
            miniX = iP2X;
            maxiX = iP1X;
          }
          if (jP1X < jP2X) {
            minjX = jP1X;
            maxjX = jP2X;
          } else {
            minjX = jP2X;
            maxjX = jP1X;
          }
          if (maxiX < minjX || miniX > maxjX) {
            continue;
          }

          if (iP1Y < iP2Y) {
            miniY = iP1Y;
            maxiY = iP2Y;
          } else {
            miniY = iP2Y;
            maxiY = iP1Y;
          }
          if (jP1Y < jP2Y) {
            minjY = jP1Y;
            maxjY = jP2Y;
          } else {
            minjY = jP2Y;
            maxjY = jP1Y;
          }
          if (maxiY < minjY || miniY > maxjY) {
            continue;
          }

          // Ignore if any end points are coincident
          if (((iP1X != jP1X) && (iP1Y != jP1Y)) && ((iP1X != jP2X) && (iP1Y != jP2Y)) && ((iP2X != jP1X) && (iP2Y != jP1Y)) && ((iP2X != jP2X) && (iP2Y != jP2Y))) {
            // Values of zero returned from awt.Line2D.relativeCCW are
            // ignored because the point being exactly on the line
            // is very rare for double and we've already checked if
            // any end point share the same vertex. Should zero
            // ever be returned, it would be the vertex connected
            // to the edge that's actually on the edge and this is
            // dealt with by the node to edge distance cost
            // function. The worst case is that the vertex is
            // pushed off the edge faster than it would be
            // otherwise. Because of ignoring the zero this code
            // below can behave like only a 1 or -1 will be
            // returned. See Lines2D.linesIntersects().
            bool intersects = ((awt.Line2D.RelativeCCW(iP1X, iP1Y, iP2X, iP2Y, jP1X, jP1Y) != awt.Line2D.RelativeCCW(iP1X, iP1Y, iP2X, iP2Y, jP2X, jP2Y)) &&
                (awt.Line2D.RelativeCCW(jP1X, jP1Y, jP2X, jP2Y, iP1X, iP1Y) != awt.Line2D.RelativeCCW(jP1X, jP1Y, jP2X, jP2Y, iP2X, iP2Y)));

            if (intersects) {
              n++;
            }
          }
        }
      }
    }
    return edgeCrossingCostFactor * n;
  }

  /**
   * This method calculates the energy of the distance between Cells and
   * Edges. This version of the edge distance cost calculates the energy
   * cost from a specified <strong>node</strong>. The distance cost to all
   * unconnected edges is calculated and the total returned.
   * 
   * @param i the index of the node in the array <code>v</code>
   * @return the total edge distance energy of the node
   */
  double getEdgeDistanceFromNode(int i) {
    double energy = 0.0;
    // This function is only performed during fine tuning for performance
    if (isOptimizeEdgeDistance && isFineTuning) {
      List<int> edges = v[i].relevantEdges;
      for (int j = 0; j < edges.length; j++) {
        // Note that the distance value is squared
        double distSquare = awt.Line2D.PtSegDistSq(v[e[edges[j]].source].x, v[e[edges[j]].source].y, v[e[edges[j]].target].x, v[e[edges[j]].target].y, v[i].x, v[i].y);

        distSquare -= v[i].radiusSquared;

        // prevents from dividing with Zero. No math.abs() call
        // for performance
        if (distSquare < minDistanceLimitSquared) {
          distSquare = minDistanceLimitSquared;
        }

        // Only bother with the divide if the node and edge are
        // fairly close together
        if (distSquare < maxDistanceLimitSquared) {
          energy += edgeDistanceCostFactor / distSquare;
        }
      }
    }
    return energy;
  }

  /**
   * Obtains the energy cost function for the specified node being moved.
   * This involves calling <code>getEdgeDistanceFromEdge</code> for all
   * edges connected to the specified node
   * @param node
   * 				the node whose connected edges cost functions are to be
   * 				calculated
   * @return the total edge distance energy of the connected edges 
   */
  double getEdgeDistanceAffectedNodes(int node) {
    double energy = 0.0;
    for (int i = 0; i < (v[node].connectedEdges.length); i++) {
      energy += getEdgeDistanceFromEdge(v[node].connectedEdges[i]);
    }

    return energy;
  }

  /**
   * This method calculates the energy of the distance between Cells and
   * Edges. This version of the edge distance cost calculates the energy
   * cost from a specified <strong>edge</strong>. The distance cost to all
   * unconnected nodes is calculated and the total returned.
   * 
   * @param i the index of the edge in the array <code>e</code>
   * @return the total edge distance energy of the edge
   */
  double getEdgeDistanceFromEdge(int i) {
    double energy = 0.0;
    // This function is only performed during fine tuning for performance
    if (isOptimizeEdgeDistance && isFineTuning) {
      for (int j = 0; j < v.length; j++) {
        // Don't calculate for connected nodes
        if (e[i].source != j && e[i].target != j) {
          double distSquare = awt.Line2D.PtSegDistSq(v[e[i].source].x, v[e[i].source].y, v[e[i].target].x, v[e[i].target].y, v[j].x, v[j].y);

          distSquare -= v[j].radiusSquared;

          // prevents from dividing with Zero. No math.abs() call
          // for performance
          if (distSquare < minDistanceLimitSquared) distSquare = minDistanceLimitSquared;

          // Only bother with the divide if the node and edge are
          // fairly close together
          if (distSquare < maxDistanceLimitSquared) {
            energy += edgeDistanceCostFactor / distSquare;
          }
        }
      }
    }
    return energy;
  }

  /**
   * Hook method to adding additional energy factors into the layout.
   * Calculates the energy just for the specified node.
   * @param i the nodes whose energy is being calculated
   * @return the energy of this node caused by the additional factors
   */
  double getAdditionFactorsEnergy(int i) {
    return 0.0;
  }

  /**
   * Returns all Edges that are not connected to the specified cell
   * 
   * @param cellIndex
   *            the cell index to which the edges are not connected
   * @return Array of all interesting Edges
   */
  List<int> getRelevantEdges(int cellIndex) {
    List<int> relevantEdgeList = new List<int>(e.length);

    for (int i = 0; i < e.length; i++) {
      if (e[i].source != cellIndex && e[i].target != cellIndex) {
        // Add non-connected edges
        relevantEdgeList.add(i);
      }
    }

    List<int> relevantEdgeArray = new List<int>(relevantEdgeList.length);
    Iterator<int> iter = relevantEdgeList.iterator;

    //Reform the list into an array but replace int values with ints
    for (int i = 0; i < relevantEdgeArray.length; i++) {
      if (iter.moveNext()) {
        relevantEdgeArray[i] = iter.current;
      }
    }

    return relevantEdgeArray;
  }

  /**
   * Returns all Edges that are connected with the specified cell
   * 
   * @param cellIndex
   *            the cell index to which the edges are connected
   * @return Array of all connected Edges
   */
  List<int> getConnectedEdges(int cellIndex) {
    List<int> connectedEdgeList = new List<int>(e.length);

    for (int i = 0; i < e.length; i++) {
      if (e[i].source == cellIndex || e[i].target == cellIndex) {
        // Add connected edges to list by their index number
        connectedEdgeList.add(i);
      }
    }

    List<int> connectedEdgeArray = new List<int>(connectedEdgeList.length);
    Iterator<int> iter = connectedEdgeList.iterator;

    // Reform the list into an array but replace int values with ints
    for (int i = 0; i < connectedEdgeArray.length; i++) {
      if (iter.moveNext()) {
        connectedEdgeArray[i] = iter.current;
        ;
      }
    }

    return connectedEdgeArray;
  }

  /**
   * Returns <code>Organic</code>, the name of this algorithm.
   */
  String toString() {
    return "Organic";
  }

  /**
   * @return Returns the averageNodeArea.
   */
  double getAverageNodeArea() {
    return averageNodeArea;
  }

  /**
   * @param averageNodeArea The averageNodeArea to set.
   */
  void setAverageNodeArea(double averageNodeArea) {
    this.averageNodeArea = averageNodeArea;
  }

  /**
   * @return Returns the borderLineCostFactor.
   */
  double getBorderLineCostFactor() {
    return borderLineCostFactor;
  }

  /**
   * @param borderLineCostFactor The borderLineCostFactor to set.
   */
  void setBorderLineCostFactor(double borderLineCostFactor) {
    this.borderLineCostFactor = borderLineCostFactor;
  }

  /**
   * @return Returns the edgeCrossingCostFactor.
   */
  double getEdgeCrossingCostFactor() {
    return edgeCrossingCostFactor;
  }

  /**
   * @param edgeCrossingCostFactor The edgeCrossingCostFactor to set.
   */
  void setEdgeCrossingCostFactor(double edgeCrossingCostFactor) {
    this.edgeCrossingCostFactor = edgeCrossingCostFactor;
  }

  /**
   * @return Returns the edgeDistanceCostFactor.
   */
  double getEdgeDistanceCostFactor() {
    return edgeDistanceCostFactor;
  }

  /**
   * @param edgeDistanceCostFactor The edgeDistanceCostFactor to set.
   */
  void setEdgeDistanceCostFactor(double edgeDistanceCostFactor) {
    this.edgeDistanceCostFactor = edgeDistanceCostFactor;
  }

  /**
   * @return Returns the edgeLengthCostFactor.
   */
  double getEdgeLengthCostFactor() {
    return edgeLengthCostFactor;
  }

  /**
   * @param edgeLengthCostFactor The edgeLengthCostFactor to set.
   */
  void setEdgeLengthCostFactor(double edgeLengthCostFactor) {
    this.edgeLengthCostFactor = edgeLengthCostFactor;
  }

  /**
   * @return Returns the fineTuningRadius.
   */
  double getFineTuningRadius() {
    return fineTuningRadius;
  }

  /**
   * @param fineTuningRadius The fineTuningRadius to set.
   */
  void setFineTuningRadius(double fineTuningRadius) {
    this.fineTuningRadius = fineTuningRadius;
  }

  /**
   * @return Returns the initialMoveRadius.
   */
  double getInitialMoveRadius() {
    return initialMoveRadius;
  }

  /**
   * @param initialMoveRadius The initialMoveRadius to set.
   */
  void setInitialMoveRadius(double initialMoveRadius) {
    this.initialMoveRadius = initialMoveRadius;
  }

  /**
   * @return Returns the isFineTuning.
   */
  //	bool isFineTuning()
  //	{
  //		return isFineTuning;
  //	}

  /**
   * @param isFineTuning The isFineTuning to set.
   */
  void setFineTuning(bool isFineTuning) {
    this.isFineTuning = isFineTuning;
  }

  /**
   * @return Returns the isOptimizeBorderLine.
   */
  //	bool isOptimizeBorderLine()
  //	{
  //		return isOptimizeBorderLine;
  //	}

  /**
   * @param isOptimizeBorderLine The isOptimizeBorderLine to set.
   */
  void setOptimizeBorderLine(bool isOptimizeBorderLine) {
    this.isOptimizeBorderLine = isOptimizeBorderLine;
  }

  /**
   * @return Returns the isOptimizeEdgeCrossing.
   */
  //	bool isOptimizeEdgeCrossing()
  //	{
  //		return isOptimizeEdgeCrossing;
  //	}

  /**
   * @param isOptimizeEdgeCrossing The isOptimizeEdgeCrossing to set.
   */
  void setOptimizeEdgeCrossing(bool isOptimizeEdgeCrossing) {
    this.isOptimizeEdgeCrossing = isOptimizeEdgeCrossing;
  }

  /**
   * @return Returns the isOptimizeEdgeDistance.
   */
  //	bool isOptimizeEdgeDistance()
  //	{
  //		return isOptimizeEdgeDistance;
  //	}

  /**
   * @param isOptimizeEdgeDistance The isOptimizeEdgeDistance to set.
   */
  void setOptimizeEdgeDistance(bool isOptimizeEdgeDistance) {
    this.isOptimizeEdgeDistance = isOptimizeEdgeDistance;
  }

  /**
   * @return Returns the isOptimizeEdgeLength.
   */
  //	bool isOptimizeEdgeLength()
  //	{
  //		return isOptimizeEdgeLength;
  //	}

  /**
   * @param isOptimizeEdgeLength The isOptimizeEdgeLength to set.
   */
  void setOptimizeEdgeLength(bool isOptimizeEdgeLength) {
    this.isOptimizeEdgeLength = isOptimizeEdgeLength;
  }

  /**
   * @return Returns the isOptimizeNodeDistribution.
   */
  //	bool isOptimizeNodeDistribution()
  //	{
  //		return isOptimizeNodeDistribution;
  //	}

  /**
   * @param isOptimizeNodeDistribution The isOptimizeNodeDistribution to set.
   */
  void setOptimizeNodeDistribution(bool isOptimizeNodeDistribution) {
    this.isOptimizeNodeDistribution = isOptimizeNodeDistribution;
  }

  /**
   * @return Returns the maxIterations.
   */
  int getMaxIterations() {
    return maxIterations;
  }

  /**
   * @param maxIterations The maxIterations to set.
   */
  void setMaxIterations(int maxIterations) {
    this.maxIterations = maxIterations;
  }

  /**
   * @return Returns the minDistanceLimit.
   */
  double getMinDistanceLimit() {
    return minDistanceLimit;
  }

  /**
   * @param minDistanceLimit The minDistanceLimit to set.
   */
  void setMinDistanceLimit(double minDistanceLimit) {
    this.minDistanceLimit = minDistanceLimit;
  }

  /**
   * @return Returns the minMoveRadius.
   */
  double getMinMoveRadius() {
    return minMoveRadius;
  }

  /**
   * @param minMoveRadius The minMoveRadius to set.
   */
  void setMinMoveRadius(double minMoveRadius) {
    this.minMoveRadius = minMoveRadius;
  }

  /**
   * @return Returns the nodeDistributionCostFactor.
   */
  double getNodeDistributionCostFactor() {
    return nodeDistributionCostFactor;
  }

  /**
   * @param nodeDistributionCostFactor The nodeDistributionCostFactor to set.
   */
  void setNodeDistributionCostFactor(double nodeDistributionCostFactor) {
    this.nodeDistributionCostFactor = nodeDistributionCostFactor;
  }

  /**
   * @return Returns the radiusScaleFactor.
   */
  double getRadiusScaleFactor() {
    return radiusScaleFactor;
  }

  /**
   * @param radiusScaleFactor The radiusScaleFactor to set.
   */
  void setRadiusScaleFactor(double radiusScaleFactor) {
    this.radiusScaleFactor = radiusScaleFactor;
  }

  /**
   * @return Returns the triesPerCell.
   */
  int getTriesPerCell() {
    return triesPerCell;
  }

  /**
   * @param triesPerCell The triesPerCell to set.
   */
  void setTriesPerCell(int triesPerCell) {
    this.triesPerCell = triesPerCell;
  }

  /**
   * @return Returns the unchangedEnergyRoundTermination.
   */
  int getUnchangedEnergyRoundTermination() {
    return unchangedEnergyRoundTermination;
  }

  /**
   * @param unchangedEnergyRoundTermination The unchangedEnergyRoundTermination to set.
   */
  void setUnchangedEnergyRoundTermination(int unchangedEnergyRoundTermination) {
    this.unchangedEnergyRoundTermination = unchangedEnergyRoundTermination;
  }

  /**
   * @return Returns the maxDistanceLimit.
   */
  double getMaxDistanceLimit() {
    return maxDistanceLimit;
  }

  /**
   * @param maxDistanceLimit The maxDistanceLimit to set.
   */
  void setMaxDistanceLimit(double maxDistanceLimit) {
    this.maxDistanceLimit = maxDistanceLimit;
  }

  /**
   * @return the approxNodeDimensions
   */
  bool isApproxNodeDimensions() {
    return approxNodeDimensions;
  }

  /**
   * @param approxNodeDimensions the approxNodeDimensions to set
   */
  void setApproxNodeDimensions(bool approxNodeDimensions) {
    this.approxNodeDimensions = approxNodeDimensions;
  }

  /**
   * @return the disableEdgeStyle
   */
  bool isDisableEdgeStyle() {
    return disableEdgeStyle;
  }

  /**
   * @param disableEdgeStyle the disableEdgeStyle to set
   */
  void setDisableEdgeStyle(bool disableEdgeStyle) {
    this.disableEdgeStyle = disableEdgeStyle;
  }

  /**
   * @return the resetEdges
   */
  bool isResetEdges() {
    return resetEdges;
  }

  /**
   * @param resetEdges the resetEdges to set
   */
  void setResetEdges(bool resetEdges) {
    this.resetEdges = resetEdges;
  }
}


/**
 * Internal representation of a node or edge that holds cached information
 * to enable the layout to perform more quickly and to simplify the code
 */
class CellWrapper {

  /**
     * The actual graph cell this wrapper represents
     */
  Object cell;

  /**
     * All edge that repel this cell, only used for nodes. This array
     * is equivalent to all edges unconnected to this node
     */
  List<int> relevantEdges = null;

  /**
     * the index of all connected edges in the <code>e</code> array
     * to this node. This is only used for nodes.
     */
  List<int> connectedEdges = null;

  /**
     * The x-coordinate position of this cell, nodes only
     */
  double x;

  /**
     * The y-coordinate position of this cell, nodes only
     */
  double y;

  /**
     * The approximate radius squared of this cell, nodes only. If
     * approxNodeDimensions is true on the layout this value holds the
     * width of the node squared
     */
  double radiusSquared;

  /**
     * The height of the node squared, only used if approxNodeDimensions
     * is set to true.
     */
  double heightSquared;

  /**
     * The index of the node attached to this edge as source, edges only
     */
  int source;

  /**
     * The index of the node attached to this edge as target, edges only
     */
  int target;

  /**
     * Constructs a new CellWrapper
     * @param cell the graph cell this wrapper represents
     */
  CellWrapper(Object cell) {
    this.cell = cell;
  }

  /**
     * @return the relevantEdges
     */
  List<int> getRelevantEdges() {
    return relevantEdges;
  }

  /**
     * @param relevantEdges the relevantEdges to set
     */
  void setRelevantEdges(List<int> relevantEdges) {
    this.relevantEdges = relevantEdges;
  }

  /**
     * @return the connectedEdges
     */
  List<int> getConnectedEdges() {
    return connectedEdges;
  }

  /**
     * @param connectedEdges the connectedEdges to set
     */
  void setConnectedEdges(List<int> connectedEdges) {
    this.connectedEdges = connectedEdges;
  }

  /**
     * @return the x
     */
  double getX() {
    return x;
  }

  /**
     * @param x the x to set
     */
  void setX(double x) {
    this.x = x;
  }

  /**
     * @return the y
     */
  double getY() {
    return y;
  }

  /**
     * @param y the y to set
     */
  void setY(double y) {
    this.y = y;
  }

  /**
     * @return the radiusSquared
     */
  double getRadiusSquared() {
    return radiusSquared;
  }

  /**
     * @param radiusSquared the radiusSquared to set
     */
  void setRadiusSquared(double radiusSquared) {
    this.radiusSquared = radiusSquared;
  }

  /**
     * @return the heightSquared
     */
  double getHeightSquared() {
    return heightSquared;
  }

  /**
     * @param heightSquared the heightSquared to set
     */
  void setHeightSquared(double heightSquared) {
    this.heightSquared = heightSquared;
  }

  /**
     * @return the source
     */
  int getSource() {
    return source;
  }

  /**
     * @param source the source to set
     */
  void setSource(int source) {
    this.source = source;
  }

  /**
     * @return the target
     */
  int getTarget() {
    return target;
  }

  /**
     * @param target the target to set
     */
  void setTarget(int target) {
    this.target = target;
  }

  /**
     * @return the cell
     */
  Object getCell() {
    return cell;
  }
}
