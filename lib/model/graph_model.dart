/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.model;

//import java.io.IOException;
//import java.io.ObjectInputStream;
//import java.io.Serializable;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Collection;
//import java.util.HashSet;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;
//import java.util.Set;

/**
 * Extends EventSource to implement a graph model. The graph model acts as
 * a wrapper around the cells which are in charge of storing the actual graph
 * datastructure. The model acts as a transactional wrapper with event
 * notification for all changes, whereas the cells contain the atomic
 * operations for updating the actual datastructure.
 * 
 * Layers:
 * 
 * The cell hierarchy in the model must have a top-level root cell which
 * contains the layers (typically one default layer), which in turn contain the
 * top-level cells of the layers. This means each cell is contained in a layer.
 * If no layers are required, then all new cells should be added to the default
 * layer.
 * 
 * Layers are useful for hiding and showing groups of cells, or for placing
 * groups of cells on top of other cells in the display. To identify a layer,
 * the <isLayer> function is used. It returns true if the parent of the given
 * cell is the root of the model.
 * 
 * This class fires the following events:
 * 
 * Event.CHANGE fires when an undoable edit is dispatched. The <code>edit</code>
 * property contains the UndoableEdit. The <code>changes</code> property
 * contains the list of undoable changes inside the undoable edit. The changes
 * property is deprecated, please use edit.getChanges() instead.
 * 
 * Event.EXECUTE fires between begin- and endUpdate and after an atomic
 * change was executed in the model. The <code>change</code> property contains
 * the atomic change that was executed.
 * 
 * Event.BEGIN_UPDATE fires after the updateLevel was incremented in
 * beginUpdate. This event contains no properties.
 * 
 * Event.END_UPDATE fires after the updateLevel was decreased in endUpdate
 * but before any notification or change dispatching. The <code>edit</code>
 * property contains the current UndoableEdit.
 * 
 * Event.BEFORE_UNDO fires before the change is dispatched after the update
 * level has reached 0 in endUpdate. The <code>edit</code> property contains
 * the current UndoableEdit.
 * 
 * Event.UNDO fires after the change was dispatched in endUpdate. The
 * <code>edit</code> property contains the current UndoableEdit.
 */
class GraphModel extends EventSource implements IGraphModel //, Serializable
{

  /**
	 * Holds the root cell, which in turn contains the cells that represent the
	 * layers of the diagram as child cells. That is, the actual element of the
	 * diagram are supposed to live in the third generation of cells and below.
	 */
  ICell _root;

  /**
	 * Maps from Ids to cells.
	 */
  Map<String, Object> _cells;

  /**
	 * Specifies if edges should automatically be moved into the nearest common
	 * ancestor of their terminals. Default is true.
	 */
  bool _maintainEdgeParent = true;

  /**
	 * Specifies if the model should automatically create Ids for new cells.
	 * Default is true.
	 */
  bool _createIds = true;

  /**
	 * Specifies the next Id to be created. Initial value is 0.
	 */
  int _nextId = 0;

  /**
	 * Holds the changes for the current transaction. If the transaction is
	 * closed then a new object is created for this variable using
	 * createUndoableEdit.
	 */
  /*transient*/ UndoableEdit _currentEdit;

  /**
	 * Counter for the depth of nested transactions. Each call to beginUpdate
	 * increments this counter and each call to endUpdate decrements it. When
	 * the counter reaches 0, the transaction is closed and the respective
	 * events are fired. Initial value is 0.
	 */
  /*transient*/ int _updateLevel = 0;

  /**
	 * 
	 */
  /*transient*/ bool _endingUpdate = false;

  /**
	 * Constructs a new empty graph model.
	 */
  //	GraphModel()
  //	{
  //		this(null);
  //	}

  /**
	 * Constructs a new graph model. If no root is specified
	 * then a new root Cell with a default layer is created.
	 * 
	 * @param root Cell that represents the root cell.
	 */
  GraphModel([Object root = null]) {
    _currentEdit = _createUndoableEdit();

    if (root != null) {
      setRoot(root);
    } else {
      clear();
    }
  }

  /**
	 * Sets a new root using createRoot.
	 */
  void clear() {
    setRoot(createRoot());
  }

  /**
	 * 
	 */
  int getUpdateLevel() {
    return _updateLevel;
  }

  /**
	 * Creates a new root cell with a default layer (child 0).
	 */
  Object createRoot() {
    Cell root = new Cell();
    root.insert(new Cell());

    return root;
  }

  /**
	 * Returns the internal lookup table that is used to map from Ids to cells.
	 */
  Map<String, Object> getCells() {
    return _cells;
  }

  /**
	 * Returns the cell for the specified Id or null if no cell can be
	 * found for the given Id.
	 * 
	 * @param id A string representing the Id of the cell.
	 * @return Returns the cell for the given Id.
	 */
  Object getCell(String id) {
    Object result = null;

    if (_cells != null) {
      result = _cells[id];
    }
    return result;
  }

  /**
	 * Returns true if the model automatically update parents of edges so that
	 * the edge is contained in the nearest-common-ancestor of its terminals.
	 * 
	 * @return Returns true if the model maintains edge parents.
	 */
  bool isMaintainEdgeParent() {
    return _maintainEdgeParent;
  }

  /**
	 * Specifies if the model automatically updates parents of edges so that
	 * the edge is contained in the nearest-common-ancestor of its terminals.
	 * 
	 * @param maintainEdgeParent bool indicating if the model should
	 * maintain edge parents.
	 */
  void setMaintainEdgeParent(bool maintainEdgeParent) {
    this._maintainEdgeParent = maintainEdgeParent;
  }

  /**
	 * Returns true if the model automatically creates Ids and resolves Id
	 * collisions.
	 * 
	 * @return Returns true if the model creates Ids.
	 */
  bool isCreateIds() {
    return _createIds;
  }

  /**
	 * Specifies if the model automatically creates Ids for new cells and
	 * resolves Id collisions.
	 * 
	 * @param value bool indicating if the model should created Ids.
	 */
  void setCreateIds(bool value) {
    _createIds = value;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getRoot()
	 */
  Object getRoot() {
    return _root;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setRoot(Object)
	 */
  Object setRoot(Object root) {
    execute(new RootChange(this, root));

    return root;
  }

  /**
	 * Inner callback to change the root of the model and update the internal
	 * datastructures, such as cells and nextId. Returns the previous root.
	 */
  Object _rootChanged(Object root) {
    Object oldRoot = this._root;
    this._root = root as ICell;

    // Resets counters and datastructures
    _nextId = 0;
    _cells = null;
    _cellAdded(root);

    return oldRoot;
  }

  /**
	 * Creates a new undoable edit.
	 */
  UndoableEdit _createUndoableEdit() {
    return new GraphModelUndoableEdit(this);
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#cloneCells(List<Object>, boolean)
	 */
  List<Object> cloneCells(List<Object> cells, bool includeChildren) {
    Map<Object, Object> mapping = new Map<Object, Object>();
    List<Object> clones = new List<Object>(cells.length);

    for (int i = 0; i < cells.length; i++) {
      try {
        clones[i] = _cloneCell(cells[i], mapping, includeChildren);
      } on CloneNotSupportedException catch (e) {
        // ignore
      }
    }

    for (int i = 0; i < cells.length; i++) {
      _restoreClone(clones[i], cells[i], mapping);
    }

    return clones;
  }

  /**
	 * Inner helper method for cloning cells recursively.
	 */
  Object _cloneCell(Object cell, Map<Object, Object> mapping, bool includeChildren) //throws CloneNotSupportedException
  {
    if (cell is ICell) {
      ICell mxc = (cell as ICell).clone() as ICell;
      mapping[cell] = mxc;

      if (includeChildren) {
        int childCount = getChildCount(cell);

        for (int i = 0; i < childCount; i++) {
          Object clone = _cloneCell(getChildAt(cell, i), mapping, true);
          mxc.insert(clone as ICell);
        }
      }

      return mxc;
    }

    return null;
  }

  /**
	 * Inner helper method for restoring the connections in
	 * a network of cloned cells.
	 */
  void _restoreClone(Object clone, Object cell, Map<Object, Object> mapping) {
    if (clone is ICell) {
      ICell mxc = clone as ICell;
      Object source = getTerminal(cell, true);

      if (source is ICell) {
        ICell tmp = mapping[source] as ICell;

        if (tmp != null) {
          tmp.insertEdge(mxc, true);
        }
      }

      Object target = getTerminal(cell, false);

      if (target is ICell) {
        ICell tmp = mapping[target] as ICell;

        if (tmp != null) {
          tmp.insertEdge(mxc, false);
        }
      }
    }

    int childCount = getChildCount(clone);

    for (int i = 0; i < childCount; i++) {
      _restoreClone(getChildAt(clone, i), getChildAt(cell, i), mapping);
    }
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isAncestor(Object, Object)
	 */
  bool isAncestor(Object parent, Object child) {
    while (child != null && child != parent) {
      child = getParent(child);
    }

    return child == parent;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#contains(Object)
	 */
  bool contains(Object cell) {
    return isAncestor(getRoot(), cell);
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getParent(Object)
	 */
  Object getParent(Object child) {
    return (child is ICell) ? (child as ICell).getParent() : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#add(Object, Object, int)
	 */
  Object add(Object parent, Object child, int index) {
    if (child != parent && parent != null && child != null) {
      bool parentChanged = parent != getParent(child);
      execute(new ChildChange(this, parent, child, index));

      // Maintains the edges parents by moving the edges
      // into the nearest common ancestor of its
      // terminals
      if (_maintainEdgeParent && parentChanged) {
        updateEdgeParents(child);
      }
    }

    return child;
  }

  /**
	 * Invoked after a cell has been added to a parent. This recursively
	 * creates an Id for the new cell and/or resolves Id collisions.
	 * 
	 * @param cell Cell that has been added.
	 */
  void _cellAdded(Object cell) {
    if (cell is ICell) {
      ICell mxc = cell as ICell;

      if (mxc.getId() == null && isCreateIds()) {
        mxc.setId(createId(cell));
      }

      if (mxc.getId() != null) {
        Object collision = getCell(mxc.getId());

        if (collision != cell) {
          while (collision != null) {
            mxc.setId(createId(cell));
            collision = getCell(mxc.getId());
          }

          if (_cells == null) {
            _cells = new Map<String, Object>();
          }

          _cells[mxc.getId()] = cell;
        }
      }

      // Makes sure IDs of deleted cells are not reused
      try {
        int id = int.parse(mxc.getId());
        _nextId = Math.max(_nextId, id + 1);
      } on NumberFormatException catch (e) {
        // ignore
      }

      int childCount = mxc.getChildCount();

      for (int i = 0; i < childCount; i++) {
        _cellAdded(mxc.getChildAt(i));
      }
    }
  }

  /**
	 * Creates a new Id for the given cell and increments the global counter
	 * for creating new Ids.
	 * 
	 * @param cell Cell for which a new Id should be created.
	 * @return Returns a new Id for the given cell.
	 */
  String createId(Object cell) {
    String id = _nextId.toString();
    _nextId++;

    return id;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#remove(Object)
	 */
  Object remove(Object cell) {
    if (cell == _root) {
      setRoot(null);
    } else if (getParent(cell) != null) {
      execute(new ChildChange(this, null, cell));
    }

    return cell;
  }

  /**
	 * Invoked after a cell has been removed from the model. This recursively
	 * removes the cell from its terminals and removes the mapping from the Id
	 * to the cell.
	 * 
	 * @param cell Cell that has been removed.
	 */
  void _cellRemoved(Object cell) {
    if (cell is ICell) {
      ICell mxc = cell as ICell;
      int childCount = mxc.getChildCount();

      for (int i = 0; i < childCount; i++) {
        _cellRemoved(mxc.getChildAt(i));
      }

      if (_cells != null && mxc.getId() != null) {
        _cells.remove(mxc.getId());
      }
    }
  }

  /**
	 * Inner callback to update the parent of a cell using Cell.insert
	 * on the parent and return the previous parent.
	 */
  Object _parentForCellChanged(Object cell, Object parent, int index) {
    ICell child = cell as ICell;
    ICell previous = getParent(cell) as ICell;

    if (parent != null) {
      if (parent != previous || previous.getIndex(child) != index) {
        (parent as ICell).insertAt(child, index);
      }
    } else if (previous != null) {
      int oldIndex = previous.getIndex(child);
      previous.remove(oldIndex);
    }

    // Checks if the previous parent was already in the
    // model and avoids calling cellAdded if it was.
    if (!contains(previous) && parent != null) {
      _cellAdded(cell);
    } else if (parent == null) {
      _cellRemoved(cell);
    }

    return previous;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getChildCount(Object)
	 */
  int getChildCount(Object cell) {
    return (cell is ICell) ? (cell as ICell).getChildCount() : 0;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getChildAt(Object, int)
	 */
  Object getChildAt(Object parent, int index) {
    return (parent is ICell) ? (parent as ICell).getChildAt(index) : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getTerminal(Object, boolean)
	 */
  Object getTerminal(Object edge, bool isSource) {
    return (edge is ICell) ? (edge as ICell).getTerminal(isSource) : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setTerminal(Object, Object, boolean)
	 */
  Object setTerminal(Object edge, Object terminal, bool isSource) {
    bool terminalChanged = terminal != getTerminal(edge, isSource);
    execute(new TerminalChange(this, edge, terminal, isSource));

    if (_maintainEdgeParent && terminalChanged) {
      updateEdgeParent(edge, getRoot());
    }

    return terminal;
  }

  /**
	 * Inner helper function to update the terminal of the edge using
	 * Cell.insertEdge and return the previous terminal.
	 */
  Object _terminalForCellChanged(Object edge, Object terminal, bool isSource) {
    ICell previous = getTerminal(edge, isSource) as ICell;

    if (terminal != null) {
      (terminal as ICell).insertEdge(edge as ICell, isSource);
    } else if (previous != null) {
      previous.removeEdge(edge as ICell, isSource);
    }

    return previous;
  }

  /**
	 * Updates the parents of the edges connected to the given cell and all its
	 * descendants so that each edge is contained in the nearest common
	 * ancestor.
	 * 
	 * @param cell Cell whose edges should be checked and updated.
	 */
  //	void updateEdgeParents(Object cell)
  //	{
  //		updateEdgeParents(cell, getRoot());
  //	}

  /**
	 * Updates the parents of the edges connected to the given cell and all its
	 * descendants so that the edge is contained in the nearest-common-ancestor.
	 * 
	 * @param cell Cell whose edges should be checked and updated.
	 * @param root Root of the cell hierarchy that contains all cells.
	 */
  void updateEdgeParents(Object cell, [Object root = null]) {
    if (root == null) {
      root = getRoot();
    }
    // Updates edges on children first
    int childCount = getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      Object child = getChildAt(cell, i);
      updateEdgeParents(child, root);
    }

    // Updates the parents of all connected edges
    int edgeCount = getEdgeCount(cell);
    List<Object> edges = new List<Object>(edgeCount);

    for (int i = 0; i < edgeCount; i++) {
      edges.add(getEdgeAt(cell, i));
    }

    Iterator<Object> it = edges.iterator;

    while (it.moveNext()) {
      Object edge = it.current();

      // Updates edge parent if edge and child have
      // a common root node (does not need to be the
      // model root node)
      if (isAncestor(root, edge)) {
        updateEdgeParent(edge, root);
      }
    }
  }

  /**
	 * Inner helper method to update the parent of the specified edge to the
	 * nearest-common-ancestor of its two terminals.
	 *
	 * @param edge Specifies the edge to be updated.
	 * @param root Current root of the model.
	 */
  void updateEdgeParent(Object edge, Object root) {
    Object source = getTerminal(edge, true);
    Object target = getTerminal(edge, false);
    Object cell = null;

    // Uses the first non-relative descendants of the source terminal
    while (source != null && !isEdge(source) && getGeometry(source) != null && getGeometry(source).isRelative()) {
      source = getParent(source);
    }

    // Uses the first non-relative descendants of the target terminal
    while (target != null && !isEdge(target) && getGeometry(target) != null && getGeometry(target).isRelative()) {
      target = getParent(target);
    }

    if (isAncestor(root, source) && isAncestor(root, target)) {
      if (source == target) {
        cell = getParent(source);
      } else {
        cell = getNearestCommonAncestor(source, target);
      }

      // Keeps the edge in the same layer
      if (cell != null && (getParent(cell) != root || isAncestor(cell, edge)) && getParent(edge) != cell) {
        Geometry geo = getGeometry(edge);

        if (geo != null) {
          Point2d origin1 = getOrigin(getParent(edge));
          Point2d origin2 = getOrigin(cell);

          double dx = origin2.getX() - origin1.getX();
          double dy = origin2.getY() - origin1.getY();

          geo = geo.clone() as Geometry;
          geo.translate(-dx, -dy);
          setGeometry(edge, geo);
        }

        add(cell, edge, getChildCount(cell));
      }
    }
  }

  /**
	 * Returns the absolute, accumulated origin for the children inside the
	 * given parent. 
	 */
  Point2d getOrigin(Object cell) {
    Point2d result = null;

    if (cell != null) {
      result = getOrigin(getParent(cell));

      if (!isEdge(cell)) {
        Geometry geo = getGeometry(cell);

        if (geo != null) {
          result.setX(result.getX() + geo.getX());
          result.setY(result.getY() + geo.getY());
        }
      }
    } else {
      result = new Point2d();
    }

    return result;
  }

  /**
	 * Returns the nearest common ancestor for the specified cells.
	 *
	 * @param cell1 Cell that specifies the first cell in the tree.
	 * @param cell2 Cell that specifies the second cell in the tree.
	 * @return Returns the nearest common ancestor of the given cells.
	 */
  Object getNearestCommonAncestor(Object cell1, Object cell2) {
    if (cell1 != null && cell2 != null) {
      // Creates the cell path for the second cell
      String path = CellPath.create(cell2 as ICell);

      if (path != null && path.length > 0) {
        // Bubbles through the ancestors of the first
        // cell to find the nearest common ancestor.
        Object cell = cell1;
        String current = CellPath.create(cell as ICell);

        while (cell != null) {
          Object parent = getParent(cell);

          // Checks if the cell path is equal to the beginning
          // of the given cell path
          if (path.indexOf(current + CellPath.PATH_SEPARATOR) == 0 && parent != null) {
            return cell;
          }

          current = CellPath.getParentPath(current);
          cell = parent;
        }
      }
    }

    return null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getEdgeCount(Object)
	 */
  int getEdgeCount(Object cell) {
    return (cell is ICell) ? (cell as ICell).getEdgeCount() : 0;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getEdgeAt(Object, int)
	 */
  Object getEdgeAt(Object parent, int index) {
    return (parent is ICell) ? (parent as ICell).getEdgeAt(index) : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isVertex(Object)
	 */
  bool isVertex(Object cell) {
    return (cell is ICell) ? (cell as ICell).isVertex() : false;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isEdge(Object)
	 */
  bool isEdge(Object cell) {
    return (cell is ICell) ? (cell as ICell).isEdge() : false;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isConnectable(Object)
	 */
  bool isConnectable(Object cell) {
    return (cell is ICell) ? (cell as ICell).isConnectable() : true;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getValue(Object)
	 */
  Object getValue(Object cell) {
    return (cell is ICell) ? (cell as ICell).getValue() : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setValue(Object, Object)
	 */
  Object setValue(Object cell, Object value) {
    execute(new ValueChange(this, cell, value));

    return value;
  }

  /**
	 * Inner callback to update the user object of the given Cell
	 * using Cell.setValue and return the previous value,
	 * that is, the return value of Cell.getValue.
	 */
  Object _valueForCellChanged(Object cell, Object value) {
    Object oldValue = (cell as ICell).getValue();
    (cell as ICell).setValue(value);

    return oldValue;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getGeometry(Object)
	 */
  Geometry getGeometry(Object cell) {
    return (cell is ICell) ? (cell as ICell).getGeometry() : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setGeometry(Object, Geometry)
	 */
  Geometry setGeometry(Object cell, Geometry geometry) {
    if (geometry != getGeometry(cell)) {
      execute(new GeometryChange(this, cell, geometry));
    }

    return geometry;
  }

  /**
	 * Inner callback to update the Geometry of the given Cell using
	 * Cell.setGeometry and return the previous Geometry.
	 */
  Geometry _geometryForCellChanged(Object cell, Geometry geometry) {
    Geometry previous = getGeometry(cell);
    (cell as ICell).setGeometry(geometry);

    return previous;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#getStyle(Object)
	 */
  String getStyle(Object cell) {
    return (cell is ICell) ? (cell as ICell).getStyle() : null;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setStyle(Object, String)
	 */
  String setStyle(Object cell, String style) {
    if (style == null || style != getStyle(cell)) {
      execute(new StyleChange(this, cell, style));
    }

    return style;
  }

  /**
	 * Inner callback to update the style of the given Cell
	 * using Cell.setStyle and return the previous style.
	 */
  String _styleForCellChanged(Object cell, String style) {
    String previous = getStyle(cell);
    (cell as ICell).setStyle(style);

    return previous;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isCollapsed(Object)
	 */
  bool isCollapsed(Object cell) {
    return (cell is ICell) ? (cell as ICell).isCollapsed() : false;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setCollapsed(Object, boolean)
	 */
  bool setCollapsed(Object cell, bool collapsed) {
    if (collapsed != isCollapsed(cell)) {
      execute(new CollapseChange(this, cell, collapsed));
    }

    return collapsed;
  }

  /**
	 * Inner callback to update the collapsed state of the
	 * given Cell using Cell.setCollapsed and return
	 * the previous collapsed state.
	 */
  bool _collapsedStateForCellChanged(Object cell, bool collapsed) {
    bool previous = isCollapsed(cell);
    (cell as ICell).setCollapsed(collapsed);

    return previous;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#isVisible(Object)
	 */
  bool isVisible(Object cell) {
    return (cell is ICell) ? (cell as ICell).isVisible() : false;
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#setVisible(Object, boolean)
	 */
  bool setVisible(Object cell, bool visible) {
    if (visible != isVisible(cell)) {
      execute(new VisibleChange(this, cell, visible));
    }

    return visible;
  }

  /**
	 * Sets the visible state of the given Cell using VisibleChange and
	 * adds the change to the current transaction.
	 */
  bool _visibleStateForCellChanged(Object cell, bool visible) {
    bool previous = isVisible(cell);
    (cell as ICell).setVisible(visible);

    return previous;
  }

  /**
	 * Executes the given atomic change and adds it to the current edit.
	 * 
	 * @param change Atomic change to be executed.
	 */
  void execute(AtomicGraphModelChange change) {
    change.execute();
    beginUpdate();
    _currentEdit.add(change);
    fireEvent(new EventObj(Event.EXECUTE, ["change", change]));
    endUpdate();
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#beginUpdate()
	 */
  void beginUpdate() {
    _updateLevel++;
    fireEvent(new EventObj(Event.BEGIN_UPDATE));
  }

  /* (non-Javadoc)
	 * @see graph.model.IGraphModel#endUpdate()
	 */
  void endUpdate() {
    _updateLevel--;

    if (!_endingUpdate) {
      _endingUpdate = _updateLevel == 0;
      fireEvent(new EventObj(Event.END_UPDATE, ["edit", _currentEdit]));

      try {
        if (_endingUpdate && !_currentEdit.isEmpty()) {
          fireEvent(new EventObj(Event.BEFORE_UNDO, ["edit", _currentEdit]));
          UndoableEdit tmp = _currentEdit;
          _currentEdit = _createUndoableEdit();
          tmp.dispatch();
          fireEvent(new EventObj(Event.UNDO, ["edit", tmp]));
        }
      } finally {
        _endingUpdate = false;
      }
    }
  }

  /**
	 * Merges the children of the given cell into the given target cell inside
	 * this model. All cells are cloned unless there is a corresponding cell in
	 * the model with the same id, in which case the source cell is ignored and
	 * all edges are connected to the corresponding cell in this model. Edges
	 * are considered to have no identity and are always cloned unless the
	 * cloneAllEdges flag is set to false, in which case edges with the same
	 * id in the target model are reconnected to reflect the terminals of the
	 * source edges.
	 * 
	 * @param from
	 * @param to
	 * @param cloneAllEdges
	 */
  void mergeChildren(ICell from, ICell to, bool cloneAllEdges) //throws CloneNotSupportedException
  {
    beginUpdate();
    try {
      Map<Object, Object> mapping = new Map<Object, Object>();
      _mergeChildrenImpl(from, to, cloneAllEdges, mapping);

      // Post-processes all edges in the mapping and
      // reconnects the terminals to the corresponding
      // cells in the target model
      Iterator<Object> it = mapping.keys.iterator;

      while (it.moveNext()) {
        Object edge = it.current();
        Object cell = mapping[edge];
        Object terminal = getTerminal(edge, true);

        if (terminal != null) {
          terminal = mapping[terminal];
          setTerminal(cell, terminal, true);
        }

        terminal = getTerminal(edge, false);

        if (terminal != null) {
          terminal = mapping[terminal];
          setTerminal(cell, terminal, false);
        }
      }
    } finally {
      endUpdate();
    }
  }

  /**
	 * Clones the children of the source cell into the given target cell in
	 * this model and adds an entry to the mapping that maps from the source
	 * cell to the target cell with the same id or the clone of the source cell
	 * that was inserted into this model.
	 */
  void _mergeChildrenImpl(ICell from, ICell to, bool cloneAllEdges, Map<Object, Object> mapping) //throws CloneNotSupportedException
  {
    beginUpdate();
    try {
      int childCount = from.getChildCount();

      for (int i = 0; i < childCount; i++) {
        ICell cell = from.getChildAt(i);
        String id = cell.getId();
        ICell target = ((id != null && (!isEdge(cell) || !cloneAllEdges)) ? getCell(id) : null) as ICell;

        // Clones and adds the child if no cell exists for the id
        if (target == null) {
          Cell clone = cell.clone() as Cell;
          clone.setId(id);

          // Do *NOT* use model.add as this will move the edge away
          // from the parent in updateEdgeParent if maintainEdgeParent
          // is enabled in the target model
          target = to.insert(clone);
          _cellAdded(target);
        }

        // Stores the mapping for later reconnecting edges
        mapping[cell] = target;

        // Recurses
        _mergeChildrenImpl(cell, target, cloneAllEdges, mapping);
      }
    } finally {
      endUpdate();
    }
  }

  /**
	 * Initializes the currentEdit field if the model is deserialized.
	 */
  void _readObject(ObjectInputStream ois) //throws IOException, ClassNotFoundException
  {
    ois.defaultReadObject();
    _currentEdit = _createUndoableEdit();
  }

  /**
	 * Returns the number of incoming or outgoing edges.
	 * 
	 * @param model Graph model that contains the connection data.
	 * @param cell Cell whose edges should be counted.
	 * @param outgoing bool that specifies if the number of outgoing or
	 * incoming edges should be returned.
	 * @return Returns the number of incoming or outgoing edges.
	 */
  //	static int getDirectedEdgeCount(IGraphModel model, Object cell,
  //			bool outgoing)
  //	{
  //		return getDirectedEdgeCount(model, cell, outgoing, null);
  //	}

  /**
	 * Returns the number of incoming or outgoing edges, ignoring the given
	 * edge.
	 *
	 * @param model Graph model that contains the connection data.
	 * @param cell Cell whose edges should be counted.
	 * @param outgoing bool that specifies if the number of outgoing or
	 * incoming edges should be returned.
	 * @param ignoredEdge Object that represents an edge to be ignored.
	 * @return Returns the number of incoming or outgoing edges.
	 */
  static int getDirectedEdgeCount(IGraphModel model, Object cell, bool outgoing, [Object ignoredEdge = null]) {
    int count = 0;
    int edgeCount = model.getEdgeCount(cell);

    for (int i = 0; i < edgeCount; i++) {
      Object edge = model.getEdgeAt(cell, i);

      if (edge != ignoredEdge && model.getTerminal(edge, outgoing) == cell) {
        count++;
      }
    }

    return count;
  }

  /**
	 * Returns all edges connected to this cell including loops.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @return Returns the array of connected edges for the given cell.
	 */
  //	static List<Object> getEdges(IGraphModel model, Object cell)
  //	{
  //		return getEdges(model, cell, true, true, true);
  //	}

  /**
	 * Returns all edges connected to this cell without loops.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @return Returns the connected edges for the given cell.
	 */
  static List<Object> getConnections(IGraphModel model, Object cell) {
    return getEdges(model, cell, true, true, false);
  }

  /**
	 * Returns the incoming edges of the given cell without loops.
	 * 
	 * @param model Graphmodel that contains the edges.
	 * @param cell Cell whose incoming edges should be returned.
	 * @return Returns the incoming edges for the given cell.
	 */
  static List<Object> getIncomingEdges(IGraphModel model, Object cell) {
    return getEdges(model, cell, true, false, false);
  }

  /**
	 * Returns the outgoing edges of the given cell without loops.
	 * 
	 * @param model Graphmodel that contains the edges.
	 * @param cell Cell whose outgoing edges should be returned.
	 * @return Returns the outgoing edges for the given cell.
	 */
  static List<Object> getOutgoingEdges(IGraphModel model, Object cell) {
    return getEdges(model, cell, false, true, false);
  }

  /**
	 * Returns all distinct edges connected to this cell.
	 *
	 * @param model Model that contains the connection information.
	 * @param cell Cell whose connections should be returned.
	 * @param incoming Specifies if incoming edges should be returned.
	 * @param outgoing Specifies if outgoing edges should be returned.
	 * @param includeLoops Specifies if loops should be returned.
	 * @return Returns the array of connected edges for the given cell.
	 */
  static List<Object> getEdges(IGraphModel model, Object cell, [bool incoming = true, bool outgoing = true, bool includeLoops = true]) {
    int edgeCount = model.getEdgeCount(cell);
    List<Object> result = new List<Object>(edgeCount);

    for (int i = 0; i < edgeCount; i++) {
      Object edge = model.getEdgeAt(cell, i);
      Object source = model.getTerminal(edge, true);
      Object target = model.getTerminal(edge, false);

      if ((includeLoops && source == target) || ((source != target) && ((incoming && target == cell) || (outgoing && source == cell)))) {
        result.add(edge);
      }
    }

    return result;
  }

  /**
	 * Returns all edges from the given source to the given target.
	 * 
	 * @param model The graph model that contains the graph.
	 * @param source Object that defines the source cell.
	 * @param target Object that defines the target cell.
	 * @return Returns all edges from source to target.
	 */
  //	static List<Object> getEdgesBetween(IGraphModel model, Object source,
  //			Object target)
  //	{
  //		return getEdgesBetween(model, source, target, false);
  //	}

  /**
	 * Returns all edges between the given source and target pair. If directed
	 * is true, then only edges from the source to the target are returned,
	 * otherwise, all edges between the two cells are returned.
	 * 
	 * @param model The graph model that contains the graph.
	 * @param source Object that defines the source cell.
	 * @param target Object that defines the target cell.
	 * @param directed bool that specifies if the direction of the edge
	 * should be taken into account.
	 * @return Returns all edges between the given source and target.
	 */
  static List<Object> getEdgesBetween(IGraphModel model, Object source, Object target, [bool directed = false]) {
    int tmp1 = model.getEdgeCount(source);
    int tmp2 = model.getEdgeCount(target);

    // Assumes the source has less connected edges
    Object terminal = source;
    int edgeCount = tmp1;

    // Uses the smaller array of connected edges
    // for searching the edge
    if (tmp2 < tmp1) {
      edgeCount = tmp2;
      terminal = target;
    }

    List<Object> result = new List<Object>(edgeCount);

    // Checks if the edge is connected to the correct
    // cell and returns the first match
    for (int i = 0; i < edgeCount; i++) {
      Object edge = model.getEdgeAt(terminal, i);
      Object src = model.getTerminal(edge, true);
      Object trg = model.getTerminal(edge, false);
      bool directedMatch = (src == source) && (trg == target);
      bool oppositeMatch = (trg == source) && (src == target);

      if (directedMatch || (!directed && oppositeMatch)) {
        result.add(edge);
      }
    }

    return result;
  }

  /**
	 * Returns all opposite cells of terminal for the given edges.
	 * 
	 * @param model Model that contains the connection information.
	 * @param edges Array of edges to be examined.
	 * @param terminal Cell that specifies the known end of the edges.
	 * @return Returns the opposite cells of the given terminal.
	 */
  //	static List<Object> getOpposites(IGraphModel model, List<Object> edges,
  //			Object terminal)
  //	{
  //		return getOpposites(model, edges, terminal, true, true);
  //	}

  /**
	 * Returns all opposite vertices wrt terminal for the given edges, only
	 * returning sources and/or targets as specified. The result is returned as
	 * an array of mxCells.
	 * 
	 * @param model Model that contains the connection information.
	 * @param edges Array of edges to be examined.
	 * @param terminal Cell that specifies the known end of the edges.
	 * @param sources bool that specifies if source terminals should
	 * be contained in the result. Default is true.
	 * @param targets bool that specifies if target terminals should
	 * be contained in the result. Default is true.
	 * @return Returns the array of opposite terminals for the given edges.
	 */
  static List<Object> getOpposites(IGraphModel model, List<Object> edges, Object terminal, [bool sources = true, bool targets = true]) {
    List<Object> terminals = new List<Object>();

    if (edges != null) {
      for (int i = 0; i < edges.length; i++) {
        Object source = model.getTerminal(edges[i], true);
        Object target = model.getTerminal(edges[i], false);

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

    return terminals;
  }

  /**
	 * Sets the source and target of the given edge in a single atomic change.
	 * 
	 * @param edge Cell that specifies the edge.
	 * @param source Cell that specifies the new source terminal.
	 * @param target Cell that specifies the new target terminal.
	 */
  static void setTerminals(IGraphModel model, Object edge, Object source, Object target) {
    model.beginUpdate();
    try {
      model.setTerminal(edge, source, true);
      model.setTerminal(edge, target, false);
    } finally {
      model.endUpdate();
    }
  }

  /**
	 * Returns all children of the given cell regardless of their type.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices or edges should be returned.
	 * @return Returns the child vertices and/or edges of the given parent.
	 */
  static List<Object> getChildren(IGraphModel model, Object parent) {
    return getChildCells(model, parent, false, false);
  }

  /**
	 * Returns the child vertices of the given parent.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices should be returned.
	 * @return Returns the child vertices of the given parent.
	 */
  static List<Object> getChildVertices(IGraphModel model, Object parent) {
    return getChildCells(model, parent, true, false);
  }

  /**
	 * Returns the child edges of the given parent.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child edges should be returned.
	 * @return Returns the child edges of the given parent.
	 */
  static List<Object> getChildEdges(IGraphModel model, Object parent) {
    return getChildCells(model, parent, false, true);
  }

  /**
	 * Returns the children of the given cell that are vertices and/or edges
	 * depending on the arguments. If both arguments are false then all
	 * children are returned regardless of their type.
	 *
	 * @param model Model that contains the hierarchical information.
	 * @param parent Cell whose child vertices or edges should be returned.
	 * @param vertices bool indicating if child vertices should be returned.
	 * @param edges bool indicating if child edges should be returned.
	 * @return Returns the child vertices and/or edges of the given parent.
	 */
  static List<Object> getChildCells(IGraphModel model, Object parent, bool vertices, bool edges) {
    int childCount = model.getChildCount(parent);
    List<Object> result = new List<Object>(childCount);

    for (int i = 0; i < childCount; i++) {
      Object child = model.getChildAt(parent, i);

      if ((!edges && !vertices) || (edges && model.isEdge(child)) || (vertices && model.isVertex(child))) {
        result.add(child);
      }
    }

    return result;
  }

  /**
	 * 
	 */
  static List<Object> getParents(IGraphModel model, List<Object> cells) {
    HashSet<Object> parents = new HashSet<Object>();

    if (cells != null) {
      for (int i = 0; i < cells.length; i++) {
        Object parent = model.getParent(cells[i]);

        if (parent != null) {
          parents.add(parent);
        }
      }
    }

    return parents;
  }

  /**
	 * 
	 */
  static List<Object> filterCells(List<Object> cells, Filter filter) {
    List<Object> result = null;

    if (cells != null) {
      result = new List<Object>(cells.length);

      for (int i = 0; i < cells.length; i++) {
        if (filter.filter(cells[i])) {
          result.add(cells[i]);
        }
      }
    }

    return (result != null) ? result : null;
  }

  /**
	 * Returns a all descendants of the given cell and the cell itself
	 * as a collection.
	 */
  static List<Object> getDescendants(IGraphModel model, Object parent) {
    return filterDescendants(model, null, parent);
  }

  /**
	 * Creates a collection of cells using the visitor pattern.
	 */
  //	static Collection<Object> filterDescendants(IGraphModel model,
  //			Filter filter)
  //	{
  //		return filterDescendants(model, filter, model.getRoot());
  //	}

  /**
	 * Creates a collection of cells using the visitor pattern.
	 */
  static List<Object> filterDescendants(IGraphModel model, Filter filter, [Object parent = null]) {
    if (parent == null) {
      parent = model.getRoot();
    }
    List<Object> result = new List<Object>();

    if (filter == null || filter.filter(parent)) {
      result.add(parent);
    }

    int childCount = model.getChildCount(parent);

    for (int i = 0; i < childCount; i++) {
      Object child = model.getChildAt(parent, i);
      result.addAll(filterDescendants(model, filter, child));
    }

    return result;
  }

  /**
	 * Function: getTopmostCells
	 * 
	 * Returns the topmost cells of the hierarchy in an array that contains no
	 * desceandants for each <Cell> that it contains. Duplicates should be
	 * removed in the cells array to improve performance.
	 * 
	 * Parameters:
	 * 
	 * cells - Array of <mxCells> whose topmost ancestors should be returned.
	 */
  static List<Object> getTopmostCells(IGraphModel model, List<Object> cells) {
    Set<Object> hash = new HashSet<Object>();
    hash.addAll(cells);
    List<Object> result = new List<Object>(cells.length);

    for (int i = 0; i < cells.length; i++) {
      Object cell = cells[i];
      bool topmost = true;
      Object parent = model.getParent(cell);

      while (parent != null) {
        if (hash.contains(parent)) {
          topmost = false;
          break;
        }

        parent = model.getParent(parent);
      }

      if (topmost) {
        result.add(cell);
      }
    }

    return result;
  }

  //
  // Visitor patterns
  //

  //
  // Atomic changes
  //

}

class GraphModelUndoableEdit extends UndoableEdit {
  GraphModelUndoableEdit(Object source) : super(source);

  void dispatch()
  {
    // LATER: Remove changes property (deprecated)
    (source as GraphModel).fireEvent(new EventObj(
        Event.CHANGE, ["edit", this, "changes", changes]));
  }
}