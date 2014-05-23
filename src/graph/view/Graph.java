/**
 * $Id: Graph.java,v 1.6 2014/02/19 09:40:59 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.view;

import graph.canvas.Graphics2DCanvas;
import graph.canvas.ICanvas;
import graph.canvas.ImageCanvas;
import graph.model.Cell;
import graph.model.ChildChange;
import graph.model.CollapseChange;
import graph.model.Filter;
import graph.model.Geometry;
import graph.model.GeometryChange;
import graph.model.GraphModel;
import graph.model.ICell;
import graph.model.IGraphModel;
import graph.model.RootChange;
import graph.model.StyleChange;
import graph.model.TerminalChange;
import graph.model.ValueChange;
import graph.model.VisibleChange;
import graph.util.Constants;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource;
import graph.util.ImageBundle;
import graph.util.Point2d;
import graph.util.Rect;
import graph.util.Resources;
import graph.util.StyleUtils;
import graph.util.UndoableEdit;
import graph.util.Utils;
import graph.util.UndoableEdit.UndoableChange;

import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Shape;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.w3c.dom.Element;

/**
 * Implements a graph object that allows to create diagrams from a graph model
 * and stylesheet.
 * 
 * <h3>Images</h3>
 * To create an image from a graph, use the following code for a given
 * XML document (doc) and File (file):
 * 
 * <code>
 * Image img = CellRenderer.createBufferedImage(
 * 		graph, null, 1, Color.WHITE, false, null);
 * ImageIO.write(img, "png", file);
 * </code>
 * 
 * If the XML is given as a string rather than a document, the document can
 * be obtained using Utils.parse.
 * 
 * This class fires the following events:
 * 
 * Event.ROOT fires if the root in the model has changed. This event has no
 * properties.
 * 
 * Event.ALIGN_CELLS fires between begin- and endUpdate in alignCells. The
 * <code>cells</code> and <code>align</code> properties contain the respective
 * arguments that were passed to alignCells.
 * 
 * Event.FLIP_EDGE fires between begin- and endUpdate in flipEdge. The
 * <code>edge</code> property contains the edge passed to flipEdge.
 * 
 * Event.ORDER_CELLS fires between begin- and endUpdate in orderCells. The
 * <code>cells</code> and <code>back</code> properties contain the respective
 * arguments that were passed to orderCells.
 *
 * Event.CELLS_ORDERED fires between begin- and endUpdate in cellsOrdered.
 * The <code>cells</code> and <code>back</code> arguments contain the
 * respective arguments that were passed to cellsOrdered.
 * 
 * Event.GROUP_CELLS fires between begin- and endUpdate in groupCells. The
 * <code>group</code>, <code>cells</code> and <code>border</code> arguments
 * contain the respective arguments that were passed to groupCells.
 * 
 * Event.UNGROUP_CELLS fires between begin- and endUpdate in ungroupCells.
 * The <code>cells</code> property contains the array of cells that was passed
 * to ungroupCells.
 * 
 * Event.REMOVE_CELLS_FROM_PARENT fires between begin- and endUpdate in
 * removeCellsFromParent. The <code>cells</code> property contains the array of
 * cells that was passed to removeCellsFromParent.
 * 
 * Event.ADD_CELLS fires between begin- and endUpdate in addCells. The
 * <code>cells</code>, <code>parent</code>, <code>index</code>,
 * <code>source</code> and <code>target</code> properties contain the
 * respective arguments that were passed to addCells.
 * 
 * Event.CELLS_ADDED fires between begin- and endUpdate in cellsAdded. The
 * <code>cells</code>, <code>parent</code>, <code>index</code>,
 * <code>source</code>, <code>target</code> and <code>absolute</code>
 * properties contain the respective arguments that were passed to cellsAdded.
 * 
 * Event.REMOVE_CELLS fires between begin- and endUpdate in removeCells. The
 * <code>cells</code> and <code>includeEdges</code> arguments contain the
 * respective arguments that were passed to removeCells.
 * 
 * Event.CELLS_REMOVED fires between begin- and endUpdate in cellsRemoved.
 * The <code>cells</code> argument contains the array of cells that was
 * removed.
 * 
 * Event.SPLIT_EDGE fires between begin- and endUpdate in splitEdge. The
 * <code>edge</code> property contains the edge to be splitted, the
 * <code>cells</code>, <code>newEdge</code>, <code>dx</code> and
 * <code>dy</code> properties contain the respective arguments that were passed
 * to splitEdge.
 * 
 * Event.TOGGLE_CELLS fires between begin- and endUpdate in toggleCells. The
 * <code>show</code>, <code>cells</code> and <code>includeEdges</code>
 * properties contain the respective arguments that were passed to toggleCells.
 * 
 * Event.FOLD_CELLS fires between begin- and endUpdate in foldCells. The
 * <code>collapse</code>, <code>cells</code> and <code>recurse</code>
 * properties contain the respective arguments that were passed to foldCells.
 * 
 * Event.CELLS_FOLDED fires between begin- and endUpdate in cellsFolded. The
 * <code>collapse</code>, <code>cells</code> and <code>recurse</code>
 * properties contain the respective arguments that were passed to cellsFolded.
 * 
 * Event.UPDATE_CELL_SIZE fires between begin- and endUpdate in
 * updateCellSize. The <code>cell</code> and <code>ignoreChildren</code>
 * properties contain the respective arguments that were passed to
 * updateCellSize.
 * 
 * Event.RESIZE_CELLS fires between begin- and endUpdate in resizeCells. The
 * <code>cells</code> and <code>bounds</code> properties contain the respective
 * arguments that were passed to resizeCells.
 * 
 * Event.CELLS_RESIZED fires between begin- and endUpdate in cellsResized.
 * The <code>cells</code> and <code>bounds</code> properties contain the
 * respective arguments that were passed to cellsResized.
 * 
 * Event.MOVE_CELLS fires between begin- and endUpdate in moveCells. The
 * <code>cells</code>, <code>dx</code>, <code>dy</code>, <code>clone</code>,
 * <code>target</code> and <code>location</code> properties contain the
 * respective arguments that were passed to moveCells.
 * 
 * Event.CELLS_MOVED fires between begin- and endUpdate in cellsMoved. The
 * <code>cells</code>, <code>dx</code>, <code>dy</code> and
 * <code>disconnect</code> properties contain the respective arguments that
 * were passed to cellsMoved.
 * 
 * Event.CONNECT_CELL fires between begin- and endUpdate in connectCell. The
 * <code>edge</code>, <code>terminal</code> and <code>source</code> properties
 * contain the respective arguments that were passed to connectCell.
 * 
 * Event.CELL_CONNECTED fires between begin- and endUpdate in cellConnected.
 * The <code>edge</code>, <code>terminal</code> and <code>source</code>
 * properties contain the respective arguments that were passed to
 * cellConnected.
 * 
 * Event.REPAINT fires if a repaint was requested by calling repaint. The
 * <code>region</code> property contains the optional Rect that was
 * passed to repaint to define the dirty region.
 */
public class Graph extends EventSource
{

	/**
	 * Adds required resources.
	 */
	static
	{
		try
		{
			Resources.add("graph.resources.graph");
		}
		catch (Exception e)
		{
			// ignore
		}
	}

	/**
	 * Holds the version number of this release. Current version
	 * is 2.8.0.0.
	 */
	public static final String VERSION = "2.8.0.0";

	/**
	 * 
	 */
	public interface ICellVisitor
	{

		/**
		 * 
		 * @param vertex
		 * @param edge
		 */
		boolean visit(Object vertex, Object edge);

	}

	/**
	 * Property change event handling.
	 */
	protected PropertyChangeSupport _changeSupport = new PropertyChangeSupport(
			this);

	/**
	 * Holds the model that contains the cells to be displayed.
	 */
	protected IGraphModel _model;

	/**
	 * Holds the view that caches the cell states.
	 */
	protected GraphView _view;

	/**
	 * Holds the stylesheet that defines the appearance of the cells.
	 */
	protected Stylesheet _stylesheet;

	/**
	 * Holds the <mxGraphSelection> that models the current selection.
	 */
	protected GraphSelectionModel _selectionModel;

	/**
	 * Specifies the grid size. Default is 10.
	 */
	protected int _gridSize = 10;

	/**
	 * Specifies if the grid is enabled. Default is true.
	 */
	protected boolean _gridEnabled = true;

	/**
	 * Specifies if ports are enabled. This is used in <cellConnected> to update
	 * the respective style. Default is true.
	 */
	protected boolean _portsEnabled = true;

	/**
	 * Value returned by getOverlap if isAllowOverlapParent returns
	 * true for the given cell. getOverlap is used in keepInside if
	 * isKeepInsideParentOnMove returns true. The value specifies the
	 * portion of the child which is allowed to overlap the parent.
	 */
	protected double _defaultOverlap = 0.5;

	/**
	 * Specifies the default parent to be used to insert new cells.
	 * This is used in getDefaultParent. Default is null.
	 */
	protected Object _defaultParent;

	/**
	 * Specifies the alternate edge style to be used if the main control point
	 * on an edge is being doubleclicked. Default is null.
	 */
	protected String _alternateEdgeStyle;

	/**
	 * Specifies the return value for isEnabled. Default is true.
	 */
	protected boolean _enabled = true;

	/**
	 * Specifies the return value for isCell(s)Locked. Default is false.
	 */
	protected boolean _cellsLocked = false;

	/**
	 * Specifies the return value for isCell(s)Editable. Default is true.
	 */
	protected boolean _cellsEditable = true;

	/**
	 * Specifies the return value for isCell(s)Sizable. Default is true.
	 */
	protected boolean _cellsResizable = true;

	/**
	 * Specifies the return value for isCell(s)Movable. Default is true.
	 */
	protected boolean _cellsMovable = true;

	/**
	 * Specifies the return value for isCell(s)Bendable. Default is true.
	 */
	protected boolean _cellsBendable = true;

	/**
	 * Specifies the return value for isCell(s)Selectable. Default is true.
	 */
	protected boolean _cellsSelectable = true;

	/**
	 * Specifies the return value for isCell(s)Deletable. Default is true.
	 */
	protected boolean _cellsDeletable = true;

	/**
	 * Specifies the return value for isCell(s)Cloneable. Default is true.
	 */
	protected boolean _cellsCloneable = true;

	/**
	 * Specifies the return value for isCellDisconntableFromTerminal. Default
	 * is true.
	 */
	protected boolean _cellsDisconnectable = true;

	/**
	 * Specifies the return value for isLabel(s)Clipped. Default is false.
	 */
	protected boolean _labelsClipped = false;

	/**
	 * Specifies the return value for edges in isLabelMovable. Default is true.
	 */
	protected boolean _edgeLabelsMovable = true;

	/**
	 * Specifies the return value for vertices in isLabelMovable. Default is false.
	 */
	protected boolean _vertexLabelsMovable = false;

	/**
	 * Specifies the return value for isDropEnabled. Default is true.
	 */
	protected boolean _dropEnabled = true;

	/**
	 * Specifies if dropping onto edges should be enabled. Default is true.
	 */
	protected boolean _splitEnabled = true;

	/**
	 * Specifies if the graph should automatically update the cell size
	 * after an edit. This is used in isAutoSizeCell. Default is false.
	 */
	protected boolean _autoSizeCells = false;

	/**
	 * <Rect> that specifies the area in which all cells in the
	 * diagram should be placed. Uses in getMaximumGraphBounds. Use a width
	 * or height of 0 if you only want to give a upper, left corner.
	 */
	protected Rect _maximumGraphBounds = null;

	/**
	 * Rect that specifies the minimum size of the graph canvas inside
	 * the scrollpane.
	 */
	protected Rect _minimumGraphSize = null;

	/**
	 * Border to be added to the bottom and right side when the container is
	 * being resized after the graph has been changed. Default is 0.
	 */
	protected int _border = 0;

	/**
	 * Specifies if edges should appear in the foreground regardless of their
	 * order in the model. This has precendence over keepEdgeInBackground
	 * Default is false.
	 */
	protected boolean _keepEdgesInForeground = false;

	/**
	 * Specifies if edges should appear in the background regardless of their
	 * order in the model. Default is false.
	 */
	protected boolean _keepEdgesInBackground = false;

	/**
	 * Specifies if the cell size should be changed to the preferred size when
	 * a cell is first collapsed. Default is true.
	 */
	protected boolean _collapseToPreferredSize = true;

	/**
	 * Specifies if negative coordinates for vertices are allowed. Default is true.
	 */
	protected boolean _allowNegativeCoordinates = true;

	/**
	 * Specifies the return value for isConstrainChildren. Default is true.
	 */
	protected boolean _constrainChildren = true;

	/**
	 * Specifies if a parent should contain the child bounds after a resize of
	 * the child. Default is true.
	 */
	protected boolean _extendParents = true;

	/**
	 * Specifies if parents should be extended according to the <extendParents>
	 * switch if cells are added. Default is true.
	 */
	protected boolean _extendParentsOnAdd = true;

	/**
	 * Specifies if the scale and translate should be reset if
	 * the root changes in the model. Default is true.
	 */
	protected boolean _resetViewOnRootChange = true;

	/**
	 * Specifies if loops (aka self-references) are allowed.
	 * Default is false.
	 */
	protected boolean _resetEdgesOnResize = false;

	/**
	 * Specifies if edge control points should be reset after
	 * the move of a connected cell. Default is false.
	 */
	protected boolean _resetEdgesOnMove = false;

	/**
	 * Specifies if edge control points should be reset after
	 * the the edge has been reconnected. Default is true.
	 */
	protected boolean _resetEdgesOnConnect = true;

	/**
	 * Specifies if loops (aka self-references) are allowed.
	 * Default is false.
	 */
	protected boolean _allowLoops = false;

	/**
	 * Specifies the multiplicities to be used for validation of the graph.
	 */
	protected Multiplicity[] _multiplicities;

	/**
	 * Specifies the default style for loops.
	 */
	protected EdgeStyle.EdgeStyleFunction _defaultLoopStyle = EdgeStyle.Loop;

	/**
	 * Specifies if multiple edges in the same direction between
	 * the same pair of vertices are allowed. Default is true.
	 */
	protected boolean _multigraph = true;

	/**
	 * Specifies if edges are connectable. Default is false.
	 * This overrides the connectable field in edges.
	 */
	protected boolean _connectableEdges = false;

	/**
	 * Specifies if edges with disconnected terminals are
	 * allowed in the graph. Default is false.
	 */
	protected boolean _allowDanglingEdges = true;

	/**
	 * Specifies if edges that are cloned should be validated and only inserted
	 * if they are valid. Default is true.
	 */
	protected boolean _cloneInvalidEdges = false;

	/**
	 * Specifies if edges should be disconnected from their terminals when they
	 * are moved. Default is true.
	 */
	protected boolean _disconnectOnMove = true;

	/**
	 * Specifies if labels should be visible. This is used in
	 * getLabel. Default is true.
	 */
	protected boolean _labelsVisible = true;

	/**
	 * Specifies the return value for isHtmlLabel. Default is false.
	 */
	protected boolean _htmlLabels = false;

	/**
	 * Specifies if nesting of swimlanes is allowed. Default is true.
	 */
	protected boolean _swimlaneNesting = true;

	/**
	 * Specifies the maximum number of changes that should be processed to find
	 * the dirty region. If the number of changes is larger, then the complete
	 * grah is repainted. A value of zero will always compute the dirty region
	 * for any number of changes. Default is 1000.
	 */
	protected int _changesRepaintThreshold = 1000;

	/**
	 * Specifies if the origin should be automatically updated. 
	 */
	protected boolean _autoOrigin = false;

	/**
	 * Holds the current automatic origin.
	 */
	protected Point2d _origin = new Point2d();

	/**
	 * Holds the list of bundles.
	 */
	protected static List<ImageBundle> _imageBundles = new LinkedList<ImageBundle>();

	/**
	 * Fires repaint events for full repaints.
	 */
	protected IEventListener _fullRepaintHandler = new IEventListener()
	{
		public void invoke(Object sender, EventObj evt)
		{
			repaint();
		}
	};

	/**
	 * Fires repaint events for full repaints.
	 */
	protected IEventListener _updateOriginHandler = new IEventListener()
	{
		public void invoke(Object sender, EventObj evt)
		{
			if (isAutoOrigin())
			{
				_updateOrigin();
			}
		}
	};

	/**
	 * Fires repaint events for model changes.
	 */
	protected IEventListener _graphModelChangeHandler = new IEventListener()
	{
		public void invoke(Object sender, EventObj evt)
		{
			Rect dirty = graphModelChanged((IGraphModel) sender,
					(List<UndoableChange>) ((UndoableEdit) evt
							.getProperty("edit")).getChanges());
			repaint(dirty);
		}
	};

	/**
	 * Constructs a new graph with an empty
	 * {@link graph.model.GraphModel}.
	 */
	public Graph()
	{
		this(null, null);
	}

	/**
	 * Constructs a new graph for the specified model. If no model is
	 * specified, then a new, empty {@link graph.model.GraphModel} is
	 * used.
	 * 
	 * @param model Model that contains the graph data
	 */
	public Graph(IGraphModel model)
	{
		this(model, null);
	}

	/**
	 * Constructs a new graph for the specified model. If no model is
	 * specified, then a new, empty {@link graph.model.GraphModel} is
	 * used.
	 * 
	 * @param stylesheet The stylesheet to use for the graph.
	 */
	public Graph(Stylesheet stylesheet)
	{
		this(null, stylesheet);
	}

	/**
	 * Constructs a new graph for the specified model. If no model is
	 * specified, then a new, empty {@link graph.model.GraphModel} is
	 * used.
	 * 
	 * @param model Model that contains the graph data
	 */
	public Graph(IGraphModel model, Stylesheet stylesheet)
	{
		_selectionModel = _createSelectionModel();
		setModel((model != null) ? model : new GraphModel());
		setStylesheet((stylesheet != null) ? stylesheet : _createStylesheet());
		setView(_createGraphView());
	}

	/**
	 * Constructs a new selection model to be used in this graph.
	 */
	protected GraphSelectionModel _createSelectionModel()
	{
		return new GraphSelectionModel(this);
	}

	/**
	 * Constructs a new stylesheet to be used in this graph.
	 */
	protected Stylesheet _createStylesheet()
	{
		return new Stylesheet();
	}

	/**
	 * Constructs a new view to be used in this graph.
	 */
	protected GraphView _createGraphView()
	{
		return new GraphView(this);
	}

	/**
	 * Returns the graph model that contains the graph data.
	 * 
	 * @return Returns the model that contains the graph data
	 */
	public IGraphModel getModel()
	{
		return _model;
	}

	/**
	 * Sets the graph model that contains the data, and fires an
	 * Event.CHANGE followed by an Event.REPAINT event.
	 * 
	 * @param value Model that contains the graph data
	 */
	public void setModel(IGraphModel value)
	{
		if (_model != null)
		{
			_model.removeListener(_graphModelChangeHandler);
		}

		Object oldModel = _model;
		_model = value;

		if (_view != null)
		{
			_view.revalidate();
		}

		_model.addListener(Event.CHANGE, _graphModelChangeHandler);
		_changeSupport.firePropertyChange("model", oldModel, _model);
		repaint();
	}

	/**
	 * Returns the view that contains the cell states.
	 * 
	 * @return Returns the view that contains the cell states
	 */
	public GraphView getView()
	{
		return _view;
	}

	/**
	 * Sets the view that contains the cell states.
	 * 
	 * @param value View that contains the cell states
	 */
	public void setView(GraphView value)
	{
		if (_view != null)
		{
			_view.removeListener(_fullRepaintHandler);
			_view.removeListener(_updateOriginHandler);
		}

		Object oldView = _view;
		_view = value;

		if (_view != null)
		{
			_view.revalidate();
		}

		// Listens to changes in the view
		_view.addListener(Event.SCALE, _fullRepaintHandler);
		_view.addListener(Event.SCALE, _updateOriginHandler);
		_view.addListener(Event.TRANSLATE, _fullRepaintHandler);
		_view.addListener(Event.SCALE_AND_TRANSLATE, _fullRepaintHandler);
		_view.addListener(Event.SCALE_AND_TRANSLATE, _updateOriginHandler);
		_view.addListener(Event.UP, _fullRepaintHandler);
		_view.addListener(Event.DOWN, _fullRepaintHandler);

		_changeSupport.firePropertyChange("view", oldView, _view);
	}

	/**
	 * Returns the stylesheet that provides the style.
	 * 
	 * @return Returns the stylesheet that provides the style.
	 */
	public Stylesheet getStylesheet()
	{
		return _stylesheet;
	}

	/**
	 * Sets the stylesheet that provides the style.
	 * 
	 * @param value Stylesheet that provides the style.
	 */
	public void setStylesheet(Stylesheet value)
	{
		Stylesheet oldValue = _stylesheet;
		_stylesheet = value;

		_changeSupport.firePropertyChange("stylesheet", oldValue, _stylesheet);
	}

	/**
	 * Returns the cells to be selected for the given list of changes.
	 */
	public Object[] getSelectionCellsForChanges(List<UndoableChange> changes)
	{
		List<Object> cells = new ArrayList<Object>();
		Iterator<UndoableChange> it = changes.iterator();

		while (it.hasNext())
		{
			Object change = it.next();

			if (change instanceof ChildChange)
			{
				cells.add(((ChildChange) change).getChild());
			}
			else if (change instanceof TerminalChange)
			{
				cells.add(((TerminalChange) change).getCell());
			}
			else if (change instanceof ValueChange)
			{
				cells.add(((ValueChange) change).getCell());
			}
			else if (change instanceof StyleChange)
			{
				cells.add(((StyleChange) change).getCell());
			}
			else if (change instanceof GeometryChange)
			{
				cells.add(((GeometryChange) change).getCell());
			}
			else if (change instanceof CollapseChange)
			{
				cells.add(((CollapseChange) change).getCell());
			}
			else if (change instanceof VisibleChange)
			{
				VisibleChange vc = (VisibleChange) change;

				if (vc.isVisible())
				{
					cells.add(((VisibleChange) change).getCell());
				}
			}
		}

		return GraphModel.getTopmostCells(_model, cells.toArray());
	}

	/**
	 * Called when the graph model changes. Invokes processChange on each
	 * item of the given array to update the view accordingly.
	 */
	public Rect graphModelChanged(IGraphModel sender,
			List<UndoableChange> changes)
	{
		int thresh = getChangesRepaintThreshold();
		boolean ignoreDirty = thresh > 0 && changes.size() > thresh;

		// Ignores dirty rectangle if there was a root change
		if (!ignoreDirty)
		{
			Iterator<UndoableChange> it = changes.iterator();

			while (it.hasNext())
			{
				if (it.next() instanceof RootChange)
				{
					ignoreDirty = true;
					break;
				}
			}
		}

		Rect dirty = processChanges(changes, true, ignoreDirty);
		_view.validate();

		if (isAutoOrigin())
		{
			_updateOrigin();
		}

		if (!ignoreDirty)
		{
			Rect tmp = processChanges(changes, false, ignoreDirty);

			if (tmp != null)
			{
				if (dirty == null)
				{
					dirty = tmp;
				}
				else
				{
					dirty.add(tmp);
				}
			}
		}

		removeSelectionCells(getRemovedCellsForChanges(changes));

		return dirty;
	}

	/**
	 * Extends the canvas by doing another validation with a shifted
	 * global translation if the bounds of the graph are below (0,0).
	 * 
	 * The first validation is required to compute the bounds of the graph
	 * while the second validation is required to apply the new translate.
	 */
	protected void _updateOrigin()
	{
		Rect bounds = getGraphBounds();

		if (bounds != null)
		{
			double scale = getView().getScale();
			double x = bounds.getX() / scale - getBorder();
			double y = bounds.getY() / scale - getBorder();

			if (x < 0 || y < 0)
			{
				double x0 = Math.min(0, x);
				double y0 = Math.min(0, y);

				_origin.setX(_origin.getX() + x0);
				_origin.setY(_origin.getY() + y0);

				Point2d t = getView().getTranslate();
				getView().setTranslate(
						new Point2d(t.getX() - x0, t.getY() - y0));
			}
			else if ((x > 0 || y > 0)
					&& (_origin.getX() < 0 || _origin.getY() < 0))
			{
				double dx = Math.min(-_origin.getX(), x);
				double dy = Math.min(-_origin.getY(), y);

				_origin.setX(_origin.getX() + dx);
				_origin.setY(_origin.getY() + dy);

				Point2d t = getView().getTranslate();
				getView().setTranslate(
						new Point2d(t.getX() - dx, t.getY() - dy));
			}
		}
	}

	/**
	 * Returns the cells that have been removed from the model.
	 */
	public Object[] getRemovedCellsForChanges(List<UndoableChange> changes)
	{
		List<Object> result = new ArrayList<Object>();
		Iterator<UndoableChange> it = changes.iterator();

		while (it.hasNext())
		{
			Object change = it.next();

			if (change instanceof RootChange)
			{
				break;
			}
			else if (change instanceof ChildChange)
			{
				ChildChange cc = (ChildChange) change;

				if (cc.getParent() == null)
				{
					result.addAll(GraphModel.getDescendants(_model,
							cc.getChild()));
				}
			}
			else if (change instanceof VisibleChange)
			{
				Object cell = ((VisibleChange) change).getCell();
				result.addAll(GraphModel.getDescendants(_model, cell));
			}
		}

		return result.toArray();
	}

	/**
	 * Processes the changes and returns the minimal rectangle to be
	 * repainted in the buffer. A return value of null means no repaint
	 * is required.
	 */
	public Rect processChanges(List<UndoableChange> changes,
			boolean invalidate, boolean ignoreDirty)
	{
		Rect bounds = null;
		Iterator<UndoableChange> it = changes.iterator();

		while (it.hasNext())
		{
			Rect rect = processChange(it.next(), invalidate, ignoreDirty);

			if (bounds == null)
			{
				bounds = rect;
			}
			else
			{
				bounds.add(rect);
			}
		}

		return bounds;
	}

	/**
	 * Processes the given change and invalidates the respective cached data
	 * in <view>. This fires a <root> event if the root has changed in the
	 * model.
	 */
	public Rect processChange(UndoableChange change,
			boolean invalidate, boolean ignoreDirty)
	{
		Rect result = null;

		if (change instanceof RootChange)
		{
			result = (ignoreDirty) ? null : getGraphBounds();

			if (invalidate)
			{
				clearSelection();
				_removeStateForCell(((RootChange) change).getPrevious());

				if (isResetViewOnRootChange())
				{
					_view.setEventsEnabled(false);

					try
					{
						_view.scaleAndTranslate(1, 0, 0);
					}
					finally
					{
						_view.setEventsEnabled(true);
					}
				}

			}

			fireEvent(new EventObj(Event.ROOT));
		}
		else if (change instanceof ChildChange)
		{
			ChildChange cc = (ChildChange) change;

			// Repaints the parent area if it is a rendered cell (vertex or
			// edge) otherwise only the child area is repainted, same holds
			// if the parent and previous are the same object, in which case
			// only the child area needs to be repainted (change of order)
			if (!ignoreDirty)
			{
				if (cc.getParent() != cc.getPrevious())
				{
					if (_model.isVertex(cc.getParent())
							|| _model.isEdge(cc.getParent()))
					{
						result = getBoundingBox(cc.getParent(), true, true);
					}

					if (_model.isVertex(cc.getPrevious())
							|| _model.isEdge(cc.getPrevious()))
					{
						if (result != null)
						{
							result.add(getBoundingBox(cc.getPrevious(), true,
									true));
						}
						else
						{
							result = getBoundingBox(cc.getPrevious(), true,
									true);
						}
					}
				}

				if (result == null)
				{
					result = getBoundingBox(cc.getChild(), true, true);
				}
			}

			if (invalidate)
			{
				if (cc.getParent() != null)
				{
					_view.clear(cc.getChild(), false, true);
				}
				else
				{
					_removeStateForCell(cc.getChild());
				}
			}
		}
		else if (change instanceof TerminalChange)
		{
			Object cell = ((TerminalChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(cell, true);
			}

			if (invalidate)
			{
				_view.invalidate(cell);
			}
		}
		else if (change instanceof ValueChange)
		{
			Object cell = ((ValueChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(cell);
			}

			if (invalidate)
			{
				_view.clear(cell, false, false);
			}
		}
		else if (change instanceof StyleChange)
		{
			Object cell = ((StyleChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(cell, true);
			}

			if (invalidate)
			{
				// TODO: Add includeEdges argument to clear method for
				// not having to call invalidate in this case (where it
				// is possible that the perimeter has changed, which
				// means the connected edges need to be invalidated)
				_view.clear(cell, false, false);
				_view.invalidate(cell);
			}
		}
		else if (change instanceof GeometryChange)
		{
			Object cell = ((GeometryChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(cell, true, true);
			}

			if (invalidate)
			{
				_view.invalidate(cell);
			}
		}
		else if (change instanceof CollapseChange)
		{
			Object cell = ((CollapseChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(((CollapseChange) change).getCell(),
						true, true);
			}

			if (invalidate)
			{
				_removeStateForCell(cell);
			}
		}
		else if (change instanceof VisibleChange)
		{
			Object cell = ((VisibleChange) change).getCell();

			if (!ignoreDirty)
			{
				result = getBoundingBox(((VisibleChange) change).getCell(),
						true, true);
			}

			if (invalidate)
			{
				_removeStateForCell(cell);
			}
		}

		return result;
	}

	/**
	 * Removes all cached information for the given cell and its descendants.
	 * This is called when a cell was removed from the model.
	 * 
	 * @param cell Cell that was removed from the model.
	 */
	protected void _removeStateForCell(Object cell)
	{
		int childCount = _model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			_removeStateForCell(_model.getChildAt(cell, i));
		}

		_view.invalidate(cell);
		_view.removeState(cell);
	}

	//
	// Cell styles
	//

	/**
	 * Returns an array of key, value pairs representing the cell style for the
	 * given cell. If no string is defined in the model that specifies the
	 * style, then the default style for the cell is returned or <EMPTY_ARRAY>,
	 * if not style can be found.
	 * 
	 * @param cell Cell whose style should be returned.
	 * @return Returns the style of the cell.
	 */
	public Map<String, Object> getCellStyle(Object cell)
	{
		Map<String, Object> style = (_model.isEdge(cell)) ? _stylesheet
				.getDefaultEdgeStyle() : _stylesheet.getDefaultVertexStyle();

		String name = _model.getStyle(cell);

		if (name != null)
		{
			style = _postProcessCellStyle(_stylesheet.getCellStyle(name, style));
		}

		if (style == null)
		{
			style = Stylesheet.EMPTY_STYLE;
		}

		return style;
	}

	/**
	 * Tries to resolve the value for the image style in the image bundles and
	 * turns short data URIs as defined in ImageBundle to data URIs as
	 * defined in RFC 2397 of the IETF.
	 */
	protected Map<String, Object> _postProcessCellStyle(Map<String, Object> style)
	{
		if (style != null)
		{
			String key = Utils.getString(style, Constants.STYLE_IMAGE);
			String image = getImageFromBundles(key);

			if (image != null)
			{
				style.put(Constants.STYLE_IMAGE, image);
			}
			else
			{
				image = key;
			}

			// Converts short data uris to normal data uris
			if (image != null && image.startsWith("data:image/"))
			{
				int comma = image.indexOf(',');

				if (comma > 0)
				{
					image = image.substring(0, comma) + ";base64,"
							+ image.substring(comma + 1);
				}

				style.put(Constants.STYLE_IMAGE, image);
			}
		}

		return style;
	}

	/**
	 * Sets the style of the selection cells to the given value.
	 * 
	 * @param style String representing the new style of the cells.
	 */
	public Object[] setCellStyle(String style)
	{
		return setCellStyle(style, null);
	}

	/**
	 * Sets the style of the specified cells. If no cells are given, then the
	 * selection cells are changed.
	 * 
	 * @param style String representing the new style of the cells.
	 * @param cells Optional array of <mxCells> to set the style for. Default is the
	 * selection cells.
	 */
	public Object[] setCellStyle(String style, Object[] cells)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		if (cells != null)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					_model.setStyle(cells[i], style);
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return cells;
	}

	/**
	 * Toggles the boolean value for the given key in the style of the
	 * given cell. If no cell is specified then the selection cell is
	 * used.
	 * 
	 * @param key Key for the boolean value to be toggled.
	 * @param defaultValue Default boolean value if no value is defined.
	 * @param cell Cell whose style should be modified.
	 */
	public Object toggleCellStyle(String key, boolean defaultValue, Object cell)
	{
		return toggleCellStyles(key, defaultValue, new Object[] { cell })[0];
	}

	/**
	 * Toggles the boolean value for the given key in the style of the
	 * selection cells.
	 * 
	 * @param key Key for the boolean value to be toggled.
	 * @param defaultValue Default boolean value if no value is defined.
	 */
	public Object[] toggleCellStyles(String key, boolean defaultValue)
	{
		return toggleCellStyles(key, defaultValue, null);
	}

	/**
	 * Toggles the boolean value for the given key in the style of the given
	 * cells. If no cells are specified, then the selection cells are used. For
	 * example, this can be used to toggle Constants.STYLE_ROUNDED or any
	 * other style with a boolean value.
	 * 
	 * @param key String representing the key of the boolean style to be toggled.
	 * @param defaultValue Default boolean value if no value is defined.
	 * @param cells Cells whose styles should be modified.
	 */
	public Object[] toggleCellStyles(String key, boolean defaultValue,
			Object[] cells)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		if (cells != null && cells.length > 0)
		{
			CellState state = _view.getState(cells[0]);
			Map<String, Object> style = (state != null) ? state.getStyle()
					: getCellStyle(cells[0]);

			if (style != null)
			{
				String value = (Utils.isTrue(style, key, defaultValue)) ? "0"
						: "1";
				setCellStyles(key, value, cells);
			}
		}

		return cells;
	}

	/**
	 * Sets the key to value in the styles of the selection cells.
	 *
	 * @param key String representing the key to be assigned.
	 * @param value String representing the new value for the key.
	 */
	public Object[] setCellStyles(String key, String value)
	{
		return setCellStyles(key, value, null);
	}

	/**
	 * Sets the key to value in the styles of the given cells. This will modify
	 * the existing cell styles in-place and override any existing assignment
	 * for the given key. If no cells are specified, then the selection cells
	 * are changed. If no value is specified, then the respective key is
	 * removed from the styles.
	 * 
	 * @param key String representing the key to be assigned.
	 * @param value String representing the new value for the key.
	 * @param cells Array of cells to change the style for.
	 */
	public Object[] setCellStyles(String key, String value, Object[] cells)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		StyleUtils.setCellStyles(_model, cells, key, value);

		return cells;
	}

	/**
	 * Toggles the given bit for the given key in the styles of the selection
	 * cells.
	 * 
	 * @param key String representing the key to toggle the flag in.
	 * @param flag Integer that represents the bit to be toggled.
	 */
	public Object[] toggleCellStyleFlags(String key, int flag)
	{
		return toggleCellStyleFlags(key, flag, null);
	}

	/**
	 * Toggles the given bit for the given key in the styles of the specified
	 * cells.
	 * 
	 * @param key String representing the key to toggle the flag in.
	 * @param flag Integer that represents the bit to be toggled.
	 * @param cells Optional array of <mxCells> to change the style for. Default is
	 * the selection cells.
	 */
	public Object[] toggleCellStyleFlags(String key, int flag, Object[] cells)
	{
		return setCellStyleFlags(key, flag, null, cells);
	}

	/**
	 * Sets or toggles the given bit for the given key in the styles of the
	 * selection cells.
	 * 
	 * @param key String representing the key to toggle the flag in.
	 * @param flag Integer that represents the bit to be toggled.
	 * @param value Boolean value to be used or null if the value should be
	 * toggled.
	 */
	public Object[] setCellStyleFlags(String key, int flag, boolean value)
	{
		return setCellStyleFlags(key, flag, value, null);
	}

	/**
	 * Sets or toggles the given bit for the given key in the styles of the
	 * specified cells.
	 * 
	 * @param key String representing the key to toggle the flag in.
	 * @param flag Integer that represents the bit to be toggled.
	 * @param value Boolean value to be used or null if the value should be
	 * toggled.
	 * @param cells Optional array of cells to change the style for. If no
	 * cells are specified then the selection cells are used.
	 */
	public Object[] setCellStyleFlags(String key, int flag, Boolean value,
			Object[] cells)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		if (cells != null && cells.length > 0)
		{
			if (value == null)
			{
				CellState state = _view.getState(cells[0]);
				Map<String, Object> style = (state != null) ? state.getStyle()
						: getCellStyle(cells[0]);

				if (style != null)
				{
					int current = Utils.getInt(style, key);
					value = !((current & flag) == flag);
				}
			}

			StyleUtils.setCellStyleFlags(_model, cells, key, flag, value);
		}

		return cells;
	}

	/**
	 * Adds the specified bundle.
	 */
	public void addImageBundle(ImageBundle bundle)
	{
		_imageBundles.add(bundle);
	}

	/**
	 * Removes the specified bundle.
	 */
	public void removeImageBundle(ImageBundle bundle)
	{
		_imageBundles.remove(bundle);
	}

	/**
	 * Searches all bundles for the specified key and returns the value for the
	 * first match or null if the key is not found.
	 */
	public String getImageFromBundles(String key)
	{
		if (key != null)
		{
			Iterator<ImageBundle> it = _imageBundles.iterator();

			while (it.hasNext())
			{
				String value = it.next().getImage(key);

				if (value != null)
				{
					return value;
				}
			}
		}

		return null;
	}

	/**
	 * Returns the image bundles
	 */
	public List<ImageBundle> getImageBundles()
	{
		return _imageBundles;
	}

	/**
	 * Returns the image bundles
	 */
	public void getImageBundles(List<ImageBundle> value)
	{
		_imageBundles = value;
	}

	//
	// Cell alignment and orientation
	//

	/**
	 * Aligns the selection cells vertically or horizontally according to the
	 * given alignment.
	 * 
	 * @param align Specifies the alignment. Possible values are all constants
	 * in Constants with an ALIGN prefix.
	 */
	public Object[] alignCells(String align)
	{
		return alignCells(align, null);
	}

	/**
	 * Aligns the given cells vertically or horizontally according to the given
	 * alignment.
	 * 
	 * @param align Specifies the alignment. Possible values are all constants
	 * in Constants with an ALIGN prefix.
	 * @param cells Array of cells to be aligned.
	 */
	public Object[] alignCells(String align, Object[] cells)
	{
		return alignCells(align, cells, null);
	}

	/**
	 * Aligns the given cells vertically or horizontally according to the given
	 * alignment using the optional parameter as the coordinate.
	 * 
	 * @param align Specifies the alignment. Possible values are all constants
	 * in Constants with an ALIGN prefix.
	 * @param cells Array of cells to be aligned.
	 * @param param Optional coordinate for the alignment.
	 */
	public Object[] alignCells(String align, Object[] cells, Object param)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		if (cells != null && cells.length > 1)
		{
			// Finds the required coordinate for the alignment
			if (param == null)
			{
				for (int i = 0; i < cells.length; i++)
				{
					Geometry geo = getCellGeometry(cells[i]);

					if (geo != null && !_model.isEdge(cells[i]))
					{
						if (param == null)
						{
							if (align == null
									|| align.equals(Constants.ALIGN_LEFT))
							{
								param = geo.getX();
							}
							else if (align.equals(Constants.ALIGN_CENTER))
							{
								param = geo.getX() + geo.getWidth() / 2;
								break;
							}
							else if (align.equals(Constants.ALIGN_RIGHT))
							{
								param = geo.getX() + geo.getWidth();
							}
							else if (align.equals(Constants.ALIGN_TOP))
							{
								param = geo.getY();
							}
							else if (align.equals(Constants.ALIGN_MIDDLE))
							{
								param = geo.getY() + geo.getHeight() / 2;
								break;
							}
							else if (align.equals(Constants.ALIGN_BOTTOM))
							{
								param = geo.getY() + geo.getHeight();
							}
						}
						else
						{
							double tmp = Double.parseDouble(String
									.valueOf(param));

							if (align == null
									|| align.equals(Constants.ALIGN_LEFT))
							{
								param = Math.min(tmp, geo.getX());
							}
							else if (align.equals(Constants.ALIGN_RIGHT))
							{
								param = Math.max(tmp,
										geo.getX() + geo.getWidth());
							}
							else if (align.equals(Constants.ALIGN_TOP))
							{
								param = Math.min(tmp, geo.getY());
							}
							else if (align.equals(Constants.ALIGN_BOTTOM))
							{
								param = Math.max(tmp,
										geo.getY() + geo.getHeight());
							}
						}
					}
				}
			}

			// Aligns the cells to the coordinate
			_model.beginUpdate();
			try
			{
				double tmp = Double.parseDouble(String.valueOf(param));

				for (int i = 0; i < cells.length; i++)
				{
					Geometry geo = getCellGeometry(cells[i]);

					if (geo != null && !_model.isEdge(cells[i]))
					{
						geo = (Geometry) geo.clone();

						if (align == null
								|| align.equals(Constants.ALIGN_LEFT))
						{
							geo.setX(tmp);
						}
						else if (align.equals(Constants.ALIGN_CENTER))
						{
							geo.setX(tmp - geo.getWidth() / 2);
						}
						else if (align.equals(Constants.ALIGN_RIGHT))
						{
							geo.setX(tmp - geo.getWidth());
						}
						else if (align.equals(Constants.ALIGN_TOP))
						{
							geo.setY(tmp);
						}
						else if (align.equals(Constants.ALIGN_MIDDLE))
						{
							geo.setY(tmp - geo.getHeight() / 2);
						}
						else if (align.equals(Constants.ALIGN_BOTTOM))
						{
							geo.setY(tmp - geo.getHeight());
						}

						_model.setGeometry(cells[i], geo);

						if (isResetEdgesOnMove())
						{
							resetEdges(new Object[] { cells[i] });
						}
					}
				}

				fireEvent(new EventObj(Event.ALIGN_CELLS, "cells",
						cells, "align", align));
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return cells;
	}

	/**
	 * Called when the main control point of the edge is double-clicked. This
	 * implementation switches between null (default) and alternateEdgeStyle
	 * and resets the edges control points. Finally, a flip event is fired
	 * before endUpdate is called on the model.
	 * 
	 * @param edge Cell that represents the edge to be flipped.
	 * @return Returns the edge that has been flipped.
	 */
	public Object flipEdge(Object edge)
	{
		if (edge != null && _alternateEdgeStyle != null)
		{
			_model.beginUpdate();
			try
			{
				String style = _model.getStyle(edge);

				if (style == null || style.length() == 0)
				{
					_model.setStyle(edge, _alternateEdgeStyle);
				}
				else
				{
					_model.setStyle(edge, null);
				}

				// Removes all existing control points
				resetEdge(edge);
				fireEvent(new EventObj(Event.FLIP_EDGE, "edge", edge));
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return edge;
	}

	//
	// Order
	//

	/**
	 * Moves the selection cells to the front or back. This is a shortcut method.
	 * 
	 * @param back Specifies if the cells should be moved to back.
	 */
	public Object[] orderCells(boolean back)
	{
		return orderCells(back, null);
	}

	/**
	 * Moves the given cells to the front or back. The change is carried out
	 * using cellsOrdered. This method fires Event.ORDER_CELLS while the
	 * transaction is in progress.
	 * 
	 * @param back Specifies if the cells should be moved to back.
	 * @param cells Array of cells whose order should be changed. If null is
	 * specified then the selection cells are used.
	 */
	public Object[] orderCells(boolean back, Object[] cells)
	{
		if (cells == null)
		{
			cells = Utils.sortCells(getSelectionCells(), true);
		}

		_model.beginUpdate();
		try
		{
			cellsOrdered(cells, back);
			fireEvent(new EventObj(Event.ORDER_CELLS, "cells", cells,
					"back", back));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Moves the given cells to the front or back. This method fires
	 * Event.CELLS_ORDERED while the transaction is in progress.
	 * 
	 * @param cells Array of cells whose order should be changed.
	 * @param back Specifies if the cells should be moved to back.
	 */
	public void cellsOrdered(Object[] cells, boolean back)
	{
		if (cells != null)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					Object parent = _model.getParent(cells[i]);

					if (back)
					{
						_model.add(parent, cells[i], i);
					}
					else
					{
						_model.add(parent, cells[i],
								_model.getChildCount(parent) - 1);
					}
				}

				fireEvent(new EventObj(Event.CELLS_ORDERED, "cells",
						cells, "back", back));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	//
	// Grouping
	//

	/**
	 * Groups the selection cells. This is a shortcut method.
	 * 
	 * @return Returns the new group.
	 */
	public Object groupCells()
	{
		return groupCells(null);
	}

	/**
	 * Groups the selection cells and adds them to the given group. This is a
	 * shortcut method.
	 * 
	 * @return Returns the new group.
	 */
	public Object groupCells(Object group)
	{
		return groupCells(group, 0);
	}

	/**
	 * Groups the selection cells and adds them to the given group. This is a
	 * shortcut method.
	 * 
	 * @return Returns the new group.
	 */
	public Object groupCells(Object group, double border)
	{
		return groupCells(group, border, null);
	}

	/**
	 * Adds the cells into the given group. The change is carried out using
	 * cellsAdded, cellsMoved and cellsResized. This method fires
	 * Event.GROUP_CELLS while the transaction is in progress. Returns the
	 * new group. A group is only created if there is at least one entry in the
	 * given array of cells.
	 * 
	 * @param group Cell that represents the target group. If null is specified
	 * then a new group is created using createGroupCell.
	 * @param border Integer that specifies the border between the child area
	 * and the group bounds.
	 * @param cells Optional array of cells to be grouped. If null is specified
	 * then the selection cells are used.
	 */
	public Object groupCells(Object group, double border, Object[] cells)
	{
		if (cells == null)
		{
			cells = Utils.sortCells(getSelectionCells(), true);
		}

		cells = getCellsForGroup(cells);

		if (group == null)
		{
			group = createGroupCell(cells);
		}

		Rect bounds = getBoundsForGroup(group, cells, border);

		if (cells.length > 0 && bounds != null)
		{
			// Uses parent of group or previous parent of first child
			Object parent = _model.getParent(group);

			if (parent == null)
			{
				parent = _model.getParent(cells[0]);
			}

			_model.beginUpdate();
			try
			{
				// Checks if the group has a geometry and
				// creates one if one does not exist
				if (getCellGeometry(group) == null)
				{
					_model.setGeometry(group, new Geometry());
				}

				// Adds the children into the group and moves
				int index = _model.getChildCount(group);
				cellsAdded(cells, group, index, null, null, false);
				cellsMoved(cells, -bounds.getX(), -bounds.getY(), false, true);

				// Adds the group into the parent and resizes
				index = _model.getChildCount(parent);
				cellsAdded(new Object[] { group }, parent, index, null, null,
						false, false);
				cellsResized(new Object[] { group },
						new Rect[] { bounds });

				fireEvent(new EventObj(Event.GROUP_CELLS, "group",
						group, "cells", cells, "border", border));
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return group;
	}

	/**
	 * Returns the cells with the same parent as the first cell
	 * in the given array.
	 */
	public Object[] getCellsForGroup(Object[] cells)
	{
		List<Object> result = new ArrayList<Object>(cells.length);

		if (cells.length > 0)
		{
			Object parent = _model.getParent(cells[0]);
			result.add(cells[0]);

			// Filters selection cells with the same parent
			for (int i = 1; i < cells.length; i++)
			{
				if (_model.getParent(cells[i]) == parent)
				{
					result.add(cells[i]);
				}
			}
		}

		return result.toArray();
	}

	/**
	 * Returns the bounds to be used for the given group and children. This
	 * implementation computes the bounding box of the geometries of all
	 * vertices in the given children array. Edges are ignored. If the group
	 * cell is a swimlane the title region is added to the bounds.
	 */
	public Rect getBoundsForGroup(Object group, Object[] children,
			double border)
	{
		Rect result = getBoundingBoxFromGeometry(children);

		if (result != null)
		{
			if (isSwimlane(group))
			{
				Rect size = getStartSize(group);

				result.setX(result.getX() - size.getWidth());
				result.setY(result.getY() - size.getHeight());
				result.setWidth(result.getWidth() + size.getWidth());
				result.setHeight(result.getHeight() + size.getHeight());
			}

			// Adds the border
			result.setX(result.getX() - border);
			result.setY(result.getY() - border);
			result.setWidth(result.getWidth() + 2 * border);
			result.setHeight(result.getHeight() + 2 * border);
		}

		return result;
	}

	/**
	 * Hook for creating the group cell to hold the given array of <mxCells> if
	 * no group cell was given to the <group> function. The children are just
	 * for informational purpose, they will be added to the returned group
	 * later. Note that the returned group should have a geometry. The
	 * coordinates of which are later overridden.
	 * 
	 * @param cells
	 * @return Returns a new group cell.
	 */
	public Object createGroupCell(Object[] cells)
	{
		Cell group = new Cell("", new Geometry(), null);
		group.setVertex(true);
		group.setConnectable(false);

		return group;
	}

	/**
	 * Ungroups the selection cells. This is a shortcut method.
	 */
	public Object[] ungroupCells()
	{
		return ungroupCells(null);
	}

	/**
	 * Ungroups the given cells by moving the children the children to their
	 * parents parent and removing the empty groups.
	 * 
	 * @param cells Array of cells to be ungrouped. If null is specified then
	 * the selection cells are used.
	 * @return Returns the children that have been removed from the groups.
	 */
	public Object[] ungroupCells(Object[] cells)
	{
		List<Object> result = new ArrayList<Object>();

		if (cells == null)
		{
			cells = getSelectionCells();

			// Finds the cells with children
			List<Object> tmp = new ArrayList<Object>(cells.length);

			for (int i = 0; i < cells.length; i++)
			{
				if (_model.getChildCount(cells[i]) > 0)
				{
					tmp.add(cells[i]);
				}
			}

			cells = tmp.toArray();
		}

		if (cells != null && cells.length > 0)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					Object[] children = GraphModel.getChildren(_model,
							cells[i]);

					if (children != null && children.length > 0)
					{
						Object parent = _model.getParent(cells[i]);
						int index = _model.getChildCount(parent);

						cellsAdded(children, parent, index, null, null, true);
						result.addAll(Arrays.asList(children));
					}
				}

				cellsRemoved(addAllEdges(cells));
				fireEvent(new EventObj(Event.UNGROUP_CELLS, "cells",
						cells));
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return result.toArray();
	}

	/**
	 * Removes the selection cells from their parents and adds them to the
	 * default parent returned by getDefaultParent.
	 */
	public Object[] removeCellsFromParent()
	{
		return removeCellsFromParent(null);
	}

	/**
	 * Removes the specified cells from their parents and adds them to the
	 * default parent.
	 * 
	 * @param cells Array of cells to be removed from their parents.
	 * @return Returns the cells that were removed from their parents.
	 */
	public Object[] removeCellsFromParent(Object[] cells)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		_model.beginUpdate();
		try
		{
			Object parent = getDefaultParent();
			int index = _model.getChildCount(parent);

			cellsAdded(cells, parent, index, null, null, true);
			fireEvent(new EventObj(Event.REMOVE_CELLS_FROM_PARENT,
					"cells", cells));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Updates the bounds of the given array of groups so that it includes
	 * all child vertices.
	 */
	public Object[] updateGroupBounds()
	{
		return updateGroupBounds(null);
	}

	/**
	 * Updates the bounds of the given array of groups so that it includes
	 * all child vertices.
	 * 
	 * @param cells The groups whose bounds should be updated.
	 */
	public Object[] updateGroupBounds(Object[] cells)
	{
		return updateGroupBounds(cells, 0);
	}

	/**
	 * Updates the bounds of the given array of groups so that it includes
	 * all child vertices.
	 * 
	 * @param cells The groups whose bounds should be updated.
	 * @param border The border to be added in the group.
	 */
	public Object[] updateGroupBounds(Object[] cells, int border)
	{
		return updateGroupBounds(cells, border, false);
	}

	/**
	 * Updates the bounds of the given array of groups so that it includes
	 * all child vertices.
	 * 
	 * @param cells The groups whose bounds should be updated.
	 * @param border The border to be added in the group.
	 * @param moveParent Specifies if the group should be moved.
	 */
	public Object[] updateGroupBounds(Object[] cells, int border,
			boolean moveParent)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		_model.beginUpdate();
		try
		{
			for (int i = 0; i < cells.length; i++)
			{
				Geometry geo = getCellGeometry(cells[i]);

				if (geo != null)
				{
					Object[] children = getChildCells(cells[i]);

					if (children != null && children.length > 0)
					{
						Rect childBounds = getBoundingBoxFromGeometry(children);

						if (childBounds.getWidth() > 0
								&& childBounds.getHeight() > 0)
						{
							Rect size = (isSwimlane(cells[i])) ? getStartSize(cells[i])
									: new Rect();

							geo = (Geometry) geo.clone();

							if (moveParent)
							{
								geo.setX(geo.getX() + childBounds.getX()
										- size.getWidth() - border);
								geo.setY(geo.getY() + childBounds.getY()
										- size.getHeight() - border);
							}

							geo.setWidth(childBounds.getWidth()
									+ size.getWidth() + 2 * border);
							geo.setHeight(childBounds.getHeight()
									+ size.getHeight() + 2 * border);

							_model.setGeometry(cells[i], geo);
							moveCells(children,
									-childBounds.getX() + size.getWidth()
											+ border, -childBounds.getY()
											+ size.getHeight() + border);
						}
					}
				}
			}
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	//
	// Cell cloning, insertion and removal
	//

	/**
	 * Clones all cells in the given array. To clone all children in a cell and
	 * add them to another graph:
	 * 
	 * <code>
	 * graph2.addCells(graph.cloneCells(new Object[] { parent }));
	 * </code>
	 * 
	 * To clone all children in a graph layer if graph g1 and put them into the
	 * default parent (typically default layer) of another graph g2, the
	 * following code is used:
	 * 
	 * <code>
	 * g2.addCells(g1.cloneCells(g1.cloneCells(g1.getChildCells(g1.getDefaultParent()));
	 * </code>
	 */
	public Object[] cloneCells(Object[] cells)
	{

		return cloneCells(cells, true);
	}

	/**
	 * Returns the clones for the given cells. If the terminal of an edge is
	 * not in the given array, then the respective end is assigned a terminal
	 * point and the terminal is removed. If a cloned edge is invalid and
	 * allowInvalidEdges is false, then a null pointer will be at this position
	 * in the returned array. Use getCloneableCells on the input array to only
	 * clone the cells where isCellCloneable returns true.
	 * 
	 * @param cells Array of mxCells to be cloned.
	 * @return Returns the clones of the given cells.
	 */
	public Object[] cloneCells(Object[] cells, boolean allowInvalidEdges)
	{
		Object[] clones = null;

		if (cells != null)
		{
			Collection<Object> tmp = new LinkedHashSet<Object>(cells.length);
			tmp.addAll(Arrays.asList(cells));

			if (!tmp.isEmpty())
			{
				double scale = _view.getScale();
				Point2d trans = _view.getTranslate();
				clones = _model.cloneCells(cells, true);

				for (int i = 0; i < cells.length; i++)
				{
					if (!allowInvalidEdges
							&& _model.isEdge(clones[i])
							&& getEdgeValidationError(clones[i],
									_model.getTerminal(clones[i], true),
									_model.getTerminal(clones[i], false)) != null)
					{
						clones[i] = null;
					}
					else
					{
						Geometry g = _model.getGeometry(clones[i]);

						if (g != null)
						{
							CellState state = _view.getState(cells[i]);
							CellState pstate = _view.getState(_model
									.getParent(cells[i]));

							if (state != null && pstate != null)
							{
								double dx = pstate.getOrigin().getX();
								double dy = pstate.getOrigin().getY();

								if (_model.isEdge(clones[i]))
								{
									// Checks if the source is cloned or sets the terminal point
									Object src = _model.getTerminal(cells[i],
											true);

									while (src != null && !tmp.contains(src))
									{
										src = _model.getParent(src);
									}

									if (src == null)
									{
										Point2d pt = state.getAbsolutePoint(0);
										g.setTerminalPoint(
												new Point2d(pt.getX() / scale
														- trans.getX(), pt
														.getY()
														/ scale
														- trans.getY()), true);
									}

									// Checks if the target is cloned or sets the terminal point
									Object trg = _model.getTerminal(cells[i],
											false);

									while (trg != null && !tmp.contains(trg))
									{
										trg = _model.getParent(trg);
									}

									if (trg == null)
									{
										Point2d pt = state
												.getAbsolutePoint(state
														.getAbsolutePointCount() - 1);
										g.setTerminalPoint(
												new Point2d(pt.getX() / scale
														- trans.getX(), pt
														.getY()
														/ scale
														- trans.getY()), false);
									}

									// Translates the control points
									List<Point2d> points = g.getPoints();

									if (points != null)
									{
										Iterator<Point2d> it = points
												.iterator();

										while (it.hasNext())
										{
											Point2d pt = it.next();
											pt.setX(pt.getX() + dx);
											pt.setY(pt.getY() + dy);
										}
									}
								}
								else
								{
									g.setX(g.getX() + dx);
									g.setY(g.getY() + dy);
								}
							}
						}
					}
				}
			}
			else
			{
				clones = new Object[] {};
			}
		}

		return clones;
	}

	/**
	 * Creates and adds a new vertex with an empty style.
	 */
	public Object insertVertex(Object parent, String id, Object value,
			double x, double y, double width, double height)
	{
		return insertVertex(parent, id, value, x, y, width, height, null);
	}

	/**
	 * Adds a new vertex into the given parent using value as the user object
	 * and the given coordinates as the geometry of the new vertex. The id and
	 * style are used for the respective properties of the new cell, which is
	 * returned.
	 * 
	 * @param parent Cell that specifies the parent of the new vertex.
	 * @param id Optional string that defines the Id of the new vertex.
	 * @param value Object to be used as the user object.
	 * @param x Integer that defines the x coordinate of the vertex.
	 * @param y Integer that defines the y coordinate of the vertex.
	 * @param width Integer that defines the width of the vertex.
	 * @param height Integer that defines the height of the vertex.
	 * @param style Optional string that defines the cell style.
	 * @return Returns the new vertex that has been inserted.
	 */
	public Object insertVertex(Object parent, String id, Object value,
			double x, double y, double width, double height, String style)
	{
		return insertVertex(parent, id, value, x, y, width, height, style,
				false);
	}

	/**
	 * Adds a new vertex into the given parent using value as the user object
	 * and the given coordinates as the geometry of the new vertex. The id and
	 * style are used for the respective properties of the new cell, which is
	 * returned.
	 * 
	 * @param parent Cell that specifies the parent of the new vertex.
	 * @param id Optional string that defines the Id of the new vertex.
	 * @param value Object to be used as the user object.
	 * @param x Integer that defines the x coordinate of the vertex.
	 * @param y Integer that defines the y coordinate of the vertex.
	 * @param width Integer that defines the width of the vertex.
	 * @param height Integer that defines the height of the vertex.
	 * @param style Optional string that defines the cell style.
	 * @param relative Specifies if the geometry should be relative.
	 * @return Returns the new vertex that has been inserted.
	 */
	public Object insertVertex(Object parent, String id, Object value,
			double x, double y, double width, double height, String style,
			boolean relative)
	{
		Object vertex = createVertex(parent, id, value, x, y, width, height,
				style, relative);

		return addCell(vertex, parent);
	}

	/**
	 * Hook method that creates the new vertex for insertVertex.
	 * 
	 * @param parent Cell that specifies the parent of the new vertex.
	 * @param id Optional string that defines the Id of the new vertex.
	 * @param value Object to be used as the user object.
	 * @param x Integer that defines the x coordinate of the vertex.
	 * @param y Integer that defines the y coordinate of the vertex.
	 * @param width Integer that defines the width of the vertex.
	 * @param height Integer that defines the height of the vertex.
	 * @param style Optional string that defines the cell style.
	 * @return Returns the new vertex to be inserted.
	 */
	public Object createVertex(Object parent, String id, Object value,
			double x, double y, double width, double height, String style)
	{
		return createVertex(parent, id, value, x, y, width, height, style,
				false);
	}

	/**
	 * Hook method that creates the new vertex for insertVertex.
	 * 
	 * @param parent Cell that specifies the parent of the new vertex.
	 * @param id Optional string that defines the Id of the new vertex.
	 * @param value Object to be used as the user object.
	 * @param x Integer that defines the x coordinate of the vertex.
	 * @param y Integer that defines the y coordinate of the vertex.
	 * @param width Integer that defines the width of the vertex.
	 * @param height Integer that defines the height of the vertex.
	 * @param style Optional string that defines the cell style.
	 * @param relative Specifies if the geometry should be relative.
	 * @return Returns the new vertex to be inserted.
	 */
	public Object createVertex(Object parent, String id, Object value,
			double x, double y, double width, double height, String style,
			boolean relative)
	{
		Geometry geometry = new Geometry(x, y, width, height);
		geometry.setRelative(relative);

		Cell vertex = new Cell(value, geometry, style);
		vertex.setId(id);
		vertex.setVertex(true);
		vertex.setConnectable(true);

		return vertex;
	}

	/**
	 * Creates and adds a new edge with an empty style.
	 */
	public Object insertEdge(Object parent, String id, Object value,
			Object source, Object target)
	{
		return insertEdge(parent, id, value, source, target, null);
	}

	/**
	 * Adds a new edge into the given parent using value as the user object and
	 * the given source and target as the terminals of the new edge. The Id and
	 * style are used for the respective properties of the new cell, which is
	 * returned.
	 * 
	 * @param parent Cell that specifies the parent of the new edge.
	 * @param id Optional string that defines the Id of the new edge.
	 * @param value Object to be used as the user object.
	 * @param source Cell that defines the source of the edge.
	 * @param target Cell that defines the target of the edge.
	 * @param style Optional string that defines the cell style.
	 * @return Returns the new edge that has been inserted.
	 */
	public Object insertEdge(Object parent, String id, Object value,
			Object source, Object target, String style)
	{
		Object edge = createEdge(parent, id, value, source, target, style);

		return addEdge(edge, parent, source, target, null);
	}

	/**
	 * Hook method that creates the new edge for insertEdge. This
	 * implementation does not set the source and target of the edge, these
	 * are set when the edge is added to the model.
	 * 
	 * @param parent Cell that specifies the parent of the new edge.
	 * @param id Optional string that defines the Id of the new edge.
	 * @param value Object to be used as the user object.
	 * @param source Cell that defines the source of the edge.
	 * @param target Cell that defines the target of the edge.
	 * @param style Optional string that defines the cell style.
	 * @return Returns the new edge to be inserted.
	 */
	public Object createEdge(Object parent, String id, Object value,
			Object source, Object target, String style)
	{
		Cell edge = new Cell(value, new Geometry(), style);

		edge.setId(id);
		edge.setEdge(true);
		edge.getGeometry().setRelative(true);

		return edge;
	}

	/**
	 * Adds the edge to the parent and connects it to the given source and
	 * target terminals. This is a shortcut method.
	 * 
	 * @param edge Edge to be inserted into the given parent.
	 * @param parent Object that represents the new parent. If no parent is
	 * given then the default parent is used.
	 * @param source Optional cell that represents the source terminal.
	 * @param target Optional cell that represents the target terminal.
	 * @param index Optional index to insert the cells at. Default is to append.
	 * @return Returns the edge that was added.
	 */
	public Object addEdge(Object edge, Object parent, Object source,
			Object target, Integer index)
	{
		return addCell(edge, parent, index, source, target);
	}

	/**
	 * Adds the cell to the default parent. This is a shortcut method.
	 * 
	 * @param cell Cell to be inserted.
	 * @return Returns the cell that was added.
	 */
	public Object addCell(Object cell)
	{
		return addCell(cell, null);
	}

	/**
	 * Adds the cell to the parent. This is a shortcut method.
	 * 
	 * @param cell Cell tobe inserted.
	 * @param parent Object that represents the new parent. If no parent is
	 * given then the default parent is used.
	 * @return Returns the cell that was added.
	 */
	public Object addCell(Object cell, Object parent)
	{
		return addCell(cell, parent, null, null, null);
	}

	/**
	 * Adds the cell to the parent and connects it to the given source and
	 * target terminals. This is a shortcut method.
	 * 
	 * @param cell Cell to be inserted into the given parent.
	 * @param parent Object that represents the new parent. If no parent is
	 * given then the default parent is used.
	 * @param index Optional index to insert the cells at. Default is to append.
	 * @param source Optional cell that represents the source terminal.
	 * @param target Optional cell that represents the target terminal.
	 * @return Returns the cell that was added.
	 */
	public Object addCell(Object cell, Object parent, Integer index,
			Object source, Object target)
	{
		return addCells(new Object[] { cell }, parent, index, source, target)[0];
	}

	/**
	 * Adds the cells to the default parent. This is a shortcut method.
	 * 
	 * @param cells Array of cells to be inserted.
	 * @return Returns the cells that were added.
	 */
	public Object[] addCells(Object[] cells)
	{
		return addCells(cells, null);
	}

	/**
	 * Adds the cells to the parent. This is a shortcut method.
	 * 
	 * @param cells Array of cells to be inserted.
	 * @param parent Optional cell that represents the new parent. If no parent
	 * is specified then the default parent is used.
	 * @return Returns the cells that were added.
	 */
	public Object[] addCells(Object[] cells, Object parent)
	{
		return addCells(cells, parent, null);
	}

	/**
	 * Adds the cells to the parent at the given index. This is a shortcut method.
	 * 
	 * @param cells Array of cells to be inserted.
	 * @param parent Optional cell that represents the new parent. If no parent
	 * is specified then the default parent is used.
	 * @param index Optional index to insert the cells at. Default is to append.
	 * @return Returns the cells that were added.
	 */
	public Object[] addCells(Object[] cells, Object parent, Integer index)
	{
		return addCells(cells, parent, index, null, null);
	}

	/**
	 * Adds the cells to the parent at the given index, connecting each cell to
	 * the optional source and target terminal. The change is carried out using
	 * cellsAdded. This method fires Event.ADD_CELLS while the transaction
	 * is in progress.
	 * 
	 * @param cells Array of cells to be added.
	 * @param parent Optional cell that represents the new parent. If no parent
	 * is specified then the default parent is used.
	 * @param index Optional index to insert the cells at. Default is to append.
	 * @param source Optional source terminal for all inserted cells.
	 * @param target Optional target terminal for all inserted cells.
	 * @return Returns the cells that were added.
	 */
	public Object[] addCells(Object[] cells, Object parent, Integer index,
			Object source, Object target)
	{
		if (parent == null)
		{
			parent = getDefaultParent();
		}

		if (index == null)
		{
			index = _model.getChildCount(parent);
		}

		_model.beginUpdate();
		try
		{
			cellsAdded(cells, parent, index, source, target, false, true);
			fireEvent(new EventObj(Event.ADD_CELLS, "cells", cells,
					"parent", parent, "index", index, "source", source,
					"target", target));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}
	/**
	 * Adds the specified cells to the given parent. This method fires
	 * Event.CELLS_ADDED while the transaction is in progress.
	 */
	public void cellsAdded(Object[] cells, Object parent, Integer index,
			Object source, Object target, boolean absolute)
	{
		cellsAdded(cells, parent, index, source, target, absolute, true);
	}
	
	/**
	 * Adds the specified cells to the given parent. This method fires
	 * Event.CELLS_ADDED while the transaction is in progress.
	 */
	public void cellsAdded(Object[] cells, Object parent, Integer index,
			Object source, Object target, boolean absolute, boolean constrain)
	{
		if (cells != null && parent != null && index != null)
		{
			_model.beginUpdate();
			try
			{
				CellState parentState = (absolute) ? _view.getState(parent)
						: null;
				Point2d o1 = (parentState != null) ? parentState.getOrigin()
						: null;
				Point2d zero = new Point2d(0, 0);

				for (int i = 0; i < cells.length; i++)
				{
					if (cells[i] == null)
					{
						index--;
					}
					else
					{
						Object previous = _model.getParent(cells[i]);

						// Keeps the cell at its absolute location
						if (o1 != null && cells[i] != parent
								&& parent != previous)
						{
							CellState oldState = _view.getState(previous);
							Point2d o2 = (oldState != null) ? oldState
									.getOrigin() : zero;
							Geometry geo = _model.getGeometry(cells[i]);

							if (geo != null)
							{
								double dx = o2.getX() - o1.getX();
								double dy = o2.getY() - o1.getY();

								geo = (Geometry) geo.clone();
								geo.translate(dx, dy);

								if (!geo.isRelative()
										&& _model.isVertex(cells[i])
										&& !isAllowNegativeCoordinates())
								{
									geo.setX(Math.max(0, geo.getX()));
									geo.setY(Math.max(0, geo.getY()));
								}

								_model.setGeometry(cells[i], geo);
							}
						}

						// Decrements all following indices
						// if cell is already in parent
						if (parent == previous)
						{
							index--;
						}

						_model.add(parent, cells[i], index + i);

						// Extends the parent
						if (isExtendParentsOnAdd() && isExtendParent(cells[i]))
						{
							extendParent(cells[i]);
						}

						// Constrains the child
						if (constrain)
						{
							constrainChild(cells[i]);
						}

						// Sets the source terminal
						if (source != null)
						{
							cellConnected(cells[i], source, true, null);
						}

						// Sets the target terminal
						if (target != null)
						{
							cellConnected(cells[i], target, false, null);
						}
					}
				}

				fireEvent(new EventObj(Event.CELLS_ADDED, "cells",
						cells, "parent", parent, "index", index, "source",
						source, "target", target, "absolute", absolute));

			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Removes the selection cells from the graph.
	 * 
	 * @return Returns the cells that have been removed.
	 */
	public Object[] removeCells()
	{
		return removeCells(null);
	}

	/**
	 * Removes the given cells from the graph.
	 * 
	 * @param cells Array of cells to remove.
	 * @return Returns the cells that have been removed.
	 */
	public Object[] removeCells(Object[] cells)
	{
		return removeCells(cells, true);
	}

	/**
	 * Removes the given cells from the graph including all connected edges if
	 * includeEdges is true. The change is carried out using cellsRemoved. This
	 * method fires Event.REMOVE_CELLS while the transaction is in progress.
	 * 
	 * @param cells Array of cells to remove. If null is specified then the
	 * selection cells which are deletable are used.
	 * @param includeEdges Specifies if all connected edges should be removed as
	 * well.
	 */
	public Object[] removeCells(Object[] cells, boolean includeEdges)
	{
		if (cells == null)
		{
			cells = getDeletableCells(getSelectionCells());
		}

		// Adds all edges to the cells
		if (includeEdges)
		{
			cells = getDeletableCells(addAllEdges(cells));
		}

		_model.beginUpdate();
		try
		{
			cellsRemoved(cells);
			fireEvent(new EventObj(Event.REMOVE_CELLS, "cells", cells,
					"includeEdges", includeEdges));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Removes the given cells from the model. This method fires
	 * Event.CELLS_REMOVED while the transaction is in progress.
	 * 
	 * @param cells Array of cells to remove.
	 */
	public void cellsRemoved(Object[] cells)
	{
		if (cells != null && cells.length > 0)
		{
			double scale = _view.getScale();
			Point2d tr = _view.getTranslate();

			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					// Disconnects edges which are not in cells
					Collection<Object> cellSet = new HashSet<Object>();
					cellSet.addAll(Arrays.asList(cells));
					Object[] edges = getConnections(cells[i]);

					for (int j = 0; j < edges.length; j++)
					{
						if (!cellSet.contains(edges[j]))
						{
							Geometry geo = _model.getGeometry(edges[j]);

							if (geo != null)
							{
								CellState state = _view.getState(edges[j]);

								if (state != null)
								{
									geo = (Geometry) geo.clone();
									boolean source = state
											.getVisibleTerminal(true) == cells[i];
									int n = (source) ? 0 : state
											.getAbsolutePointCount() - 1;
									Point2d pt = state.getAbsolutePoint(n);

									geo.setTerminalPoint(new Point2d(pt.getX()
											/ scale - tr.getX(), pt.getY()
											/ scale - tr.getY()), source);
									_model.setTerminal(edges[j], null, source);
									_model.setGeometry(edges[j], geo);
								}
							}
						}
					}

					_model.remove(cells[i]);
				}

				fireEvent(new EventObj(Event.CELLS_REMOVED, "cells",
						cells));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * 
	 */
	public Object splitEdge(Object edge, Object[] cells)
	{
		return splitEdge(edge, cells, null, 0, 0);
	}

	/**
	 * 
	 */
	public Object splitEdge(Object edge, Object[] cells, double dx, double dy)
	{
		return splitEdge(edge, cells, null, dx, dy);
	}

	/**
	 * Splits the given edge by adding a newEdge between the previous source
	 * and the given cell and reconnecting the source of the given edge to the
	 * given cell. Fires Event.SPLIT_EDGE while the transaction is in
	 * progress.
	 * 
	 * @param edge Object that represents the edge to be splitted.
	 * @param cells Array that contains the cells to insert into the edge.
	 * @param newEdge Object that represents the edge to be inserted.
	 * @return Returns the new edge that has been inserted.
	 */
	public Object splitEdge(Object edge, Object[] cells, Object newEdge,
			double dx, double dy)
	{
		if (newEdge == null)
		{
			newEdge = cloneCells(new Object[] { edge })[0];
		}

		Object parent = _model.getParent(edge);
		Object source = _model.getTerminal(edge, true);

		_model.beginUpdate();
		try
		{
			cellsMoved(cells, dx, dy, false, false);
			cellsAdded(cells, parent, _model.getChildCount(parent), null, null,
					true);
			cellsAdded(new Object[] { newEdge }, parent,
					_model.getChildCount(parent), source, cells[0], false);
			cellConnected(edge, cells[0], true, null);
			fireEvent(new EventObj(Event.SPLIT_EDGE, "edge", edge,
					"cells", cells, "newEdge", newEdge, "dx", dx, "dy", dy));
		}
		finally
		{
			_model.endUpdate();
		}

		return newEdge;
	}

	//
	// Cell visibility
	//

	/**
	 * Sets the visible state of the selection cells. This is a shortcut
	 * method.
	 * 
	 * @param show Boolean that specifies the visible state to be assigned.
	 * @return Returns the cells whose visible state was changed.
	 */
	public Object[] toggleCells(boolean show)
	{
		return toggleCells(show, null);
	}

	/**
	 * Sets the visible state of the specified cells. This is a shortcut
	 * method.
	 *
	 * @param show Boolean that specifies the visible state to be assigned.
	 * @param cells Array of cells whose visible state should be changed.
	 * @return Returns the cells whose visible state was changed.
	 */
	public Object[] toggleCells(boolean show, Object[] cells)
	{
		return toggleCells(show, cells, true);
	}

	/**
	 * Sets the visible state of the specified cells and all connected edges
	 * if includeEdges is true. The change is carried out using cellsToggled.
	 * This method fires Event.TOGGLE_CELLS while the transaction is in
	 * progress.
	 *
	 * @param show Boolean that specifies the visible state to be assigned.
	 * @param cells Array of cells whose visible state should be changed. If
	 * null is specified then the selection cells are used.
	 * @return Returns the cells whose visible state was changed.
	 */
	public Object[] toggleCells(boolean show, Object[] cells,
			boolean includeEdges)
	{
		if (cells == null)
		{
			cells = getSelectionCells();
		}

		// Adds all connected edges recursively
		if (includeEdges)
		{
			cells = addAllEdges(cells);
		}

		_model.beginUpdate();
		try
		{
			cellsToggled(cells, show);
			fireEvent(new EventObj(Event.TOGGLE_CELLS, "show", show,
					"cells", cells, "includeEdges", includeEdges));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Sets the visible state of the specified cells.
	 * 
	 * @param cells Array of cells whose visible state should be changed.
	 * @param show Boolean that specifies the visible state to be assigned.
	 */
	public void cellsToggled(Object[] cells, boolean show)
	{
		if (cells != null && cells.length > 0)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					_model.setVisible(cells[i], show);
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	//
	// Folding
	//

	/**
	 * Sets the collapsed state of the selection cells without recursion.
	 * This is a shortcut method.
	 * 
	 * @param collapse Boolean that specifies the collapsed state to be
	 * assigned.
	 * @return Returns the cells whose collapsed state was changed.
	 */
	public Object[] foldCells(boolean collapse)
	{
		return foldCells(collapse, false);
	}

	/**
	 * Sets the collapsed state of the selection cells. This is a shortcut
	 * method.
	 * 
	 * @param collapse Boolean that specifies the collapsed state to be
	 * assigned.
	 * @param recurse Boolean that specifies if the collapsed state should
	 * be assigned to all descendants.
	 * @return Returns the cells whose collapsed state was changed.
	 */
	public Object[] foldCells(boolean collapse, boolean recurse)
	{
		return foldCells(collapse, recurse, null);
	}

	/**
	 * Invokes foldCells with checkFoldable set to false.
	 */
	public Object[] foldCells(boolean collapse, boolean recurse, Object[] cells)
	{
		return foldCells(collapse, recurse, cells, false);
	}

	/**
	 * Sets the collapsed state of the specified cells and all descendants
	 * if recurse is true. The change is carried out using cellsFolded.
	 * This method fires Event.FOLD_CELLS while the transaction is in
	 * progress. Returns the cells whose collapsed state was changed.
	 * 
	 * @param collapse Boolean indicating the collapsed state to be assigned.
	 * @param recurse Boolean indicating if the collapsed state of all
	 * descendants should be set.
	 * @param cells Array of cells whose collapsed state should be set. If
	 * null is specified then the foldable selection cells are used.
	 * @param checkFoldable Boolean indicating of isCellFoldable should be
	 * checked. Default is false.
	 */
	public Object[] foldCells(boolean collapse, boolean recurse,
			Object[] cells, boolean checkFoldable)
	{
		if (cells == null)
		{
			cells = getFoldableCells(getSelectionCells(), collapse);
		}

		_model.beginUpdate();
		try
		{
			cellsFolded(cells, collapse, recurse, checkFoldable);
			fireEvent(new EventObj(Event.FOLD_CELLS, "cells", cells,
					"collapse", collapse, "recurse", recurse));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Invokes cellsFoldable with checkFoldable set to false.
	 */
	public void cellsFolded(Object[] cells, boolean collapse, boolean recurse)
	{
		cellsFolded(cells, collapse, recurse, false);
	}

	/**
	 * Sets the collapsed state of the specified cells. This method fires
	 * Event.CELLS_FOLDED while the transaction is in progress. Returns the
	 * cells whose collapsed state was changed.
	 * 
	 * @param cells Array of cells whose collapsed state should be set.
	 * @param collapse Boolean indicating the collapsed state to be assigned.
	 * @param recurse Boolean indicating if the collapsed state of all
	 * descendants should be set.
	 * @param checkFoldable Boolean indicating of isCellFoldable should be
	 * checked. Default is false.
	 */
	public void cellsFolded(Object[] cells, boolean collapse, boolean recurse,
			boolean checkFoldable)
	{
		if (cells != null && cells.length > 0)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					if ((!checkFoldable || isCellFoldable(cells[i], collapse))
							&& collapse != isCellCollapsed(cells[i]))
					{
						_model.setCollapsed(cells[i], collapse);
						swapBounds(cells[i], collapse);

						if (isExtendParent(cells[i]))
						{
							extendParent(cells[i]);
						}

						if (recurse)
						{
							Object[] children = GraphModel.getChildren(_model,
									cells[i]);
							cellsFolded(children, collapse, recurse);
						}
					}
				}

				fireEvent(new EventObj(Event.CELLS_FOLDED, "cells",
						cells, "collapse", collapse, "recurse", recurse));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Swaps the alternate and the actual bounds in the geometry of the given
	 * cell invoking updateAlternateBounds before carrying out the swap.
	 * 
	 * @param cell Cell for which the bounds should be swapped.
	 * @param willCollapse Boolean indicating if the cell is going to be collapsed.
	 */
	public void swapBounds(Object cell, boolean willCollapse)
	{
		if (cell != null)
		{
			Geometry geo = _model.getGeometry(cell);

			if (geo != null)
			{
				geo = (Geometry) geo.clone();

				updateAlternateBounds(cell, geo, willCollapse);
				geo.swap();

				_model.setGeometry(cell, geo);
			}
		}
	}

	/**
	 * Updates or sets the alternate bounds in the given geometry for the given
	 * cell depending on whether the cell is going to be collapsed. If no
	 * alternate bounds are defined in the geometry and
	 * collapseToPreferredSize is true, then the preferred size is used for
	 * the alternate bounds. The top, left corner is always kept at the same
	 * location.
	 * 
	 * @param cell Cell for which the geometry is being udpated.
	 * @param geo Geometry for which the alternate bounds should be updated.
	 * @param willCollapse Boolean indicating if the cell is going to be collapsed.
	 */
	public void updateAlternateBounds(Object cell, Geometry geo,
			boolean willCollapse)
	{
		if (cell != null && geo != null)
		{
			if (geo.getAlternateBounds() == null)
			{
				Rect bounds = null;

				if (isCollapseToPreferredSize())
				{
					bounds = getPreferredSizeForCell(cell);

					if (isSwimlane(cell))
					{
						Rect size = getStartSize(cell);

						bounds.setHeight(Math.max(bounds.getHeight(),
								size.getHeight()));
						bounds.setWidth(Math.max(bounds.getWidth(),
								size.getWidth()));
					}
				}

				if (bounds == null)
				{
					bounds = geo;
				}

				geo.setAlternateBounds(new Rect(geo.getX(), geo.getY(),
						bounds.getWidth(), bounds.getHeight()));
			}
			else
			{
				geo.getAlternateBounds().setX(geo.getX());
				geo.getAlternateBounds().setY(geo.getY());
			}
		}
	}

	/**
	 * Returns an array with the given cells and all edges that are connected
	 * to a cell or one of its descendants.
	 */
	public Object[] addAllEdges(Object[] cells)
	{
		List<Object> allCells = new ArrayList<Object>(cells.length);
		allCells.addAll(Arrays.asList(cells));
		allCells.addAll(Arrays.asList(getAllEdges(cells)));

		return allCells.toArray();
	}

	/**
	 * Returns all edges connected to the given cells or their descendants.
	 */
	public Object[] getAllEdges(Object[] cells)
	{
		List<Object> edges = new ArrayList<Object>();

		if (cells != null)
		{
			for (int i = 0; i < cells.length; i++)
			{
				int edgeCount = _model.getEdgeCount(cells[i]);

				for (int j = 0; j < edgeCount; j++)
				{
					edges.add(_model.getEdgeAt(cells[i], j));
				}

				// Recurses
				Object[] children = GraphModel.getChildren(_model, cells[i]);
				edges.addAll(Arrays.asList(getAllEdges(children)));
			}
		}

		return edges.toArray();
	}

	//
	// Cell sizing
	//

	/**
	 * Updates the size of the given cell in the model using
	 * getPreferredSizeForCell to get the new size. This function
	 * fires beforeUpdateSize and afterUpdateSize events.
	 * 
	 * @param cell <Cell> for which the size should be changed.
	 */
	public Object updateCellSize(Object cell)
	{
		return updateCellSize(cell, false);
	}

	/**
	 * Updates the size of the given cell in the model using
	 * getPreferredSizeForCell to get the new size. This function
	 * fires Event.UPDATE_CELL_SIZE.
	 * 
	 * @param cell Cell for which the size should be changed.
	 */
	public Object updateCellSize(Object cell, boolean ignoreChildren)
	{
		_model.beginUpdate();
		try
		{
			cellSizeUpdated(cell, ignoreChildren);
			fireEvent(new EventObj(Event.UPDATE_CELL_SIZE, "cell", cell,
					"ignoreChildren", ignoreChildren));
		}
		finally
		{
			_model.endUpdate();
		}

		return cell;
	}

	/**
	 * Updates the size of the given cell in the model using
	 * getPreferredSizeForCell to get the new size.
	 * 
	 * @param cell Cell for which the size should be changed.
	 */
	public void cellSizeUpdated(Object cell, boolean ignoreChildren)
	{
		if (cell != null)
		{
			_model.beginUpdate();
			try
			{
				Rect size = getPreferredSizeForCell(cell);
				Geometry geo = _model.getGeometry(cell);

				if (size != null && geo != null)
				{
					boolean collapsed = isCellCollapsed(cell);
					geo = (Geometry) geo.clone();

					if (isSwimlane(cell))
					{
						CellState state = _view.getState(cell);
						Map<String, Object> style = (state != null) ? state
								.getStyle() : getCellStyle(cell);
						String cellStyle = _model.getStyle(cell);

						if (cellStyle == null)
						{
							cellStyle = "";
						}

						if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL,
								true))
						{
							cellStyle = StyleUtils.setStyle(cellStyle,
									Constants.STYLE_STARTSIZE,
									String.valueOf(size.getHeight() + 8));

							if (collapsed)
							{
								geo.setHeight(size.getHeight() + 8);
							}

							geo.setWidth(size.getWidth());
						}
						else
						{
							cellStyle = StyleUtils.setStyle(cellStyle,
									Constants.STYLE_STARTSIZE,
									String.valueOf(size.getWidth() + 8));

							if (collapsed)
							{
								geo.setWidth(size.getWidth() + 8);
							}

							geo.setHeight(size.getHeight());
						}

						_model.setStyle(cell, cellStyle);
					}
					else
					{
						geo.setWidth(size.getWidth());
						geo.setHeight(size.getHeight());
					}

					if (!ignoreChildren && !collapsed)
					{
						Rect bounds = _view.getBounds(GraphModel
								.getChildren(_model, cell));

						if (bounds != null)
						{
							Point2d tr = _view.getTranslate();
							double scale = _view.getScale();

							double width = (bounds.getX() + bounds.getWidth())
									/ scale - geo.getX() - tr.getX();
							double height = (bounds.getY() + bounds.getHeight())
									/ scale - geo.getY() - tr.getY();

							geo.setWidth(Math.max(geo.getWidth(), width));
							geo.setHeight(Math.max(geo.getHeight(), height));
						}
					}

					cellsResized(new Object[] { cell },
							new Rect[] { geo });
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Returns the preferred width and height of the given <Cell> as an
	 * <Rect>.
	 * 
	 * @param cell <Cell> for which the preferred size should be returned.
	 */
	public Rect getPreferredSizeForCell(Object cell)
	{
		Rect result = null;

		if (cell != null)
		{
			CellState state = _view.getState(cell);
			Map<String, Object> style = (state != null) ? state._style
					: getCellStyle(cell);

			if (style != null && !_model.isEdge(cell))
			{
				double dx = 0;
				double dy = 0;

				// Adds dimension of image if shape is a label
				if (getImage(state) != null
						|| Utils.getString(style, Constants.STYLE_IMAGE) != null)
				{
					if (Utils.getString(style, Constants.STYLE_SHAPE, "")
							.equals(Constants.SHAPE_LABEL))
					{
						if (Utils.getString(style,
								Constants.STYLE_VERTICAL_ALIGN, "").equals(
								Constants.ALIGN_MIDDLE))
						{
							dx += Utils.getDouble(style,
									Constants.STYLE_IMAGE_WIDTH,
									Constants.DEFAULT_IMAGESIZE);
						}

						if (Utils.getString(style, Constants.STYLE_ALIGN,
								"").equals(Constants.ALIGN_CENTER))
						{
							dy += Utils.getDouble(style,
									Constants.STYLE_IMAGE_HEIGHT,
									Constants.DEFAULT_IMAGESIZE);
						}
					}
				}

				// Adds spacings
				double spacing = Utils.getDouble(style,
						Constants.STYLE_SPACING);
				dx += 2 * spacing;
				dx += Utils.getDouble(style, Constants.STYLE_SPACING_LEFT);
				dx += Utils.getDouble(style, Constants.STYLE_SPACING_RIGHT);

				dy += 2 * spacing;
				dy += Utils.getDouble(style, Constants.STYLE_SPACING_TOP);
				dy += Utils
						.getDouble(style, Constants.STYLE_SPACING_BOTTOM);

				// LATER: Add space for collapse/expand icon if applicable

				// Adds space for label
				String value = getLabel(cell);

				if (value != null && value.length() > 0)
				{
					Rect size = Utils.getLabelSize(value, style,
							isHtmlLabel(cell), 1);
					double width = size.getWidth() + dx;
					double height = size.getHeight() + dy;

					if (!Utils.isTrue(style, Constants.STYLE_HORIZONTAL,
							true))
					{
						double tmp = height;

						height = width;
						width = tmp;
					}

					if (_gridEnabled)
					{
						width = snap(width + _gridSize / 2);
						height = snap(height + _gridSize / 2);
					}

					result = new Rect(0, 0, width, height);
				}
				else
				{
					double gs2 = 4 * _gridSize;
					result = new Rect(0, 0, gs2, gs2);
				}
			}
		}

		return result;
	}

	/**
	 * Sets the bounds of the given cell using resizeCells. Returns the
	 * cell which was passed to the function.
	 * 
	 * @param cell <Cell> whose bounds should be changed.
	 * @param bounds <Rect> that represents the new bounds.
	 */
	public Object resizeCell(Object cell, Rect bounds)
	{
		return resizeCells(new Object[] { cell }, new Rect[] { bounds })[0];
	}

	/**
	 * Sets the bounds of the given cells and fires a Event.RESIZE_CELLS
	 * event. while the transaction is in progress. Returns the cells which
	 * have been passed to the function.
	 * 
	 * @param cells Array of cells whose bounds should be changed.
	 * @param bounds Array of rectangles that represents the new bounds.
	 */
	public Object[] resizeCells(Object[] cells, Rect[] bounds)
	{
		_model.beginUpdate();
		try
		{
			cellsResized(cells, bounds);
			fireEvent(new EventObj(Event.RESIZE_CELLS, "cells", cells,
					"bounds", bounds));
		}
		finally
		{
			_model.endUpdate();
		}

		return cells;
	}

	/**
	 * Sets the bounds of the given cells and fires a <Event.CELLS_RESIZED>
	 * event. If extendParents is true, then the parent is extended if a child
	 * size is changed so that it overlaps with the parent.
	 * 
	 * @param cells Array of <mxCells> whose bounds should be changed.
	 * @param bounds Array of <mxRectangles> that represents the new bounds.
	 */
	public void cellsResized(Object[] cells, Rect[] bounds)
	{
		if (cells != null && bounds != null && cells.length == bounds.length)
		{
			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					Rect tmp = bounds[i];
					Geometry geo = _model.getGeometry(cells[i]);

					if (geo != null
							&& (geo.getX() != tmp.getX()
									|| geo.getY() != tmp.getY()
									|| geo.getWidth() != tmp.getWidth() || geo
									.getHeight() != tmp.getHeight()))
					{
						geo = (Geometry) geo.clone();

						if (geo.isRelative())
						{
							Point2d offset = geo.getOffset();

							if (offset != null)
							{
								offset.setX(offset.getX() + tmp.getX());
								offset.setY(offset.getY() + tmp.getY());
							}
						}
						else
						{
							geo.setX(tmp.getX());
							geo.setY(tmp.getY());
						}

						geo.setWidth(tmp.getWidth());
						geo.setHeight(tmp.getHeight());

						if (!geo.isRelative() && _model.isVertex(cells[i])
								&& !isAllowNegativeCoordinates())
						{
							geo.setX(Math.max(0, geo.getX()));
							geo.setY(Math.max(0, geo.getY()));
						}

						_model.setGeometry(cells[i], geo);

						if (isExtendParent(cells[i]))
						{
							extendParent(cells[i]);
						}
					}
				}

				if (isResetEdgesOnResize())
				{
					resetEdges(cells);
				}

				// RENAME BOUNDSARRAY TO BOUNDS
				fireEvent(new EventObj(Event.CELLS_RESIZED, "cells",
						cells, "bounds", bounds));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Resizes the parents recursively so that they contain the complete area
	 * of the resized child cell.
	 * 
	 * @param cell <Cell> that has been resized.
	 */
	public void extendParent(Object cell)
	{
		if (cell != null)
		{
			Object parent = _model.getParent(cell);
			Geometry p = _model.getGeometry(parent);

			if (parent != null && p != null && !isCellCollapsed(parent))
			{
				Geometry geo = _model.getGeometry(cell);

				if (geo != null
						&& (p.getWidth() < geo.getX() + geo.getWidth() || p
								.getHeight() < geo.getY() + geo.getHeight()))
				{
					p = (Geometry) p.clone();

					p.setWidth(Math.max(p.getWidth(),
							geo.getX() + geo.getWidth()));
					p.setHeight(Math.max(p.getHeight(),
							geo.getY() + geo.getHeight()));

					cellsResized(new Object[] { parent },
							new Rect[] { p });
				}
			}
		}
	}

	//
	// Cell moving
	//

	/**
	 * Moves the cells by the given amount. This is a shortcut method.
	 */
	public Object[] moveCells(Object[] cells, double dx, double dy)
	{
		return moveCells(cells, dx, dy, false);
	}

	/**
	 * Moves or clones the cells and moves the cells or clones by the given
	 * amount. This is a shortcut method.
	 */
	public Object[] moveCells(Object[] cells, double dx, double dy,
			boolean clone)
	{
		return moveCells(cells, dx, dy, clone, null, null);
	}

	/**
	 * Moves or clones the specified cells and moves the cells or clones by the
	 * given amount, adding them to the optional target cell. The location is
	 * the position of the mouse pointer as the mouse was released. The change
	 * is carried out using cellsMoved. This method fires Event.MOVE_CELLS
	 * while the transaction is in progress.
	 * 
	 * @param cells Array of cells to be moved, cloned or added to the target.
	 * @param dx Integer that specifies the x-coordinate of the vector.
	 * @param dy Integer that specifies the y-coordinate of the vector.
	 * @param clone Boolean indicating if the cells should be cloned.
	 * @param target Cell that represents the new parent of the cells.
	 * @param location Location where the mouse was released.
	 * @return Returns the cells that were moved.
	 */
	public Object[] moveCells(Object[] cells, double dx, double dy,
			boolean clone, Object target, Point location)
	{
		if (cells != null && (dx != 0 || dy != 0 || clone || target != null))
		{
			_model.beginUpdate();
			try
			{
				if (clone)
				{
					cells = cloneCells(cells, isCloneInvalidEdges());

					if (target == null)
					{
						target = getDefaultParent();
					}
				}

				// Need to disable allowNegativeCoordinates if target not null to
				// allow for temporary negative numbers until cellsAdded is called.
				boolean previous = isAllowNegativeCoordinates();
				
				if (target != null)
				{
					setAllowNegativeCoordinates(true);
				}
				
				cellsMoved(cells, dx, dy, !clone && isDisconnectOnMove()
						&& isAllowDanglingEdges(), target == null);
				
				setAllowNegativeCoordinates(previous);

				if (target != null)
				{
					Integer index = _model.getChildCount(target);
					cellsAdded(cells, target, index, null, null, true);
				}

				fireEvent(new EventObj(Event.MOVE_CELLS, "cells", cells,
						"dx", dx, "dy", dy, "clone", clone, "target", target,
						"location", location));
			}
			finally
			{
				_model.endUpdate();
			}
		}

		return cells;
	}

	/**
	 * Moves the specified cells by the given vector, disconnecting the cells
	 * using disconnectGraph if disconnect is true. This method fires
	 * Event.CELLS_MOVED while the transaction is in progress.
	 */
	public void cellsMoved(Object[] cells, double dx, double dy,
			boolean disconnect, boolean constrain)
	{
		if (cells != null && (dx != 0 || dy != 0))
		{
			_model.beginUpdate();
			try
			{
				if (disconnect)
				{
					disconnectGraph(cells);
				}

				for (int i = 0; i < cells.length; i++)
				{
					translateCell(cells[i], dx, dy);

					if (constrain)
					{
						constrainChild(cells[i]);
					}
				}

				if (isResetEdgesOnMove())
				{
					resetEdges(cells);
				}

				fireEvent(new EventObj(Event.CELLS_MOVED, "cells",
						cells, "dx", dx, "dy", dy, "disconnect", disconnect));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Translates the geometry of the given cell and stores the new,
	 * translated geometry in the model as an atomic change.
	 */
	public void translateCell(Object cell, double dx, double dy)
	{
		Geometry geo = _model.getGeometry(cell);

		if (geo != null)
		{
			geo = (Geometry) geo.clone();
			geo.translate(dx, dy);

			if (!geo.isRelative() && _model.isVertex(cell)
					&& !isAllowNegativeCoordinates())
			{
				geo.setX(Math.max(0, geo.getX()));
				geo.setY(Math.max(0, geo.getY()));
			}

			if (geo.isRelative() && !_model.isEdge(cell))
			{
				if (geo.getOffset() == null)
				{
					geo.setOffset(new Point2d(dx, dy));
				}
				else
				{
					Point2d offset = geo.getOffset();

					offset.setX(offset.getX() + dx);
					offset.setY(offset.getY() + dy);
				}
			}

			_model.setGeometry(cell, geo);
		}
	}

	/**
	 * Returns the Rect inside which a cell is to be kept.
	 */
	public Rect getCellContainmentArea(Object cell)
	{
		if (cell != null && !_model.isEdge(cell))
		{
			Object parent = _model.getParent(cell);

			if (parent == getDefaultParent() || parent == getCurrentRoot())
			{
				return getMaximumGraphBounds();
			}
			else if (parent != null && parent != getDefaultParent())
			{
				Geometry g = _model.getGeometry(parent);

				if (g != null)
				{
					double x = 0;
					double y = 0;
					double w = g.getWidth();
					double h = g.getHeight();

					if (isSwimlane(parent))
					{
						Rect size = getStartSize(parent);

						x = size.getWidth();
						w -= size.getWidth();
						y = size.getHeight();
						h -= size.getHeight();
					}

					return new Rect(x, y, w, h);
				}
			}
		}

		return null;
	}

	/**
	 * @return the maximumGraphBounds
	 */
	public Rect getMaximumGraphBounds()
	{
		return _maximumGraphBounds;
	}

	/**
	 * @param value the maximumGraphBounds to set
	 */
	public void setMaximumGraphBounds(Rect value)
	{
		Rect oldValue = _maximumGraphBounds;
		_maximumGraphBounds = value;

		_changeSupport.firePropertyChange("maximumGraphBounds", oldValue,
				_maximumGraphBounds);
	}

	/**
	 * Keeps the given cell inside the bounds returned by
	 * getCellContainmentArea for its parent, according to the rules defined by
	 * getOverlap and isConstrainChild. This modifies the cell's geometry
	 * in-place and does not clone it.
	 * 
	 * @param cell Cell which should be constrained.
	 */
	public void constrainChild(Object cell)
	{
		if (cell != null)
		{
			Geometry geo = _model.getGeometry(cell);
			Rect area = (isConstrainChild(cell)) ? getCellContainmentArea(cell)
					: getMaximumGraphBounds();

			if (geo != null && area != null)
			{
				// Keeps child within the content area of the parent
				if (!geo.isRelative()
						&& (geo.getX() < area.getX()
								|| geo.getY() < area.getY()
								|| area.getWidth() < geo.getX()
										+ geo.getWidth() || area.getHeight() < geo
								.getY() + geo.getHeight()))
				{
					double overlap = getOverlap(cell);

					if (area.getWidth() > 0)
					{
						geo.setX(Math.min(geo.getX(),
								area.getX() + area.getWidth() - (1 - overlap)
										* geo.getWidth()));
					}

					if (area.getHeight() > 0)
					{
						geo.setY(Math.min(geo.getY(),
								area.getY() + area.getHeight() - (1 - overlap)
										* geo.getHeight()));
					}

					geo.setX(Math.max(geo.getX(), area.getX() - geo.getWidth()
							* overlap));
					geo.setY(Math.max(geo.getY(), area.getY() - geo.getHeight()
							* overlap));
				}
			}
		}
	}

	/**
	 * Resets the control points of the edges that are connected to the given
	 * cells if not both ends of the edge are in the given cells array.
	 * 
	 * @param cells Array of mxCells for which the connected edges should be
	 * reset.
	 */
	public void resetEdges(Object[] cells)
	{
		if (cells != null)
		{
			// Prepares a hashtable for faster cell lookups
			HashSet<Object> set = new HashSet<Object>(Arrays.asList(cells));

			_model.beginUpdate();
			try
			{
				for (int i = 0; i < cells.length; i++)
				{
					Object[] edges = GraphModel.getEdges(_model, cells[i]);

					if (edges != null)
					{
						for (int j = 0; j < edges.length; j++)
						{
							CellState state = _view.getState(edges[j]);
							Object source = (state != null) ? state
									.getVisibleTerminal(true) : _view
									.getVisibleTerminal(edges[j], true);
							Object target = (state != null) ? state
									.getVisibleTerminal(false) : _view
									.getVisibleTerminal(edges[j], false);

							// Checks if one of the terminals is not in the given array
							if (!set.contains(source) || !set.contains(target))
							{
								resetEdge(edges[j]);
							}
						}
					}

					resetEdges(GraphModel.getChildren(_model, cells[i]));
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Resets the control points of the given edge.
	 */
	public Object resetEdge(Object edge)
	{
		Geometry geo = _model.getGeometry(edge);

		if (geo != null)
		{
			// Resets the control points
			List<Point2d> points = geo.getPoints();

			if (points != null && !points.isEmpty())
			{
				geo = (Geometry) geo.clone();
				geo.setPoints(null);
				_model.setGeometry(edge, geo);
			}
		}

		return edge;
	}

	//
	// Cell connecting and connection constraints
	//

	/**
	 * Returns an array of all constraints for the given terminal.
	 * 
	 * @param terminal Cell state that represents the terminal.
	 * @param source Specifies if the terminal is the source or target.
	 */
	public ConnectionConstraint[] getAllConnectionConstraints(
			CellState terminal, boolean source)
	{
		return null;
	}

	/**
	 * Returns an connection constraint that describes the given connection
	 * point. This result can then be passed to getConnectionPoint.
	 * 
	 * @param edge Cell state that represents the edge.
	 * @param terminal Cell state that represents the terminal.
	 * @param source Boolean indicating if the terminal is the source or target.
	 */
	public ConnectionConstraint getConnectionConstraint(CellState edge,
			CellState terminal, boolean source)
	{
		Point2d point = null;
		Object x = edge.getStyle()
				.get((source) ? Constants.STYLE_EXIT_X
						: Constants.STYLE_ENTRY_X);

		if (x != null)
		{
			Object y = edge.getStyle().get(
					(source) ? Constants.STYLE_EXIT_Y
							: Constants.STYLE_ENTRY_Y);

			if (y != null)
			{
				point = new Point2d(Double.parseDouble(x.toString()),
						Double.parseDouble(y.toString()));
			}
		}

		boolean perimeter = false;

		if (point != null)
		{
			perimeter = Utils.isTrue(edge._style,
					(source) ? Constants.STYLE_EXIT_PERIMETER
							: Constants.STYLE_ENTRY_PERIMETER, true);
		}

		return new ConnectionConstraint(point, perimeter);
	}

	/**
	 * Sets the connection constraint that describes the given connection point.
	 * If no constraint is given then nothing is changed. To remove an existing
	 * constraint from the given edge, use an empty constraint instead.
	 * 
	 * @param edge Cell that represents the edge.
	 * @param terminal Cell that represents the terminal.
	 * @param source Boolean indicating if the terminal is the source or target.
	 * @param constraint Optional connection constraint to be used for this connection.
	 */
	public void setConnectionConstraint(Object edge, Object terminal,
			boolean source, ConnectionConstraint constraint)
	{
		if (constraint != null)
		{
			_model.beginUpdate();
			try
			{
				Object[] cells = new Object[] { edge };

				// FIXME, constraint can't be null, we've checked that above
				if (constraint == null || constraint._point == null)
				{
					setCellStyles((source) ? Constants.STYLE_EXIT_X
							: Constants.STYLE_ENTRY_X, null, cells);
					setCellStyles((source) ? Constants.STYLE_EXIT_Y
							: Constants.STYLE_ENTRY_Y, null, cells);
					setCellStyles((source) ? Constants.STYLE_EXIT_PERIMETER
							: Constants.STYLE_ENTRY_PERIMETER, null, cells);
				}
				else if (constraint._point != null)
				{
					setCellStyles((source) ? Constants.STYLE_EXIT_X
							: Constants.STYLE_ENTRY_X,
							String.valueOf(constraint._point.getX()), cells);
					setCellStyles((source) ? Constants.STYLE_EXIT_Y
							: Constants.STYLE_ENTRY_Y,
							String.valueOf(constraint._point.getY()), cells);

					// Only writes 0 since 1 is default
					if (!constraint._perimeter)
					{
						setCellStyles(
								(source) ? Constants.STYLE_EXIT_PERIMETER
										: Constants.STYLE_ENTRY_PERIMETER,
								"0", cells);
					}
					else
					{
						setCellStyles(
								(source) ? Constants.STYLE_EXIT_PERIMETER
										: Constants.STYLE_ENTRY_PERIMETER,
								null, cells);
					}
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Sets the connection constraint that describes the given connection point.
	 * If no constraint is given then nothing is changed. To remove an existing
	 * constraint from the given edge, use an empty constraint instead.
	 * 
	 * @param vertex Cell state that represents the vertex.
	 * @param constraint Connection constraint that represents the connection point
	 * constraint as returned by getConnectionConstraint.
	 */
	public Point2d getConnectionPoint(CellState vertex,
			ConnectionConstraint constraint)
	{
		Point2d point = null;

		if (vertex != null && constraint._point != null)
		{
			point = new Point2d(vertex.getX() + constraint.getPoint().getX()
					* vertex.getWidth(), vertex.getY()
					+ constraint.getPoint().getY() * vertex.getHeight());
		}

		if (point != null && constraint._perimeter)
		{
			point = _view.getPerimeterPoint(vertex, point, false);
		}

		return point;
	}

	/**
	 * Connects the specified end of the given edge to the given terminal
	 * using cellConnected and fires Event.CONNECT_CELL while the transaction
	 * is in progress.
	 */
	public Object connectCell(Object edge, Object terminal, boolean source)
	{
		return connectCell(edge, terminal, source, null);
	}

	/**
	 * Connects the specified end of the given edge to the given terminal
	 * using cellConnected and fires Event.CONNECT_CELL while the transaction
	 * is in progress.
	 * 
	 * @param edge Edge whose terminal should be updated.
	 * @param terminal New terminal to be used.
	 * @param source Specifies if the new terminal is the source or target.
	 * @param constraint Optional constraint to be used for this connection.
	 * @return Returns the update edge.
	 */
	public Object connectCell(Object edge, Object terminal, boolean source,
			ConnectionConstraint constraint)
	{
		_model.beginUpdate();
		try
		{
			Object previous = _model.getTerminal(edge, source);
			cellConnected(edge, terminal, source, constraint);
			fireEvent(new EventObj(Event.CONNECT_CELL, "edge", edge,
					"terminal", terminal, "source", source, "previous",
					previous));
		}
		finally
		{
			_model.endUpdate();
		}

		return edge;
	}

	/**
	 * Sets the new terminal for the given edge and resets the edge points if
	 * isResetEdgesOnConnect returns true. This method fires
	 * <Event.CELL_CONNECTED> while the transaction is in progress.
	 * 
	 * @param edge Edge whose terminal should be updated.
	 * @param terminal New terminal to be used.
	 * @param source Specifies if the new terminal is the source or target.
	 * @param constraint Constraint to be used for this connection.
	 */
	public void cellConnected(Object edge, Object terminal, boolean source,
			ConnectionConstraint constraint)
	{
		if (edge != null)
		{
			_model.beginUpdate();
			try
			{
				Object previous = _model.getTerminal(edge, source);

				// Updates the constraint
				setConnectionConstraint(edge, terminal, source, constraint);
				
				// Checks if the new terminal is a port, uses the ID of the port in the
				// style and the parent of the port as the actual terminal of the edge.
				if (isPortsEnabled())
				{
					// Checks if the new terminal is a port
					String id = null;
	
					if (isPort(terminal) && terminal instanceof ICell)
					{
						id = ((ICell) terminal).getId();
						terminal = getTerminalForPort(terminal, source);
					}
	
					// Sets or resets all previous information for connecting to a child port
					String key = (source) ? Constants.STYLE_SOURCE_PORT
							: Constants.STYLE_TARGET_PORT;
					setCellStyles(key, id, new Object[] { edge });
				}
				
				_model.setTerminal(edge, terminal, source);

				if (isResetEdgesOnConnect())
				{
					resetEdge(edge);
				}

				fireEvent(new EventObj(Event.CELL_CONNECTED, "edge",
						edge, "terminal", terminal, "source", source,
						"previous", previous));
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	/**
	 * Disconnects the given edges from the terminals which are not in the
	 * given array.
	 * 
	 * @param cells Array of <mxCells> to be disconnected.
	 */
	public void disconnectGraph(Object[] cells)
	{
		if (cells != null)
		{
			_model.beginUpdate();
			try
			{
				double scale = _view.getScale();
				Point2d tr = _view.getTranslate();

				// Prepares a hashtable for faster cell lookups
				Set<Object> hash = new HashSet<Object>();

				for (int i = 0; i < cells.length; i++)
				{
					hash.add(cells[i]);
				}

				for (int i = 0; i < cells.length; i++)
				{
					if (_model.isEdge(cells[i]))
					{
						Geometry geo = _model.getGeometry(cells[i]);

						if (geo != null)
						{
							CellState state = _view.getState(cells[i]);
							CellState pstate = _view.getState(_model
									.getParent(cells[i]));

							if (state != null && pstate != null)
							{
								geo = (Geometry) geo.clone();

								double dx = -pstate.getOrigin().getX();
								double dy = -pstate.getOrigin().getY();

								Object src = _model.getTerminal(cells[i], true);

								if (src != null
										&& isCellDisconnectable(cells[i], src,
												true))
								{
									while (src != null && !hash.contains(src))
									{
										src = _model.getParent(src);
									}

									if (src == null)
									{
										Point2d pt = state.getAbsolutePoint(0);
										geo.setTerminalPoint(
												new Point2d(pt.getX() / scale
														- tr.getX() + dx, pt
														.getY()
														/ scale
														- tr.getY() + dy), true);
										_model.setTerminal(cells[i], null, true);
									}
								}

								Object trg = _model.getTerminal(cells[i], false);

								if (trg != null
										&& isCellDisconnectable(cells[i], trg,
												false))
								{
									while (trg != null && !hash.contains(trg))
									{
										trg = _model.getParent(trg);
									}

									if (trg == null)
									{
										int n = state.getAbsolutePointCount() - 1;
										Point2d pt = state.getAbsolutePoint(n);
										geo.setTerminalPoint(
												new Point2d(pt.getX() / scale
														- tr.getX() + dx, pt
														.getY()
														/ scale
														- tr.getY() + dy),
												false);
										_model.setTerminal(cells[i], null, false);
									}
								}
							}

							_model.setGeometry(cells[i], geo);
						}
					}
				}
			}
			finally
			{
				_model.endUpdate();
			}
		}
	}

	//
	// Drilldown
	//

	/**
	 * Returns the current root of the displayed cell hierarchy. This is a
	 * shortcut to <GraphView.currentRoot> in <view>.
	 * 
	 * @return Returns the current root in the view.
	 */
	public Object getCurrentRoot()
	{
		return _view.getCurrentRoot();
	}

	/**
	 * Returns the translation to be used if the given cell is the root cell as
	 * an <Point2d>. This implementation returns null.
	 * 
	 * @param cell Cell that represents the root of the view.
	 * @return Returns the translation of the graph for the given root cell.
	 */
	public Point2d getTranslateForRoot(Object cell)
	{
		return null;
	}

	/**
	 * Returns true if the given cell is a "port", that is, when connecting to
	 * it, the cell returned by getTerminalForPort should be used as the
	 * terminal and the port should be referenced by the ID in either the
	 * Constants.STYLE_SOURCE_PORT or the or the
	 * Constants.STYLE_TARGET_PORT. Note that a port should not be movable.
	 * This implementation always returns false.
	 * 
	 * A typical implementation of this method looks as follows:
	 * 
	 * <code>
	 * public boolean isPort(Object cell)
	 * {
	 *   Geometry geo = getCellGeometry(cell);
	 *   
	 *   return (geo != null) ? geo.isRelative() : false;
	 * }
	 * </code>
	 * 
	 * @param cell Cell that represents the port.
	 * @return Returns true if the cell is a port.
	 */
	public boolean isPort(Object cell)
	{
		return false;
	}

	/**
	 * Returns the terminal to be used for a given port. This implementation
	 * always returns the parent cell.
	 * 
	 * @param cell Cell that represents the port.
	 * @param source If the cell is the source or target port.
	 * @return Returns the terminal to be used for the given port.
	 */
	public Object getTerminalForPort(Object cell, boolean source)
	{
		return getModel().getParent(cell);
	}

	/**
	 * Returns the offset to be used for the cells inside the given cell. The
	 * root and layer cells may be identified using GraphModel.isRoot and
	 * GraphModel.isLayer. This implementation returns null.
	 *
	 * @param cell Cell whose offset should be returned.
	 * @return Returns the child offset for the given cell.
	 */
	public Point2d getChildOffsetForCell(Object cell)
	{
		return null;
	}

	/**
	 * 
	 */
	public void enterGroup()
	{
		enterGroup(null);
	}

	/**
	 * Uses the given cell as the root of the displayed cell hierarchy. If no
	 * cell is specified then the selection cell is used. The cell is only used
	 * if <isValidRoot> returns true.
	 * 
	 * @param cell
	 */
	public void enterGroup(Object cell)
	{
		if (cell == null)
		{
			cell = getSelectionCell();
		}

		if (cell != null && isValidRoot(cell))
		{
			_view.setCurrentRoot(cell);
			clearSelection();
		}
	}

	/**
	 * Changes the current root to the next valid root in the displayed cell
	 * hierarchy.
	 */
	public void exitGroup()
	{
		Object root = _model.getRoot();
		Object current = getCurrentRoot();

		if (current != null)
		{
			Object next = _model.getParent(current);

			// Finds the next valid root in the hierarchy
			while (next != root && !isValidRoot(next)
					&& _model.getParent(next) != root)
			{
				next = _model.getParent(next);
			}

			// Clears the current root if the new root is
			// the model's root or one of the layers.
			if (next == root || _model.getParent(next) == root)
			{
				_view.setCurrentRoot(null);
			}
			else
			{
				_view.setCurrentRoot(next);
			}

			CellState state = _view.getState(current);

			// Selects the previous root in the graph
			if (state != null)
			{
				setSelectionCell(current);
			}
		}
	}

	/**
	 * Uses the root of the model as the root of the displayed cell hierarchy
	 * and selects the previous root.
	 */
	public void home()
	{
		Object current = getCurrentRoot();

		if (current != null)
		{
			_view.setCurrentRoot(null);
			CellState state = _view.getState(current);

			if (state != null)
			{
				setSelectionCell(current);
			}
		}
	}

	/**
	 * Returns true if the given cell is a valid root for the cell display
	 * hierarchy. This implementation returns true for all non-null values.
	 * 
	 * @param cell <Cell> which should be checked as a possible root.
	 * @return Returns true if the given cell is a valid root.
	 */
	public boolean isValidRoot(Object cell)
	{
		return (cell != null);
	}

	//
	// Graph display
	//

	/**
	 * Returns the bounds of the visible graph.
	 */
	public Rect getGraphBounds()
	{
		return _view.getGraphBounds();
	}

	/**
	 * Returns the bounds of the given cell.
	 */
	public Rect getCellBounds(Object cell)
	{
		return getCellBounds(cell, false);
	}

	/**
	 * Returns the bounds of the given cell including all connected edges
	 * if includeEdge is true.
	 */
	public Rect getCellBounds(Object cell, boolean includeEdges)
	{
		return getCellBounds(cell, includeEdges, false);
	}

	/**
	 * Returns the bounds of the given cell including all connected edges
	 * if includeEdge is true.
	 */
	public Rect getCellBounds(Object cell, boolean includeEdges,
			boolean includeDescendants)
	{
		return getCellBounds(cell, includeEdges, includeDescendants, false);
	}

	/**
	 * Returns the bounding box for the geometries of the vertices in the
	 * given array of cells.
	 */
	public Rect getBoundingBoxFromGeometry(Object[] cells)
	{
		Rect result = null;

		if (cells != null)
		{
			for (int i = 0; i < cells.length; i++)
			{
				if (getModel().isVertex(cells[i]))
				{
					Geometry geo = getCellGeometry(cells[i]);

					if (result == null)
					{
						result = new Rect(geo);
					}
					else
					{
						result.add(geo);
					}
				}
			}
		}

		return result;
	}

	/**
	 * Returns the bounds of the given cell.
	 */
	public Rect getBoundingBox(Object cell)
	{
		return getBoundingBox(cell, false);
	}

	/**
	 * Returns the bounding box of the given cell including all connected edges
	 * if includeEdge is true.
	 */
	public Rect getBoundingBox(Object cell, boolean includeEdges)
	{
		return getBoundingBox(cell, includeEdges, false);
	}

	/**
	 * Returns the bounding box of the given cell including all connected edges
	 * if includeEdge is true.
	 */
	public Rect getBoundingBox(Object cell, boolean includeEdges,
			boolean includeDescendants)
	{
		return getCellBounds(cell, includeEdges, includeDescendants, true);
	}

	/**
	 * Returns the bounding box of the given cells and their descendants.
	 */
	public Rect getPaintBounds(Object[] cells)
	{
		return getBoundsForCells(cells, false, true, true);
	}

	/**
	 * Returns the bounds for the given cells.
	 */
	public Rect getBoundsForCells(Object[] cells, boolean includeEdges,
			boolean includeDescendants, boolean boundingBox)
	{
		Rect result = null;

		if (cells != null && cells.length > 0)
		{
			for (int i = 0; i < cells.length; i++)
			{
				Rect tmp = getCellBounds(cells[i], includeEdges,
						includeDescendants, boundingBox);

				if (tmp != null)
				{
					if (result == null)
					{
						result = new Rect(tmp);
					}
					else
					{
						result.add(tmp);
					}
				}
			}
		}

		return result;
	}

	/**
	 * Returns the bounds of the given cell including all connected edges
	 * if includeEdge is true.
	 */
	public Rect getCellBounds(Object cell, boolean includeEdges,
			boolean includeDescendants, boolean boundingBox)
	{
		Object[] cells;

		// Recursively includes connected edges
		if (includeEdges)
		{
			Set<Object> allCells = new HashSet<Object>();
			allCells.add(cell);

			Set<Object> edges = new HashSet<Object>(
					Arrays.asList(getEdges(cell)));

			while (!edges.isEmpty() && !allCells.containsAll(edges))
			{
				allCells.addAll(edges);

				Set<Object> tmp = new HashSet<Object>();
				Iterator<Object> it = edges.iterator();

				while (it.hasNext())
				{
					Object edge = it.next();
					tmp.addAll(Arrays.asList(getEdges(edge)));
				}

				edges = tmp;
			}

			cells = allCells.toArray();
		}
		else
		{
			cells = new Object[] { cell };
		}

		Rect result = _view.getBounds(cells, boundingBox);

		// Recursively includes the bounds of the children
		if (includeDescendants)
		{
			for (int i = 0; i < cells.length; i++)
			{
				int childCount = _model.getChildCount(cells[i]);
	
				for (int j = 0; j < childCount; j++)
				{
					Rect tmp = getCellBounds(_model.getChildAt(cells[i], j),
							includeEdges, true, boundingBox);
	
					if (result != null)
					{
						result.add(tmp);
					}
					else
					{
						result = tmp;
					}
				}
			}
		}

		return result;
	}

	/**
	 * Clears all cell states or the states for the hierarchy starting at the
	 * given cell and validates the graph.
	 */
	public void refresh()
	{
		_view.reload();
		repaint();
	}

	/**
	 * Fires a repaint event.
	 */
	public void repaint()
	{
		repaint(null);
	}

	/**
	 * Fires a repaint event. The optional region is the rectangle that needs
	 * to be repainted.
	 */
	public void repaint(Rect region)
	{
		fireEvent(new EventObj(Event.REPAINT, "region", region));
	}

	/**
	 * Snaps the given numeric value to the grid if <gridEnabled> is true.
	 *
	 * @param value Numeric value to be snapped to the grid.
	 * @return Returns the value aligned to the grid.
	 */
	public double snap(double value)
	{
		if (_gridEnabled)
		{
			value = Math.round(value / _gridSize) * _gridSize;
		}

		return value;
	}

	/**
	 * Returns the geometry for the given cell.
	 * 
	 * @param cell Cell whose geometry should be returned.
	 * @return Returns the geometry of the cell.
	 */
	public Geometry getCellGeometry(Object cell)
	{
		return _model.getGeometry(cell);
	}

	/**
	 * Returns true if the given cell is visible in this graph. This
	 * implementation uses <GraphModel.isVisible>. Subclassers can override
	 * this to implement specific visibility for cells in only one graph, that
	 * is, without affecting the visible state of the cell.
	 * 
	 * When using dynamic filter expressions for cell visibility, then the
	 * graph should be revalidated after the filter expression has changed.
	 * 
	 * @param cell Cell whose visible state should be returned.
	 * @return Returns the visible state of the cell.
	 */
	public boolean isCellVisible(Object cell)
	{
		return _model.isVisible(cell);
	}

	/**
	 * Returns true if the given cell is collapsed in this graph. This
	 * implementation uses <GraphModel.isCollapsed>. Subclassers can override
	 * this to implement specific collapsed states for cells in only one graph,
	 * that is, without affecting the collapsed state of the cell.
	 * 
	 * When using dynamic filter expressions for the collapsed state, then the
	 * graph should be revalidated after the filter expression has changed.
	 * 
	 * @param cell Cell whose collapsed state should be returned.
	 * @return Returns the collapsed state of the cell.
	 */
	public boolean isCellCollapsed(Object cell)
	{
		return _model.isCollapsed(cell);
	}

	/**
	 * Returns true if the given cell is connectable in this graph. This
	 * implementation uses <GraphModel.isConnectable>. Subclassers can override
	 * this to implement specific connectable states for cells in only one graph,
	 * that is, without affecting the connectable state of the cell in the model.
	 * 
	 * @param cell Cell whose connectable state should be returned.
	 * @return Returns the connectable state of the cell.
	 */
	public boolean isCellConnectable(Object cell)
	{
		return _model.isConnectable(cell);
	}

	/**
	 * Returns true if perimeter points should be computed such that the
	 * resulting edge has only horizontal or vertical segments.
	 * 
	 * @param edge Cell state that represents the edge.
	 */
	public boolean isOrthogonal(CellState edge)
	{
		if (edge.getStyle().containsKey(Constants.STYLE_ORTHOGONAL))
		{
			return Utils
					.isTrue(edge.getStyle(), Constants.STYLE_ORTHOGONAL);
		}

		EdgeStyle.EdgeStyleFunction tmp = _view.getEdgeStyle(edge, null,
				null, null);

		return tmp == EdgeStyle.SegmentConnector
				|| tmp == EdgeStyle.ElbowConnector
				|| tmp == EdgeStyle.SideToSide
				|| tmp == EdgeStyle.TopToBottom
				|| tmp == EdgeStyle.EntityRelation
				|| tmp == EdgeStyle.OrthConnector;
	}

	/**
	 * Returns true if the given cell state is a loop.
	 * 
	 * @param state <CellState> that represents a potential loop.
	 * @return Returns true if the given cell is a loop.
	 */
	public boolean isLoop(CellState state)
	{
		Object src = state.getVisibleTerminalState(true);
		Object trg = state.getVisibleTerminalState(false);

		return (src != null && src == trg);
	}

	//
	// Cell validation
	//

	/**
	 * 
	 */
	public void setMultiplicities(Multiplicity[] value)
	{
		Multiplicity[] oldValue = _multiplicities;
		_multiplicities = value;

		_changeSupport.firePropertyChange("multiplicities", oldValue,
				_multiplicities);
	}

	/**
	 * 
	 */
	public Multiplicity[] getMultiplicities()
	{
		return _multiplicities;
	}

	/**
	 * Checks if the return value of getEdgeValidationError for the given
	 * arguments is null.
	 * 
	 * @param edge Cell that represents the edge to validate.
	 * @param source Cell that represents the source terminal.
	 * @param target Cell that represents the target terminal.
	 */
	public boolean isEdgeValid(Object edge, Object source, Object target)
	{
		return getEdgeValidationError(edge, source, target) == null;
	}

	/**
	 * Returns the validation error message to be displayed when inserting or
	 * changing an edges' connectivity. A return value of null means the edge
	 * is valid, a return value of '' means it's not valid, but do not display
	 * an error message. Any other (non-empty) string returned from this method
	 * is displayed as an error message when trying to connect an edge to a
	 * source and target. This implementation uses the multiplicities, as
	 * well as multigraph and allowDanglingEdges to generate validation
	 * errors.
	 * 
	 * @param edge Cell that represents the edge to validate.
	 * @param source Cell that represents the source terminal.
	 * @param target Cell that represents the target terminal.
	 */
	public String getEdgeValidationError(Object edge, Object source,
			Object target)
	{
		if (edge != null && !isAllowDanglingEdges()
				&& (source == null || target == null))
		{
			return "";
		}

		if (edge != null && _model.getTerminal(edge, true) == null
				&& _model.getTerminal(edge, false) == null)
		{
			return null;
		}

		// Checks if we're dealing with a loop
		if (!isAllowLoops() && source == target && source != null)
		{
			return "";
		}

		// Checks if the connection is generally allowed
		if (!isValidConnection(source, target))
		{
			return "";
		}

		if (source != null && target != null)
		{
			StringBuffer error = new StringBuffer();

			// Checks if the cells are already connected
			// and adds an error message if required			
			if (!_multigraph)
			{
				Object[] tmp = GraphModel.getEdgesBetween(_model, source,
						target, true);

				// Checks if the source and target are not connected by another edge
				if (tmp.length > 1 || (tmp.length == 1 && tmp[0] != edge))
				{
					error.append(Resources.get("alreadyConnected",
							"Already Connected") + "\n");
				}
			}

			// Gets the number of outgoing edges from the source
			// and the number of incoming edges from the target
			// without counting the edge being currently changed.
			int sourceOut = GraphModel.getDirectedEdgeCount(_model, source,
					true, edge);
			int targetIn = GraphModel.getDirectedEdgeCount(_model, target,
					false, edge);

			// Checks the change against each multiplicity rule
			if (_multiplicities != null)
			{
				for (int i = 0; i < _multiplicities.length; i++)
				{
					String err = _multiplicities[i].check(this, edge, source,
							target, sourceOut, targetIn);

					if (err != null)
					{
						error.append(err);
					}
				}
			}

			// Validates the source and target terminals independently
			String err = validateEdge(edge, source, target);

			if (err != null)
			{
				error.append(err);
			}

			return (error.length() > 0) ? error.toString() : null;
		}

		return (_allowDanglingEdges) ? null : "";
	}

	/**
	 * Hook method for subclassers to return an error message for the given
	 * edge and terminals. This implementation returns null.
	 * 
	 * @param edge Cell that represents the edge to validate.
	 * @param source Cell that represents the source terminal.
	 * @param target Cell that represents the target terminal.
	 */
	public String validateEdge(Object edge, Object source, Object target)
	{
		return null;
	}

	/**
	 * Checks all multiplicities that cannot be enforced while the graph is
	 * being modified, namely, all multiplicities that require a minimum of
	 * 1 edge.
	 * 
	 * @param cell Cell for which the multiplicities should be checked.
	 */
	public String getCellValidationError(Object cell)
	{
		int outCount = GraphModel.getDirectedEdgeCount(_model, cell, true);
		int inCount = GraphModel.getDirectedEdgeCount(_model, cell, false);
		StringBuffer error = new StringBuffer();
		Object value = _model.getValue(cell);

		if (_multiplicities != null)
		{
			for (int i = 0; i < _multiplicities.length; i++)
			{
				Multiplicity rule = _multiplicities[i];
				int max = rule.getMaxValue();

				if (rule._source
						&& Utils.isNode(value, rule._type, rule._attr,
								rule._value)
						&& ((max == 0 && outCount > 0)
								|| (rule._min == 1 && outCount == 0) || (max == 1 && outCount > 1)))
				{
					error.append(rule._countError + '\n');
				}
				else if (!rule._source
						&& Utils.isNode(value, rule._type, rule._attr,
								rule._value)
						&& ((max == 0 && inCount > 0)
								|| (rule._min == 1 && inCount == 0) || (max == 1 && inCount > 1)))
				{
					error.append(rule._countError + '\n');
				}
			}
		}

		return (error.length() > 0) ? error.toString() : null;
	}

	/**
	 * Hook method for subclassers to return an error message for the given
	 * cell and validation context. This implementation returns null.
	 * 
	 * @param cell Cell that represents the cell to validate.
	 * @param context Hashtable that represents the global validation state.
	 */
	public String validateCell(Object cell, Hashtable<Object, Object> context)
	{
		return null;
	}

	//
	// Graph appearance
	//

	/**
	 * @return the labelsVisible
	 */
	public boolean isLabelsVisible()
	{
		return _labelsVisible;
	}

	/**
	 * @param value the labelsVisible to set
	 */
	public void setLabelsVisible(boolean value)
	{
		boolean oldValue = _labelsVisible;
		_labelsVisible = value;

		_changeSupport.firePropertyChange("labelsVisible", oldValue,
				_labelsVisible);
	}

	/**
	 * @param value the htmlLabels to set
	 */
	public void setHtmlLabels(boolean value)
	{
		boolean oldValue = _htmlLabels;
		_htmlLabels = value;

		_changeSupport.firePropertyChange("htmlLabels", oldValue, _htmlLabels);
	}

	/**
	 * 
	 */
	public boolean isHtmlLabels()
	{
		return _htmlLabels;
	}

	/**
	 * Returns the textual representation for the given cell.
	 * 
	 * @param cell Cell to be converted to a string.
	 * @return Returns the textual representation of the cell.
	 */
	public String convertValueToString(Object cell)
	{
		Object result = _model.getValue(cell);

		return (result != null) ? result.toString() : "";
	}

	/**
	 * Returns a string or DOM node that represents the label for the given
	 * cell. This implementation uses <convertValueToString> if <labelsVisible>
	 * is true. Otherwise it returns an empty string.
	 * 
	 * @param cell <Cell> whose label should be returned.
	 * @return Returns the label for the given cell.
	 */
	public String getLabel(Object cell)
	{
		String result = "";

		if (cell != null)
		{
			CellState state = _view.getState(cell);
			Map<String, Object> style = (state != null) ? state.getStyle()
					: getCellStyle(cell);

			if (_labelsVisible
					&& !Utils.isTrue(style, Constants.STYLE_NOLABEL, false))
			{
				result = convertValueToString(cell);
			}
		}

		return result;
	}

	/**
	 * Sets the new label for a cell. If autoSize is true then
	 * <cellSizeUpdated> will be called.
	 * 
	 * @param cell Cell whose label should be changed.
	 * @param value New label to be assigned.
	 * @param autoSize Specifies if cellSizeUpdated should be called.
	 */
	public void cellLabelChanged(Object cell, Object value, boolean autoSize)
	{
		_model.beginUpdate();
		try
		{
			getModel().setValue(cell, value);

			if (autoSize)
			{
				cellSizeUpdated(cell, false);
			}
		}
		finally
		{
			_model.endUpdate();
		}
	}

	/**
	 * Returns true if the label must be rendered as HTML markup. The default
	 * implementation returns <htmlLabels>.
	 * 
	 * @param cell <Cell> whose label should be displayed as HTML markup.
	 * @return Returns true if the given cell label is HTML markup.
	 */
	public boolean isHtmlLabel(Object cell)
	{
		return isHtmlLabels();
	}

	/**
	 * Returns the tooltip to be used for the given cell.
	 */
	public String getToolTipForCell(Object cell)
	{
		return convertValueToString(cell);
	}

	/**
	 * Returns the start size of the given swimlane, that is, the width or
	 * height of the part that contains the title, depending on the
	 * horizontal style. The return value is an <Rect> with either
	 * width or height set as appropriate.
	 * 
	 * @param swimlane <Cell> whose start size should be returned.
	 * @return Returns the startsize for the given swimlane.
	 */
	public Rect getStartSize(Object swimlane)
	{
		Rect result = new Rect();
		CellState state = _view.getState(swimlane);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(swimlane);

		if (style != null)
		{
			double size = Utils.getDouble(style, Constants.STYLE_STARTSIZE,
					Constants.DEFAULT_STARTSIZE);

			if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true))
			{
				result.setHeight(size);
			}
			else
			{
				result.setWidth(size);
			}
		}

		return result;
	}

	/**
	 * Returns the image URL for the given cell state. This implementation
	 * returns the value stored under <Constants.STYLE_IMAGE> in the cell
	 * style.
	 * 
	 * @param state
	 * @return Returns the image associated with the given cell state.
	 */
	public String getImage(CellState state)
	{
		return (state != null && state.getStyle() != null) ? Utils.getString(
				state.getStyle(), Constants.STYLE_IMAGE) : null;
	}

	/**
	 * Returns the value of <border>.
	 * 
	 * @return Returns the border.
	 */
	public int getBorder()
	{
		return _border;
	}

	/**
	 * Sets the value of <border>.
	 * 
	 * @param value Positive integer that represents the border to be used.
	 */
	public void setBorder(int value)
	{
		_border = value;
	}

	/**
	 * Returns the default edge style used for loops.
	 * 
	 * @return Returns the default loop style.
	 */
	public EdgeStyle.EdgeStyleFunction getDefaultLoopStyle()
	{
		return _defaultLoopStyle;
	}

	/**
	 * Sets the default style used for loops.
	 * 
	 * @param value Default style to be used for loops.
	 */
	public void setDefaultLoopStyle(EdgeStyle.EdgeStyleFunction value)
	{
		EdgeStyle.EdgeStyleFunction oldValue = _defaultLoopStyle;
		_defaultLoopStyle = value;

		_changeSupport.firePropertyChange("defaultLoopStyle", oldValue,
				_defaultLoopStyle);
	}

	/**
	 * Returns true if the given cell is a swimlane. This implementation always
	 * returns false.
	 * 
	 * @param cell Cell that should be checked. 
	 * @return Returns true if the cell is a swimlane.
	 */
	public boolean isSwimlane(Object cell)
	{
		if (cell != null)
		{
			if (_model.getParent(cell) != _model.getRoot())
			{
				CellState state = _view.getState(cell);
				Map<String, Object> style = (state != null) ? state.getStyle()
						: getCellStyle(cell);

				if (style != null && !_model.isEdge(cell))
				{
					return Utils
							.getString(style, Constants.STYLE_SHAPE, "")
							.equals(Constants.SHAPE_SWIMLANE);
				}
			}
		}

		return false;
	}

	//
	// Cells and labels control options
	//

	/**
	 * Returns true if the given cell may not be moved, sized, bended,
	 * disconnected, edited or selected. This implementation returns true for
	 * all vertices with a relative geometry if cellsLocked is false.
	 * 
	 * @param cell Cell whose locked state should be returned.
	 * @return Returns true if the given cell is locked.
	 */
	public boolean isCellLocked(Object cell)
	{
		Geometry geometry = _model.getGeometry(cell);

		return isCellsLocked()
				|| (geometry != null && _model.isVertex(cell) && geometry
						.isRelative());
	}

	/**
	 * Returns cellsLocked, the default return value for isCellLocked.
	 */
	public boolean isCellsLocked()
	{
		return _cellsLocked;
	}

	/**
	 * Sets cellsLocked, the default return value for isCellLocked and fires a
	 * property change event for cellsLocked.
	 */
	public void setCellsLocked(boolean value)
	{
		boolean oldValue = _cellsLocked;
		_cellsLocked = value;

		_changeSupport.firePropertyChange("cellsLocked", oldValue, _cellsLocked);
	}

	/**
	 * Returns true if the given cell is movable. This implementation returns editable.
	 * 
	 * @param cell Cell whose editable state should be returned.
	 * @return Returns true if the cell is editable.
	 */
	public boolean isCellEditable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsEditable() && !isCellLocked(cell)
				&& Utils.isTrue(style, Constants.STYLE_EDITABLE, true);
	}

	/**
	 * Returns true if editing is allowed in this graph.
	 * 
	 * @return Returns true if the graph is editable.
	 */
	public boolean isCellsEditable()
	{
		return _cellsEditable;
	}

	/**
	 * Sets if the graph is editable.
	 */
	public void setCellsEditable(boolean value)
	{
		boolean oldValue = _cellsEditable;
		_cellsEditable = value;

		_changeSupport.firePropertyChange("cellsEditable", oldValue,
				_cellsEditable);
	}

	/**
	 * Returns true if the given cell is resizable. This implementation returns
	 * cellsSizable for all cells.
	 * 
	 * @param cell Cell whose resizable state should be returned.
	 * @return Returns true if the cell is sizable.
	 */
	public boolean isCellResizable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsResizable() && !isCellLocked(cell)
				&& Utils.isTrue(style, Constants.STYLE_RESIZABLE, true);
	}

	/**
	 * Returns true if the given cell is resizable. This implementation return sizable.
	 */
	public boolean isCellsResizable()
	{
		return _cellsResizable;
	}

	/**
	 * Sets if the graph is resizable.
	 */
	public void setCellsResizable(boolean value)
	{
		boolean oldValue = _cellsResizable;
		_cellsResizable = value;

		_changeSupport.firePropertyChange("cellsResizable", oldValue,
				_cellsResizable);
	}

	/**
	 * Returns the cells which are movable in the given array of cells.
	 */
	public Object[] getMovableCells(Object[] cells)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return isCellMovable(cell);
			}
		});
	}

	/**
	 * Returns true if the given cell is movable. This implementation
	 * returns movable.
	 * 
	 * @param cell Cell whose movable state should be returned.
	 * @return Returns true if the cell is movable.
	 */
	public boolean isCellMovable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsMovable() && !isCellLocked(cell)
				&& Utils.isTrue(style, Constants.STYLE_MOVABLE, true);
	}

	/**
	 * Returns cellsMovable.
	 */
	public boolean isCellsMovable()
	{
		return _cellsMovable;
	}

	/**
	 * Sets cellsMovable.
	 */
	public void setCellsMovable(boolean value)
	{
		boolean oldValue = _cellsMovable;
		_cellsMovable = value;

		_changeSupport
				.firePropertyChange("cellsMovable", oldValue, _cellsMovable);
	}

	/**
	 * Function: isTerminalPointMovable
	 *
	 * Returns true if the given terminal point is movable. This is independent
	 * from isCellConnectable and isCellDisconnectable and controls if terminal
	 * points can be moved in the graph if the edge is not connected. Note that
	 * it is required for this to return true to connect unconnected edges.
	 * This implementation returns true.
	 * 
	 * @param cell Cell whose terminal point should be moved.
	 * @param source Boolean indicating if the source or target terminal should be moved.
	 */
	public boolean isTerminalPointMovable(Object cell, boolean source)
	{
		return true;
	}

	/**
	 * Returns true if the given cell is bendable. This implementation returns
	 * bendable. This is used in ElbowEdgeHandler to determine if the middle
	 * handle should be shown.
	 * 
	 * @param cell Cell whose bendable state should be returned.
	 * @return Returns true if the cell is bendable.
	 */
	public boolean isCellBendable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsBendable() && !isCellLocked(cell)
				&& Utils.isTrue(style, Constants.STYLE_BENDABLE, true);
	}

	/**
	 * Returns cellsBendable.
	 */
	public boolean isCellsBendable()
	{
		return _cellsBendable;
	}

	/**
	 * Sets cellsBendable.
	 */
	public void setCellsBendable(boolean value)
	{
		boolean oldValue = _cellsBendable;
		_cellsBendable = value;

		_changeSupport.firePropertyChange("cellsBendable", oldValue,
				_cellsBendable);
	}

	/**
	 * Returns true if the given cell is selectable. This implementation returns
	 * <selectable>.
	 * 
	 * @param cell <Cell> whose selectable state should be returned.
	 * @return Returns true if the given cell is selectable.
	 */
	public boolean isCellSelectable(Object cell)
	{
		return isCellsSelectable();
	}

	/**
	 * Returns cellsSelectable.
	 */
	public boolean isCellsSelectable()
	{
		return _cellsSelectable;
	}

	/**
	 * Sets cellsSelectable.
	 */
	public void setCellsSelectable(boolean value)
	{
		boolean oldValue = _cellsSelectable;
		_cellsSelectable = value;

		_changeSupport.firePropertyChange("cellsSelectable", oldValue,
				_cellsSelectable);
	}

	/**
	 * Returns the cells which are movable in the given array of cells.
	 */
	public Object[] getDeletableCells(Object[] cells)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return isCellDeletable(cell);
			}
		});
	}

	/**
	 * Returns true if the given cell is movable. This implementation always
	 * returns true.
	 * 
	 * @param cell Cell whose movable state should be returned.
	 * @return Returns true if the cell is movable.
	 */
	public boolean isCellDeletable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsDeletable()
				&& Utils.isTrue(style, Constants.STYLE_DELETABLE, true);
	}

	/**
	 * Returns cellsDeletable.
	 */
	public boolean isCellsDeletable()
	{
		return _cellsDeletable;
	}

	/**
	 * Sets cellsDeletable.
	 */
	public void setCellsDeletable(boolean value)
	{
		boolean oldValue = _cellsDeletable;
		_cellsDeletable = value;

		_changeSupport.firePropertyChange("cellsDeletable", oldValue,
				_cellsDeletable);
	}

	/**
	 * Returns the cells which are movable in the given array of cells.
	 */
	public Object[] getCloneableCells(Object[] cells)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return isCellCloneable(cell);
			}
		});
	}

	/**
	 * Returns the constant true. This does not use the cloneable field to
	 * return a value for a given cell, it is simply a hook for subclassers
	 * to disallow cloning of individual cells.
	 */
	public boolean isCellCloneable(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isCellsCloneable()
				&& Utils.isTrue(style, Constants.STYLE_CLONEABLE, true);
	}

	/**
	 * Returns cellsCloneable.
	 */
	public boolean isCellsCloneable()
	{
		return _cellsCloneable;
	}

	/**
	 * Specifies if the graph should allow cloning of cells by holding down the
	 * control key while cells are being moved. This implementation updates
	 * cellsCloneable.
	 *
	 * @param value Boolean indicating if the graph should be cloneable.
	 */
	public void setCellsCloneable(boolean value)
	{
		boolean oldValue = _cellsCloneable;
		_cellsCloneable = value;

		_changeSupport.firePropertyChange("cellsCloneable", oldValue,
				_cellsCloneable);
	}

	/**
	 * Returns true if the given cell is disconnectable from the source or
	 * target terminal. This returns <disconnectable> for all given cells if
	 * <isLocked> does not return true for the given cell.
	 * 
	 * @param cell <Cell> whose disconnectable state should be returned.
	 * @param terminal <Cell> that represents the source or target terminal.
	 * @param source Boolean indicating if the source or target terminal is to be
	 * disconnected.
	 * @return Returns true if the given edge can be disconnected from the given
	 * terminal.
	 */
	public boolean isCellDisconnectable(Object cell, Object terminal,
			boolean source)
	{
		return isCellsDisconnectable() && !isCellLocked(cell);
	}

	/**
	 * Returns cellsDisconnectable.
	 */
	public boolean isCellsDisconnectable()
	{
		return _cellsDisconnectable;
	}

	/**
	 * Sets cellsDisconnectable.
	 * 
	 * @param value Boolean indicating if the graph should allow disconnecting of
	 * edges.
	 */
	public void setCellsDisconnectable(boolean value)
	{
		boolean oldValue = _cellsDisconnectable;
		_cellsDisconnectable = value;

		_changeSupport.firePropertyChange("cellsDisconnectable", oldValue,
				_cellsDisconnectable);
	}

	/**
	 * Returns true if the overflow portion of labels should be hidden. If this
	 * returns true then vertex labels will be clipped to the size of the vertices.
	 * This implementation returns true if <Constants.STYLE_OVERFLOW> in the
	 * style of the given cell is "hidden".
	 * 
	 * @param cell Cell whose label should be clipped.
	 * @return Returns true if the cell label should be clipped.
	 */
	public boolean isLabelClipped(Object cell)
	{
		if (!isLabelsClipped())
		{
			CellState state = _view.getState(cell);
			Map<String, Object> style = (state != null) ? state.getStyle()
					: getCellStyle(cell);

			return (style != null) ? Utils.getString(style,
					Constants.STYLE_OVERFLOW, "").equals("hidden") : false;
		}

		return isLabelsClipped();
	}

	/**
	 * Returns labelsClipped.
	 */
	public boolean isLabelsClipped()
	{
		return _labelsClipped;
	}

	/**
	 * Sets labelsClipped.
	 */
	public void setLabelsClipped(boolean value)
	{
		boolean oldValue = _labelsClipped;
		_labelsClipped = value;

		_changeSupport.firePropertyChange("labelsClipped", oldValue,
				_labelsClipped);
	}

	/**
	 * Returns true if the given edges's label is moveable. This returns
	 * <movable> for all given cells if <isLocked> does not return true
	 * for the given cell.
	 * 
	 * @param cell <Cell> whose label should be moved.
	 * @return Returns true if the label of the given cell is movable.
	 */
	public boolean isLabelMovable(Object cell)
	{
		return !isCellLocked(cell)
				&& ((_model.isEdge(cell) && isEdgeLabelsMovable()) || (_model
						.isVertex(cell) && isVertexLabelsMovable()));
	}

	/**
	 * Returns vertexLabelsMovable.
	 */
	public boolean isVertexLabelsMovable()
	{
		return _vertexLabelsMovable;
	}

	/**
	 * Sets vertexLabelsMovable.
	 */
	public void setVertexLabelsMovable(boolean value)
	{
		boolean oldValue = _vertexLabelsMovable;
		_vertexLabelsMovable = value;

		_changeSupport.firePropertyChange("vertexLabelsMovable", oldValue,
				_vertexLabelsMovable);
	}

	/**
	 * Returns edgeLabelsMovable.
	 */
	public boolean isEdgeLabelsMovable()
	{
		return _edgeLabelsMovable;
	}

	/**
	 * Returns edgeLabelsMovable.
	 */
	public void setEdgeLabelsMovable(boolean value)
	{
		boolean oldValue = _edgeLabelsMovable;
		_edgeLabelsMovable = value;

		_changeSupport.firePropertyChange("edgeLabelsMovable", oldValue,
				_edgeLabelsMovable);
	}

	//
	// Graph control options
	//

	/**
	 * Returns true if the graph is <enabled>.
	 * 
	 * @return Returns true if the graph is enabled.
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * Specifies if the graph should allow any interactions. This
	 * implementation updates <enabled>.
	 * 
	 * @param value Boolean indicating if the graph should be enabled.
	 */
	public void setEnabled(boolean value)
	{
		boolean oldValue = _enabled;
		_enabled = value;

		_changeSupport.firePropertyChange("enabled", oldValue, _enabled);
	}

	/**
	 * Returns true if the graph allows drop into other cells.
	 */
	public boolean isDropEnabled()
	{
		return _dropEnabled;
	}

	/**
	 * Sets dropEnabled.
	 */
	public void setDropEnabled(boolean value)
	{
		boolean oldValue = _dropEnabled;
		_dropEnabled = value;

		_changeSupport.firePropertyChange("dropEnabled", oldValue, _dropEnabled);
	}

	/**
	 * Affects the return values of isValidDropTarget to allow for edges as
	 * drop targets. The splitEdge method is called in GraphHandler if
	 * GraphComponent.isSplitEvent returns true for a given configuration.
	 */
	public boolean isSplitEnabled()
	{
		return _splitEnabled;
	}

	/**
	 * Sets splitEnabled.
	 */
	public void setSplitEnabled(boolean value)
	{
		_splitEnabled = value;
	}

	/**
	 * Returns multigraph.
	 */
	public boolean isMultigraph()
	{
		return _multigraph;
	}

	/**
	 * Sets multigraph.
	 */
	public void setMultigraph(boolean value)
	{
		boolean oldValue = _multigraph;
		_multigraph = value;

		_changeSupport.firePropertyChange("multigraph", oldValue, _multigraph);
	}

	/**
	 * Returns swimlaneNesting.
	 */
	public boolean isSwimlaneNesting()
	{
		return _swimlaneNesting;
	}

	/**
	 * Sets swimlaneNesting.
	 */
	public void setSwimlaneNesting(boolean value)
	{
		boolean oldValue = _swimlaneNesting;
		_swimlaneNesting = value;

		_changeSupport.firePropertyChange("swimlaneNesting", oldValue,
				_swimlaneNesting);
	}

	/**
	 * Returns allowDanglingEdges
	 */
	public boolean isAllowDanglingEdges()
	{
		return _allowDanglingEdges;
	}

	/**
	 * Sets allowDanglingEdges.
	 */
	public void setAllowDanglingEdges(boolean value)
	{
		boolean oldValue = _allowDanglingEdges;
		_allowDanglingEdges = value;

		_changeSupport.firePropertyChange("allowDanglingEdges", oldValue,
				_allowDanglingEdges);
	}

	/**
	 * Returns cloneInvalidEdges.
	 */
	public boolean isCloneInvalidEdges()
	{
		return _cloneInvalidEdges;
	}

	/**
	 * Sets cloneInvalidEdge.
	 */
	public void setCloneInvalidEdges(boolean value)
	{
		boolean oldValue = _cloneInvalidEdges;
		_cloneInvalidEdges = value;

		_changeSupport.firePropertyChange("cloneInvalidEdges", oldValue,
				_cloneInvalidEdges);
	}

	/**
	 * Returns disconnectOnMove
	 */
	public boolean isDisconnectOnMove()
	{
		return _disconnectOnMove;
	}

	/**
	 * Sets disconnectOnMove.
	 */
	public void setDisconnectOnMove(boolean value)
	{
		boolean oldValue = _disconnectOnMove;
		_disconnectOnMove = value;

		_changeSupport.firePropertyChange("disconnectOnMove", oldValue,
				_disconnectOnMove);

	}

	/**
	 * Returns allowLoops.
	 */
	public boolean isAllowLoops()
	{
		return _allowLoops;
	}

	/**
	 * Sets allowLoops.
	 */
	public void setAllowLoops(boolean value)
	{
		boolean oldValue = _allowLoops;
		_allowLoops = value;

		_changeSupport.firePropertyChange("allowLoops", oldValue, _allowLoops);
	}

	/**
	 * Returns connectableEdges.
	 */
	public boolean isConnectableEdges()
	{
		return _connectableEdges;
	}

	/**
	 * Sets connetableEdges.
	 */
	public void setConnectableEdges(boolean value)
	{
		boolean oldValue = _connectableEdges;
		_connectableEdges = value;

		_changeSupport.firePropertyChange("connectableEdges", oldValue,
				_connectableEdges);

	}

	/**
	 * Returns resetEdgesOnMove.
	 */
	public boolean isResetEdgesOnMove()
	{
		return _resetEdgesOnMove;
	}

	/**
	 * Sets resetEdgesOnMove.
	 */
	public void setResetEdgesOnMove(boolean value)
	{
		boolean oldValue = _resetEdgesOnMove;
		_resetEdgesOnMove = value;

		_changeSupport.firePropertyChange("resetEdgesOnMove", oldValue,
				_resetEdgesOnMove);
	}

	/**
	 * Returns resetViewOnRootChange.
	 */
	public boolean isResetViewOnRootChange()
	{
		return _resetViewOnRootChange;
	}

	/**
	 * Sets resetEdgesOnResize.
	 */
	public void setResetViewOnRootChange(boolean value)
	{
		boolean oldValue = _resetViewOnRootChange;
		_resetViewOnRootChange = value;

		_changeSupport.firePropertyChange("resetViewOnRootChange", oldValue,
				_resetViewOnRootChange);
	}

	/**
	 * Returns resetEdgesOnResize.
	 */
	public boolean isResetEdgesOnResize()
	{
		return _resetEdgesOnResize;
	}

	/**
	 * Sets resetEdgesOnResize.
	 */
	public void setResetEdgesOnResize(boolean value)
	{
		boolean oldValue = _resetEdgesOnResize;
		_resetEdgesOnResize = value;

		_changeSupport.firePropertyChange("resetEdgesOnResize", oldValue,
				_resetEdgesOnResize);
	}

	/**
	 * Returns resetEdgesOnConnect.
	 */
	public boolean isResetEdgesOnConnect()
	{
		return _resetEdgesOnConnect;
	}

	/**
	 * Sets resetEdgesOnConnect.
	 */
	public void setResetEdgesOnConnect(boolean value)
	{
		boolean oldValue = _resetEdgesOnConnect;
		_resetEdgesOnConnect = value;

		_changeSupport.firePropertyChange("resetEdgesOnConnect", oldValue,
				_resetEdgesOnResize);
	}

	/**
	 * Returns true if the size of the given cell should automatically be
	 * updated after a change of the label. This implementation returns
	 * autoSize for all given cells or checks if the cell style does specify
	 * Constants.STYLE_AUTOSIZE to be 1.
	 * 
	 * @param cell Cell that should be resized.
	 * @return Returns true if the size of the given cell should be updated.
	 */
	public boolean isAutoSizeCell(Object cell)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return isAutoSizeCells()
				|| Utils.isTrue(style, Constants.STYLE_AUTOSIZE, false);
	}

	/**
	 * Returns true if the size of the given cell should automatically be
	 * updated after a change of the label. This implementation returns
	 * autoSize for all given cells.
	 */
	public boolean isAutoSizeCells()
	{
		return _autoSizeCells;
	}

	/**
	 * Specifies if cell sizes should be automatically updated after a label
	 * change. This implementation sets autoSize to the given parameter.
	 * 
	 * @param value Boolean indicating if cells should be resized
	 * automatically.
	 */
	public void setAutoSizeCells(boolean value)
	{
		boolean oldValue = _autoSizeCells;
		_autoSizeCells = value;

		_changeSupport.firePropertyChange("autoSizeCells", oldValue,
				_autoSizeCells);
	}

	/**
	 * Returns true if the parent of the given cell should be extended if the
	 * child has been resized so that it overlaps the parent. This
		 * implementation returns ExtendParents if cell is not an edge.
	 * 
	 * @param cell Cell that has been resized.
	 */
	public boolean isExtendParent(Object cell)
	{
		return !getModel().isEdge(cell) && isExtendParents();
	}

	/**
	 * Returns extendParents.
	 */
	public boolean isExtendParents()
	{
		return _extendParents;
	}

	/**
	 * Sets extendParents.
	 */
	public void setExtendParents(boolean value)
	{
		boolean oldValue = _extendParents;
		_extendParents = value;

		_changeSupport.firePropertyChange("extendParents", oldValue,
				_extendParents);
	}

	/**
	 * Returns extendParentsOnAdd.
	 */
	public boolean isExtendParentsOnAdd()
	{
		return _extendParentsOnAdd;
	}

	/**
	 * Sets extendParentsOnAdd.
	 */
	public void setExtendParentsOnAdd(boolean value)
	{
		boolean oldValue = _extendParentsOnAdd;
		_extendParentsOnAdd = value;

		_changeSupport.firePropertyChange("extendParentsOnAdd", oldValue,
				_extendParentsOnAdd);
	}

	/**
	 * Returns true if the given cell should be kept inside the bounds of its
	 * parent according to the rules defined by getOverlap and
	 * isAllowOverlapParent. This implementation returns false for all children
	 * of edges and isConstrainChildren() otherwise.
	 */
	public boolean isConstrainChild(Object cell)
	{
		return isConstrainChildren()
				&& !getModel().isEdge(getModel().getParent(cell));
	}

	/**
	 * Returns constrainChildren.
	 * 
	 * @return the keepInsideParentOnMove
	 */
	public boolean isConstrainChildren()
	{
		return _constrainChildren;
	}

	/**
	 * @param value the constrainChildren to set
	 */
	public void setConstrainChildren(boolean value)
	{
		boolean oldValue = _constrainChildren;
		_constrainChildren = value;

		_changeSupport.firePropertyChange("constrainChildren", oldValue,
				_constrainChildren);
	}

	/**
	 * Returns autoOrigin.
	 */
	public boolean isAutoOrigin()
	{
		return _autoOrigin;
	}

	/**
	 * @param value the autoOrigin to set
	 */
	public void setAutoOrigin(boolean value)
	{
		boolean oldValue = _autoOrigin;
		_autoOrigin = value;

		_changeSupport.firePropertyChange("autoOrigin", oldValue, _autoOrigin);
	}

	/**
	 * Returns origin.
	 */
	public Point2d getOrigin()
	{
		return _origin;
	}

	/**
	 * @param value the origin to set
	 */
	public void setOrigin(Point2d value)
	{
		Point2d oldValue = _origin;
		_origin = value;

		_changeSupport.firePropertyChange("origin", oldValue, _origin);
	}

	/**
	 * @return Returns changesRepaintThreshold.
	 */
	public int getChangesRepaintThreshold()
	{
		return _changesRepaintThreshold;
	}

	/**
	 * @param value the changesRepaintThreshold to set
	 */
	public void setChangesRepaintThreshold(int value)
	{
		int oldValue = _changesRepaintThreshold;
		_changesRepaintThreshold = value;

		_changeSupport.firePropertyChange("changesRepaintThreshold", oldValue,
				_changesRepaintThreshold);
	}

	/**
	 * Returns isAllowNegativeCoordinates.
	 * 
	 * @return the allowNegativeCoordinates
	 */
	public boolean isAllowNegativeCoordinates()
	{
		return _allowNegativeCoordinates;
	}

	/**
	 * @param value the allowNegativeCoordinates to set
	 */
	public void setAllowNegativeCoordinates(boolean value)
	{
		boolean oldValue = _allowNegativeCoordinates;
		_allowNegativeCoordinates = value;

		_changeSupport.firePropertyChange("allowNegativeCoordinates", oldValue,
				_allowNegativeCoordinates);
	}

	/**
	 * Returns collapseToPreferredSize.
	 * 
	 * @return the collapseToPreferredSize
	 */
	public boolean isCollapseToPreferredSize()
	{
		return _collapseToPreferredSize;
	}

	/**
	 * @param value the collapseToPreferredSize to set
	 */
	public void setCollapseToPreferredSize(boolean value)
	{
		boolean oldValue = _collapseToPreferredSize;
		_collapseToPreferredSize = value;

		_changeSupport.firePropertyChange("collapseToPreferredSize", oldValue,
				_collapseToPreferredSize);
	}

	/**
	 * @return Returns true if edges are rendered in the foreground.
	 */
	public boolean isKeepEdgesInForeground()
	{
		return _keepEdgesInForeground;
	}

	/**
	 * @param value the keepEdgesInForeground to set
	 */
	public void setKeepEdgesInForeground(boolean value)
	{
		boolean oldValue = _keepEdgesInForeground;
		_keepEdgesInForeground = value;

		_changeSupport.firePropertyChange("keepEdgesInForeground", oldValue,
				_keepEdgesInForeground);
	}

	/**
	 * @return Returns true if edges are rendered in the background.
	 */
	public boolean isKeepEdgesInBackground()
	{
		return _keepEdgesInBackground;
	}

	/**
	 * @param value the keepEdgesInBackground to set
	 */
	public void setKeepEdgesInBackground(boolean value)
	{
		boolean oldValue = _keepEdgesInBackground;
		_keepEdgesInBackground = value;

		_changeSupport.firePropertyChange("keepEdgesInBackground", oldValue,
				_keepEdgesInBackground);
	}

	/**
	 * Returns true if the given cell is a valid source for new connections.
	 * This implementation returns true for all non-null values and is
	 * called by is called by <isValidConnection>.
	 * 
	 * @param cell Object that represents a possible source or null.
	 * @return Returns true if the given cell is a valid source terminal.
	 */
	public boolean isValidSource(Object cell)
	{
		return (cell == null && _allowDanglingEdges)
				|| (cell != null
						&& (!_model.isEdge(cell) || isConnectableEdges()) && isCellConnectable(cell));
	}

	/**
	 * Returns isValidSource for the given cell. This is called by
	 * isValidConnection.
	 *
	 * @param cell Object that represents a possible target or null.
	 * @return Returns true if the given cell is a valid target.
	 */
	public boolean isValidTarget(Object cell)
	{
		return isValidSource(cell);
	}

	/**
	 * Returns true if the given target cell is a valid target for source.
	 * This is a boolean implementation for not allowing connections between
	 * certain pairs of vertices and is called by <getEdgeValidationError>.
	 * This implementation returns true if <isValidSource> returns true for
	 * the source and <isValidTarget> returns true for the target.
	 * 
	 * @param source Object that represents the source cell.
	 * @param target Object that represents the target cell.
	 * @return Returns true if the the connection between the given terminals
	 * is valid.
	 */
	public boolean isValidConnection(Object source, Object target)
	{
		return isValidSource(source) && isValidTarget(target)
				&& (isAllowLoops() || source != target);
	}

	/**
	 * Returns the minimum size of the diagram.
	 * 
	 * @return Returns the minimum container size.
	 */
	public Rect getMinimumGraphSize()
	{
		return _minimumGraphSize;
	}

	/**
	 * @param value the minimumGraphSize to set
	 */
	public void setMinimumGraphSize(Rect value)
	{
		Rect oldValue = _minimumGraphSize;
		_minimumGraphSize = value;

		_changeSupport.firePropertyChange("minimumGraphSize", oldValue, value);
	}

	/**
	 * Returns a decimal number representing the amount of the width and height
	 * of the given cell that is allowed to overlap its parent. A value of 0
	 * means all children must stay inside the parent, 1 means the child is
	 * allowed to be placed outside of the parent such that it touches one of
	 * the parents sides. If <isAllowOverlapParent> returns false for the given
	 * cell, then this method returns 0.
	 * 
	 * @param cell
	 * @return Returns the overlapping value for the given cell inside its
	 * parent.
	 */
	public double getOverlap(Object cell)
	{
		return (isAllowOverlapParent(cell)) ? getDefaultOverlap() : 0;
	}

	/**
	 * Gets defaultOverlap.
	 */
	public double getDefaultOverlap()
	{
		return _defaultOverlap;
	}

	/**
	 * Sets defaultOverlap.
	 */
	public void setDefaultOverlap(double value)
	{
		double oldValue = _defaultOverlap;
		_defaultOverlap = value;

		_changeSupport.firePropertyChange("defaultOverlap", oldValue, value);
	}

	/**
	 * Returns true if the given cell is allowed to be placed outside of the
	 * parents area.
	 * 
	 * @param cell
	 * @return Returns true if the given cell may overlap its parent.
	 */
	public boolean isAllowOverlapParent(Object cell)
	{
		return false;
	}

	/**
	 * Returns the cells which are movable in the given array of cells.
	 */
	public Object[] getFoldableCells(Object[] cells, final boolean collapse)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return isCellFoldable(cell, collapse);
			}
		});
	}

	/**
	 * Returns true if the given cell is expandable. This implementation
	 * returns true if the cell has at least one child and its style
	 * does not specify Constants.STYLE_FOLDABLE to be 0.
	 *
	 * @param cell <Cell> whose expandable state should be returned.
	 * @return Returns true if the given cell is expandable.
	 */
	public boolean isCellFoldable(Object cell, boolean collapse)
	{
		CellState state = _view.getState(cell);
		Map<String, Object> style = (state != null) ? state.getStyle()
				: getCellStyle(cell);

		return _model.getChildCount(cell) > 0
				&& Utils.isTrue(style, Constants.STYLE_FOLDABLE, true);
	}

	/**
	 * Returns true if the grid is enabled.
	 * 
	 * @return Returns the enabled state of the grid.
	 */
	public boolean isGridEnabled()
	{
		return _gridEnabled;
	}

	/**
	 * Sets if the grid is enabled.
	 * 
	 * @param value Specifies if the grid should be enabled.
	 */
	public void setGridEnabled(boolean value)
	{
		boolean oldValue = _gridEnabled;
		_gridEnabled = value;

		_changeSupport.firePropertyChange("gridEnabled", oldValue, _gridEnabled);
	}

	/**
	 * Returns true if ports are enabled.
	 * 
	 * @return Returns the enabled state of the ports.
	 */
	public boolean isPortsEnabled()
	{
		return _portsEnabled;
	}

	/**
	 * Sets if ports are enabled.
	 * 
	 * @param value Specifies if the ports should be enabled.
	 */
	public void setPortsEnabled(boolean value)
	{
		boolean oldValue = _portsEnabled;
		_portsEnabled = value;

		_changeSupport.firePropertyChange("portsEnabled", oldValue, _portsEnabled);
	}

	/**
	 * Returns the grid size.
	 * 
	 * @return Returns the grid size
	 */
	public int getGridSize()
	{
		return _gridSize;
	}

	/**
	 * Sets the grid size and fires a property change event for gridSize.
	 * 
	 * @param value New grid size to be used.
	 */
	public void setGridSize(int value)
	{
		int oldValue = _gridSize;
		_gridSize = value;

		_changeSupport.firePropertyChange("gridSize", oldValue, _gridSize);
	}

	/**
	 * Returns alternateEdgeStyle.
	 */
	public String getAlternateEdgeStyle()
	{
		return _alternateEdgeStyle;
	}

	/**
	 * Sets alternateEdgeStyle.
	 */
	public void setAlternateEdgeStyle(String value)
	{
		String oldValue = _alternateEdgeStyle;
		_alternateEdgeStyle = value;

		_changeSupport.firePropertyChange("alternateEdgeStyle", oldValue,
				_alternateEdgeStyle);
	}

	/**
	 * Returns true if the given cell is a valid drop target for the specified
	 * cells. This returns true if the cell is a swimlane, has children and is
	 * not collapsed, or if splitEnabled is true and isSplitTarget returns
	 * true for the given arguments
	 * 
	 * @param cell Object that represents the possible drop target.
	 * @param cells Objects that are going to be dropped.
	 * @return Returns true if the cell is a valid drop target for the given
	 * cells.
	 */
	public boolean isValidDropTarget(Object cell, Object[] cells)
	{
		return cell != null
				&& ((isSplitEnabled() && isSplitTarget(cell, cells)) || (!_model
						.isEdge(cell) && (isSwimlane(cell) || (_model
						.getChildCount(cell) > 0 && !isCellCollapsed(cell)))));
	}

	/**
	 * Returns true if split is enabled and the given edge may be splitted into
	 * two edges with the given cell as a new terminal between the two.
	 * 
	 * @param target Object that represents the edge to be splitted.
	 * @param cells Array of cells to add into the given edge.
	 * @return Returns true if the given edge may be splitted by the given
	 * cell.
	 */
	public boolean isSplitTarget(Object target, Object[] cells)
	{
		if (target != null && cells != null && cells.length == 1)
		{
			Object src = _model.getTerminal(target, true);
			Object trg = _model.getTerminal(target, false);

			return (_model.isEdge(target)
					&& isCellConnectable(cells[0])
					&& getEdgeValidationError(target,
							_model.getTerminal(target, true), cells[0]) == null
					&& !_model.isAncestor(cells[0], src) && !_model.isAncestor(
					cells[0], trg));
		}

		return false;
	}

	/**
	 * Returns the given cell if it is a drop target for the given cells or the
	 * nearest ancestor that may be used as a drop target for the given cells.
	 * If the given array contains a swimlane and swimlaneNesting is false
	 * then this always returns null. If no cell is given, then the bottommost
	 * swimlane at the location of the given event is returned.
	 * 
	 * This function should only be used if isDropEnabled returns true.
	 */
	public Object getDropTarget(Object[] cells, Point pt, Object cell)
	{
		if (!isSwimlaneNesting())
		{
			for (int i = 0; i < cells.length; i++)
			{
				if (isSwimlane(cells[i]))
				{
					return null;
				}
			}
		}

		// FIXME the else below does nothing if swimlane is null
		Object swimlane = null; //getSwimlaneAt(pt.x, pt.y);

		if (cell == null)
		{
			cell = swimlane;
		}
		/*else if (swimlane != null)
		{
			// Checks if the cell is an ancestor of the swimlane
			// under the mouse and uses the swimlane in that case
			Object tmp = model.getParent(swimlane);

			while (tmp != null && isSwimlane(tmp) && tmp != cell)
			{
				tmp = model.getParent(tmp);
			}

			if (tmp == cell)
			{
				cell = swimlane;
			}
		}*/

		while (cell != null && !isValidDropTarget(cell, cells)
				&& _model.getParent(cell) != _model.getRoot())
		{
			cell = _model.getParent(cell);
		}

		return (_model.getParent(cell) != _model.getRoot() && !Utils.contains(
				cells, cell)) ? cell : null;
	};

	//
	// Cell retrieval
	//

	/**
	 * Returns the first child of the root in the model, that is, the first or
	 * default layer of the diagram. 
	 * 
	 * @return Returns the default parent for new cells.
	 */
	public Object getDefaultParent()
	{
		Object parent = _defaultParent;

		if (parent == null)
		{
			parent = _view.getCurrentRoot();

			if (parent == null)
			{
				Object root = _model.getRoot();
				parent = _model.getChildAt(root, 0);
			}
		}

		return parent;
	}

	/**
	 * Sets the default parent to be returned by getDefaultParent.
	 * Set this to null to return the first child of the root in
	 * getDefaultParent.
	 */
	public void setDefaultParent(Object value)
	{
		_defaultParent = value;
	}

	/**
	 * Returns the visible child vertices of the given parent.
	 * 
	 * @param parent Cell whose children should be returned.
	 */
	public Object[] getChildVertices(Object parent)
	{
		return getChildCells(parent, true, false);
	}

	/**
	 * Returns the visible child edges of the given parent.
	 * 
	 * @param parent Cell whose children should be returned.
	 */
	public Object[] getChildEdges(Object parent)
	{
		return getChildCells(parent, false, true);
	}

	/**
	 * Returns the visible children of the given parent.
	 * 
	 * @param parent Cell whose children should be returned.
	 */
	public Object[] getChildCells(Object parent)
	{
		return getChildCells(parent, false, false);
	}

	/**
	 * Returns the visible child vertices or edges in the given parent. If
	 * vertices and edges is false, then all children are returned.
	 * 
	 * @param parent Cell whose children should be returned.
	 * @param vertices Specifies if child vertices should be returned.
	 * @param edges Specifies if child edges should be returned.
	 * @return Returns the child vertices and edges.
	 */
	public Object[] getChildCells(Object parent, boolean vertices, boolean edges)
	{
		Object[] cells = GraphModel.getChildCells(_model, parent, vertices,
				edges);
		List<Object> result = new ArrayList<Object>(cells.length);

		// Filters out the non-visible child cells
		for (int i = 0; i < cells.length; i++)
		{
			if (isCellVisible(cells[i]))
			{
				result.add(cells[i]);
			}
		}

		return result.toArray();
	}

	/**
	 * Returns all visible edges connected to the given cell without loops.
	 * 
	 * @param cell Cell whose connections should be returned.
	 * @return Returns the connected edges for the given cell.
	 */
	public Object[] getConnections(Object cell)
	{
		return getConnections(cell, null);
	}

	/**
	 * Returns all visible edges connected to the given cell without loops.
	 * If the optional parent argument is specified, then only child
	 * edges of the given parent are returned.
	 * 
	 * @param cell Cell whose connections should be returned.
	 * @param parent Optional parent of the opposite end for a connection
	 * to be returned.
	 * @return Returns the connected edges for the given cell.
	 */
	public Object[] getConnections(Object cell, Object parent)
	{
		return getConnections(cell, parent, false);
	}

	/**
	 * Returns all visible edges connected to the given cell without loops.
	 * If the optional parent argument is specified, then only child
	 * edges of the given parent are returned.
	 * 
	 * @param cell Cell whose connections should be returned.
	 * @param parent Optional parent of the opposite end for a connection
	 * to be returned.
	 * @return Returns the connected edges for the given cell.
	 */
	public Object[] getConnections(Object cell, Object parent, boolean recurse)
	{
		return getEdges(cell, parent, true, true, false, recurse);
	}

	/**
	 * Returns all incoming visible edges connected to the given cell without
	 * loops.
	 * 
	 * @param cell Cell whose incoming edges should be returned.
	 * @return Returns the incoming edges of the given cell.
	 */
	public Object[] getIncomingEdges(Object cell)
	{
		return getIncomingEdges(cell, null);
	}

	/**
	 * Returns the visible incoming edges for the given cell. If the optional
	 * parent argument is specified, then only child edges of the given parent
	 * are returned.
	 * 
	 * @param cell Cell whose incoming edges should be returned.
	 * @param parent Optional parent of the opposite end for an edge
	 * to be returned.
	 * @return Returns the incoming edges of the given cell.
	 */
	public Object[] getIncomingEdges(Object cell, Object parent)
	{
		return getEdges(cell, parent, true, false, false);
	}

	/**
	 * Returns all outgoing visible edges connected to the given cell without
	 * loops.
	 * 
	 * @param cell Cell whose outgoing edges should be returned.
	 * @return Returns the outgoing edges of the given cell.
	 */
	public Object[] getOutgoingEdges(Object cell)
	{
		return getOutgoingEdges(cell, null);
	}

	/**
	 * Returns the visible outgoing edges for the given cell. If the optional
	 * parent argument is specified, then only child edges of the given parent
	 * are returned.
	 * 
	 * @param cell Cell whose outgoing edges should be returned.
	 * @param parent Optional parent of the opposite end for an edge
	 * to be returned.
	 * @return Returns the outgoing edges of the given cell.
	 */
	public Object[] getOutgoingEdges(Object cell, Object parent)
	{
		return getEdges(cell, parent, false, true, false);
	}

	/**
	 * Returns all visible edges connected to the given cell including loops.
	 *
	 * @param cell Cell whose edges should be returned.
	 * @return Returns the edges of the given cell.
	 */
	public Object[] getEdges(Object cell)
	{
		return getEdges(cell, null);
	}

	/**
	 * Returns all visible edges connected to the given cell including loops.
	 * 
	 * @param cell Cell whose edges should be returned.
	 * @param parent Optional parent of the opposite end for an edge
	 * to be returned.
	 * @return Returns the edges of the given cell.
	 */
	public Object[] getEdges(Object cell, Object parent)
	{
		return getEdges(cell, parent, true, true, true);
	}

	/**
	 * Returns the incoming and/or outgoing edges for the given cell.
	 * If the optional parent argument is specified, then only edges are returned
	 * where the opposite is in the given parent cell.
	 * 
	 * @param cell Cell whose edges should be returned.
	 * @param parent Optional parent. If specified the opposite end of any edge
	 * must be a direct child of that parent in order for the edge to be returned.
	 * @param incoming Specifies if incoming edges should be included in the
	 * result.
	 * @param outgoing Specifies if outgoing edges should be included in the
	 * result.
	 * @param includeLoops Specifies if loops should be included in the result.
	 * @return Returns the edges connected to the given cell.
	 */
	public Object[] getEdges(Object cell, Object parent, boolean incoming,
			boolean outgoing, boolean includeLoops)
	{
		return getEdges(cell, parent, incoming, outgoing, includeLoops, false);
	}

	/**
	 * Returns the incoming and/or outgoing edges for the given cell.
	 * If the optional parent argument is specified, then only edges are returned
	 * where the opposite is in the given parent cell.
	 * 
	 * @param cell Cell whose edges should be returned.
	 * @param parent Optional parent. If specified the opposite end of any edge
	 * must be a child of that parent in order for the edge to be returned. The
	 * recurse parameter specifies whether or not it must be the direct child
	 * or the parent just be an ancestral parent.
	 * @param incoming Specifies if incoming edges should be included in the
	 * result.
	 * @param outgoing Specifies if outgoing edges should be included in the
	 * result.
	 * @param includeLoops Specifies if loops should be included in the result.
	 * @param recurse Specifies if the parent specified only need be an ancestral
	 * parent, <code>true</code>, or the direct parent, <code>false</code>
	 * @return Returns the edges connected to the given cell.
	 */
	public Object[] getEdges(Object cell, Object parent, boolean incoming,
			boolean outgoing, boolean includeLoops, boolean recurse)
	{
		boolean isCollapsed = isCellCollapsed(cell);
		List<Object> edges = new ArrayList<Object>();
		int childCount = _model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = _model.getChildAt(cell, i);

			if (isCollapsed || !isCellVisible(child))
			{
				edges.addAll(Arrays.asList(GraphModel.getEdges(_model, child,
						incoming, outgoing, includeLoops)));
			}
		}

		edges.addAll(Arrays.asList(GraphModel.getEdges(_model, cell, incoming,
				outgoing, includeLoops)));
		List<Object> result = new ArrayList<Object>(edges.size());
		Iterator<Object> it = edges.iterator();

		while (it.hasNext())
		{
			Object edge = it.next();
			CellState state = _view.getState(edge);
			Object source = (state != null) ? state.getVisibleTerminal(true)
					: _view.getVisibleTerminal(edge, true);
			Object target = (state != null) ? state.getVisibleTerminal(false)
					: _view.getVisibleTerminal(edge, false);

			if ((includeLoops && source == target)
					|| ((source != target) && ((incoming && target == cell && (parent == null || isValidAncestor(
							source, parent, recurse))) || (outgoing
							&& source == cell && (parent == null || isValidAncestor(
							target, parent, recurse))))))
			{
				result.add(edge);
			}
		}

		return result.toArray();
	}

	/**
	 * Returns whether or not the specified parent is a valid
	 * ancestor of the specified cell, either direct or indirectly
	 * based on whether ancestor recursion is enabled.
	 * @param cell the possible child cell
	 * @param parent the possible parent cell
	 * @param recurse whether or not to recurse the child ancestors
	 * @return whether or not the specified parent is a valid
	 * ancestor of the specified cell, either direct or indirectly
	 * based on whether ancestor recursion is enabled.
	 */
	public boolean isValidAncestor(Object cell, Object parent, boolean recurse)
	{
		return (recurse ? _model.isAncestor(parent, cell) : _model
				.getParent(cell) == parent);
	}

	/**
	 * Returns all distinct visible opposite cells of the terminal on the given
	 * edges.
	 * 
	 * @param edges
	 * @param terminal
	 * @return Returns the terminals at the opposite ends of the given edges.
	 */
	public Object[] getOpposites(Object[] edges, Object terminal)
	{
		return getOpposites(edges, terminal, true, true);
	}

	/**
	 * Returns all distincts visible opposite cells for the specified terminal
	 * on the given edges.
	 * 
	 * @param edges Edges whose opposite terminals should be returned.
	 * @param terminal Terminal that specifies the end whose opposite should be
	 * returned.
	 * @param sources Specifies if source terminals should be included in the
	 * result.
	 * @param targets Specifies if target terminals should be included in the
	 * result.
	 * @return Returns the cells at the opposite ends of the given edges.
	 */
	public Object[] getOpposites(Object[] edges, Object terminal,
			boolean sources, boolean targets)
	{
		Collection<Object> terminals = new LinkedHashSet<Object>();

		if (edges != null)
		{
			for (int i = 0; i < edges.length; i++)
			{
				CellState state = _view.getState(edges[i]);
				Object source = (state != null) ? state
						.getVisibleTerminal(true) : _view.getVisibleTerminal(
						edges[i], true);
				Object target = (state != null) ? state
						.getVisibleTerminal(false) : _view.getVisibleTerminal(
						edges[i], false);

				// Checks if the terminal is the source of
				// the edge and if the target should be
				// stored in the result
				if (targets && source == terminal && target != null
						&& target != terminal)
				{
					terminals.add(target);
				}

				// Checks if the terminal is the taget of
				// the edge and if the source should be
				// stored in the result
				else if (sources && target == terminal && source != null
						&& source != terminal)
				{
					terminals.add(source);
				}
			}
		}

		return terminals.toArray();
	}

	/**
	 * Returns the edges between the given source and target. This takes into
	 * account collapsed and invisible cells and returns the connected edges
	 * as displayed on the screen.
	 * 
	 * @param source
	 * @param target
	 * @return Returns all edges between the given terminals.
	 */
	public Object[] getEdgesBetween(Object source, Object target)
	{
		return getEdgesBetween(source, target, false);
	}

	/**
	 * Returns the edges between the given source and target. This takes into
	 * account collapsed and invisible cells and returns the connected edges
	 * as displayed on the screen.
	 * 
	 * @param source
	 * @param target
	 * @param directed
	 * @return Returns all edges between the given terminals.
	 */
	public Object[] getEdgesBetween(Object source, Object target,
			boolean directed)
	{
		Object[] edges = getEdges(source);
		List<Object> result = new ArrayList<Object>(edges.length);

		// Checks if the edge is connected to the correct
		// cell and adds any match to the result
		for (int i = 0; i < edges.length; i++)
		{
			CellState state = _view.getState(edges[i]);
			Object src = (state != null) ? state.getVisibleTerminal(true)
					: _view.getVisibleTerminal(edges[i], true);
			Object trg = (state != null) ? state.getVisibleTerminal(false)
					: _view.getVisibleTerminal(edges[i], false);

			if ((src == source && trg == target)
					|| (!directed && src == target && trg == source))
			{
				result.add(edges[i]);
			}
		}

		return result.toArray();
	}

	/**
	 * Returns the children of the given parent that are contained in the
	 * halfpane from the given point (x0, y0) rightwards and downwards
	 * depending on rightHalfpane and bottomHalfpane.
	 * 
	 * @param x0 X-coordinate of the origin.
	 * @param y0 Y-coordinate of the origin.
	 * @param parent <Cell> whose children should be checked.
	 * @param rightHalfpane Boolean indicating if the cells in the right halfpane
	 * from the origin should be returned.
	 * @param bottomHalfpane Boolean indicating if the cells in the bottom halfpane
	 * from the origin should be returned.
	 * @return Returns the cells beyond the given halfpane.
	 */
	public Object[] getCellsBeyond(double x0, double y0, Object parent,
			boolean rightHalfpane, boolean bottomHalfpane)
	{
		if (parent == null)
		{
			parent = getDefaultParent();
		}

		int childCount = _model.getChildCount(parent);
		List<Object> result = new ArrayList<Object>(childCount);

		if (rightHalfpane || bottomHalfpane)
		{

			if (parent != null)
			{
				for (int i = 0; i < childCount; i++)
				{
					Object child = _model.getChildAt(parent, i);
					CellState state = _view.getState(child);

					if (isCellVisible(child) && state != null)
					{
						if ((!rightHalfpane || state.getX() >= x0)
								&& (!bottomHalfpane || state.getY() >= y0))
						{
							result.add(child);
						}
					}
				}
			}
		}

		return result.toArray();
	}

	/**
	 * Returns all visible children in the given parent which do not have
	 * incoming edges. If the result is empty then the with the greatest
	 * difference between incoming and outgoing edges is returned. This
	 * takes into account edges that are being promoted to the given
	 * root due to invisible children or collapsed cells.
	 * 
	 * @param parent Cell whose children should be checked.
	 * @return List of tree roots in parent.
	 */
	public List<Object> findTreeRoots(Object parent)
	{
		return findTreeRoots(parent, false);
	}

	/**
	 * Returns all visible children in the given parent which do not have
	 * incoming edges. If the result is empty then the children with the
	 * maximum difference between incoming and outgoing edges are returned.
	 * This takes into account edges that are being promoted to the given
	 * root due to invisible children or collapsed cells.
	 * 
	 * @param parent Cell whose children should be checked.
	 * @param isolate Specifies if edges should be ignored if the opposite
	 * end is not a child of the given parent cell.
	 * @return List of tree roots in parent.
	 */
	public List<Object> findTreeRoots(Object parent, boolean isolate)
	{
		return findTreeRoots(parent, isolate, false);
	}

	/**
	 * Returns all visible children in the given parent which do not have
	 * incoming edges. If the result is empty then the children with the
	 * maximum difference between incoming and outgoing edges are returned.
	 * This takes into account edges that are being promoted to the given
	 * root due to invisible children or collapsed cells.
	 * 
	 * @param parent Cell whose children should be checked.
	 * @param isolate Specifies if edges should be ignored if the opposite
	 * end is not a child of the given parent cell.
	 * @param invert Specifies if outgoing or incoming edges should be counted
	 * for a tree root. If false then outgoing edges will be counted.
	 * @return List of tree roots in parent.
	 */
	public List<Object> findTreeRoots(Object parent, boolean isolate,
			boolean invert)
	{
		List<Object> roots = new ArrayList<Object>();

		if (parent != null)
		{
			int childCount = _model.getChildCount(parent);
			Object best = null;
			int maxDiff = 0;

			for (int i = 0; i < childCount; i++)
			{
				Object cell = _model.getChildAt(parent, i);

				if (_model.isVertex(cell) && isCellVisible(cell))
				{
					Object[] conns = getConnections(cell, (isolate) ? parent
							: null);
					int fanOut = 0;
					int fanIn = 0;

					for (int j = 0; j < conns.length; j++)
					{
						Object src = _view.getVisibleTerminal(conns[j], true);

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
	 * Traverses the tree starting at the given vertex. Here is how to use this
	 * method for a given vertex (root) which is typically the root of a tree:
	 * <code>
	 * graph.traverse(root, true, new ICellVisitor()
	 * {
	 *   public boolean visit(Object vertex, Object edge)
	 *   {
	 *     System.out.println("edge="+graph.convertValueToString(edge)+
	 *       " vertex="+graph.convertValueToString(vertex));
	 *     
	 *     return true;
	 *   }
	 * });
	 * </code>
	 * 
	 * @param vertex
	 * @param directed
	 * @param visitor
	 */
	public void traverse(Object vertex, boolean directed, ICellVisitor visitor)
	{
		traverse(vertex, directed, visitor, null, null);
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
	 * @param visitor Visitor that takes the current vertex and the incoming edge.
	 * The traversal stops if the function returns false.
	 * @param edge Optional <Cell> that represents the incoming edge. This is
	 * null for the first step of the traversal.
	 * @param visited Optional array of cell paths for the visited cells.
	 */
	public void traverse(Object vertex, boolean directed,
			ICellVisitor visitor, Object edge, Set<Object> visited)
	{
		if (vertex != null && visitor != null)
		{
			if (visited == null)
			{
				visited = new HashSet<Object>();
			}

			if (!visited.contains(vertex))
			{
				visited.add(vertex);

				if (visitor.visit(vertex, edge))
				{
					int edgeCount = _model.getEdgeCount(vertex);

					if (edgeCount > 0)
					{
						for (int i = 0; i < edgeCount; i++)
						{
							Object e = _model.getEdgeAt(vertex, i);
							boolean isSource = _model.getTerminal(e, true) == vertex;

							if (!directed || isSource)
							{
								Object next = _model.getTerminal(e, !isSource);
								traverse(next, directed, visitor, e, visited);
							}
						}
					}
				}
			}
		}
	}

	//
	// Selection
	//

	/**
	 * 
	 */
	public GraphSelectionModel getSelectionModel()
	{
		return _selectionModel;
	}

	/**
	 * 
	 */
	public int getSelectionCount()
	{
		return _selectionModel.size();
	}

	/**
	 * 
	 * @param cell
	 * @return Returns true if the given cell is selected.
	 */
	public boolean isCellSelected(Object cell)
	{
		return _selectionModel.isSelected(cell);
	}

	/**
	 * 
	 * @return Returns true if the selection is empty.
	 */
	public boolean isSelectionEmpty()
	{
		return _selectionModel.isEmpty();
	}

	/**
	 * 
	 */
	public void clearSelection()
	{
		_selectionModel.clear();
	}

	/**
	 * 
	 * @return Returns the selection cell.
	 */
	public Object getSelectionCell()
	{
		return _selectionModel.getCell();
	}

	/**
	 * 
	 * @param cell
	 */
	public void setSelectionCell(Object cell)
	{
		_selectionModel.setCell(cell);
	}

	/**
	 * 
	 * @return Returns the selection cells.
	 */
	public Object[] getSelectionCells()
	{
		return _selectionModel.getCells();
	}

	/**
	 * 
	 */
	public void setSelectionCells(Object[] cells)
	{
		_selectionModel.setCells(cells);
	}

	/**
	 * 
	 * @param cells
	 */
	public void setSelectionCells(Collection<Object> cells)
	{
		if (cells != null)
		{
			setSelectionCells(cells.toArray());
		}
	}

	/**
	 * 
	 */
	public void addSelectionCell(Object cell)
	{
		_selectionModel.addCell(cell);
	}

	/**
	 * 
	 */
	public void addSelectionCells(Object[] cells)
	{
		_selectionModel.addCells(cells);
	}

	/**
	 * 
	 */
	public void removeSelectionCell(Object cell)
	{
		_selectionModel.removeCell(cell);
	}

	/**
	 * 
	 */
	public void removeSelectionCells(Object[] cells)
	{
		_selectionModel.removeCells(cells);
	}

	/**
	 * Selects the next cell.
	 */
	public void selectNextCell()
	{
		selectCell(true, false, false);
	}

	/**
	 * Selects the previous cell.
	 */
	public void selectPreviousCell()
	{
		selectCell(false, false, false);
	}

	/**
	 * Selects the parent cell.
	 */
	public void selectParentCell()
	{
		selectCell(false, true, false);
	}

	/**
	 * Selects the first child cell.
	 */
	public void selectChildCell()
	{
		selectCell(false, false, true);
	}

	/**
	 * Selects the next, parent, first child or previous cell, if all arguments
	 * are false.
	 * 
	 * @param isNext
	 * @param isParent
	 * @param isChild
	 */
	public void selectCell(boolean isNext, boolean isParent, boolean isChild)
	{
		Object cell = getSelectionCell();

		if (getSelectionCount() > 1)
		{
			clearSelection();
		}

		Object parent = (cell != null) ? _model.getParent(cell)
				: getDefaultParent();
		int childCount = _model.getChildCount(parent);

		if (cell == null && childCount > 0)
		{
			Object child = _model.getChildAt(parent, 0);
			setSelectionCell(child);
		}
		else if ((cell == null || isParent) && _view.getState(parent) != null
				&& _model.getGeometry(parent) != null)
		{
			if (getCurrentRoot() != parent)
			{
				setSelectionCell(parent);
			}
		}
		else if (cell != null && isChild)
		{
			int tmp = _model.getChildCount(cell);

			if (tmp > 0)
			{
				Object child = _model.getChildAt(cell, 0);
				setSelectionCell(child);
			}
		}
		else if (childCount > 0)
		{
			int i = ((ICell) parent).getIndex((ICell) cell);

			if (isNext)
			{
				i++;
				setSelectionCell(_model.getChildAt(parent, i % childCount));
			}
			else
			{
				i--;
				int index = (i < 0) ? childCount - 1 : i;
				setSelectionCell(_model.getChildAt(parent, index));
			}
		}
	}

	/**
	 * Selects all vertices inside the default parent.
	 */
	public void selectVertices()
	{
		selectVertices(null);
	}

	/**
	 * Selects all vertices inside the given parent or the default parent
	 * if no parent is given.
	 */
	public void selectVertices(Object parent)
	{
		selectCells(true, false, parent);
	}

	/**
	 * Selects all vertices inside the default parent.
	 */
	public void selectEdges()
	{
		selectEdges(null);
	}

	/**
	 * Selects all vertices inside the given parent or the default parent
	 * if no parent is given.
	 */
	public void selectEdges(Object parent)
	{
		selectCells(false, true, parent);
	}

	/**
	 * Selects all vertices and/or edges depending on the given boolean
	 * arguments recursively, starting at the default parent. Use
	 * <code>selectAll</code> to select all cells.
	 *  
	 * @param vertices Boolean indicating if vertices should be selected.
	 * @param edges Boolean indicating if edges should be selected.
	 */
	public void selectCells(boolean vertices, boolean edges)
	{
		selectCells(vertices, edges, null);
	}

	/**
	 * Selects all vertices and/or edges depending on the given boolean
	 * arguments recursively, starting at the given parent or the default
	 * parent if no parent is specified. Use <code>selectAll</code> to select
	 * all cells.
	 * 
	 * @param vertices Boolean indicating if vertices should be selected.
	 * @param edges Boolean indicating if edges should be selected.
	 * @param parent Optional cell that acts as the root of the recursion.
	 * Default is <code>defaultParent</code>.
	 */
	public void selectCells(final boolean vertices, final boolean edges,
			Object parent)
	{
		if (parent == null)
		{
			parent = getDefaultParent();
		}

		Collection<Object> cells = GraphModel.filterDescendants(getModel(),
				new Filter()
				{

					/**
					 * 
					 */
					public boolean filter(Object cell)
					{
						return _view.getState(cell) != null
								&& _model.getChildCount(cell) == 0
								&& ((_model.isVertex(cell) && vertices) || (_model
										.isEdge(cell) && edges));
					}

				});
		setSelectionCells(cells);
	}

	/**
	 * 
	 */
	public void selectAll()
	{
		selectAll(null);
	}

	/**
	 * Selects all children of the given parent cell or the children of the
	 * default parent if no parent is specified. To select leaf vertices and/or
	 * edges use <selectCells>.
	 * 
	 * @param parent  Optional <Cell> whose children should be selected.
	 * Default is <defaultParent>.
	 */
	public void selectAll(Object parent)
	{
		if (parent == null)
		{
			parent = getDefaultParent();
		}

		Object[] children = GraphModel.getChildren(_model, parent);

		if (children != null)
		{
			setSelectionCells(children);
		}
	}

	//
	// Images and drawing
	//

	/**
	 * Draws the graph onto the given canvas.
	 * 
	 * @param canvas Canvas onto which the graph should be drawn.
	 */
	public void drawGraph(ICanvas canvas)
	{
		drawCell(canvas, getModel().getRoot());
	}

	/**
	 * Draws the given cell and its descendants onto the specified canvas.
	 * 
	 * @param canvas Canvas onto which the cell should be drawn.
	 * @param cell Cell that should be drawn onto the canvas.
	 */
	public void drawCell(ICanvas canvas, Object cell)
	{
		drawState(canvas, getView().getState(cell), true);

		// Draws the children on top of their parent
		int childCount = _model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = _model.getChildAt(cell, i);
			drawCell(canvas, child);
		}
	}

	/**
	 * Draws the cell state with the given label onto the canvas. No
	 * children or descendants are painted here. This method invokes
	 * cellDrawn after the cell, but not its descendants have been
	 * painted.
	 * 
	 * @param canvas Canvas onto which the cell should be drawn.
	 * @param state State of the cell to be drawn.
	 * @param drawLabel Indicates if the label should be drawn.
	 */
	public void drawState(ICanvas canvas, CellState state, boolean drawLabel)
	{
		Object cell = (state != null) ? state.getCell() : null;

		if (cell != null && cell != _view.getCurrentRoot()
				&& cell != _model.getRoot()
				&& (_model.isVertex(cell) || _model.isEdge(cell)))
		{
			Object obj = canvas.drawCell(state);
			Object lab = null;

			// Holds the current clipping region in case the label will
			// be clipped
			Shape clip = null;
			Rectangle newClip = state.getRectangle();

			// Indirection for image canvas that contains a graphics canvas
			ICanvas clippedCanvas = (isLabelClipped(state.getCell())) ? canvas
					: null;

			if (clippedCanvas instanceof ImageCanvas)
			{
				clippedCanvas = ((ImageCanvas) clippedCanvas)
						.getGraphicsCanvas();
				// TODO: Shift newClip to match the image offset
				//Point pt = ((ImageCanvas) canvas).getTranslate();
				//newClip.translate(-pt.x, -pt.y);
			}

			if (clippedCanvas instanceof Graphics2DCanvas)
			{
				Graphics g = ((Graphics2DCanvas) clippedCanvas).getGraphics();
				clip = g.getClip();
				
				// Ensure that our new clip resides within our old clip
				if (clip instanceof Rectangle)
				{
					g.setClip(newClip.intersection((Rectangle) clip));
				}
				// Otherwise, default to original implementation
				else
				{
					g.setClip(newClip);
				}
			}

			if (drawLabel)
			{
				String label = state.getLabel();

				if (label != null && state.getLabelBounds() != null)
				{
					lab = canvas.drawLabel(label, state, isHtmlLabel(cell));
				}
			}

			// Restores the previous clipping region
			if (clippedCanvas instanceof Graphics2DCanvas)
			{
				((Graphics2DCanvas) clippedCanvas).getGraphics()
						.setClip(clip);
			}

			// Invokes the cellDrawn callback with the object which was created
			// by the canvas to represent the cell graphically
			if (obj != null)
			{
				_cellDrawn(canvas, state, obj, lab);
			}
		}
	}

	/**
	 * Called when a cell has been painted as the specified object, typically a
	 * DOM node that represents the given cell graphically in a document.
	 */
	protected void _cellDrawn(ICanvas canvas, CellState state,
			Object element, Object labelElement)
	{
		if (element instanceof Element)
		{
			String link = _getLinkForCell(state.getCell());

			if (link != null)
			{
				String title = getToolTipForCell(state.getCell());
				Element elem = (Element) element;

				if (elem.getNodeName().startsWith("v:"))
				{
					elem.setAttribute("href", link.toString());

					if (title != null)
					{
						elem.setAttribute("title", title);
					}
				}
				else if (elem.getOwnerDocument().getElementsByTagName("svg")
						.getLength() > 0)
				{
					Element xlink = elem.getOwnerDocument().createElement("a");
					xlink.setAttribute("xlink:href", link.toString());

					elem.getParentNode().replaceChild(xlink, elem);
					xlink.appendChild(elem);

					if (title != null)
					{
						xlink.setAttribute("xlink:title", title);
					}

					elem = xlink;
				}
				else
				{
					Element a = elem.getOwnerDocument().createElement("a");
					a.setAttribute("href", link.toString());
					a.setAttribute("style", "text-decoration:none;");

					elem.getParentNode().replaceChild(a, elem);
					a.appendChild(elem);

					if (title != null)
					{
						a.setAttribute("title", title);
					}

					elem = a;
				}

				String target = _getTargetForCell(state.getCell());

				if (target != null)
				{
					elem.setAttribute("target", target);
				}
			}
		}
	}

	/**
	 * Returns the hyperlink to be used for the given cell.
	 */
	protected String _getLinkForCell(Object cell)
	{
		return null;
	}

	/**
	 * Returns the hyperlink to be used for the given cell.
	 */
	protected String _getTargetForCell(Object cell)
	{
		return null;
	}

	//
	// Redirected to change support
	//

	/**
	 * @param listener
	 * @see java.beans.PropertyChangeSupport#addPropertyChangeListener(java.beans.PropertyChangeListener)
	 */
	public void addPropertyChangeListener(PropertyChangeListener listener)
	{
		_changeSupport.addPropertyChangeListener(listener);
	}

	/**
	 * @param propertyName
	 * @param listener
	 * @see java.beans.PropertyChangeSupport#addPropertyChangeListener(java.lang.String, java.beans.PropertyChangeListener)
	 */
	public void addPropertyChangeListener(String propertyName,
			PropertyChangeListener listener)
	{
		_changeSupport.addPropertyChangeListener(propertyName, listener);
	}

	/**
	 * @param listener
	 * @see java.beans.PropertyChangeSupport#removePropertyChangeListener(java.beans.PropertyChangeListener)
	 */
	public void removePropertyChangeListener(PropertyChangeListener listener)
	{
		_changeSupport.removePropertyChangeListener(listener);
	}

	/**
	 * @param propertyName
	 * @param listener
	 * @see java.beans.PropertyChangeSupport#removePropertyChangeListener(java.lang.String, java.beans.PropertyChangeListener)
	 */
	public void removePropertyChangeListener(String propertyName,
			PropertyChangeListener listener)
	{
		_changeSupport.removePropertyChangeListener(propertyName, listener);
	}

	/**
	 * Prints the version number on the console. 
	 */
	public static void main(String[] args)
	{
		System.out.println("Graph version \"" + VERSION + "\"");
	}

}
