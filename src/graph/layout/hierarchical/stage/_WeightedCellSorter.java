package graph.layout.hierarchical.stage;

//import graph.layout.hierarchical.model.GraphAbstractHierarchyCell;

/**
 * A utility class used to track cells whilst sorting occurs on the weighted
 * sum of their connected edges. Does not violate (x.compareTo(y)==0) ==
 * (x.equals(y))
 */
class _WeightedCellSorter implements Comparable<Object>
{

	/**
	 * The weighted value of the cell stored
	 */
	public int weightedValue = 0;

	/**
	 * Whether or not to flip equal weight values.
	 */
	public boolean nudge = false;

	/**
	 * Whether or not this cell has been visited in the current assignment
	 */
	public boolean visited = false;

	/**
	 * The index this cell is in the model rank
	 */
	public int rankIndex;

	/**
	 * The cell whose median value is being calculated
	 */
	public GraphAbstractHierarchyCell cell = null;

	public _WeightedCellSorter()
	{
		this(null, 0);
	}

	public _WeightedCellSorter(GraphAbstractHierarchyCell cell,
			int weightedValue)
	{
		this.cell = cell;
		this.weightedValue = weightedValue;
	}

	/**
	 * comparator on the medianValue
	 * 
	 * @param arg0
	 *            the object to be compared to
	 * @return the standard return you would expect when comparing two
	 *         double
	 */
	public int compareTo(Object arg0)
	{
		if (arg0 instanceof _WeightedCellSorter)
		{
			if (weightedValue > ((_WeightedCellSorter) arg0).weightedValue)
			{
				return -1;
			}
			else if (weightedValue < ((_WeightedCellSorter) arg0).weightedValue)
			{
				return 1;
			}
		}

		return 0;
	}
}