/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.util;

//import java.util.ArrayList;
//import java.util.List;

/**
 * Implements an undo history.
 * 
 * This class fires the following events:
 * 
 * Event.CLEAR fires after clear was executed. The event has no properties.
 * 
 * Event.UNDO fires afer a significant edit was undone in undo. The
 * <code>edit</code> property contains the UndoableEdit that was undone.
 * 
 * Event.REDO fires afer a significant edit was redone in redo. The
 * <code>edit</code> property contains the UndoableEdit that was redone.
 * 
 * Event.ADD fires after an undoable edit was added to the history. The
 * <code>edit</code> property contains the UndoableEdit that was added.
 */
class UndoManager extends EventSource {

  /**
	 * Maximum command history size. 0 means unlimited history. Default is 100.
	 */
  int _size;

  /**
	 * List that contains the steps of the command history.
	 */
  List<UndoableEdit> _history;

  /**
	 * Index of the element to be added next.
	 */
  int _indexOfNextAdd;

  /**
	 * Constructs a new undo manager with a default history size.
	 */
  //	UndoManager()
  //	{
  //		this(100);
  //	}

  /**
	 * Constructs a new undo manager for the specified size.
	 */
  UndoManager([int size = 100]) {
    this._size = size;
    clear();
  }

  /**
	 * 
	 */
  bool isEmpty() {
    return _history.isEmpty();
  }

  /**
	 * Clears the command history.
	 */
  void clear() {
    _history = new List<UndoableEdit>(_size);
    _indexOfNextAdd = 0;
    fireEvent(new EventObj(Event.CLEAR));
  }

  /**
	 * Returns true if an undo is possible.
	 */
  bool canUndo() {
    return _indexOfNextAdd > 0;
  }

  /**
	 * Undoes the last change.
	 */
  void undo() {
    while (_indexOfNextAdd > 0) {
      UndoableEdit edit = _history.get(--_indexOfNextAdd);
      edit.undo();

      if (edit.isSignificant()) {
        fireEvent(new EventObj(Event.UNDO, "edit", edit));
        break;
      }
    }
  }

  /**
	 * Returns true if a redo is possible.
	 */
  bool canRedo() {
    return _indexOfNextAdd < _history.size();
  }

  /**
	 * Redoes the last change.
	 */
  void redo() {
    int n = _history.size();

    while (_indexOfNextAdd < n) {
      UndoableEdit edit = _history.get(_indexOfNextAdd++);
      edit.redo();

      if (edit.isSignificant()) {
        fireEvent(new EventObj(Event.REDO, "edit", edit));
        break;
      }
    }
  }

  /**
	 * Method to be called to add new undoable edits to the history.
	 */
  void undoableEditHappened(UndoableEdit undoableEdit) {
    _trim();

    if (_size > 0 && _size == _history.size()) {
      _history.remove(0);
    }

    _history.add(undoableEdit);
    _indexOfNextAdd = _history.size();
    fireEvent(new EventObj(Event.ADD, "edit", undoableEdit));
  }

  /**
	 * Removes all pending steps after indexOfNextAdd from the history,
	 * invoking die on each edit. This is called from undoableEditHappened.
	 */
  void _trim() {
    while (_history.size() > _indexOfNextAdd) {
      UndoableEdit edit = _history.remove(_indexOfNextAdd);
      edit.die();
    }
  }

}
