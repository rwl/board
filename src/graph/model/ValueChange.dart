package graph.model;

//import graph.model.IGraphModel.AtomicGraphModelChange;

public class ValueChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell, value, previous;

	/**
	 * 
	 */
	public ValueChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	public ValueChange(GraphModel model, Object cell, Object value)
	{
		super(model);
		this.cell = cell;
		this.value = value;
		this.previous = this.value;
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
	public void setValue(Object value)
	{
		this.value = value;
	}

	/**
	 * @return the value
	 */
	public Object getValue()
	{
		return value;
	}

	/**
	 * 
	 */
	public void setPrevious(Object value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	public Object getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	public void execute()
	{
		value = previous;
		previous = ((GraphModel) model)._valueForCellChanged(cell,
				previous);
	}

}