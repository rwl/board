/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.analysis;

//import java.util.Hashtable;
//import java.util.Map;

/**
 * This class implements a priority queue.
 */
class FibonacciHeap
{

	/**
	 * Maps from elements to nodes
	 */
	Map<Object, _FibonacciHeapNode> _nodes = new Hashtable<Object, _FibonacciHeapNode>();

	/**
	 * 
	 */
	_FibonacciHeapNode _min;

	/**
	 * 
	 */
	int _size;

	/**
	 * Returns the node that represents element.
	 */
	_FibonacciHeapNode getNode(Object element, bool create)
	{
		_FibonacciHeapNode node = _nodes[element];

		if (node == null && create)
		{
			node = new _FibonacciHeapNode(element, Double.MAX_VALUE);
			_nodes[element] = node;
			insert(node, node.getKey());
		}
		return node;
	}

	/**
	 * Returns true if the queue is empty.
	 */
	bool isEmpty()
	{
		return _min == null;
	}

	/**
	 * Decreases the key value for a heap node, given the new value to take on.
	 * The structure of the heap may be changed and will not be consolidated.
	 * 
	 * <p>
	 * Running time: O(1) amortized
	 * </p>
	 * 
	 * @param x Node whose value should be decreased.
	 * @param k New key value for node x.
	 * 
	 * @exception IllegalArgumentException
	 *                Thrown if k is larger than x.key value.
	 */
	void decreaseKey(_FibonacciHeapNode x, double k)
	{
		if (k > x._key)
		{
			throw new IllegalArgumentException(
					"decreaseKey() got larger key value");
		}

		x._key = k;
		_FibonacciHeapNode y = x._parent;

		if ((y != null) && (x._key < y._key))
		{
			_cut(x, y);
			_cascadingCut(y);
		}

		if (_min == null || x._key < _min._key)
		{
			_min = x;
		}
	}

	/**
	 * Deletes a node from the heap given the reference to the node. The trees
	 * in the heap will be consolidated, if necessary. This operation may fail
	 * to remove the correct element if there are nodes with key value
	 * -Infinity.
	 * 
	 * <p>
	 * Running time: O(log n) amortized
	 * </p>
	 * 
	 * @param x The node to remove from the heap.
	 */
	void delete(_FibonacciHeapNode x)
	{
		// make x as small as possible
		decreaseKey(x, Double.NEGATIVE_INFINITY);

		// remove the smallest, which decreases n also
		removeMin();
	}

	/**
	 * Inserts a new data element into the heap. No heap consolidation is
	 * performed at this time, the new node is simply inserted into the root
	 * list of this heap.
	 * 
	 * <p>
	 * Running time: O(1) actual
	 * </p>
	 * 
	 * @param node
	 *            new node to insert into heap
	 * @param key
	 *            key value associated with data object
	 */
	void insert(_FibonacciHeapNode node, double key)
	{
		node._key = key;

		// concatenate node into min list
		if (_min != null)
		{
			node._left = _min;
			node._right = _min._right;
			_min._right = node;
			node._right._left = node;

			if (key < _min._key)
			{
				_min = node;
			}
		}
		else
		{
			_min = node;
		}

		_size++;
	}

	/**
	 * Returns the smallest element in the heap. This smallest element is the
	 * one with the minimum key value.
	 * 
	 * <p>
	 * Running time: O(1) actual
	 * </p>
	 * 
	 * @return Returns the heap node with the smallest key.
	 */
	_FibonacciHeapNode min()
	{
		return _min;
	}

	/**
	 * Removes the smallest element from the heap. This will cause the trees in
	 * the heap to be consolidated, if necessary.
	 * Does not remove the data node so that the current key remains stored.
	 * 
	 * <p>
	 * Running time: O(log n) amortized
	 * </p>
	 * 
	 * @return Returns the node with the smallest key.
	 */
	_FibonacciHeapNode removeMin()
	{
		_FibonacciHeapNode z = _min;

		if (z != null)
		{
			int numKids = z._degree;
			_FibonacciHeapNode x = z._child;
			_FibonacciHeapNode tempRight;

			// for each child of z do...
			while (numKids > 0)
			{
				tempRight = x._right;

				// remove x from child list
				x._left._right = x._right;
				x._right._left = x._left;

				// add x to root list of heap
				x._left = _min;
				x._right = _min._right;
				_min._right = x;
				x._right._left = x;

				// set parent[x] to null
				x._parent = null;
				x = tempRight;
				numKids--;
			}

			// remove z from root list of heap
			z._left._right = z._right;
			z._right._left = z._left;

			if (z == z._right)
			{
				_min = null;
			}
			else
			{
				_min = z._right;
				_consolidate();
			}

			// decrement size of heap
			_size--;
		}

		return z;
	}

	/**
	 * Returns the size of the heap which is measured in the number of elements
	 * contained in the heap.
	 * 
	 * <p>
	 * Running time: O(1) actual
	 * </p>
	 * 
	 * @return Returns the number of elements in the heap.
	 */
	int size()
	{
		return _size;
	}

	/**
	 * Joins two Fibonacci heaps into a new one. No heap consolidation is
	 * performed at this time. The two root lists are simply joined together.
	 * 
	 * <p>
	 * Running time: O(1) actual
	 * </p>
	 * 
	 * @param h1 The first heap.
	 * @param h2 The second heap.
	 * @return Returns a new heap containing h1 and h2.
	 */
	static FibonacciHeap union(FibonacciHeap h1, FibonacciHeap h2)
	{
		FibonacciHeap h = new FibonacciHeap();

		if ((h1 != null) && (h2 != null))
		{
			h._min = h1._min;

			if (h._min != null)
			{
				if (h2._min != null)
				{
					h._min._right._left = h2._min._left;
					h2._min._left._right = h._min._right;
					h._min._right = h2._min;
					h2._min._left = h._min;

					if (h2._min._key < h1._min._key)
					{
						h._min = h2._min;
					}
				}
			}
			else
			{
				h._min = h2._min;
			}

			h._size = h1._size + h2._size;
		}

		return h;
	}

	/**
	 * Performs a cascading cut operation. This cuts y from its parent and then
	 * does the same for its parent, and so on up the tree.
	 * 
	 * <p>
	 * Running time: O(log n); O(1) excluding the recursion
	 * </p>
	 * 
	 * @param y The node to perform cascading cut on.
	 */
	void _cascadingCut(_FibonacciHeapNode y)
	{
		_FibonacciHeapNode z = y._parent;

		// if there's a parent...
		if (z != null)
		{
			// if y is unmarked, set it marked
			if (!y._mark)
			{
				y._mark = true;
			}
			else
			{
				// it's marked, cut it from parent
				_cut(y, z);

				// cut its parent as well
				_cascadingCut(z);
			}
		}
	}

	/**
	 * Consolidates the trees in the heap by joining trees of equal degree until
	 * there are no more trees of equal degree in the root list.
	 * 
	 * <p>
	 * Running time: O(log n) amortized
	 * </p>
	 */
	void _consolidate()
	{
		int arraySize = _size + 1;
		List<_FibonacciHeapNode> array = new List<_FibonacciHeapNode>(arraySize);

		// Initialize degree array
		for (int i = 0; i < arraySize; i++)
		{
			array[i] = null;
		}

		// Find the number of root nodes.
		int numRoots = 0;
		_FibonacciHeapNode x = _min;

		if (x != null)
		{
			numRoots++;
			x = x._right;

			while (x != _min)
			{
				numRoots++;
				x = x._right;
			}
		}

		// For each node in root list do...
		while (numRoots > 0)
		{
			// Access this node's degree..
			int d = x._degree;
			_FibonacciHeapNode next = x._right;

			// ..and see if there's another of the same degree.
			while (array[d] != null)
			{
				// There is, make one of the nodes a child of the other.
				_FibonacciHeapNode y = array[d];

				// Do this based on the key value.
				if (x._key > y._key)
				{
					_FibonacciHeapNode temp = y;
					y = x;
					x = temp;
				}

				// Node y disappears from root list.
				_link(y, x);

				// We've handled this degree, go to next one.
				array[d] = null;
				d++;
			}

			// Save this node for later when we might encounter another
			// of the same degree.
			array[d] = x;

			// Move forward through list.
			x = next;
			numRoots--;
		}

		// Set min to null (effectively losing the root list) and
		// reconstruct the root list from the array entries in array[].
		_min = null;

		for (int i = 0; i < arraySize; i++)
		{
			if (array[i] != null)
			{
				// We've got a live one, add it to root list.
				if (_min != null)
				{
					// First remove node from root list.
					array[i]._left._right = array[i]._right;
					array[i]._right._left = array[i]._left;

					// Now add to root list, again.
					array[i]._left = _min;
					array[i]._right = _min._right;
					_min._right = array[i];
					array[i]._right._left = array[i];

					// Check if this is a new min.
					if (array[i]._key < _min._key)
					{
						_min = array[i];
					}
				}
				else
				{
					_min = array[i];
				}
			}
		}
	}

	/**
	 * The reverse of the link operation: removes x from the child list of y.
	 * This method assumes that min is non-null.
	 * 
	 * <p>
	 * Running time: O(1)
	 * </p>
	 * 
	 * @param x The child of y to be removed from y's child list.
	 * @param y The parent of x about to lose a child.
	 */
	void _cut(_FibonacciHeapNode x, _FibonacciHeapNode y)
	{
		// remove x from childlist of y and decrement degree[y]
		x._left._right = x._right;
		x._right._left = x._left;
		y._degree--;

		// reset y.child if necessary
		if (y._child == x)
		{
			y._child = x._right;
		}

		if (y._degree == 0)
		{
			y._child = null;
		}

		// add x to root list of heap
		x._left = _min;
		x._right = _min._right;
		_min._right = x;
		x._right._left = x;

		// set parent[x] to nil
		x._parent = null;

		// set mark[x] to false
		x._mark = false;
	}

	/**
	 * Make node y a child of node x.
	 * 
	 * <p>
	 * Running time: O(1) actual
	 * </p>
	 * 
	 * @param y The node to become child.
	 * @param x The node to become parent.
	 */
	void _link(_FibonacciHeapNode y, _FibonacciHeapNode x)
	{
		// remove y from root list of heap
		y._left._right = y._right;
		y._right._left = y._left;

		// make y a child of x
		y._parent = x;

		if (x._child == null)
		{
			x._child = y;
			y._right = y;
			y._left = y;
		}
		else
		{
			y._left = x._child;
			y._right = x._child._right;
			x._child._right = y;
			y._right._left = y;
		}

		// increase degree[x]
		x._degree++;

		// set mark[y] false
		y._mark = false;
	}

}

/**
 * Implements a node of the Fibonacci heap. It holds the information
 * necessary for maintaining the structure of the heap. It also holds the
 * reference to the key value (which is used to determine the heap
 * structure). Additional Node data should be stored in a subclass.
 */
class _FibonacciHeapNode
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
  bool _mark;

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
  _FibonacciHeapNode(Object userObject, double key)
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
  /*final*/ double getKey()
  {
    return _key;
  }

  /**
   * @return Returns the userObject.
   */
  Object getUserObject()
  {
    return _userObject;
  }

  /**
   * @param userObject The userObject to set.
   */
  void setUserObject(Object userObject)
  {
    this._userObject = userObject;
  }

}