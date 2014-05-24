part of graph.view;

import '../model/model.dart' show Cell;
import '../util/util.dart' show Rect;

//import java.util.Hashtable;

class TemporaryCellStates
{
	/**
	 * 
	 */
	GraphView _view;

	/**
	 * 
	 */
	Hashtable<Object, CellState> _oldStates;

	/**
	 * 
	 */
	Rect _oldBounds;

	/**
	 * 
	 */
	double _oldScale;

	/**
	 * Constructs a new temporary cell states instance.
	 */
	TemporaryCellStates(GraphView view)
	{
		this(view, 1, null);
	}

	/**
	 * Constructs a new temporary cell states instance.
	 */
	TemporaryCellStates(GraphView view, double scale)
	{
		this(view, scale, null);
	}

	/**
	 * Constructs a new temporary cell states instance.
	 */
	TemporaryCellStates(GraphView view, double scale, Object[] cells)
	{
		this._view = view;

		// Stores the previous state
		_oldBounds = view.getGraphBounds();
		_oldStates = view.getStates();
		_oldScale = view.getScale();

		// Creates space for the new states
		view.setStates(new Hashtable<Object, CellState>());
		view.setScale(scale);

		if (cells != null)
		{
			Rect bbox = null;

			// Validates the vertices and edges without adding them to
			// the model so that the original cells are not modified
			for (int i = 0; i < cells.length; i++)
			{
				Rect bounds = view.getBoundingBox(view.validateCellState(view.validateCell(cells[i])));
				
				if (bbox == null)
				{
					bbox = bounds;
				}
				else
				{
					bbox.add(bounds);
				}
			}
			
			if (bbox == null)
			{
				bbox = new Rect();
			}

			view.setGraphBounds(bbox);
		}
	}

	/**
	 * Destroys the cell states and restores the state of the graph view.
	 */
	void destroy()
	{
		_view.setScale(_oldScale);
		_view.setStates(_oldStates);
		_view.setGraphBounds(_oldBounds);
	}

}
