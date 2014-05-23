package graph.layout;

/**
 * 
 */
class _Polyline
{

	/**
	 * 
	 */
	protected double dx, dy;

	/**
	 * 
	 */
	protected _Polyline next;

	/**
	 * 
	 */
	protected _Polyline(double dx, double dy, _Polyline next)
	{
		this.dx = dx;
		this.dy = dy;
		this.next = next;
	}

}