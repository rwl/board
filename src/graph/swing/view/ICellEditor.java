/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.view;

//import java.util.EventObject;

/**
 *
 */
public interface ICellEditor
{

	/**
	 * Returns the cell that is currently being edited.
	 */
	public Object getEditingCell();

	/**
	 * Starts editing the given cell.
	 */
	public void startEditing(Object cell, EventObject trigger);

	/**
	 * Stops the current editing.
	 */
	public void stopEditing(boolean cancel);

}
