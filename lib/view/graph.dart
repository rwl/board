/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;

//import java.awt.Graphics;
//import java.awt.Point;
//import java.awt.awt.Rectangle;
//import java.awt.Shape;
//import java.beans.PropertyChangeListener;
//import java.beans.PropertyChangeSupport;

//import org.w3c.dom.Element;

typedef bool ICellVisitor(Object vertex, Object edge);

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
class Graph extends EventSource {

  /**
   * Adds required resources.
   */
  /*static
	{
		try
		{
			Resources.add("graph.resources.graph");
		}
		on Exception catch (e)
		{
			// ignore
		}
	}*/

  /**
   * Holds the version number of this release. Current version
   * is 2.8.0.0.
   */
  static final String VERSION = "2.8.0.0";

  /**
   * Property change event handling.
   */
  PropertyChangeSupport _changeSupport;

  /**
   * Holds the model that contains the cells to be displayed.
   */
  IGraphModel _model;

  /**
   * Holds the view that caches the cell states.
   */
  GraphView _view;

  /**
   * Holds the stylesheet that defines the appearance of the cells.
   */
  Stylesheet _stylesheet;

  /**
   * Holds the <mxGraphSelection> that models the current selection.
   */
  GraphSelectionModel _selectionModel;

  /**
   * Specifies the grid size. Default is 10.
   */
  int _gridSize = 10;

  /**
   * Specifies if the grid is enabled. Default is true.
   */
  bool _gridEnabled = true;

  /**
   * Specifies if ports are enabled. This is used in <cellConnected> to update
   * the respective style. Default is true.
   */
  bool _portsEnabled = true;

  /**
   * Value returned by getOverlap if isAllowOverlapParent returns
   * true for the given cell. getOverlap is used in keepInside if
   * isKeepInsideParentOnMove returns true. The value specifies the
   * portion of the child which is allowed to overlap the parent.
   */
  double _defaultOverlap = 0.5;

  /**
   * Specifies the default parent to be used to insert new cells.
   * This is used in getDefaultParent. Default is null.
   */
  Object _defaultParent;

  /**
   * Specifies the alternate edge style to be used if the main control point
   * on an edge is being doubleclicked. Default is null.
   */
  String _alternateEdgeStyle;

  /**
   * Specifies the return value for isEnabled. Default is true.
   */
  bool _enabled = true;

  /**
   * Specifies the return value for isCell(s)Locked. Default is false.
   */
  bool _cellsLocked = false;

  /**
   * Specifies the return value for isCell(s)Editable. Default is true.
   */
  bool _cellsEditable = true;

  /**
   * Specifies the return value for isCell(s)Sizable. Default is true.
   */
  bool _cellsResizable = true;

  /**
   * Specifies the return value for isCell(s)Movable. Default is true.
   */
  bool _cellsMovable = true;

  /**
   * Specifies the return value for isCell(s)Bendable. Default is true.
   */
  bool _cellsBendable = true;

  /**
   * Specifies the return value for isCell(s)Selectable. Default is true.
   */
  bool _cellsSelectable = true;

  /**
   * Specifies the return value for isCell(s)Deletable. Default is true.
   */
  bool _cellsDeletable = true;

  /**
   * Specifies the return value for isCell(s)Cloneable. Default is true.
   */
  bool _cellsCloneable = true;

  /**
   * Specifies the return value for isCellDisconntableFromTerminal. Default
   * is true.
   */
  bool _cellsDisconnectable = true;

  /**
   * Specifies the return value for isLabel(s)Clipped. Default is false.
   */
  bool _labelsClipped = false;

  /**
   * Specifies the return value for edges in isLabelMovable. Default is true.
   */
  bool _edgeLabelsMovable = true;

  /**
   * Specifies the return value for vertices in isLabelMovable. Default is false.
   */
  bool _vertexLabelsMovable = false;

  /**
   * Specifies the return value for isDropEnabled. Default is true.
   */
  bool _dropEnabled = true;

  /**
   * Specifies if dropping onto edges should be enabled. Default is true.
   */
  bool _splitEnabled = true;

  /**
   * Specifies if the graph should automatically update the cell size
   * after an edit. This is used in isAutoSizeCell. Default is false.
   */
  bool _autoSizeCells = false;

  /**
   * <Rect> that specifies the area in which all cells in the
   * diagram should be placed. Uses in getMaximumGraphBounds. Use a width
   * or height of 0 if you only want to give a upper, left corner.
   */
  Rect _maximumGraphBounds = null;

  /**
   * Rect that specifies the minimum size of the graph canvas inside
   * the scrollpane.
   */
  Rect _minimumGraphSize = null;

  /**
   * Border to be added to the bottom and right side when the container is
   * being resized after the graph has been changed. Default is 0.
   */
  int _border = 0;

  /**
   * Specifies if edges should appear in the foreground regardless of their
   * order in the model. This has precendence over keepEdgeInBackground
   * Default is false.
   */
  bool _keepEdgesInForeground = false;

  /**
   * Specifies if edges should appear in the background regardless of their
   * order in the model. Default is false.
   */
  bool _keepEdgesInBackground = false;

  /**
   * Specifies if the cell size should be changed to the preferred size when
   * a cell is first collapsed. Default is true.
   */
  bool _collapseToPreferredSize = true;

  /**
   * Specifies if negative coordinates for vertices are allowed. Default is true.
   */
  bool _allowNegativeCoordinates = true;

  /**
   * Specifies the return value for isConstrainChildren. Default is true.
   */
  bool _constrainChildren = true;

  /**
   * Specifies if a parent should contain the child bounds after a resize of
   * the child. Default is true.
   */
  bool _extendParents = true;

  /**
   * Specifies if parents should be extended according to the <extendParents>
   * switch if cells are added. Default is true.
   */
  bool _extendParentsOnAdd = true;

  /**
   * Specifies if the scale and translate should be reset if
   * the root changes in the model. Default is true.
   */
  bool _resetViewOnRootChange = true;

  /**
   * Specifies if loops (aka self-references) are allowed.
   * Default is false.
   */
  bool _resetEdgesOnResize = false;

  /**
   * Specifies if edge control points should be reset after
   * the move of a connected cell. Default is false.
   */
  bool _resetEdgesOnMove = false;

  /**
   * Specifies if edge control points should be reset after
   * the the edge has been reconnected. Default is true.
   */
  bool _resetEdgesOnConnect = true;

  /**
   * Specifies if loops (aka self-references) are allowed.
   * Default is false.
   */
  bool _allowLoops = false;

  /**
   * Specifies the multiplicities to be used for validation of the graph.
   */
  List<Multiplicity> _multiplicities;

  /**
   * Specifies the default style for loops.
   */
  EdgeStyleFunction _defaultLoopStyle = EdgeStyle.Loop;

  /**
   * Specifies if multiple edges in the same direction between
   * the same pair of vertices are allowed. Default is true.
   */
  bool _multigraph = true;

  /**
   * Specifies if edges are connectable. Default is false.
   * This overrides the connectable field in edges.
   */
  bool _connectableEdges = false;

  /**
   * Specifies if edges with disconnected terminals are
   * allowed in the graph. Default is false.
   */
  bool _allowDanglingEdges = true;

  /**
   * Specifies if edges that are cloned should be validated and only inserted
   * if they are valid. Default is true.
   */
  bool _cloneInvalidEdges = false;

  /**
   * Specifies if edges should be disconnected from their terminals when they
   * are moved. Default is true.
   */
  bool _disconnectOnMove = true;

  /**
   * Specifies if labels should be visible. This is used in
   * getLabel. Default is true.
   */
  bool _labelsVisible = true;

  /**
   * Specifies the return value for isHtmlLabel. Default is false.
   */
  bool _htmlLabels = false;

  /**
   * Specifies if nesting of swimlanes is allowed. Default is true.
   */
  bool _swimlaneNesting = true;

  /**
   * Specifies the maximum number of changes that should be processed to find
   * the dirty region. If the number of changes is larger, then the complete
   * grah is repainted. A value of zero will always compute the dirty region
   * for any number of changes. Default is 1000.
   */
  int _changesRepaintThreshold = 1000;

  /**
   * Specifies if the origin should be automatically updated. 
   */
  bool _autoOrigin = false;

  /**
   * Holds the current automatic origin.
   */
  Point2d _origin = new Point2d();

  /**
   * Holds the list of bundles.
   */
  static List<ImageBundle> _imageBundles = new /*Linked*/List<ImageBundle>();

  /**
   * Fires repaint events for full repaints.
   */
  IEventListener _fullRepaintHandler;

  /**
   * Fires repaint events for full repaints.
   */
  IEventListener _updateOriginHandler;

  /**
   * Fires repaint events for model changes.
   */
  IEventListener _graphModelChangeHandler;

  /**
   * Constructs a new graph with an empty
   * {@link graph.model.GraphModel}.
   */
  //	Graph()
  //	{
  //		this(null, null);
  //	}

  /**
   * Constructs a new graph for the specified model. If no model is
   * specified, then a new, empty {@link graph.model.GraphModel} is
   * used.
   * 
   * @param model Model that contains the graph data
   */
  //	Graph(IGraphModel model)
  //	{
  //		this(model, null);
  //	}

  /**
   * Constructs a new graph for the specified model. If no model is
   * specified, then a new, empty {@link graph.model.GraphModel} is
   * used.
   * 
   * @param stylesheet The stylesheet to use for the graph.
   */
  //	Graph(Stylesheet stylesheet)
  //	{
  //		this(null, stylesheet);
  //	}

  /**
   * Constructs a new graph for the specified model. If no model is
   * specified, then a new, empty {@link graph.model.GraphModel} is
   * used.
   * 
   * @param model Model that contains the graph data
   */
  Graph([IGraphModel model = null, Stylesheet stylesheet = null]) {
    _changeSupport = new PropertyChangeSupport(this);
    _fullRepaintHandler = (Object sender, EventObj evt) {
      repaint();
    };
    _updateOriginHandler = (Object sender, EventObj evt) {
      if (isAutoOrigin()) {
        _updateOrigin();
      }
    };
    _graphModelChangeHandler = (Object sender, EventObj evt) {
      Rect dirty = graphModelChanged(sender as IGraphModel, (evt.getProperty("edit") as UndoableEdit).getChanges() as List<UndoableChange>);
      repaint(dirty);
    };

    _selectionModel = _createSelectionModel();
    setModel((model != null) ? model : new GraphModel());
    setStylesheet((stylesheet != null) ? stylesheet : _createStylesheet());
    setView(_createGraphView());
  }

  /**
   * Constructs a new selection model to be used in this graph.
   */
  GraphSelectionModel _createSelectionModel() {
    return new GraphSelectionModel(this);
  }

  /**
   * Constructs a new stylesheet to be used in this graph.
   */
  Stylesheet _createStylesheet() {
    return new Stylesheet();
  }

  /**
   * Constructs a new view to be used in this graph.
   */
  GraphView _createGraphView() {
    return new GraphView(this);
  }

  /**
   * Returns the graph model that contains the graph data.
   * 
   * @return Returns the model that contains the graph data
   */
  IGraphModel getModel() {
    return _model;
  }

  /**
   * Sets the graph model that contains the data, and fires an
   * Event.CHANGE followed by an Event.REPAINT event.
   * 
   * @param value Model that contains the graph data
   */
  void setModel(IGraphModel value) {
    if (_model != null) {
      _model.removeListener(_graphModelChangeHandler);
    }

    Object oldModel = _model;
    _model = value;

    if (_view != null) {
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
  GraphView getView() {
    return _view;
  }

  /**
   * Sets the view that contains the cell states.
   * 
   * @param value View that contains the cell states
   */
  void setView(GraphView value) {
    if (_view != null) {
      _view.removeListener(_fullRepaintHandler);
      _view.removeListener(_updateOriginHandler);
    }

    Object oldView = _view;
    _view = value;

    if (_view != null) {
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
  Stylesheet getStylesheet() {
    return _stylesheet;
  }

  /**
   * Sets the stylesheet that provides the style.
   * 
   * @param value Stylesheet that provides the style.
   */
  void setStylesheet(Stylesheet value) {
    Stylesheet oldValue = _stylesheet;
    _stylesheet = value;

    _changeSupport.firePropertyChange("stylesheet", oldValue, _stylesheet);
  }

  /**
   * Returns the cells to be selected for the given list of changes.
   */
  List<Object> getSelectionCellsForChanges(List<UndoableChange> changes) {
    List<Object> cells = new List<Object>();
    Iterator<UndoableChange> it = changes.iterator;

    while (it.moveNext()) {
      Object change = it.current;

      if (change is ChildChange) {
        cells.add((change as ChildChange).getChild());
      } else if (change is TerminalChange) {
        cells.add((change as TerminalChange).getCell());
      } else if (change is ValueChange) {
        cells.add((change as ValueChange).getCell());
      } else if (change is StyleChange) {
        cells.add((change as StyleChange).getCell());
      } else if (change is GeometryChange) {
        cells.add((change as GeometryChange).getCell());
      } else if (change is CollapseChange) {
        cells.add((change as CollapseChange).getCell());
      } else if (change is VisibleChange) {
        VisibleChange vc = change as VisibleChange;

        if (vc.isVisible()) {
          cells.add((change as VisibleChange).getCell());
        }
      }
    }

    return GraphModel.getTopmostCells(_model, cells);
  }

  /**
   * Called when the graph model changes. Invokes processChange on each
   * item of the given array to update the view accordingly.
   */
  Rect graphModelChanged(IGraphModel sender, List<UndoableChange> changes) {
    int thresh = getChangesRepaintThreshold();
    bool ignoreDirty = thresh > 0 && changes.length > thresh;

    // Ignores dirty rectangle if there was a root change
    if (!ignoreDirty) {
      Iterator<UndoableChange> it = changes.iterator;

      while (it.moveNext()) {
        if (it.current is RootChange) {
          ignoreDirty = true;
          break;
        }
      }
    }

    Rect dirty = processChanges(changes, true, ignoreDirty);
    _view.validate();

    if (isAutoOrigin()) {
      _updateOrigin();
    }

    if (!ignoreDirty) {
      Rect tmp = processChanges(changes, false, ignoreDirty);

      if (tmp != null) {
        if (dirty == null) {
          dirty = tmp;
        } else {
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
  void _updateOrigin() {
    Rect bounds = getGraphBounds();

    if (bounds != null) {
      double scale = getView().getScale();
      double x = bounds.getX() / scale - getBorder();
      double y = bounds.getY() / scale - getBorder();

      if (x < 0 || y < 0) {
        double x0 = Math.min(0, x);
        double y0 = Math.min(0, y);

        _origin.setX(_origin.getX() + x0);
        _origin.setY(_origin.getY() + y0);

        Point2d t = getView().getTranslate();
        getView().setTranslate(new Point2d(t.getX() - x0, t.getY() - y0));
      } else if ((x > 0 || y > 0) && (_origin.getX() < 0 || _origin.getY() < 0)) {
        double dx = Math.min(-_origin.getX(), x);
        double dy = Math.min(-_origin.getY(), y);

        _origin.setX(_origin.getX() + dx);
        _origin.setY(_origin.getY() + dy);

        Point2d t = getView().getTranslate();
        getView().setTranslate(new Point2d(t.getX() - dx, t.getY() - dy));
      }
    }
  }

  /**
   * Returns the cells that have been removed from the model.
   */
  List<Object> getRemovedCellsForChanges(List<UndoableChange> changes) {
    List<Object> result = new List<Object>();
    Iterator<UndoableChange> it = changes.iterator;

    while (it.moveNext()) {
      Object change = it.current;

      if (change is RootChange) {
        break;
      } else if (change is ChildChange) {
        ChildChange cc = change as ChildChange;

        if (cc.getParent() == null) {
          result.addAll(GraphModel.getDescendants(_model, cc.getChild()));
        }
      } else if (change is VisibleChange) {
        Object cell = (change as VisibleChange).getCell();
        result.addAll(GraphModel.getDescendants(_model, cell));
      }
    }

    return result;
  }

  /**
   * Processes the changes and returns the minimal rectangle to be
   * repainted in the buffer. A return value of null means no repaint
   * is required.
   */
  Rect processChanges(List<UndoableChange> changes, bool invalidate, bool ignoreDirty) {
    Rect bounds = null;
    Iterator<UndoableChange> it = changes.iterator;

    while (it.moveNext()) {
      Rect rect = processChange(it.current, invalidate, ignoreDirty);

      if (bounds == null) {
        bounds = rect;
      } else {
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
  Rect processChange(UndoableChange change, bool invalidate, bool ignoreDirty) {
    Rect result = null;

    if (change is RootChange) {
      result = (ignoreDirty) ? null : getGraphBounds();

      if (invalidate) {
        clearSelection();
        _removeStateForCell((change as RootChange).getPrevious());

        if (isResetViewOnRootChange()) {
          _view.setEventsEnabled(false);

          try {
            _view.scaleAndTranslate(1.0, 0.0, 0.0);
          } finally {
            _view.setEventsEnabled(true);
          }
        }

      }

      fireEvent(new EventObj(Event.ROOT));
    } else if (change is ChildChange) {
      ChildChange cc = change as ChildChange;

      // Repaints the parent area if it is a rendered cell (vertex or
      // edge) otherwise only the child area is repainted, same holds
      // if the parent and previous are the same object, in which case
      // only the child area needs to be repainted (change of order)
      if (!ignoreDirty) {
        if (cc.getParent() != cc.getPrevious()) {
          if (_model.isVertex(cc.getParent()) || _model.isEdge(cc.getParent())) {
            result = getBoundingBox(cc.getParent(), true, true);
          }

          if (_model.isVertex(cc.getPrevious()) || _model.isEdge(cc.getPrevious())) {
            if (result != null) {
              result.add(getBoundingBox(cc.getPrevious(), true, true));
            } else {
              result = getBoundingBox(cc.getPrevious(), true, true);
            }
          }
        }

        if (result == null) {
          result = getBoundingBox(cc.getChild(), true, true);
        }
      }

      if (invalidate) {
        if (cc.getParent() != null) {
          _view.clear(cc.getChild(), false, true);
        } else {
          _removeStateForCell(cc.getChild());
        }
      }
    } else if (change is TerminalChange) {
      Object cell = (change as TerminalChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox(cell, true);
      }

      if (invalidate) {
        _view.invalidate(cell);
      }
    } else if (change is ValueChange) {
      Object cell = (change as ValueChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox(cell);
      }

      if (invalidate) {
        _view.clear(cell, false, false);
      }
    } else if (change is StyleChange) {
      Object cell = (change as StyleChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox(cell, true);
      }

      if (invalidate) {
        // TODO: Add includeEdges argument to clear method for
        // not having to call invalidate in this case (where it
        // is possible that the perimeter has changed, which
        // means the connected edges need to be invalidated)
        _view.clear(cell, false, false);
        _view.invalidate(cell);
      }
    } else if (change is GeometryChange) {
      Object cell = (change as GeometryChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox(cell, true, true);
      }

      if (invalidate) {
        _view.invalidate(cell);
      }
    } else if (change is CollapseChange) {
      Object cell = (change as CollapseChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox((change as CollapseChange).getCell(), true, true);
      }

      if (invalidate) {
        _removeStateForCell(cell);
      }
    } else if (change is VisibleChange) {
      Object cell = (change as VisibleChange).getCell();

      if (!ignoreDirty) {
        result = getBoundingBox((change as VisibleChange).getCell(), true, true);
      }

      if (invalidate) {
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
  void _removeStateForCell(Object cell) {
    int childCount = _model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
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
  Map<String, Object> getCellStyle(Object cell) {
    Map<String, Object> style = (_model.isEdge(cell)) ? _stylesheet.getDefaultEdgeStyle() : _stylesheet.getDefaultVertexStyle();

    String name = _model.getStyle(cell);

    if (name != null) {
      style = _postProcessCellStyle(_stylesheet.getCellStyle(name, style));
    }

    if (style == null) {
      style = Stylesheet.EMPTY_STYLE;
    }

    return style;
  }

  /**
   * Tries to resolve the value for the image style in the image bundles and
   * turns short data URIs as defined in ImageBundle to data URIs as
   * defined in RFC 2397 of the IETF.
   */
  Map<String, Object> _postProcessCellStyle(Map<String, Object> style) {
    if (style != null) {
      String key = Utils.getString(style, Constants.STYLE_IMAGE);
      String image = getImageFromBundles(key);

      if (image != null) {
        style[Constants.STYLE_IMAGE] = image;
      } else {
        image = key;
      }

      // Converts short data uris to normal data uris
      if (image != null && image.startsWith("data:image/")) {
        int comma = image.indexOf(',');

        if (comma > 0) {
          image = image.substring(0, comma) + ";base64," + image.substring(comma + 1);
        }

        style[Constants.STYLE_IMAGE] = image;
      }
    }

    return style;
  }

  /**
   * Sets the style of the selection cells to the given value.
   * 
   * @param style String representing the new style of the cells.
   */
  //	List<Object> setCellStyle(String style)
  //	{
  //		return setCellStyle(style, null);
  //	}

  /**
   * Sets the style of the specified cells. If no cells are given, then the
   * selection cells are changed.
   * 
   * @param style String representing the new style of the cells.
   * @param cells Optional array of <mxCells> to set the style for. Default is the
   * selection cells.
   */
  List<Object> setCellStyle(String style, [List<Object> cells = null]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    if (cells != null) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          _model.setStyle(cells[i], style);
        }
      } finally {
        _model.endUpdate();
      }
    }

    return cells;
  }

  /**
   * Toggles the bool value for the given key in the style of the
   * given cell. If no cell is specified then the selection cell is
   * used.
   * 
   * @param key Key for the bool value to be toggled.
   * @param defaultValue Default bool value if no value is defined.
   * @param cell Cell whose style should be modified.
   */
  Object toggleCellStyle(String key, bool defaultValue, Object cell) {
    return toggleCellStyles(key, defaultValue, [cell])[0];
  }

  /**
   * Toggles the bool value for the given key in the style of the
   * selection cells.
   * 
   * @param key Key for the bool value to be toggled.
   * @param defaultValue Default bool value if no value is defined.
   */
  //	List<Object> toggleCellStyles(String key, bool defaultValue)
  //	{
  //		return toggleCellStyles(key, defaultValue, null);
  //	}

  /**
   * Toggles the bool value for the given key in the style of the given
   * cells. If no cells are specified, then the selection cells are used. For
   * example, this can be used to toggle Constants.STYLE_ROUNDED or any
   * other style with a bool value.
   * 
   * @param key String representing the key of the bool style to be toggled.
   * @param defaultValue Default bool value if no value is defined.
   * @param cells Cells whose styles should be modified.
   */
  List<Object> toggleCellStyles(String key, bool defaultValue, [List<Object> cells = null]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    if (cells != null && cells.length > 0) {
      CellState state = _view.getState(cells[0]);
      Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cells[0]);

      if (style != null) {
        String value = (Utils.isTrue(style, key, defaultValue)) ? "0" : "1";
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
  //	List<Object> setCellStyles(String key, String value)
  //	{
  //		return setCellStyles(key, value, null);
  //	}

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
  List<Object> setCellStyles(String key, String value, [List<Object> cells = null]) {
    if (cells == null) {
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
   * @param flag int that represents the bit to be toggled.
   */
  //	List<Object> toggleCellStyleFlags(String key, int flag)
  //	{
  //		return toggleCellStyleFlags(key, flag, null);
  //	}

  /**
   * Toggles the given bit for the given key in the styles of the specified
   * cells.
   * 
   * @param key String representing the key to toggle the flag in.
   * @param flag int that represents the bit to be toggled.
   * @param cells Optional array of <mxCells> to change the style for. Default is
   * the selection cells.
   */
  List<Object> toggleCellStyleFlags(String key, int flag, [List<Object> cells = null]) {
    return setCellStyleFlags(key, flag, null, cells);
  }

  /**
   * Sets or toggles the given bit for the given key in the styles of the
   * selection cells.
   * 
   * @param key String representing the key to toggle the flag in.
   * @param flag int that represents the bit to be toggled.
   * @param value bool value to be used or null if the value should be
   * toggled.
   */
  //	List<Object> setCellStyleFlags(String key, int flag, bool value)
  //	{
  //		return setCellStyleFlags(key, flag, value, null);
  //	}

  /**
   * Sets or toggles the given bit for the given key in the styles of the
   * specified cells.
   * 
   * @param key String representing the key to toggle the flag in.
   * @param flag int that represents the bit to be toggled.
   * @param value bool value to be used or null if the value should be
   * toggled.
   * @param cells Optional array of cells to change the style for. If no
   * cells are specified then the selection cells are used.
   */
  List<Object> setCellStyleFlags(String key, int flag, bool value, [List<Object> cells = null]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    if (cells != null && cells.length > 0) {
      if (value == null) {
        CellState state = _view.getState(cells[0]);
        Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cells[0]);

        if (style != null) {
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
  void addImageBundle(ImageBundle bundle) {
    _imageBundles.add(bundle);
  }

  /**
   * Removes the specified bundle.
   */
  void removeImageBundle(ImageBundle bundle) {
    _imageBundles.remove(bundle);
  }

  /**
   * Searches all bundles for the specified key and returns the value for the
   * first match or null if the key is not found.
   */
  String getImageFromBundles(String key) {
    if (key != null) {
      Iterator<ImageBundle> it = _imageBundles.iterator;

      while (it.moveNext()) {
        String value = it.current.getImage(key);

        if (value != null) {
          return value;
        }
      }
    }

    return null;
  }

  /**
   * Returns the image bundles
   */
  List<ImageBundle> getImageBundles() {
    return _imageBundles;
  }

  /**
   * Returns the image bundles
   */
  void setImageBundles(List<ImageBundle> value) {
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
  //	List<Object> alignCells(String align)
  //	{
  //		return alignCells(align, null);
  //	}

  /**
   * Aligns the given cells vertically or horizontally according to the given
   * alignment.
   * 
   * @param align Specifies the alignment. Possible values are all constants
   * in Constants with an ALIGN prefix.
   * @param cells Array of cells to be aligned.
   */
  //	List<Object> alignCells(String align, List<Object> cells)
  //	{
  //		return alignCells(align, cells, null);
  //	}

  /**
   * Aligns the given cells vertically or horizontally according to the given
   * alignment using the optional parameter as the coordinate.
   * 
   * @param align Specifies the alignment. Possible values are all constants
   * in Constants with an ALIGN prefix.
   * @param cells Array of cells to be aligned.
   * @param param Optional coordinate for the alignment.
   */
  List<Object> alignCells(String align, [List<Object> cells = null, Object param = null]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    if (cells != null && cells.length > 1) {
      // Finds the required coordinate for the alignment
      if (param == null) {
        for (int i = 0; i < cells.length; i++) {
          Geometry geo = getCellGeometry(cells[i]);

          if (geo != null && !_model.isEdge(cells[i])) {
            if (param == null) {
              if (align == null || align == Constants.ALIGN_LEFT) {
                param = geo.getX();
              } else if (align == Constants.ALIGN_CENTER) {
                param = geo.getX() + geo.getWidth() / 2;
                break;
              } else if (align == Constants.ALIGN_RIGHT) {
                param = geo.getX() + geo.getWidth();
              } else if (align == Constants.ALIGN_TOP) {
                param = geo.getY();
              } else if (align == Constants.ALIGN_MIDDLE) {
                param = geo.getY() + geo.getHeight() / 2;
                break;
              } else if (align == Constants.ALIGN_BOTTOM) {
                param = geo.getY() + geo.getHeight();
              }
            } else {
              double tmp = double.parse(param.toString());

              if (align == null || align == Constants.ALIGN_LEFT) {
                param = Math.min(tmp, geo.getX());
              } else if (align == Constants.ALIGN_RIGHT) {
                param = Math.max(tmp, geo.getX() + geo.getWidth());
              } else if (align == Constants.ALIGN_TOP) {
                param = Math.min(tmp, geo.getY());
              } else if (align == Constants.ALIGN_BOTTOM) {
                param = Math.max(tmp, geo.getY() + geo.getHeight());
              }
            }
          }
        }
      }

      // Aligns the cells to the coordinate
      _model.beginUpdate();
      try {
        double tmp = double.parse(param.toString());

        for (int i = 0; i < cells.length; i++) {
          Geometry geo = getCellGeometry(cells[i]);

          if (geo != null && !_model.isEdge(cells[i])) {
            geo = geo.clone() as Geometry;

            if (align == null || align == Constants.ALIGN_LEFT) {
              geo.setX(tmp);
            } else if (align == Constants.ALIGN_CENTER) {
              geo.setX(tmp - geo.getWidth() / 2);
            } else if (align == Constants.ALIGN_RIGHT) {
              geo.setX(tmp - geo.getWidth());
            } else if (align == Constants.ALIGN_TOP) {
              geo.setY(tmp);
            } else if (align == Constants.ALIGN_MIDDLE) {
              geo.setY(tmp - geo.getHeight() / 2);
            } else if (align == Constants.ALIGN_BOTTOM) {
              geo.setY(tmp - geo.getHeight());
            }

            _model.setGeometry(cells[i], geo);

            if (isResetEdgesOnMove()) {
              resetEdges([cells[i]]);
            }
          }
        }

        fireEvent(new EventObj(Event.ALIGN_CELLS, ["cells", cells, "align", align]));
      } finally {
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
  Object flipEdge(Object edge) {
    if (edge != null && _alternateEdgeStyle != null) {
      _model.beginUpdate();
      try {
        String style = _model.getStyle(edge);

        if (style == null || style.length == 0) {
          _model.setStyle(edge, _alternateEdgeStyle);
        } else {
          _model.setStyle(edge, null);
        }

        // Removes all existing control points
        resetEdge(edge);
        fireEvent(new EventObj(Event.FLIP_EDGE, ["edge", edge]));
      } finally {
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
  //	List<Object> orderCells(bool back)
  //	{
  //		return orderCells(back, null);
  //	}

  /**
   * Moves the given cells to the front or back. The change is carried out
   * using cellsOrdered. This method fires Event.ORDER_CELLS while the
   * transaction is in progress.
   * 
   * @param back Specifies if the cells should be moved to back.
   * @param cells Array of cells whose order should be changed. If null is
   * specified then the selection cells are used.
   */
  List<Object> orderCells(bool back, [List<Object> cells = null]) {
    if (cells == null) {
      cells = Utils.sortCells(getSelectionCells(), true);
    }

    _model.beginUpdate();
    try {
      cellsOrdered(cells, back);
      fireEvent(new EventObj(Event.ORDER_CELLS, ["cells", cells, "back", back]));
    } finally {
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
  void cellsOrdered(List<Object> cells, bool back) {
    if (cells != null) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          Object parent = _model.getParent(cells[i]);

          if (back) {
            _model.add(parent, cells[i], i);
          } else {
            _model.add(parent, cells[i], _model.getChildCount(parent) - 1);
          }
        }

        fireEvent(new EventObj(Event.CELLS_ORDERED, ["cells", cells, "back", back]));
      } finally {
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
  //	Object groupCells()
  //	{
  //		return groupCells(null);
  //	}

  /**
   * Groups the selection cells and adds them to the given group. This is a
   * shortcut method.
   * 
   * @return Returns the new group.
   */
  //	Object groupCells(Object group)
  //	{
  //		return groupCells(group, 0);
  //	}

  /**
   * Groups the selection cells and adds them to the given group. This is a
   * shortcut method.
   * 
   * @return Returns the new group.
   */
  //	Object groupCells([Object group=null, double border=0.0])
  //	{
  //		return groupCells(group, border, null);
  //	}

  /**
   * Adds the cells into the given group. The change is carried out using
   * cellsAdded, cellsMoved and cellsResized. This method fires
   * Event.GROUP_CELLS while the transaction is in progress. Returns the
   * new group. A group is only created if there is at least one entry in the
   * given array of cells.
   * 
   * @param group Cell that represents the target group. If null is specified
   * then a new group is created using createGroupCell.
   * @param border int that specifies the border between the child area
   * and the group bounds.
   * @param cells Optional array of cells to be grouped. If null is specified
   * then the selection cells are used.
   */
  Object groupCells([Object group = null, double border = 0.0, List<Object> cells = null]) {
    if (cells == null) {
      cells = Utils.sortCells(getSelectionCells(), true);
    }

    cells = getCellsForGroup(cells);

    if (group == null) {
      group = createGroupCell(cells);
    }

    Rect bounds = getBoundsForGroup(group, cells, border);

    if (cells.length > 0 && bounds != null) {
      // Uses parent of group or previous parent of first child
      Object parent = _model.getParent(group);

      if (parent == null) {
        parent = _model.getParent(cells[0]);
      }

      _model.beginUpdate();
      try {
        // Checks if the group has a geometry and
        // creates one if one does not exist
        if (getCellGeometry(group) == null) {
          _model.setGeometry(group, new Geometry());
        }

        // Adds the children into the group and moves
        int index = _model.getChildCount(group);
        cellsAdded(cells, group, index, null, null, false);
        cellsMoved(cells, -bounds.getX(), -bounds.getY(), false, true);

        // Adds the group into the parent and resizes
        index = _model.getChildCount(parent);
        cellsAdded([group], parent, index, null, null, false, false);
        cellsResized([group], [bounds]);

        fireEvent(new EventObj(Event.GROUP_CELLS, ["group", group, "cells", cells, "border", border]));
      } finally {
        _model.endUpdate();
      }
    }

    return group;
  }

  /**
   * Returns the cells with the same parent as the first cell
   * in the given array.
   */
  List<Object> getCellsForGroup(List<Object> cells) {
    List<Object> result = new List<Object>(cells.length);

    if (cells.length > 0) {
      Object parent = _model.getParent(cells[0]);
      result.add(cells[0]);

      // Filters selection cells with the same parent
      for (int i = 1; i < cells.length; i++) {
        if (_model.getParent(cells[i]) == parent) {
          result.add(cells[i]);
        }
      }
    }

    return result;
  }

  /**
   * Returns the bounds to be used for the given group and children. This
   * implementation computes the bounding box of the geometries of all
   * vertices in the given children array. Edges are ignored. If the group
   * cell is a swimlane the title region is added to the bounds.
   */
  Rect getBoundsForGroup(Object group, List<Object> children, double border) {
    Rect result = getBoundingBoxFromGeometry(children);

    if (result != null) {
      if (isSwimlane(group)) {
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
  Object createGroupCell(List<Object> cells) {
    Cell group = new Cell("", new Geometry(), null);
    group.setVertex(true);
    group.setConnectable(false);

    return group;
  }

  /**
   * Ungroups the selection cells. This is a shortcut method.
   */
  //	List<Object> ungroupCells()
  //	{
  //		return ungroupCells(null);
  //	}

  /**
   * Ungroups the given cells by moving the children the children to their
   * parents parent and removing the empty groups.
   * 
   * @param cells Array of cells to be ungrouped. If null is specified then
   * the selection cells are used.
   * @return Returns the children that have been removed from the groups.
   */
  List<Object> ungroupCells([List<Object> cells = null]) {
    List<Object> result = new List<Object>();

    if (cells == null) {
      cells = getSelectionCells();

      // Finds the cells with children
      List<Object> tmp = new List<Object>(cells.length);

      for (int i = 0; i < cells.length; i++) {
        if (_model.getChildCount(cells[i]) > 0) {
          tmp.add(cells[i]);
        }
      }

      cells = tmp;
    }

    if (cells != null && cells.length > 0) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          List<Object> children = GraphModel.getChildren(_model, cells[i]);

          if (children != null && children.length > 0) {
            Object parent = _model.getParent(cells[i]);
            int index = _model.getChildCount(parent);

            cellsAdded(children, parent, index, null, null, true);
            result.addAll(children);
          }
        }

        cellsRemoved(addAllEdges(cells));
        fireEvent(new EventObj(Event.UNGROUP_CELLS, ["cells", cells]));
      } finally {
        _model.endUpdate();
      }
    }

    return result;
  }

  /**
   * Removes the selection cells from their parents and adds them to the
   * default parent returned by getDefaultParent.
   */
  //	List<Object> removeCellsFromParent()
  //	{
  //		return removeCellsFromParent(null);
  //	}

  /**
   * Removes the specified cells from their parents and adds them to the
   * default parent.
   * 
   * @param cells Array of cells to be removed from their parents.
   * @return Returns the cells that were removed from their parents.
   */
  List<Object> removeCellsFromParent([List<Object> cells = null]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    _model.beginUpdate();
    try {
      Object parent = getDefaultParent();
      int index = _model.getChildCount(parent);

      cellsAdded(cells, parent, index, null, null, true);
      fireEvent(new EventObj(Event.REMOVE_CELLS_FROM_PARENT, ["cells", cells]));
    } finally {
      _model.endUpdate();
    }

    return cells;
  }

  /**
   * Updates the bounds of the given array of groups so that it includes
   * all child vertices.
   */
  //	List<Object> updateGroupBounds()
  //	{
  //		return updateGroupBounds(null);
  //	}

  /**
   * Updates the bounds of the given array of groups so that it includes
   * all child vertices.
   * 
   * @param cells The groups whose bounds should be updated.
   */
  //	List<Object> updateGroupBounds(List<Object> cells)
  //	{
  //		return updateGroupBounds(cells, 0);
  //	}

  /**
   * Updates the bounds of the given array of groups so that it includes
   * all child vertices.
   * 
   * @param cells The groups whose bounds should be updated.
   * @param border The border to be added in the group.
   */
  //	List<Object> updateGroupBounds(List<Object> cells, [int border=0])
  //	{
  //		return updateGroupBounds(cells, border, false);
  //	}

  /**
   * Updates the bounds of the given array of groups so that it includes
   * all child vertices.
   * 
   * @param cells The groups whose bounds should be updated.
   * @param border The border to be added in the group.
   * @param moveParent Specifies if the group should be moved.
   */
  List<Object> updateGroupBounds([List<Object> cells = null, int border = 0, bool moveParent = false]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    _model.beginUpdate();
    try {
      for (int i = 0; i < cells.length; i++) {
        Geometry geo = getCellGeometry(cells[i]);

        if (geo != null) {
          List<Object> children = getChildCells(cells[i]);

          if (children != null && children.length > 0) {
            Rect childBounds = getBoundingBoxFromGeometry(children);

            if (childBounds.getWidth() > 0 && childBounds.getHeight() > 0) {
              Rect size = (isSwimlane(cells[i])) ? getStartSize(cells[i]) : new Rect();

              geo = geo.clone() as Geometry;

              if (moveParent) {
                geo.setX(geo.getX() + childBounds.getX() - size.getWidth() - border);
                geo.setY(geo.getY() + childBounds.getY() - size.getHeight() - border);
              }

              geo.setWidth(childBounds.getWidth() + size.getWidth() + 2 * border);
              geo.setHeight(childBounds.getHeight() + size.getHeight() + 2 * border);

              _model.setGeometry(cells[i], geo);
              moveCells(children, -childBounds.getX() + size.getWidth() + border, -childBounds.getY() + size.getHeight() + border);
            }
          }
        }
      }
    } finally {
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
   * graph2.addCells(graph.cloneCells(new List<Object> { parent }));
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
  //	List<Object> cloneCells(List<Object> cells)
  //	{
  //
  //		return cloneCells(cells, true);
  //	}

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
  List<Object> cloneCells(List<Object> cells, [bool allowInvalidEdges = true]) {
    List<Object> clones = null;

    if (cells != null) {
      Iterable<Object> tmp = new LinkedHashSet<Object>.from(cells);

      if (tmp.length > 0) {
        double scale = _view.getScale();
        Point2d trans = _view.getTranslate();
        clones = _model.cloneCells(cells, true);

        for (int i = 0; i < cells.length; i++) {
          if (!allowInvalidEdges && _model.isEdge(clones[i]) && getEdgeValidationError(clones[i], _model.getTerminal(clones[i], true), _model.getTerminal(clones[i], false)) != null) {
            clones[i] = null;
          } else {
            Geometry g = _model.getGeometry(clones[i]);

            if (g != null) {
              CellState state = _view.getState(cells[i]);
              CellState pstate = _view.getState(_model.getParent(cells[i]));

              if (state != null && pstate != null) {
                double dx = pstate.getOrigin().getX();
                double dy = pstate.getOrigin().getY();

                if (_model.isEdge(clones[i])) {
                  // Checks if the source is cloned or sets the terminal point
                  Object src = _model.getTerminal(cells[i], true);

                  while (src != null && !tmp.contains(src)) {
                    src = _model.getParent(src);
                  }

                  if (src == null) {
                    Point2d pt = state.getAbsolutePoint(0);
                    g.setTerminalPoint(new Point2d(pt.getX() / scale - trans.getX(), pt.getY() / scale - trans.getY()), true);
                  }

                  // Checks if the target is cloned or sets the terminal point
                  Object trg = _model.getTerminal(cells[i], false);

                  while (trg != null && !tmp.contains(trg)) {
                    trg = _model.getParent(trg);
                  }

                  if (trg == null) {
                    Point2d pt = state.getAbsolutePoint(state.getAbsolutePointCount() - 1);
                    g.setTerminalPoint(new Point2d(pt.getX() / scale - trans.getX(), pt.getY() / scale - trans.getY()), false);
                  }

                  // Translates the control points
                  List<Point2d> points = g.getPoints();

                  if (points != null) {
                    Iterator<Point2d> it = points.iterator;

                    while (it.moveNext()) {
                      Point2d pt = it.current;
                      pt.setX(pt.getX() + dx);
                      pt.setY(pt.getY() + dy);
                    }
                  }
                } else {
                  g.setX(g.getX() + dx);
                  g.setY(g.getY() + dy);
                }
              }
            }
          }
        }
      } else {
        clones = new List<Object>();
      }
    }

    return clones;
  }

  /**
   * Creates and adds a new vertex with an empty style.
   */
  //	Object insertVertex(Object parent, String id, Object value,
  //			double x, double y, double width, double height)
  //	{
  //		return insertVertex(parent, id, value, x, y, width, height, null);
  //	}

  /**
   * Adds a new vertex into the given parent using value as the user object
   * and the given coordinates as the geometry of the new vertex. The id and
   * style are used for the respective properties of the new cell, which is
   * returned.
   * 
   * @param parent Cell that specifies the parent of the new vertex.
   * @param id Optional string that defines the Id of the new vertex.
   * @param value Object to be used as the user object.
   * @param x int that defines the x coordinate of the vertex.
   * @param y int that defines the y coordinate of the vertex.
   * @param width int that defines the width of the vertex.
   * @param height int that defines the height of the vertex.
   * @param style Optional string that defines the cell style.
   * @return Returns the new vertex that has been inserted.
   */
  //	Object insertVertex(Object parent, String id, Object value,
  //			double x, double y, double width, double height, String style)
  //	{
  //		return insertVertex(parent, id, value, x, y, width, height, style,
  //				false);
  //	}

  /**
   * Adds a new vertex into the given parent using value as the user object
   * and the given coordinates as the geometry of the new vertex. The id and
   * style are used for the respective properties of the new cell, which is
   * returned.
   * 
   * @param parent Cell that specifies the parent of the new vertex.
   * @param id Optional string that defines the Id of the new vertex.
   * @param value Object to be used as the user object.
   * @param x int that defines the x coordinate of the vertex.
   * @param y int that defines the y coordinate of the vertex.
   * @param width int that defines the width of the vertex.
   * @param height int that defines the height of the vertex.
   * @param style Optional string that defines the cell style.
   * @param relative Specifies if the geometry should be relative.
   * @return Returns the new vertex that has been inserted.
   */
  Object insertVertex(Object parent, String id, Object value, double x, double y, double width, double height, [String style = null, bool relative = false]) {
    Object vertex = createVertex(parent, id, value, x, y, width, height, style, relative);

    return addCell(vertex, parent);
  }

  /**
   * Hook method that creates the new vertex for insertVertex.
   * 
   * @param parent Cell that specifies the parent of the new vertex.
   * @param id Optional string that defines the Id of the new vertex.
   * @param value Object to be used as the user object.
   * @param x int that defines the x coordinate of the vertex.
   * @param y int that defines the y coordinate of the vertex.
   * @param width int that defines the width of the vertex.
   * @param height int that defines the height of the vertex.
   * @param style Optional string that defines the cell style.
   * @return Returns the new vertex to be inserted.
   */
  //	Object createVertex(Object parent, String id, Object value,
  //			double x, double y, double width, double height, String style)
  //	{
  //		return createVertex(parent, id, value, x, y, width, height, style,
  //				false);
  //	}

  /**
   * Hook method that creates the new vertex for insertVertex.
   * 
   * @param parent Cell that specifies the parent of the new vertex.
   * @param id Optional string that defines the Id of the new vertex.
   * @param value Object to be used as the user object.
   * @param x int that defines the x coordinate of the vertex.
   * @param y int that defines the y coordinate of the vertex.
   * @param width int that defines the width of the vertex.
   * @param height int that defines the height of the vertex.
   * @param style Optional string that defines the cell style.
   * @param relative Specifies if the geometry should be relative.
   * @return Returns the new vertex to be inserted.
   */
  Object createVertex(Object parent, String id, Object value, double x, double y, double width, double height, String style, [bool relative = false]) {
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
  //	Object insertEdge(Object parent, String id, Object value,
  //			Object source, Object target)
  //	{
  //		return insertEdge(parent, id, value, source, target, null);
  //	}

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
  Object insertEdge(Object parent, String id, Object value, Object source, Object target, [String style = null]) {
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
  Object createEdge(Object parent, String id, Object value, Object source, Object target, String style) {
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
  Object addEdge(Object edge, Object parent, Object source, Object target, int index) {
    return addCell(edge, parent, index, source, target);
  }

  /**
   * Adds the cell to the default parent. This is a shortcut method.
   * 
   * @param cell Cell to be inserted.
   * @return Returns the cell that was added.
   */
  //	Object addCell(Object cell)
  //	{
  //		return addCell(cell, null);
  //	}

  /**
   * Adds the cell to the parent. This is a shortcut method.
   * 
   * @param cell Cell tobe inserted.
   * @param parent Object that represents the new parent. If no parent is
   * given then the default parent is used.
   * @return Returns the cell that was added.
   */
  //	Object addCell(Object cell, Object parent)
  //	{
  //		return addCell(cell, parent, null, null, null);
  //	}

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
  Object addCell(Object cell, [Object parent=null, int index = null, Object source = null, Object target = null]) {
    return addCells([cell], parent, index, source, target)[0];
  }

  /**
   * Adds the cells to the default parent. This is a shortcut method.
   * 
   * @param cells Array of cells to be inserted.
   * @return Returns the cells that were added.
   */
  //	List<Object> addCells(List<Object> cells)
  //	{
  //		return addCells(cells, null);
  //	}

  /**
   * Adds the cells to the parent. This is a shortcut method.
   * 
   * @param cells Array of cells to be inserted.
   * @param parent Optional cell that represents the new parent. If no parent
   * is specified then the default parent is used.
   * @return Returns the cells that were added.
   */
  //	List<Object> addCells(List<Object> cells, Object parent)
  //	{
  //		return addCells(cells, parent, null);
  //	}

  /**
   * Adds the cells to the parent at the given index. This is a shortcut method.
   * 
   * @param cells Array of cells to be inserted.
   * @param parent Optional cell that represents the new parent. If no parent
   * is specified then the default parent is used.
   * @param index Optional index to insert the cells at. Default is to append.
   * @return Returns the cells that were added.
   */
  //	List<Object> addCells(List<Object> cells, Object parent, int index)
  //	{
  //		return addCells(cells, parent, index, null, null);
  //	}

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
  List<Object> addCells(List<Object> cells, [Object parent = null, int index = null, Object source = null, Object target = null]) {
    if (parent == null) {
      parent = getDefaultParent();
    }

    if (index == null) {
      index = _model.getChildCount(parent);
    }

    _model.beginUpdate();
    try {
      cellsAdded(cells, parent, index, source, target, false, true);
      fireEvent(new EventObj(Event.ADD_CELLS, ["cells", cells, "parent", parent, "index", index, "source", source, "target", target]));
    } finally {
      _model.endUpdate();
    }

    return cells;
  }
  /**
   * Adds the specified cells to the given parent. This method fires
   * Event.CELLS_ADDED while the transaction is in progress.
   */
  //	void cellsAdded(List<Object> cells, Object parent, int index,
  //			Object source, Object target, bool absolute)
  //	{
  //		cellsAdded(cells, parent, index, source, target, absolute, true);
  //	}

  /**
   * Adds the specified cells to the given parent. This method fires
   * Event.CELLS_ADDED while the transaction is in progress.
   */
  void cellsAdded(List<Object> cells, Object parent, int index, Object source, Object target, bool absolute, [bool constrain = true]) {
    if (cells != null && parent != null && index != null) {
      _model.beginUpdate();
      try {
        CellState parentState = (absolute) ? _view.getState(parent) : null;
        Point2d o1 = (parentState != null) ? parentState.getOrigin() : null;
        Point2d zero = new Point2d(0.0, 0.0);

        for (int i = 0; i < cells.length; i++) {
          if (cells[i] == null) {
            index--;
          } else {
            Object previous = _model.getParent(cells[i]);

            // Keeps the cell at its absolute location
            if (o1 != null && cells[i] != parent && parent != previous) {
              CellState oldState = _view.getState(previous);
              Point2d o2 = (oldState != null) ? oldState.getOrigin() : zero;
              Geometry geo = _model.getGeometry(cells[i]);

              if (geo != null) {
                double dx = o2.getX() - o1.getX();
                double dy = o2.getY() - o1.getY();

                geo = geo.clone() as Geometry;
                geo.translate(dx, dy);

                if (!geo.isRelative() && _model.isVertex(cells[i]) && !isAllowNegativeCoordinates()) {
                  geo.setX(Math.max(0, geo.getX()));
                  geo.setY(Math.max(0, geo.getY()));
                }

                _model.setGeometry(cells[i], geo);
              }
            }

            // Decrements all following indices
            // if cell is already in parent
            if (parent == previous) {
              index--;
            }

            _model.add(parent, cells[i], index + i);

            // Extends the parent
            if (isExtendParentsOnAdd() && isExtendParent(cells[i])) {
              extendParent(cells[i]);
            }

            // Constrains the child
            if (constrain) {
              constrainChild(cells[i]);
            }

            // Sets the source terminal
            if (source != null) {
              cellConnected(cells[i], source, true, null);
            }

            // Sets the target terminal
            if (target != null) {
              cellConnected(cells[i], target, false, null);
            }
          }
        }

        fireEvent(new EventObj(Event.CELLS_ADDED, ["cells", cells, "parent", parent, "index", index, "source", source, "target", target, "absolute", absolute]));

      } finally {
        _model.endUpdate();
      }
    }
  }

  /**
   * Removes the selection cells from the graph.
   * 
   * @return Returns the cells that have been removed.
   */
  //	List<Object> removeCells()
  //	{
  //		return removeCells(null);
  //	}

  /**
   * Removes the given cells from the graph.
   * 
   * @param cells Array of cells to remove.
   * @return Returns the cells that have been removed.
   */
  //	List<Object> removeCells([List<Object> cells=null])
  //	{
  //		return removeCells(cells, true);
  //	}

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
  List<Object> removeCells(List<Object> cells, [bool includeEdges = true]) {
    if (cells == null) {
      cells = getDeletableCells(getSelectionCells());
    }

    // Adds all edges to the cells
    if (includeEdges) {
      cells = getDeletableCells(addAllEdges(cells));
    }

    _model.beginUpdate();
    try {
      cellsRemoved(cells);
      fireEvent(new EventObj(Event.REMOVE_CELLS, ["cells", cells, "includeEdges", includeEdges]));
    } finally {
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
  void cellsRemoved(List<Object> cells) {
    if (cells != null && cells.length > 0) {
      double scale = _view.getScale();
      Point2d tr = _view.getTranslate();

      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          // Disconnects edges which are not in cells
          /*Collection*/Set<Object> cellSet = new HashSet<Object>();
          cellSet.addAll(cells);
          List<Object> edges = getConnections(cells[i]);

          for (int j = 0; j < edges.length; j++) {
            if (!cellSet.contains(edges[j])) {
              Geometry geo = _model.getGeometry(edges[j]);

              if (geo != null) {
                CellState state = _view.getState(edges[j]);

                if (state != null) {
                  geo = geo.clone() as Geometry;
                  bool source = state.getVisibleTerminal(true) == cells[i];
                  int n = (source) ? 0 : state.getAbsolutePointCount() - 1;
                  Point2d pt = state.getAbsolutePoint(n);

                  geo.setTerminalPoint(new Point2d(pt.getX() / scale - tr.getX(), pt.getY() / scale - tr.getY()), source);
                  _model.setTerminal(edges[j], null, source);
                  _model.setGeometry(edges[j], geo);
                }
              }
            }
          }

          _model.remove(cells[i]);
        }

        fireEvent(new EventObj(Event.CELLS_REMOVED, ["cells", cells]));
      } finally {
        _model.endUpdate();
      }
    }
  }

  //	Object splitEdge(Object edge, List<Object> cells)
  //	{
  //		return splitEdge(edge, cells, null, 0, 0);
  //	}

  //	Object splitEdge(Object edge, List<Object> cells, [double dx=0.0, double dy=0.0])
  //	{
  //		return splitEdge(edge, cells, null, dx, dy);
  //	}

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
  Object splitEdge(Object edge, List<Object> cells, [Object newEdge = null, double dx = 0.0, double dy = 0.0]) {
    if (newEdge == null) {
      newEdge = cloneCells([edge])[0];
    }

    Object parent = _model.getParent(edge);
    Object source = _model.getTerminal(edge, true);

    _model.beginUpdate();
    try {
      cellsMoved(cells, dx, dy, false, false);
      cellsAdded(cells, parent, _model.getChildCount(parent), null, null, true);
      cellsAdded([newEdge], parent, _model.getChildCount(parent), source, cells[0], false);
      cellConnected(edge, cells[0], true, null);
      fireEvent(new EventObj(Event.SPLIT_EDGE, ["edge", edge, "cells", cells, "newEdge", newEdge, "dx", dx, "dy", dy]));
    } finally {
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
   * @param show bool that specifies the visible state to be assigned.
   * @return Returns the cells whose visible state was changed.
   */
  //	List<Object> toggleCells(bool show)
  //	{
  //		return toggleCells(show, null);
  //	}

  /**
   * Sets the visible state of the specified cells. This is a shortcut
   * method.
   *
   * @param show bool that specifies the visible state to be assigned.
   * @param cells Array of cells whose visible state should be changed.
   * @return Returns the cells whose visible state was changed.
   */
  //	List<Object> toggleCells(bool show, List<Object> cells)
  //	{
  //		return toggleCells(show, cells, true);
  //	}

  /**
   * Sets the visible state of the specified cells and all connected edges
   * if includeEdges is true. The change is carried out using cellsToggled.
   * This method fires Event.TOGGLE_CELLS while the transaction is in
   * progress.
   *
   * @param show bool that specifies the visible state to be assigned.
   * @param cells Array of cells whose visible state should be changed. If
   * null is specified then the selection cells are used.
   * @return Returns the cells whose visible state was changed.
   */
  List<Object> toggleCells(bool show, [List<Object> cells = null, bool includeEdges = true]) {
    if (cells == null) {
      cells = getSelectionCells();
    }

    // Adds all connected edges recursively
    if (includeEdges) {
      cells = addAllEdges(cells);
    }

    _model.beginUpdate();
    try {
      cellsToggled(cells, show);
      fireEvent(new EventObj(Event.TOGGLE_CELLS, ["show", show, "cells", cells, "includeEdges", includeEdges]));
    } finally {
      _model.endUpdate();
    }

    return cells;
  }

  /**
   * Sets the visible state of the specified cells.
   * 
   * @param cells Array of cells whose visible state should be changed.
   * @param show bool that specifies the visible state to be assigned.
   */
  void cellsToggled(List<Object> cells, bool show) {
    if (cells != null && cells.length > 0) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          _model.setVisible(cells[i], show);
        }
      } finally {
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
   * @param collapse bool that specifies the collapsed state to be
   * assigned.
   * @return Returns the cells whose collapsed state was changed.
   */
  //	List<Object> foldCells(bool collapse)
  //	{
  //		return foldCells(collapse, false);
  //	}

  /**
   * Sets the collapsed state of the selection cells. This is a shortcut
   * method.
   * 
   * @param collapse bool that specifies the collapsed state to be
   * assigned.
   * @param recurse bool that specifies if the collapsed state should
   * be assigned to all descendants.
   * @return Returns the cells whose collapsed state was changed.
   */
  //	List<Object> foldCells(bool collapse, bool recurse)
  //	{
  //		return foldCells(collapse, recurse, null);
  //	}

  /**
   * Invokes foldCells with checkFoldable set to false.
   */
  //	List<Object> foldCells(bool collapse, bool recurse, List<Object> cells)
  //	{
  //		return foldCells(collapse, recurse, cells, false);
  //	}

  /**
   * Sets the collapsed state of the specified cells and all descendants
   * if recurse is true. The change is carried out using cellsFolded.
   * This method fires Event.FOLD_CELLS while the transaction is in
   * progress. Returns the cells whose collapsed state was changed.
   * 
   * @param collapse bool indicating the collapsed state to be assigned.
   * @param recurse bool indicating if the collapsed state of all
   * descendants should be set.
   * @param cells Array of cells whose collapsed state should be set. If
   * null is specified then the foldable selection cells are used.
   * @param checkFoldable bool indicating of isCellFoldable should be
   * checked. Default is false.
   */
  List<Object> foldCells(bool collapse, [bool recurse = false, List<Object> cells = null, bool checkFoldable = false]) {
    if (cells == null) {
      cells = getFoldableCells(getSelectionCells(), collapse);
    }

    _model.beginUpdate();
    try {
      cellsFolded(cells, collapse, recurse, checkFoldable);
      fireEvent(new EventObj(Event.FOLD_CELLS, ["cells", cells, "collapse", collapse, "recurse", recurse]));
    } finally {
      _model.endUpdate();
    }

    return cells;
  }

  /**
   * Invokes cellsFoldable with checkFoldable set to false.
   */
  //	void cellsFolded(List<Object> cells, bool collapse, bool recurse)
  //	{
  //		cellsFolded(cells, collapse, recurse, false);
  //	}

  /**
   * Sets the collapsed state of the specified cells. This method fires
   * Event.CELLS_FOLDED while the transaction is in progress. Returns the
   * cells whose collapsed state was changed.
   * 
   * @param cells Array of cells whose collapsed state should be set.
   * @param collapse bool indicating the collapsed state to be assigned.
   * @param recurse bool indicating if the collapsed state of all
   * descendants should be set.
   * @param checkFoldable bool indicating of isCellFoldable should be
   * checked. Default is false.
   */
  void cellsFolded(List<Object> cells, bool collapse, bool recurse, [bool checkFoldable = false]) {
    if (cells != null && cells.length > 0) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          if ((!checkFoldable || isCellFoldable(cells[i], collapse)) && collapse != isCellCollapsed(cells[i])) {
            _model.setCollapsed(cells[i], collapse);
            swapBounds(cells[i], collapse);

            if (isExtendParent(cells[i])) {
              extendParent(cells[i]);
            }

            if (recurse) {
              List<Object> children = GraphModel.getChildren(_model, cells[i]);
              cellsFolded(children, collapse, recurse);
            }
          }
        }

        fireEvent(new EventObj(Event.CELLS_FOLDED, ["cells", cells, "collapse", collapse, "recurse", recurse]));
      } finally {
        _model.endUpdate();
      }
    }
  }

  /**
   * Swaps the alternate and the actual bounds in the geometry of the given
   * cell invoking updateAlternateBounds before carrying out the swap.
   * 
   * @param cell Cell for which the bounds should be swapped.
   * @param willCollapse bool indicating if the cell is going to be collapsed.
   */
  void swapBounds(Object cell, bool willCollapse) {
    if (cell != null) {
      Geometry geo = _model.getGeometry(cell);

      if (geo != null) {
        geo = geo.clone() as Geometry;

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
   * @param willCollapse bool indicating if the cell is going to be collapsed.
   */
  void updateAlternateBounds(Object cell, Geometry geo, bool willCollapse) {
    if (cell != null && geo != null) {
      if (geo.getAlternateBounds() == null) {
        Rect bounds = null;

        if (isCollapseToPreferredSize()) {
          bounds = getPreferredSizeForCell(cell);

          if (isSwimlane(cell)) {
            Rect size = getStartSize(cell);

            bounds.setHeight(Math.max(bounds.getHeight(), size.getHeight()));
            bounds.setWidth(Math.max(bounds.getWidth(), size.getWidth()));
          }
        }

        if (bounds == null) {
          bounds = geo;
        }

        geo.setAlternateBounds(new Rect(geo.getX(), geo.getY(), bounds.getWidth(), bounds.getHeight()));
      } else {
        geo.getAlternateBounds().setX(geo.getX());
        geo.getAlternateBounds().setY(geo.getY());
      }
    }
  }

  /**
   * Returns an array with the given cells and all edges that are connected
   * to a cell or one of its descendants.
   */
  List<Object> addAllEdges(List<Object> cells) {
    List<Object> allCells = new List<Object>(cells.length);
    allCells.addAll(cells);
    allCells.addAll(getAllEdges(cells));

    return allCells;
  }

  /**
   * Returns all edges connected to the given cells or their descendants.
   */
  List<Object> getAllEdges(List<Object> cells) {
    List<Object> edges = new List<Object>();

    if (cells != null) {
      for (int i = 0; i < cells.length; i++) {
        int edgeCount = _model.getEdgeCount(cells[i]);

        for (int j = 0; j < edgeCount; j++) {
          edges.add(_model.getEdgeAt(cells[i], j));
        }

        // Recurses
        List<Object> children = GraphModel.getChildren(_model, cells[i]);
        edges.addAll(getAllEdges(children));
      }
    }

    return edges;
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
  //	Object updateCellSize(Object cell)
  //	{
  //		return updateCellSize(cell, false);
  //	}

  /**
   * Updates the size of the given cell in the model using
   * getPreferredSizeForCell to get the new size. This function
   * fires Event.UPDATE_CELL_SIZE.
   * 
   * @param cell Cell for which the size should be changed.
   */
  Object updateCellSize(Object cell, [bool ignoreChildren = false]) {
    _model.beginUpdate();
    try {
      cellSizeUpdated(cell, ignoreChildren);
      fireEvent(new EventObj(Event.UPDATE_CELL_SIZE, ["cell", cell, "ignoreChildren", ignoreChildren]));
    } finally {
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
  void cellSizeUpdated(Object cell, bool ignoreChildren) {
    if (cell != null) {
      _model.beginUpdate();
      try {
        Rect size = getPreferredSizeForCell(cell);
        Geometry geo = _model.getGeometry(cell);

        if (size != null && geo != null) {
          bool collapsed = isCellCollapsed(cell);
          geo = geo.clone() as Geometry;

          if (isSwimlane(cell)) {
            CellState state = _view.getState(cell);
            Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);
            String cellStyle = _model.getStyle(cell);

            if (cellStyle == null) {
              cellStyle = "";
            }

            if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
              cellStyle = StyleUtils.setStyle(cellStyle, Constants.STYLE_STARTSIZE, (size.getHeight() + 8).toString());

              if (collapsed) {
                geo.setHeight(size.getHeight() + 8);
              }

              geo.setWidth(size.getWidth());
            } else {
              cellStyle = StyleUtils.setStyle(cellStyle, Constants.STYLE_STARTSIZE, (size.getWidth() + 8).toString());

              if (collapsed) {
                geo.setWidth(size.getWidth() + 8);
              }

              geo.setHeight(size.getHeight());
            }

            _model.setStyle(cell, cellStyle);
          } else {
            geo.setWidth(size.getWidth());
            geo.setHeight(size.getHeight());
          }

          if (!ignoreChildren && !collapsed) {
            Rect bounds = _view.getBounds(GraphModel.getChildren(_model, cell));

            if (bounds != null) {
              Point2d tr = _view.getTranslate();
              double scale = _view.getScale();

              double width = (bounds.getX() + bounds.getWidth()) / scale - geo.getX() - tr.getX();
              double height = (bounds.getY() + bounds.getHeight()) / scale - geo.getY() - tr.getY();

              geo.setWidth(Math.max(geo.getWidth(), width));
              geo.setHeight(Math.max(geo.getHeight(), height));
            }
          }

          cellsResized([cell], [geo]);
        }
      } finally {
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
  Rect getPreferredSizeForCell(Object cell) {
    Rect result = null;

    if (cell != null) {
      CellState state = _view.getState(cell);
      Map<String, Object> style = (state != null) ? state._style : getCellStyle(cell);

      if (style != null && !_model.isEdge(cell)) {
        double dx = 0.0;
        double dy = 0.0;

        // Adds dimension of image if shape is a label
        if (getImage(state) != null || Utils.getString(style, Constants.STYLE_IMAGE) != null) {
          if (Utils.getString(style, Constants.STYLE_SHAPE, "") == Constants.SHAPE_LABEL) {
            if (Utils.getString(style, Constants.STYLE_VERTICAL_ALIGN, "") == Constants.ALIGN_MIDDLE) {
              dx += Utils.getDouble(style, Constants.STYLE_IMAGE_WIDTH, Constants.DEFAULT_IMAGESIZE.toDouble());
            }

            if (Utils.getString(style, Constants.STYLE_ALIGN, "") == Constants.ALIGN_CENTER) {
              dy += Utils.getDouble(style, Constants.STYLE_IMAGE_HEIGHT, Constants.DEFAULT_IMAGESIZE.toDouble());
            }
          }
        }

        // Adds spacings
        double spacing = Utils.getDouble(style, Constants.STYLE_SPACING);
        dx += 2 * spacing;
        dx += Utils.getDouble(style, Constants.STYLE_SPACING_LEFT);
        dx += Utils.getDouble(style, Constants.STYLE_SPACING_RIGHT);

        dy += 2 * spacing;
        dy += Utils.getDouble(style, Constants.STYLE_SPACING_TOP);
        dy += Utils.getDouble(style, Constants.STYLE_SPACING_BOTTOM);

        // LATER: Add space for collapse/expand icon if applicable

        // Adds space for label
        String value = getLabel(cell);

        if (value != null && value.length > 0) {
          Rect size = Utils.getLabelSize(value, style, isHtmlLabel(cell), 1.0);
          double width = size.getWidth() + dx;
          double height = size.getHeight() + dy;

          if (!Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
            double tmp = height;

            height = width;
            width = tmp;
          }

          if (_gridEnabled) {
            width = snap(width + _gridSize / 2);
            height = snap(height + _gridSize / 2);
          }

          result = new Rect(0.0, 0.0, width, height);
        } else {
          double gs2 = 4.0 * _gridSize;
          result = new Rect(0.0, 0.0, gs2, gs2);
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
  Object resizeCell(Object cell, Rect bounds) {
    return resizeCells([cell], [bounds])[0];
  }

  /**
   * Sets the bounds of the given cells and fires a Event.RESIZE_CELLS
   * event. while the transaction is in progress. Returns the cells which
   * have been passed to the function.
   * 
   * @param cells Array of cells whose bounds should be changed.
   * @param bounds Array of rectangles that represents the new bounds.
   */
  List<Object> resizeCells(List<Object> cells, List<Rect> bounds) {
    _model.beginUpdate();
    try {
      cellsResized(cells, bounds);
      fireEvent(new EventObj(Event.RESIZE_CELLS, ["cells", cells, "bounds", bounds]));
    } finally {
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
  void cellsResized(List<Object> cells, List<Rect> bounds) {
    if (cells != null && bounds != null && cells.length == bounds.length) {
      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          Rect tmp = bounds[i];
          Geometry geo = _model.getGeometry(cells[i]);

          if (geo != null && (geo.getX() != tmp.getX() || geo.getY() != tmp.getY() || geo.getWidth() != tmp.getWidth() || geo.getHeight() != tmp.getHeight())) {
            geo = geo.clone() as Geometry;

            if (geo.isRelative()) {
              Point2d offset = geo.getOffset();

              if (offset != null) {
                offset.setX(offset.getX() + tmp.getX());
                offset.setY(offset.getY() + tmp.getY());
              }
            } else {
              geo.setX(tmp.getX());
              geo.setY(tmp.getY());
            }

            geo.setWidth(tmp.getWidth());
            geo.setHeight(tmp.getHeight());

            if (!geo.isRelative() && _model.isVertex(cells[i]) && !isAllowNegativeCoordinates()) {
              geo.setX(Math.max(0, geo.getX()));
              geo.setY(Math.max(0, geo.getY()));
            }

            _model.setGeometry(cells[i], geo);

            if (isExtendParent(cells[i])) {
              extendParent(cells[i]);
            }
          }
        }

        if (isResetEdgesOnResize()) {
          resetEdges(cells);
        }

        // RENAME BOUNDSARRAY TO BOUNDS
        fireEvent(new EventObj(Event.CELLS_RESIZED, ["cells", cells, "bounds", bounds]));
      } finally {
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
  void extendParent(Object cell) {
    if (cell != null) {
      Object parent = _model.getParent(cell);
      Geometry p = _model.getGeometry(parent);

      if (parent != null && p != null && !isCellCollapsed(parent)) {
        Geometry geo = _model.getGeometry(cell);

        if (geo != null && (p.getWidth() < geo.getX() + geo.getWidth() || p.getHeight() < geo.getY() + geo.getHeight())) {
          p = p.clone() as Geometry;

          p.setWidth(Math.max(p.getWidth(), geo.getX() + geo.getWidth()));
          p.setHeight(Math.max(p.getHeight(), geo.getY() + geo.getHeight()));

          cellsResized([parent], [p]);
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
  //	List<Object> moveCells(List<Object> cells, double dx, double dy)
  //	{
  //		return moveCells(cells, dx, dy, false);
  //	}

  /**
   * Moves or clones the cells and moves the cells or clones by the given
   * amount. This is a shortcut method.
   */
  //	List<Object> moveCells(List<Object> cells, double dx, double dy,
  //			bool clone)
  //	{
  //		return moveCells(cells, dx, dy, clone, null, null);
  //	}

  /**
   * Moves or clones the specified cells and moves the cells or clones by the
   * given amount, adding them to the optional target cell. The location is
   * the position of the mouse pointer as the mouse was released. The change
   * is carried out using cellsMoved. This method fires Event.MOVE_CELLS
   * while the transaction is in progress.
   * 
   * @param cells Array of cells to be moved, cloned or added to the target.
   * @param dx int that specifies the x-coordinate of the vector.
   * @param dy int that specifies the y-coordinate of the vector.
   * @param clone bool indicating if the cells should be cloned.
   * @param target Cell that represents the new parent of the cells.
   * @param location Location where the mouse was released.
   * @return Returns the cells that were moved.
   */
  List<Object> moveCells(List<Object> cells, double dx, double dy, [bool clone = false, Object target = null, svg.Point location = null]) {
    if (cells != null && (dx != 0 || dy != 0 || clone || target != null)) {
      _model.beginUpdate();
      try {
        if (clone) {
          cells = cloneCells(cells, isCloneInvalidEdges());

          if (target == null) {
            target = getDefaultParent();
          }
        }

        // Need to disable allowNegativeCoordinates if target not null to
        // allow for temporary negative numbers until cellsAdded is called.
        bool previous = isAllowNegativeCoordinates();

        if (target != null) {
          setAllowNegativeCoordinates(true);
        }

        cellsMoved(cells, dx, dy, !clone && isDisconnectOnMove() && isAllowDanglingEdges(), target == null);

        setAllowNegativeCoordinates(previous);

        if (target != null) {
          int index = _model.getChildCount(target);
          cellsAdded(cells, target, index, null, null, true);
        }

        fireEvent(new EventObj(Event.MOVE_CELLS, ["cells", cells, "dx", dx, "dy", dy, "clone", clone, "target", target, "location", location]));
      } finally {
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
  void cellsMoved(List<Object> cells, double dx, double dy, bool disconnect, bool constrain) {
    if (cells != null && (dx != 0 || dy != 0)) {
      _model.beginUpdate();
      try {
        if (disconnect) {
          disconnectGraph(cells);
        }

        for (int i = 0; i < cells.length; i++) {
          translateCell(cells[i], dx, dy);

          if (constrain) {
            constrainChild(cells[i]);
          }
        }

        if (isResetEdgesOnMove()) {
          resetEdges(cells);
        }

        fireEvent(new EventObj(Event.CELLS_MOVED, ["cells", cells, "dx", dx, "dy", dy, "disconnect", disconnect]));
      } finally {
        _model.endUpdate();
      }
    }
  }

  /**
   * Translates the geometry of the given cell and stores the new,
   * translated geometry in the model as an atomic change.
   */
  void translateCell(Object cell, double dx, double dy) {
    Geometry geo = _model.getGeometry(cell);

    if (geo != null) {
      geo = geo.clone() as Geometry;
      geo.translate(dx, dy);

      if (!geo.isRelative() && _model.isVertex(cell) && !isAllowNegativeCoordinates()) {
        geo.setX(Math.max(0, geo.getX()));
        geo.setY(Math.max(0, geo.getY()));
      }

      if (geo.isRelative() && !_model.isEdge(cell)) {
        if (geo.getOffset() == null) {
          geo.setOffset(new Point2d(dx, dy));
        } else {
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
  Rect getCellContainmentArea(Object cell) {
    if (cell != null && !_model.isEdge(cell)) {
      Object parent = _model.getParent(cell);

      if (parent == getDefaultParent() || parent == getCurrentRoot()) {
        return getMaximumGraphBounds();
      } else if (parent != null && parent != getDefaultParent()) {
        Geometry g = _model.getGeometry(parent);

        if (g != null) {
          double x = 0.0;
          double y = 0.0;
          double w = g.getWidth();
          double h = g.getHeight();

          if (isSwimlane(parent)) {
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
  Rect getMaximumGraphBounds() {
    return _maximumGraphBounds;
  }

  /**
   * @param value the maximumGraphBounds to set
   */
  void setMaximumGraphBounds(Rect value) {
    Rect oldValue = _maximumGraphBounds;
    _maximumGraphBounds = value;

    _changeSupport.firePropertyChange("maximumGraphBounds", oldValue, _maximumGraphBounds);
  }

  /**
   * Keeps the given cell inside the bounds returned by
   * getCellContainmentArea for its parent, according to the rules defined by
   * getOverlap and isConstrainChild. This modifies the cell's geometry
   * in-place and does not clone it.
   * 
   * @param cell Cell which should be constrained.
   */
  void constrainChild(Object cell) {
    if (cell != null) {
      Geometry geo = _model.getGeometry(cell);
      Rect area = (isConstrainChild(cell)) ? getCellContainmentArea(cell) : getMaximumGraphBounds();

      if (geo != null && area != null) {
        // Keeps child within the content area of the parent
        if (!geo.isRelative() && (geo.getX() < area.getX() || geo.getY() < area.getY() || area.getWidth() < geo.getX() + geo.getWidth() || area.getHeight() < geo.getY() + geo.getHeight())) {
          double overlap = getOverlap(cell);

          if (area.getWidth() > 0) {
            geo.setX(Math.min(geo.getX(), area.getX() + area.getWidth() - (1 - overlap) * geo.getWidth()));
          }

          if (area.getHeight() > 0) {
            geo.setY(Math.min(geo.getY(), area.getY() + area.getHeight() - (1 - overlap) * geo.getHeight()));
          }

          geo.setX(Math.max(geo.getX(), area.getX() - geo.getWidth() * overlap));
          geo.setY(Math.max(geo.getY(), area.getY() - geo.getHeight() * overlap));
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
  void resetEdges(List<Object> cells) {
    if (cells != null) {
      // Prepares a hashtable for faster cell lookups
      HashSet<Object> set = new HashSet<Object>.from(cells);

      _model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          List<Object> edges = GraphModel.getEdges(_model, cells[i]);

          if (edges != null) {
            for (int j = 0; j < edges.length; j++) {
              CellState state = _view.getState(edges[j]);
              Object source = (state != null) ? state.getVisibleTerminal(true) : _view.getVisibleTerminal(edges[j], true);
              Object target = (state != null) ? state.getVisibleTerminal(false) : _view.getVisibleTerminal(edges[j], false);

              // Checks if one of the terminals is not in the given array
              if (!set.contains(source) || !set.contains(target)) {
                resetEdge(edges[j]);
              }
            }
          }

          resetEdges(GraphModel.getChildren(_model, cells[i]));
        }
      } finally {
        _model.endUpdate();
      }
    }
  }

  /**
   * Resets the control points of the given edge.
   */
  Object resetEdge(Object edge) {
    Geometry geo = _model.getGeometry(edge);

    if (geo != null) {
      // Resets the control points
      List<Point2d> points = geo.getPoints();

      if (points != null && points.length > 0) {
        geo = geo.clone() as Geometry;
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
  List<ConnectionConstraint> getAllConnectionConstraints(CellState terminal, bool source) {
    return null;
  }

  /**
   * Returns an connection constraint that describes the given connection
   * point. This result can then be passed to getConnectionPoint.
   * 
   * @param edge Cell state that represents the edge.
   * @param terminal Cell state that represents the terminal.
   * @param source bool indicating if the terminal is the source or target.
   */
  ConnectionConstraint getConnectionConstraint(CellState edge, CellState terminal, bool source) {
    Point2d point = null;
    Object x = edge.getStyle()[(source) ? Constants.STYLE_EXIT_X : Constants.STYLE_ENTRY_X];

    if (x != null) {
      Object y = edge.getStyle()[(source) ? Constants.STYLE_EXIT_Y : Constants.STYLE_ENTRY_Y];

      if (y != null) {
        point = new Point2d(double.parse(x.toString()), double.parse(y.toString()));
      }
    }

    bool perimeter = false;

    if (point != null) {
      perimeter = Utils.isTrue(edge._style, (source) ? Constants.STYLE_EXIT_PERIMETER : Constants.STYLE_ENTRY_PERIMETER, true);
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
   * @param source bool indicating if the terminal is the source or target.
   * @param constraint Optional connection constraint to be used for this connection.
   */
  void setConnectionConstraint(Object edge, Object terminal, bool source, ConnectionConstraint constraint) {
    if (constraint != null) {
      _model.beginUpdate();
      try {
        List<Object> cells = [edge];

        // FIXME, constraint can't be null, we've checked that above
        if (constraint == null || constraint._point == null) {
          setCellStyles((source) ? Constants.STYLE_EXIT_X : Constants.STYLE_ENTRY_X, null, cells);
          setCellStyles((source) ? Constants.STYLE_EXIT_Y : Constants.STYLE_ENTRY_Y, null, cells);
          setCellStyles((source) ? Constants.STYLE_EXIT_PERIMETER : Constants.STYLE_ENTRY_PERIMETER, null, cells);
        } else if (constraint._point != null) {
          setCellStyles((source) ? Constants.STYLE_EXIT_X : Constants.STYLE_ENTRY_X, constraint._point.getX().toString(), cells);
          setCellStyles((source) ? Constants.STYLE_EXIT_Y : Constants.STYLE_ENTRY_Y, constraint._point.getY().toString(), cells);

          // Only writes 0 since 1 is default
          if (!constraint._perimeter) {
            setCellStyles((source) ? Constants.STYLE_EXIT_PERIMETER : Constants.STYLE_ENTRY_PERIMETER, "0", cells);
          } else {
            setCellStyles((source) ? Constants.STYLE_EXIT_PERIMETER : Constants.STYLE_ENTRY_PERIMETER, null, cells);
          }
        }
      } finally {
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
  Point2d getConnectionPoint(CellState vertex, ConnectionConstraint constraint) {
    Point2d point = null;

    if (vertex != null && constraint._point != null) {
      point = new Point2d(vertex.getX() + constraint.getPoint().getX() * vertex.getWidth(), vertex.getY() + constraint.getPoint().getY() * vertex.getHeight());
    }

    if (point != null && constraint._perimeter) {
      point = _view.getPerimeterPoint(vertex, point, false);
    }

    return point;
  }

  /**
   * Connects the specified end of the given edge to the given terminal
   * using cellConnected and fires Event.CONNECT_CELL while the transaction
   * is in progress.
   */
  //	Object connectCell(Object edge, Object terminal, bool source)
  //	{
  //		return connectCell(edge, terminal, source, null);
  //	}

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
  Object connectCell(Object edge, Object terminal, bool source, [ConnectionConstraint constraint = null]) {
    _model.beginUpdate();
    try {
      Object previous = _model.getTerminal(edge, source);
      cellConnected(edge, terminal, source, constraint);
      fireEvent(new EventObj(Event.CONNECT_CELL, ["edge", edge, "terminal", terminal, "source", source, "previous", previous]));
    } finally {
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
  void cellConnected(Object edge, Object terminal, bool source, ConnectionConstraint constraint) {
    if (edge != null) {
      _model.beginUpdate();
      try {
        Object previous = _model.getTerminal(edge, source);

        // Updates the constraint
        setConnectionConstraint(edge, terminal, source, constraint);

        // Checks if the new terminal is a port, uses the ID of the port in the
        // style and the parent of the port as the actual terminal of the edge.
        if (isPortsEnabled()) {
          // Checks if the new terminal is a port
          String id = null;

          if (isPort(terminal) && terminal is ICell) {
            id = (terminal as ICell).getId();
            terminal = getTerminalForPort(terminal, source);
          }

          // Sets or resets all previous information for connecting to a child port
          String key = (source) ? Constants.STYLE_SOURCE_PORT : Constants.STYLE_TARGET_PORT;
          setCellStyles(key, id, [edge]);
        }

        _model.setTerminal(edge, terminal, source);

        if (isResetEdgesOnConnect()) {
          resetEdge(edge);
        }

        fireEvent(new EventObj(Event.CELL_CONNECTED, ["edge", edge, "terminal", terminal, "source", source, "previous", previous]));
      } finally {
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
  void disconnectGraph(List<Object> cells) {
    if (cells != null) {
      _model.beginUpdate();
      try {
        double scale = _view.getScale();
        Point2d tr = _view.getTranslate();

        // Prepares a hashtable for faster cell lookups
        Set<Object> hash = new HashSet<Object>();

        for (int i = 0; i < cells.length; i++) {
          hash.add(cells[i]);
        }

        for (int i = 0; i < cells.length; i++) {
          if (_model.isEdge(cells[i])) {
            Geometry geo = _model.getGeometry(cells[i]);

            if (geo != null) {
              CellState state = _view.getState(cells[i]);
              CellState pstate = _view.getState(_model.getParent(cells[i]));

              if (state != null && pstate != null) {
                geo = geo.clone() as Geometry;

                double dx = -pstate.getOrigin().getX();
                double dy = -pstate.getOrigin().getY();

                Object src = _model.getTerminal(cells[i], true);

                if (src != null && isCellDisconnectable(cells[i], src, true)) {
                  while (src != null && !hash.contains(src)) {
                    src = _model.getParent(src);
                  }

                  if (src == null) {
                    Point2d pt = state.getAbsolutePoint(0);
                    geo.setTerminalPoint(new Point2d(pt.getX() / scale - tr.getX() + dx, pt.getY() / scale - tr.getY() + dy), true);
                    _model.setTerminal(cells[i], null, true);
                  }
                }

                Object trg = _model.getTerminal(cells[i], false);

                if (trg != null && isCellDisconnectable(cells[i], trg, false)) {
                  while (trg != null && !hash.contains(trg)) {
                    trg = _model.getParent(trg);
                  }

                  if (trg == null) {
                    int n = state.getAbsolutePointCount() - 1;
                    Point2d pt = state.getAbsolutePoint(n);
                    geo.setTerminalPoint(new Point2d(pt.getX() / scale - tr.getX() + dx, pt.getY() / scale - tr.getY() + dy), false);
                    _model.setTerminal(cells[i], null, false);
                  }
                }
              }

              _model.setGeometry(cells[i], geo);
            }
          }
        }
      } finally {
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
  Object getCurrentRoot() {
    return _view.getCurrentRoot();
  }

  /**
   * Returns the translation to be used if the given cell is the root cell as
   * an <Point2d>. This implementation returns null.
   * 
   * @param cell Cell that represents the root of the view.
   * @return Returns the translation of the graph for the given root cell.
   */
  Point2d getTranslateForRoot(Object cell) {
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
   * public bool isPort(Object cell)
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
  bool isPort(Object cell) {
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
  Object getTerminalForPort(Object cell, bool source) {
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
  Point2d getChildOffsetForCell(Object cell) {
    return null;
  }

  //	void enterGroup()
  //	{
  //		enterGroup(null);
  //	}

  /**
   * Uses the given cell as the root of the displayed cell hierarchy. If no
   * cell is specified then the selection cell is used. The cell is only used
   * if <isValidRoot> returns true.
   * 
   * @param cell
   */
  void enterGroup([Object cell = null]) {
    if (cell == null) {
      cell = getSelectionCell();
    }

    if (cell != null && isValidRoot(cell)) {
      _view.setCurrentRoot(cell);
      clearSelection();
    }
  }

  /**
   * Changes the current root to the next valid root in the displayed cell
   * hierarchy.
   */
  void exitGroup() {
    Object root = _model.getRoot();
    Object current = getCurrentRoot();

    if (current != null) {
      Object next = _model.getParent(current);

      // Finds the next valid root in the hierarchy
      while (next != root && !isValidRoot(next) && _model.getParent(next) != root) {
        next = _model.getParent(next);
      }

      // Clears the current root if the new root is
      // the model's root or one of the layers.
      if (next == root || _model.getParent(next) == root) {
        _view.setCurrentRoot(null);
      } else {
        _view.setCurrentRoot(next);
      }

      CellState state = _view.getState(current);

      // Selects the previous root in the graph
      if (state != null) {
        setSelectionCell(current);
      }
    }
  }

  /**
   * Uses the root of the model as the root of the displayed cell hierarchy
   * and selects the previous root.
   */
  void home() {
    Object current = getCurrentRoot();

    if (current != null) {
      _view.setCurrentRoot(null);
      CellState state = _view.getState(current);

      if (state != null) {
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
  bool isValidRoot(Object cell) {
    return (cell != null);
  }

  //
  // Graph display
  //

  /**
   * Returns the bounds of the visible graph.
   */
  Rect getGraphBounds() {
    return _view.getGraphBounds();
  }

  /**
   * Returns the bounds of the given cell.
   */
  //	Rect getCellBounds(Object cell)
  //	{
  //		return getCellBounds(cell, false);
  //	}

  /**
   * Returns the bounds of the given cell including all connected edges
   * if includeEdge is true.
   */
  //	Rect getCellBounds(Object cell, bool includeEdges)
  //	{
  //		return getCellBounds(cell, includeEdges, false);
  //	}

  /**
   * Returns the bounds of the given cell including all connected edges
   * if includeEdge is true.
   */
  //	Rect getCellBounds(Object cell, [bool includeEdges=false,
  //			bool includeDescendants=false])
  //	{
  //		return getCellBounds(cell, includeEdges, includeDescendants, false);
  //	}

  /**
   * Returns the bounding box for the geometries of the vertices in the
   * given array of cells.
   */
  Rect getBoundingBoxFromGeometry(List<Object> cells) {
    Rect result = null;

    if (cells != null) {
      for (int i = 0; i < cells.length; i++) {
        if (getModel().isVertex(cells[i])) {
          Geometry geo = getCellGeometry(cells[i]);

          if (result == null) {
            result = new Rect.from(geo);
          } else {
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
  //	Rect getBoundingBox(Object cell)
  //	{
  //		return getBoundingBox(cell, false);
  //	}

  /**
   * Returns the bounding box of the given cell including all connected edges
   * if includeEdge is true.
   */
  //	Rect getBoundingBox(Object cell, bool includeEdges)
  //	{
  //		return getBoundingBox(cell, includeEdges, false);
  //	}

  /**
   * Returns the bounding box of the given cell including all connected edges
   * if includeEdge is true.
   */
  Rect getBoundingBox(Object cell, [bool includeEdges = false, bool includeDescendants = false]) {
    return getCellBounds(cell, includeEdges, includeDescendants, true);
  }

  /**
   * Returns the bounding box of the given cells and their descendants.
   */
  Rect getPaintBounds(List<Object> cells) {
    return getBoundsForCells(cells, false, true, true);
  }

  /**
   * Returns the bounds for the given cells.
   */
  Rect getBoundsForCells(List<Object> cells, bool includeEdges, bool includeDescendants, bool boundingBox) {
    Rect result = null;

    if (cells != null && cells.length > 0) {
      for (int i = 0; i < cells.length; i++) {
        Rect tmp = getCellBounds(cells[i], includeEdges, includeDescendants, boundingBox);

        if (tmp != null) {
          if (result == null) {
            result = new Rect.from(tmp);
          } else {
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
  Rect getCellBounds(Object cell, [bool includeEdges = false, bool includeDescendants = false, bool boundingBox = false]) {
    List<Object> cells;

    // Recursively includes connected edges
    if (includeEdges) {
      Set<Object> allCells = new HashSet<Object>();
      allCells.add(cell);

      Set<Object> edges = new HashSet<Object>.from(getEdges(cell));

      while (edges.length > 0 && !allCells.containsAll(edges)) {
        allCells.addAll(edges);

        Set<Object> tmp = new HashSet<Object>();
        Iterator<Object> it = edges.iterator;

        while (it.moveNext()) {
          Object edge = it.current();
          tmp.addAll(getEdges(edge));
        }

        edges = tmp;
      }

      cells = new List<Object>.from(allCells);
    } else {
      cells = [cell];
    }

    Rect result = _view.getBounds(cells, boundingBox);

    // Recursively includes the bounds of the children
    if (includeDescendants) {
      for (int i = 0; i < cells.length; i++) {
        int childCount = _model.getChildCount(cells[i]);

        for (int j = 0; j < childCount; j++) {
          Rect tmp = getCellBounds(_model.getChildAt(cells[i], j), includeEdges, true, boundingBox);

          if (result != null) {
            result.add(tmp);
          } else {
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
  void refresh() {
    _view.reload();
    repaint();
  }

  /**
   * Fires a repaint event.
   */
  //	void repaint()
  //	{
  //		repaint(null);
  //	}

  /**
   * Fires a repaint event. The optional region is the rectangle that needs
   * to be repainted.
   */
  void repaint([Rect region = null]) {
    fireEvent(new EventObj(Event.REPAINT, ["region", region]));
  }

  /**
   * Snaps the given numeric value to the grid if <gridEnabled> is true.
   *
   * @param value Numeric value to be snapped to the grid.
   * @return Returns the value aligned to the grid.
   */
  double snap(double value) {
    if (_gridEnabled) {
      value = math.round(value / _gridSize) * _gridSize;
    }

    return value;
  }

  /**
   * Returns the geometry for the given cell.
   * 
   * @param cell Cell whose geometry should be returned.
   * @return Returns the geometry of the cell.
   */
  Geometry getCellGeometry(Object cell) {
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
  bool isCellVisible(Object cell) {
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
  bool isCellCollapsed(Object cell) {
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
  bool isCellConnectable(Object cell) {
    return _model.isConnectable(cell);
  }

  /**
   * Returns true if perimeter points should be computed such that the
   * resulting edge has only horizontal or vertical segments.
   * 
   * @param edge Cell state that represents the edge.
   */
  bool isOrthogonal(CellState edge) {
    if (edge.getStyle().containsKey(Constants.STYLE_ORTHOGONAL)) {
      return Utils.isTrue(edge.getStyle(), Constants.STYLE_ORTHOGONAL);
    }

    EdgeStyleFunction tmp = _view.getEdgeStyle(edge, null, null, null);

    return tmp == EdgeStyle.SegmentConnector || tmp == EdgeStyle.ElbowConnector || tmp == EdgeStyle.SideToSide || tmp == EdgeStyle.TopToBottom || tmp == EdgeStyle.EntityRelation || tmp == EdgeStyle.OrthConnector;
  }

  /**
   * Returns true if the given cell state is a loop.
   * 
   * @param state <CellState> that represents a potential loop.
   * @return Returns true if the given cell is a loop.
   */
  bool isLoop(CellState state) {
    Object src = state.getVisibleTerminalState(true);
    Object trg = state.getVisibleTerminalState(false);

    return (src != null && src == trg);
  }

  //
  // Cell validation
  //

  void setMultiplicities(List<Multiplicity> value) {
    List<Multiplicity> oldValue = _multiplicities;
    _multiplicities = value;

    _changeSupport.firePropertyChange("multiplicities", oldValue, _multiplicities);
  }

  List<Multiplicity> getMultiplicities() {
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
  bool isEdgeValid(Object edge, Object source, Object target) {
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
  String getEdgeValidationError(Object edge, Object source, Object target) {
    if (edge != null && !isAllowDanglingEdges() && (source == null || target == null)) {
      return "";
    }

    if (edge != null && _model.getTerminal(edge, true) == null && _model.getTerminal(edge, false) == null) {
      return null;
    }

    // Checks if we're dealing with a loop
    if (!isAllowLoops() && source == target && source != null) {
      return "";
    }

    // Checks if the connection is generally allowed
    if (!isValidConnection(source, target)) {
      return "";
    }

    if (source != null && target != null) {
      StringBuffer error = new StringBuffer();

      // Checks if the cells are already connected
      // and adds an error message if required
      if (!_multigraph) {
        List<Object> tmp = GraphModel.getEdgesBetween(_model, source, target, true);

        // Checks if the source and target are not connected by another edge
        if (tmp.length > 1 || (tmp.length == 1 && tmp[0] != edge)) {
          error.write(Resources.get("alreadyConnected", ["Already Connected"]) + "\n");
        }
      }

      // Gets the number of outgoing edges from the source
      // and the number of incoming edges from the target
      // without counting the edge being currently changed.
      int sourceOut = GraphModel.getDirectedEdgeCount(_model, source, true, edge);
      int targetIn = GraphModel.getDirectedEdgeCount(_model, target, false, edge);

      // Checks the change against each multiplicity rule
      if (_multiplicities != null) {
        for (int i = 0; i < _multiplicities.length; i++) {
          String err = _multiplicities[i].check(this, edge, source, target, sourceOut, targetIn);

          if (err != null) {
            error.write(err);
          }
        }
      }

      // Validates the source and target terminals independently
      String err = validateEdge(edge, source, target);

      if (err != null) {
        error.write(err);
      }

      return (error.length > 0) ? error.toString() : null;
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
  String validateEdge(Object edge, Object source, Object target) {
    return null;
  }

  /**
   * Checks all multiplicities that cannot be enforced while the graph is
   * being modified, namely, all multiplicities that require a minimum of
   * 1 edge.
   * 
   * @param cell Cell for which the multiplicities should be checked.
   */
  String getCellValidationError(Object cell) {
    int outCount = GraphModel.getDirectedEdgeCount(_model, cell, true);
    int inCount = GraphModel.getDirectedEdgeCount(_model, cell, false);
    StringBuffer error = new StringBuffer();
    Object value = _model.getValue(cell);

    if (_multiplicities != null) {
      for (int i = 0; i < _multiplicities.length; i++) {
        Multiplicity rule = _multiplicities[i];
        int max = rule.getMaxValue();

        if (rule._source && Utils.isNode(value, rule._type, rule._attr, rule._value) && ((max == 0 && outCount > 0) || (rule._min == 1 && outCount == 0) || (max == 1 && outCount > 1))) {
          error.write(rule._countError + '\n');
        } else if (!rule._source && Utils.isNode(value, rule._type, rule._attr, rule._value) && ((max == 0 && inCount > 0) || (rule._min == 1 && inCount == 0) || (max == 1 && inCount > 1))) {
          error.write(rule._countError + '\n');
        }
      }
    }

    return (error.length > 0) ? error.toString() : null;
  }

  /**
   * Hook method for subclassers to return an error message for the given
   * cell and validation context. This implementation returns null.
   * 
   * @param cell Cell that represents the cell to validate.
   * @param context Hashtable that represents the global validation state.
   */
  String validateCell(Object cell, Map<Object, Object> context) {
    return null;
  }

  //
  // Graph appearance
  //

  /**
   * @return the labelsVisible
   */
  bool isLabelsVisible() {
    return _labelsVisible;
  }

  /**
   * @param value the labelsVisible to set
   */
  void setLabelsVisible(bool value) {
    bool oldValue = _labelsVisible;
    _labelsVisible = value;

    _changeSupport.firePropertyChange("labelsVisible", oldValue, _labelsVisible);
  }

  /**
   * @param value the htmlLabels to set
   */
  void setHtmlLabels(bool value) {
    bool oldValue = _htmlLabels;
    _htmlLabels = value;

    _changeSupport.firePropertyChange("htmlLabels", oldValue, _htmlLabels);
  }

  bool isHtmlLabels() {
    return _htmlLabels;
  }

  /**
   * Returns the textual representation for the given cell.
   * 
   * @param cell Cell to be converted to a string.
   * @return Returns the textual representation of the cell.
   */
  String convertValueToString(Object cell) {
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
  String getLabel(Object cell) {
    String result = "";

    if (cell != null) {
      CellState state = _view.getState(cell);
      Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

      if (_labelsVisible && !Utils.isTrue(style, Constants.STYLE_NOLABEL, false)) {
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
  void cellLabelChanged(Object cell, Object value, bool autoSize) {
    _model.beginUpdate();
    try {
      getModel().setValue(cell, value);

      if (autoSize) {
        cellSizeUpdated(cell, false);
      }
    } finally {
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
  bool isHtmlLabel(Object cell) {
    return isHtmlLabels();
  }

  /**
   * Returns the tooltip to be used for the given cell.
   */
  String getToolTipForCell(Object cell) {
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
  Rect getStartSize(Object swimlane) {
    Rect result = new Rect();
    CellState state = _view.getState(swimlane);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(swimlane);

    if (style != null) {
      double size = Utils.getDouble(style, Constants.STYLE_STARTSIZE, Constants.DEFAULT_STARTSIZE.toDouble());

      if (Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true)) {
        result.setHeight(size);
      } else {
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
  String getImage(CellState state) {
    return (state != null && state.getStyle() != null) ? Utils.getString(state.getStyle(), Constants.STYLE_IMAGE) : null;
  }

  /**
   * Returns the value of <border>.
   * 
   * @return Returns the border.
   */
  int getBorder() {
    return _border;
  }

  /**
   * Sets the value of <border>.
   * 
   * @param value Positive integer that represents the border to be used.
   */
  void setBorder(int value) {
    _border = value;
  }

  /**
   * Returns the default edge style used for loops.
   * 
   * @return Returns the default loop style.
   */
  EdgeStyleFunction getDefaultLoopStyle() {
    return _defaultLoopStyle;
  }

  /**
   * Sets the default style used for loops.
   * 
   * @param value Default style to be used for loops.
   */
  void setDefaultLoopStyle(EdgeStyleFunction value) {
    EdgeStyleFunction oldValue = _defaultLoopStyle;
    _defaultLoopStyle = value;

    _changeSupport.firePropertyChange("defaultLoopStyle", oldValue, _defaultLoopStyle);
  }

  /**
   * Returns true if the given cell is a swimlane. This implementation always
   * returns false.
   * 
   * @param cell Cell that should be checked. 
   * @return Returns true if the cell is a swimlane.
   */
  bool isSwimlane(Object cell) {
    if (cell != null) {
      if (_model.getParent(cell) != _model.getRoot()) {
        CellState state = _view.getState(cell);
        Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

        if (style != null && !_model.isEdge(cell)) {
          return Utils.getString(style, Constants.STYLE_SHAPE, "") == Constants.SHAPE_SWIMLANE;
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
  bool isCellLocked(Object cell) {
    Geometry geometry = _model.getGeometry(cell);

    return isCellsLocked() || (geometry != null && _model.isVertex(cell) && geometry.isRelative());
  }

  /**
   * Returns cellsLocked, the default return value for isCellLocked.
   */
  bool isCellsLocked() {
    return _cellsLocked;
  }

  /**
   * Sets cellsLocked, the default return value for isCellLocked and fires a
   * property change event for cellsLocked.
   */
  void setCellsLocked(bool value) {
    bool oldValue = _cellsLocked;
    _cellsLocked = value;

    _changeSupport.firePropertyChange("cellsLocked", oldValue, _cellsLocked);
  }

  /**
   * Returns true if the given cell is movable. This implementation returns editable.
   * 
   * @param cell Cell whose editable state should be returned.
   * @return Returns true if the cell is editable.
   */
  bool isCellEditable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsEditable() && !isCellLocked(cell) && Utils.isTrue(style, Constants.STYLE_EDITABLE, true);
  }

  /**
   * Returns true if editing is allowed in this graph.
   * 
   * @return Returns true if the graph is editable.
   */
  bool isCellsEditable() {
    return _cellsEditable;
  }

  /**
   * Sets if the graph is editable.
   */
  void setCellsEditable(bool value) {
    bool oldValue = _cellsEditable;
    _cellsEditable = value;

    _changeSupport.firePropertyChange("cellsEditable", oldValue, _cellsEditable);
  }

  /**
   * Returns true if the given cell is resizable. This implementation returns
   * cellsSizable for all cells.
   * 
   * @param cell Cell whose resizable state should be returned.
   * @return Returns true if the cell is sizable.
   */
  bool isCellResizable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsResizable() && !isCellLocked(cell) && Utils.isTrue(style, Constants.STYLE_RESIZABLE, true);
  }

  /**
   * Returns true if the given cell is resizable. This implementation return sizable.
   */
  bool isCellsResizable() {
    return _cellsResizable;
  }

  /**
   * Sets if the graph is resizable.
   */
  void setCellsResizable(bool value) {
    bool oldValue = _cellsResizable;
    _cellsResizable = value;

    _changeSupport.firePropertyChange("cellsResizable", oldValue, _cellsResizable);
  }

  /**
   * Returns the cells which are movable in the given array of cells.
   */
  List<Object> getMovableCells(List<Object> cells) {
    return GraphModel.filterCells(cells, (Object cell) {
      return isCellMovable(cell);
    });
  }

  /**
   * Returns true if the given cell is movable. This implementation
   * returns movable.
   * 
   * @param cell Cell whose movable state should be returned.
   * @return Returns true if the cell is movable.
   */
  bool isCellMovable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsMovable() && !isCellLocked(cell) && Utils.isTrue(style, Constants.STYLE_MOVABLE, true);
  }

  /**
   * Returns cellsMovable.
   */
  bool isCellsMovable() {
    return _cellsMovable;
  }

  /**
   * Sets cellsMovable.
   */
  void setCellsMovable(bool value) {
    bool oldValue = _cellsMovable;
    _cellsMovable = value;

    _changeSupport.firePropertyChange("cellsMovable", oldValue, _cellsMovable);
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
   * @param source bool indicating if the source or target terminal should be moved.
   */
  bool isTerminalPointMovable(Object cell, bool source) {
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
  bool isCellBendable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsBendable() && !isCellLocked(cell) && Utils.isTrue(style, Constants.STYLE_BENDABLE, true);
  }

  /**
   * Returns cellsBendable.
   */
  bool isCellsBendable() {
    return _cellsBendable;
  }

  /**
   * Sets cellsBendable.
   */
  void setCellsBendable(bool value) {
    bool oldValue = _cellsBendable;
    _cellsBendable = value;

    _changeSupport.firePropertyChange("cellsBendable", oldValue, _cellsBendable);
  }

  /**
   * Returns true if the given cell is selectable. This implementation returns
   * <selectable>.
   * 
   * @param cell <Cell> whose selectable state should be returned.
   * @return Returns true if the given cell is selectable.
   */
  bool isCellSelectable(Object cell) {
    return isCellsSelectable();
  }

  /**
   * Returns cellsSelectable.
   */
  bool isCellsSelectable() {
    return _cellsSelectable;
  }

  /**
   * Sets cellsSelectable.
   */
  void setCellsSelectable(bool value) {
    bool oldValue = _cellsSelectable;
    _cellsSelectable = value;

    _changeSupport.firePropertyChange("cellsSelectable", oldValue, _cellsSelectable);
  }

  /**
   * Returns the cells which are movable in the given array of cells.
   */
  List<Object> getDeletableCells(List<Object> cells) {
    return GraphModel.filterCells(cells, (Object cell) {
      return isCellDeletable(cell);
    });
  }

  /**
   * Returns true if the given cell is movable. This implementation always
   * returns true.
   * 
   * @param cell Cell whose movable state should be returned.
   * @return Returns true if the cell is movable.
   */
  bool isCellDeletable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsDeletable() && Utils.isTrue(style, Constants.STYLE_DELETABLE, true);
  }

  /**
   * Returns cellsDeletable.
   */
  bool isCellsDeletable() {
    return _cellsDeletable;
  }

  /**
   * Sets cellsDeletable.
   */
  void setCellsDeletable(bool value) {
    bool oldValue = _cellsDeletable;
    _cellsDeletable = value;

    _changeSupport.firePropertyChange("cellsDeletable", oldValue, _cellsDeletable);
  }

  /**
   * Returns the cells which are movable in the given array of cells.
   */
  List<Object> getCloneableCells(List<Object> cells) {
    return GraphModel.filterCells(cells, (Object cell) {
      return isCellCloneable(cell);
    });
  }

  /**
   * Returns the constant true. This does not use the cloneable field to
   * return a value for a given cell, it is simply a hook for subclassers
   * to disallow cloning of individual cells.
   */
  bool isCellCloneable(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isCellsCloneable() && Utils.isTrue(style, Constants.STYLE_CLONEABLE, true);
  }

  /**
   * Returns cellsCloneable.
   */
  bool isCellsCloneable() {
    return _cellsCloneable;
  }

  /**
   * Specifies if the graph should allow cloning of cells by holding down the
   * control key while cells are being moved. This implementation updates
   * cellsCloneable.
   *
   * @param value bool indicating if the graph should be cloneable.
   */
  void setCellsCloneable(bool value) {
    bool oldValue = _cellsCloneable;
    _cellsCloneable = value;

    _changeSupport.firePropertyChange("cellsCloneable", oldValue, _cellsCloneable);
  }

  /**
   * Returns true if the given cell is disconnectable from the source or
   * target terminal. This returns <disconnectable> for all given cells if
   * <isLocked> does not return true for the given cell.
   * 
   * @param cell <Cell> whose disconnectable state should be returned.
   * @param terminal <Cell> that represents the source or target terminal.
   * @param source bool indicating if the source or target terminal is to be
   * disconnected.
   * @return Returns true if the given edge can be disconnected from the given
   * terminal.
   */
  bool isCellDisconnectable(Object cell, Object terminal, bool source) {
    return isCellsDisconnectable() && !isCellLocked(cell);
  }

  /**
   * Returns cellsDisconnectable.
   */
  bool isCellsDisconnectable() {
    return _cellsDisconnectable;
  }

  /**
   * Sets cellsDisconnectable.
   * 
   * @param value bool indicating if the graph should allow disconnecting of
   * edges.
   */
  void setCellsDisconnectable(bool value) {
    bool oldValue = _cellsDisconnectable;
    _cellsDisconnectable = value;

    _changeSupport.firePropertyChange("cellsDisconnectable", oldValue, _cellsDisconnectable);
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
  bool isLabelClipped(Object cell) {
    if (!isLabelsClipped()) {
      CellState state = _view.getState(cell);
      Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

      return (style != null) ? Utils.getString(style, Constants.STYLE_OVERFLOW, "") == "hidden" : false;
    }

    return isLabelsClipped();
  }

  /**
   * Returns labelsClipped.
   */
  bool isLabelsClipped() {
    return _labelsClipped;
  }

  /**
   * Sets labelsClipped.
   */
  void setLabelsClipped(bool value) {
    bool oldValue = _labelsClipped;
    _labelsClipped = value;

    _changeSupport.firePropertyChange("labelsClipped", oldValue, _labelsClipped);
  }

  /**
   * Returns true if the given edges's label is moveable. This returns
   * <movable> for all given cells if <isLocked> does not return true
   * for the given cell.
   * 
   * @param cell <Cell> whose label should be moved.
   * @return Returns true if the label of the given cell is movable.
   */
  bool isLabelMovable(Object cell) {
    return !isCellLocked(cell) && ((_model.isEdge(cell) && isEdgeLabelsMovable()) || (_model.isVertex(cell) && isVertexLabelsMovable()));
  }

  /**
   * Returns vertexLabelsMovable.
   */
  bool isVertexLabelsMovable() {
    return _vertexLabelsMovable;
  }

  /**
   * Sets vertexLabelsMovable.
   */
  void setVertexLabelsMovable(bool value) {
    bool oldValue = _vertexLabelsMovable;
    _vertexLabelsMovable = value;

    _changeSupport.firePropertyChange("vertexLabelsMovable", oldValue, _vertexLabelsMovable);
  }

  /**
   * Returns edgeLabelsMovable.
   */
  bool isEdgeLabelsMovable() {
    return _edgeLabelsMovable;
  }

  /**
   * Returns edgeLabelsMovable.
   */
  void setEdgeLabelsMovable(bool value) {
    bool oldValue = _edgeLabelsMovable;
    _edgeLabelsMovable = value;

    _changeSupport.firePropertyChange("edgeLabelsMovable", oldValue, _edgeLabelsMovable);
  }

  //
  // Graph control options
  //

  /**
   * Returns true if the graph is <enabled>.
   * 
   * @return Returns true if the graph is enabled.
   */
  bool isEnabled() {
    return _enabled;
  }

  /**
   * Specifies if the graph should allow any interactions. This
   * implementation updates <enabled>.
   * 
   * @param value bool indicating if the graph should be enabled.
   */
  void setEnabled(bool value) {
    bool oldValue = _enabled;
    _enabled = value;

    _changeSupport.firePropertyChange("enabled", oldValue, _enabled);
  }

  /**
   * Returns true if the graph allows drop into other cells.
   */
  bool isDropEnabled() {
    return _dropEnabled;
  }

  /**
   * Sets dropEnabled.
   */
  void setDropEnabled(bool value) {
    bool oldValue = _dropEnabled;
    _dropEnabled = value;

    _changeSupport.firePropertyChange("dropEnabled", oldValue, _dropEnabled);
  }

  /**
   * Affects the return values of isValidDropTarget to allow for edges as
   * drop targets. The splitEdge method is called in GraphHandler if
   * GraphComponent.isSplitEvent returns true for a given configuration.
   */
  bool isSplitEnabled() {
    return _splitEnabled;
  }

  /**
   * Sets splitEnabled.
   */
  void setSplitEnabled(bool value) {
    _splitEnabled = value;
  }

  /**
   * Returns multigraph.
   */
  bool isMultigraph() {
    return _multigraph;
  }

  /**
   * Sets multigraph.
   */
  void setMultigraph(bool value) {
    bool oldValue = _multigraph;
    _multigraph = value;

    _changeSupport.firePropertyChange("multigraph", oldValue, _multigraph);
  }

  /**
   * Returns swimlaneNesting.
   */
  bool isSwimlaneNesting() {
    return _swimlaneNesting;
  }

  /**
   * Sets swimlaneNesting.
   */
  void setSwimlaneNesting(bool value) {
    bool oldValue = _swimlaneNesting;
    _swimlaneNesting = value;

    _changeSupport.firePropertyChange("swimlaneNesting", oldValue, _swimlaneNesting);
  }

  /**
   * Returns allowDanglingEdges
   */
  bool isAllowDanglingEdges() {
    return _allowDanglingEdges;
  }

  /**
   * Sets allowDanglingEdges.
   */
  void setAllowDanglingEdges(bool value) {
    bool oldValue = _allowDanglingEdges;
    _allowDanglingEdges = value;

    _changeSupport.firePropertyChange("allowDanglingEdges", oldValue, _allowDanglingEdges);
  }

  /**
   * Returns cloneInvalidEdges.
   */
  bool isCloneInvalidEdges() {
    return _cloneInvalidEdges;
  }

  /**
   * Sets cloneInvalidEdge.
   */
  void setCloneInvalidEdges(bool value) {
    bool oldValue = _cloneInvalidEdges;
    _cloneInvalidEdges = value;

    _changeSupport.firePropertyChange("cloneInvalidEdges", oldValue, _cloneInvalidEdges);
  }

  /**
   * Returns disconnectOnMove
   */
  bool isDisconnectOnMove() {
    return _disconnectOnMove;
  }

  /**
   * Sets disconnectOnMove.
   */
  void setDisconnectOnMove(bool value) {
    bool oldValue = _disconnectOnMove;
    _disconnectOnMove = value;

    _changeSupport.firePropertyChange("disconnectOnMove", oldValue, _disconnectOnMove);

  }

  /**
   * Returns allowLoops.
   */
  bool isAllowLoops() {
    return _allowLoops;
  }

  /**
   * Sets allowLoops.
   */
  void setAllowLoops(bool value) {
    bool oldValue = _allowLoops;
    _allowLoops = value;

    _changeSupport.firePropertyChange("allowLoops", oldValue, _allowLoops);
  }

  /**
   * Returns connectableEdges.
   */
  bool isConnectableEdges() {
    return _connectableEdges;
  }

  /**
   * Sets connetableEdges.
   */
  void setConnectableEdges(bool value) {
    bool oldValue = _connectableEdges;
    _connectableEdges = value;

    _changeSupport.firePropertyChange("connectableEdges", oldValue, _connectableEdges);

  }

  /**
   * Returns resetEdgesOnMove.
   */
  bool isResetEdgesOnMove() {
    return _resetEdgesOnMove;
  }

  /**
   * Sets resetEdgesOnMove.
   */
  void setResetEdgesOnMove(bool value) {
    bool oldValue = _resetEdgesOnMove;
    _resetEdgesOnMove = value;

    _changeSupport.firePropertyChange("resetEdgesOnMove", oldValue, _resetEdgesOnMove);
  }

  /**
   * Returns resetViewOnRootChange.
   */
  bool isResetViewOnRootChange() {
    return _resetViewOnRootChange;
  }

  /**
   * Sets resetEdgesOnResize.
   */
  void setResetViewOnRootChange(bool value) {
    bool oldValue = _resetViewOnRootChange;
    _resetViewOnRootChange = value;

    _changeSupport.firePropertyChange("resetViewOnRootChange", oldValue, _resetViewOnRootChange);
  }

  /**
   * Returns resetEdgesOnResize.
   */
  bool isResetEdgesOnResize() {
    return _resetEdgesOnResize;
  }

  /**
   * Sets resetEdgesOnResize.
   */
  void setResetEdgesOnResize(bool value) {
    bool oldValue = _resetEdgesOnResize;
    _resetEdgesOnResize = value;

    _changeSupport.firePropertyChange("resetEdgesOnResize", oldValue, _resetEdgesOnResize);
  }

  /**
   * Returns resetEdgesOnConnect.
   */
  bool isResetEdgesOnConnect() {
    return _resetEdgesOnConnect;
  }

  /**
   * Sets resetEdgesOnConnect.
   */
  void setResetEdgesOnConnect(bool value) {
    bool oldValue = _resetEdgesOnConnect;
    _resetEdgesOnConnect = value;

    _changeSupport.firePropertyChange("resetEdgesOnConnect", oldValue, _resetEdgesOnResize);
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
  bool isAutoSizeCell(Object cell) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return isAutoSizeCells() || Utils.isTrue(style, Constants.STYLE_AUTOSIZE, false);
  }

  /**
   * Returns true if the size of the given cell should automatically be
   * updated after a change of the label. This implementation returns
   * autoSize for all given cells.
   */
  bool isAutoSizeCells() {
    return _autoSizeCells;
  }

  /**
   * Specifies if cell sizes should be automatically updated after a label
   * change. This implementation sets autoSize to the given parameter.
   * 
   * @param value bool indicating if cells should be resized
   * automatically.
   */
  void setAutoSizeCells(bool value) {
    bool oldValue = _autoSizeCells;
    _autoSizeCells = value;

    _changeSupport.firePropertyChange("autoSizeCells", oldValue, _autoSizeCells);
  }

  /**
   * Returns true if the parent of the given cell should be extended if the
   * child has been resized so that it overlaps the parent. This
	   * implementation returns ExtendParents if cell is not an edge.
   * 
   * @param cell Cell that has been resized.
   */
  bool isExtendParent(Object cell) {
    return !getModel().isEdge(cell) && isExtendParents();
  }

  /**
   * Returns extendParents.
   */
  bool isExtendParents() {
    return _extendParents;
  }

  /**
   * Sets extendParents.
   */
  void setExtendParents(bool value) {
    bool oldValue = _extendParents;
    _extendParents = value;

    _changeSupport.firePropertyChange("extendParents", oldValue, _extendParents);
  }

  /**
   * Returns extendParentsOnAdd.
   */
  bool isExtendParentsOnAdd() {
    return _extendParentsOnAdd;
  }

  /**
   * Sets extendParentsOnAdd.
   */
  void setExtendParentsOnAdd(bool value) {
    bool oldValue = _extendParentsOnAdd;
    _extendParentsOnAdd = value;

    _changeSupport.firePropertyChange("extendParentsOnAdd", oldValue, _extendParentsOnAdd);
  }

  /**
   * Returns true if the given cell should be kept inside the bounds of its
   * parent according to the rules defined by getOverlap and
   * isAllowOverlapParent. This implementation returns false for all children
   * of edges and isConstrainChildren() otherwise.
   */
  bool isConstrainChild(Object cell) {
    return isConstrainChildren() && !getModel().isEdge(getModel().getParent(cell));
  }

  /**
   * Returns constrainChildren.
   * 
   * @return the keepInsideParentOnMove
   */
  bool isConstrainChildren() {
    return _constrainChildren;
  }

  /**
   * @param value the constrainChildren to set
   */
  void setConstrainChildren(bool value) {
    bool oldValue = _constrainChildren;
    _constrainChildren = value;

    _changeSupport.firePropertyChange("constrainChildren", oldValue, _constrainChildren);
  }

  /**
   * Returns autoOrigin.
   */
  bool isAutoOrigin() {
    return _autoOrigin;
  }

  /**
   * @param value the autoOrigin to set
   */
  void setAutoOrigin(bool value) {
    bool oldValue = _autoOrigin;
    _autoOrigin = value;

    _changeSupport.firePropertyChange("autoOrigin", oldValue, _autoOrigin);
  }

  /**
   * Returns origin.
   */
  Point2d getOrigin() {
    return _origin;
  }

  /**
   * @param value the origin to set
   */
  void setOrigin(Point2d value) {
    Point2d oldValue = _origin;
    _origin = value;

    _changeSupport.firePropertyChange("origin", oldValue, _origin);
  }

  /**
   * @return Returns changesRepaintThreshold.
   */
  int getChangesRepaintThreshold() {
    return _changesRepaintThreshold;
  }

  /**
   * @param value the changesRepaintThreshold to set
   */
  void setChangesRepaintThreshold(int value) {
    int oldValue = _changesRepaintThreshold;
    _changesRepaintThreshold = value;

    _changeSupport.firePropertyChange("changesRepaintThreshold", oldValue, _changesRepaintThreshold);
  }

  /**
   * Returns isAllowNegativeCoordinates.
   * 
   * @return the allowNegativeCoordinates
   */
  bool isAllowNegativeCoordinates() {
    return _allowNegativeCoordinates;
  }

  /**
   * @param value the allowNegativeCoordinates to set
   */
  void setAllowNegativeCoordinates(bool value) {
    bool oldValue = _allowNegativeCoordinates;
    _allowNegativeCoordinates = value;

    _changeSupport.firePropertyChange("allowNegativeCoordinates", oldValue, _allowNegativeCoordinates);
  }

  /**
   * Returns collapseToPreferredSize.
   * 
   * @return the collapseToPreferredSize
   */
  bool isCollapseToPreferredSize() {
    return _collapseToPreferredSize;
  }

  /**
   * @param value the collapseToPreferredSize to set
   */
  void setCollapseToPreferredSize(bool value) {
    bool oldValue = _collapseToPreferredSize;
    _collapseToPreferredSize = value;

    _changeSupport.firePropertyChange("collapseToPreferredSize", oldValue, _collapseToPreferredSize);
  }

  /**
   * @return Returns true if edges are rendered in the foreground.
   */
  bool isKeepEdgesInForeground() {
    return _keepEdgesInForeground;
  }

  /**
   * @param value the keepEdgesInForeground to set
   */
  void setKeepEdgesInForeground(bool value) {
    bool oldValue = _keepEdgesInForeground;
    _keepEdgesInForeground = value;

    _changeSupport.firePropertyChange("keepEdgesInForeground", oldValue, _keepEdgesInForeground);
  }

  /**
   * @return Returns true if edges are rendered in the background.
   */
  bool isKeepEdgesInBackground() {
    return _keepEdgesInBackground;
  }

  /**
   * @param value the keepEdgesInBackground to set
   */
  void setKeepEdgesInBackground(bool value) {
    bool oldValue = _keepEdgesInBackground;
    _keepEdgesInBackground = value;

    _changeSupport.firePropertyChange("keepEdgesInBackground", oldValue, _keepEdgesInBackground);
  }

  /**
   * Returns true if the given cell is a valid source for new connections.
   * This implementation returns true for all non-null values and is
   * called by is called by <isValidConnection>.
   * 
   * @param cell Object that represents a possible source or null.
   * @return Returns true if the given cell is a valid source terminal.
   */
  bool isValidSource(Object cell) {
    return (cell == null && _allowDanglingEdges) || (cell != null && (!_model.isEdge(cell) || isConnectableEdges()) && isCellConnectable(cell));
  }

  /**
   * Returns isValidSource for the given cell. This is called by
   * isValidConnection.
   *
   * @param cell Object that represents a possible target or null.
   * @return Returns true if the given cell is a valid target.
   */
  bool isValidTarget(Object cell) {
    return isValidSource(cell);
  }

  /**
   * Returns true if the given target cell is a valid target for source.
   * This is a bool implementation for not allowing connections between
   * certain pairs of vertices and is called by <getEdgeValidationError>.
   * This implementation returns true if <isValidSource> returns true for
   * the source and <isValidTarget> returns true for the target.
   * 
   * @param source Object that represents the source cell.
   * @param target Object that represents the target cell.
   * @return Returns true if the the connection between the given terminals
   * is valid.
   */
  bool isValidConnection(Object source, Object target) {
    return isValidSource(source) && isValidTarget(target) && (isAllowLoops() || source != target);
  }

  /**
   * Returns the minimum size of the diagram.
   * 
   * @return Returns the minimum container size.
   */
  Rect getMinimumGraphSize() {
    return _minimumGraphSize;
  }

  /**
   * @param value the minimumGraphSize to set
   */
  void setMinimumGraphSize(Rect value) {
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
  double getOverlap(Object cell) {
    return (isAllowOverlapParent(cell)) ? getDefaultOverlap() : 0;
  }

  /**
   * Gets defaultOverlap.
   */
  double getDefaultOverlap() {
    return _defaultOverlap;
  }

  /**
   * Sets defaultOverlap.
   */
  void setDefaultOverlap(double value) {
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
  bool isAllowOverlapParent(Object cell) {
    return false;
  }

  /**
   * Returns the cells which are movable in the given array of cells.
   */
  List<Object> getFoldableCells(List<Object> cells, final bool collapse) {
    return GraphModel.filterCells(cells, (Object cell) {
      return isCellFoldable(cell, collapse);
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
  bool isCellFoldable(Object cell, bool collapse) {
    CellState state = _view.getState(cell);
    Map<String, Object> style = (state != null) ? state.getStyle() : getCellStyle(cell);

    return _model.getChildCount(cell) > 0 && Utils.isTrue(style, Constants.STYLE_FOLDABLE, true);
  }

  /**
   * Returns true if the grid is enabled.
   * 
   * @return Returns the enabled state of the grid.
   */
  bool isGridEnabled() {
    return _gridEnabled;
  }

  /**
   * Sets if the grid is enabled.
   * 
   * @param value Specifies if the grid should be enabled.
   */
  void setGridEnabled(bool value) {
    bool oldValue = _gridEnabled;
    _gridEnabled = value;

    _changeSupport.firePropertyChange("gridEnabled", oldValue, _gridEnabled);
  }

  /**
   * Returns true if ports are enabled.
   * 
   * @return Returns the enabled state of the ports.
   */
  bool isPortsEnabled() {
    return _portsEnabled;
  }

  /**
   * Sets if ports are enabled.
   * 
   * @param value Specifies if the ports should be enabled.
   */
  void setPortsEnabled(bool value) {
    bool oldValue = _portsEnabled;
    _portsEnabled = value;

    _changeSupport.firePropertyChange("portsEnabled", oldValue, _portsEnabled);
  }

  /**
   * Returns the grid size.
   * 
   * @return Returns the grid size
   */
  int getGridSize() {
    return _gridSize;
  }

  /**
   * Sets the grid size and fires a property change event for gridSize.
   * 
   * @param value New grid size to be used.
   */
  void setGridSize(int value) {
    int oldValue = _gridSize;
    _gridSize = value;

    _changeSupport.firePropertyChange("gridSize", oldValue, _gridSize);
  }

  /**
   * Returns alternateEdgeStyle.
   */
  String getAlternateEdgeStyle() {
    return _alternateEdgeStyle;
  }

  /**
   * Sets alternateEdgeStyle.
   */
  void setAlternateEdgeStyle(String value) {
    String oldValue = _alternateEdgeStyle;
    _alternateEdgeStyle = value;

    _changeSupport.firePropertyChange("alternateEdgeStyle", oldValue, _alternateEdgeStyle);
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
  bool isValidDropTarget(Object cell, List<Object> cells) {
    return cell != null && ((isSplitEnabled() && isSplitTarget(cell, cells)) || (!_model.isEdge(cell) && (isSwimlane(cell) || (_model.getChildCount(cell) > 0 && !isCellCollapsed(cell)))));
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
  bool isSplitTarget(Object target, List<Object> cells) {
    if (target != null && cells != null && cells.length == 1) {
      Object src = _model.getTerminal(target, true);
      Object trg = _model.getTerminal(target, false);

      return (_model.isEdge(target) && isCellConnectable(cells[0]) && getEdgeValidationError(target, _model.getTerminal(target, true), cells[0]) == null && !_model.isAncestor(cells[0], src) && !_model.isAncestor(cells[0], trg));
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
  Object getDropTarget(List<Object> cells, svg.Point pt, Object cell) {
    if (!isSwimlaneNesting()) {
      for (int i = 0; i < cells.length; i++) {
        if (isSwimlane(cells[i])) {
          return null;
        }
      }
    }

    // FIXME the else below does nothing if swimlane is null
    Object swimlane = null; //getSwimlaneAt(pt.x, pt.y);

    if (cell == null) {
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

    while (cell != null && !isValidDropTarget(cell, cells) && _model.getParent(cell) != _model.getRoot()) {
      cell = _model.getParent(cell);
    }

    return (_model.getParent(cell) != _model.getRoot() && !Utils.contains(cells, cell)) ? cell : null;
  }

  //
  // Cell retrieval
  //

  /**
   * Returns the first child of the root in the model, that is, the first or
   * default layer of the diagram. 
   * 
   * @return Returns the default parent for new cells.
   */
  Object getDefaultParent() {
    Object parent = _defaultParent;

    if (parent == null) {
      parent = _view.getCurrentRoot();

      if (parent == null) {
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
  void setDefaultParent(Object value) {
    _defaultParent = value;
  }

  /**
   * Returns the visible child vertices of the given parent.
   * 
   * @param parent Cell whose children should be returned.
   */
  List<Object> getChildVertices(Object parent) {
    return getChildCells(parent, true, false);
  }

  /**
   * Returns the visible child edges of the given parent.
   * 
   * @param parent Cell whose children should be returned.
   */
  List<Object> getChildEdges(Object parent) {
    return getChildCells(parent, false, true);
  }

  /**
   * Returns the visible children of the given parent.
   * 
   * @param parent Cell whose children should be returned.
   */
  //	List<Object> getChildCells(Object parent)
  //	{
  //		return getChildCells(parent, false, false);
  //	}

  /**
   * Returns the visible child vertices or edges in the given parent. If
   * vertices and edges is false, then all children are returned.
   * 
   * @param parent Cell whose children should be returned.
   * @param vertices Specifies if child vertices should be returned.
   * @param edges Specifies if child edges should be returned.
   * @return Returns the child vertices and edges.
   */
  List<Object> getChildCells(Object parent, [bool vertices = false, bool edges = false]) {
    List<Object> cells = GraphModel.getChildCells(_model, parent, vertices, edges);
    List<Object> result = new List<Object>(cells.length);

    // Filters out the non-visible child cells
    for (int i = 0; i < cells.length; i++) {
      if (isCellVisible(cells[i])) {
        result.add(cells[i]);
      }
    }

    return result;
  }

  /**
   * Returns all visible edges connected to the given cell without loops.
   * 
   * @param cell Cell whose connections should be returned.
   * @return Returns the connected edges for the given cell.
   */
  //	List<Object> getConnections(Object cell)
  //	{
  //		return getConnections(cell, null);
  //	}

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
  //	List<Object> getConnections(Object cell, [Object parent=null])
  //	{
  //		return getConnections(cell, parent, false);
  //	}

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
  List<Object> getConnections(Object cell, [Object parent = null, bool recurse = false]) {
    return getEdges(cell, parent, true, true, false, recurse);
  }

  /**
   * Returns all incoming visible edges connected to the given cell without
   * loops.
   * 
   * @param cell Cell whose incoming edges should be returned.
   * @return Returns the incoming edges of the given cell.
   */
  //	List<Object> getIncomingEdges(Object cell)
  //	{
  //		return getIncomingEdges(cell, null);
  //	}

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
  List<Object> getIncomingEdges(Object cell, [Object parent = null]) {
    return getEdges(cell, parent, true, false, false);
  }

  /**
   * Returns all outgoing visible edges connected to the given cell without
   * loops.
   * 
   * @param cell Cell whose outgoing edges should be returned.
   * @return Returns the outgoing edges of the given cell.
   */
  //	List<Object> getOutgoingEdges(Object cell)
  //	{
  //		return getOutgoingEdges(cell, null);
  //	}

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
  List<Object> getOutgoingEdges(Object cell, [Object parent = null]) {
    return getEdges(cell, parent, false, true, false);
  }

  /**
   * Returns all visible edges connected to the given cell including loops.
   *
   * @param cell Cell whose edges should be returned.
   * @return Returns the edges of the given cell.
   */
  //	List<Object> getEdges(Object cell)
  //	{
  //		return getEdges(cell, null);
  //	}

  /**
   * Returns all visible edges connected to the given cell including loops.
   * 
   * @param cell Cell whose edges should be returned.
   * @param parent Optional parent of the opposite end for an edge
   * to be returned.
   * @return Returns the edges of the given cell.
   */
  //	List<Object> getEdges(Object cell, Object parent)
  //	{
  //		return getEdges(cell, parent, true, true, true);
  //	}

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
  //	List<Object> getEdges(Object cell, Object parent, bool incoming,
  //			bool outgoing, bool includeLoops)
  //	{
  //		return getEdges(cell, parent, incoming, outgoing, includeLoops, false);
  //	}

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
  List<Object> getEdges(Object cell, [Object parent = null, bool incoming = true, bool outgoing = true, bool includeLoops = true, bool recurse = false]) {
    bool isCollapsed = isCellCollapsed(cell);
    List<Object> edges = new List<Object>();
    int childCount = _model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      Object child = _model.getChildAt(cell, i);

      if (isCollapsed || !isCellVisible(child)) {
        edges.addAll(GraphModel.getEdges(_model, child, incoming, outgoing, includeLoops));
      }
    }

    edges.addAll(GraphModel.getEdges(_model, cell, incoming, outgoing, includeLoops));
    List<Object> result = new List<Object>(edges.length);
    Iterator<Object> it = edges.iterator;

    while (it.moveNext()) {
      Object edge = it.current;
      CellState state = _view.getState(edge);
      Object source = (state != null) ? state.getVisibleTerminal(true) : _view.getVisibleTerminal(edge, true);
      Object target = (state != null) ? state.getVisibleTerminal(false) : _view.getVisibleTerminal(edge, false);

      if ((includeLoops && source == target) || ((source != target) && ((incoming && target == cell && (parent == null || isValidAncestor(source, parent, recurse))) || (outgoing && source == cell && (parent == null || isValidAncestor(target, parent, recurse)))))) {
        result.add(edge);
      }
    }

    return result;
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
  bool isValidAncestor(Object cell, Object parent, bool recurse) {
    return (recurse ? _model.isAncestor(parent, cell) : _model.getParent(cell) == parent);
  }

  /**
   * Returns all distinct visible opposite cells of the terminal on the given
   * edges.
   * 
   * @param edges
   * @param terminal
   * @return Returns the terminals at the opposite ends of the given edges.
   */
  //	List<Object> getOpposites(List<Object> edges, Object terminal)
  //	{
  //		return getOpposites(edges, terminal, true, true);
  //	}

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
  List<Object> getOpposites(List<Object> edges, Object terminal, [bool sources = true, bool targets = true]) {
    /*Collection*/Set<Object> terminals = new LinkedHashSet<Object>();

    if (edges != null) {
      for (int i = 0; i < edges.length; i++) {
        CellState state = _view.getState(edges[i]);
        Object source = (state != null) ? state.getVisibleTerminal(true) : _view.getVisibleTerminal(edges[i], true);
        Object target = (state != null) ? state.getVisibleTerminal(false) : _view.getVisibleTerminal(edges[i], false);

        // Checks if the terminal is the source of
        // the edge and if the target should be
        // stored in the result
        if (targets && source == terminal && target != null && target != terminal) {
          terminals.add(target);
        } // Checks if the terminal is the taget of
        // the edge and if the source should be
        // stored in the result
        else if (sources && target == terminal && source != null && source != terminal) {
          terminals.add(source);
        }
      }
    }

    return new List<Object>.from(terminals);
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
  //	List<Object> getEdgesBetween(Object source, Object target)
  //	{
  //		return getEdgesBetween(source, target, false);
  //	}

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
  List<Object> getEdgesBetween(Object source, Object target, [bool directed = false]) {
    List<Object> edges = getEdges(source);
    List<Object> result = new List<Object>(edges.length);

    // Checks if the edge is connected to the correct
    // cell and adds any match to the result
    for (int i = 0; i < edges.length; i++) {
      CellState state = _view.getState(edges[i]);
      Object src = (state != null) ? state.getVisibleTerminal(true) : _view.getVisibleTerminal(edges[i], true);
      Object trg = (state != null) ? state.getVisibleTerminal(false) : _view.getVisibleTerminal(edges[i], false);

      if ((src == source && trg == target) || (!directed && src == target && trg == source)) {
        result.add(edges[i]);
      }
    }

    return result;
  }

  /**
   * Returns the children of the given parent that are contained in the
   * halfpane from the given point (x0, y0) rightwards and downwards
   * depending on rightHalfpane and bottomHalfpane.
   * 
   * @param x0 X-coordinate of the origin.
   * @param y0 Y-coordinate of the origin.
   * @param parent <Cell> whose children should be checked.
   * @param rightHalfpane bool indicating if the cells in the right halfpane
   * from the origin should be returned.
   * @param bottomHalfpane bool indicating if the cells in the bottom halfpane
   * from the origin should be returned.
   * @return Returns the cells beyond the given halfpane.
   */
  List<Object> getCellsBeyond(double x0, double y0, Object parent, bool rightHalfpane, bool bottomHalfpane) {
    if (parent == null) {
      parent = getDefaultParent();
    }

    int childCount = _model.getChildCount(parent);
    List<Object> result = new List<Object>(childCount);

    if (rightHalfpane || bottomHalfpane) {

      if (parent != null) {
        for (int i = 0; i < childCount; i++) {
          Object child = _model.getChildAt(parent, i);
          CellState state = _view.getState(child);

          if (isCellVisible(child) && state != null) {
            if ((!rightHalfpane || state.getX() >= x0) && (!bottomHalfpane || state.getY() >= y0)) {
              result.add(child);
            }
          }
        }
      }
    }

    return result;
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
  //	List<Object> findTreeRoots(Object parent)
  //	{
  //		return findTreeRoots(parent, false);
  //	}

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
  //	List<Object> findTreeRoots(Object parent, bool isolate)
  //	{
  //		return findTreeRoots(parent, isolate, false);
  //	}

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
  List<Object> findTreeRoots(Object parent, [bool isolate = false, bool invert = false]) {
    List<Object> roots = new List<Object>();

    if (parent != null) {
      int childCount = _model.getChildCount(parent);
      Object best = null;
      int maxDiff = 0;

      for (int i = 0; i < childCount; i++) {
        Object cell = _model.getChildAt(parent, i);

        if (_model.isVertex(cell) && isCellVisible(cell)) {
          List<Object> conns = getConnections(cell, (isolate) ? parent : null);
          int fanOut = 0;
          int fanIn = 0;

          for (int j = 0; j < conns.length; j++) {
            Object src = _view.getVisibleTerminal(conns[j], true);

            if (src == cell) {
              fanOut++;
            } else {
              fanIn++;
            }
          }

          if ((invert && fanOut == 0 && fanIn > 0) || (!invert && fanIn == 0 && fanOut > 0)) {
            roots.add(cell);
          }

          int diff = (invert) ? fanIn - fanOut : fanOut - fanIn;

          if (diff > maxDiff) {
            maxDiff = diff;
            best = cell;
          }
        }
      }

      if (roots.length == 0 && best != null) {
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
   *   public bool visit(Object vertex, Object edge)
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
  //	void traverse(Object vertex, bool directed, ICellVisitor visitor)
  //	{
  //		traverse(vertex, directed, visitor, null, null);
  //	}

  /**
   * Traverses the (directed) graph invoking the given function for each
   * visited vertex and edge. The function is invoked with the current vertex
   * and the incoming edge as a parameter. This implementation makes sure
   * each vertex is only visited once. The function may return false if the
   * traversal should stop at the given vertex.
   * 
   * @param vertex <Cell> that represents the vertex where the traversal starts.
   * @param directed Optional bool indicating if edges should only be traversed
   * from source to target. Default is true.
   * @param visitor Visitor that takes the current vertex and the incoming edge.
   * The traversal stops if the function returns false.
   * @param edge Optional <Cell> that represents the incoming edge. This is
   * null for the first step of the traversal.
   * @param visited Optional array of cell paths for the visited cells.
   */
  void traverse(Object vertex, bool directed, ICellVisitor visitor, [Object edge = null, Set<Object> visited = null]) {
    if (vertex != null && visitor != null) {
      if (visited == null) {
        visited = new HashSet<Object>();
      }

      if (!visited.contains(vertex)) {
        visited.add(vertex);

        if (visitor(vertex, edge)) {
          int edgeCount = _model.getEdgeCount(vertex);

          if (edgeCount > 0) {
            for (int i = 0; i < edgeCount; i++) {
              Object e = _model.getEdgeAt(vertex, i);
              bool isSource = _model.getTerminal(e, true) == vertex;

              if (!directed || isSource) {
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

  GraphSelectionModel getSelectionModel() {
    return _selectionModel;
  }

  int getSelectionCount() {
    return _selectionModel.size();
  }

  /**
   * 
   * @param cell
   * @return Returns true if the given cell is selected.
   */
  bool isCellSelected(Object cell) {
    return _selectionModel.isSelected(cell);
  }

  /**
   * 
   * @return Returns true if the selection is empty.
   */
  bool isSelectionEmpty() {
    return _selectionModel.isEmpty();
  }

  void clearSelection() {
    _selectionModel.clear();
  }

  /**
   * 
   * @return Returns the selection cell.
   */
  Object getSelectionCell() {
    return _selectionModel.getCell();
  }

  /**
   * 
   * @param cell
   */
  void setSelectionCell(Object cell) {
    _selectionModel.setCell(cell);
  }

  /**
   * 
   * @return Returns the selection cells.
   */
  List<Object> getSelectionCells() {
    return _selectionModel.getCells();
  }

//  void setSelectionCells(List<Object> cells) {
//    _selectionModel.setCells(cells);
//  }

  /**
   * 
   * @param cells
   */
	void setSelectionCells(Iterable<Object> cells)
	{
		if (cells != null)
		{
			//setSelectionCells(cells.toArray());
		  _selectionModel.setCells(new List<Object>.from(cells));
		}
	}

  void addSelectionCell(Object cell) {
    _selectionModel.addCell(cell);
  }

  void addSelectionCells(List<Object> cells) {
    _selectionModel.addCells(cells);
  }

  void removeSelectionCell(Object cell) {
    _selectionModel.removeCell(cell);
  }

  void removeSelectionCells(List<Object> cells) {
    _selectionModel.removeCells(cells);
  }

  /**
   * Selects the next cell.
   */
  void selectNextCell() {
    selectCell(true, false, false);
  }

  /**
   * Selects the previous cell.
   */
  void selectPreviousCell() {
    selectCell(false, false, false);
  }

  /**
   * Selects the parent cell.
   */
  void selectParentCell() {
    selectCell(false, true, false);
  }

  /**
   * Selects the first child cell.
   */
  void selectChildCell() {
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
  void selectCell(bool isNext, bool isParent, bool isChild) {
    Object cell = getSelectionCell();

    if (getSelectionCount() > 1) {
      clearSelection();
    }

    Object parent = (cell != null) ? _model.getParent(cell) : getDefaultParent();
    int childCount = _model.getChildCount(parent);

    if (cell == null && childCount > 0) {
      Object child = _model.getChildAt(parent, 0);
      setSelectionCell(child);
    } else if ((cell == null || isParent) && _view.getState(parent) != null && _model.getGeometry(parent) != null) {
      if (getCurrentRoot() != parent) {
        setSelectionCell(parent);
      }
    } else if (cell != null && isChild) {
      int tmp = _model.getChildCount(cell);

      if (tmp > 0) {
        Object child = _model.getChildAt(cell, 0);
        setSelectionCell(child);
      }
    } else if (childCount > 0) {
      int i = (parent as ICell).getIndex(cell as ICell);

      if (isNext) {
        i++;
        setSelectionCell(_model.getChildAt(parent, i % childCount));
      } else {
        i--;
        int index = (i < 0) ? childCount - 1 : i;
        setSelectionCell(_model.getChildAt(parent, index));
      }
    }
  }

  /**
   * Selects all vertices inside the default parent.
   */
  //	void selectVertices()
  //	{
  //		selectVertices(null);
  //	}

  /**
   * Selects all vertices inside the given parent or the default parent
   * if no parent is given.
   */
  void selectVertices([Object parent = null]) {
    selectCells(true, false, parent);
  }

  /**
   * Selects all vertices inside the default parent.
   */
  //	void selectEdges()
  //	{
  //		selectEdges(null);
  //	}

  /**
   * Selects all vertices inside the given parent or the default parent
   * if no parent is given.
   */
  void selectEdges([Object parent = null]) {
    selectCells(false, true, parent);
  }

  /**
   * Selects all vertices and/or edges depending on the given boolean
   * arguments recursively, starting at the default parent. Use
   * <code>selectAll</code> to select all cells.
   *  
   * @param vertices bool indicating if vertices should be selected.
   * @param edges bool indicating if edges should be selected.
   */
  //	void selectCells(bool vertices, bool edges)
  //	{
  //		selectCells(vertices, edges, null);
  //	}

  /**
   * Selects all vertices and/or edges depending on the given boolean
   * arguments recursively, starting at the given parent or the default
   * parent if no parent is specified. Use <code>selectAll</code> to select
   * all cells.
   * 
   * @param vertices bool indicating if vertices should be selected.
   * @param edges bool indicating if edges should be selected.
   * @param parent Optional cell that acts as the root of the recursion.
   * Default is <code>defaultParent</code>.
   */
  void selectCells(final bool vertices, final bool edges, [Object parent = null]) {
    if (parent == null) {
      parent = getDefaultParent();
    }

    Iterable<Object> cells = GraphModel.filterDescendants(getModel(), (Object cell) {
      return _view.getState(cell) != null && _model.getChildCount(cell) == 0 &&
        ((_model.isVertex(cell) && vertices) || (_model.isEdge(cell) && edges));
    });
    setSelectionCells(cells);
  }

  //	void selectAll()
  //	{
  //		selectAll(null);
  //	}

  /**
   * Selects all children of the given parent cell or the children of the
   * default parent if no parent is specified. To select leaf vertices and/or
   * edges use <selectCells>.
   * 
   * @param parent  Optional <Cell> whose children should be selected.
   * Default is <defaultParent>.
   */
  void selectAll([Object parent = null]) {
    if (parent == null) {
      parent = getDefaultParent();
    }

    List<Object> children = GraphModel.getChildren(_model, parent);

    if (children != null) {
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
  void drawGraph(ICanvas canvas) {
    drawCell(canvas, getModel().getRoot());
  }

  /**
   * Draws the given cell and its descendants onto the specified canvas.
   * 
   * @param canvas Canvas onto which the cell should be drawn.
   * @param cell Cell that should be drawn onto the canvas.
   */
  void drawCell(ICanvas canvas, Object cell) {
    drawState(canvas, getView().getState(cell), true);

    // Draws the children on top of their parent
    int childCount = _model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
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
  void drawState(ICanvas canvas, CellState state, bool drawLabel) {
    Object cell = (state != null) ? state.getCell() : null;

    if (cell != null && cell != _view.getCurrentRoot() && cell != _model.getRoot() && (_model.isVertex(cell) || _model.isEdge(cell))) {
      Object obj = canvas.drawCell(state);
      Object lab = null;

      // Holds the current clipping region in case the label will
      // be clipped
      Shape clip = null;
      awt.Rectangle newClip = state.getRectangle();

      // Indirection for image canvas that contains a graphics canvas
      ICanvas clippedCanvas = (isLabelClipped(state.getCell())) ? canvas : null;

      if (clippedCanvas is ImageCanvas) {
        clippedCanvas = (clippedCanvas as ImageCanvas).getGraphicsCanvas();
        // TODO: Shift newClip to match the image offset
        //awt.Point pt = ((ImageCanvas) canvas).getTranslate();
        //newClip.translate(-pt.x, -pt.y);
      }

      if (clippedCanvas is Graphics2DCanvas) {
        Graphics g = (clippedCanvas as Graphics2DCanvas).getGraphics();
        clip = g.getClip();

        // Ensure that our new clip resides within our old clip
        if (clip is awt.Rectangle) {
          g.setClip(newClip.intersection(clip as awt.Rectangle));
        } // Otherwise, default to original implementation
        else {
          g.setClip(newClip);
        }
      }

      if (drawLabel) {
        String label = state.getLabel();

        if (label != null && state.getLabelBounds() != null) {
          lab = canvas.drawLabel(label, state, isHtmlLabel(cell));
        }
      }

      // Restores the previous clipping region
      if (clippedCanvas is Graphics2DCanvas) {
        (clippedCanvas as Graphics2DCanvas).getGraphics().setClip(clip);
      }

      // Invokes the cellDrawn callback with the object which was created
      // by the canvas to represent the cell graphically
      if (obj != null) {
        _cellDrawn(canvas, state, obj, lab);
      }
    }
  }

  /**
   * Called when a cell has been painted as the specified object, typically a
   * DOM node that represents the given cell graphically in a document.
   */
  void _cellDrawn(ICanvas canvas, CellState state, Object element, Object labelElement) {
    if (element is Element) {
      String link = _getLinkForCell(state.getCell());

      if (link != null) {
        String title = getToolTipForCell(state.getCell());
        Element elem = element as Element;

        if (elem.getNodeName().startsWith("v:")) {
          elem.setAttribute("href", link.toString());

          if (title != null) {
            elem.setAttribute("title", title);
          }
        } else if (elem.getOwnerDocument().getElementsByTagName("svg").getLength() > 0) {
          Element xlink = elem.getOwnerDocument().createElement("a");
          xlink.setAttribute("xlink:href", link.toString());

          elem.getParentNode().replaceChild(xlink, elem);
          xlink.append(elem);

          if (title != null) {
            xlink.setAttribute("xlink:title", title);
          }

          elem = xlink;
        } else {
          Element a = elem.getOwnerDocument().createElement("a");
          a.setAttribute("href", link.toString());
          a.setAttribute("style", "text-decoration:none;");

          //elem.parentNode.replaceChild(a, elem);
          elem.replaceWith(a);
          a.append(elem);

          if (title != null) {
            a.setAttribute("title", title);
          }

          elem = a;
        }

        String target = _getTargetForCell(state.getCell());

        if (target != null) {
          elem.setAttribute("target", target);
        }
      }
    }
  }

  /**
   * Returns the hyperlink to be used for the given cell.
   */
  String _getLinkForCell(Object cell) {
    return null;
  }

  /**
   * Returns the hyperlink to be used for the given cell.
   */
  String _getTargetForCell(Object cell) {
    return null;
  }

  //
  // Redirected to change support
  //

  /**
   * @param listener
   * @see java.beans.PropertyChangeSupport#addPropertyChangeListener(java.beans.PropertyChangeListener)
   */
  void addPropertyChangeListener(PropertyChangeListener listener) {
    _changeSupport.addPropertyChangeListener(listener);
  }

  /**
   * @param propertyName
   * @param listener
   * @see java.beans.PropertyChangeSupport#addPropertyChangeListener(java.lang.String, java.beans.PropertyChangeListener)
   */
  void addNamedPropertyChangeListener(String propertyName, PropertyChangeListener listener) {
    _changeSupport.addPropertyChangeListener(propertyName, listener);
  }

  /**
   * @param listener
   * @see java.beans.PropertyChangeSupport#removePropertyChangeListener(java.beans.PropertyChangeListener)
   */
  void removePropertyChangeListener(PropertyChangeListener listener) {
    _changeSupport.removePropertyChangeListener(listener);
  }

  /**
   * @param propertyName
   * @param listener
   * @see java.beans.PropertyChangeSupport#removePropertyChangeListener(java.lang.String, java.beans.PropertyChangeListener)
   */
  void removeNamedPropertyChangeListener(String propertyName, PropertyChangeListener listener) {
    _changeSupport.removePropertyChangeListener(propertyName, listener);
  }

  /**
   * Prints the version number on the console. 
   */
  //	static void main(List<String> args)
  //	{
  //		System.out.println("Graph version \"" + VERSION + "\"");
  //	}

}
