/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import graph.swing.GraphComponent;
//import graph.swing.GraphControl;
//import graph.swing.util.SwingConstants;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.Utils;
//import graph.util.EventSource.IEventListener;

//import java.awt.Color;
//import java.awt.Graphics;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.KeyAdapter;
//import java.awt.event.KeyEvent;
//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

/**
 * Implements a rubberband selection.
 */
public class Rubberband implements MouseListener, MouseMotionListener
{

	/**
	 * Defines the border color for drawing the rubberband selection.
	 * Default is Constants.RUBBERBAND_BORDERCOLOR.
	 */
	protected Color _borderColor = SwingConstants.RUBBERBAND_BORDERCOLOR;

	/**
	 * Defines the color to be used for filling the rubberband selection.
	 * Default is Constants.RUBBERBAND_FILLCOLOR.
	 */
	protected Color _fillColor = SwingConstants.RUBBERBAND_FILLCOLOR;

	/**
	 * Reference to the enclosing graph container.
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Specifies if the rubberband is enabled.
	 */
	protected boolean _enabled = true;

	/**
	 * Holds the point where the selection has started.
	 */
	protected transient Point _first;

	/**
	 * Holds the current rubberband bounds.
	 */
	protected transient Rectangle _bounds;

	/**
	 * Constructs a new rubberband selection for the given graph component.
	 * 
	 * @param graphComponent Component that contains the rubberband.
	 */
	public Rubberband(final GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;

		// Adds the required listeners
		graphComponent.getGraphControl().addMouseListener(this);
		graphComponent.getGraphControl().addMouseMotionListener(this);

		graphComponent.addListener(Event.AFTER_PAINT, new IEventListener()
		{

			public void invoke(Object source, EventObj evt)
			{
				paintRubberband((Graphics) evt.getProperty("g"));
			}

		});

		// Handles escape keystrokes
		graphComponent.addKeyListener(new KeyAdapter()
		{
			/**
			 * 
			 * @param e
			 * @return
			 */
			public void keyPressed(KeyEvent e)
			{
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE
						&& graphComponent.isEscapeEnabled())
				{
					reset();
				}
			}
		});

		// LATER: Add destroy method for removing above listeners
	}

	/**
	 * Returns the enabled state.
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * Sets the enabled state.
	 */
	public void setEnabled(boolean enabled)
	{
		this._enabled = enabled;
	}

	/**
	 * Returns the border color.
	 */
	public Color getBorderColor()
	{
		return _borderColor;
	}

	/**
	 * Sets the border color.
	 */
	public void setBorderColor(Color value)
	{
		_borderColor = value;
	}

	/**
	 * Returns the fill color.
	 */
	public Color getFillColor()
	{
		return _fillColor;
	}

	/**
	 * Sets the fill color.
	 */
	public void setFillColor(Color value)
	{
		_fillColor = value;
	}

	/**
	 * Returns true if the given event should start the rubberband selection.
	 */
	public boolean isRubberbandTrigger(MouseEvent e)
	{
		return true;
	}

	/**
	 * Starts the rubberband selection at the given point.
	 */
	public void start(Point point)
	{
		_first = point;
		_bounds = new Rectangle(_first);
	}

	/**
	 * Resets the rubberband selection without carrying out the selection.
	 */
	public void reset()
	{
		_first = null;

		if (_bounds != null)
		{
			_graphComponent.getGraphControl().repaint(_bounds);
			_bounds = null;
		}
	}

	/**
	 * 
	 * @param rect
	 * @param e
	 */
	public Object[] select(Rectangle rect, MouseEvent e)
	{
		return _graphComponent.selectRegion(rect, e);
	}

	/**
	 * 
	 */
	public void paintRubberband(Graphics g)
	{
		if (_first != null && _bounds != null
				&& _graphComponent.isSignificant(_bounds.width, _bounds.height))
		{
			Rectangle rect = new Rectangle(_bounds);
			g.setColor(_fillColor);
			Utils.fillClippedRect(g, rect.x, rect.y, rect.width, rect.height);
			g.setColor(_borderColor);
			rect.width -= 1;
			rect.height -= 1;
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
		}
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (!e.isConsumed() && isEnabled() && isRubberbandTrigger(e)
				&& !e.isPopupTrigger())
		{
			start(e.getPoint());
			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (!e.isConsumed() && _first != null)
		{
			Rectangle oldBounds = new Rectangle(_bounds);
			_bounds = new Rectangle(_first);
			_bounds.add(e.getPoint());

			if (_graphComponent.isSignificant(_bounds.width, _bounds.height))
			{
				GraphControl control = _graphComponent.getGraphControl();

				// Repaints exact difference between old and new bounds
				Rectangle union = new Rectangle(oldBounds);
				union.add(_bounds);

				if (_bounds.x != oldBounds.x)
				{
					int maxleft = Math.max(_bounds.x, oldBounds.x);
					Rectangle tmp = new Rectangle(union.x - 1, union.y, maxleft
							- union.x + 2, union.height);
					control.repaint(tmp);
				}

				if (_bounds.x + _bounds.width != oldBounds.x + oldBounds.width)
				{
					int minright = Math.min(_bounds.x + _bounds.width,
							oldBounds.x + oldBounds.width);
					Rectangle tmp = new Rectangle(minright - 1, union.y,
							union.x + union.width - minright + 1, union.height);
					control.repaint(tmp);
				}

				if (_bounds.y != oldBounds.y)
				{
					int maxtop = Math.max(_bounds.y, oldBounds.y);
					Rectangle tmp = new Rectangle(union.x, union.y - 1,
							union.width, maxtop - union.y + 2);
					control.repaint(tmp);
				}

				if (_bounds.y + _bounds.height != oldBounds.y + oldBounds.height)
				{
					int minbottom = Math.min(_bounds.y + _bounds.height,
							oldBounds.y + oldBounds.height);
					Rectangle tmp = new Rectangle(union.x, minbottom - 1,
							union.width, union.y + union.height - minbottom + 1);
					control.repaint(tmp);
				}

				if (!_graphComponent.isToggleEvent(e)
						&& !_graphComponent.getGraph().isSelectionEmpty())
				{
					_graphComponent.getGraph().clearSelection();
				}
			}

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		Rectangle rect = _bounds;
		reset();

		if (!e.isConsumed() && rect != null
				&& _graphComponent.isSignificant(rect.width, rect.height))
		{
			select(rect, e);
			e.consume();
		}

	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
	 */
	public void mouseClicked(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
	public void mouseEntered(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
	public void mouseExited(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent)
	 */
	public void mouseMoved(MouseEvent arg0)
	{
		// empty
	}

}
