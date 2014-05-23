package graph.model;

import graph.model.IGraphModel.AtomicGraphModelChange;

public class CollapseChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell;

	/**
	 * 
	 */
	protected boolean collapsed, previous;

	/**
	 * 
	 */
	public CollapseChange()
	{
		this(null, null, false);
	}

	/**
	 * 
	 */
	public CollapseChange(GraphModel model, Object cell,
			boolean collapsed)
	{
		super(model);
		this.cell = cell;
		this.collapsed = collapsed;
		this.previous = this.collapsed;
	}

	/**
	 * 
	 */
	public void setCell(Object value)
	{
		cell = value;
	}

	/**
	 * @return the cell
	 */
	public Object getCell()
	{
		return cell;
	}

	/**
	 * 
	 */
	public void setCollapsed(boolean value)
	{
		collapsed = value;
	}

	/**
	 * @return the collapsed
	 */
	public boolean isCollapsed()
	{
		return collapsed;
	}

	/**
	 * 
	 */
	public void setPrevious(boolean value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	public boolean getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	public void execute()
	{
		collapsed = previous;
		previous = ((GraphModel) model)._collapsedStateForCellChanged(
				cell, previous);
	}

}