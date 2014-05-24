/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import graph.model.Geometry;
//import graph.model.IGraphModel;
//import graph.swing.GraphComponent;
//import graph.swing.GraphControl;
//import graph.swing.util.MouseAdapter;
//import graph.util.Constants;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.util.EventSource.IEventListener;
//import graph.view.CellState;
//import graph.view.Graph;
//import graph.view.GraphView;

//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;
//import java.beans.PropertyChangeEvent;
//import java.beans.PropertyChangeListener;

//import javax.swing.ImageIcon;
//import javax.swing.JOptionPane;

/**
 * Connection handler creates new connections between cells. This control is used to display the connector
 * icon, while the preview is used to draw the line.
 * 
 * Event.CONNECT fires between begin- and endUpdate in mouseReleased. The <code>cell</code>
 * property contains the inserted edge, the <code>event</code> and <code>target</code> 
 * properties contain the respective arguments that were passed to mouseReleased.
 */
public class ConnectionHandler extends MouseAdapter
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -2543899557644889853L;

	/**
	 * 
	 */
	public static Cursor CONNECT_CURSOR = new Cursor(Cursor.HAND_CURSOR);

	/**
	 * 
	 */
	protected GraphComponent _graphComponent;

	/**
	 * Holds the event source.
	 */
	protected EventSource _eventSource = new EventSource(this);

	/**
	 * 
	 */
	protected ConnectPreview _connectPreview;

	/**
	 * Specifies the icon to be used for creating new connections. If this is
	 * specified then it is used instead of the handle. Default is null.
	 */
	protected ImageIcon _connectIcon = null;

	/**
	 * Specifies the size of the handle to be used for creating new
	 * connections. Default is Constants.CONNECT_HANDLE_SIZE. 
	 */
	protected int _handleSize = Constants.CONNECT_HANDLE_SIZE;

	/**
	 * Specifies if a handle should be used for creating new connections. This
	 * is only used if no connectIcon is specified. If this is false, then the
	 * source cell will be highlighted when the mouse is over the hotspot given
	 * in the marker. Default is Constants.CONNECT_HANDLE_ENABLED.
	 */
	protected boolean _handleEnabled = Constants.CONNECT_HANDLE_ENABLED;

	/**
	 * 
	 */
	protected boolean _select = true;

	/**
	 * Specifies if the source should be cloned and used as a target if no
	 * target was selected. Default is false.
	 */
	protected boolean _createTarget = false;

	/**
	 * Appearance and event handling order wrt subhandles.
	 */
	protected boolean _keepOnTop = true;

	/**
	 * 
	 */
	protected boolean _enabled = true;

	/**
	 * 
	 */
	protected transient Point _first;

	/**
	 * 
	 */
	protected transient boolean _active = false;

	/**
	 * 
	 */
	protected transient Rectangle _bounds;

	/**
	 * 
	 */
	protected transient CellState _source;

	/**
	 * 
	 */
	protected transient CellMarker _marker;

	/**
	 * 
	 */
	protected transient String _error;

	/**
	 * 
	 */
	protected transient IEventListener _resetHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			reset();
		}
	};

	/**
	 * 
	 * @param graphComponent
	 */
	public ConnectionHandler(GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;

		// Installs the paint handler
		graphComponent.addListener(Event.AFTER_PAINT, new IEventListener()
		{
			public void invoke(Object sender, EventObj evt)
			{
				Graphics g = (Graphics) evt.getProperty("g");
				paint(g);
			}
		});

		_connectPreview = _createConnectPreview();

		GraphControl graphControl = graphComponent.getGraphControl();
		graphControl.addMouseListener(this);
		graphControl.addMouseMotionListener(this);

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

		_marker = new CellMarker(graphComponent)
		{
			/**
			 * 
			 */
			private static final long serialVersionUID = 103433247310526381L;

			// Overrides to return cell at location only if valid (so that
			// there is no highlight for invalid cells that have no error
			// message when the mouse is released)
			protected Object _getCell(MouseEvent e)
			{
				Object cell = super._getCell(e);

				if (isConnecting())
				{
					if (_source != null)
					{
						_error = validateConnection(_source.getCell(), cell);

						if (_error != null && _error.length() == 0)
						{
							cell = null;

							// Enables create target inside groups
							if (_createTarget)
							{
								_error = null;
							}
						}
					}
				}
				else if (!isValidSource(cell))
				{
					cell = null;
				}

				return cell;
			}

			// Sets the highlight color according to isValidConnection
			protected boolean _isValidState(CellState state)
			{
				if (isConnecting())
				{
					return _error == null;
				}
				else
				{
					return super._isValidState(state);
				}
			}

			// Overrides to use marker color only in highlight mode or for
			// target selection
			protected Color _getMarkerColor(MouseEvent e, CellState state,
					boolean isValid)
			{
				return (isHighlighting() || isConnecting()) ? super
						._getMarkerColor(e, state, isValid) : null;
			}

			// Overrides to use hotspot only for source selection otherwise
			// intersects always returns true when over a cell
			protected boolean _intersects(CellState state, MouseEvent e)
			{
				if (!isHighlighting() || isConnecting())
				{
					return true;
				}

				return super._intersects(state, e);
			}
		};

		_marker.setHotspotEnabled(true);
	}

	/**
	 * Installs the listeners to update the handles after any changes.
	 */
	protected void _addGraphListeners(Graph graph)
	{
		// LATER: Install change listener for graph model, view
		if (graph != null)
		{
			GraphView view = graph.getView();
			view.addListener(Event.SCALE, _resetHandler);
			view.addListener(Event.TRANSLATE, _resetHandler);
			view.addListener(Event.SCALE_AND_TRANSLATE, _resetHandler);

			graph.getModel().addListener(Event.CHANGE, _resetHandler);
		}
	}

	/**
	 * Removes all installed listeners.
	 */
	protected void _removeGraphListeners(Graph graph)
	{
		if (graph != null)
		{
			GraphView view = graph.getView();
			view.removeListener(_resetHandler, Event.SCALE);
			view.removeListener(_resetHandler, Event.TRANSLATE);
			view.removeListener(_resetHandler, Event.SCALE_AND_TRANSLATE);

			graph.getModel().removeListener(_resetHandler, Event.CHANGE);
		}
	}

	/**
	 * 
	 */
	protected ConnectPreview _createConnectPreview()
	{
		return new ConnectPreview(_graphComponent);
	}

	/**
	 * 
	 */
	public ConnectPreview getConnectPreview()
	{
		return _connectPreview;
	}

	/**
	 * 
	 */
	public void setConnectPreview(ConnectPreview value)
	{
		_connectPreview = value;
	}

	/**
	 * Returns true if the source terminal has been clicked and a new
	 * connection is currently being previewed.
	 */
	public boolean isConnecting()
	{
		return _connectPreview.isActive();
	}

	/**
	 * 
	 */
	public boolean isActive()
	{
		return _active;
	}
	
	/**
	 * Returns true if no connectIcon is specified and handleEnabled is false.
	 */
	public boolean isHighlighting()
	{
		return _connectIcon == null && !_handleEnabled;
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
	public boolean isKeepOnTop()
	{
		return _keepOnTop;
	}

	/**
	 * 
	 */
	public void setKeepOnTop(boolean value)
	{
		_keepOnTop = value;
	}

	/**
	 * 
	 */
	public void setConnectIcon(ImageIcon value)
	{
		_connectIcon = value;
	}

	/**
	 * 
	 */
	public ImageIcon getConnecIcon()
	{
		return _connectIcon;
	}

	/**
	 * 
	 */
	public void setHandleEnabled(boolean value)
	{
		_handleEnabled = value;
	}

	/**
	 * 
	 */
	public boolean isHandleEnabled()
	{
		return _handleEnabled;
	}

	/**
	 * 
	 */
	public void setHandleSize(int value)
	{
		_handleSize = value;
	}

	/**
	 * 
	 */
	public int getHandleSize()
	{
		return _handleSize;
	}

	/**
	 * 
	 */
	public CellMarker getMarker()
	{
		return _marker;
	}

	/**
	 * 
	 */
	public void setMarker(CellMarker value)
	{
		_marker = value;
	}

	/**
	 * 
	 */
	public void setCreateTarget(boolean value)
	{
		_createTarget = value;
	}

	/**
	 * 
	 */
	public boolean isCreateTarget()
	{
		return _createTarget;
	}

	/**
	 * 
	 */
	public void setSelect(boolean value)
	{
		_select = value;
	}

	/**
	 * 
	 */
	public boolean isSelect()
	{
		return _select;
	}

	/**
	 * 
	 */
	public void reset()
	{
		_connectPreview.stop(false);
		setBounds(null);
		_marker.reset();
		_active = false;
		_source = null;
		_first = null;
		_error = null;
	}

	/**
	 * 
	 */
	public Object createTargetVertex(MouseEvent e, Object source)
	{
		Graph graph = _graphComponent.getGraph();
		Object clone = graph.cloneCells(new Object[] { source })[0];
		IGraphModel model = graph.getModel();
		Geometry geo = model.getGeometry(clone);

		if (geo != null)
		{
			Point2d point = _graphComponent.getPointForEvent(e);
			geo.setX(graph.snap(point.getX() - geo.getWidth() / 2));
			geo.setY(graph.snap(point.getY() - geo.getHeight() / 2));
		}

		return clone;
	}

	/**
	 * 
	 */
	public boolean isValidSource(Object cell)
	{
		return _graphComponent.getGraph().isValidSource(cell);
	}

	/**
	 * Returns true. The call to Graph.isValidTarget is implicit by calling
	 * Graph.getEdgeValidationError in validateConnection. This is an
	 * additional hook for disabling certain targets in this specific handler.
	 */
	public boolean isValidTarget(Object cell)
	{
		return true;
	}

	/**
	 * Returns the error message or an empty string if the connection for the
	 * given source target pair is not valid. Otherwise it returns null.
	 */
	public String validateConnection(Object source, Object target)
	{
		if (target == null && _createTarget)
		{
			return null;
		}

		if (!isValidTarget(target))
		{
			return "";
		}

		return _graphComponent.getGraph().getEdgeValidationError(
				_connectPreview.getPreviewState().getCell(), source, target);
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (!_graphComponent.isForceMarqueeEvent(e)
				&& !_graphComponent.isPanningEvent(e)
				&& !e.isPopupTrigger()
				&& _graphComponent.isEnabled()
				&& isEnabled()
				&& !e.isConsumed()
				&& ((isHighlighting() && _marker.hasValidState()) || (!isHighlighting()
						&& _bounds != null && _bounds.contains(e.getPoint()))))
		{
			start(e, _marker.getValidState());
			e.consume();
		}
	}

	/**
	 * 
	 */
	public void start(MouseEvent e, CellState state)
	{
		_first = e.getPoint();
		_connectPreview.start(e, state, "");
	}

	/**
	 * 
	 */
	public void mouseMoved(MouseEvent e)
	{
		mouseDragged(e);

		if (isHighlighting() && !_marker.hasValidState())
		{
			_source = null;
		}

		if (!isHighlighting() && _source != null)
		{
			int imgWidth = _handleSize;
			int imgHeight = _handleSize;

			if (_connectIcon != null)
			{
				imgWidth = _connectIcon.getIconWidth();
				imgHeight = _connectIcon.getIconHeight();
			}

			int x = (int) _source.getCenterX() - imgWidth / 2;
			int y = (int) _source.getCenterY() - imgHeight / 2;

			if (_graphComponent.getGraph().isSwimlane(_source.getCell()))
			{
				Rect size = _graphComponent.getGraph().getStartSize(
						_source.getCell());

				if (size.getWidth() > 0)
				{
					x = (int) (_source.getX() + size.getWidth() / 2 - imgWidth / 2);
				}
				else
				{
					y = (int) (_source.getY() + size.getHeight() / 2 - imgHeight / 2);
				}
			}

			setBounds(new Rectangle(x, y, imgWidth, imgHeight));
		}
		else
		{
			setBounds(null);
		}

		if (_source != null && (_bounds == null || _bounds.contains(e.getPoint())))
		{
			_graphComponent.getGraphControl().setCursor(CONNECT_CURSOR);
			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (!e.isConsumed() && _graphComponent.isEnabled() && isEnabled())
		{
			// Activates the handler
			if (!_active && _first != null)
			{
				double dx = Math.abs(_first.getX() - e.getX());
				double dy = Math.abs(_first.getY() - e.getY());
				int tol = _graphComponent.getTolerance();
				
				if (dx > tol || dy > tol)
				{
					_active = true;
				}
			}
			
			if (e.getButton() == 0 || (isActive() && _connectPreview.isActive()))
			{
				CellState state = _marker.process(e);
	
				if (_connectPreview.isActive())
				{
					_connectPreview.update(e, _marker.getValidState(), e.getX(),
							e.getY());
					setBounds(null);
					e.consume();
				}
				else
				{
					_source = state;
				}
			}
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (isActive())
		{
			if (_error != null)
			{
				if (_error.length() > 0)
				{
					JOptionPane.showMessageDialog(_graphComponent, _error);
				}
			}
			else if (_first != null)
			{
				Graph graph = _graphComponent.getGraph();
				double dx = _first.getX() - e.getX();
				double dy = _first.getY() - e.getY();
	
				if (_connectPreview.isActive()
						&& (_marker.hasValidState() || isCreateTarget() || graph
								.isAllowDanglingEdges()))
				{
					graph.getModel().beginUpdate();
	
					try
					{
						Object dropTarget = null;
	
						if (!_marker.hasValidState() && isCreateTarget())
						{
							Object vertex = createTargetVertex(e, _source.getCell());
							dropTarget = graph.getDropTarget(
									new Object[] { vertex }, e.getPoint(),
									_graphComponent.getCellAt(e.getX(), e.getY()));
	
							if (vertex != null)
							{
								// Disables edges as drop targets if the target cell was created
								if (dropTarget == null
										|| !graph.getModel().isEdge(dropTarget))
								{
									CellState pstate = graph.getView().getState(
											dropTarget);
	
									if (pstate != null)
									{
										Geometry geo = graph.getModel()
												.getGeometry(vertex);
	
										Point2d origin = pstate.getOrigin();
										geo.setX(geo.getX() - origin.getX());
										geo.setY(geo.getY() - origin.getY());
									}
								}
								else
								{
									dropTarget = graph.getDefaultParent();
								}
	
								graph.addCells(new Object[] { vertex }, dropTarget);
							}
	
							// FIXME: Here we pre-create the state for the vertex to be
							// inserted in order to invoke update in the connectPreview.
							// This means we have a cell state which should be created
							// after the model.update, so this should be fixed.
							CellState targetState = graph.getView().getState(
									vertex, true);
							_connectPreview.update(e, targetState, e.getX(),
									e.getY());
						}
	
						Object cell = _connectPreview.stop(
								_graphComponent.isSignificant(dx, dy), e);
	
						if (cell != null)
						{
							_graphComponent.getGraph().setSelectionCell(cell);
							_eventSource.fireEvent(new EventObj(
									Event.CONNECT, "cell", cell, "event", e,
									"target", dropTarget));
						}
	
						e.consume();
					}
					finally
					{
						graph.getModel().endUpdate();
					}
				}
			}
		}

		reset();
	}

	/**
	 * 
	 */
	public void setBounds(Rectangle value)
	{
		if ((_bounds == null && value != null)
				|| (_bounds != null && value == null)
				|| (_bounds != null && value != null && !_bounds.equals(value)))
		{
			Rectangle tmp = _bounds;

			if (tmp != null)
			{
				if (value != null)
				{
					tmp.add(value);
				}
			}
			else
			{
				tmp = value;
			}

			_bounds = value;

			if (tmp != null)
			{
				_graphComponent.getGraphControl().repaint(tmp);
			}
		}
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
	 * 
	 */
	public void paint(Graphics g)
	{
		if (_bounds != null)
		{
			if (_connectIcon != null)
			{
				g.drawImage(_connectIcon.getImage(), _bounds.x, _bounds.y,
						_bounds.width, _bounds.height, null);
			}
			else if (_handleEnabled)
			{
				g.setColor(Color.BLACK);
				g.draw3DRect(_bounds.x, _bounds.y, _bounds.width - 1,
						_bounds.height - 1, true);
				g.setColor(Color.GREEN);
				g.fill3DRect(_bounds.x + 1, _bounds.y + 1, _bounds.width - 2,
						_bounds.height - 2, true);
				g.setColor(Color.BLUE);
				g.drawRect(_bounds.x + _bounds.width / 2 - 1, _bounds.y
						+ _bounds.height / 2 - 1, 1, 1);
			}
		}
	}

}
