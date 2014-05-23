/**
 * $Id: CellMarker.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2008-2012, JGraph Ltd
 */
package graph.swing.handler;

import graph.swing.GraphComponent;
import graph.swing.util.SwingConstants;
import graph.util.Constants;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource;
import graph.util.Utils;
import graph.util.EventSource.IEventListener;
import graph.view.CellState;
import graph.view.GraphView;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Stroke;
import java.awt.event.MouseEvent;

import javax.swing.JComponent;

/**
 * Implements a mouse tracker that marks cells under the mouse.
 * 
 * This class fires the following event:
 * 
 * Event.MARK fires in mark and unmark to notify the listener of a new cell
 * under the mouse. The <code>state</code> property contains the CellState
 * of the respective cell or null if no cell is under the mouse.
 * 
 * To create a cell marker which highlights cells "in-place", the following
 * code can be used:
 * <code>
 * CellMarker highlighter = new CellMarker(graphComponent) {
 * 
 *   protected Map<String, Object> lastStyle;
 *   
 *   public CellState process(MouseEvent e)
 *   {
 *     CellState state = null;
 *     
 *     if (isEnabled())
 *     {
 *       state = getState(e);
 *       boolean isValid = (state != null) ? isValidState(state) : false;
 *       
 *       if (!isValid)
 *       {
 *         state = null;
 *       }
 *       
 *       highlight(state);
 *     }
 *     
 *     return state;
 *   }
 *   
 *   public void highlight(CellState state)
 *   {
 *     if (validState != state)
 *     {
 *       Rectangle dirty = null;
 *       
 *       if (validState != null)
 *       {
 *         validState.setStyle(lastStyle);
 *         dirty = validState.getBoundingBox().getRectangle();
 *         dirty.grow(4, 4);
 *       }
 *       
 *       if (state != null)
 *       {
 *         lastStyle = state.getStyle();
 *         state.setStyle(new Hashtable<String, Object>(state.getStyle()));
 *         state.getStyle().put("strokeColor", "#00ff00");
 *         state.getStyle().put("fontColor", "#00ff00");
 *         state.getStyle().put("strokeWidth", "3");
 *          
 *         Rectangle tmp = state.getBoundingBox().getRectangle();
 *         
 *         if (dirty != null)
 *         {
 *           dirty.add(tmp);
 *         }
 *         else
 *         {
 *           dirty = tmp;
 *         }
 *         
 *         dirty.grow(4, 4);
 *       }
 *       
 *       validState = state;
 *       graphComponent.repaint(dirty);
 *     }
 *   }
 *
 *   public void reset()
 *   {
 *     highlight(null);
 *   }
 *
 *   public void paint(Graphics g)
 *   {
 *     // do nothing
 *   }
 * };
 *  
 * graphComponent.getConnectionHandler().setMarker(highlighter);
 * </code>
 */
public class CellMarker extends JComponent
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 614473367053597572L;

	/**
	 * Specifies if the highlights should appear on top of everything
	 * else in the overlay pane. Default is false.
	 */
	public static boolean KEEP_ON_TOP = false;

	/**
	 * Specifies the default stroke for the marker.
	 */
	public static Stroke DEFAULT_STROKE = new BasicStroke(3);

	/**
	 * Holds the event source.
	 */
	protected EventSource _eventSource = new EventSource(this);

	/**
	 * Holds the enclosing graph component.
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Specifies if the marker is enabled. Default is true.
	 */
	protected boolean _enabled = true;

	/**
	 * Specifies the portion of the width and height that should trigger
	 * a highlight. The area around the center of the cell to be marked is used
	 * as the hotspot. Possible values are between 0 and 1. Default is
	 * Constants.DEFAULT_HOTSPOT.
	 */
	protected double _hotspot;

	/**
	 * Specifies if the hotspot is enabled. Default is false.
	 */
	protected boolean _hotspotEnabled = false;

	/**
	 * Specifies if the the content area of swimlane should be non-transparent
	 * to mouse events. Default is false.
	 */
	protected boolean _swimlaneContentEnabled = false;

	/**
	 * Specifies the valid- and invalidColor for the marker.
	 */
	protected Color _validColor, _invalidColor;

	/**
	 * Holds the current marker color.
	 */
	protected transient Color _currentColor;

	/**
	 * Holds the marked state if it is valid.
	 */
	protected transient CellState _validState;

	/**
	 * Holds the marked state.
	 */
	protected transient CellState _markedState;

	/**
	 * Constructs a new marker for the given graph component.
	 * 
	 * @param graphComponent
	 */
	public CellMarker(GraphComponent graphComponent)
	{
		this(graphComponent, SwingConstants.DEFAULT_VALID_COLOR);
	}

	/**
	 * Constructs a new marker for the given graph component.
	 */
	public CellMarker(GraphComponent graphComponent, Color validColor)
	{
		this(graphComponent, validColor, SwingConstants.DEFAULT_INVALID_COLOR);
	}

	/**
	 * Constructs a new marker for the given graph component.
	 */
	public CellMarker(GraphComponent graphComponent, Color validColor,
			Color invalidColor)
	{
		this(graphComponent, validColor, invalidColor,
				Constants.DEFAULT_HOTSPOT);
	}

	/**
	 * Constructs a new marker for the given graph component.
	 */
	public CellMarker(GraphComponent graphComponent, Color validColor,
			Color invalidColor, double hotspot)
	{
		this._graphComponent = graphComponent;
		this._validColor = validColor;
		this._invalidColor = invalidColor;
		this._hotspot = hotspot;
	}

	/**
	 * Sets the enabled state of the marker.
	 */
	public void setEnabled(boolean enabled)
	{
		this._enabled = enabled;
	}

	/**
	 * Returns true if the marker is enabled, that is, if it processes events
	 * in process.
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * Sets the hotspot.
	 */
	public void setHotspot(double hotspot)
	{
		this._hotspot = hotspot;
	}

	/**
	 * Returns the hotspot.
	 */
	public double getHotspot()
	{
		return _hotspot;
	}

	/**
	 * Specifies whether the hotspot should be used in intersects.
	 */
	public void setHotspotEnabled(boolean enabled)
	{
		this._hotspotEnabled = enabled;
	}

	/**
	 * Returns true if hotspot is used in intersects.
	 */
	public boolean isHotspotEnabled()
	{
		return _hotspotEnabled;
	}

	/**
	 * Sets if the content area of swimlanes should not be transparent to
	 * events.
	 */
	public void setSwimlaneContentEnabled(boolean swimlaneContentEnabled)
	{
		this._swimlaneContentEnabled = swimlaneContentEnabled;
	}

	/**
	 * Returns true if the content area of swimlanes is non-transparent to
	 * events.
	 */
	public boolean isSwimlaneContentEnabled()
	{
		return _swimlaneContentEnabled;
	}

	/**
	 * Sets the color used for valid highlights.
	 */
	public void setValidColor(Color value)
	{
		_validColor = value;
	}

	/**
	 * Returns the color used for valid highlights.
	 */
	public Color getValidColor()
	{
		return _validColor;
	}

	/**
	 * Sets the color used for invalid highlights.
	 */
	public void setInvalidColor(Color value)
	{
		_invalidColor = value;
	}

	/**
	 * Returns the color used for invalid highlights.
	 */
	public Color getInvalidColor()
	{
		return _invalidColor;
	}

	/**
	 * Returns true if validState is not null.
	 */
	public boolean hasValidState()
	{
		return (_validState != null);
	}

	/**
	 * Returns the valid state.
	 */
	public CellState getValidState()
	{
		return _validState;
	}

	/**
	 * Sets the current color. 
	 */
	public void setCurrentColor(Color value)
	{
		_currentColor = value;
	}

	/**
	 * Returns the current color.
	 */
	public Color getCurrentColor()
	{
		return _currentColor;
	}

	/**
	 * Sets the marked state. 
	 */
	public void setMarkedState(CellState value)
	{
		_markedState = value;
	}

	/**
	 * Returns the marked state.
	 */
	public CellState getMarkedState()
	{
		return _markedState;
	}

	/**
	 * Resets the state of the cell marker.
	 */
	public void reset()
	{
		_validState = null;

		if (_markedState != null)
		{
			_markedState = null;
			unmark();
		}
	}

	/**
	 * Processes the given event and marks the state returned by getStateAt
	 * with the color returned by getMarkerColor. If the markerColor is not
	 * null, then the state is stored in markedState. If isValidState returns
	 * true, then the state is stored in validState regardless of the marker
	 * color. The state is returned regardless of the marker color and
	 * valid state. 
	 */
	public CellState process(MouseEvent e)
	{
		CellState state = null;

		if (isEnabled())
		{
			state = _getState(e);
			boolean valid = (state != null) ? _isValidState(state) : false;
			Color color = _getMarkerColor(e, state, valid);
			
			highlight(state, color, valid);
		}

		return state;
	}
	
	/**
	 * 
	 */
	public void highlight(CellState state, Color color)
	{
		highlight(state, color, true);
	}
	
	/**
	 * 
	 */
	public void highlight(CellState state, Color color, boolean valid)
	{
		if (valid)
		{
			_validState = state;
		}
		else
		{
			_validState = null;
		}

		if (state != _markedState || color != _currentColor)
		{
			_currentColor = color;

			if (state != null && _currentColor != null)
			{
				_markedState = state;
				mark();
			}
			else if (_markedState != null)
			{
				_markedState = null;
				unmark();
			}
		}
	}

	/**
	 * Marks the markedState and fires a Event.MARK event.
	 */
	public void mark()
	{
		if (_markedState != null)
		{
			Rectangle bounds = _markedState.getRectangle();
			bounds.grow(3, 3);
			bounds.width += 1;
			bounds.height += 1;
			setBounds(bounds);

			if (getParent() == null)
			{
				setVisible(true);

				if (KEEP_ON_TOP)
				{
					_graphComponent.getGraphControl().add(this, 0);
				}
				else
				{
					_graphComponent.getGraphControl().add(this);
				}
			}

			repaint();
			_eventSource.fireEvent(new EventObj(Event.MARK, "state",
					_markedState));
		}
	}

	/**
	 * Hides the marker and fires a Event.MARK event.
	 */
	public void unmark()
	{
		if (getParent() != null)
		{
			setVisible(false);
			getParent().remove(this);
			_eventSource.fireEvent(new EventObj(Event.MARK));
		}
	}

	/**
	 * Returns true if the given state is a valid state. If this returns true,
	 * then the state is stored in validState. The return value of this method
	 * is used as the argument for getMarkerColor.
	 */
	protected boolean _isValidState(CellState state)
	{
		return true;
	}

	/**
	 * Returns the valid- or invalidColor depending on the value of isValid.
	 * The given state is ignored by this implementation.
	 */
	protected Color _getMarkerColor(MouseEvent e, CellState state,
			boolean isValid)
	{
		return (isValid) ? _validColor : _invalidColor;
	}

	/**
	 * Uses getCell, getMarkedState and intersects to return the state for
	 * the given event.
	 */
	protected CellState _getState(MouseEvent e)
	{
		Object cell = _getCell(e);
		GraphView view = _graphComponent.getGraph().getView();
		CellState state = _getStateToMark(view.getState(cell));

		return (state != null && _intersects(state, e)) ? state : null;
	}

	/**
	 * Returns the state at the given location. This uses Graph.getCellAt.
	 */
	protected Object _getCell(MouseEvent e)
	{
		return _graphComponent.getCellAt(e.getX(), e.getY(),
				_swimlaneContentEnabled);
	}

	/**
	 * Returns the state to be marked for the given state under the mouse. This
	 * returns the given state.
	 */
	protected CellState _getStateToMark(CellState state)
	{
		return state;
	}

	/**
	 * Returns true if the given mouse event intersects the given state. This
	 * returns true if the hotspot is 0 or the event is inside the hotspot for
	 * the given cell state.
	 */
	protected boolean _intersects(CellState state, MouseEvent e)
	{
		if (isHotspotEnabled())
		{
			return Utils.intersectsHotspot(state, e.getX(), e.getY(),
					_hotspot, Constants.MIN_HOTSPOT_SIZE,
					Constants.MAX_HOTSPOT_SIZE);
		}

		return true;
	}

	/**
	 * Adds the given event listener.
	 */
	public void addListener(String eventName, IEventListener listener)
	{
		_eventSource.addListener(eventName, listener);
	}

	/**
	 * Removes the given event listener.
	 */
	public void removeListener(IEventListener listener)
	{
		_eventSource.removeListener(listener);
	}

	/**
	 * Removes the given event listener for the specified event name.
	 */
	public void removeListener(IEventListener listener, String eventName)
	{
		_eventSource.removeListener(listener, eventName);
	}

	/**
	 * Paints the outline of the markedState with the currentColor.
	 */
	public void paint(Graphics g)
	{
		if (_markedState != null && _currentColor != null)
		{
			((Graphics2D) g).setStroke(DEFAULT_STROKE);
			g.setColor(_currentColor);

			if (_markedState.getAbsolutePointCount() > 0)
			{
				Point last = _markedState.getAbsolutePoint(0).getPoint();

				for (int i = 1; i < _markedState.getAbsolutePointCount(); i++)
				{
					Point current = _markedState.getAbsolutePoint(i).getPoint();
					g.drawLine(last.x - getX(), last.y - getY(), current.x
							- getX(), current.y - getY());
					last = current;
				}
			}
			else
			{
				g.drawRect(1, 1, getWidth() - 3, getHeight() - 3);
			}
		}
	}

}
