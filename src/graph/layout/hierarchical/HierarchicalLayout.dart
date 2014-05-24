/*
 * $Id: HierarchicalLayout.java,v 1.1 2012/11/15 13:26:50 gaudenz Exp $
 * Copyright (c) 2005-2012, JGraph Ltd
 */
part of graph.layout.hierarchical;

//import graph.layout.GraphLayout;
//import graph.layout.hierarchical.model.GraphHierarchyModel;
//import graph.layout.hierarchical.stage.CoordinateAssignment;
//import graph.layout.hierarchical.stage.HierarchicalLayoutStage;
//import graph.layout.hierarchical.stage.MedianHybridCrossingReduction;
//import graph.layout.hierarchical.stage.MinimumCycleRemover;
//import graph.model.GraphModel;
//import graph.model.IGraphModel;
//import graph.view.CellState;
//import graph.view.Graph;
//import graph.view.GraphView;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Iterator;
//import java.util.LinkedHashSet;
//import java.util.List;
//import java.util.Set;
//import java.util.logging.Level;
//import java.util.logging.Logger;

//import javax.swing.SwingConstants;

/**
 * The top level compound layout of the hierarchical layout. The individual
 * elements of the layout are called in sequence.
 */
public class HierarchicalLayout extends GraphLayout/*,
JGraphLayout.Stoppable*/
{
	/** The root nodes of the layout */
	protected List<Object> _roots = null;

	/**
	 * Specifies if the parent should be resized after the layout so that it
	 * contains all the child cells. Default is false. @See parentBorder.
	 */
	protected boolean _resizeParent = true;

	/**
	 * Specifies if the parnent should be moved if resizeParent is enabled.
	 * Default is false. @See resizeParent.
	 */
	protected boolean _moveParent = false;

	/**
	 * The border to be added around the children if the parent is to be
	 * resized using resizeParent. Default is 0. @See resizeParent.
	 */
	protected int _parentBorder = 0;

	/**
	 * The spacing buffer added between cells on the same layer
	 */
	protected double _intraCellSpacing = 30.0;

	/**
	 * The spacing buffer added between cell on adjacent layers
	 */
	protected double _interRankCellSpacing = 50.0;

	/**
	 * The spacing buffer between unconnected hierarchies
	 */
	protected double _interHierarchySpacing = 60.0;

	/**
	 * The distance between each parallel edge on each ranks for long edges
	 */
	protected double _parallelEdgeSpacing = 10.0;

	/**
	 * The position of the root node(s) relative to the laid out graph in. 
	 * Default is <code>SwingConstants.NORTH</code>, i.e. top-down.
	 */
	protected int _orientation = SwingConstants.NORTH;

	/**
	 *  Specifies if the STYLE_NOEDGESTYLE flag should be set on edges that are
	 * modified by the result. Default is true.
	 */
	protected boolean _disableEdgeStyle = true;

	/**
	 * Whether or not to perform local optimisations and iterate multiple times
	 * through the algorithm
	 */
	protected boolean _fineTuning = true;

	/**
	 * Whether or not to promote edges that terminate on vertices with
	 * different but common ancestry to appear connected to the highest
	 * siblings in the ancestry chains
	 */
	protected boolean _promoteEdges = true;

	/**
	 * Whether or not to navigate edges whose terminal vertices 
	 * have different parents but are in the same ancestry chain
	 */
	protected boolean _traverseAncestors = true;

	/**
	 * The internal model formed of the layout
	 */
	protected GraphHierarchyModel _model = null;

	/**
	 * The layout progress bar
	 */
	//protected JGraphLayoutProgress progress = new JGraphLayoutProgress();
	/** The logger for this class */
	private static Logger _logger = Logger
			.getLogger("com.jgraph.layout.hierarchical.JGraphHierarchicalLayout");

	/**
	 * Constructs a hierarchical layout
	 * @param graph the graph to lay out
	 * 
	 */
	public HierarchicalLayout(Graph graph)
	{
		this(graph, SwingConstants.NORTH);
	}

	/**
	 * Constructs a hierarchical layout
	 * @param graph the graph to lay out
	 * @param orientation <code>SwingConstants.NORTH, SwingConstants.EAST, SwingConstants.SOUTH</code> or <code> SwingConstants.WEST</code>
	 * 
	 */
	public HierarchicalLayout(Graph graph, int orientation)
	{
		super(graph);
		this._orientation = orientation;
	}

	/**
	 * Returns the model for this layout algorithm.
	 */
	public GraphHierarchyModel getModel()
	{
		return _model;
	}

	/**
	 * Executes the layout for the children of the specified parent.
	 * 
	 * @param parent Parent cell that contains the children to be laid out.
	 */
	public void execute(Object parent)
	{
		execute(parent, null);
	}

	/**
	 * Executes the layout for the children of the specified parent.
	 * 
	 * @param parent Parent cell that contains the children to be laid out.
	 * @param roots the starting roots of the layout
	 */
	public void execute(Object parent, List<Object> roots)
	{
		super.execute(parent);
		IGraphModel model = graph.getModel();

		// If the roots are set and the parent is set, only
		// use the roots that are some dependent of the that
		// parent.
		// If just the root are set, use them as-is
		// If just the parent is set use it's immediate
		// children as the initial set

		if (roots == null && parent == null)
		{
			// TODO indicate the problem
			return;
		}

		if (roots != null && parent != null)
		{
			for (Object root : roots)
			{
				if (!model.isAncestor(parent, root))
				{
					roots.remove(root);
				}
			}
		}

		this._roots = roots;

		model.beginUpdate();
		try
		{
			run(parent);

			if (isResizeParent() && !graph.isCellCollapsed(parent))
			{
				graph.updateGroupBounds(new Object[] { parent },
						getParentBorder(), isMoveParent());
			}
		}
		finally
		{
			model.endUpdate();
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
	 * @return List of tree roots in parent.
	 */
	public List<Object> findRoots(Object parent, Set<Object> vertices)
	{
		List<Object> roots = new ArrayList<Object>();

		Object best = null;
		int maxDiff = -100000;
		IGraphModel model = graph.getModel();

		for (Object vertex : vertices)
		{
			if (model.isVertex(vertex) && graph.isCellVisible(vertex))
			{
				Object[] conns = this.getEdges(vertex);
				int fanOut = 0;
				int fanIn = 0;

				for (int k = 0; k < conns.length; k++)
				{
					Object src = graph.getView().getVisibleTerminal(conns[k],
							true);

					if (src == vertex)
					{
						fanOut++;
					}
					else
					{
						fanIn++;
					}
				}

				if (fanIn == 0 && fanOut > 0)
				{
					roots.add(vertex);
				}

				int diff = fanOut - fanIn;

				if (diff > maxDiff)
				{
					maxDiff = diff;
					best = vertex;
				}
			}
		}

		if (roots.isEmpty() && best != null)
		{
			roots.add(best);
		}

		return roots;
	}

	/**
	 * 
	 * @param cell
	 * @return
	 */
	public Object[] getEdges(Object cell)
	{
		IGraphModel model = graph.getModel();
		boolean isCollapsed = graph.isCellCollapsed(cell);
		List<Object> edges = new ArrayList<Object>();
		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(cell, i);

			if (isCollapsed || !graph.isCellVisible(child))
			{
				edges.addAll(Arrays.asList(GraphModel.getEdges(model, child,
						true, true, false)));
			}
		}

		edges.addAll(Arrays.asList(GraphModel.getEdges(model, cell, true,
				true, false)));
		List<Object> result = new ArrayList<Object>(edges.size());
		Iterator<Object> it = edges.iterator();

		while (it.hasNext())
		{
			Object edge = it.next();
			CellState state = graph.getView().getState(edge);
			Object source = (state != null) ? state.getVisibleTerminal(true)
					: graph.getView().getVisibleTerminal(edge, true);
			Object target = (state != null) ? state.getVisibleTerminal(false)
					: graph.getView().getVisibleTerminal(edge, false);

			if (((source != target) && ((target == cell && (parent == null || graph
					.isValidAncestor(source, parent, _traverseAncestors))) || (source == cell && (parent == null || graph
					.isValidAncestor(target, parent, _traverseAncestors))))))
			{
				result.add(edge);
			}
		}

		return result.toArray();
	}

	/**
	 * The API method used to exercise the layout upon the graph description
	 * and produce a separate description of the vertex position and edge
	 * routing changes made.
	 */
	public void run(Object parent)
	{
		// Separate out unconnected hierarchies
		List<Set<Object>> hierarchyVertices = new ArrayList<Set<Object>>();
		Set<Object> allVertexSet = new LinkedHashSet<Object>();

		if (this._roots == null && parent != null)
		{
			Set<Object> filledVertexSet = filterDescendants(parent);

			this._roots = new ArrayList<Object>();

			while (!filledVertexSet.isEmpty())
			{
				List<Object> candidateRoots = findRoots(parent, filledVertexSet);

				for (Object root : candidateRoots)
				{
					Set<Object> vertexSet = new LinkedHashSet<Object>();
					hierarchyVertices.add(vertexSet);

					_traverse(root, true, null, allVertexSet, vertexSet,
							hierarchyVertices, filledVertexSet);
				}

				this._roots.addAll(candidateRoots);
			}
		}
		else
		{
			// Find vertex set as directed traversal from roots

			for (int i = 0; i < _roots.size(); i++)
			{
				Set<Object> vertexSet = new LinkedHashSet<Object>();
				hierarchyVertices.add(vertexSet);

				_traverse(_roots.get(i), true, null, allVertexSet, vertexSet,
						hierarchyVertices, null);
			}
		}

		// Iterate through the result removing parents who have children in this layout
		
		
		// Perform a layout for each separate hierarchy
		// Track initial coordinate x-positioning
		double initialX = 0;
		Iterator<Set<Object>> iter = hierarchyVertices.iterator();

		while (iter.hasNext())
		{
			Set<Object> vertexSet = iter.next();

			this._model = new GraphHierarchyModel(this, vertexSet.toArray(),
					_roots, parent);

			cycleStage(parent);
			layeringStage();
			crossingStage(parent);
			initialX = placementStage(initialX, parent);
		}
	}

	/**
	 * Creates a set of descendant cells
	 * @param cell The cell whose descendants are to be calculated
	 * @return the descendants of the cell (not the cell)
	 */
	public Set<Object> filterDescendants(Object cell)
	{
		IGraphModel model = graph.getModel();
		Set<Object> result = new LinkedHashSet<Object>();

		if (model.isVertex(cell) && cell != this.parent && model.isVisible(cell))
		{
			result.add(cell);
		}

		if (this._traverseAncestors || cell == this.parent
				&& model.isVisible(cell))
		{
			int childCount = model.getChildCount(cell);

			for (int i = 0; i < childCount; i++)
			{
				Object child = model.getChildAt(cell, i);
				result.addAll(filterDescendants(child));
			}
		}

		return result;
	}

	/**
	 * Traverses the (directed) graph invoking the given function for each
	 * visited vertex and edge. The function is invoked with the current vertex
	 * and the incoming edge as a parameter. This implementation makes sure
	 * each vertex is only visited once. The function may return false if the
	 * traversal should stop at the given vertex.
	 * 
	 * @param vertex <Cell> that represents the vertex where the traversal starts.
	 * @param directed Optional boolean indicating if edges should only be traversed
	 * from source to target. Default is true.
	 * @param edge Optional <Cell> that represents the incoming edge. This is
	 * null for the first step of the traversal.
	 * @param allVertices Array of cell paths for the visited cells.
	 */
	protected void _traverse(Object vertex, boolean directed, Object edge,
			Set<Object> allVertices, Set<Object> currentComp,
			List<Set<Object>> hierarchyVertices, Set<Object> filledVertexSet)
	{
		GraphView view = graph.getView();
		IGraphModel model = graph.getModel();

		if (vertex != null && allVertices != null)
		{
			// Has this vertex been seen before in any traversal
			// And if the filled vertex set is populated, only 
			// process vertices in that it contains
			if (!allVertices.contains(vertex)
					&& (filledVertexSet == null ? true : filledVertexSet
							.contains(vertex)))
			{
				currentComp.add(vertex);
				allVertices.add(vertex);

				if (filledVertexSet != null)
				{
					filledVertexSet.remove(vertex);
				}

				int edgeCount = model.getEdgeCount(vertex);

				if (edgeCount > 0)
				{
					for (int i = 0; i < edgeCount; i++)
					{
						Object e = model.getEdgeAt(vertex, i);
						boolean isSource = view.getVisibleTerminal(e, true) == vertex;

						if (!directed || isSource)
						{
							Object next = view.getVisibleTerminal(e, !isSource);
							_traverse(next, directed, e, allVertices,
									currentComp, hierarchyVertices,
									filledVertexSet);
						}
					}
				}
			}
			else
			{
				if (!currentComp.contains(vertex))
				{
					// We've seen this vertex before, but not in the current component
					// This component and the one it's in need to be merged
					Set<Object> matchComp = null;

					for (Set<Object> comp : hierarchyVertices)
					{
						if (comp.contains(vertex))
						{
							currentComp.addAll(comp);
							matchComp = comp;
							break;
						}
					}

					if (matchComp != null)
					{
						hierarchyVertices.remove(matchComp);
					}
				}
			}
		}
	}

	/**
	 * Executes the cycle stage. This implementation uses the
	 * MinimumCycleRemover.
	 */
	public void cycleStage(Object parent)
	{
		HierarchicalLayoutStage cycleStage = new MinimumCycleRemover(this);
		cycleStage.execute(parent);
	}

	/**
	 * Implements first stage of a Sugiyama layout.
	 */
	public void layeringStage()
	{
		_model.initialRank();
		_model.fixRanks();
	}

	/**
	 * Executes the crossing stage using MedianHybridCrossingReduction.
	 */
	public void crossingStage(Object parent)
	{
		HierarchicalLayoutStage crossingStage = new MedianHybridCrossingReduction(
				this);
		crossingStage.execute(parent);
	}

	/**
	 * Executes the placement stage using CoordinateAssignment.
	 */
	public double placementStage(double initialX, Object parent)
	{
		CoordinateAssignment placementStage = new CoordinateAssignment(
				this, _intraCellSpacing, _interRankCellSpacing, _orientation,
				initialX, _parallelEdgeSpacing);
		placementStage.setFineTuning(_fineTuning);
		placementStage.execute(parent);

		return placementStage.getLimitX() + _interHierarchySpacing;
	}

	/**
	 * Returns the resizeParent flag.
	 */
	public boolean isResizeParent()
	{
		return _resizeParent;
	}

	/**
	 * Sets the resizeParent flag.
	 */
	public void setResizeParent(boolean value)
	{
		_resizeParent = value;
	}

	/**
	 * Returns the moveParent flag.
	 */
	public boolean isMoveParent()
	{
		return _moveParent;
	}

	/**
	 * Sets the moveParent flag.
	 */
	public void setMoveParent(boolean value)
	{
		_moveParent = value;
	}

	/**
	 * Returns parentBorder.
	 */
	public int getParentBorder()
	{
		return _parentBorder;
	}

	/**
	 * Sets parentBorder.
	 */
	public void setParentBorder(int value)
	{
		_parentBorder = value;
	}

	/**
	 * @return Returns the intraCellSpacing.
	 */
	public double getIntraCellSpacing()
	{
		return _intraCellSpacing;
	}

	/**
	 * @param intraCellSpacing
	 *            The intraCellSpacing to set.
	 */
	public void setIntraCellSpacing(double intraCellSpacing)
	{
		this._intraCellSpacing = intraCellSpacing;
	}

	/**
	 * @return Returns the interRankCellSpacing.
	 */
	public double getInterRankCellSpacing()
	{
		return _interRankCellSpacing;
	}

	/**
	 * @param interRankCellSpacing
	 *            The interRankCellSpacing to set.
	 */
	public void setInterRankCellSpacing(double interRankCellSpacing)
	{
		this._interRankCellSpacing = interRankCellSpacing;
	}

	/**
	 * @return Returns the orientation.
	 */
	public int getOrientation()
	{
		return _orientation;
	}

	/**
	 * @param orientation
	 *            The orientation to set.
	 */
	public void setOrientation(int orientation)
	{
		this._orientation = orientation;
	}

	/**
	 * @return Returns the interHierarchySpacing.
	 */
	public double getInterHierarchySpacing()
	{
		return _interHierarchySpacing;
	}

	/**
	 * @param interHierarchySpacing
	 *            The interHierarchySpacing to set.
	 */
	public void setInterHierarchySpacing(double interHierarchySpacing)
	{
		this._interHierarchySpacing = interHierarchySpacing;
	}

	public double getParallelEdgeSpacing()
	{
		return _parallelEdgeSpacing;
	}

	public void setParallelEdgeSpacing(double parallelEdgeSpacing)
	{
		this._parallelEdgeSpacing = parallelEdgeSpacing;
	}

	/**
	 * @return Returns the fineTuning.
	 */
	public boolean isFineTuning()
	{
		return _fineTuning;
	}

	/**
	 * @param fineTuning
	 *            The fineTuning to set.
	 */
	public void setFineTuning(boolean fineTuning)
	{
		this._fineTuning = fineTuning;
	}

	/**
	 *
	 */
	public boolean isDisableEdgeStyle()
	{
		return _disableEdgeStyle;
	}

	/**
	 * 
	 * @param disableEdgeStyle
	 */
	public void setDisableEdgeStyle(boolean disableEdgeStyle)
	{
		this._disableEdgeStyle = disableEdgeStyle;
	}

	/**
	 * Sets the logging level of this class
	 * @param level the logging level to set
	 */
	public void setLoggerLevel(Level level)
	{
		try
		{
			_logger.setLevel(level);
		}
		catch (SecurityException e)
		{
			// Probably running in an applet
		}
	}

	/**
	 * Returns <code>Hierarchical</code>, the name of this algorithm.
	 */
	public String toString()
	{
		return "Hierarchical";
	}

}
