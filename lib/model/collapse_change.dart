part of graph.model;

class CollapseChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object cell;

	/**
	 * 
	 */
	bool collapsed, previous;

	/**
	 * 
	 */
//	CollapseChange()
//	{
//		this(null, null, false);
//	}

	/**
	 * 
	 */
	CollapseChange([GraphModel model=null, Object cell=null,
			bool collapsed=false]) : super(model)
	{
		this.cell = cell;
		this.collapsed = collapsed;
		this.previous = this.collapsed;
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
	void setCollapsed(bool value)
	{
		collapsed = value;
	}

	/**
	 * @return the collapsed
	 */
	bool isCollapsed()
	{
		return collapsed;
	}

	/**
	 * 
	 */
	void setPrevious(bool value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	bool getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	void execute()
	{
		collapsed = previous;
		previous = (model as GraphModel)._collapsedStateForCellChanged(
				cell, previous);
	}

}