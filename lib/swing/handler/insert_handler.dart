part of graph.swing.handler;

//import graph.swing.GraphComponent;
//import graph.swing.util.MouseAdapter;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.util.EventSource.IEventListener;
//import graph.view.Graph;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;

public class InsertHandler extends MouseAdapter
{

	/**
	 * Reference to the enclosing graph component.
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Specifies if this handler is enabled. Default is true.
	 */
	protected boolean _enabled = true;

	/**
	 * 
	 */
	protected String _style;

	/**
	 * 
	 */
	protected Point _first;

	/**
	 * 
	 */
	protected float _lineWidth = 1;

	/**
	 * 
	 */
	protected Color _lineColor = Color.black;

	/**
	 * 
	 */
	protected boolean _rounded = false;

	/**
	 * 
	 */
	protected Rect _current;

	/**
	 * 
	 */
	protected EventSource _eventSource = new EventSource(this);

	/**
	 * 
	 */
	public InsertHandler(GraphComponent graphComponent, String style)
	{
		this._graphComponent = graphComponent;
		this._style = style;

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
	public boolean isStartEvent(MouseEvent e)
	{
		return true;
	}

	/**
	 * 
	 */
	public void start(MouseEvent e)
	{
		_first = e.getPoint();
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
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
		if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& _first != null)
		{
			Rect dirty = _current;

			_current = new Rect(_first.x, _first.y, 0, 0);
			_current.add(new Rect(e.getX(), e.getY(), 0, 0));

			if (dirty != null)
			{
				dirty.add(_current);
			}
			else
			{
				dirty = _current;
			}

			Rectangle tmp = dirty.getRectangle();
			int b = (int) Math.ceil(_lineWidth);
			_graphComponent.getGraphControl().repaint(tmp.x - b, tmp.y - b,
					tmp.width + 2 * b, tmp.height + 2 * b);

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& _current != null)
		{
			Graph graph = _graphComponent.getGraph();
			double scale = graph.getView().getScale();
			Point2d tr = graph.getView().getTranslate();
			_current.setX(_current.getX() / scale - tr.getX());
			_current.setY(_current.getY() / scale - tr.getY());
			_current.setWidth(_current.getWidth() / scale);
			_current.setHeight(_current.getHeight() / scale);

			Object cell = insertCell(_current);
			_eventSource.fireEvent(new EventObj(Event.INSERT, "cell",
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
		return _graphComponent.getGraph().insertVertex(null, null, "",
				bounds.getX(), bounds.getY(), bounds.getWidth(),
				bounds.getHeight(), _style);
	}

	/**
	 * 
	 */
	public void reset()
	{
		Rectangle dirty = null;

		if (_current != null)
		{
			dirty = _current.getRectangle();
		}

		_current = null;
		_first = null;

		if (dirty != null)
		{
			int b = (int) Math.ceil(_lineWidth);
			_graphComponent.getGraphControl().repaint(dirty.x - b, dirty.y - b,
					dirty.width + 2 * b, dirty.height + 2 * b);
		}
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		if (_first != null && _current != null)
		{
			((Graphics2D) g).setStroke(new BasicStroke(_lineWidth));
			g.setColor(_lineColor);
			Rectangle rect = _current.getRectangle();

			if (_rounded)
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
		_eventSource.addListener(eventName, listener);
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
		_eventSource.removeListener(listener, eventName);
	}

}
