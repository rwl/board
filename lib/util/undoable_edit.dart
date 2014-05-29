/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.util;

//import java.util.ArrayList;
//import java.util.List;

/**
 * Defines the requirements for an undoable change.
 */
abstract class UndoableChange {

  /**
   * Undoes or redoes the change depending on its undo state.
   */
  void execute();

}

/**
 * Implements a 2-dimensional rectangle with double precision coordinates.
 */
class UndoableEdit {

  /**
	 * Holds the source of the undoable edit.
	 */
  Object _source;

  /**
	 * Holds the list of changes that make up this undoable edit.
	 */
  List<UndoableChange> _changes = new List<UndoableChange>();

  /**
	 * Specifies this undoable edit is significant. Default is true.
	 */
  bool _significant = true;

  /**
	 * Specifies the state of the undoable edit.
	 */
  bool _undone, _redone;

  /**
	 * Constructs a new undoable edit for the given source.
	 */
  //	UndoableEdit(Object source)
  //	{
  //		this(source, true);
  //	}

  /**
	 * Constructs a new undoable edit for the given source.
	 */
  UndoableEdit(Object source, [bool significant = true]) {
    this._source = source;
    this._significant = significant;
  }

  /**
	 * Hook to notify any listeners of the changes after an undo or redo
	 * has been carried out. This implementation is empty.
	 */
  void dispatch() {
    // empty
  }

  /**
	 * Hook to free resources after the edit has been removed from the command
	 * history. This implementation is empty.
	 */
  void die() {
    // empty
  }

  /**
	 * @return the source
	 */
  Object getSource() {
    return _source;
  }

  Object get source => _source;

  /**
	 * @return the changes
	 */
  List<UndoableChange> getChanges() {
    return _changes;
  }

  List<UndoableChange> get changes => _changes;

  /**
	 * @return the significant
	 */
  bool isSignificant() {
    return _significant;
  }

  /**
	 * @return the undone
	 */
  bool isUndone() {
    return _undone;
  }

  /**
	 * @return the redone
	 */
  bool isRedone() {
    return _redone;
  }

  /**
	 * Returns true if the this edit contains no changes.
	 */
  bool isEmpty() {
    return _changes.isEmpty();
  }

  /**
	 * Adds the specified change to this edit. The change is an object that is
	 * expected to either have an undo and redo, or an execute function.
	 */
  void add(UndoableChange change) {
    _changes.add(change);
  }

  /**
	 * 
	 */
  void undo() {
    if (!_undone) {
      int count = _changes.length;

      for (int i = count - 1; i >= 0; i--) {
        UndoableChange change = _changes[i];
        change.execute();
      }

      _undone = true;
      _redone = false;
    }

    dispatch();
  }

  /**
	 * 
	 */
  void redo() {
    if (!_redone) {
      int count = _changes.length;

      for (int i = 0; i < count; i++) {
        UndoableChange change = _changes[i];
        change.execute();
      }

      _undone = false;
      _redone = true;
    }

    dispatch();
  }

}
