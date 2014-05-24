part of graph.model;

//import graph.model.IGraphModel.AtomicGraphModelChange;

public class RootChange extends AtomicGraphModelChange
{

	/**
	 * Holds the new and previous root cell.
	 */
	protected Object root, previous;

	/**
	 * 
	 */
	public RootChange()
	{
		this(null, null);
	}

	/**
	 * 
	 */
	public RootChange(GraphModel model, Object root)
	{
		super(model);
		this.root = root;
		previous = root;
	}

	/**
	 * 
	 */
	public void setRoot(Object value)
	{
		root = value;
	}

	/**
	 * @return the root
	 */
	public Object getRoot()
	{
		return root;
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
	 * Changes the root of the model.
	 */
	public void execute()
	{
		root = previous;
		previous = ((GraphModel) model)._rootChanged(previous);
	}

}