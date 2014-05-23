/**
 * $Id: UndoManager.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
package graph.util;

import java.util.ArrayList;
import java.util.List;

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
public class UndoManager extends EventSource
{

	/**
	 * Maximum command history size. 0 means unlimited history. Default is 100.
	 */
	protected int _size;

	/**
	 * List that contains the steps of the command history.
	 */
	protected List<UndoableEdit> _history;

	/**
	 * Index of the element to be added next.
	 */
	protected int _indexOfNextAdd;

	/**
	 * Constructs a new undo manager with a default history size.
	 */
	public UndoManager()
	{
		this(100);
	}

	/**
	 * Constructs a new undo manager for the specified size.
	 */
	public UndoManager(int size)
	{
		this._size = size;
		clear();
	}

	/**
	 * 
	 */
	public boolean isEmpty()
	{
		return _history.isEmpty();
	}

	/**
	 * Clears the command history.
	 */
	public void clear()
	{
		_history = new ArrayList<UndoableEdit>(_size);
		_indexOfNextAdd = 0;
		fireEvent(new EventObj(Event.CLEAR));
	}

	/**
	 * Returns true if an undo is possible.
	 */
	public boolean canUndo()
	{
		return _indexOfNextAdd > 0;
	}

	/**
	 * Undoes the last change.
	 */
	public void undo()
	{
		while (_indexOfNextAdd > 0)
		{
			UndoableEdit edit = _history.get(--_indexOfNextAdd);
			edit.undo();

			if (edit.isSignificant())
			{
				fireEvent(new EventObj(Event.UNDO, "edit", edit));
				break;
			}
		}
	}

	/**
	 * Returns true if a redo is possible.
	 */
	public boolean canRedo()
	{
		return _indexOfNextAdd < _history.size();
	}

	/**
	 * Redoes the last change.
	 */
	public void redo()
	{
		int n = _history.size();

		while (_indexOfNextAdd < n)
		{
			UndoableEdit edit = _history.get(_indexOfNextAdd++);
			edit.redo();

			if (edit.isSignificant())
			{
				fireEvent(new EventObj(Event.REDO, "edit", edit));
				break;
			}
		}
	}

	/**
	 * Method to be called to add new undoable edits to the history.
	 */
	public void undoableEditHappened(UndoableEdit undoableEdit)
	{
		_trim();

		if (_size > 0 && _size == _history.size())
		{
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
	protected void _trim()
	{
		while (_history.size() > _indexOfNextAdd)
		{
			UndoableEdit edit = _history
					.remove(_indexOfNextAdd);
			edit.die();
		}
	}

}
