package graph.analysis;

/**
 * Implements a node of the Fibonacci heap. It holds the information
 * necessary for maintaining the structure of the heap. It also holds the
 * reference to the key value (which is used to determine the heap
 * structure). Additional Node data should be stored in a subclass.
 */
public class _FibonacciHeapNode
{

	Object _userObject;

	/**
	 * first child node
	 */
	_FibonacciHeapNode _child;

	/**
	 * left sibling node
	 */
	_FibonacciHeapNode _left;

	/**
	 * parent node
	 */
	_FibonacciHeapNode _parent;

	/**
	 * right sibling node
	 */
	_FibonacciHeapNode _right;

	/**
	 * true if this node has had a child removed since this node was added
	 * to its parent
	 */
	boolean _mark;

	/**
	 * key value for this node
	 */
	double _key;

	/**
	 * number of children of this node (does not count grandchildren)
	 */
	int _degree;

	/**
	 * Default constructor. Initializes the right and left pointers, making
	 * this a circular doubly-linked list.
	 * 
	 * @param key The initial key for node.
	 */
	public _FibonacciHeapNode(Object userObject, double key)
	{
		this._userObject = userObject;
		_right = this;
		_left = this;
		this._key = key;
	}

	/**
	 * Obtain the key for this node.
	 * 
	 * @return the key
	 */
	public final double getKey()
	{
		return _key;
	}

	/**
	 * @return Returns the userObject.
	 */
	public Object getUserObject()
	{
		return _userObject;
	}

	/**
	 * @param userObject The userObject to set.
	 */
	public void setUserObject(Object userObject)
	{
		this._userObject = userObject;
	}

}