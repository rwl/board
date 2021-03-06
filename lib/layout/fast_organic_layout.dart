/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.layout;


/**
 * Fast organic layout algorithm.
 */
class FastOrganicLayout extends GraphLayout {
  /**
   * Specifies if the top left corner of the input cells should be the origin
   * of the layout result. Default is true.
   */
  bool useInputOrigin = true;

  /**
   * Specifies if all edge points of traversed edges should be removed.
   * Default is true.
   */
  bool resetEdges = true;

  /**
   *  Specifies if the STYLE_NOEDGESTYLE flag should be set on edges that are
   * modified by the result. Default is true.
   */
  bool disableEdgeStyle = true;

  /**
   * The force constant by which the attractive forces are divided and the
   * replusive forces are multiple by the square of. The value equates to the
   * average radius there is of free space around each node. Default is 50.
   */
  double forceConstant = 50.0;

  /**
   * Cache of <forceConstant>^2 for performance.
   */
  double forceConstantSquared = 0.0;

  /**
   * Minimal distance limit. Default is 2. Prevents of
   * dividing by zero.
   */
  double minDistanceLimit = 2.0;

  /**
   * Cached version of <minDistanceLimit> squared.
   */
  double minDistanceLimitSquared = 0.0;

  /**
   * The maximum distance between vertices, beyond which their
   * repulsion no longer has an effect
   */
  double maxDistanceLimit = 500.0;

  /**
   * Start value of temperature. Default is 200.
   */
  double initialTemp = 200.0;

  /**
   * Temperature to limit displacement at later stages of layout.
   */
  double temperature = 0.0;

  /**
   * Total number of iterations to run the layout though.
   */
  double maxIterations = 0.0;

  /**
   * Current iteration count.
   */
  double iteration = 0.0;

  /**
   * An array of all vertices to be laid out.
   */
  List<Object> vertexArray;

  /**
   * An array of locally stored X co-ordinate displacements for the vertices.
   */
  List<double> dispX;

  /**
   * An array of locally stored Y co-ordinate displacements for the vertices.
   */
  List<double> dispY;

  /**
   * An array of locally stored co-ordinate positions for the vertices.
   */
  List<List<double>> cellLocation;

  /**
   * The approximate radius of each cell, nodes only.
   */
  List<double> radius;

  /**
   * The approximate radius squared of each cell, nodes only.
   */
  List<double> radiusSquared;

  /**
   * Array of booleans representing the movable states of the vertices.
   */
  List<bool> isMoveable;

  /**
   * Local copy of cell neighbours.
   */
  List<List<int>> neighbours;

  /**
   * bool flag that specifies if the layout is allowed to run. If this is
   * set to false, then the layout exits in the following iteration.
   */
  bool allowedToRun = true;

  /**
   * Maps from vertices to indices.
   */
  Map<Object, int> indices = new Map<Object, int>();

  /**
   * Constructs a new fast organic layout for the specified graph.
   */
  FastOrganicLayout(Graph graph) : super(graph);

  /**
   * Returns a bool indicating if the given <Cell> should be ignored as a
   * vertex. This returns true if the cell has no connections.
   * 
   * @param vertex Object that represents the vertex to be tested.
   * @return Returns true if the vertex should be ignored.
   */
  bool isVertexIgnored(Object vertex) {
    return super.isVertexIgnored(vertex) || graph.getConnections(vertex).length == 0;
  }

  /**
   *
   */
  bool isUseInputOrigin() {
    return useInputOrigin;
  }

  /**
   * 
   * @param value
   */
  void setUseInputOrigin(bool value) {
    useInputOrigin = value;
  }

  /**
   *
   */
  bool isResetEdges() {
    return resetEdges;
  }

  /**
   * 
   * @param value
   */
  void setResetEdges(bool value) {
    resetEdges = value;
  }

  /**
   *
   */
  bool isDisableEdgeStyle() {
    return disableEdgeStyle;
  }

  /**
   * 
   * @param value
   */
  void setDisableEdgeStyle(bool value) {
    disableEdgeStyle = value;
  }

  double getMaxIterations() {
    return maxIterations;
  }

  /**
   * 
   * @param value
   */
  void setMaxIterations(double value) {
    maxIterations = value;
  }

  double getForceConstant() {
    return forceConstant;
  }

  /**
   * 
   * @param value
   */
  void setForceConstant(double value) {
    forceConstant = value;
  }

  double getMinDistanceLimit() {
    return minDistanceLimit;
  }

  /**
   * 
   * @param value
   */
  void setMinDistanceLimit(double value) {
    minDistanceLimit = value;
  }

  /**
   * @return the maxDistanceLimit
   */
  double getMaxDistanceLimit() {
    return maxDistanceLimit;
  }

  /**
   * @param maxDistanceLimit the maxDistanceLimit to set
   */
  void setMaxDistanceLimit(double maxDistanceLimit) {
    this.maxDistanceLimit = maxDistanceLimit;
  }

  double getInitialTemp() {
    return initialTemp;
  }

  /**
   * 
   * @param value
   */
  void setInitialTemp(double value) {
    initialTemp = value;
  }

  /**
   * Reduces the temperature of the layout from an initial setting in a linear
   * fashion to zero.
   */
  void reduceTemperature() {
    temperature = initialTemp * (1.0 - iteration / maxIterations);
  }

  /**
   * @see graph.layout.IGraphLayout#move(java.lang.Object, double, double)
   */
  void moveCell(Object cell, double x, double y) {
    // TODO: Map the position to a child index for
    // the cell to be placed closest to the position
  }

  /**
   * @see graph.layout.IGraphLayout#execute(java.lang.Object)
   */
  void execute(Object parent) {
    IGraphModel model = graph.getModel();

    // Finds the relevant vertices for the layout
    List<Object> vertices = graph.getChildVertices(parent);
    List<Object> tmp = new List<Object>(vertices.length);

    for (int i = 0; i < vertices.length; i++) {
      if (!isVertexIgnored(vertices[i])) {
        tmp.add(vertices[i]);
      }
    }

    vertexArray = tmp;
    Rect initialBounds = (useInputOrigin) ? graph.getBoundsForCells(vertexArray, false, false, true) : null;
    int n = vertexArray.length;

    dispX = new List<double>(n);
    dispY = new List<double>(n);
    cellLocation = new List<List<double>>(n);
    isMoveable = new List<bool>(n);
    neighbours = new List<List<int>>(n);
    radius = new List<double>(n);
    radiusSquared = new List<double>(n);

    minDistanceLimitSquared = minDistanceLimit * minDistanceLimit;

    if (forceConstant < 0.001) {
      forceConstant = 0.001;
    }

    forceConstantSquared = forceConstant * forceConstant;

    // Create a map of vertices first. This is required for the array of
    // arrays called neighbours which holds, for each vertex, a list of
    // ints which represents the neighbours cells to that vertex as
    // the indices into vertexArray
    for (int i = 0; i < vertexArray.length; i++) {
      Object vertex = vertexArray[i];
      cellLocation[i] = new List<double>(2);

      // Set up the mapping from array indices to cells
      indices[vertex] = i;
      Rect bounds = getVertexBounds(vertex);

      // Set the X,Y value of the internal version of the cell to
      // the center point of the vertex for better positioning
      double width = bounds.getWidth();
      double height = bounds.getHeight();

      // Randomize (0, 0) locations
      double x = bounds.getX();
      double y = bounds.getY();

      cellLocation[i][0] = x + width / 2.0;
      cellLocation[i][1] = y + height / 2.0;

      radius[i] = Math.min(width, height);
      radiusSquared[i] = radius[i] * radius[i];
    }

    // Moves cell location back to top-left from center locations used in
    // algorithm, resetting the edge points is part of the transaction
    model.beginUpdate();
    try {
      for (int i = 0; i < n; i++) {
        dispX[i] = 0.0;
        dispY[i] = 0.0;
        isMoveable[i] = isVertexMovable(vertexArray[i]);

        // Get lists of neighbours to all vertices, translate the cells
        // obtained in indices into vertexArray and store as an array
        // against the original cell index
        List<Object> edges = graph.getConnections(vertexArray[i], parent);
        for (int k = 0; k < edges.length; k++) {
          if (isResetEdges()) {
            graph.resetEdge(edges[k]);
          }

          if (isDisableEdgeStyle()) {
            setEdgeStyleEnabled(edges[k], false);
          }
        }

        List<Object> cells = graph.getOpposites(edges, vertexArray[i]);

        neighbours[i] = new List<int>(cells.length);

        for (int j = 0; j < cells.length; j++) {
          int index = indices[cells[j]];

          // Check the connected cell in part of the vertex list to be
          // acted on by this layout
          if (index != null) {
            neighbours[i][j] = index;
          } // Else if index of the other cell doesn't correspond to
          // any cell listed to be acted upon in this layout. Set
          // the index to the value of this vertex (a dummy self-loop)
          // so the attraction force of the edge is not calculated
          else {
            neighbours[i][j] = i;
          }
        }
      }

      temperature = initialTemp;

      // If max number of iterations has not been set, guess it
      if (maxIterations == 0) {
        maxIterations = 20.0 * Math.sqrt(n);
      }

      // Main iteration loop
      for (iteration = 0.0; iteration < maxIterations; iteration++) {
        if (!allowedToRun) {
          return;
        }

        // Calculate repulsive forces on all vertices
        calcRepulsion();

        // Calculate attractive forces through edges
        calcAttraction();

        calcPositions();
        reduceTemperature();
      }

      double minx = null;
      double miny = null;

      for (int i = 0; i < vertexArray.length; i++) {
        Object vertex = vertexArray[i];
        Geometry geo = model.getGeometry(vertex);

        if (geo != null) {
          cellLocation[i][0] -= geo.getWidth() / 2.0;
          cellLocation[i][1] -= geo.getHeight() / 2.0;

          double x = graph.snap(cellLocation[i][0]);
          double y = graph.snap(cellLocation[i][1]);
          setVertexLocation(vertex, x, y);

          if (minx == null) {
            minx = x;
          } else {
            minx = Math.min(minx, x);
          }

          if (miny == null) {
            miny = y;
          } else {
            miny = Math.min(miny, y);
          }
        }
      }

      // Modifies the cloned geometries in-place. Not needed
      // to clone the geometries again as we're in the same
      // undoable change.
      double dx = (minx != null) ? -minx - 1 : 0;
      double dy = (miny != null) ? -miny - 1 : 0;

      if (initialBounds != null) {
        dx += initialBounds.getX();
        dy += initialBounds.getY();
      }

      graph.moveCells(vertexArray, dx, dy);
    } finally {
      model.endUpdate();
    }
  }

  /**
   * Takes the displacements calculated for each cell and applies them to the
   * local cache of cell positions. Limits the displacement to the current
   * temperature.
   */
  void calcPositions() {
    for (int index = 0; index < vertexArray.length; index++) {
      if (isMoveable[index]) {
        // Get the distance of displacement for this node for this
        // iteration
        double deltaLength = Math.sqrt(dispX[index] * dispX[index] + dispY[index] * dispY[index]);

        if (deltaLength < 0.001) {
          deltaLength = 0.001;
        }

        // Scale down by the current temperature if less than the
        // displacement distance
        double newXDisp = dispX[index] / deltaLength * Math.min(deltaLength, temperature);
        double newYDisp = dispY[index] / deltaLength * Math.min(deltaLength, temperature);

        // reset displacements
        dispX[index] = 0.0;
        dispY[index] = 0.0;

        // Update the cached cell locations
        cellLocation[index][0] += newXDisp;
        cellLocation[index][1] += newYDisp;
      }
    }
  }

  /**
   * Calculates the attractive forces between all laid out nodes linked by
   * edges
   */
  void calcAttraction() {
    // Check the neighbours of each vertex and calculate the attractive
    // force of the edge connecting them
    for (int i = 0; i < vertexArray.length; i++) {
      for (int k = 0; k < neighbours[i].length; k++) {
        // Get the index of the othe cell in the vertex array
        int j = neighbours[i][k];

        // Do not proceed self-loops
        if (i != j) {
          double xDelta = cellLocation[i][0] - cellLocation[j][0];
          double yDelta = cellLocation[i][1] - cellLocation[j][1];

          // The distance between the nodes
          double deltaLengthSquared = xDelta * xDelta + yDelta * yDelta - radiusSquared[i] - radiusSquared[j];

          if (deltaLengthSquared < minDistanceLimitSquared) {
            deltaLengthSquared = minDistanceLimitSquared;
          }

          double deltaLength = Math.sqrt(deltaLengthSquared);
          double force = (deltaLengthSquared) / forceConstant;

          double displacementX = (xDelta / deltaLength) * force;
          double displacementY = (yDelta / deltaLength) * force;

          if (isMoveable[i]) {
            this.dispX[i] -= displacementX;
            this.dispY[i] -= displacementY;
          }

          if (isMoveable[j]) {
            dispX[j] += displacementX;
            dispY[j] += displacementY;
          }
        }
      }
    }
  }

  /**
   * Calculates the repulsive forces between all laid out nodes
   */
  void calcRepulsion() {
    int vertexCount = vertexArray.length;

    for (int i = 0; i < vertexCount; i++) {
      for (int j = i; j < vertexCount; j++) {
        // Exits if the layout is no longer allowed to run
        if (!allowedToRun) {
          return;
        }

        if (j != i) {
          double xDelta = cellLocation[i][0] - cellLocation[j][0];
          double yDelta = cellLocation[i][1] - cellLocation[j][1];

          if (xDelta == 0) {
            xDelta = 0.01 + math.random();
          }

          if (yDelta == 0) {
            yDelta = 0.01 + math.random();
          }

          // Distance between nodes
          double deltaLength = Math.sqrt((xDelta * xDelta) + (yDelta * yDelta));

          double deltaLengthWithRadius = deltaLength - radius[i] - radius[j];

          if (deltaLengthWithRadius > maxDistanceLimit) {
            // Ignore vertices too far apart
            continue;
          }

          if (deltaLengthWithRadius < minDistanceLimit) {
            deltaLengthWithRadius = minDistanceLimit;
          }

          double force = forceConstantSquared / deltaLengthWithRadius;

          double displacementX = (xDelta / deltaLength) * force;
          double displacementY = (yDelta / deltaLength) * force;

          if (isMoveable[i]) {
            dispX[i] += displacementX;
            dispY[i] += displacementY;
          }

          if (isMoveable[j]) {
            dispX[j] -= displacementX;
            dispY[j] -= displacementY;
          }
        }
      }
    }
  }

}
