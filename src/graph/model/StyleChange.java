package graph.model;

import graph.model.IGraphModel.AtomicGraphModelChange;

public class StyleChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell;

	/**
	 * 
	 */
	protected String style, previous;

	/**
	 * 
	 */
	public StyleChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	public StyleChange(GraphModel model, Object cell, String style)
	{
		super(model);
		this.cell = cell;
		this.style = style;
		this.previous = this.style;
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
	public void setStyle(String value)
	{
		style = value;
	}

	/**
	 * @return the style
	 */
	public String getStyle()
	{
		return style;
	}

	/**
	 * 
	 */
	public void setPrevious(String value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	public String getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	public void execute()
	{
		style = previous;
		previous = ((GraphModel) model)._styleForCellChanged(cell,
				previous);
	}

}