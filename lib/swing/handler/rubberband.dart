/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

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
class Rubberband implements MouseListener, MouseMotionListener
{

	/**
	 * Defines the border color for drawing the rubberband selection.
	 * Default is Constants.RUBBERBAND_BORDERCOLOR.
	 */
	Color _borderColor = SwingConstants.RUBBERBAND_BORDERCOLOR;

	/**
	 * Defines the color to be used for filling the rubberband selection.
	 * Default is Constants.RUBBERBAND_FILLCOLOR.
	 */
	Color _fillColor = SwingConstants.RUBBERBAND_FILLCOLOR;

	/**
	 * Reference to the enclosing graph container.
	 */
	GraphComponent _graphComponent;

	/**
	 * Specifies if the rubberband is enabled.
	 */
	bool _enabled = true;

	/**
	 * Holds the point where the selection has started.
	 */
	/*transient*/ Point _first;

	/**
	 * Holds the current rubberband bounds.
	 */
	/*transient*/ Rectangle _bounds;

	/**
	 * Constructs a new rubberband selection for the given graph component.
	 * 
	 * @param graphComponent Component that contains the rubberband.
	 */
	Rubberband(final GraphComponent graphComponent)
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
	bool isEnabled()
	{
		return _enabled;
	}

	/**
	 * Sets the enabled state.
	 */
	void setEnabled(bool enabled)
	{
		this._enabled = enabled;
	}

	/**
	 * Returns the border color.
	 */
	Color getBorderColor()
	{
		return _borderColor;
	}

	/**
	 * Sets the border color.
	 */
	void setBorderColor(Color value)
	{
		_borderColor = value;
	}

	/**
	 * Returns the fill color.
	 */
	Color getFillColor()
	{
		return _fillColor;
	}

	/**
	 * Sets the fill color.
	 */
	void setFillColor(Color value)
	{
		_fillColor = value;
	}

	/**
	 * Returns true if the given event should start the rubberband selection.
	 */
	bool isRubberbandTrigger(MouseEvent e)
	{
		return true;
	}

	/**
	 * Starts the rubberband selection at the given point.
	 */
	void start(Point point)
	{
		_first = point;
		_bounds = new Rectangle(_first);
	}

	/**
	 * Resets the rubberband selection without carrying out the selection.
	 */
	void reset()
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
	List<Object> select(Rectangle rect, MouseEvent e)
	{
		return _graphComponent.selectRegion(rect, e);
	}

	/**
	 * 
	 */
	void paintRubberband(Graphics g)
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
	void mousePressed(MouseEvent e)
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
	void mouseDragged(MouseEvent e)
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
	void mouseReleased(MouseEvent e)
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
	void mouseClicked(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
	void mouseEntered(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
	void mouseExited(MouseEvent arg0)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent)
	 */
	void mouseMoved(MouseEvent arg0)
	{
		// empty
	}

}