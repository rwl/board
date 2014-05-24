/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.model;

//import java.io.Serializable;
//import java.util.ArrayList;
//import java.util.List;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Defines the requirements for a cell that can be used in an GraphModel.
 */
public interface ICell
{

  /**
   * Returns the Id of the cell as a string.
   * 
   * @return Returns the Id.
   */
  String getId();

  /**
   * Sets the Id of the cell to the given string.
   * 
   * @param id String that represents the new Id.
   */
  void setId(String id);

  /**
   * Returns the user object of the cell.
   * 
   * @return Returns the user object.
   */
  Object getValue();

  /**
   * Sets the user object of the cell.
   * 
   * @param value Object that represents the new value.
   */
  void setValue(Object value);

  /**
   * Returns the object that describes the geometry.
   * 
   * @return Returns the cell geometry.
   */
  Geometry getGeometry();

  /**
   * Sets the object to be used as the geometry.
   */
  void setGeometry(Geometry geometry);

  /**
   * Returns the string that describes the style.
   * 
   * @return Returns the cell style.
   */
  String getStyle();

  /**
   * Sets the string to be used as the style.
   */
  void setStyle(String style);

  /**
   * Returns true if the cell is a vertex.
   * 
   * @return Returns true if the cell is a vertex.
   */
  boolean isVertex();

  /**
   * Returns true if the cell is an edge.
   * 
   * @return Returns true if the cell is an edge.
   */
  boolean isEdge();

  /**
   * Returns true if the cell is connectable.
   * 
   * @return Returns the connectable state.
   */
  boolean isConnectable();

  /**
   * Returns true if the cell is visibile.
   * 
   * @return Returns the visible state.
   */
  boolean isVisible();

  /**
   * Specifies if the cell is visible.
   * 
   * @param visible Boolean that specifies the new visible state.
   */
  void setVisible(boolean visible);

  /**
   * Returns true if the cell is collapsed.
   * 
   * @return Returns the collapsed state.
   */
  boolean isCollapsed();

  /**
   * Sets the collapsed state.
   * 
   * @param collapsed Boolean that specifies the new collapsed state.
   */
  void setCollapsed(boolean collapsed);

  /**
   * Returns the cell's parent.
   * 
   * @return Returns the parent cell.
   */
  ICell getParent();

  /**
   * Sets the parent cell.
   * 
   * @param parent Cell that represents the new parent.
   */
  void setParent(ICell parent);

  /**
   * Returns the source or target terminal.
   * 
   * @param source Boolean that specifies if the source terminal should be
   * returned.
   * @return Returns the source or target terminal.
   */
  ICell getTerminal(boolean source);

  /**
   * Sets the source or target terminal and returns the new terminal.
   * 
   * @param terminal Cell that represents the new source or target terminal.
   * @param isSource Boolean that specifies if the source or target terminal
   * should be set.
   * @return Returns the new terminal.
   */
  ICell setTerminal(ICell terminal, boolean isSource);

  /**
   * Returns the number of child cells.
   * 
   * @return Returns the number of children.
   */
  int getChildCount();

  /**
   * Returns the index of the specified child in the child array.
   * 
   * @param child Child whose index should be returned.
   * @return Returns the index of the given child.
   */
  int getIndex(ICell child);

  /**
   * Returns the child at the specified index.
   * 
   * @param index Integer that specifies the child to be returned.
   * @return Returns the child at the given index.
   */
  ICell getChildAt(int index);

  /**
   * Appends the specified child into the child array and updates the parent
   * reference of the child. Returns the appended child.
   * 
   * @param child Cell to be appended to the child array.
   * @return Returns the new child.
   */
  ICell insert(ICell child);

  /**
   * Inserts the specified child into the child array at the specified index
   * and updates the parent reference of the child. Returns the inserted child.
   * 
   * @param child Cell to be inserted into the child array.
   * @param index Integer that specifies the index at which the child should
   * be inserted into the child array.
   * @return Returns the new child.
   */
  ICell insert(ICell child, int index);

  /**
   * Removes the child at the specified index from the child array and
   * returns the child that was removed. Will remove the parent reference of
   * the child.
   * 
   * @param index Integer that specifies the index of the child to be
   * removed.
   * @return Returns the child that was removed.
   */
  ICell remove(int index);

  /**
   * Removes the given child from the child array and returns it. Will remove
   * the parent reference of the child.
   * 
   * @param child Cell that represents the child to be removed.
   * @return Returns the child that was removed.
   */
  ICell remove(ICell child);

  /**
   * Removes the cell from its parent.
   */
  void removeFromParent();

  /**
   * Returns the number of edges in the edge array.
   * 
   * @return Returns the number of edges.
   */
  int getEdgeCount();

  /**
   * Returns the index of the specified edge in the edge array.
   * 
   * @param edge Cell whose index should be returned.
   * @return Returns the index of the given edge.
   */
  int getEdgeIndex(ICell edge);

  /**
   * Returns the edge at the specified index in the edge array.
   * 
   * @param index Integer that specifies the index of the edge to be
   * returned.
   * @return Returns the edge at the given index.
   */
  ICell getEdgeAt(int index);

  /**
   * Inserts the specified edge into the edge array and returns the edge.
   * Will update the respective terminal reference of the edge.
   * 
   * @param edge Cell to be inserted into the edge array.
   * @param isOutgoing Boolean that specifies if the edge is outgoing.
   * @return Returns the new edge.
   */
  ICell insertEdge(ICell edge, boolean isOutgoing);

  /**
   * Removes the specified edge from the edge array and returns the edge.
   * Will remove the respective terminal reference from the edge.
   * 
   * @param edge Cell to be removed from the edge array.
   * @param isOutgoing Boolean that specifies if the edge is outgoing.
   * @return Returns the edge that was removed.
   */
  ICell removeEdge(ICell edge, boolean isOutgoing);

  /**
   * Removes the edge from its source or target terminal.
   * 
   * @param isSource Boolean that specifies if the edge should be removed
   * from its source or target terminal.
   */
  void removeFromTerminal(boolean isSource);

  /**
   * Returns a clone of this cell.
   * 
   * @return Returns a clone of this cell.
   */
  Object clone() throws CloneNotSupportedException;

}

/**
 * Cells are the elements of the graph model. They represent the state
 * of the groups, vertices and edges in a graph.
 *
 * <h4>Edge Labels</h4>
 * 
 * Using the x- and y-coordinates of a cell's geometry it is
 * possible to position the label on edges on a specific location
 * on the actual edge shape as it appears on the screen. The
 * x-coordinate of an edge's geometry is used to describe the
 * distance from the center of the edge from -1 to 1 with 0
 * being the center of the edge and the default value. The
 * y-coordinate of an edge's geometry is used to describe
 * the absolute, orthogonal distance in pixels from that
 * point. In addition, the Geometry.offset is used
 * as a absolute offset vector from the resulting point.
 * 
 * The width and height of an edge geometry are ignored.
 * 
 * To add more than one edge label, add a child vertex with
 * a relative geometry. The x- and y-coordinates of that
 * geometry will have the same semantiv as the above for
 * edge labels.
 */
public class Cell implements ICell, Cloneable, Serializable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 910211337632342672L;

	/**
	 * Holds the Id. Default is null.
	 */
	protected String _id;

	/**
	 * Holds the user object. Default is null.
	 */
	protected Object _value;

	/**
	 * Holds the geometry. Default is null.
	 */
	protected Geometry _geometry;

	/**
	 * Holds the style as a string of the form
	 * stylename[;key=value]. Default is null.
	 */
	protected String _style;

	/**
	 * Specifies whether the cell is a vertex or edge and whether it is
	 * connectable, visible and collapsed. Default values are false, false,
	 * true, true and false respectively.
	 */
	protected boolean _vertex = false, _edge = false, _connectable = true,
			_visible = true, _collapsed = false;

	/**
	 * Reference to the parent cell and source and target terminals for edges.
	 */
	protected ICell _parent, _source, _target;

	/**
	 * Holds the child cells and connected edges.
	 */
	protected List<Object> _children, _edges;

	/**
	 * Constructs a new cell with an empty user object.
	 */
	public Cell()
	{
		this(null);
	}

	/**
	 * Constructs a new cell for the given user object.
	 * 
	 * @param value
	 *   Object that represents the value of the cell.
	 */
	public Cell(Object value)
	{
		this(value, null, null);
	}

	/**
	 * Constructs a new cell for the given parameters.
	 * 
	 * @param value Object that represents the value of the cell.
	 * @param geometry Specifies the geometry of the cell.
	 * @param style Specifies the style as a formatted string.
	 */
	public Cell(Object value, Geometry geometry, String style)
	{
		setValue(value);
		setGeometry(geometry);
		setStyle(style);
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getId()
	 */
	public String getId()
	{
		return _id;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setId(String)
	 */
	public void setId(String id)
	{
		this._id = id;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getValue()
	 */
	public Object getValue()
	{
		return _value;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setValue(Object)
	 */
	public void setValue(Object value)
	{
		this._value = value;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getGeometry()
	 */
	public Geometry getGeometry()
	{
		return _geometry;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setGeometry(graph.model.Geometry)
	 */
	public void setGeometry(Geometry geometry)
	{
		this._geometry = geometry;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getStyle()
	 */
	public String getStyle()
	{
		return _style;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setStyle(String)
	 */
	public void setStyle(String style)
	{
		this._style = style;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#isVertex()
	 */
	public boolean isVertex()
	{
		return _vertex;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setVertex(boolean)
	 */
	public void setVertex(boolean vertex)
	{
		this._vertex = vertex;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#isEdge()
	 */
	public boolean isEdge()
	{
		return _edge;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setEdge(boolean)
	 */
	public void setEdge(boolean edge)
	{
		this._edge = edge;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#isConnectable()
	 */
	public boolean isConnectable()
	{
		return _connectable;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setConnectable(boolean)
	 */
	public void setConnectable(boolean connectable)
	{
		this._connectable = connectable;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#isVisible()
	 */
	public boolean isVisible()
	{
		return _visible;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setVisible(boolean)
	 */
	public void setVisible(boolean visible)
	{
		this._visible = visible;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#isCollapsed()
	 */
	public boolean isCollapsed()
	{
		return _collapsed;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setCollapsed(boolean)
	 */
	public void setCollapsed(boolean collapsed)
	{
		this._collapsed = collapsed;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getParent()
	 */
	public ICell getParent()
	{
		return _parent;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setParent(graph.model.ICell)
	 */
	public void setParent(ICell parent)
	{
		this._parent = parent;
	}

	/**
	 * Returns the source terminal.
	 */
	public ICell getSource()
	{
		return _source;
	}

	/**
	 * Sets the source terminal.
	 * 
	 * @param source Cell that represents the new source terminal.
	 */
	public void setSource(ICell source)
	{
		this._source = source;
	}

	/**
	 * Returns the target terminal.
	 */
	public ICell getTarget()
	{
		return _target;
	}

	/**
	 * Sets the target terminal.
	 * 
	 * @param target Cell that represents the new target terminal.
	 */
	public void setTarget(ICell target)
	{
		this._target = target;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getTerminal(boolean)
	 */
	public ICell getTerminal(boolean source)
	{
		return (source) ? getSource() : getTarget();
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#setTerminal(graph.model.ICell, boolean)
	 */
	public ICell setTerminal(ICell terminal, boolean isSource)
	{
		if (isSource)
		{
			setSource(terminal);
		}
		else
		{
			setTarget(terminal);
		}

		return terminal;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getChildCount()
	 */
	public int getChildCount()
	{
		return (_children != null) ? _children.size() : 0;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getIndex(graph.model.ICell)
	 */
	public int getIndex(ICell child)
	{
		return (_children != null) ? _children.indexOf(child) : -1;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getChildAt(int)
	 */
	public ICell getChildAt(int index)
	{
		return (_children != null) ? (ICell) _children.get(index) : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#insert(graph.model.ICell)
	 */
	public ICell insert(ICell child)
	{
		int index = getChildCount();
		
		if (child.getParent() == this)
		{
			index--;
		}
		
		return insert(child, index);
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#insert(graph.model.ICell, int)
	 */
	public ICell insert(ICell child, int index)
	{
		if (child != null)
		{
			child.removeFromParent();
			child.setParent(this);

			if (_children == null)
			{
				_children = new ArrayList<Object>();
				_children.add(child);
			}
			else
			{
				_children.add(index, child);
			}
		}

		return child;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#remove(int)
	 */
	public ICell remove(int index)
	{
		ICell child = null;

		if (_children != null && index >= 0)
		{
			child = getChildAt(index);
			remove(child);
		}

		return child;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#remove(graph.model.ICell)
	 */
	public ICell remove(ICell child)
	{
		if (child != null && _children != null)
		{
			_children.remove(child);
			child.setParent(null);
		}

		return child;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#removeFromParent()
	 */
	public void removeFromParent()
	{
		if (_parent != null)
		{
			_parent.remove(this);
		}
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getEdgeCount()
	 */
	public int getEdgeCount()
	{
		return (_edges != null) ? _edges.size() : 0;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getEdgeIndex(graph.model.ICell)
	 */
	public int getEdgeIndex(ICell edge)
	{
		return (_edges != null) ? _edges.indexOf(edge) : -1;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#getEdgeAt(int)
	 */
	public ICell getEdgeAt(int index)
	{
		return (_edges != null) ? (ICell) _edges.get(index) : null;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#insertEdge(graph.model.ICell, boolean)
	 */
	public ICell insertEdge(ICell edge, boolean isOutgoing)
	{
		if (edge != null)
		{
			edge.removeFromTerminal(isOutgoing);
			edge.setTerminal(this, isOutgoing);

			if (_edges == null || edge.getTerminal(!isOutgoing) != this
					|| !_edges.contains(edge))
			{
				if (_edges == null)
				{
					_edges = new ArrayList<Object>();
				}

				_edges.add(edge);
			}
		}

		return edge;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#removeEdge(graph.model.ICell, boolean)
	 */
	public ICell removeEdge(ICell edge, boolean isOutgoing)
	{
		if (edge != null)
		{
			if (edge.getTerminal(!isOutgoing) != this && _edges != null)
			{
				_edges.remove(edge);
			}
			
			edge.setTerminal(null, isOutgoing);
		}

		return edge;
	}

	/* (non-Javadoc)
	 * @see graph.model.ICell#removeFromTerminal(boolean)
	 */
	public void removeFromTerminal(boolean isSource)
	{
		ICell terminal = getTerminal(isSource);

		if (terminal != null)
		{
			terminal.removeEdge(this, isSource);
		}
	}

	/**
	 * Returns the specified attribute from the user object if it is an XML
	 * node.
	 * 
	 * @param name Name of the attribute whose value should be returned.
	 * @return Returns the value of the given attribute or null.
	 */
	public String getAttribute(String name)
	{
		return getAttribute(name, null);
	}

	/**
	 * Returns the specified attribute from the user object if it is an XML
	 * node.
	 * 
	 * @param name Name of the attribute whose value should be returned.
	 * @param defaultValue Default value to use if the attribute has no value.
	 * @return Returns the value of the given attribute or defaultValue.
	 */
	public String getAttribute(String name, String defaultValue)
	{
		Object userObject = getValue();
		String val = null;

		if (userObject instanceof Element)
		{
			Element element = (Element) userObject;
			val = element.getAttribute(name);
		}

		if (val == null)
		{
			val = defaultValue;
		}

		return val;
	}

	/**
	 * Sets the specified attribute on the user object if it is an XML node.
	 * 
	 * @param name Name of the attribute whose value should be set.
	 * @param value New value of the attribute.
	 */
	public void setAttribute(String name, String value)
	{
		Object userObject = getValue();

		if (userObject instanceof Element)
		{
			Element element = (Element) userObject;
			element.setAttribute(name, value);
		}
	}

	/**
	 * Returns a clone of the cell.
	 */
	public Object clone() throws CloneNotSupportedException
	{
		Cell clone = (Cell) super.clone();

		clone.setValue(cloneValue());
		clone.setStyle(getStyle());
		clone.setCollapsed(isCollapsed());
		clone.setConnectable(isConnectable());
		clone.setEdge(isEdge());
		clone.setVertex(isVertex());
		clone.setVisible(isVisible());
		clone.setParent(null);
		clone.setSource(null);
		clone.setTarget(null);
		clone._children = null;
		clone._edges = null;

		Geometry geometry = getGeometry();

		if (geometry != null)
		{
			clone.setGeometry((Geometry) geometry.clone());
		}

		return clone;
	}

	/**
	 * Returns a clone of the user object. This implementation clones any XML
	 * nodes or otherwise returns the same user object instance.
	 */
	protected Object cloneValue()
	{
		Object value = getValue();

		if (value instanceof Node)
		{
			value = ((Node) value).cloneNode(true);
		}

		return value;
	}

}
