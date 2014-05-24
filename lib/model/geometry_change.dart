part of graph.model;

import '../model/model.dart' show AtomicGraphModelChange;

class GeometryChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	Object cell;

	/**
	 * 
	 */
	Geometry geometry, previous;

	/**
	 * 
	 */
	GeometryChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	GeometryChange(GraphModel model, Object cell,
			Geometry geometry)
	{
		super(model);
		this.cell = cell;
		this.geometry = geometry;
		this.previous = this.geometry;
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
	void setGeometry(Geometry value)
	{
		geometry = value;
	}

	/**
	 * @return the geometry
	 */
	Geometry getGeometry()
	{
		return geometry;
	}

	/**
	 *
	 */
	void setPrevious(Geometry value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	Geometry getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	void execute()
	{
		geometry = previous;
		previous = ((GraphModel) model)._geometryForCellChanged(cell,
				previous);
	}

}