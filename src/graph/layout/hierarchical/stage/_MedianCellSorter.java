package graph.layout.hierarchical.stage;

import graph.layout.hierarchical.model.GraphAbstractHierarchyCell;

/**
 * A utility class used to track cells whilst sorting occurs on the median
 * values. Does not violate (x.compareTo(y)==0) == (x.equals(y))
 */
class _MedianCellSorter implements Comparable<Object>
{

	/**
	 * The median value of the cell stored
	 */
	public double medianValue = 0.0;

	/**
	 * The cell whose median value is being calculated
	 */
	GraphAbstractHierarchyCell cell = null;

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
		if (arg0 instanceof _MedianCellSorter)
		{
			if (medianValue < ((_MedianCellSorter) arg0).medianValue)
			{
				return -1;
			}
			else if (medianValue > ((_MedianCellSorter) arg0).medianValue)
			{
				return 1;
			}
		}
		
		return 0;
	}
}