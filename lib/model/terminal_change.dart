part of graph.model;

//import graph.model.IGraphModel.AtomicGraphModelChange;

public class TerminalChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell, terminal, previous;

	/**
	 * 
	 */
	protected boolean source;

	/**
	 * 
	 */
	public TerminalChange()
	{
		this(null, null, null, false);
	}

	/**
	 * 
	 */
	public TerminalChange(GraphModel model, Object cell,
			Object terminal, boolean source)
	{
		super(model);
		this.cell = cell;
		this.terminal = terminal;
		this.previous = this.terminal;
		this.source = source;
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
	public void setTerminal(Object value)
	{
		terminal = value;
	}

	/**
	 * @return the terminal
	 */
	public Object getTerminal()
	{
		return terminal;
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
	 * 
	 */
	public void setSource(boolean value)
	{
		source = value;
	}

	/**
	 * @return the isSource
	 */
	public boolean isSource()
	{
		return source;
	}

	/**
	 * Changes the root of the model.
	 */
	public void execute()
	{
		terminal = previous;
		previous = ((GraphModel) model)._terminalForCellChanged(cell,
				previous, source);
	}

}