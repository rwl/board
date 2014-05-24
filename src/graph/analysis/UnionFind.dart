/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.analysis;

//import java.util.Hashtable;
//import java.util.Map;

/**
 * Implements a union find structure that uses union by rank and path
 * compression. The union by rank guarantees worst case find time of O(log N),
 * while Tarjan shows that in combination with path compression (halving) the
 * average time for an arbitrary sequence of m >= n operations is
 * O(m*alpha(m,n)), where alpha is the inverse of the Ackermann function,
 * defined as follows:
 * <code>alpha(m,n) = min{i &gt;= 1 | A(i, floor(m/n)) &gt; log n} for m &gt;= n &gt;= 1</code>
 * Which yields almost constant time for each individual operation.
 */
public class UnionFind
{

	/**
	 * Maps from elements to nodes
	 */
	protected Map<Object, _UnionFindNode> _nodes = new Hashtable<Object, _UnionFindNode>();

	/**
	 * Constructs a union find structure and initializes it with the specified
	 * elements.
	 * 
	 * @param elements
	 */
	public UnionFind(Object[] elements)
	{
		for (int i = 0; i < elements.length; i++)
		{
			_nodes.put(elements[i], new _UnionFindNode());
		}
	}

	/**
	 * Returns the node that represents element.
	 */
	public _UnionFindNode getNode(Object element)
	{
		return _nodes.get(element);
	}

	/**
	 * Returns the set that contains <code>node</code>. This implementation
	 * provides path compression by halving.
	 */
	public _UnionFindNode find(_UnionFindNode unionFindNode)
	{
		while (unionFindNode.getParent().getParent() != unionFindNode.getParent())
		{
			_UnionFindNode t = unionFindNode.getParent().getParent();
			unionFindNode.setParent(t);
			unionFindNode = t;
		}

		return unionFindNode.getParent();
	}

	/**
	 * Unifies the sets <code>a</code> and <code>b</code> in constant time
	 * using a union by rank on the tree size.
	 */
	public void union(_UnionFindNode a, _UnionFindNode b)
	{
		_UnionFindNode set1 = find(a);
		_UnionFindNode set2 = find(b);

		if (set1 != set2)
		{
			// Limits the worst case runtime of a find to O(log N)
			if (set1.getSize() < set2.getSize())
			{
				set2.setParent(set1);
				set1.setSize(set1.getSize() + set2.getSize());
			}
			else
			{
				set1.setParent(set2);
				set2.setSize(set1.getSize() + set2.getSize());
			}
		}
	}

	/**
	 * Returns true if element a and element b are not in the same set. This
	 * uses getNode and then find to determine the elements set.
	 * 
	 * @param a The first element to compare.
	 * @param b The second element to compare.
	 * @return Returns true if a and b are in the same set.
	 * 
	 * @see #getNode(Object)
	 */
	public boolean differ(Object a, Object b)
	{
		_UnionFindNode set1 = find(getNode(a));
		_UnionFindNode set2 = find(getNode(b));

		return set1 != set2;
	}
}