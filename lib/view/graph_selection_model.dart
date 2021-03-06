/*
 * $Id: GraphSelectionModel.java,v 1.1 2012/11/15 13:26:46 gaudenz Exp $
 * Copyright (c) 2001-2005, Gaudenz Alder
 * 
 * All rights reserved.
 * 
 * See LICENSE file for license details. If you are unable to locate
 * this file please contact info (at) jgraph (dot) com.
 */
part of graph.view;


/**
 * Implements the selection model for a graph.
 * 
 * This class fires the following events:
 * 
 * Event.UNDO fires after the selection was changed in changeSelection. The
 * <code>edit</code> property contains the UndoableEdit which contains the
 * SelectionChange.
 * 
 * Event.CHANGE fires after the selection changes by executing an
 * SelectionChange. The <code>added</code> and <code>removed</code>
 * properties contain Collections of cells that have been added to or removed
 * from the selection, respectively.
 *  
 * To add a change listener to the graph selection model:
 * 
 * <code>
 * addListener(
 *   Event.CHANGE, new IEventListener()
 *   {
 *     public void invoke(Object sender, EventObj evt)
 *     {
 *       GraphSelectionModel model = (mxSelectionModel) sender;
 *       Collection added = (Collection) evt.getProperty("added");
 *       Collection removed = (Collection) evt.getProperty("removed");
 *       selectionChanged(model, added, removed);
 *     }
 *   });
 * </code>
 */
class GraphSelectionModel extends EventSource {

  /**
   * Reference to the enclosing graph.
   */
  Graph _graph;

  /**
   * Specifies if only one selected item at a time is allowed.
   * Default is false.
   */
  bool _singleSelection = false;

  /**
   * Holds the selection cells.
   */
  Set<Object> _cells = new LinkedHashSet<Object>();

  /**
   * Constructs a new selection model for the specified graph.
   * 
   * @param graph
   */
  GraphSelectionModel(Graph graph) {
    this._graph = graph;
  }

  /**
   * @return the singleSelection
   */
  bool isSingleSelection() {
    return _singleSelection;
  }

  /**
   * @param singleSelection the singleSelection to set
   */
  void setSingleSelection(bool singleSelection) {
    this._singleSelection = singleSelection;
  }

  /**
   * Returns true if the given cell is selected.
   * 
   * @param cell
   * @return Returns true if the given cell is selected.
   */
  bool isSelected(Object cell) {
    return (cell == null) ? false : _cells.contains(cell);
  }

  /**
   * Returns true if no cells are selected.
   */
  bool isEmpty() {
    return _cells.length == 0;
  }

  /**
   * Returns the number of selected cells.
   */
  int size() {
    return _cells.length;
  }

  /**
   * Clears the selection.
   */
  void clear() {
    _changeSelection(null, _cells);
  }

  /**
   * Returns the first selected cell.
   */
  Object getCell() {
    return (_cells.length == 0) ? null : _cells.iterator.current;
  }

  /**
   * Returns the selection cells.
   */
  List<Object> getCells() {
    return new List<Object>.from(_cells);
  }

  /**
   * Clears the selection and adds the given cell to the selection.
   */
  void setCell(Object cell) {
    if (cell != null) {
      setCells([cell]);
    } else {
      clear();
    }
  }

  /**
   * Clears the selection and adds the given cells.
   */
  void setCells(List<Object> cells) {
    if (cells != null) {
      if (_singleSelection) {
        cells = [_getFirstSelectableCell(cells)];
      }

      List<Object> tmp = new List<Object>(cells.length);

      for (int i = 0; i < cells.length; i++) {
        if (_graph.isCellSelectable(cells[i])) {
          tmp.add(cells[i]);
        }
      }

      _changeSelection(tmp, this._cells);
    } else {
      clear();
    }
  }

  /**
   * Returns the first selectable cell in the given array of cells.
   * 
   * @param cells Array of cells to return the first selectable cell for.
   * @return Returns the first cell that may be selected.
   */
  Object _getFirstSelectableCell(List<Object> cells) {
    if (cells != null) {
      for (int i = 0; i < cells.length; i++) {
        if (_graph.isCellSelectable(cells[i])) {
          return cells[i];
        }
      }
    }

    return null;
  }

  /**
   * Adds the given cell to the selection.
   */
  void addCell(Object cell) {
    if (cell != null) {
      addCells([cell]);
    }
  }

  void addCells(List<Object> cells) {
    if (cells != null) {
      Iterable<Object> remove = null;

      if (_singleSelection) {
        remove = this._cells;
        cells = [_getFirstSelectableCell(cells)];
      }

      List<Object> tmp = new List<Object>(cells.length);

      for (int i = 0; i < cells.length; i++) {
        if (!isSelected(cells[i]) && _graph.isCellSelectable(cells[i])) {
          tmp.add(cells[i]);
        }
      }

      _changeSelection(tmp, remove);
    }
  }

  /**
   * Removes the given cell from the selection.
   */
  void removeCell(Object cell) {
    if (cell != null) {
      removeCells([cell]);
    }
  }

  void removeCells(List<Object> cells) {
    if (cells != null) {
      List<Object> tmp = new List<Object>(cells.length);

      for (int i = 0; i < cells.length; i++) {
        if (isSelected(cells[i])) {
          tmp.add(cells[i]);
        }
      }

      _changeSelection(null, tmp);
    }
  }

  void _changeSelection(Iterable<Object> added, Iterable<Object> removed) {
    if ((added != null && added.length > 0) || (removed != null && removed.length > 0)) {
      SelectionChange change = new SelectionChange(this, added, removed);
      change.execute();
      UndoableEdit edit = new UndoableEdit(this, false);
      edit.add(change);
      fireEvent(new EventObj(Event.UNDO, ["edit", edit]));
    }
  }

  void _cellAdded(Object cell) {
    if (cell != null) {
      _cells.add(cell);
    }
  }

  void _cellRemoved(Object cell) {
    if (cell != null) {
      _cells.remove(cell);
    }
  }

}

/**
 *
 */
class SelectionChange implements UndoableChange {

  GraphSelectionModel model;

  List<Object> added, removed;

  /**
   * 
   * @param model
   * @param added
   * @param removed
   */
  SelectionChange(GraphSelectionModel model, Iterable<Object> added, Iterable<Object> removed) {
    this.model = model;
    this.added = (added != null) ? new List<Object>.from(added) : null;
    this.removed = (removed != null) ? new List<Object>.from(removed) : null;
  }

  void execute() {
    if (removed != null) {
      Iterator<Object> it = removed.iterator;

      while (it.moveNext()) {
        model._cellRemoved(it.current);
      }
    }

    if (added != null) {
      Iterator<Object> it = added.iterator;

      while (it.moveNext()) {
        model._cellAdded(it.current);
      }
    }

    Iterable<Object> tmp = added;
    added = removed;
    removed = tmp;
    model.fireEvent(new EventObj(Event.CHANGE, ["added", added, "removed", removed]));
  }

}
