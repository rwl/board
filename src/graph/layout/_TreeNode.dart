package graph.layout;


/**
 * 
 */
class _TreeNode
{
	/**
	 * 
	 */
	protected Object cell;

	/**
	 * 
	 */
	protected double x, y, width, height, offsetX, offsetY;

	/**
	 * 
	 */
	protected _TreeNode child, next; // parent, sibling

	/**
	 * 
	 */
	protected _Polygon contour = new _Polygon();

	/**
	 * 
	 */
	public _TreeNode(Object cell)
	{
		this.cell = cell;
	}

}