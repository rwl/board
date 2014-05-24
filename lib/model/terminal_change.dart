part of graph.model;

import '../model/model.dart' show AtomicGraphModelChange;

class TerminalChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object cell, terminal, previous;

	/**
	 * 
	 */
	bool source;

	/**
	 * 
	 */
	TerminalChange()
	{
		this(null, null, null, false);
	}

	/**
	 * 
	 */
	TerminalChange(GraphModel model, Object cell,
			Object terminal, bool source)
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
	void setTerminal(Object value)
	{
		terminal = value;
	}

	/**
	 * @return the terminal
	 */
	Object getTerminal()
	{
		return terminal;
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
	void setSource(bool value)
	{
		source = value;
	}

	/**
	 * @return the isSource
	 */
	bool isSource()
	{
		return source;
	}

	/**
	 * Changes the root of the model.
	 */
	void execute()
	{
		terminal = previous;
		previous = ((GraphModel) model)._terminalForCellChanged(cell,
				previous, source);
	}

}