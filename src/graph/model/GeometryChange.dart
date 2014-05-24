package graph.model;

//import graph.model.IGraphModel.AtomicGraphModelChange;

public class GeometryChange extends AtomicGraphModelChange
{

	/**
	 *
	 */
	protected Object cell;

	/**
	 * 
	 */
	protected Geometry geometry, previous;

	/**
	 * 
	 */
	public GeometryChange()
	{
		this(null, null, null);
	}

	/**
	 * 
	 */
	public GeometryChange(GraphModel model, Object cell,
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
	public void setGeometry(Geometry value)
	{
		geometry = value;
	}

	/**
	 * @return the geometry
	 */
	public Geometry getGeometry()
	{
		return geometry;
	}

	/**
	 *
	 */
	public void setPrevious(Geometry value)
	{
		previous = value;
	}

	/**
	 * @return the previous
	 */
	public Geometry getPrevious()
	{
		return previous;
	}

	/**
	 * Changes the root of the model.
	 */
	public void execute()
	{
		geometry = previous;
		previous = ((GraphModel) model)._geometryForCellChanged(cell,
				previous);
	}

}