package graph.analysis;

/**
 * A class that defines the identity of a set.
 */
public class _UnionFindNode
{

	/**
	 * Reference to the parent node. Root nodes point to themselves.
	 */
	protected _UnionFindNode parent = this;

	/**
	 * The size of the tree. Initial value is 1.
	 */
	protected int size = 1;

	/**
	 * @return Returns the parent node
	 */
	public _UnionFindNode getParent()
	{
		return parent;
	}

	/**
	 * @param parent The parent node to set.
	 */
	public void setParent(_UnionFindNode parent)
	{
		this.parent = parent;
	}

	/**
	 * @return Returns the size.
	 */
	public int getSize()
	{
		return size;
	}

	/**
	 * @param size The size to set.
	 */
	public void setSize(int size)
	{
		this.size = size;
	}
}