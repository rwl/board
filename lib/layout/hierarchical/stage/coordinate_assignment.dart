/**
 * Copyright (c) 2005-2012, JGraph Ltd
 */

part of graph.layout.hierarchical.stage;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Collection;
//import java.util.HashMap;
//import java.util.HashSet;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.LinkedList;
//import java.util.List;
//import java.util.Map;
//import java.util.Set;
//import java.util.logging.Level;
//import java.util.logging.Logger;

//import javax.swing.SwingConstants;

/**
 * Sets the horizontal locations of node and edge dummy nodes on each layer.
 * Uses median down and up weighings as well as heuristics to straighten edges as
 * far as possible.
 */
class CoordinateAssignment implements HierarchicalLayoutStage
{

	enum HierarchicalEdgeStyle
	{
		ORTHOGONAL, POLYLINE, STRAIGHT
	}

	/**
	 * Reference to the enclosing layout algorithm
	 */
	HierarchicalLayout _layout;

	/**
	 * The minimum buffer between cells on the same rank
	 */
	double _intraCellSpacing = 30.0;

	/**
	 * The minimum distance between cells on adjacent ranks
	 */
	double _interRankCellSpacing = 30.0;

	/**
	 * The distance between each parallel edge on each ranks for long edges
	 */
	double _parallelEdgeSpacing = 4.0;

	/**
	 * The buffer on either side of a vertex where edges must not connect.
	 */
	double _vertexConnectionBuffer = 0.0;

	/**
	 * The number of heuristic iterations to run
	 */
	int _maxIterations = 8;

	/**
	 * The preferred horizontal distance between edges exiting a vertex
	 */
	int _prefHozEdgeSep = 5;

	/**
	 * The preferred vertical offset between edges exiting a vertex
	 */
	int _prefVertEdgeOff = 2;

	/**
	 * The minimum distance for an edge jetty from a vertex
	 */
	int _minEdgeJetty = 12;

	/**
	 * The size of the vertical buffer in the center of inter-rank channels
	 * where edge control points should not be placed
	 */
	int _channelBuffer = 4;

	/**
	 * Map of internal edges and (x,y) pair of positions of the start and end jetty
	 * for that edge where it connects to the source and target vertices.
	 * Note this should technically be a WeakHashMap, but since JS does not
	 * have an equivalent, housekeeping must be performed before using.
	 * i.e. check all edges are still in the model and clear the values.
	 * Note that the y co-ord is the offset of the jetty, not the
	 * absolute point
	 */
	Map<GraphHierarchyEdge, List<double>> _jettyPositions = new HashMap<GraphHierarchyEdge, List<double>>();

	/**
	 * The position of the root ( start ) node(s) relative to the rest of the
	 * laid out graph
	 */
	int _orientation = SwingConstants.NORTH;

	/**
	 * The minimum x position node placement starts at
	 */
	double _initialX;

	/**
	 * The maximum x value this positioning lays up to
	 */
	double _limitX;

	/**
	 * The sum of x-displacements for the current iteration
	 */
	double _currentXDelta;

	/**
	 * The rank that has the widest x position
	 */
	int _widestRank;

	/**
	 * Internal cache of top-most values of Y for each rank
	 */
	List<double> _rankTopY;

	/**
	 * Internal cache of bottom-most value of Y for each rank
	 */
	List<double> _rankBottomY;

	/**
	 * The X-coordinate of the edge of the widest rank
	 */
	double _widestRankValue;

	/**
	 * The width of all the ranks
	 */
	List<double> _rankWidths;

	/**
	 * The Y-coordinate of all the ranks
	 */
	List<double> _rankY;

	/**
	 * Whether or not to perform local optimisations and iterate multiple times
	 * through the algorithm
	 */
	bool _fineTuning = true;

	/**
	 * Specifies if the STYLE_NOEDGESTYLE flag should be set on edges that are
	 * modified by the result. Default is true.
	 */
	bool _disableEdgeStyle = true;

	/**
	 * The style to apply between cell layers to edge segments
	 */
	HierarchicalEdgeStyle _edgeStyle = HierarchicalEdgeStyle.POLYLINE;

	/**
	 * A store of connections to the layer above for speed
	 */
	GraphAbstractHierarchyCell[][] _nextLayerConnectedCache;

	/**
	 * Padding added to resized parents
	 */
	int _groupPadding = 10;

	/**
	 * A store of connections to the layer below for speed
	 */
	GraphAbstractHierarchyCell[][] _previousLayerConnectedCache;

	/** The logger for this class */
	static Logger _logger = Logger
			.getLogger("com.jgraph.layout.hierarchical.JGraphCoordinateAssignment");

	/**
	 * Creates a coordinate assignment.
	 * 
	 * @param intraCellSpacing
	 *            the minimum buffer between cells on the same rank
	 * @param interRankCellSpacing
	 *            the minimum distance between cells on adjacent ranks
	 * @param orientation
	 *            the position of the root node(s) relative to the graph
	 * @param initialX
	 *            the leftmost coordinate node placement starts at
	 */
	CoordinateAssignment(HierarchicalLayout layout,
			double intraCellSpacing, double interRankCellSpacing,
			int orientation, double initialX, double parallelEdgeSpacing)
	{
		this._layout = layout;
		this._intraCellSpacing = intraCellSpacing;
		this._interRankCellSpacing = interRankCellSpacing;
		this._orientation = orientation;
		this._initialX = initialX;
		this._parallelEdgeSpacing = parallelEdgeSpacing;
		setLoggerLevel(Level.OFF);
	}

	/**
	 * Utility method to display the x co-ords
	 */
	void printStatus()
	{
		GraphHierarchyModel model = _layout.getModel();

		System.out.println("======Coord assignment debug=======");

		for (int j = 0; j < model.ranks.size(); j++)
		{
			System.out.print("Rank " + j + " : " );
			GraphHierarchyRank rank = model.ranks
					.get(new Integer(j));
			Iterator<GraphAbstractHierarchyCell> iter = rank
					.iterator();

			while (iter.hasNext())
			{
				GraphAbstractHierarchyCell cell = iter.next();
				System.out.print(cell.getX(j) + "  ");
			}
			System.out.println();
		}
		
		System.out.println("====================================");
	}
	
	/**
	 * A basic horizontal coordinate assignment algorithm
	 */
	void execute(Object parent)
	{
		GraphHierarchyModel model = _layout.getModel();
		_currentXDelta = 0.0;

		_initialCoords(_layout.getGraph(), model);

		if (_fineTuning)
		{
			_minNode(model);
		}

		double bestXDelta = 100000000.0;

		if (_fineTuning)
		{
			for (int i = 0; i < _maxIterations; i++)
			{
				// Median Heuristic
				if (i != 0)
				{
					_medianPos(i, model);
					_minNode(model);
				}

				// if the total offset is less for the current positioning,
				// there are less heavily angled edges and so the current
				// positioning is used
				if (_currentXDelta < bestXDelta)
				{
					for (int j = 0; j < model.ranks.size(); j++)
					{
						GraphHierarchyRank rank = model.ranks
								.get(new Integer(j));
						Iterator<GraphAbstractHierarchyCell> iter = rank
								.iterator();

						while (iter.hasNext())
						{
							GraphAbstractHierarchyCell cell = iter.next();
							cell.setX(j, cell.getGeneralPurposeVariable(j));
						}
					}

					bestXDelta = _currentXDelta;
				}
				else
				{
					// Restore the best positions
					for (int j = 0; j < model.ranks.size(); j++)
					{
						GraphHierarchyRank rank = model.ranks
								.get(new Integer(j));
						Iterator<GraphAbstractHierarchyCell> iter = rank
								.iterator();

						while (iter.hasNext())
						{
							GraphAbstractHierarchyCell cell = iter.next();
							cell.setGeneralPurposeVariable(j,
									(int) cell.getX(j));
						}
					}
				}

				_minPath(model);

				_currentXDelta = 0;
			}
		}

		_setCellLocations(_layout.getGraph(), model);
	}

	/**
	 * Performs one median positioning sweep in both directions
	 * 
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _minNode(GraphHierarchyModel model)
	{
		// Queue all nodes
		LinkedList<_WeightedCellSorter> nodeList = new LinkedList<_WeightedCellSorter>();

		// Need to be able to map from cell to cellWrapper
		Map<GraphAbstractHierarchyCell, _WeightedCellSorter> map = new Hashtable<GraphAbstractHierarchyCell, _WeightedCellSorter>();
		GraphAbstractHierarchyCell[][] rank = new GraphAbstractHierarchyCell[model.maxRank + 1][];

		for (int i = 0; i <= model.maxRank; i++)
		{
			GraphHierarchyRank rankSet = model.ranks.get(new Integer(i));
			rank[i] = rankSet.toArray(new GraphAbstractHierarchyCell[rankSet
					.size()]);

			for (int j = 0; j < rank[i].length; j++)
			{
				// Use the weight to store the rank and visited to store whether
				// or not the cell is in the list
				GraphAbstractHierarchyCell cell = rank[i][j];
				_WeightedCellSorter cellWrapper = new _WeightedCellSorter(cell, i);
				cellWrapper.rankIndex = j;
				cellWrapper.visited = true;
				nodeList.add(cellWrapper);
				map.put(cell, cellWrapper);
			}
		}

		// Set a limit of the maximum number of times we will access the queue
		// in case a loop appears
		int maxTries = nodeList.size() * 10;
		int count = 0;

		// Don't move cell within this value of their median
		int tolerance = 1;

		while (!nodeList.isEmpty() && count <= maxTries)
		{
			_WeightedCellSorter cellWrapper = nodeList.getFirst();
			GraphAbstractHierarchyCell cell = cellWrapper.cell;

			int rankValue = cellWrapper.weightedValue;
			int rankIndex = cellWrapper.rankIndex;

			List<Object> nextLayerConnectedCells = cell.getNextLayerConnectedCells(
					rankValue).toArray();
			List<Object> previousLayerConnectedCells = cell
					.getPreviousLayerConnectedCells(rankValue).toArray();

			int numNextLayerConnected = nextLayerConnectedCells.length;
			int numPreviousLayerConnected = previousLayerConnectedCells.length;

			int medianNextLevel = _medianXValue(nextLayerConnectedCells,
					rankValue + 1);
			int medianPreviousLevel = _medianXValue(previousLayerConnectedCells,
					rankValue - 1);

			int numConnectedNeighbours = numNextLayerConnected
					+ numPreviousLayerConnected;
			int currentPosition = cell.getGeneralPurposeVariable(rankValue);
			double cellMedian = currentPosition;

			if (numConnectedNeighbours > 0)
			{
				cellMedian = (medianNextLevel * numNextLayerConnected + medianPreviousLevel
						* numPreviousLayerConnected)
						/ numConnectedNeighbours;
			}

			// Flag storing whether or not position has changed
			bool positionChanged = false;

			if (cellMedian < currentPosition - tolerance)
			{
				if (rankIndex == 0)
				{
					cell.setGeneralPurposeVariable(rankValue, (int) cellMedian);
					positionChanged = true;
				}
				else
				{
					GraphAbstractHierarchyCell leftCell = rank[rankValue][rankIndex - 1];
					int leftLimit = leftCell
							.getGeneralPurposeVariable(rankValue);
					leftLimit = leftLimit + (int) leftCell.width / 2
							+ (int) _intraCellSpacing + (int) cell.width / 2;

					if (leftLimit < cellMedian)
					{
						cell.setGeneralPurposeVariable(rankValue,
								(int) cellMedian);
						positionChanged = true;
					}
					else if (leftLimit < cell
							.getGeneralPurposeVariable(rankValue) - tolerance)
					{
						cell.setGeneralPurposeVariable(rankValue, leftLimit);
						positionChanged = true;
					}
				}
			}
			else if (cellMedian > currentPosition + tolerance)
			{
				int rankSize = rank[rankValue].length;

				if (rankIndex == rankSize - 1)
				{
					cell.setGeneralPurposeVariable(rankValue, (int) cellMedian);
					positionChanged = true;
				}
				else
				{
					GraphAbstractHierarchyCell rightCell = rank[rankValue][rankIndex + 1];
					int rightLimit = rightCell
							.getGeneralPurposeVariable(rankValue);
					rightLimit = rightLimit - (int) rightCell.width / 2
							- (int) _intraCellSpacing - (int) cell.width / 2;

					if (rightLimit > cellMedian)
					{
						cell.setGeneralPurposeVariable(rankValue,
								(int) cellMedian);
						positionChanged = true;
					}
					else if (rightLimit > cell
							.getGeneralPurposeVariable(rankValue) + tolerance)
					{
						cell.setGeneralPurposeVariable(rankValue, rightLimit);
						positionChanged = true;
					}
				}
			}

			if (positionChanged)
			{
				// Add connected nodes to map and list
				for (int i = 0; i < nextLayerConnectedCells.length; i++)
				{
					GraphAbstractHierarchyCell connectedCell = (GraphAbstractHierarchyCell) nextLayerConnectedCells[i];
					_WeightedCellSorter connectedCellWrapper = map
							.get(connectedCell);

					if (connectedCellWrapper != null)
					{
						if (connectedCellWrapper.visited == false)
						{
							connectedCellWrapper.visited = true;
							nodeList.add(connectedCellWrapper);
						}
					}
				}

				// Add connected nodes to map and list
				for (int i = 0; i < previousLayerConnectedCells.length; i++)
				{
					GraphAbstractHierarchyCell connectedCell = (GraphAbstractHierarchyCell) previousLayerConnectedCells[i];
					_WeightedCellSorter connectedCellWrapper = map
							.get(connectedCell);

					if (connectedCellWrapper != null)
					{
						if (connectedCellWrapper.visited == false)
						{
							connectedCellWrapper.visited = true;
							nodeList.add(connectedCellWrapper);
						}
					}
				}
			}

			nodeList.removeFirst();
			cellWrapper.visited = false;
			count++;
		}
	}

	/**
	 * Performs one median positioning sweep in one direction
	 * 
	 * @param i
	 *            the iteration of the whole process
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _medianPos(int i, GraphHierarchyModel model)
	{
		// Reverse sweep direction each time through this method
		bool downwardSweep = (i % 2 == 0);

		if (downwardSweep)
		{
			for (int j = model.maxRank; j > 0; j--)
			{
				_rankMedianPosition(j - 1, model, j);
			}
		}
		else
		{
			for (int j = 0; j < model.maxRank - 1; j++)
			{
				_rankMedianPosition(j + 1, model, j);
			}
		}
	}

	/**
	 * Performs median minimisation over one rank.
	 * 
	 * @param rankValue
	 *            the layer number of this rank
	 * @param model
	 *            an internal model of the hierarchical layout
	 * @param nextRankValue
	 *            the layer number whose connected cels are to be laid out
	 *            relative to
	 */
	void _rankMedianPosition(int rankValue,
			GraphHierarchyModel model, int nextRankValue)
	{
		GraphHierarchyRank rankSet = model.ranks.get(new Integer(rankValue));
		List<Object> rank = rankSet.toArray();
		// Form an array of the order in which the cells are to be processed
		// , the order is given by the weighted sum of the in or out edges,
		// depending on whether we're travelling up or down the hierarchy.
		_WeightedCellSorter[] weightedValues = new _WeightedCellSorter[rank.length];
		Map<GraphAbstractHierarchyCell, _WeightedCellSorter> cellMap = new Hashtable<GraphAbstractHierarchyCell, _WeightedCellSorter>(
				rank.length);

		for (int i = 0; i < rank.length; i++)
		{
			GraphAbstractHierarchyCell currentCell = (GraphAbstractHierarchyCell) rank[i];
			weightedValues[i] = new _WeightedCellSorter();
			weightedValues[i].cell = currentCell;
			weightedValues[i].rankIndex = i;
			cellMap.put(currentCell, weightedValues[i]);
			Collection<GraphAbstractHierarchyCell> nextLayerConnectedCells = null;

			if (nextRankValue < rankValue)
			{
				nextLayerConnectedCells = currentCell
						.getPreviousLayerConnectedCells(rankValue);
			}
			else
			{
				nextLayerConnectedCells = currentCell
						.getNextLayerConnectedCells(rankValue);
			}

			// Calculate the weighing based on this node type and those this
			// node is connected to on the next layer
			weightedValues[i].weightedValue = _calculatedWeightedValue(
					currentCell, nextLayerConnectedCells);
		}

		Arrays.sort(weightedValues);
		// Set the new position of each node within the rank using
		// its temp variable

		for (int i = 0; i < weightedValues.length; i++)
		{
			int numConnectionsNextLevel = 0;
			GraphAbstractHierarchyCell cell = weightedValues[i].cell;
			List<Object> nextLayerConnectedCells = null;
			int medianNextLevel = 0;

			if (nextRankValue < rankValue)
			{
				nextLayerConnectedCells = cell.getPreviousLayerConnectedCells(
						rankValue).toArray();
			}
			else
			{
				nextLayerConnectedCells = cell.getNextLayerConnectedCells(
						rankValue).toArray();
			}

			if (nextLayerConnectedCells != null)
			{
				numConnectionsNextLevel = nextLayerConnectedCells.length;

				if (numConnectionsNextLevel > 0)
				{
					medianNextLevel = _medianXValue(nextLayerConnectedCells,
							nextRankValue);
				}
				else
				{
					// For case of no connections on the next level set the
					// median to be the current position and try to be
					// positioned there
					medianNextLevel = cell.getGeneralPurposeVariable(rankValue);
				}
			}

			double leftBuffer = 0.0;
			double leftLimit = -100000000.0;

			for (int j = weightedValues[i].rankIndex - 1; j >= 0;)
			{
				_WeightedCellSorter weightedValue = cellMap.get(rank[j]);

				if (weightedValue != null)
				{
					GraphAbstractHierarchyCell leftCell = weightedValue.cell;

					if (weightedValue.visited)
					{
						// The left limit is the right hand limit of that
						// cell plus any allowance for unallocated cells
						// in-between
						leftLimit = leftCell
								.getGeneralPurposeVariable(rankValue)
								+ leftCell.width
								/ 2.0
								+ _intraCellSpacing
								+ leftBuffer + cell.width / 2.0;
						j = -1;
					}
					else
					{
						leftBuffer += leftCell.width + _intraCellSpacing;
						j--;
					}
				}
			}

			double rightBuffer = 0.0;
			double rightLimit = 100000000.0;

			for (int j = weightedValues[i].rankIndex + 1; j < weightedValues.length;)
			{
				_WeightedCellSorter weightedValue = cellMap.get(rank[j]);

				if (weightedValue != null)
				{
					GraphAbstractHierarchyCell rightCell = weightedValue.cell;

					if (weightedValue.visited)
					{
						// The left limit is the right hand limit of that
						// cell plus any allowance for unallocated cells
						// in-between
						rightLimit = rightCell
								.getGeneralPurposeVariable(rankValue)
								- rightCell.width
								/ 2.0
								- _intraCellSpacing
								- rightBuffer - cell.width / 2.0;
						j = weightedValues.length;
					}
					else
					{
						rightBuffer += rightCell.width + _intraCellSpacing;
						j++;
					}
				}
			}

			if (medianNextLevel >= leftLimit && medianNextLevel <= rightLimit)
			{
				cell.setGeneralPurposeVariable(rankValue, medianNextLevel);
			}
			else if (medianNextLevel < leftLimit)
			{
				// Couldn't place at median value, place as close to that
				// value as possible
				cell.setGeneralPurposeVariable(rankValue, (int) leftLimit);
				_currentXDelta += leftLimit - medianNextLevel;
			}
			else if (medianNextLevel > rightLimit)
			{
				// Couldn't place at median value, place as close to that
				// value as possible
				cell.setGeneralPurposeVariable(rankValue, (int) rightLimit);
				_currentXDelta += medianNextLevel - rightLimit;
			}

			weightedValues[i].visited = true;
		}
	}

	/**
	 * Calculates the priority the specified cell has based on the type of its
	 * cell and the cells it is connected to on the next layer
	 * 
	 * @param currentCell
	 *            the cell whose weight is to be calculated
	 * @param collection
	 *            the cells the specified cell is connected to
	 * @return the total weighted of the edges between these cells
	 */
	int _calculatedWeightedValue(
			GraphAbstractHierarchyCell currentCell,
			Collection<GraphAbstractHierarchyCell> collection)
	{
		int totalWeight = 0;
		Iterator<GraphAbstractHierarchyCell> iter = collection.iterator();

		while (iter.hasNext())
		{
			GraphAbstractHierarchyCell cell = iter.next();

			if (currentCell.isVertex() && cell.isVertex())
			{
				totalWeight++;
			}
			else if (currentCell.isEdge() && cell.isEdge())
			{
				totalWeight += 8;
			}
			else
			{
				totalWeight += 2;
			}
		}

		return totalWeight;
	}

	/**
	 * Calculates the median position of the connected cell on the specified
	 * rank
	 * 
	 * @param connectedCells
	 *            the cells the candidate connects to on this level
	 * @param rankValue
	 *            the layer number of this rank
	 * @return the median rank order ( not x position ) of the connected cells
	 */
	int _medianXValue(List<Object> connectedCells, int rankValue)
	{
		if (connectedCells.length == 0)
		{
			return 0;
		}

		List<int> medianValues = new int[connectedCells.length];

		for (int i = 0; i < connectedCells.length; i++)
		{
			medianValues[i] = ((GraphAbstractHierarchyCell) connectedCells[i])
					.getGeneralPurposeVariable(rankValue);
		}

		Arrays.sort(medianValues);

		if (connectedCells.length % 2 == 1)
		{
			// For odd numbers of adjacent vertices return the median
			return medianValues[connectedCells.length / 2];
		}
		else
		{
			int medianPoint = connectedCells.length / 2;
			int leftMedian = medianValues[medianPoint - 1];
			int rightMedian = medianValues[medianPoint];

			return ((leftMedian + rightMedian) / 2);
		}
	}

	/**
	 * Sets up the layout in an initial positioning. The ranks are all centered
	 * as much as possible along the middle vertex in each rank. The other cells
	 * are then placed as close as possible on either side.
	 * 
	 * @param facade
	 *            the facade describing the input graph
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _initialCoords(Graph facade, GraphHierarchyModel model)
	{
		_calculateWidestRank(facade, model);

		// Sweep up and down from the widest rank
		for (int i = _widestRank; i >= 0; i--)
		{
			if (i < model.maxRank)
			{
				_rankCoordinates(i, facade, model);
			}
		}

		for (int i = _widestRank + 1; i <= model.maxRank; i++)
		{
			if (i > 0)
			{
				_rankCoordinates(i, facade, model);
			}
		}
	}

	/**
	 * Sets up the layout in an initial positioning. All the first cells in each
	 * rank are moved to the left and the rest of the rank inserted as close
	 * together as their size and buffering permits. This method works on just
	 * the specified rank.
	 * 
	 * @param rankValue
	 *            the current rank being processed
	 * @param graph
	 *            the facade describing the input graph
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _rankCoordinates(int rankValue, Graph graph,
			GraphHierarchyModel model)
	{
		GraphHierarchyRank rank = model.ranks.get(new Integer(rankValue));
		double maxY = 0.0;
		double localX = _initialX + (_widestRankValue - _rankWidths[rankValue])
				/ 2;

		// Store whether or not any of the cells' bounds were unavailable so
		// to only issue the warning once for all cells
		bool boundsWarning = false;

		for (GraphAbstractHierarchyCell cell : rank)
		{
			if (cell.isVertex())
			{
				GraphHierarchyNode node = (GraphHierarchyNode) cell;
				Rect bounds = _layout.getVertexBounds(node.cell);

				if (bounds != null)
				{
					if (_orientation == SwingConstants.NORTH
							|| _orientation == SwingConstants.SOUTH)
					{
						cell.width = bounds.getWidth();
						cell.height = bounds.getHeight();
					}
					else
					{
						cell.width = bounds.getHeight();
						cell.height = bounds.getWidth();
					}
				}
				else
				{
					boundsWarning = true;
				}

				maxY = Math.max(maxY, cell.height);
			}
			else if (cell.isEdge())
			{
				GraphHierarchyEdge edge = (GraphHierarchyEdge) cell;
				// The width is the number of additional parallel edges
				// time the parallel edge spacing
				int numEdges = 1;

				if (edge.edges != null)
				{
					numEdges = edge.edges.size();
				}
				else
				{
					_logger.info("edge.edges is null");
				}

				cell.width = (numEdges - 1) * _parallelEdgeSpacing;
			}

			// Set the initial x-value as being the best result so far
			localX += cell.width / 2.0;
			cell.setX(rankValue, localX);
			cell.setGeneralPurposeVariable(rankValue, (int) localX);
			localX += cell.width / 2.0;
			localX += _intraCellSpacing;
		}

		if (boundsWarning == true)
		{
			_logger.info("At least one cell has no bounds");
		}
	}

	/**
	 * Calculates the width rank in the hierarchy. Also set the y value of each
	 * rank whilst performing the calculation
	 * 
	 * @param graph
	 *            the facade describing the input graph
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _calculateWidestRank(Graph graph,
			GraphHierarchyModel model)
	{
		// Starting y co-ordinate
		double y = -_interRankCellSpacing;

		// Track the widest cell on the last rank since the y
		// difference depends on it
		double lastRankMaxCellHeight = 0.0;
		_rankWidths = new double[model.maxRank + 1];
		_rankY = new double[model.maxRank + 1];

		for (int rankValue = model.maxRank; rankValue >= 0; rankValue--)
		{
			// Keep track of the widest cell on this rank
			double maxCellHeight = 0.0;
			GraphHierarchyRank rank = model.ranks.get(new Integer(rankValue));
			double localX = _initialX;

			// Store whether or not any of the cells' bounds were unavailable so
			// to only issue the warning once for all cells
			bool boundsWarning = false;
			Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

			while (iter.hasNext())
			{
				GraphAbstractHierarchyCell cell = iter.next();

				if (cell.isVertex())
				{
					GraphHierarchyNode node = (GraphHierarchyNode) cell;
					Rect bounds = _layout.getVertexBounds(node.cell);

					if (bounds != null)
					{
						if (_orientation == SwingConstants.NORTH
								|| _orientation == SwingConstants.SOUTH)
						{
							cell.width = bounds.getWidth();
							cell.height = bounds.getHeight();
						}
						else
						{
							cell.width = bounds.getHeight();
							cell.height = bounds.getWidth();
						}
					}
					else
					{
						boundsWarning = true;
					}

					maxCellHeight = Math.max(maxCellHeight, cell.height);
				}
				else if (cell.isEdge())
				{
					GraphHierarchyEdge edge = (GraphHierarchyEdge) cell;
					// The width is the number of additional parallel edges
					// time the parallel edge spacing
					int numEdges = 1;

					if (edge.edges != null)
					{
						numEdges = edge.edges.size();
					}
					else
					{
						_logger.info("edge.edges is null");
					}

					cell.width = (numEdges - 1) * _parallelEdgeSpacing;
				}

				// Set the initial x-value as being the best result so far
				localX += cell.width / 2.0;
				cell.setX(rankValue, localX);
				cell.setGeneralPurposeVariable(rankValue, (int) localX);
				localX += cell.width / 2.0;
				localX += _intraCellSpacing;

				if (localX > _widestRankValue)
				{
					_widestRankValue = localX;
					_widestRank = rankValue;
				}

				_rankWidths[rankValue] = localX;
			}

			if (boundsWarning == true)
			{
				_logger.info("At least one cell has no bounds");
			}

			_rankY[rankValue] = y;
			double distanceToNextRank = maxCellHeight / 2.0
					+ lastRankMaxCellHeight / 2.0 + _interRankCellSpacing;
			lastRankMaxCellHeight = maxCellHeight;

			if (_orientation == SwingConstants.NORTH
					|| _orientation == SwingConstants.WEST)
			{
				y += distanceToNextRank;
			}
			else
			{
				y -= distanceToNextRank;
			}

			iter = rank.iterator();

			while (iter.hasNext())
			{
				GraphAbstractHierarchyCell cell = iter.next();
				cell.setY(rankValue, y);
			}
		}
	}

	/**
	 * Straightens out chains of virtual nodes where possible
	 * 
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _minPath(GraphHierarchyModel model)
	{
		// Work down and up each edge with at least 2 control points
		// trying to straighten each one out. If the same number of
		// straight segments are formed in both directions, the 
		// preferred direction used is the one where the final
		// control points have the least offset from the connectable 
		// region of the terminating vertices
		Map<Object, GraphHierarchyEdge> edges = model.getEdgeMapper();

		for (GraphAbstractHierarchyCell cell : edges.values())
		{
			if (cell.maxRank > cell.minRank + 2)
			{
				int numEdgeLayers = cell.maxRank - cell.minRank - 1;
				// At least two virtual nodes in the edge
				// Check first whether the edge is already straight
				int referenceX = cell
						.getGeneralPurposeVariable(cell.minRank + 1);
				bool edgeStraight = true;
				int refSegCount = 0;

				for (int i = cell.minRank + 2; i < cell.maxRank; i++)
				{
					int x = cell.getGeneralPurposeVariable(i);

					if (referenceX != x)
					{
						edgeStraight = false;
						referenceX = x;
					}
					else
					{
						refSegCount++;
					}
				}

				if (edgeStraight)
				{
					continue;
				}

				int upSegCount = 0;
				int downSegCount = 0;
				double upXPositions[] = new double[numEdgeLayers - 1];
				double downXPositions[] = new double[numEdgeLayers - 1];

				double currentX = cell.getX(cell.minRank + 1);

				for (int i = cell.minRank + 1; i < cell.maxRank - 1; i++)
				{
					// Attempt to straight out the control point on the
					// next segment up with the current control point.
					double nextX = cell.getX(i + 1);

					if (currentX == nextX)
					{
						upXPositions[i - cell.minRank - 1] = currentX;
						upSegCount++;
					}
					else if (_repositionValid(model, cell, i + 1, currentX))
					{
						upXPositions[i - cell.minRank - 1] = currentX;
						upSegCount++;
						// Leave currentX at same value
					}
					else
					{
						upXPositions[i - cell.minRank - 1] = nextX;
						currentX = nextX;
					}
				}

				currentX = cell.getX(cell.maxRank - 1);

				for (int i = cell.maxRank - 1; i > cell.minRank + 1; i--)
				{
					// Attempt to straight out the control point on the
					// next segment down with the current control point.
					double nextX = cell.getX(i - 1);

					if (currentX == nextX)
					{
						downXPositions[i - cell.minRank - 2] = currentX;
						downSegCount++;
					}
					else if (_repositionValid(model, cell, i - 1, currentX))
					{
						downXPositions[i - cell.minRank - 2] = currentX;
						downSegCount++;
						// Leave currentX at same value
					}
					else
					{
						downXPositions[i - cell.minRank - 2] = cell.getX(i-1);
						currentX = nextX;
					}
				}

				if (downSegCount <= refSegCount && upSegCount <= refSegCount)
				{
					// Neither of the new calculation provide a straighter edge
					continue;
				}

				if (downSegCount >= upSegCount)
				{
					// Apply down calculation values
					for (int i = cell.maxRank - 2; i > cell.minRank; i--)
					{
						cell.setX(i, (int) downXPositions[i - cell.minRank - 1]);
					}
				}
				else if (upSegCount > downSegCount)
				{
					// Apply up calculation values
					for (int i = cell.minRank + 2; i < cell.maxRank; i++)
					{
						cell.setX(i, (int) upXPositions[i - cell.minRank - 2]);
					}
				}
				else
				{
					// Neither direction provided a favourable result
					// But both calculations are better than the
					// existing solution, so apply the one with minimal
					// offset to attached vertices at either end.

				}
			}
		}
	}

	/**
	 * Determines whether or not a node may be moved to the specified x 
	 * position on the specified rank
	 * @param model the layout model
	 * @param cell the cell being analysed
	 * @param rank the layer of the cell
	 * @param position the x position being sought
	 * @return whether or not the virtual node can be moved to this position
	 */
	bool _repositionValid(GraphHierarchyModel model,
			GraphAbstractHierarchyCell cell, int rank, double position)
	{
		GraphHierarchyRank rankSet = model.ranks.get(new Integer(rank));
		GraphAbstractHierarchyCell[] rankArray = rankSet
				.toArray(new GraphAbstractHierarchyCell[rankSet.size()]);
		int rankIndex = -1;

		for (int i = 0; i < rankArray.length; i++)
		{
			if (cell == rankArray[i])
			{
				rankIndex = i;
				break;
			}
		}

		if (rankIndex < 0)
		{
			return false;
		}

		int currentX = cell.getGeneralPurposeVariable(rank);

		if (position < currentX)
		{
			// Trying to move node to the left.
			if (rankIndex == 0)
			{
				// Left-most node, can move anywhere
				return true;
			}

			GraphAbstractHierarchyCell leftCell = rankArray[rankIndex - 1];
			int leftLimit = leftCell.getGeneralPurposeVariable(rank);
			leftLimit = leftLimit + (int) leftCell.width / 2
					+ (int) _intraCellSpacing + (int) cell.width / 2;

			if (leftLimit <= position)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else if (position > currentX)
		{
			// Trying to move node to the right.
			if (rankIndex == rankArray.length - 1)
			{
				// Right-most node, can move anywhere
				return true;
			}

			GraphAbstractHierarchyCell rightCell = rankArray[rankIndex + 1];
			int rightLimit = rightCell.getGeneralPurposeVariable(rank);
			rightLimit = rightLimit - (int) rightCell.width / 2
					- (int) _intraCellSpacing - (int) cell.width / 2;

			if (rightLimit >= position)
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		return true;
	}

	/**
	 * Sets the cell locations in the facade to those stored after this layout
	 * processing step has completed.
	 * 
	 * @param graph
	 *            the facade describing the input graph
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _setCellLocations(Graph graph, GraphHierarchyModel model)
	{
		_rankTopY = new double[model.ranks.size()];
		_rankBottomY = new double[model.ranks.size()];

		for (int i = 0; i < model.ranks.size(); i++)
		{
			_rankTopY[i] = Double.MAX_VALUE;
			_rankBottomY[i] = 0.0;
		}

		Set<Object> parentsChanged = null;
		
		if (_layout.isResizeParent())
		{
			parentsChanged = new HashSet<Object>();
		}
		
		Map<Object, GraphHierarchyEdge> edges = model.getEdgeMapper();
		Map<Object, GraphHierarchyNode> vertices = model.getVertexMapper();

		// Process vertices all first, since they define the lower and 
		// limits of each rank. Between these limits lie the channels
		// where the edges can be routed across the graph

		for (GraphHierarchyNode cell : vertices.values())
		{
			_setVertexLocation(cell);
			
			if (_layout.isResizeParent())
			{
				parentsChanged.add(graph.getModel().getParent(cell.cell));
			}
		}
		
		if (_layout.isResizeParent())
		{
			_adjustParents(parentsChanged);
		}

		// Post process edge styles. Needs the vertex locations set for initial
		// values of the top and bottoms of each rank
		if (this._edgeStyle == HierarchicalEdgeStyle.ORTHOGONAL
				|| this._edgeStyle == HierarchicalEdgeStyle.POLYLINE)
		{
			_localEdgeProcessing(model);
		}

		for (GraphAbstractHierarchyCell cell : edges.values())
		{
			_setEdgePosition(cell);
		}
	}

	/**
	 * Adjust parent cells whose child geometries have changed. The default 
	 * implementation adjusts the group to just fit around the children with 
	 * a padding.
	 */
	void _adjustParents(Set<Object> parentsChanged)
	{
		_layout.arrangeGroups(Utils.sortCells(parentsChanged, true).toArray(), _groupPadding);
	}

	/**
	 * Separates the x position of edges as they connect to vertices
	 * 
	 * @param model
	 *            an internal model of the hierarchical layout
	 */
	void _localEdgeProcessing(GraphHierarchyModel model)
	{
		// Check the map of jetty positions doesn't contain
		// any deleted edges. We can't use a WeakHashMap because
		// it doesn't translate to JS.
		Map<Object, GraphHierarchyEdge> edgeMapping = model.getEdgeMapper();

		if (edgeMapping != null && _jettyPositions.size() != edgeMapping.size())
		{
			_jettyPositions = new HashMap<GraphHierarchyEdge, List<double>>();
		}

		//jettyPositions.removeAll();
		// Iterate through each vertex, look at the edges connected in
		// both directions.
		for (int i = 0; i < model.ranks.size(); i++)
		{
			GraphHierarchyRank rank = model.ranks.get(new Integer(i));

			// Iterate over the top rank and fill in the connection information
			Iterator<GraphAbstractHierarchyCell> iter = rank.iterator();

			while (iter.hasNext())
			{
				GraphAbstractHierarchyCell cell = iter.next();

				if (cell.isVertex())
				{
					GraphAbstractHierarchyCell[] currentCells = (cell
							.getPreviousLayerConnectedCells(i))
							.toArray(new GraphAbstractHierarchyCell[cell
									.getPreviousLayerConnectedCells(i).size()]);

					int currentRank = i - 1;

					// Two loops, last connected cells, and next
					for (int k = 0; k < 2; k++)
					{
						if (currentRank > -1
								&& currentRank < model.ranks.size()
								&& currentCells != null
								&& currentCells.length > 0)
						{
							_WeightedCellSorter[] sortedCells = new _WeightedCellSorter[currentCells.length];

							for (int j = 0; j < currentCells.length; j++)
							{
								sortedCells[j] = new _WeightedCellSorter(
										currentCells[j],
										-(int) currentCells[j].getX(currentRank));
							}

							Arrays.sort(sortedCells);

							GraphHierarchyNode node = (GraphHierarchyNode) cell;
							double leftLimit = node.x[0] - node.width / 2;
							double rightLimit = leftLimit + node.width;

							// Connected edge count starts at 1 to allow for buffer
							// with edge of vertex
							int connectedEdgeCount = 0;
							int connectedEdgeGroupCount = 0;
							GraphHierarchyEdge[] connectedEdges = new GraphHierarchyEdge[sortedCells.length];
							// Calculate width requirements for all connected edges
							for (int j = 0; j < sortedCells.length; j++)
							{
								GraphAbstractHierarchyCell innerCell = sortedCells[j].cell;
								Collection<GraphHierarchyEdge> connections;

								if (innerCell.isVertex())
								{
									// Get the connecting edge
									if (k == 0)
									{
										connections = ((GraphHierarchyNode) cell).connectsAsSource;

									}
									else
									{
										connections = ((GraphHierarchyNode) cell).connectsAsTarget;
									}

									for (GraphHierarchyEdge connectedEdge : connections)
									{
										if (connectedEdge.source == innerCell
												|| connectedEdge.target == innerCell)
										{
											connectedEdgeCount += connectedEdge.edges
													.size();
											connectedEdgeGroupCount++;

											connectedEdges[j] = connectedEdge;
										}
									}
								}
								else
								{
									connectedEdgeCount += ((GraphHierarchyEdge) innerCell).edges
											.size();
									connectedEdgeGroupCount++;
									connectedEdges[j] = (GraphHierarchyEdge) innerCell;
								}
							}

							double requiredWidth = (connectedEdgeCount + 1)
									* _prefHozEdgeSep;

							// Add a buffer on the edges of the vertex if the edge count allows
							if (cell.width > requiredWidth
									+ (2 * _prefHozEdgeSep))
							{
								leftLimit += _prefHozEdgeSep;
								rightLimit -= _prefHozEdgeSep;
							}

							double availableWidth = rightLimit - leftLimit;
							double edgeSpacing = availableWidth / connectedEdgeCount;

							double currentX = leftLimit + edgeSpacing / 2.0;
							double currentYOffset = _minEdgeJetty - _prefVertEdgeOff;
							double maxYOffset = 0;

							for (int j = 0; j < connectedEdges.length; j++)
							{
								int numActualEdges = connectedEdges[j].edges
										.size();
								List<double> pos = _jettyPositions
										.get(connectedEdges[j]);

								if (pos == null
										|| pos.length != 4 * numActualEdges)
								{
									pos = new double[4 * numActualEdges];
									_jettyPositions.put(connectedEdges[j], pos);
								}

								if (j < (float)connectedEdgeCount / 2.0f)
								{
									currentYOffset += _prefVertEdgeOff;
								}
								else if (j > (float)connectedEdgeCount / 2.0f)
								{
									currentYOffset -= _prefVertEdgeOff;
								}
								// Ignore the case if equals, this means the second of 2
								// jettys with the same y (even number of edges)

								for (int m = 0; m < numActualEdges; m++)
								{
									pos[m * 4 + k * 2] = currentX;
									currentX += edgeSpacing;
									pos[m * 4 + k * 2 + 1] = currentYOffset;
								}
								
								maxYOffset = Math.max(maxYOffset,
										currentYOffset);
							}
						}

						currentCells = (cell.getNextLayerConnectedCells(i))
								.toArray(new GraphAbstractHierarchyCell[cell
										.getNextLayerConnectedCells(i).size()]);

						currentRank = i + 1;
					}
				}
			}
		}
	}

	/**
	 * Fixes the control points 
	 * @param cell
	 */
	void _setEdgePosition(GraphAbstractHierarchyCell cell)
	{
		GraphHierarchyEdge edge = (GraphHierarchyEdge) cell;

		// For parallel edges we need to separate out the points a
		// little
		double offsetX = 0.0;

		// Only set the edge control points once
		if (edge.temp[0] != 101207)
		{
			int maxRank = edge.maxRank;
			int minRank = edge.minRank;
			
			if (maxRank == minRank)
			{
				maxRank = edge.source.maxRank;
				minRank = edge.target.minRank;
			}

			Iterator<Object> parallelEdges = edge.edges.iterator();
			int parallelEdgeCount = 0;
			List<double> jettys = _jettyPositions.get(edge);
			
			Object source = edge.isReversed() ? edge.target.cell : edge.source.cell;

			while (parallelEdges.hasNext())
			{
				Object realEdge = parallelEdges.next();
				Object realSource = _layout.getGraph().getView().getVisibleTerminal(realEdge, true);
				
				List<Point2d> newPoints = new List<Point2d>(edge.x.length);

				// Single length reversed edges end up with the jettys in the wrong
				// places. Since single length edges only have jettys, not segment
				// control points, we just say the edge isn't reversed in this section
				bool reversed = edge.isReversed();
				
				if (realSource != source)
				{
					// The real edges include all core model edges and these can go
					// in both directions. If the source of the hierarchical model edge
					// isn't the source of the specific real edge in this iteration
					// treat if as reversed
					reversed = !reversed;
				}
				
				// First jetty of edge
				if (jettys != null)
				{
					int arrayOffset = reversed ? 2 : 0;
					double y = reversed ? _rankTopY[minRank] : _rankBottomY[maxRank];
					double jetty = jettys[parallelEdgeCount * 4 + 1 + arrayOffset];
					
					// If the edge is reversed invert the y position within the channel,
					// unless it is a single length edge
					if (reversed)
					{
						jetty = -jetty;
					}
					
					y += jetty;
					double x = jettys[parallelEdgeCount * 4 + arrayOffset];

					if (_orientation == SwingConstants.NORTH
							|| _orientation == SwingConstants.SOUTH)
					{
						newPoints.add(new Point2d(x, y));
					}
					else
					{
						newPoints.add(new Point2d(y, x));
					}
				}

				// Declare variables to define loop through edge points and 
				// change direction if edge is reversed

				int loopStart = edge.x.length - 1;
				int loopLimit = -1;
				int loopDelta = -1;
				int currentRank = edge.maxRank - 1;

				if (reversed)
				{
					loopStart = 0;
					loopLimit = edge.x.length;
					loopDelta = 1;
					currentRank = edge.minRank + 1;
				}

				// Reversed edges need the points inserted in
				// reverse order
				for (int j = loopStart; (edge.maxRank != edge.minRank) && j != loopLimit; j += loopDelta)
				{
					// The horizontal position in a vertical layout
					double positionX = edge.x[j] + offsetX;

					// Work out the vertical positions in a vertical layout
					// in the edge buffer channels above and below this rank
					double topChannelY = (_rankTopY[currentRank] + _rankBottomY[currentRank + 1]) / 2.0;
					double bottomChannelY = (_rankTopY[currentRank - 1] + _rankBottomY[currentRank]) / 2.0;

					if (reversed)
					{
						double tmp = topChannelY;
						topChannelY = bottomChannelY;
						bottomChannelY = tmp;
					}

					if (_orientation == SwingConstants.NORTH
							|| _orientation == SwingConstants.SOUTH)
					{
						newPoints.add(new Point2d(positionX, topChannelY));
						newPoints.add(new Point2d(positionX, bottomChannelY));
					}
					else
					{
						newPoints.add(new Point2d(topChannelY, positionX));
						newPoints.add(new Point2d(bottomChannelY, positionX));
					}

					_limitX = Math.max(_limitX, positionX);

					//					double currentY = (rankTopY[currentRank] + rankBottomY[currentRank]) / 2.0;
					//					System.out.println("topChannelY = " + topChannelY + " , "
					//							+ "exact Y = " + edge.y[j]);
					currentRank += loopDelta;
				}

				// Second jetty of edge
				if (jettys != null)
				{
					int arrayOffset = reversed ? 2 : 0;
					double rankY = reversed ? _rankBottomY[maxRank] : _rankTopY[minRank];
					double jetty = jettys[parallelEdgeCount * 4 + 3 - arrayOffset];
					
					if (reversed)
					{
						jetty = -jetty;
					}
					double y = rankY - jetty;
					double x = jettys[parallelEdgeCount * 4 + 2 - arrayOffset];

					if (_orientation == SwingConstants.NORTH
							|| _orientation == SwingConstants.SOUTH)
					{
						newPoints.add(new Point2d(x, y));
					}
					else
					{
						newPoints.add(new Point2d(y, x));
					}
				}
				
				if (edge.isReversed())
				{
					_processReversedEdge(edge, realEdge);
				}

				_layout.setEdgePoints(realEdge, newPoints);

				// Increase offset so next edge is drawn next to
				// this one
				if (offsetX == 0.0)
				{
					offsetX = _parallelEdgeSpacing;
				}
				else if (offsetX > 0)
				{
					offsetX = -offsetX;
				}
				else
				{
					offsetX = -offsetX + _parallelEdgeSpacing;
				}
				
				parallelEdgeCount++;
			}

			edge.temp[0] = 101207;
		}
	}

	/**
	 * Fixes the position of the specified vertex
	 * @param cell the vertex to position
	 */
	void _setVertexLocation(GraphAbstractHierarchyCell cell)
	{
		GraphHierarchyNode node = (GraphHierarchyNode) cell;
		Object realCell = node.cell;
		double positionX = node.x[0] - node.width / 2;
		double positionY = node.y[0] - node.height / 2;

//		if (cell.minRank == -1)
//		{
//			System.out.println("invalid rank, never set");
//		}

		_rankTopY[cell.minRank] = Math.min(_rankTopY[cell.minRank], positionY);
		_rankBottomY[cell.minRank] = Math.max(_rankBottomY[cell.minRank],
				positionY + node.height);

		if (_orientation == SwingConstants.NORTH
				|| _orientation == SwingConstants.SOUTH)
		{
			_layout.setVertexLocation(realCell, positionX, positionY);
		}
		else
		{
			_layout.setVertexLocation(realCell, positionY, positionX);
		}

		_limitX = Math.max(_limitX, positionX + node.width);
	}

	/**
	 * Hook to add additional processing
	 * 
	 * @param edge
	 *            The hierarchical model edge
	 * @param realEdge
	 *            The real edge in the graph
	 */
	void _processReversedEdge(GraphHierarchyEdge edge,
			Object realEdge)
	{
		// Added as hook for customer
	}

	/**
	 * @return Returns the interRankCellSpacing.
	 */
	double getInterRankCellSpacing()
	{
		return _interRankCellSpacing;
	}

	/**
	 * @param interRankCellSpacing
	 *            The interRankCellSpacing to set.
	 */
	void setInterRankCellSpacing(double interRankCellSpacing)
	{
		this._interRankCellSpacing = interRankCellSpacing;
	}

	/**
	 * @return Returns the intraCellSpacing.
	 */
	double getIntraCellSpacing()
	{
		return _intraCellSpacing;
	}

	/**
	 * @param intraCellSpacing
	 *            The intraCellSpacing to set.
	 */
	void setIntraCellSpacing(double intraCellSpacing)
	{
		this._intraCellSpacing = intraCellSpacing;
	}

	/**
	 * @return Returns the orientation.
	 */
	int getOrientation()
	{
		return _orientation;
	}

	/**
	 * @param orientation
	 *            The orientation to set.
	 */
	void setOrientation(int orientation)
	{
		this._orientation = orientation;
	}

	/**
	 * @return Returns the limitX.
	 */
	double getLimitX()
	{
		return _limitX;
	}

	/**
	 * @param limitX
	 *            The limitX to set.
	 */
	void setLimitX(double limitX)
	{
		this._limitX = limitX;
	}

	/**
	 * @return Returns the fineTuning.
	 */
	bool isFineTuning()
	{
		return _fineTuning;
	}

	/**
	 * @param fineTuning
	 *            The fineTuning to set.
	 */
	void setFineTuning(bool fineTuning)
	{
		this._fineTuning = fineTuning;
	}

	/**
	 * Sets the logging level of this class
	 * 
	 * @param level
	 *            the logging level to set
	 */
	void setLoggerLevel(Level level)
	{
		try
		{
			_logger.setLevel(level);
		}
		on SecurityException catch (e)
		{
			// Probably running in an applet
		}
	}
}
