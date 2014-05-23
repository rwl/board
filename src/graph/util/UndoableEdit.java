/**
 * $Id: UndoableEdit.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
package graph.util;

import java.util.ArrayList;
import java.util.List;

/**
 * Implements a 2-dimensional rectangle with double precision coordinates.
 */
public class UndoableEdit
{

	/**
	 * Defines the requirements for an undoable change.
	 */
	public interface UndoableChange
	{

		/**
		 * Undoes or redoes the change depending on its undo state.
		 */
		void execute();

	}

	/**
	 * Holds the source of the undoable edit.
	 */
	protected Object _source;

	/**
	 * Holds the list of changes that make up this undoable edit.
	 */
	protected List<UndoableChange> _changes = new ArrayList<UndoableChange>();

	/**
	 * Specifies this undoable edit is significant. Default is true.
	 */
	protected boolean _significant = true;

	/**
	 * Specifies the state of the undoable edit.
	 */
	protected boolean _undone, _redone;

	/**
	 * Constructs a new undoable edit for the given source.
	 */
	public UndoableEdit(Object source)
	{
		this(source, true);
	}

	/**
	 * Constructs a new undoable edit for the given source.
	 */
	public UndoableEdit(Object source, boolean significant)
	{
		this._source = source;
		this._significant = significant;
	}

	/**
	 * Hook to notify any listeners of the changes after an undo or redo
	 * has been carried out. This implementation is empty.
	 */
	public void dispatch()
	{
		// empty
	}

	/**
	 * Hook to free resources after the edit has been removed from the command
	 * history. This implementation is empty.
	 */
	public void die()
	{
		// empty
	}

	/**
	 * @return the source
	 */
	public Object getSource()
	{
		return _source;
	}

	/**
	 * @return the changes
	 */
	public List<UndoableChange> getChanges()
	{
		return _changes;
	}

	/**
	 * @return the significant
	 */
	public boolean isSignificant()
	{
		return _significant;
	}

	/**
	 * @return the undone
	 */
	public boolean isUndone()
	{
		return _undone;
	}

	/**
	 * @return the redone
	 */
	public boolean isRedone()
	{
		return _redone;
	}

	/**
	 * Returns true if the this edit contains no changes.
	 */
	public boolean isEmpty()
	{
		return _changes.isEmpty();
	}

	/**
	 * Adds the specified change to this edit. The change is an object that is
	 * expected to either have an undo and redo, or an execute function.
	 */
	public void add(UndoableChange change)
	{
		_changes.add(change);
	}

	/**
	 * 
	 */
	public void undo()
	{
		if (!_undone)
		{
			int count = _changes.size();

			for (int i = count - 1; i >= 0; i--)
			{
				UndoableChange change = _changes.get(i);
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
	public void redo()
	{
		if (!_redone)
		{
			int count = _changes.size();

			for (int i = 0; i < count; i++)
			{
				UndoableChange change = _changes.get(i);
				change.execute();
			}

			_undone = false;
			_redone = true;
		}

		dispatch();
	}

}
