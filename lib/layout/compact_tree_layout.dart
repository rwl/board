part of graph.layout;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.HashSet;
//import java.util.List;
//import java.util.Set;

class CompactTreeLayout extends GraphLayout
{

	/**
	 * Specifies the orientation of the layout. Default is true.
	 */
	bool _horizontal;

	/**
	 * Specifies if edge directions should be inverted. Default is false.
	 */
	bool _invert;

	/**
	 * If the parents should be resized to match the width/height of the
	 * children. Default is true.
	 */
	bool _resizeParent = true;

	/**
	 * Padding added to resized parents
	 */
	int _groupPadding = 10;

	/**
	 * A set of the parents that need updating based on children
	 * process as part of the layout
	 */
	Set<Object> _parentsChanged = null;

	/**
	 * Specifies if the tree should be moved to the top, left corner
	 * if it is inside a top-level layer. Default is false.
	 */
	bool _moveTree = false;

	/**
	 * Specifies if all edge points of traversed edges should be removed.
	 * Default is true.
	 */
	bool _resetEdges = true;

	/**
	 * Holds the levelDistance. Default is 10.
	 */
	int _levelDistance = 10;

	/**
	 * Holds the nodeDistance. Default is 20.
	 */
	int _nodeDistance = 20;

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
	 * Whether or not to apply the internal tree edge routing
	 */
	bool _edgeRouting = true;

	/**
	 * 
	 * @param graph
	 */
//	CompactTreeLayout(Graph graph)
//	{
//		this(graph, true);
//	}

	/**
	 * 
	 * @param graph
	 * @param horizontal
	 */
//	CompactTreeLayout(Graph graph, bool horizontal)
//	{
//		this(graph, horizontal, false);
//	}

	/**
	 * 
	 * @param graph
	 * @param horizontal
	 * @param invert
	 */
	CompactTreeLayout(Graph graph, [bool horizontal=true, bool invert=false]) : super(graph)
	{
		this._horizontal = horizontal;
		this._invert = invert;
	}

	/**
	 * Returns a bool indicating if the given <Cell> should be ignored as a
	 * vertex. This returns true if the cell has no connections.
	 * 
	 * @param vertex Object that represents the vertex to be tested.
	 * @return Returns true if the vertex should be ignored.
	 */
	bool isVertexIgnored(Object vertex)
	{
		return super.isVertexIgnored(vertex)
				|| graph.getConnections(vertex).length == 0;
	}

	/**
	 * @return the horizontal
	 */
	bool isHorizontal()
	{
		return _horizontal;
	}

	/**
	 * @param horizontal the horizontal to set
	 */
	void setHorizontal(bool horizontal)
	{
		this._horizontal = horizontal;
	}

	/**
	 * @return the invert
	 */
	bool isInvert()
	{
		return _invert;
	}

	/**
	 * @param invert the invert to set
	 */
	void setInvert(bool invert)
	{
		this._invert = invert;
	}

	/**
	 * @return the resizeParent
	 */
	bool isResizeParent()
	{
		return _resizeParent;
	}

	/**
	 * @param resizeParent the resizeParent to set
	 */
	void setResizeParent(bool resizeParent)
	{
		this._resizeParent = resizeParent;
	}

	/**
	 * @return the moveTree
	 */
	bool isMoveTree()
	{
		return _moveTree;
	}

	/**
	 * @param moveTree the moveTree to set
	 */
	void setMoveTree(bool moveTree)
	{
		this._moveTree = moveTree;
	}

	/**
	 * @return the resetEdges
	 */
	bool isResetEdges()
	{
		return _resetEdges;
	}

	/**
	 * @param resetEdges the resetEdges to set
	 */
	void setResetEdges(bool resetEdges)
	{
		this._resetEdges = resetEdges;
	}

	bool isEdgeRouting()
	{
		return _edgeRouting;
	}

	void setEdgeRouting(bool edgeRouting)
	{
		this._edgeRouting = edgeRouting;
	}

	/**
	 * @return the levelDistance
	 */
	int getLevelDistance()
	{
		return _levelDistance;
	}

	/**
	 * @param levelDistance the levelDistance to set
	 */
	void setLevelDistance(int levelDistance)
	{
		this._levelDistance = levelDistance;
	}

	/**
	 * @return the nodeDistance
	 */
	int getNodeDistance()
	{
		return _nodeDistance;
	}

	/**
	 * @param nodeDistance the nodeDistance to set
	 */
	void setNodeDistance(int nodeDistance)
	{
		this._nodeDistance = nodeDistance;
	}

	double getGroupPadding()
	{
		return _groupPadding;
	}

	void setGroupPadding(int groupPadding)
	{
		this._groupPadding = groupPadding;
	}

	/*
	 * (non-Javadoc)
	 * @see graph.layout.IGraphLayout#execute(java.lang.Object)
	 */
//	void execute(Object parent)
//	{
//		super.execute(parent);
//		execute(parent, null);
//	}

	/**
	 * Implements <GraphLayout.execute>.
	 * 
	 * If the parent has any connected edges, then it is used as the root of
	 * the tree. Else, <Graph.findTreeRoots> will be used to find a suitable
	 * root node within the set of children of the given parent.
	 */
	void execute(Object parent, [Object root=null])
	{
		IGraphModel model = graph.getModel();

		if (root == null)
		{
			// Takes the parent as the root if it has outgoing edges
			if (graph.getEdges(parent, model.getParent(parent), _invert,
					!_invert, false).length > 0)
			{
				root = parent;
			}

			// Tries to find a suitable root in the parent's
			// children
			else
			{
				List<Object> roots = findTreeRoots(parent, _invert);

				if (roots.size() > 0)
				{
					for (int i = 0; i < roots.size(); i++)
					{
						if (!isVertexIgnored(roots.get(i))
								&& graph.getEdges(roots.get(i), null, _invert,
										!_invert, false).length > 0)
						{
							root = roots.get(i);
							break;
						}
					}
				}
			}
		}

		if (root != null)
		{
			if (_resizeParent)
			{
				_parentsChanged = new HashSet<Object>();
			}
			else
			{
				_parentsChanged = null;
			}

			model.beginUpdate();

			try
			{
				_TreeNode node = _dfs(root, parent, null);

				if (node != null)
				{
					_layout(node);

					double x0 = graph.getGridSize();
					double y0 = x0;

					if (!_moveTree)
					{
						Rect g = getVertexBounds(root);

						if (g != null)
						{
							x0 = g.getX();
							y0 = g.getY();
						}
					}

					Rect bounds = null;

					if (_horizontal)
					{
						bounds = _horizontalLayout(node, x0, y0, null);
					}
					else
					{
						bounds = _verticalLayout(node, null, x0, y0, null);
					}

					if (bounds != null)
					{
						double dx = 0;
						double dy = 0;

						if (bounds.getX() < 0)
						{
							dx = Math.abs(x0 - bounds.getX());
						}

						if (bounds.getY() < 0)
						{
							dy = Math.abs(y0 - bounds.getY());
						}

						if (dx != 0 || dy != 0)
						{
							_moveNode(node, dx, dy);
						}

						if (_resizeParent)
						{
							_adjustParents();
						}

						if (_edgeRouting)
						{
							// Iterate through all edges setting their positions
							_localEdgeProcessing(node);
						}
					}
				}
			}
			finally
			{
				model.endUpdate();
			}
		}
	}

	/**
	 * Returns all visible children in the given parent which do not have
	 * incoming edges. If the result is empty then the children with the
	 * maximum difference between incoming and outgoing edges are returned.
	 * This takes into account edges that are being promoted to the given
	 * root due to invisible children or collapsed cells.
	 * 
	 * @param parent Cell whose children should be checked.
	 * @param invert Specifies if outgoing or incoming edges should be counted
	 * for a tree root. If false then outgoing edges will be counted.
	 * @return List of tree roots in parent.
	 */
	List<Object> findTreeRoots(Object parent, bool invert)
	{
		List<Object> roots = new List<Object>();

		if (parent != null)
		{
			IGraphModel model = graph.getModel();
			int childCount = model.getChildCount(parent);
			Object best = null;
			int maxDiff = 0;

			for (int i = 0; i < childCount; i++)
			{
				Object cell = model.getChildAt(parent, i);

				if (model.isVertex(cell) && graph.isCellVisible(cell))
				{
					List<Object> conns = graph.getConnections(cell, parent, true);
					int fanOut = 0;
					int fanIn = 0;

					for (int j = 0; j < conns.length; j++)
					{
						Object src = graph.getView().getVisibleTerminal(
								conns[j], true);

						if (src == cell)
						{
							fanOut++;
						}
						else
						{
							fanIn++;
						}
					}

					if ((invert && fanOut == 0 && fanIn > 0)
							|| (!invert && fanIn == 0 && fanOut > 0))
					{
						roots.add(cell);
					}

					int diff = (invert) ? fanIn - fanOut : fanOut - fanIn;

					if (diff > maxDiff)
					{
						maxDiff = diff;
						best = cell;
					}
				}
			}

			if (roots.isEmpty() && best != null)
			{
				roots.add(best);
			}
		}

		return roots;
	}

	/**
	 * Moves the specified node and all of its children by the given amount.
	 */
	void _moveNode(_TreeNode node, double dx, double dy)
	{
		node.x += dx;
		node.y += dy;
		_apply(node, null);

		_TreeNode child = node.child;

		while (child != null)
		{
			_moveNode(child, dx, dy);
			child = child.next;
		}
	}

	/**
	 * Does a depth first search starting at the specified cell.
	 * Makes sure the specified parent is never left by the
	 * algorithm.
	 */
	_TreeNode _dfs(Object cell, Object parent, Set<Object> visited)
	{
		if (visited == null)
		{
			visited = new HashSet<Object>();
		}

		_TreeNode node = null;

		if (cell != null && !visited.contains(cell) && !isVertexIgnored(cell))
		{
			visited.add(cell);
			node = _createNode(cell);

			IGraphModel model = graph.getModel();
			_TreeNode prev = null;
			List<Object> out = graph.getEdges(cell, parent, _invert, !_invert, false,
					true);
			GraphView view = graph.getView();

			for (int i = 0; i < out.length; i++)
			{
				Object edge = out[i];

				if (!isEdgeIgnored(edge))
				{
					// Resets the points on the traversed edge
					if (_resetEdges)
					{
						setEdgePoints(edge, null);
					}

					if (_edgeRouting)
					{
						setEdgeStyleEnabled(edge, false);
						setEdgePoints(edge, null);
					}

					// Checks if terminal in same swimlane
					CellState state = view.getState(edge);
					Object target = (state != null) ? state
							.getVisibleTerminal(_invert) : view
							.getVisibleTerminal(edge, _invert);
					_TreeNode tmp = _dfs(target, parent, visited);

					if (tmp != null && model.getGeometry(target) != null)
					{
						if (prev == null)
						{
							node.child = tmp;
						}
						else
						{
							prev.next = tmp;
						}

						prev = tmp;
					}
				}
			}
		}

		return node;
	}

	/**
	 * Starts the actual compact tree layout algorithm
	 * at the given node.
	 */
	void _layout(_TreeNode node)
	{
		if (node != null)
		{
			_TreeNode child = node.child;

			while (child != null)
			{
				_layout(child);
				child = child.next;
			}

			if (node.child != null)
			{
				_attachParent(node, _join(node));
			}
			else
			{
				_layoutLeaf(node);
			}
		}
	}

	/**
	 * 
	 */
	Rect _horizontalLayout(_TreeNode node, double x0, double y0,
			Rect bounds)
	{
		node.x += x0 + node.offsetX;
		node.y += y0 + node.offsetY;
		bounds = _apply(node, bounds);
		_TreeNode child = node.child;

		if (child != null)
		{
			bounds = _horizontalLayout(child, node.x, node.y, bounds);
			double siblingOffset = node.y + child.offsetY;
			_TreeNode s = child.next;

			while (s != null)
			{
				bounds = _horizontalLayout(s, node.x + child.offsetX,
						siblingOffset, bounds);
				siblingOffset += s.offsetY;
				s = s.next;
			}
		}

		return bounds;
	}

	/**
	 * 
	 */
	Rect _verticalLayout(_TreeNode node, Object parent,
			double x0, double y0, Rect bounds)
	{
		node.x += x0 + node.offsetY;
		node.y += y0 + node.offsetX;
		bounds = _apply(node, bounds);
		_TreeNode child = node.child;

		if (child != null)
		{
			bounds = _verticalLayout(child, node, node.x, node.y, bounds);
			double siblingOffset = node.x + child.offsetY;
			_TreeNode s = child.next;

			while (s != null)
			{
				bounds = _verticalLayout(s, node, siblingOffset, node.y
						+ child.offsetX, bounds);
				siblingOffset += s.offsetY;
				s = s.next;
			}
		}

		return bounds;
	}

	/**
	 * 
	 */
	void _attachParent(_TreeNode node, double height)
	{
		double x = _nodeDistance + _levelDistance;
		double y2 = (height - node.width) / 2 - _nodeDistance;
		double y1 = y2 + node.width + 2 * _nodeDistance - height;

		node.child.offsetX = x + node.height;
		node.child.offsetY = y1;

		node.contour.upperHead = _createLine(node.height, 0,
				_createLine(x, y1, node.contour.upperHead));
		node.contour.lowerHead = _createLine(node.height, 0,
				_createLine(x, y2, node.contour.lowerHead));
	}

	/**
	 * 
	 */
	void _layoutLeaf(_TreeNode node)
	{
		double dist = 2 * _nodeDistance;

		node.contour.upperTail = _createLine(node.height + dist, 0, null);
		node.contour.upperHead = node.contour.upperTail;
		node.contour.lowerTail = _createLine(0, -node.width - dist, null);
		node.contour.lowerHead = _createLine(node.height + dist, 0,
				node.contour.lowerTail);
	}

	/**
	 * 
	 */
	double _join(_TreeNode node)
	{
		double dist = 2 * _nodeDistance;

		_TreeNode child = node.child;
		node.contour = child.contour;
		double h = child.width + dist;
		double sum = h;
		child = child.next;

		while (child != null)
		{
			double d = _merge(node.contour, child.contour);
			child.offsetY = d + h;
			child.offsetX = 0;
			h = child.width + dist;
			sum += d + h;
			child = child.next;
		}

		return sum;
	}

	/**
	 * 
	 */
	double _merge(_Polygon p1, _Polygon p2)
	{
		double x = 0;
		double y = 0;
		double total = 0;

		_Polyline upper = p1.lowerHead;
		_Polyline lower = p2.upperHead;

		while (lower != null && upper != null)
		{
			double d = _offset(x, y, lower.dx, lower.dy, upper.dx, upper.dy);
			y += d;
			total += d;

			if (x + lower.dx <= upper.dx)
			{
				x += lower.dx;
				y += lower.dy;
				lower = lower.next;
			}
			else
			{
				x -= upper.dx;
				y -= upper.dy;
				upper = upper.next;
			}
		}

		if (lower != null)
		{
			_Polyline b = _bridge(p1.upperTail, 0, 0, lower, x, y);
			p1.upperTail = (b.next != null) ? p2.upperTail : b;
			p1.lowerTail = p2.lowerTail;
		}
		else
		{
			_Polyline b = _bridge(p2.lowerTail, x, y, upper, 0, 0);

			if (b.next == null)
			{
				p1.lowerTail = b;
			}
		}

		p1.lowerHead = p2.lowerHead;

		return total;
	}

	/**
	 * 
	 */
	double _offset(double p1, double p2, double a1, double a2,
			double b1, double b2)
	{
		double d = 0;

		if (b1 <= p1 || p1 + a1 <= 0)
		{
			return 0;
		}

		double t = b1 * a2 - a1 * b2;

		if (t > 0)
		{
			if (p1 < 0)
			{
				double s = p1 * a2;
				d = s / a1 - p2;
			}
			else if (p1 > 0)
			{
				double s = p1 * b2;
				d = s / b1 - p2;
			}
			else
			{
				d = -p2;
			}
		}
		else if (b1 < p1 + a1)
		{
			double s = (b1 - p1) * a2;
			d = b2 - (p2 + s / a1);
		}
		else if (b1 > p1 + a1)
		{
			double s = (a1 + p1) * b2;
			d = s / b1 - (p2 + a2);
		}
		else
		{
			d = b2 - (p2 + a2);
		}

		if (d > 0)
		{
			return d;
		}

		return 0;
	}

	/**
	 * 
	 */
	_Polyline _bridge(_Polyline line1, double x1, double y1,
			_Polyline line2, double x2, double y2)
	{
		double dx = x2 + line2.dx - x1;
		double dy = 0;
		double s = 0;

		if (line2.dx == 0)
		{
			dy = line2.dy;
		}
		else
		{
			s = dx * line2.dy;
			dy = s / line2.dx;
		}

		_Polyline r = _createLine(dx, dy, line2.next);
		line1.next = _createLine(0, y2 + line2.dy - dy - y1, r);

		return r;
	}

	/**
	 * 
	 */
	_TreeNode _createNode(Object cell)
	{
		_TreeNode node = new _TreeNode(cell);

		Rect geo = getVertexBounds(cell);

		if (geo != null)
		{
			if (_horizontal)
			{
				node.width = geo.getHeight();
				node.height = geo.getWidth();
			}
			else
			{
				node.width = geo.getWidth();
				node.height = geo.getHeight();
			}
		}

		return node;
	}

	/**
	 * 
	 * @param node
	 * @param bounds
	 * @return
	 */
	Rect _apply(_TreeNode node, Rect bounds)
	{
		IGraphModel model = graph.getModel();
		Object cell = node.cell;
		Rect g = model.getGeometry(cell);

		if (cell != null && g != null)
		{
			if (isVertexMovable(cell))
			{
				g = setVertexLocation(cell, node.x, node.y);

				if (_resizeParent)
				{
					_parentsChanged.add(model.getParent(cell));
				}
			}

			if (bounds == null)
			{
				bounds = new Rect(g.getX(), g.getY(), g.getWidth(),
						g.getHeight());
			}
			else
			{
				bounds = new Rect(Math.min(bounds.getX(), g.getX()),
						Math.min(bounds.getY(), g.getY()), Math.max(
								bounds.getX() + bounds.getWidth(),
								g.getX() + g.getWidth()), Math.max(
								bounds.getY() + bounds.getHeight(), g.getY()
										+ g.getHeight()));
			}
		}

		return bounds;
	}

	/**
	 * 
	 */
	_Polyline _createLine(double dx, double dy, _Polyline next)
	{
		return new _Polyline(dx, dy, next);
	}

	/**
	 * Adjust parent cells whose child geometries have changed. The default 
	 * implementation adjusts the group to just fit around the children with 
	 * a padding.
	 */
	void _adjustParents()
	{
		arrangeGroups(Utils.sortCells(this._parentsChanged, true).toArray(), _groupPadding);
	}

	/**
	 * Moves the specified node and all of its children by the given amount.
	 */
	void _localEdgeProcessing(_TreeNode node)
	{
		_processNodeOutgoing(node);
		_TreeNode child = node.child;

		while (child != null)
		{
			_localEdgeProcessing(child);
			child = child.next;
		}
	}

	/**
	 * Separates the x position of edges as they connect to vertices
	 * 
	 * @param node
	 *            the root node of the tree
	 */
	void _processNodeOutgoing(_TreeNode node)
	{
		IGraphModel model = graph.getModel();

		_TreeNode child = node.child;
		Object parentCell = node.cell;

		int childCount = 0;
		List<_WeightedCellSorter> sortedCells = new List<_WeightedCellSorter>();

		while (child != null)
		{
			childCount++;

			double sortingCriterion = child.x;

			if (this._horizontal)
			{
				sortingCriterion = child.y;
			}

			sortedCells.add(new _WeightedCellSorter(child,
					sortingCriterion as int));
			child = child.next;
		}

		List<_WeightedCellSorter> sortedCellsArray = sortedCells
				.toArray(new List<_WeightedCellSorter>(sortedCells.size()));
		Arrays.sort(sortedCellsArray);

		double availableWidth = node.width;

		double requiredWidth = (childCount + 1) * _prefHozEdgeSep;

		// Add a buffer on the edges of the vertex if the edge count allows
		if (availableWidth > requiredWidth + (2 * _prefHozEdgeSep))
		{
			availableWidth -= 2 * _prefHozEdgeSep;
		}

		double edgeSpacing = availableWidth / childCount;

		double currentXOffset = edgeSpacing / 2.0;

		if (availableWidth > requiredWidth + (2 * _prefHozEdgeSep))
		{
			currentXOffset += _prefHozEdgeSep;
		}

		double currentYOffset = _minEdgeJetty - _prefVertEdgeOff;
		double maxYOffset = 0;

		Rect parentBounds = getVertexBounds(parentCell);
		child = node.child;

		for (int j = 0; j < sortedCellsArray.length; j++)
		{
			Object childCell = sortedCellsArray[j].cell.cell;
			Rect childBounds = getVertexBounds(childCell);

			List<Object> edges = GraphModel.getEdgesBetween(model, parentCell,
					childCell);

			List<Point2d> newPoints = new List<Point2d>(3);
			double x = 0;
			double y = 0;

			for (int i = 0; i < edges.length; i++)
			{
				if (this._horizontal)
				{
					// Use opposite co-ords, calculation was done for 
					// 
					x = parentBounds.getX() + parentBounds.getWidth();
					y = parentBounds.getY() + currentXOffset;
					newPoints.add(new Point2d(x, y));
					x = parentBounds.getX() + parentBounds.getWidth()
							+ currentYOffset;
					newPoints.add(new Point2d(x, y));
					y = childBounds.getY() + childBounds.getHeight() / 2.0;
					newPoints.add(new Point2d(x, y));
					setEdgePoints(edges[i], newPoints);
				}
				else
				{
					x = parentBounds.getX() + currentXOffset;
					y = parentBounds.getY() + parentBounds.getHeight();
					newPoints.add(new Point2d(x, y));
					y = parentBounds.getY() + parentBounds.getHeight()
							+ currentYOffset;
					newPoints.add(new Point2d(x, y));
					x = childBounds.getX() + childBounds.getWidth() / 2.0;
					newPoints.add(new Point2d(x, y));
					setEdgePoints(edges[i], newPoints);
				}
			}

			if (j < (childCount as float) / 2.0)
			{
				currentYOffset += _prefVertEdgeOff;
			}
			else if (j > (childCount as float) / 2.0)
			{
				currentYOffset -= _prefVertEdgeOff;
			}
			// Ignore the case if equals, this means the second of 2
			// jettys with the same y (even number of edges)

			//								pos[k * 2] = currentX;
			currentXOffset += edgeSpacing;
			//								pos[k * 2 + 1] = currentYOffset;

			maxYOffset = Math.max(maxYOffset, currentYOffset);
		}
	}

}

/**
 * A utility class used to track cells whilst sorting occurs on the weighted
 * sum of their connected edges. Does not violate (x.compareTo(y)==0) ==
 * (x.equals(y))
 */
class _WeightedCellSorter implements Comparable<Object>
{

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
   * The cell whose median value is being calculated
   */
  _TreeNode cell = null;

  _WeightedCellSorter()
  {
    this(null, 0);
  }

  _WeightedCellSorter(_TreeNode cell, int weightedValue)
  {
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
  int compareTo(Object arg0)
  {
    if (arg0 is _WeightedCellSorter)
    {
      if (weightedValue > (arg0 as _WeightedCellSorter).weightedValue)
      {
        return 1;
      }
      else if (weightedValue < (arg0 as _WeightedCellSorter).weightedValue)
      {
        return -1;
      }
    }

    return 0;
  }
}

/**
 * 
 */
class _Polygon
{

  /**
   * 
   */
  _Polyline lowerHead, lowerTail, upperHead, upperTail;

}

/**
 * 
 */
class _Polyline
{

  /**
   * 
   */
  double dx, dy;

  /**
   * 
   */
  _Polyline next;

  /**
   * 
   */
  _Polyline(double dx, double dy, _Polyline next)
  {
    this.dx = dx;
    this.dy = dy;
    this.next = next;
  }

}

/**
 * 
 */
class _TreeNode
{
  /**
   * 
   */
  Object cell;

  /**
   * 
   */
  double x, y, width, height, offsetX, offsetY;

  /**
   * 
   */
  _TreeNode child, next; // parent, sibling

  /**
   * 
   */
  _Polygon contour = new _Polygon();

  /**
   * 
   */
  _TreeNode(Object cell)
  {
    this.cell = cell;
  }

}