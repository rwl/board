part of graph.model;

class ValueChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object cell, value, previous;

	/**
	 * 
	 */
	ValueChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	ValueChange(GraphModel model, Object cell, Object value)
	{
		super(model);
		this.cell = cell;
		this.value = value;
		this.previous = this.value;
	}

	/**
	 * 
	 */
	void setCell(Object value)
	{
		cell = value;
	}

	/**
	 * @return the cell
	 */
	Object getCell()
	{
		return cell;
	}

	/**
	 * 
	 */
	void setValue(Object value)
	{
		this.value = value;
	}

	/**
	 * @return the value
	 */
	Object getValue()
	{
		return value;
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
	 * Changes the root of the model.
	 */
	void execute()
	{
		value = previous;
		previous = ((GraphModel) model)._valueForCellChanged(cell,
				previous);
	}

}