package graph.model;

//import graph.model.IGraphModel.AtomicGraphModelChange;

public class VisibleChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell;

	/**
	 * 
	 */
	protected boolean visible, previous;

	/**
	 * 
	 */
	public VisibleChange()
	{
		this(null, null, false);
	}

	/**
	 * 
	 */
	public VisibleChange(GraphModel model, Object cell, boolean visible)
	{
		super(model);
		this.cell = cell;
		this.visible = visible;
		this.previous = this.visible;
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
	public void setVisible(boolean value)
	{
		visible = value;
	}

	/**
	 * @return the visible
	 */
	public boolean isVisible()
	{
		return visible;
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
		visible = previous;
		previous = ((GraphModel) model)._visibleStateForCellChanged(cell,
				previous);
	}

}