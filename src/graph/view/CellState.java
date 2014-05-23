/**
 * $Id: CellState.java,v 1.2 2013/08/28 06:01:37 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.view;

import graph.util.Point2d;
import graph.util.Rect;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Represents the current state of a cell in a given graph view.
 */
public class CellState extends Rect
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 7588335615324083354L;

	/**
	 * Reference to the enclosing graph view.
	 */
	protected GraphView view;

	/**
	 * Reference to the cell that is represented by this state.
	 */
	protected Object cell;

	/**
	 * Holds the current label value, including newlines which result from
	 * word wrapping.
	 */
	protected String label;

	/**
	 * Contains an array of key, value pairs that represent the style of the
	 * cell.
	 */
	protected Map<String, Object> style;

	/**
	 * Holds the origin for all child cells.
	 */
	protected Point2d origin = new Point2d();

	/**
	 * List of mxPoints that represent the absolute points of an edge.
	 */
	protected List<Point2d> absolutePoints;

	/**
	 * Holds the absolute offset. For edges, this is the absolute coordinates
	 * of the label position. For vertices, this is the offset of the label
	 * relative to the top, left corner of the vertex.
	 */
	protected Point2d absoluteOffset = new Point2d();

	/**
	 * Caches the distance between the end points and the length of an edge.
	 */
	protected double terminalDistance, length;

	/**
	 * Array of numbers that represent the cached length of each segment of the
	 * edge.
	 */
	protected double[] segments;

	/**
	 * Holds the rectangle which contains the label.
	 */
	protected Rect labelBounds;

	/**
	 * Holds the largest rectangle which contains all rendering for this cell.
	 */
	protected Rect boundingBox;

	/**
	 * Specifies if the state is invalid. Default is true.
	 */
	protected boolean invalid = true;

	/**
	 * Caches the visible source and target terminal states.
	 */
	protected CellState visibleSourceState, visibleTargetState;

	/**
	 * Constructs an empty cell state.
	 */
	public CellState()
	{
		this(null, null, null);
	}

	/**
	 * Constructs a new object that represents the current state of the given
	 * cell in the specified view.
	 * 
	 * @param view Graph view that contains the state.
	 * @param cell Cell that this state represents.
	 * @param style Array of key, value pairs that constitute the style.
	 */
	public CellState(GraphView view, Object cell, Map<String, Object> style)
	{
		setView(view);
		setCell(cell);
		setStyle(style);
	}

	/**
	 * Returns true if the state is invalid.
	 */
	public boolean isInvalid()
	{
		return invalid;
	}

	/**
	 * Sets the invalid state.
	 */
	public void setInvalid(boolean invalid)
	{
		this.invalid = invalid;
	}

	/**
	 * Returns the enclosing graph view.
	 * 
	 * @return the view
	 */
	public GraphView getView()
	{
		return view;
	}

	/**
	 * Sets the enclosing graph view. 
	 *
	 * @param view the view to set
	 */
	public void setView(GraphView view)
	{
		this.view = view;
	}

	/**
	 * Returns the current label.
	 */
	public String getLabel()
	{
		return label;
	}

	/**
	 * Returns the current label.
	 */
	public void setLabel(String value)
	{
		label = value;
	}

	/**
	 * Returns the cell that is represented by this state.
	 * 
	 * @return the cell
	 */
	public Object getCell()
	{
		return cell;
	}

	/**
	 * Sets the cell that this state represents.
	 * 
	 * @param cell the cell to set
	 */
	public void setCell(Object cell)
	{
		this.cell = cell;
	}

	/**
	 * Returns the cell style as a map of key, value pairs.
	 * 
	 * @return the style
	 */
	public Map<String, Object> getStyle()
	{
		return style;
	}

	/**
	 * Sets the cell style as a map of key, value pairs.
	 * 
	 * @param style the style to set
	 */
	public void setStyle(Map<String, Object> style)
	{
		this.style = style;
	}

	/**
	 * Returns the origin for the children.
	 * 
	 * @return the origin
	 */
	public Point2d getOrigin()
	{
		return origin;
	}

	/**
	 * Sets the origin for the children.
	 * 
	 * @param origin the origin to set
	 */
	public void setOrigin(Point2d origin)
	{
		this.origin = origin;
	}

	/**
	 * Returns the absolute point at the given index.
	 * 
	 * @return the Point2d at the given index
	 */
	public Point2d getAbsolutePoint(int index)
	{
		return absolutePoints.get(index);
	}

	/**
	 * Returns the absolute point at the given index.
	 * 
	 * @return the Point2d at the given index
	 */
	public Point2d setAbsolutePoint(int index, Point2d point)
	{
		return absolutePoints.set(index, point);
	}

	/**
	 * Returns the number of absolute points.
	 * 
	 * @return the absolutePoints
	 */
	public int getAbsolutePointCount()
	{
		return (absolutePoints != null) ? absolutePoints.size() : 0;
	}

	/**
	 * Returns the absolute points.
	 * 
	 * @return the absolutePoints
	 */
	public List<Point2d> getAbsolutePoints()
	{
		return absolutePoints;
	}

	/**
	 * Returns the absolute points.
	 * 
	 * @param absolutePoints the absolutePoints to set
	 */
	public void setAbsolutePoints(List<Point2d> absolutePoints)
	{
		this.absolutePoints = absolutePoints;
	}

	/**
	 * Returns the absolute offset.
	 * 
	 * @return the absoluteOffset
	 */
	public Point2d getAbsoluteOffset()
	{
		return absoluteOffset;
	}

	/**
	 * Returns the absolute offset.
	 * 
	 * @param absoluteOffset the absoluteOffset to set
	 */
	public void setAbsoluteOffset(Point2d absoluteOffset)
	{
		this.absoluteOffset = absoluteOffset;
	}

	/**
	 * Returns the terminal distance.
	 * 
	 * @return the terminalDistance
	 */
	public double getTerminalDistance()
	{
		return terminalDistance;
	}

	/**
	 * Sets the terminal distance.
	 * 
	 * @param terminalDistance the terminalDistance to set
	 */
	public void setTerminalDistance(double terminalDistance)
	{
		this.terminalDistance = terminalDistance;
	}

	/**
	 * Returns the length.
	 * 
	 * @return the length
	 */
	public double getLength()
	{
		return length;
	}

	/**
	 * Sets the length.
	 * 
	 * @param length the length to set
	 */
	public void setLength(double length)
	{
		this.length = length;
	}

	/**
	 * Returns the length of the segments.
	 * 
	 * @return the segments
	 */
	public double[] getSegments()
	{
		return segments;
	}

	/**
	 * Sets the length of the segments.
	 * 
	 * @param segments the segments to set
	 */
	public void setSegments(double[] segments)
	{
		this.segments = segments;
	}

	/**
	 * Returns the label bounds.
	 * 
	 * @return Returns the label bounds for this state.
	 */
	public Rect getLabelBounds()
	{
		return labelBounds;
	}

	/**
	 * Sets the label bounds.
	 * 
	 * @param labelBounds
	 */
	public void setLabelBounds(Rect labelBounds)
	{
		this.labelBounds = labelBounds;
	}

	/**
	 * Returns the bounding box.
	 * 
	 * @return Returns the bounding box for this state.
	 */
	public Rect getBoundingBox()
	{
		return boundingBox;
	}

	/**
	 * Sets the bounding box.
	 * 
	 * @param boundingBox
	 */
	public void setBoundingBox(Rect boundingBox)
	{
		this.boundingBox = boundingBox;
	}

	/**
	 * Returns the rectangle that should be used as the perimeter of the cell.
	 * This implementation adds the perimeter spacing to the rectangle
	 * defined by this cell state.
	 * 
	 * @return Returns the rectangle that defines the perimeter.
	 */
	public Rect getPerimeterBounds()
	{
		return getPerimeterBounds(0);
	}

	/**
	 * Returns the rectangle that should be used as the perimeter of the cell.
	 * 
	 * @return Returns the rectangle that defines the perimeter.
	 */
	public Rect getPerimeterBounds(double border)
	{
		Rect bounds = new Rect(getRectangle());

		if (border != 0)
		{
			bounds.grow(border);
		}

		return bounds;
	}

	/**
	 * Sets the first or last point in the list of points depending on isSource.
	 * 
	 * @param point Point that represents the terminal point.
	 * @param isSource Boolean that specifies if the first or last point should
	 * be assigned.
	 */
	public void setAbsoluteTerminalPoint(Point2d point, boolean isSource)
	{
		if (isSource)
		{
			if (absolutePoints == null)
			{
				absolutePoints = new ArrayList<Point2d>();
			}

			if (absolutePoints.size() == 0)
			{
				absolutePoints.add(point);
			}
			else
			{
				absolutePoints.set(0, point);
			}
		}
		else
		{
			if (absolutePoints == null)
			{
				absolutePoints = new ArrayList<Point2d>();
				absolutePoints.add(null);
				absolutePoints.add(point);
			}
			else if (absolutePoints.size() == 1)
			{
				absolutePoints.add(point);
			}
			else
			{
				absolutePoints.set(absolutePoints.size() - 1, point);
			}
		}
	}

	/**
	 * Returns the visible source or target terminal cell.
	 * 
	 * @param source Boolean that specifies if the source or target cell should be
	 * returned.
	 */
	public Object getVisibleTerminal(boolean source)
	{
		CellState tmp = getVisibleTerminalState(source);

		return (tmp != null) ? tmp.getCell() : null;
	}

	/**
	 * Returns the visible source or target terminal state.
	 * 
	 * @param Boolean that specifies if the source or target state should be
	 * returned.
	 */
	public CellState getVisibleTerminalState(boolean source)
	{
		return (source) ? visibleSourceState : visibleTargetState;
	}

	/**
	 * Sets the visible source or target terminal state.
	 * 
	 * @param terminalState Cell state that represents the terminal.
	 * @param source Boolean that specifies if the source or target state should be set.
	 */
	public void setVisibleTerminalState(CellState terminalState,
			boolean source)
	{
		if (source)
		{
			visibleSourceState = terminalState;
		}
		else
		{
			visibleTargetState = terminalState;
		}
	}

	/**
	 * Returns a clone of this state where all members are deeply cloned
	 * except the view and cell references, which are copied with no
	 * cloning to the new instance.
	 */
	public Object clone()
	{
		CellState clone = new CellState(view, cell, style);
		
		if (label != null)
		{
			clone.label = label;
		}

		if (absolutePoints != null)
		{
			clone.absolutePoints = new ArrayList<Point2d>();

			for (int i = 0; i < absolutePoints.size(); i++)
			{
				clone.absolutePoints.add((Point2d) absolutePoints.get(i)
						.clone());
			}
		}

		if (origin != null)
		{
			clone.origin = (Point2d) origin.clone();
		}

		if (absoluteOffset != null)
		{
			clone.absoluteOffset = (Point2d) absoluteOffset.clone();
		}

		if (labelBounds != null)
		{
			clone.labelBounds = (Rect) labelBounds.clone();
		}

		if (boundingBox != null)
		{
			clone.boundingBox = (Rect) boundingBox.clone();
		}

		clone.terminalDistance = terminalDistance;
		clone.segments = segments;
		clone.length = length;
		clone.x = x;
		clone.y = y;
		clone.width = width;
		clone.height = height;

		return clone;
	}

}
