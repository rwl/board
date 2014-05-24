part of graph.model;

import '../model/model.dart' show AtomicGraphModelChange;

class ChildChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object parent, previous, child;

	/**
	 * 
	 */
	int index, previousIndex;

	/**
	 * 
	 */
	ChildChange()
	{
		this(null, null, null, 0);
	}

	/**
	 * 
	 */
	ChildChange(GraphModel model, Object parent, Object child)
	{
		this(model, parent, child, 0);
	}

	/**
	 * 
	 */
	ChildChange(GraphModel model, Object parent, Object child,
			int index)
	{
		super(model);
		this.parent = parent;
		previous = this.parent;
		this.child = child;
		this.index = index;
		previousIndex = index;
	}

	/**
	 *
	 */
	void setParent(Object value)
	{
		parent = value;
	}

	/**
	 * @return the parent
	 */
	Object getParent()
	{
		return parent;
	}

	/**
	 *
	 */
	void setPrevious(Object value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	Object getPrevious()
	{
		return previous;
	}

	/**
	 *
	 */
	void setChild(Object value)
	{
		child = value;
	}

	/**
	 * @return the child
	 */
	Object getChild()
	{
		return child;
	}

	/**
	 *
	 */
	void setIndex(int value)
	{
		index = value;
	}

	/**
	 * @return the index
	 */
	int getIndex()
	{
		return index;
	}

	/**
	 *
	 */
	void setPreviousIndex(int value)
	{
		previousIndex = value;
	}

	/**
	 * @return the previousIndex
	 */
	int getPreviousIndex()
	{
		return previousIndex;
	}

	/**
	 * Gets the source or target terminal field for the given
	 * edge even if the edge is not stored as an incoming or
	 * outgoing edge in the respective terminal.
	 */
	Object getTerminal(Object edge, bool source)
	{
		return model.getTerminal(edge, source);
	}

	/**
	 * Sets the source or target terminal field for the given edge
	 * without inserting an incoming or outgoing edge in the
	 * respective terminal.
	 */
	void setTerminal(Object edge, Object terminal, bool source)
	{
		((ICell) edge).setTerminal((ICell) terminal, source);
	}

	/**
	 * 
	 */
	void connect(Object cell, bool isConnect)
	{
		Object source = getTerminal(cell, true);
		Object target = getTerminal(cell, false);

		if (source != null)
		{
			if (isConnect)
			{
				((GraphModel) model)._terminalForCellChanged(cell, source,
						true);
			}
			else
			{
				((GraphModel) model)._terminalForCellChanged(cell, null,
						true);
			}
		}

		if (target != null)
		{
			if (isConnect)
			{
				((GraphModel) model)._terminalForCellChanged(cell, target,
						false);
			}
			else
			{
				((GraphModel) model)._terminalForCellChanged(cell, null,
						false);
			}
		}

		// Stores the previous terminals in the edge
		setTerminal(cell, source, true);
		setTerminal(cell, target, false);

		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			connect(model.getChildAt(cell, i), isConnect);
		}
	}

	/**
	 * Returns the index of the given child inside the given parent.
	 */
	int getChildIndex(Object parent, Object child)
	{
		return (parent instanceof ICell && child instanceof ICell) ? ((ICell) parent)
				.getIndex((ICell) child) : 0;
	}

	/**
	 * Changes the root of the model.
	 */
	void execute()
	{
		Object tmp = model.getParent(child);
		int tmp2 = getChildIndex(tmp, child);

		if (previous == null)
		{
			connect(child, false);
		}

		tmp = ((GraphModel) model)._parentForCellChanged(child, previous,
				previousIndex);

		if (previous != null)
		{
			connect(child, true);
		}

		parent = previous;
		previous = tmp;
		index = previousIndex;
		previousIndex = tmp2;
	}

}