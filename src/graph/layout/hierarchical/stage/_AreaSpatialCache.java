package graph.layout.hierarchical.stage;

import java.awt.geom.Rectangle2D;
import java.util.HashSet;
import java.util.Set;

/**
 * Utility class that stores a collection of vertices and edge points within
 * a certain area. This area includes the buffer lengths of cells.
 */
class _AreaSpatialCache extends Rectangle2D.Double
{
	public Set<Object> cells = new HashSet<Object>();
}