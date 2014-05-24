part of graph.model;

import '../model/model.dart' show AtomicGraphModelChange;

class StyleChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object cell;

	/**
	 * 
	 */
	String style, previous;

	/**
	 * 
	 */
	StyleChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	StyleChange(GraphModel model, Object cell, String style)
	{
		super(model);
		this.cell = cell;
		this.style = style;
		this.previous = this.style;
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
	void setStyle(String value)
	{
		style = value;
	}

	/**
	 * @return the style
	 */
	String getStyle()
	{
		return style;
	}

	/**
	 * 
	 */
	void setPrevious(String value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	String getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	void execute()
	{
		style = previous;
		previous = ((GraphModel) model)._styleForCellChanged(cell,
				previous);
	}

}