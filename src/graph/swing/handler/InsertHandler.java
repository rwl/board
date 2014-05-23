package graph.swing.handler;

import graph.swing.GraphComponent;
import graph.swing.util.MouseAdapter;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.EventSource;
import graph.util.Point2d;
import graph.util.Rect;
import graph.util.EventSource.IEventListener;
import graph.view.Graph;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;

public class InsertHandler extends MouseAdapter
{

	/**
	 * Reference to the enclosing graph component.
	 */
	protected GraphComponent graphComponent;

	/**
	 * Specifies if this handler is enabled. Default is true.
	 */
	protected boolean enabled = true;

	/**
	 * 
	 */
	protected String style;

	/**
	 * 
	 */
	protected Point first;

	/**
	 * 
	 */
	protected float lineWidth = 1;

	/**
	 * 
	 */
	protected Color lineColor = Color.black;

	/**
	 * 
	 */
	protected boolean rounded = false;

	/**
	 * 
	 */
	protected Rect current;

	/**
	 * 
	 */
	protected EventSource eventSource = new EventSource(this);

	/**
	 * 
	 */
	public InsertHandler(GraphComponent graphComponent, String style)
	{
		this.graphComponent = graphComponent;
		this.style = style;

		// Installs the paint handler
		graphComponent.addListener(Event.AFTER_PAINT, new IEventListener()
		{
			public void invoke(Object sender, EventObj evt)
			{
				Graphics g = (Graphics) evt.getProperty("g");
				paint(g);
			}
		});

		// Listens to all mouse events on the rendering control
		graphComponent.getGraphControl().addMouseListener(this);
		graphComponent.getGraphControl().addMouseMotionListener(this);
	}

	/**
	 * 
	 */
	public GraphComponent getGraphComponent()
	{
		return graphComponent;
	}

	/**
	 * 
	 */
	public boolean isEnabled()
	{
		return enabled;
	}

	/**
	 * 
	 */
	public void setEnabled(boolean value)
	{
		enabled = value;
	}

	/**
	 * 
	 */
	public boolean isStartEvent(MouseEvent e)
	{
		return true;
	}

	/**
	 * 
	 */
	public void start(MouseEvent e)
	{
		first = e.getPoint();
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& isStartEvent(e))
		{
			start(e);
			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& first != null)
		{
			Rect dirty = current;

			current = new Rect(first.x, first.y, 0, 0);
			current.add(new Rect(e.getX(), e.getY(), 0, 0));

			if (dirty != null)
			{
				dirty.add(current);
			}
			else
			{
				dirty = current;
			}

			Rectangle tmp = dirty.getRectangle();
			int b = (int) Math.ceil(lineWidth);
			graphComponent.getGraphControl().repaint(tmp.x - b, tmp.y - b,
					tmp.width + 2 * b, tmp.height + 2 * b);

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& current != null)
		{
			Graph graph = graphComponent.getGraph();
			double scale = graph.getView().getScale();
			Point2d tr = graph.getView().getTranslate();
			current.setX(current.getX() / scale - tr.getX());
			current.setY(current.getY() / scale - tr.getY());
			current.setWidth(current.getWidth() / scale);
			current.setHeight(current.getHeight() / scale);

			Object cell = insertCell(current);
			eventSource.fireEvent(new EventObj(Event.INSERT, "cell",
					cell));
			e.consume();
		}

		reset();
	}

	/**
	 * 
	 */
	public Object insertCell(Rect bounds)
	{
		// FIXME: Clone prototype cell for insert
		return graphComponent.getGraph().insertVertex(null, null, "",
				bounds.getX(), bounds.getY(), bounds.getWidth(),
				bounds.getHeight(), style);
	}

	/**
	 * 
	 */
	public void reset()
	{
		Rectangle dirty = null;

		if (current != null)
		{
			dirty = current.getRectangle();
		}

		current = null;
		first = null;

		if (dirty != null)
		{
			int b = (int) Math.ceil(lineWidth);
			graphComponent.getGraphControl().repaint(dirty.x - b, dirty.y - b,
					dirty.width + 2 * b, dirty.height + 2 * b);
		}
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		if (first != null && current != null)
		{
			((Graphics2D) g).setStroke(new BasicStroke(lineWidth));
			g.setColor(lineColor);
			Rectangle rect = current.getRectangle();

			if (rounded)
			{
				g.drawRoundRect(rect.x, rect.y, rect.width, rect.height, 8, 8);
			}
			else
			{
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
		}
	}

	/**
	 *
	 */
	public void addListener(String eventName, IEventListener listener)
	{
		eventSource.addListener(eventName, listener);
	}

	/**
	 *
	 */
	public void removeListener(IEventListener listener)
	{
		removeListener(listener, null);
	}

	/**
	 *
	 */
	public void removeListener(IEventListener listener, String eventName)
	{
		eventSource.removeListener(listener, eventName);
	}

}
