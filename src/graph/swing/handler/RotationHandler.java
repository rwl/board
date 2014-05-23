package graph.swing.handler;

import graph.swing.GraphComponent;
import graph.swing.util.MouseAdapter;
import graph.util.Constants;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.Rect;
import graph.util.Utils;
import graph.util.EventSource.IEventListener;
import graph.view.CellState;

import java.awt.Cursor;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;

import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;

/**
 * Basic example of implementing a handler for rotation. This can be used as follows:
 * 
 * new RotationHandler(graphComponent)
 * 
 * Note that the Java core does actually not support rotation for the selection handles,
 * perimeter points etc. Feel free to contribute a fix!
 */
public class RotationHandler extends MouseAdapter
{
	/**
	 * 
	 */
	public static ImageIcon ROTATE_ICON = null;

	/**
	 * Loads the collapse and expand icons.
	 */
	static
	{
		ROTATE_ICON = new ImageIcon(
				RotationHandler.class
						.getResource("/com/mxgraph/swing/images/rotate.gif"));
	}

	/**
	 * 
	 */
	private static double _PI4 = Math.PI / 4;

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
	protected JComponent _handle;

	/**
	 * 
	 */
	protected CellState _currentState;

	/**
	 * 
	 */
	protected double _initialAngle;

	/**
	 * 
	 */
	protected double _currentAngle;

	/**
	 * 
	 */
	protected Point _first;

	/**
	 * Constructs a new rotation handler.
	 */
	public RotationHandler(GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;
		graphComponent.addMouseListener(this);
		_handle = _createHandle();

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

		// Needs to catch events because these are consumed
		_handle.addMouseListener(this);
		_handle.addMouseMotionListener(this);
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
	protected JComponent _createHandle()
	{
		JLabel label = new JLabel(ROTATE_ICON);
		label.setSize(ROTATE_ICON.getIconWidth(), ROTATE_ICON.getIconHeight());
		label.setOpaque(false);

		return label;
	}

	/**
	 * 
	 */
	public boolean isStateHandled(CellState state)
	{
		return _graphComponent.getGraph().getModel().isVertex(state.getCell());
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (_currentState != null && _handle.getParent() != null
				&& e.getSource() == _handle /* mouse hits handle */)
		{
			start(e);
			e.consume();
		}
	}

	/**
	 * 
	 */
	public void start(MouseEvent e)
	{
		_initialAngle = Utils.getDouble(_currentState.getStyle(),
				Constants.STYLE_ROTATION) * Constants.RAD_PER_DEG;
		_currentAngle = _initialAngle;
		_first = SwingUtilities.convertPoint(e.getComponent(), e.getPoint(),
				_graphComponent.getGraphControl());

		if (!_graphComponent.getGraph().isCellSelected(_currentState.getCell()))
		{
			_graphComponent.selectCellForEvent(_currentState.getCell(), e);
		}
	}

	/**
	 * 
	 */
	public void mouseMoved(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled())
		{
			if (_handle.getParent() != null && e.getSource() == _handle /* mouse hits handle */)
			{
				_graphComponent.getGraphControl().setCursor(
						new Cursor(Cursor.HAND_CURSOR));
				e.consume();
			}
			else if (_currentState == null
					|| !_currentState.getRectangle().contains(e.getPoint()))
			{
				CellState eventState = _graphComponent
						.getGraph()
						.getView()
						.getState(
								_graphComponent.getCellAt(e.getX(), e.getY(),
										false));

				CellState state = null;

				if (eventState != null && isStateHandled(eventState))
				{
					state = eventState;
				}

				if (_currentState != state)
				{
					_currentState = state;

					if (_currentState == null && _handle.getParent() != null)
					{
						_handle.setVisible(false);
						_handle.getParent().remove(_handle);
					}
					else if (_currentState != null)
					{
						if (_handle.getParent() == null)
						{
							// Adds component for rendering the handles (preview is separate)
							_graphComponent.getGraphControl().add(_handle, 0);
							_handle.setVisible(true);
						}

						_handle.setLocation(
								(int) (_currentState.getX()
										+ _currentState.getWidth()
										- _handle.getWidth() - 4),
								(int) (_currentState.getY()
										+ _currentState.getHeight()
										- _handle.getWidth() - 4));
					}
				}
			}
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
			Rect dirty = Utils.getBoundingBox(_currentState,
					_currentAngle * Constants.DEG_PER_RAD);
			Point pt = SwingUtilities.convertPoint(e.getComponent(),
					e.getPoint(), _graphComponent.getGraphControl());

			double cx = _currentState.getCenterX();
			double cy = _currentState.getCenterY();
			double dx = pt.getX() - cx;
			double dy = pt.getY() - cy;
			double c = Math.sqrt(dx * dx + dy * dy);

			_currentAngle = ((pt.getX() > cx) ? -1 : 1) * Math.acos(dy / c)
					+ _PI4 + _initialAngle;

			dirty.add(Utils.getBoundingBox(_currentState, _currentAngle
					* Constants.DEG_PER_RAD));
			dirty.grow(1);

			// TODO: Compute dirty rectangle and repaint
			_graphComponent.getGraphControl().repaint(dirty.getRectangle());
			e.consume();
		}
		else if (_handle.getParent() != null)
		{
			_handle.getParent().remove(_handle);
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
				&& _first != null)
		{
			double deg = 0;
			Object cell = null;

			if (_currentState != null)
			{
				cell = _currentState.getCell();
				/*deg = Utils.getDouble(currentState.getStyle(),
						Constants.STYLE_ROTATION);*/
			}

			deg += _currentAngle * Constants.DEG_PER_RAD;
			boolean willExecute = cell != null && _first != null;

			// TODO: Call reset before execute in all handlers that
			// offer an execute method
			reset();

			if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()
					&& willExecute)
			{
				_graphComponent.getGraph().setCellStyles(
						Constants.STYLE_ROTATION, String.valueOf(deg),
						new Object[] { cell });

				_graphComponent.getGraphControl().repaint();

				e.consume();
			}
		}

		_currentState = null;
	}

	/**
	 * 
	 */
	public void reset()
	{
		if (_handle.getParent() != null)
		{
			_handle.getParent().remove(_handle);
		}

		Rect dirty = null;

		if (_currentState != null && _first != null)
		{
			dirty = Utils.getBoundingBox(_currentState, _currentAngle
					* Constants.DEG_PER_RAD);
			dirty.grow(1);
		}

		_currentState = null;
		_currentAngle = 0;
		_first = null;

		if (dirty != null)
		{
			_graphComponent.getGraphControl().repaint(dirty.getRectangle());
		}
	}

	/**
	 *
	 */
	public void paint(Graphics g)
	{
		if (_currentState != null && _first != null)
		{
			Rectangle rect = _currentState.getRectangle();
			double deg = _currentAngle * Constants.DEG_PER_RAD;

			if (deg != 0)
			{
				((Graphics2D) g).rotate(Math.toRadians(deg),
						_currentState.getCenterX(), _currentState.getCenterY());
			}

			Utils.setAntiAlias((Graphics2D) g, true, false);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
		}
	}

}
