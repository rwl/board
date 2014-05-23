/**
 * $Id: SelectionCellsHandler.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2008, Gaudenz Alder
 * 
 * Known issue: Drag image size depends on the initial position and may sometimes
 * not align with the grid when dragging. This is because the rounding of the width
 * and height at the initial position may be different than that at the current
 * position as the left and bottom side of the shape must align to the grid lines.
 */
package graph.swing.handler;

import graph.swing.GraphComponent;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource.IEventListener;
import graph.view.CellState;
import graph.view.Graph;

import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.Stroke;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.swing.SwingUtilities;

public class SelectionCellsHandler implements MouseListener,
		MouseMotionListener
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -882368002120921842L;

	/**
	 * Defines the default value for maxHandlers. Default is 100.
	 */
	public static int DEFAULT_MAX_HANDLERS = 100;

	/**
	 * Reference to the enclosing graph component.
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Specifies if this handler is enabled.
	 */
	protected boolean _enabled = true;

	/**
	 * Specifies if this handler is visible.
	 */
	protected boolean _visible = true;

	/**
	 * Reference to the enclosing graph component.
	 */
	protected Rectangle _bounds = null;

	/**
	 * Defines the maximum number of handlers to paint individually.
	 * Default is DEFAULT_MAX_HANDLES.
	 */
	protected int _maxHandlers = DEFAULT_MAX_HANDLERS;

	/**
	 * Maps from cells to handlers in the order of the selection cells.
	 */
	protected transient LinkedHashMap<Object, CellHandler> _handlers = new LinkedHashMap<Object, CellHandler>();

	/**
	 * 
	 */
	protected transient IEventListener _refreshHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			if (isEnabled())
			{
				refresh();
			}
		}
	};

	/**
	 * 
	 */
	protected transient PropertyChangeListener _labelMoveHandler = new PropertyChangeListener()
	{

		/*
		 * (non-Javadoc)
		 * @see java.beans.PropertyChangeListener#propertyChange(java.beans.PropertyChangeEvent)
		 */
		public void propertyChange(PropertyChangeEvent evt)
		{
			if (evt.getPropertyName().equals("vertexLabelsMovable")
					|| evt.getPropertyName().equals("edgeLabelsMovable"))
			{
				refresh();
			}
		}

	};

	/**
	 * 
	 * @param graphComponent
	 */
	public SelectionCellsHandler(final GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;

		// Listens to all mouse events on the rendering control
		graphComponent.getGraphControl().addMouseListener(this);
		graphComponent.getGraphControl().addMouseMotionListener(this);

		// Installs the graph listeners and keeps them in sync
		_addGraphListeners(graphComponent.getGraph());

		graphComponent.addPropertyChangeListener(new PropertyChangeListener()
		{
			public void propertyChange(PropertyChangeEvent evt)
			{
				if (evt.getPropertyName().equals("graph"))
				{
					_removeGraphListeners((Graph) evt.getOldValue());
					_addGraphListeners((Graph) evt.getNewValue());
				}
			}
		});

		// Installs the paint handler
		graphComponent.addListener(Event.PAINT, new IEventListener()
		{
			public void invoke(Object sender, EventObj evt)
			{
				Graphics g = (Graphics) evt.getProperty("g");
				paintHandles(g);
			}
		});
	}

	/**
	 * Installs the listeners to update the handles after any changes.
	 */
	protected void _addGraphListeners(Graph graph)
	{
		// LATER: Install change listener for graph model, selection model, view
		if (graph != null)
		{
			graph.getSelectionModel().addListener(Event.CHANGE,
					_refreshHandler);
			graph.getModel().addListener(Event.CHANGE, _refreshHandler);
			graph.getView().addListener(Event.SCALE, _refreshHandler);
			graph.getView().addListener(Event.TRANSLATE, _refreshHandler);
			graph.getView().addListener(Event.SCALE_AND_TRANSLATE,
					_refreshHandler);
			graph.getView().addListener(Event.DOWN, _refreshHandler);
			graph.getView().addListener(Event.UP, _refreshHandler);

			// Refreshes the handles if moveVertexLabels or moveEdgeLabels changes
			graph.addPropertyChangeListener(_labelMoveHandler);
		}
	}

	/**
	 * Removes all installed listeners.
	 */
	protected void _removeGraphListeners(Graph graph)
	{
		if (graph != null)
		{
			graph.getSelectionModel().removeListener(_refreshHandler,
					Event.CHANGE);
			graph.getModel().removeListener(_refreshHandler, Event.CHANGE);
			graph.getView().removeListener(_refreshHandler, Event.SCALE);
			graph.getView().removeListener(_refreshHandler, Event.TRANSLATE);
			graph.getView().removeListener(_refreshHandler,
					Event.SCALE_AND_TRANSLATE);
			graph.getView().removeListener(_refreshHandler, Event.DOWN);
			graph.getView().removeListener(_refreshHandler, Event.UP);

			// Refreshes the handles if moveVertexLabels or moveEdgeLabels changes
			graph.removePropertyChangeListener(_labelMoveHandler);
		}
	}

	/**
	 * 
	 */
	public GraphComponent getGraphComponent()
	{
		return _graphComponent;
	}

	/**
	 * 
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * 
	 */
	public void setEnabled(boolean value)
	{
		_enabled = value;
	}

	/**
	 * 
	 */
	public boolean isVisible()
	{
		return _visible;
	}

	/**
	 * 
	 */
	public void setVisible(boolean value)
	{
		_visible = value;
	}

	/**
	 * 
	 */
	public int getMaxHandlers()
	{
		return _maxHandlers;
	}

	/**
	 * 
	 */
	public void setMaxHandlers(int value)
	{
		_maxHandlers = value;
	}

	/**
	 * 
	 */
	public CellHandler getHandler(Object cell)
	{
		return _handlers.get(cell);
	}

	/**
	 * Dispatches the mousepressed event to the subhandles. This is
	 * called from the connection handler as subhandles have precedence
	 * over the connection handler.
	 */
	public void mousePressed(MouseEvent e)
	{
		if (_graphComponent.isEnabled()
				&& !_graphComponent.isForceMarqueeEvent(e) && isEnabled())
		{
			Iterator<CellHandler> it = _handlers.values().iterator();

			while (it.hasNext() && !e.isConsumed())
			{
				it.next().mousePressed(e);
			}
		}
	}

	/**
	 * 
	 */
	public void mouseMoved(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled())
		{
			Iterator<CellHandler> it = _handlers.values().iterator();

			while (it.hasNext() && !e.isConsumed())
			{
				it.next().mouseMoved(e);
			}
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled())
		{
			Iterator<CellHandler> it = _handlers.values().iterator();

			while (it.hasNext() && !e.isConsumed())
			{
				it.next().mouseDragged(e);
			}
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled())
		{
			Iterator<CellHandler> it = _handlers.values().iterator();

			while (it.hasNext() && !e.isConsumed())
			{
				it.next().mouseReleased(e);
			}
		}

		reset();
	}

	/**
	 * Redirects the tooltip handling of the JComponent to the graph
	 * component, which in turn may use getHandleToolTipText in this class to
	 * find a tooltip associated with a handle.
	 */
	public String getToolTipText(MouseEvent e)
	{
		MouseEvent tmp = SwingUtilities.convertMouseEvent(e.getComponent(), e,
				_graphComponent.getGraphControl());
		Iterator<CellHandler> it = _handlers.values().iterator();
		String tip = null;

		while (it.hasNext() && tip == null)
		{
			tip = it.next().getToolTipText(tmp);
		}

		return tip;
	}

	/**
	 * 
	 */
	public void reset()
	{
		Iterator<CellHandler> it = _handlers.values().iterator();

		while (it.hasNext())
		{
			it.next().reset();
		}
	}

	/**
	 * 
	 */
	public void refresh()
	{
		Graph graph = _graphComponent.getGraph();

		// Creates a new map for the handlers and tries to
		// to reuse existing handlers from the old map
		LinkedHashMap<Object, CellHandler> oldHandlers = _handlers;
		_handlers = new LinkedHashMap<Object, CellHandler>();

		// Creates handles for all selection cells
		Object[] tmp = graph.getSelectionCells();
		boolean handlesVisible = tmp.length <= getMaxHandlers();
		Rectangle handleBounds = null;

		for (int i = 0; i < tmp.length; i++)
		{
			CellState state = graph.getView().getState(tmp[i]);

			if (state != null && state.getCell() != graph.getView().getCurrentRoot())
			{
				CellHandler handler = oldHandlers.remove(tmp[i]);

				if (handler != null)
				{
					handler.refresh(state);
				}
				else
				{
					handler = _graphComponent.createHandler(state);
				}

				if (handler != null)
				{
					handler.setHandlesVisible(handlesVisible);
					_handlers.put(tmp[i], handler);
					Rectangle bounds = handler.getBounds();
					Stroke stroke = handler.getSelectionStroke();

					if (stroke != null)
					{
						bounds = stroke.createStrokedShape(bounds).getBounds();
					}

					if (handleBounds == null)
					{
						handleBounds = bounds;
					}
					else
					{
						handleBounds.add(bounds);
					}
				}
			}
		}
		
		for (CellHandler handler: oldHandlers.values())
		{
			handler._destroy();
		}

		Rectangle dirty = _bounds;

		if (handleBounds != null)
		{
			if (dirty != null)
			{
				dirty.add(handleBounds);
			}
			else
			{
				dirty = handleBounds;
			}
		}

		if (dirty != null)
		{
			_graphComponent.getGraphControl().repaint(dirty);
		}

		// Stores current bounds for later use
		_bounds = handleBounds;
	}

	/**
	 * 
	 */
	public void paintHandles(Graphics g)
	{
		Iterator<CellHandler> it = _handlers.values().iterator();

		while (it.hasNext())
		{
			it.next().paint(g);
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

}
