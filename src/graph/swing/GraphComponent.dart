/**
 * Copyright (c) 2009-2010, Gaudenz Alder, David Benson
 */
part of graph.swing;

//import graph.canvas.Graphics2DCanvas;
//import graph.model.Filter;
//import graph.model.GraphModel;
//import graph.model.IGraphModel;
//import graph.swing.handler.CellHandler;
//import graph.swing.handler.ConnectionHandler;
//import graph.swing.handler.EdgeHandler;
//import graph.swing.handler.ElbowEdgeHandler;
//import graph.swing.handler.GraphHandler;
//import graph.swing.handler.GraphTransferHandler;
//import graph.swing.handler.PanningHandler;
//import graph.swing.handler.SelectionCellsHandler;
//import graph.swing.handler.VertexHandler;
//import graph.swing.util.CellOverlay;
//import graph.swing.util.ICellOverlay;
//import graph.swing.view.CellEditor;
//import graph.swing.view.ICellEditor;
//import graph.swing.view.InteractiveCanvas;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.util.Resources;
//import graph.util.Utils;
//import graph.util.EventSource.IEventListener;
//import graph.view.CellState;
//import graph.view.EdgeStyle;
//import graph.view.Graph;
//import graph.view.GraphView;
//import graph.view.TemporaryCellStates;
//import graph.view.EdgeStyle.EdgeStyleFunction;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Component;
//import java.awt.Cursor;
//import java.awt.Dimension;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.ComponentAdapter;
//import java.awt.event.ComponentEvent;
//import java.awt.event.KeyAdapter;
//import java.awt.event.KeyEvent;
//import java.awt.event.MouseAdapter;
//import java.awt.event.MouseEvent;
//import java.awt.image.BufferedImage;
//import java.awt.print.PageFormat;
//import java.awt.print.Printable;
//import java.beans.PropertyChangeEvent;
//import java.beans.PropertyChangeListener;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Collection;
//import java.util.EventObject;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map;

//import javax.swing.BorderFactory;
//import javax.swing.BoundedRangeModel;
//import javax.swing.ImageIcon;
//import javax.swing.JPanel;
//import javax.swing.JScrollBar;
//import javax.swing.JScrollPane;
//import javax.swing.RepaintManager;
//import javax.swing.SwingUtilities;
//import javax.swing.ToolTipManager;
//import javax.swing.TransferHandler;

/**
 * For setting the preferred size of the viewport for scrolling, use
 * Graph.setMinimumGraphSize. This component is a combined scrollpane with an
 * inner GraphControl. The control contains the actual graph display.
 * 
 * To set the background color of the graph, use the following code:
 * 
 * <pre>
 * graphComponent.getViewport().setOpaque(true);
 * graphComponent.getViewport().setBackground(newColor);
 * </pre>
 * 
 * This class fires the following events:
 * 
 * Event.START_EDITING fires before starting the in-place editor for an
 * existing cell in startEditingAtCell. The <code>cell</code> property contains
 * the cell that is being edit and the <code>event</code> property contains
 * optional EventObject which was passed to startEditingAtCell.
 * 
 * Event.LABEL_CHANGED fires between begin- and endUpdate after the call to
 * Graph.cellLabelChanged in labelChanged. The <code>cell</code> property
 * contains the cell, the <code>value</code> property contains the new value for
 * the cell and the optional <code>event</code> property contains the
 * EventObject that started the edit.
 * 
 * Event.ADD_OVERLAY and Event.REMOVE_OVERLAY fire afer an overlay was added
 * or removed using add-/removeOverlay. The <code>cell</code> property contains
 * the cell for which the overlay was added or removed and the
 * <code>overlay</code> property contain the mxOverlay.
 * 
 * Event.BEFORE_PAINT and Event.AFTER_PAINT fire before and after the paint
 * method is called on the component. The <code>g</code> property contains the
 * graphics context which is used for painting.
 */
public class GraphComponent extends JScrollPane implements Printable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -30203858391633447L;

	/**
	 * 
	 */
	public static final int GRID_STYLE_DOT = 0;

	/**
	 * 
	 */
	public static final int GRID_STYLE_CROSS = 1;

	/**
	 * 
	 */
	public static final int GRID_STYLE_LINE = 2;

	/**
	 * 
	 */
	public static final int GRID_STYLE_DASHED = 3;

	/**
	 * 
	 */
	public static final int ZOOM_POLICY_NONE = 0;

	/**
	 * 
	 */
	public static final int ZOOM_POLICY_PAGE = 1;

	/**
	 * 
	 */
	public static final int ZOOM_POLICY_WIDTH = 2;

	/**
	 * 
	 */
	public static ImageIcon DEFAULT_EXPANDED_ICON = null;

	/**
	 * 
	 */
	public static ImageIcon DEFAULT_COLLAPSED_ICON = null;

	/**
	 * 
	 */
	public static ImageIcon DEFAULT_WARNING_ICON = null;

	/**
	 * Specifies the default page scale. Default is 1.4
	 */
	public static final double DEFAULT_PAGESCALE = 1.4;

	/**
	 * Loads the collapse and expand icons.
	 */
	static
	{
		DEFAULT_EXPANDED_ICON = new ImageIcon(
				GraphComponent.class
						.getResource("/com/mxgraph/swing/images/expanded.gif"));
		DEFAULT_COLLAPSED_ICON = new ImageIcon(
				GraphComponent.class
						.getResource("/com/mxgraph/swing/images/collapsed.gif"));
		DEFAULT_WARNING_ICON = new ImageIcon(
				GraphComponent.class
						.getResource("/com/mxgraph/swing/images/warning.gif"));
	}

	/**
	 * 
	 */
	protected Graph _graph;

	/**
	 * 
	 */
	protected GraphControl _graphControl;

	/**
	 * 
	 */
	protected EventSource _eventSource = new EventSource(this);

	/**
	 * 
	 */
	protected ICellEditor _cellEditor;

	/**
	 * 
	 */
	protected ConnectionHandler _connectionHandler;

	/**
	 * 
	 */
	protected PanningHandler _panningHandler;

	/**
	 * 
	 */
	protected SelectionCellsHandler _selectionCellsHandler;

	/**
	 * 
	 */
	protected GraphHandler _graphHandler;

	/**
	 * The transparency of previewed cells from 0.0. to 0.1. 0.0 indicates
	 * transparent, 1.0 indicates opaque. Default is 1.
	 */
	protected float _previewAlpha = 0.5f;

	/**
	 * Specifies the <Image> to be returned by <getBackgroundImage>. Default
	 * is null.
	 */
	protected ImageIcon _backgroundImage;

	/**
	 * Background page format.
	 */
	protected PageFormat _pageFormat = new PageFormat();

	/**
	 * 
	 */
	protected InteractiveCanvas _canvas;

	/**
	 * 
	 */
	protected BufferedImage _tripleBuffer;

	/**
	 * 
	 */
	protected Graphics2D _tripleBufferGraphics;

	/**
	 * Defines the scaling for the background page metrics. Default is
	 * {@link #DEFAULT_PAGESCALE}.
	 */
	protected double _pageScale = DEFAULT_PAGESCALE;

	/**
	 * Specifies if the background page should be visible. Default is false.
	 */
	protected boolean _pageVisible = false;

	/**
	 * If the pageFormat should be used to determine the minimal graph bounds
	 * even if the page is not visible (see pageVisible). Default is false.
	 */
	protected boolean _preferPageSize = false;

	/**
	 * Specifies if a dashed line should be drawn between multiple pages.
	 */
	protected boolean _pageBreaksVisible = true;

	/**
	 * Specifies the color of page breaks
	 */
	protected Color _pageBreakColor = Color.darkGray;

	/**
	 * Specifies the number of pages in the horizontal direction.
	 */
	protected int _horizontalPageCount = 1;

	/**
	 * Specifies the number of pages in the vertical direction.
	 */
	protected int _verticalPageCount = 1;

	/**
	 * Specifies if the background page should be centered by automatically
	 * setting the translate in the view. Default is true. This does only apply
	 * if pageVisible is true.
	 */
	protected boolean _centerPage = true;

	/**
	 * Color of the background area if layout view.
	 */
	protected Color _pageBackgroundColor = new Color(144, 153, 174);

	/**
	 * 
	 */
	protected Color _pageShadowColor = new Color(110, 120, 140);

	/**
	 * 
	 */
	protected Color _pageBorderColor = Color.black;

	/**
	 * Specifies if the grid is visible. Default is false.
	 */
	protected boolean _gridVisible = false;

	/**
	 * 
	 */
	protected Color _gridColor = new Color(192, 192, 192);

	/**
	 * Whether or not to scroll the scrollable container the graph exists in if
	 * a suitable handler is active and the graph bounds already exist extended
	 * in the direction of mouse travel.
	 */
	protected boolean _autoScroll = true;

	/**
	 * Whether to extend the graph bounds and scroll towards the limit of those
	 * new bounds in the direction of mouse travel if a handler is active while
	 * the mouse leaves the container that the graph exists in.
	 */
	protected boolean _autoExtend = true;

	/**
	 * 
	 */
	protected boolean _dragEnabled = true;

	/**
	 * 
	 */
	protected boolean _importEnabled = true;

	/**
	 * 
	 */
	protected boolean _exportEnabled = true;

	/**
	 * Specifies if folding (collapse and expand via an image icon in the graph
	 * should be enabled). Default is true.
	 */
	protected boolean _foldingEnabled = true;

	/**
	 * Specifies the tolerance for mouse clicks. Default is 4.
	 */
	protected int _tolerance = 4;

	/**
	 * Specifies if swimlanes are selected when the mouse is released over the
	 * swimlanes content area. Default is true.
	 */
	protected boolean _swimlaneSelectionEnabled = true;

	/**
	 * Specifies if the content area should be transparent to events. Default is
	 * true.
	 */
	protected boolean _transparentSwimlaneContent = true;

	/**
	 * 
	 */
	protected int _gridStyle = GRID_STYLE_DOT;

	/**
	 * 
	 */
	protected ImageIcon _expandedIcon = DEFAULT_EXPANDED_ICON;

	/**
	 * 
	 */
	protected ImageIcon _collapsedIcon = DEFAULT_COLLAPSED_ICON;

	/**
	 * 
	 */
	protected ImageIcon _warningIcon = DEFAULT_WARNING_ICON;

	/**
	 * 
	 */
	protected boolean _antiAlias = true;

	/**
	 * 
	 */
	protected boolean _textAntiAlias = true;

	/**
	 * Specifies <escape> should be invoked when the escape key is pressed.
	 * Default is true.
	 */
	protected boolean _escapeEnabled = true;

	/**
	 * If true, when editing is to be stopped by way of selection changing, data
	 * in diagram changing or other means stopCellEditing is invoked, and
	 * changes are saved. This is implemented in a mouse listener in this class.
	 * Default is true.
	 */
	protected boolean _invokesStopCellEditing = true;

	/**
	 * If true, pressing the enter key without pressing control will stop
	 * editing and accept the new value. This is used in <mxKeyHandler> to stop
	 * cell editing. Default is false.
	 */
	protected boolean _enterStopsCellEditing = false;

	/**
	 * Specifies the zoom policy. Default is ZOOM_POLICY_PAGE. The zoom policy
	 * does only apply if pageVisible is true.
	 */
	protected int _zoomPolicy = ZOOM_POLICY_PAGE;

	/**
	 * Internal flag to not reset zoomPolicy when zoom was set automatically.
	 */
	private transient boolean _zooming = false;

	/**
	 * Specifies the factor used for zoomIn and zoomOut. Default is 1.2 (120%).
	 */
	protected double _zoomFactor = 1.2;

	/**
	 * Specifies if the viewport should automatically contain the selection
	 * cells after a zoom operation. Default is false.
	 */
	protected boolean _keepSelectionVisibleOnZoom = false;

	/**
	 * Specifies if the zoom operations should go into the center of the actual
	 * diagram rather than going from top, left. Default is true.
	 */
	protected boolean _centerZoom = true;

	/**
	 * Specifies if an image buffer should be used for painting the component.
	 * Default is false.
	 */
	protected boolean _tripleBuffered = false;

	/**
	 * Used for debugging the dirty region.
	 */
	public boolean showDirtyRectangle = false;

	/**
	 * Maps from cells to lists of heavyweights.
	 */
	protected Hashtable<Object, Component[]> _components = new Hashtable<Object, Component[]>();

	/**
	 * Maps from cells to lists of overlays.
	 */
	protected Hashtable<Object, ICellOverlay[]> _overlays = new Hashtable<Object, ICellOverlay[]>();

	/**
	 * Boolean flag to disable centering after the first time.
	 */
	private transient boolean _centerOnResize = true;

	/**
	 * Updates the heavyweight component structure after any changes.
	 */
	protected IEventListener _updateHandler = new IEventListener()
	{
		public void invoke(Object sender, EventObj evt)
		{
			updateComponents();
			_graphControl.updatePreferredSize();
		}
	};

	/**
	 * 
	 */
	protected IEventListener _repaintHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			Rect dirty = (Rect) evt.getProperty("region");
			Rectangle rect = (dirty != null) ? dirty.getRectangle() : null;

			if (rect != null)
			{
				rect.grow(1, 1);
			}

			// Updates the triple buffer
			repaintTripleBuffer(rect);

			// Repaints the control using the optional triple buffer
			_graphControl.repaint((rect != null) ? rect : getViewport()
					.getViewRect());

			// ----------------------------------------------------------
			// Shows the dirty region as a red rectangle (for debugging)
			JPanel panel = (JPanel) getClientProperty("dirty");

			if (showDirtyRectangle)
			{
				if (panel == null)
				{
					panel = new JPanel();
					panel.setOpaque(false);
					panel.setBorder(BorderFactory.createLineBorder(Color.RED));

					putClientProperty("dirty", panel);
					_graphControl.add(panel);
				}

				if (dirty != null)
				{
					panel.setBounds(dirty.getRectangle());
				}

				panel.setVisible(dirty != null);
			}
			else if (panel != null && panel.getParent() != null)
			{
				panel.getParent().remove(panel);
				putClientProperty("dirty", null);
				repaint();
			}
			// ----------------------------------------------------------
		}
	};

	/**
	 * 
	 */
	protected PropertyChangeListener _viewChangeHandler = new PropertyChangeListener()
	{
		/**
		 * 
		 */
		public void propertyChange(PropertyChangeEvent evt)
		{
			if (evt.getPropertyName().equals("view"))
			{
				GraphView oldView = (GraphView) evt.getOldValue();
				GraphView newView = (GraphView) evt.getNewValue();

				if (oldView != null)
				{
					oldView.removeListener(_updateHandler);
				}

				if (newView != null)
				{
					newView.addListener(Event.SCALE, _updateHandler);
					newView.addListener(Event.TRANSLATE, _updateHandler);
					newView.addListener(Event.SCALE_AND_TRANSLATE,
							_updateHandler);
					newView.addListener(Event.UP, _updateHandler);
					newView.addListener(Event.DOWN, _updateHandler);
				}
			}
			else if (evt.getPropertyName().equals("model"))
			{
				GraphModel oldModel = (GraphModel) evt.getOldValue();
				GraphModel newModel = (GraphModel) evt.getNewValue();

				if (oldModel != null)
				{
					oldModel.removeListener(_updateHandler);
				}

				if (newModel != null)
				{
					newModel.addListener(Event.CHANGE, _updateHandler);
				}
			}
		}

	};

	/**
	 * Resets the zoom policy if the scale is changed manually.
	 */
	protected IEventListener _scaleHandler = new IEventListener()
	{
		/**
		 * 
		 */
		public void invoke(Object sender, EventObj evt)
		{
			if (!_zooming)
			{
				_zoomPolicy = ZOOM_POLICY_NONE;
			}
		}
	};

	/**
	 * 
	 * @param graph
	 */
	public GraphComponent(Graph graph)
	{
		setCellEditor(_createCellEditor());
		_canvas = createCanvas();

		// Initializes the buffered view and
		_graphControl = _createGraphControl();
		_installFocusHandler();
		_installKeyHandler();
		_installResizeHandler();
		setGraph(graph);

		// Adds the viewport view and initializes handlers
		setViewportView(_graphControl);
		_createHandlers();
		_installDoubleClickHandler();
	}

	/**
	 * installs a handler to set the focus to the container.
	 */
	protected void _installFocusHandler()
	{
		_graphControl.addMouseListener(new MouseAdapter()
		{
			public void mousePressed(MouseEvent e)
			{
				if (!hasFocus())
				{
					requestFocus();
				}
			}
		});
	}

	/**
	 * Handles escape keystrokes.
	 */
	protected void _installKeyHandler()
	{
		addKeyListener(new KeyAdapter()
		{
			public void keyPressed(KeyEvent e)
			{
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE && isEscapeEnabled())
				{
					escape(e);
				}
			}
		});
	}

	/**
	 * Applies the zoom policy if the size of the component changes.
	 */
	protected void _installResizeHandler()
	{
		addComponentListener(new ComponentAdapter()
		{
			public void componentResized(ComponentEvent e)
			{
				zoomAndCenter();
			}
		});
	}

	/**
	 * Adds handling of edit and stop-edit events after all other handlers have
	 * been installed.
	 */
	protected void _installDoubleClickHandler()
	{
		_graphControl.addMouseListener(new MouseAdapter()
		{
			public void mouseReleased(MouseEvent e)
			{
				if (isEnabled())
				{
					if (!e.isConsumed() && isEditEvent(e))
					{
						Object cell = getCellAt(e.getX(), e.getY(), false);

						if (cell != null && getGraph().isCellEditable(cell))
						{
							startEditingAtCell(cell, e);
						}
					}
					else
					{
						// Other languages use focus traversal here, in Java
						// we explicitely stop editing after a click elsewhere
						stopEditing(!_invokesStopCellEditing);
					}
				}
			}

		});
	}

	/**
	 * 
	 */
	protected ICellEditor _createCellEditor()
	{
		return new CellEditor(this);
	}

	/**
	 * 
	 */
	public void setGraph(Graph value)
	{
		Graph oldValue = _graph;

		// Uninstalls listeners for existing graph
		if (_graph != null)
		{
			_graph.removeListener(_repaintHandler);
			_graph.getModel().removeListener(_updateHandler);
			_graph.getView().removeListener(_updateHandler);
			_graph.removePropertyChangeListener(_viewChangeHandler);
			_graph.getView().removeListener(_scaleHandler);
		}

		_graph = value;

		// Updates the buffer if the model changes
		_graph.addListener(Event.REPAINT, _repaintHandler);

		// Installs the update handler to sync the overlays and controls
		_graph.getModel().addListener(Event.CHANGE, _updateHandler);

		// Repaint after the following events is handled via
		// Graph.repaint-events
		// The respective handlers are installed in Graph.setView
		GraphView view = _graph.getView();

		view.addListener(Event.SCALE, _updateHandler);
		view.addListener(Event.TRANSLATE, _updateHandler);
		view.addListener(Event.SCALE_AND_TRANSLATE, _updateHandler);
		view.addListener(Event.UP, _updateHandler);
		view.addListener(Event.DOWN, _updateHandler);

		_graph.addPropertyChangeListener(_viewChangeHandler);

		// Resets the zoom policy if the scale changes
		_graph.getView().addListener(Event.SCALE, _scaleHandler);
		_graph.getView().addListener(Event.SCALE_AND_TRANSLATE, _scaleHandler);

		// Invoke the update handler once for initial state
		_updateHandler.invoke(_graph.getView(), null);

		firePropertyChange("graph", oldValue, _graph);
	}

	/**
	 * 
	 * @return Returns the object that contains the graph.
	 */
	public Graph getGraph()
	{
		return _graph;
	}

	/**
	 * Creates the inner control that handles tooltips, preferred size and can
	 * draw cells onto a canvas.
	 */
	protected GraphControl _createGraphControl()
	{
		return new GraphControl(this);
	}

	/**
	 * 
	 * @return Returns the control that renders the graph.
	 */
	public GraphControl getGraphControl()
	{
		return _graphControl;
	}

	/**
	 * Creates the connection-, panning and graphhandler (in this order).
	 */
	protected void _createHandlers()
	{
		setTransferHandler(_createTransferHandler());
		_panningHandler = _createPanningHandler();
		_selectionCellsHandler = _createSelectionCellsHandler();
		_connectionHandler = _createConnectionHandler();
		_graphHandler = _createGraphHandler();
	}

	/**
	 * 
	 */
	protected TransferHandler _createTransferHandler()
	{
		return new GraphTransferHandler();
	}

	/**
	 *
	 */
	protected SelectionCellsHandler _createSelectionCellsHandler()
	{
		return new SelectionCellsHandler(this);
	}

	/**
	 *
	 */
	protected GraphHandler _createGraphHandler()
	{
		return new GraphHandler(this);
	}

	/**
	 * 
	 */
	public SelectionCellsHandler getSelectionCellsHandler()
	{
		return _selectionCellsHandler;
	}

	/**
	 * 
	 */
	public GraphHandler getGraphHandler()
	{
		return _graphHandler;
	}

	/**
	 *
	 */
	protected ConnectionHandler _createConnectionHandler()
	{
		return new ConnectionHandler(this);
	}

	/**
	 * 
	 */
	public ConnectionHandler getConnectionHandler()
	{
		return _connectionHandler;
	}

	/**
	 *
	 */
	protected PanningHandler _createPanningHandler()
	{
		return new PanningHandler(this);
	}

	/**
	 * 
	 */
	public PanningHandler getPanningHandler()
	{
		return _panningHandler;
	}

	/**
	 * 
	 */
	public boolean isEditing()
	{
		return getCellEditor().getEditingCell() != null;
	}

	/**
	 * 
	 */
	public ICellEditor getCellEditor()
	{
		return _cellEditor;
	}

	/**
	 * 
	 */
	public void setCellEditor(ICellEditor value)
	{
		ICellEditor oldValue = _cellEditor;
		_cellEditor = value;

		firePropertyChange("cellEditor", oldValue, _cellEditor);
	}

	/**
	 * @return the tolerance
	 */
	public int getTolerance()
	{
		return _tolerance;
	}

	/**
	 * @param value
	 *            the tolerance to set
	 */
	public void setTolerance(int value)
	{
		int oldValue = _tolerance;
		_tolerance = value;

		firePropertyChange("tolerance", oldValue, _tolerance);
	}

	/**
	 * 
	 */
	public PageFormat getPageFormat()
	{
		return _pageFormat;
	}

	/**
	 * 
	 */
	public void setPageFormat(PageFormat value)
	{
		PageFormat oldValue = _pageFormat;
		_pageFormat = value;

		firePropertyChange("pageFormat", oldValue, _pageFormat);
	}

	/**
	 * 
	 */
	public double getPageScale()
	{
		return _pageScale;
	}

	/**
	 * 
	 */
	public void setPageScale(double value)
	{
		double oldValue = _pageScale;
		_pageScale = value;

		firePropertyChange("pageScale", oldValue, _pageScale);
	}

	/**
	 * Returns the size of the area that layouts can operate in.
	 */
	public Rect getLayoutAreaSize()
	{
		if (_pageVisible)
		{
			Dimension d = _getPreferredSizeForPage();

			return new Rect(new Rectangle(d));
		}
		else
		{
			return new Rect(new Rectangle(_graphControl.getSize()));
		}
	}

	/**
	 * 
	 */
	public ImageIcon getBackgroundImage()
	{
		return _backgroundImage;
	}

	/**
	 * 
	 */
	public void setBackgroundImage(ImageIcon value)
	{
		ImageIcon oldValue = _backgroundImage;
		_backgroundImage = value;

		firePropertyChange("backgroundImage", oldValue, _backgroundImage);
	}

	/**
	 * @return the pageVisible
	 */
	public boolean isPageVisible()
	{
		return _pageVisible;
	}

	/**
	 * Fires a property change event for <code>pageVisible</code>. zoomAndCenter
	 * should be called if this is set to true.
	 * 
	 * @param value
	 *            the pageVisible to set
	 */
	public void setPageVisible(boolean value)
	{
		boolean oldValue = _pageVisible;
		_pageVisible = value;

		firePropertyChange("pageVisible", oldValue, _pageVisible);
	}

	/**
	 * @return the preferPageSize
	 */
	public boolean isPreferPageSize()
	{
		return _preferPageSize;
	}

	/**
	 * Fires a property change event for <code>preferPageSize</code>.
	 * 
	 * @param value
	 *            the preferPageSize to set
	 */
	public void setPreferPageSize(boolean value)
	{
		boolean oldValue = _preferPageSize;
		_preferPageSize = value;

		firePropertyChange("preferPageSize", oldValue, _preferPageSize);
	}

	/**
	 * @return the pageBreaksVisible
	 */
	public boolean isPageBreaksVisible()
	{
		return _pageBreaksVisible;
	}

	/**
	 * @param value
	 *            the pageBreaksVisible to set
	 */
	public void setPageBreaksVisible(boolean value)
	{
		boolean oldValue = _pageBreaksVisible;
		_pageBreaksVisible = value;

		firePropertyChange("pageBreaksVisible", oldValue, _pageBreaksVisible);
	}

	/**
	 * @return the pageBreakColor
	 */
	public Color getPageBreakColor()
	{
		return _pageBreakColor;
	}

	/**
	 * @param pageBreakColor the pageBreakColor to set
	 */
	public void setPageBreakColor(Color pageBreakColor)
	{
		this._pageBreakColor = pageBreakColor;
	}

	/**
	 * @param value
	 *            the horizontalPageCount to set
	 */
	public void setHorizontalPageCount(int value)
	{
		int oldValue = _horizontalPageCount;
		_horizontalPageCount = value;

		firePropertyChange("horizontalPageCount", oldValue, _horizontalPageCount);
	}

	/**
	 * 
	 */
	public int getHorizontalPageCount()
	{
		return _horizontalPageCount;
	}

	/**
	 * @param value
	 *            the verticalPageCount to set
	 */
	public void setVerticalPageCount(int value)
	{
		int oldValue = _verticalPageCount;
		_verticalPageCount = value;

		firePropertyChange("verticalPageCount", oldValue, _verticalPageCount);
	}

	/**
	 * 
	 */
	public int getVerticalPageCount()
	{
		return _verticalPageCount;
	}

	/**
	 * @return the centerPage
	 */
	public boolean isCenterPage()
	{
		return _centerPage;
	}

	/**
	 * zoomAndCenter should be called if this is set to true.
	 * 
	 * @param value
	 *            the centerPage to set
	 */
	public void setCenterPage(boolean value)
	{
		boolean oldValue = _centerPage;
		_centerPage = value;

		firePropertyChange("centerPage", oldValue, _centerPage);
	}

	/**
	 * @return the pageBackgroundColor
	 */
	public Color getPageBackgroundColor()
	{
		return _pageBackgroundColor;
	}

	/**
	 * Sets the color that appears behind the page.
	 * 
	 * @param value
	 *            the pageBackgroundColor to set
	 */
	public void setPageBackgroundColor(Color value)
	{
		Color oldValue = _pageBackgroundColor;
		_pageBackgroundColor = value;

		firePropertyChange("pageBackgroundColor", oldValue, _pageBackgroundColor);
	}

	/**
	 * @return the pageShadowColor
	 */
	public Color getPageShadowColor()
	{
		return _pageShadowColor;
	}

	/**
	 * @param value
	 *            the pageShadowColor to set
	 */
	public void setPageShadowColor(Color value)
	{
		Color oldValue = _pageShadowColor;
		_pageShadowColor = value;

		firePropertyChange("pageShadowColor", oldValue, _pageShadowColor);
	}

	/**
	 * @return the pageShadowColor
	 */
	public Color getPageBorderColor()
	{
		return _pageBorderColor;
	}

	/**
	 * @param value
	 *            the pageBorderColor to set
	 */
	public void setPageBorderColor(Color value)
	{
		Color oldValue = _pageBorderColor;
		_pageBorderColor = value;

		firePropertyChange("pageBorderColor", oldValue, _pageBorderColor);
	}

	/**
	 * @return the keepSelectionVisibleOnZoom
	 */
	public boolean isKeepSelectionVisibleOnZoom()
	{
		return _keepSelectionVisibleOnZoom;
	}

	/**
	 * @param value
	 *            the keepSelectionVisibleOnZoom to set
	 */
	public void setKeepSelectionVisibleOnZoom(boolean value)
	{
		boolean oldValue = _keepSelectionVisibleOnZoom;
		_keepSelectionVisibleOnZoom = value;

		firePropertyChange("keepSelectionVisibleOnZoom", oldValue,
				_keepSelectionVisibleOnZoom);
	}

	/**
	 * @return the zoomFactor
	 */
	public double getZoomFactor()
	{
		return _zoomFactor;
	}

	/**
	 * @param value
	 *            the zoomFactor to set
	 */
	public void setZoomFactor(double value)
	{
		double oldValue = _zoomFactor;
		_zoomFactor = value;

		firePropertyChange("zoomFactor", oldValue, _zoomFactor);
	}

	/**
	 * @return the centerZoom
	 */
	public boolean isCenterZoom()
	{
		return _centerZoom;
	}

	/**
	 * @param value
	 *            the centerZoom to set
	 */
	public void setCenterZoom(boolean value)
	{
		boolean oldValue = _centerZoom;
		_centerZoom = value;

		firePropertyChange("centerZoom", oldValue, _centerZoom);
	}

	/**
	 * 
	 */
	public void setZoomPolicy(int value)
	{
		int oldValue = _zoomPolicy;
		_zoomPolicy = value;

		if (_zoomPolicy != ZOOM_POLICY_NONE)
		{
			zoom(_zoomPolicy == ZOOM_POLICY_PAGE, true);
		}

		firePropertyChange("zoomPolicy", oldValue, _zoomPolicy);
	}

	/**
	 * 
	 */
	public int getZoomPolicy()
	{
		return _zoomPolicy;
	}

	/**
	 * Callback to process an escape keystroke.
	 * 
	 * @param e
	 */
	public void escape(KeyEvent e)
	{
		if (_selectionCellsHandler != null)
		{
			_selectionCellsHandler.reset();
		}

		if (_connectionHandler != null)
		{
			_connectionHandler.reset();
		}

		if (_graphHandler != null)
		{
			_graphHandler.reset();
		}

		if (_cellEditor != null)
		{
			_cellEditor.stopEditing(true);
		}
	}

	/**
	 * Clones and inserts the given cells into the graph using the move method
	 * and returns the inserted cells. This shortcut is used if cells are
	 * inserted via datatransfer.
	 */
	public Object[] importCells(Object[] cells, double dx, double dy,
			Object target, Point location)
	{
		return _graph.moveCells(cells, dx, dy, true, target, location);
	}

	/**
	 * Refreshes the display and handles.
	 */
	public void refresh()
	{
		_graph.refresh();
		_selectionCellsHandler.refresh();
	}

	/**
	 * Returns an Point2d representing the given event in the unscaled,
	 * non-translated coordinate space and applies the grid.
	 */
	public Point2d getPointForEvent(MouseEvent e)
	{
		return getPointForEvent(e, true);
	}

	/**
	 * Returns an Point2d representing the given event in the unscaled,
	 * non-translated coordinate space and applies the grid.
	 */
	public Point2d getPointForEvent(MouseEvent e, boolean addOffset)
	{
		double s = _graph.getView().getScale();
		Point2d tr = _graph.getView().getTranslate();

		double off = (addOffset) ? _graph.getGridSize() / 2 : 0;
		double x = _graph.snap(e.getX() / s - tr.getX() - off);
		double y = _graph.snap(e.getY() / s - tr.getY() - off);

		return new Point2d(x, y);
	}

	/**
	 * 
	 */
	public void startEditing()
	{
		startEditingAtCell(null);
	}

	/**
	 * 
	 */
	public void startEditingAtCell(Object cell)
	{
		startEditingAtCell(cell, null);
	}

	/**
	 * 
	 */
	public void startEditingAtCell(Object cell, EventObject evt)
	{
		if (cell == null)
		{
			cell = _graph.getSelectionCell();

			if (cell != null && !_graph.isCellEditable(cell))
			{
				cell = null;
			}
		}

		if (cell != null)
		{
			_eventSource.fireEvent(new EventObj(Event.START_EDITING,
					"cell", cell, "event", evt));
			_cellEditor.startEditing(cell, evt);
		}
	}

	/**
	 * 
	 */
	public String getEditingValue(Object cell, EventObject trigger)
	{
		return _graph.convertValueToString(cell);
	}

	/**
	 * 
	 */
	public void stopEditing(boolean cancel)
	{
		_cellEditor.stopEditing(cancel);
	}

	/**
	 * Sets the label of the specified cell to the given value using
	 * Graph.cellLabelChanged and fires Event.LABEL_CHANGED while the
	 * transaction is in progress. Returns the cell whose label was changed.
	 * 
	 * @param cell
	 *            Cell whose label should be changed.
	 * @param value
	 *            New value of the label.
	 * @param evt
	 *            Optional event that triggered the change.
	 */
	public Object labelChanged(Object cell, Object value, EventObject evt)
	{
		IGraphModel model = _graph.getModel();

		model.beginUpdate();
		try
		{
			_graph.cellLabelChanged(cell, value, _graph.isAutoSizeCell(cell));
			_eventSource.fireEvent(new EventObj(Event.LABEL_CHANGED,
					"cell", cell, "value", value, "event", evt));
		}
		finally
		{
			model.endUpdate();
		}

		return cell;
	}

	/**
	 * Returns the (unscaled) preferred size for the current page format (scaled
	 * by pageScale).
	 */
	protected Dimension _getPreferredSizeForPage()
	{
		return new Dimension((int) Math.round(_pageFormat.getWidth() * _pageScale
				* _horizontalPageCount), (int) Math.round(_pageFormat.getHeight()
				* _pageScale * _verticalPageCount));
	}

	/**
	 * Returns the vertical border between the page and the control.
	 */
	public int getVerticalPageBorder()
	{
		return (int) Math.round(_pageFormat.getWidth() * _pageScale);
	}

	/**
	 * Returns the horizontal border between the page and the control.
	 */
	public int getHorizontalPageBorder()
	{
		return (int) Math.round(0.5 * _pageFormat.getHeight() * _pageScale);
	}

	/**
	 * Returns the scaled preferred size for the current graph.
	 */
	protected Dimension _getScaledPreferredSizeForGraph()
	{
		Rect bounds = _graph.getGraphBounds();
		int border = _graph.getBorder();

		return new Dimension(
				(int) Math.round(bounds.getX() + bounds.getWidth()) + border
						+ 1, (int) Math.round(bounds.getY()
						+ bounds.getHeight())
						+ border + 1);
	}

	/**
	 * Should be called by a hook inside GraphView/Graph
	 */
	protected Point2d _getPageTranslate(double scale)
	{
		Dimension d = _getPreferredSizeForPage();
		Dimension bd = new Dimension(d);

		if (!_preferPageSize)
		{
			bd.width += 2 * getHorizontalPageBorder();
			bd.height += 2 * getVerticalPageBorder();
		}

		double width = Math.max(bd.width, (getViewport().getWidth() - 8)
				/ scale);
		double height = Math.max(bd.height, (getViewport().getHeight() - 8)
				/ scale);

		double dx = Math.max(0, (width - d.width) / 2);
		double dy = Math.max(0, (height - d.height) / 2);

		return new Point2d(dx, dy);
	}

	/**
	 * Invoked after the component was resized to update the zoom if the zoom
	 * policy is not none and/or update the translation of the diagram if
	 * pageVisible and centerPage are true.
	 */
	public void zoomAndCenter()
	{
		if (_zoomPolicy != ZOOM_POLICY_NONE)
		{
			// Centers only on the initial zoom call
			zoom(_zoomPolicy == ZOOM_POLICY_PAGE, _centerOnResize
					|| _zoomPolicy == ZOOM_POLICY_PAGE);
			_centerOnResize = false;
		}
		else if (_pageVisible && _centerPage)
		{
			Point2d translate = _getPageTranslate(_graph.getView().getScale());
			_graph.getView().setTranslate(translate);
		}
		else
		{
			getGraphControl().updatePreferredSize();
		}
	}

	/**
	 * Zooms into the graph by zoomFactor.
	 */
	public void zoomIn()
	{
		zoom(_zoomFactor);
	}

	/**
	 * Function: zoomOut
	 * 
	 * Zooms out of the graph by <zoomFactor>.
	 */
	public void zoomOut()
	{
		zoom(1 / _zoomFactor);
	}

	/**
	 * 
	 */
	public void zoom(double factor)
	{
		GraphView view = _graph.getView();
		double newScale = (double) ((int) (view.getScale() * 100 * factor)) / 100;

		if (newScale != view.getScale() && newScale > 0.04)
		{
			Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(newScale)
					: new Point2d();
			_graph.getView().scaleAndTranslate(newScale, translate.getX(),
					translate.getY());

			if (_keepSelectionVisibleOnZoom && !_graph.isSelectionEmpty())
			{
				getGraphControl().scrollRectToVisible(
						view.getBoundingBox(_graph.getSelectionCells())
								.getRectangle());
			}
			else
			{
				_maintainScrollBar(true, factor, _centerZoom);
				_maintainScrollBar(false, factor, _centerZoom);
			}
		}
	}

	/**
	 * 
	 */
	public void zoomTo(final double newScale, final boolean center)
	{
		GraphView view = _graph.getView();
		final double scale = view.getScale();

		Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(newScale)
				: new Point2d();
		_graph.getView().scaleAndTranslate(newScale, translate.getX(),
				translate.getY());

		// Causes two repaints on the scrollpane, namely one for the scale
		// change with the new preferred size and one for the change of
		// the scrollbar position. The latter cannot be done immediately
		// because the scrollbar keeps the value <= max - extent, and if
		// max is changed the value change will trigger a syncScrollPane
		// WithViewport in BasicScrollPaneUI, which will update the value
		// for the previous maximum (ie. it must be invoked later).
		SwingUtilities.invokeLater(new Runnable()
		{
			public void run()
			{
				_maintainScrollBar(true, newScale / scale, center);
				_maintainScrollBar(false, newScale / scale, center);
			}
		});
	}

	/**
	 * Function: zoomActual
	 * 
	 * Resets the zoom and panning in the view.
	 */
	public void zoomActual()
	{
		Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(1)
				: new Point2d();
		_graph.getView()
				.scaleAndTranslate(1, translate.getX(), translate.getY());

		if (isPageVisible())
		{
			// Causes two repaints, see zoomTo for more details
			SwingUtilities.invokeLater(new Runnable()
			{
				public void run()
				{
					Dimension pageSize = _getPreferredSizeForPage();

					if (getViewport().getWidth() > pageSize.getWidth())
					{
						scrollToCenter(true);
					}
					else
					{
						JScrollBar scrollBar = getHorizontalScrollBar();

						if (scrollBar != null)
						{
							scrollBar.setValue((scrollBar.getMaximum() / 3) - 4);
						}
					}

					if (getViewport().getHeight() > pageSize.getHeight())
					{
						scrollToCenter(false);
					}
					else
					{
						JScrollBar scrollBar = getVerticalScrollBar();

						if (scrollBar != null)
						{
							scrollBar.setValue((scrollBar.getMaximum() / 4) - 4);
						}
					}
				}
			});
		}
	}

	/**
	 * 
	 */
	public void zoom(final boolean page, final boolean center)
	{
		if (_pageVisible && !_zooming)
		{
			_zooming = true;

			try
			{
				int off = (getPageShadowColor() != null) ? 8 : 0;
				
				// Adds some extra space for the shadow and border
				double width = getViewport().getWidth() - off;
				double height = getViewport().getHeight() - off;

				Dimension d = _getPreferredSizeForPage();
				double pageWidth = d.width;
				double pageHeight = d.height;

				double scaleX = width / pageWidth;
				double scaleY = (page) ? height / pageHeight : scaleX;

				// Rounds the new scale to 5% steps
				final double newScale = (double) ((int) (Math.min(scaleX,
						scaleY) * 20)) / 20;

				if (newScale > 0)
				{
					GraphView graphView = _graph.getView();
					final double scale = graphView.getScale();
					Point2d translate = (_centerPage) ? _getPageTranslate(newScale)
							: new Point2d();
					graphView.scaleAndTranslate(newScale, translate.getX(),
							translate.getY());

					// Causes two repaints, see zoomTo for more details
					final double factor = newScale / scale;

					SwingUtilities.invokeLater(new Runnable()
					{
						public void run()
						{
							if (center)
							{
								if (page)
								{
									scrollToCenter(true);
									scrollToCenter(false);
								}
								else
								{
									scrollToCenter(true);
									_maintainScrollBar(false, factor, false);
								}
							}
							else if (factor != 1)
							{
								_maintainScrollBar(true, factor, false);
								_maintainScrollBar(false, factor, false);
							}
						}
					});
				}
			}
			finally
			{
				_zooming = false;
			}
		}
	}

	/**
	 *
	 */
	protected void _maintainScrollBar(boolean horizontal, double factor,
			boolean center)
	{
		JScrollBar scrollBar = (horizontal) ? getHorizontalScrollBar()
				: getVerticalScrollBar();

		if (scrollBar != null)
		{
			BoundedRangeModel model = scrollBar.getModel();
			int newValue = (int) Math.round(model.getValue() * factor)
					+ (int) Math.round((center) ? (model.getExtent()
							* (factor - 1) / 2) : 0);
			model.setValue(newValue);
		}
	}

	/**
	 * 
	 */
	public void scrollToCenter(boolean horizontal)
	{
		JScrollBar scrollBar = (horizontal) ? getHorizontalScrollBar()
				: getVerticalScrollBar();

		if (scrollBar != null)
		{
			final BoundedRangeModel model = scrollBar.getModel();
			final int newValue = ((model.getMaximum()) / 2) - model.getExtent()
					/ 2;
			model.setValue(newValue);
		}
	}

	/**
	 * Scrolls the graph so that it shows the given cell.
	 * 
	 * @param cell
	 */
	public void scrollCellToVisible(Object cell)
	{
		scrollCellToVisible(cell, false);
	}

	/**
	 * Scrolls the graph so that it shows the given cell.
	 * 
	 * @param cell
	 */
	public void scrollCellToVisible(Object cell, boolean center)
	{
		CellState state = _graph.getView().getState(cell);

		if (state != null)
		{
			Rect bounds = state;

			if (center)
			{
				bounds = (Rect) bounds.clone();

				bounds.setX(bounds.getCenterX() - getWidth() / 2);
				bounds.setWidth(getWidth());
				bounds.setY(bounds.getCenterY() - getHeight() / 2);
				bounds.setHeight(getHeight());
			}

			getGraphControl().scrollRectToVisible(bounds.getRectangle());
		}
	}

	/**
	 * 
	 * @param x
	 * @param y
	 * @return Returns the cell at the given location.
	 */
	public Object getCellAt(int x, int y)
	{
		return getCellAt(x, y, true);
	}

	/**
	 * 
	 * @param x
	 * @param y
	 * @param hitSwimlaneContent
	 * @return Returns the cell at the given location.
	 */
	public Object getCellAt(int x, int y, boolean hitSwimlaneContent)
	{
		return getCellAt(x, y, hitSwimlaneContent, null);
	}

	/**
	 * Returns the bottom-most cell that intersects the given point (x, y) in
	 * the cell hierarchy starting at the given parent.
	 * 
	 * @param x
	 *            X-coordinate of the location to be checked.
	 * @param y
	 *            Y-coordinate of the location to be checked.
	 * @param parent
	 *            <Cell> that should be used as the root of the recursion.
	 *            Default is <defaultParent>.
	 * @return Returns the child at the given location.
	 */
	public Object getCellAt(int x, int y, boolean hitSwimlaneContent,
			Object parent)
	{
		if (parent == null)
		{
			parent = _graph.getDefaultParent();
		}

		if (parent != null)
		{
			Point previousTranslate = _canvas.getTranslate();
			double previousScale = _canvas.getScale();

			try
			{
				_canvas.setScale(_graph.getView().getScale());
				_canvas.setTranslate(0, 0);

				IGraphModel model = _graph.getModel();
				GraphView view = _graph.getView();

				Rectangle hit = new Rectangle(x, y, 1, 1);
				int childCount = model.getChildCount(parent);

				for (int i = childCount - 1; i >= 0; i--)
				{
					Object cell = model.getChildAt(parent, i);
					Object result = getCellAt(x, y, hitSwimlaneContent, cell);

					if (result != null)
					{
						return result;
					}
					else if (_graph.isCellVisible(cell))
					{
						CellState state = view.getState(cell);

						if (state != null
								&& _canvas.intersects(this, hit, state)
								&& (!_graph.isSwimlane(cell)
										|| hitSwimlaneContent || (_transparentSwimlaneContent && !_canvas
										.hitSwimlaneContent(this, state, x, y))))
						{
							return cell;
						}
					}
				}
			}
			finally
			{
				_canvas.setScale(previousScale);
				_canvas.setTranslate(previousTranslate.x, previousTranslate.y);
			}
		}

		return null;
	}

	/**
	 * 
	 */
	public void setSwimlaneSelectionEnabled(boolean value)
	{
		boolean oldValue = _swimlaneSelectionEnabled;
		_swimlaneSelectionEnabled = value;

		firePropertyChange("swimlaneSelectionEnabled", oldValue,
				_swimlaneSelectionEnabled);
	}

	/**
	 * 
	 */
	public boolean isSwimlaneSelectionEnabled()
	{
		return _swimlaneSelectionEnabled;
	}

	/**
	 * 
	 */
	public Object[] selectRegion(Rectangle rect, MouseEvent e)
	{
		Object[] cells = getCells(rect);

		if (cells.length > 0)
		{
			selectCellsForEvent(cells, e);
		}
		else if (!_graph.isSelectionEmpty() && !e.isConsumed())
		{
			_graph.clearSelection();
		}

		return cells;
	}

	/**
	 * Returns the cells inside the given rectangle.
	 * 
	 * @return Returns the cells inside the given rectangle.
	 */
	public Object[] getCells(Rectangle rect)
	{
		return getCells(rect, null);
	}

	/**
	 * Returns the children of the given parent that are contained in the given
	 * rectangle (x, y, width, height). The result is added to the optional
	 * result array, which is returned from the function. If no result array is
	 * specified then a new array is created and returned.
	 * 
	 * @return Returns the children inside the given rectangle.
	 */
	public Object[] getCells(Rectangle rect, Object parent)
	{
		Collection<Object> result = new ArrayList<Object>();

		if (rect.width > 0 || rect.height > 0)
		{
			if (parent == null)
			{
				parent = _graph.getDefaultParent();
			}

			if (parent != null)
			{
				Point previousTranslate = _canvas.getTranslate();
				double previousScale = _canvas.getScale();

				try
				{
					_canvas.setScale(_graph.getView().getScale());
					_canvas.setTranslate(0, 0);

					IGraphModel model = _graph.getModel();
					GraphView view = _graph.getView();

					int childCount = model.getChildCount(parent);

					for (int i = 0; i < childCount; i++)
					{
						Object cell = model.getChildAt(parent, i);
						CellState state = view.getState(cell);

						if (_graph.isCellVisible(cell) && state != null)
						{
							if (_canvas.contains(this, rect, state))
							{
								result.add(cell);
							}
							else
							{
								result.addAll(Arrays
										.asList(getCells(rect, cell)));
							}
						}
					}
				}
				finally
				{
					_canvas.setScale(previousScale);
					_canvas.setTranslate(previousTranslate.x,
							previousTranslate.y);
				}
			}
		}

		return result.toArray();
	}

	/**
	 * Selects the cells for the given event.
	 */
	public void selectCellsForEvent(Object[] cells, MouseEvent event)
	{
		if (isToggleEvent(event))
		{
			_graph.addSelectionCells(cells);
		}
		else
		{
			_graph.setSelectionCells(cells);
		}
	}

	/**
	 * Selects the cell for the given event.
	 */
	public void selectCellForEvent(Object cell, MouseEvent e)
	{
		boolean isSelected = _graph.isCellSelected(cell);

		if (isToggleEvent(e))
		{
			if (isSelected)
			{
				_graph.removeSelectionCell(cell);
			}
			else
			{
				_graph.addSelectionCell(cell);
			}
		}
		else if (!isSelected || _graph.getSelectionCount() != 1)
		{
			_graph.setSelectionCell(cell);
		}
	}

	/**
	 * Returns true if the absolute value of one of the given parameters is
	 * greater than the tolerance.
	 */
	public boolean isSignificant(double dx, double dy)
	{
		return Math.abs(dx) > _tolerance || Math.abs(dy) > _tolerance;
	}

	/**
	 * Returns the icon used to display the collapsed state of the specified
	 * cell state. This returns null for all edges.
	 */
	public ImageIcon getFoldingIcon(CellState state)
	{
		if (state != null && isFoldingEnabled()
				&& !getGraph().getModel().isEdge(state.getCell()))
		{
			Object cell = state.getCell();
			boolean tmp = _graph.isCellCollapsed(cell);

			if (_graph.isCellFoldable(cell, !tmp))
			{
				return (tmp) ? _collapsedIcon : _expandedIcon;
			}
		}

		return null;
	}

	/**
	 * 
	 */
	public Rectangle getFoldingIconBounds(CellState state, ImageIcon icon)
	{
		IGraphModel model = _graph.getModel();
		boolean isEdge = model.isEdge(state.getCell());
		double scale = getGraph().getView().getScale();

		int x = (int) Math.round(state.getX() + 4 * scale);
		int y = (int) Math.round(state.getY() + 4 * scale);
		int w = (int) Math.max(8, icon.getIconWidth() * scale);
		int h = (int) Math.max(8, icon.getIconHeight() * scale);

		if (isEdge)
		{
			Point2d pt = _graph.getView().getPoint(state);

			x = (int) pt.getX() - w / 2;
			y = (int) pt.getY() - h / 2;
		}

		return new Rectangle(x, y, w, h);
	}

	/**
	 *
	 */
	public boolean hitFoldingIcon(Object cell, int x, int y)
	{
		if (cell != null)
		{
			IGraphModel model = _graph.getModel();

			// Draws the collapse/expand icons
			boolean isEdge = model.isEdge(cell);

			if (_foldingEnabled && (model.isVertex(cell) || isEdge))
			{
				CellState state = _graph.getView().getState(cell);

				if (state != null)
				{
					ImageIcon icon = getFoldingIcon(state);

					if (icon != null)
					{
						return getFoldingIconBounds(state, icon).contains(x, y);
					}
				}
			}
		}

		return false;
	}

	/**
	 * 
	 * @param enabled
	 */
	public void setToolTips(boolean enabled)
	{
		if (enabled)
		{
			ToolTipManager.sharedInstance().registerComponent(_graphControl);
		}
		else
		{
			ToolTipManager.sharedInstance().unregisterComponent(_graphControl);
		}
	}

	/**
	 * 
	 */
	public boolean isConnectable()
	{
		return _connectionHandler.isEnabled();
	}

	/**
	 * @param connectable
	 */
	public void setConnectable(boolean connectable)
	{
		_connectionHandler.setEnabled(connectable);
	}

	/**
	 * 
	 */
	public boolean isPanning()
	{
		return _panningHandler.isEnabled();
	}

	/**
	 * @param enabled
	 */
	public void setPanning(boolean enabled)
	{
		_panningHandler.setEnabled(enabled);
	}

	/**
	 * @return the autoScroll
	 */
	public boolean isAutoScroll()
	{
		return _autoScroll;
	}

	/**
	 * @param value
	 *            the autoScroll to set
	 */
	public void setAutoScroll(boolean value)
	{
		_autoScroll = value;
	}

	/**
	 * @return the autoExtend
	 */
	public boolean isAutoExtend()
	{
		return _autoExtend;
	}

	/**
	 * @param value
	 *            the autoExtend to set
	 */
	public void setAutoExtend(boolean value)
	{
		_autoExtend = value;
	}

	/**
	 * @return the escapeEnabled
	 */
	public boolean isEscapeEnabled()
	{
		return _escapeEnabled;
	}

	/**
	 * @param value
	 *            the escapeEnabled to set
	 */
	public void setEscapeEnabled(boolean value)
	{
		boolean oldValue = _escapeEnabled;
		_escapeEnabled = value;

		firePropertyChange("escapeEnabled", oldValue, _escapeEnabled);
	}

	/**
	 * @return the escapeEnabled
	 */
	public boolean isInvokesStopCellEditing()
	{
		return _invokesStopCellEditing;
	}

	/**
	 * @param value
	 *            the invokesStopCellEditing to set
	 */
	public void setInvokesStopCellEditing(boolean value)
	{
		boolean oldValue = _invokesStopCellEditing;
		_invokesStopCellEditing = value;

		firePropertyChange("invokesStopCellEditing", oldValue,
				_invokesStopCellEditing);
	}

	/**
	 * @return the enterStopsCellEditing
	 */
	public boolean isEnterStopsCellEditing()
	{
		return _enterStopsCellEditing;
	}

	/**
	 * @param value
	 *            the enterStopsCellEditing to set
	 */
	public void setEnterStopsCellEditing(boolean value)
	{
		boolean oldValue = _enterStopsCellEditing;
		_enterStopsCellEditing = value;

		firePropertyChange("enterStopsCellEditing", oldValue,
				_enterStopsCellEditing);
	}

	/**
	 * @return the dragEnabled
	 */
	public boolean isDragEnabled()
	{
		return _dragEnabled;
	}

	/**
	 * @param value
	 *            the dragEnabled to set
	 */
	public void setDragEnabled(boolean value)
	{
		boolean oldValue = _dragEnabled;
		_dragEnabled = value;

		firePropertyChange("dragEnabled", oldValue, _dragEnabled);
	}

	/**
	 * @return the gridVisible
	 */
	public boolean isGridVisible()
	{
		return _gridVisible;
	}

	/**
	 * Fires a property change event for <code>gridVisible</code>.
	 * 
	 * @param value
	 *            the gridVisible to set
	 */
	public void setGridVisible(boolean value)
	{
		boolean oldValue = _gridVisible;
		_gridVisible = value;

		firePropertyChange("gridVisible", oldValue, _gridVisible);
	}

	/**
	 * @return the gridVisible
	 */
	public boolean isAntiAlias()
	{
		return _antiAlias;
	}

	/**
	 * Fires a property change event for <code>antiAlias</code>.
	 * 
	 * @param value
	 *            the antiAlias to set
	 */
	public void setAntiAlias(boolean value)
	{
		boolean oldValue = _antiAlias;
		_antiAlias = value;

		firePropertyChange("antiAlias", oldValue, _antiAlias);
	}

	/**
	 * @return the gridVisible
	 */
	public boolean isTextAntiAlias()
	{
		return _antiAlias;
	}

	/**
	 * Fires a property change event for <code>textAntiAlias</code>.
	 * 
	 * @param value
	 *            the textAntiAlias to set
	 */
	public void setTextAntiAlias(boolean value)
	{
		boolean oldValue = _textAntiAlias;
		_textAntiAlias = value;

		firePropertyChange("textAntiAlias", oldValue, _textAntiAlias);
	}

	/**
	 * 
	 */
	public float getPreviewAlpha()
	{
		return _previewAlpha;
	}

	/**
	 * 
	 */
	public void setPreviewAlpha(float value)
	{
		float oldValue = _previewAlpha;
		_previewAlpha = value;

		firePropertyChange("previewAlpha", oldValue, _previewAlpha);
	}

	/**
	 * @return the tripleBuffered
	 */
	public boolean isTripleBuffered()
	{
		return _tripleBuffered;
	}

	/**
	 * Hook for dynamic triple buffering condition.
	 */
	public boolean isForceTripleBuffered()
	{
		// LATER: Dynamic condition (cell density) to use triple
		// buffering for a large number of cells on a small rect
		return false;
	}

	/**
	 * @param value
	 *            the tripleBuffered to set
	 */
	public void setTripleBuffered(boolean value)
	{
		boolean oldValue = _tripleBuffered;
		_tripleBuffered = value;

		firePropertyChange("tripleBuffered", oldValue, _tripleBuffered);
	}

	/**
	 * @return the gridColor
	 */
	public Color getGridColor()
	{
		return _gridColor;
	}

	/**
	 * Fires a property change event for <code>gridColor</code>.
	 * 
	 * @param value
	 *            the gridColor to set
	 */
	public void setGridColor(Color value)
	{
		Color oldValue = _gridColor;
		_gridColor = value;

		firePropertyChange("gridColor", oldValue, _gridColor);
	}

	/**
	 * @return the gridStyle
	 */
	public int getGridStyle()
	{
		return _gridStyle;
	}

	/**
	 * Fires a property change event for <code>gridStyle</code>.
	 * 
	 * @param value
	 *            the gridStyle to set
	 */
	public void setGridStyle(int value)
	{
		int oldValue = _gridStyle;
		_gridStyle = value;

		firePropertyChange("gridStyle", oldValue, _gridStyle);
	}

	/**
	 * Returns importEnabled.
	 */
	public boolean isImportEnabled()
	{
		return _importEnabled;
	}

	/**
	 * Sets importEnabled.
	 */
	public void setImportEnabled(boolean value)
	{
		boolean oldValue = _importEnabled;
		_importEnabled = value;

		firePropertyChange("importEnabled", oldValue, _importEnabled);
	}

	/**
	 * Returns all cells which may be imported via datatransfer.
	 */
	public Object[] getImportableCells(Object[] cells)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return canImportCell(cell);
			}
		});
	}

	/**
	 * Returns true if the given cell can be imported via datatransfer. This
	 * returns importEnabled.
	 */
	public boolean canImportCell(Object cell)
	{
		return isImportEnabled();
	}

	/**
	 * @return the exportEnabled
	 */
	public boolean isExportEnabled()
	{
		return _exportEnabled;
	}

	/**
	 * @param value
	 *            the exportEnabled to set
	 */
	public void setExportEnabled(boolean value)
	{
		boolean oldValue = _exportEnabled;
		_exportEnabled = value;

		firePropertyChange("exportEnabled", oldValue, _exportEnabled);
	}

	/**
	 * Returns all cells which may be exported via datatransfer.
	 */
	public Object[] getExportableCells(Object[] cells)
	{
		return GraphModel.filterCells(cells, new Filter()
		{
			public boolean filter(Object cell)
			{
				return canExportCell(cell);
			}
		});
	}

	/**
	 * Returns true if the given cell can be exported via datatransfer.
	 */
	public boolean canExportCell(Object cell)
	{
		return isExportEnabled();
	}

	/**
	 * @return the foldingEnabled
	 */
	public boolean isFoldingEnabled()
	{
		return _foldingEnabled;
	}

	/**
	 * @param value
	 *            the foldingEnabled to set
	 */
	public void setFoldingEnabled(boolean value)
	{
		boolean oldValue = _foldingEnabled;
		_foldingEnabled = value;

		firePropertyChange("foldingEnabled", oldValue, _foldingEnabled);
	}

	/**
	 * 
	 */
	public boolean isEditEvent(MouseEvent e)
	{
		return (e != null) ? e.getClickCount() == 2 : false;
	}

	/**
	 * 
	 * @param event
	 * @return Returns true if the given event should toggle selected cells.
	 */
	public boolean isCloneEvent(MouseEvent event)
	{
		return (event != null) ? event.isControlDown() : false;
	}

	/**
	 * 
	 * @param event
	 * @return Returns true if the given event should toggle selected cells.
	 */
	public boolean isToggleEvent(MouseEvent event)
	{
		// NOTE: IsMetaDown always returns true for right-clicks on the Mac, so
		// toggle selection for left mouse buttons requires CMD key to be pressed,
		// but toggle for right mouse buttons requires CTRL to be pressed.
		return (event != null) ? ((Utils.IS_MAC) ? ((SwingUtilities
				.isLeftMouseButton(event) && event.isMetaDown()) || (SwingUtilities
				.isRightMouseButton(event) && event.isControlDown()))
				: event.isControlDown())
				: false;
	}

	/**
	 * 
	 * @param event
	 * @return Returns true if the given event allows the grid to be applied.
	 */
	public boolean isGridEnabledEvent(MouseEvent event)
	{
		return (event != null) ? !event.isAltDown() : false;
	}

	/**
	 * Note: This is not used during drag and drop operations due to limitations
	 * of the underlying API. To enable this for move operations set dragEnabled
	 * to false.
	 * 
	 * @param event
	 * @return Returns true if the given event is a panning event.
	 */
	public boolean isPanningEvent(MouseEvent event)
	{
		return (event != null) ? event.isShiftDown() && event.isControlDown()
				: false;
	}

	/**
	 * Note: This is not used during drag and drop operations due to limitations
	 * of the underlying API. To enable this for move operations set dragEnabled
	 * to false.
	 * 
	 * @param event
	 * @return Returns true if the given event is constrained.
	 */
	public boolean isConstrainedEvent(MouseEvent event)
	{
		return (event != null) ? event.isShiftDown() : false;
	}

	/**
	 * Note: This is not used during drag and drop operations due to limitations
	 * of the underlying API. To enable this for move operations set dragEnabled
	 * to false.
	 * 
	 * @param event
	 * @return Returns true if the given event is constrained.
	 */
	public boolean isForceMarqueeEvent(MouseEvent event)
	{
		return (event != null) ? event.isAltDown() : false;
	}

	/**
	 * 
	 */
	public Point2d snapScaledPoint(Point2d pt)
	{
		return snapScaledPoint(pt, 0, 0);
	}

	/**
	 * 
	 */
	public Point2d snapScaledPoint(Point2d pt, double dx, double dy)
	{
		if (pt != null)
		{
			double scale = _graph.getView().getScale();
			Point2d trans = _graph.getView().getTranslate();

			pt.setX((_graph.snap(pt.getX() / scale - trans.getX() + dx / scale) + trans
					.getX()) * scale - dx);
			pt.setY((_graph.snap(pt.getY() / scale - trans.getY() + dy / scale) + trans
					.getY()) * scale - dy);
		}

		return pt;
	}

	/**
	 * Prints the specified page on the specified graphics using
	 * <code>pageFormat</code> for the page format.
	 * 
	 * @param g
	 *            The graphics to paint the graph on.
	 * @param printFormat
	 *            The page format to use for printing.
	 * @param page
	 *            The page to print
	 * @return Returns {@link Printable#PAGE_EXISTS} or
	 *         {@link Printable#NO_SUCH_PAGE}.
	 */
	public int print(Graphics g, PageFormat printFormat, int page)
	{
		int result = NO_SUCH_PAGE;

		// Disables double-buffering before printing
		RepaintManager currentManager = RepaintManager
				.currentManager(GraphComponent.this);
		currentManager.setDoubleBufferingEnabled(false);

		// Gets the current state of the view
		GraphView view = _graph.getView();

		// Stores the old state of the view
		boolean eventsEnabled = view.isEventsEnabled();
		Point2d translate = view.getTranslate();

		// Disables firing of scale events so that there is no
		// repaint or update of the original graph while pages
		// are being printed
		view.setEventsEnabled(false);

		// Uses the view to create temporary cell states for each cell
		TemporaryCellStates tempStates = new TemporaryCellStates(view,
				1 / _pageScale);

		try
		{
			view.setTranslate(new Point2d(0, 0));

			Graphics2DCanvas canvas = createCanvas();
			canvas.setGraphics((Graphics2D) g);
			canvas.setScale(1 / _pageScale);

			view.revalidate();

			Rect graphBounds = _graph.getGraphBounds();
			Dimension pSize = new Dimension((int) Math.ceil(graphBounds.getX()
					+ graphBounds.getWidth()) + 1, (int) Math.ceil(graphBounds
					.getY() + graphBounds.getHeight()) + 1);

			int w = (int) (printFormat.getImageableWidth());
			int h = (int) (printFormat.getImageableHeight());
			int cols = (int) Math.max(
					Math.ceil((double) (pSize.width - 5) / (double) w), 1);
			int rows = (int) Math.max(
					Math.ceil((double) (pSize.height - 5) / (double) h), 1);

			if (page < cols * rows)
			{
				int dx = (int) ((page % cols) * printFormat.getImageableWidth());
				int dy = (int) (Math.floor(page / cols) * printFormat
						.getImageableHeight());

				g.translate(-dx + (int) printFormat.getImageableX(), -dy
						+ (int) printFormat.getImageableY());
				g.setClip(dx, dy, (int) (dx + printFormat.getWidth()),
						(int) (dy + printFormat.getHeight()));

				_graph.drawGraph(canvas);

				result = PAGE_EXISTS;
			}
		}
		finally
		{
			view.setTranslate(translate);

			tempStates.destroy();
			view.setEventsEnabled(eventsEnabled);

			// Enables double-buffering after printing
			currentManager.setDoubleBufferingEnabled(true);
		}

		return result;
	}

	/**
	 * 
	 */
	public InteractiveCanvas getCanvas()
	{
		return _canvas;
	}

	/**
	 * 
	 */
	public BufferedImage getTripleBuffer()
	{
		return _tripleBuffer;
	}

	/**
	 * Hook for subclassers to replace the graphics canvas for rendering and and
	 * printing. This must be overridden to return a custom canvas if there are
	 * any custom shapes.
	 */
	public InteractiveCanvas createCanvas()
	{
		// NOTE: http://forum.jgraph.com/questions/3354/ reports that we should not
		// pass image observer here as it will cause JVM to enter infinite loop.
		return new InteractiveCanvas();
	}

	/**
	 * 
	 * @param state
	 *            Cell state for which a handler should be created.
	 * @return Returns the handler to be used for the given cell state.
	 */
	public CellHandler createHandler(CellState state)
	{
		if (_graph.getModel().isVertex(state.getCell()))
		{
			return new VertexHandler(this, state);
		}
		else if (_graph.getModel().isEdge(state.getCell()))
		{
			EdgeStyleFunction style = _graph.getView().getEdgeStyle(state,
					null, null, null);

			if (_graph.isLoop(state) || style == EdgeStyle.ElbowConnector
					|| style == EdgeStyle.SideToSide
					|| style == EdgeStyle.TopToBottom)
			{
				return new ElbowEdgeHandler(this, state);
			}

			return new EdgeHandler(this, state);
		}

		return new CellHandler(this, state);
	}

	//
	// Heavyweights
	//

	/**
	 * Hook for subclassers to create the array of heavyweights for the given
	 * state.
	 */
	public Component[] createComponents(CellState state)
	{
		return null;
	}

	/**
	 * 
	 */
	public void insertComponent(CellState state, Component c)
	{
		getGraphControl().add(c, 0);
	}

	/**
	 * 
	 */
	public void removeComponent(Component c, Object cell)
	{
		if (c.getParent() != null)
		{
			c.getParent().remove(c);
		}
	}

	/**
	 * 
	 */
	public void updateComponent(CellState state, Component c)
	{
		int x = (int) state.getX();
		int y = (int) state.getY();
		int width = (int) state.getWidth();
		int height = (int) state.getHeight();

		Dimension s = c.getMinimumSize();

		if (s.width > width)
		{
			x -= (s.width - width) / 2;
			width = s.width;
		}

		if (s.height > height)
		{
			y -= (s.height - height) / 2;
			height = s.height;
		}

		c.setBounds(x, y, width, height);
	}

	/**
	 * 
	 */
	public void updateComponents()
	{
		Object root = _graph.getModel().getRoot();
		Hashtable<Object, Component[]> result = updateComponents(root);

		// Components now contains the mappings which are no
		// longer used, the result contains the new mappings
		removeAllComponents(_components);
		_components = result;

		if (!_overlays.isEmpty())
		{
			Hashtable<Object, ICellOverlay[]> result2 = updateCellOverlays(root);

			// Overlays now contains the mappings from cells which
			// are no longer in the model, the result contains the
			// mappings from cells which still exists, regardless
			// from whether a state exists for a particular cell
			removeAllOverlays(_overlays);
			_overlays = result2;
		}
	}

	/**
	 * 
	 */
	public void removeAllComponents(Hashtable<Object, Component[]> map)
	{
		Iterator<Map.Entry<Object, Component[]>> it = map.entrySet().iterator();

		while (it.hasNext())
		{
			Map.Entry<Object, Component[]> entry = it.next();
			Component[] c = entry.getValue();

			for (int i = 0; i < c.length; i++)
			{
				removeComponent(c[i], entry.getKey());
			}
		}
	}

	/**
	 * 
	 */
	public void removeAllOverlays(Hashtable<Object, ICellOverlay[]> map)
	{
		Iterator<Map.Entry<Object, ICellOverlay[]>> it = map.entrySet()
				.iterator();

		while (it.hasNext())
		{
			Map.Entry<Object, ICellOverlay[]> entry = it.next();
			ICellOverlay[] c = entry.getValue();

			for (int i = 0; i < c.length; i++)
			{
				_removeCellOverlayComponent(c[i], entry.getKey());
			}
		}
	}

	/**
	 * 
	 */
	public Hashtable<Object, Component[]> updateComponents(Object cell)
	{
		Hashtable<Object, Component[]> result = new Hashtable<Object, Component[]>();
		Component[] c = _components.remove(cell);
		CellState state = getGraph().getView().getState(cell);

		if (state != null)
		{
			if (c == null)
			{
				c = createComponents(state);

				if (c != null)
				{
					for (int i = 0; i < c.length; i++)
					{
						insertComponent(state, c[i]);
					}
				}
			}

			if (c != null)
			{
				result.put(cell, c);

				for (int i = 0; i < c.length; i++)
				{
					updateComponent(state, c[i]);
				}
			}
		}
		// Puts the component back into the map so that it will be removed
		else if (c != null)
		{
			_components.put(cell, c);
		}

		int childCount = getGraph().getModel().getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			result.putAll(updateComponents(getGraph().getModel().getChildAt(
					cell, i)));
		}

		return result;
	}

	//
	// Validation and overlays
	//

	/**
	 * Validates the graph by validating each descendant of the given cell or
	 * the root of the model. Context is an object that contains the validation
	 * state for the complete validation run. The validation errors are attached
	 * to their cells using <setWarning>. This function returns true if no
	 * validation errors exist in the graph.
	 */
	public String validateGraph()
	{
		return validateGraph(_graph.getModel().getRoot(),
				new Hashtable<Object, Object>());
	}

	/**
	 * Validates the graph by validating each descendant of the given cell or
	 * the root of the model. Context is an object that contains the validation
	 * state for the complete validation run. The validation errors are attached
	 * to their cells using <setWarning>. This function returns true if no
	 * validation errors exist in the graph.
	 * 
	 * @param cell
	 *            Cell to start the validation recursion.
	 * @param context
	 *            Object that represents the global validation state.
	 */
	public String validateGraph(Object cell, Hashtable<Object, Object> context)
	{
		IGraphModel model = _graph.getModel();
		GraphView view = _graph.getView();
		boolean isValid = true;
		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object tmp = model.getChildAt(cell, i);
			Hashtable<Object, Object> ctx = context;

			if (_graph.isValidRoot(tmp))
			{
				ctx = new Hashtable<Object, Object>();
			}

			String warn = validateGraph(tmp, ctx);

			if (warn != null)
			{
				String html = warn.replaceAll("\n", "<br>");
				int len = html.length();
				setCellWarning(tmp, html.substring(0, Math.max(0, len - 4)));
			}
			else
			{
				setCellWarning(tmp, null);
			}

			isValid = isValid && warn == null;
		}

		StringBuffer warning = new StringBuffer();

		// Adds error for invalid children if collapsed (children invisible)
		if (_graph.isCellCollapsed(cell) && !isValid)
		{
			warning.append(Resources.get("containsValidationErrors",
					"Contains Validation Errors") + "\n");
		}

		// Checks edges and cells using the defined multiplicities
		if (model.isEdge(cell))
		{
			String tmp = _graph.getEdgeValidationError(cell,
					model.getTerminal(cell, true),
					model.getTerminal(cell, false));

			if (tmp != null)
			{
				warning.append(tmp);
			}
		}
		else
		{
			String tmp = _graph.getCellValidationError(cell);

			if (tmp != null)
			{
				warning.append(tmp);
			}
		}

		// Checks custom validation rules
		String err = _graph.validateCell(cell, context);

		if (err != null)
		{
			warning.append(err);
		}

		// Updates the display with the warning icons before any potential
		// alerts are displayed
		if (model.getParent(cell) == null)
		{
			view.validate();
		}

		return (warning.length() > 0 || !isValid) ? warning.toString() : null;
	}

	/**
	 * Adds an overlay for the specified cell. This method fires an addoverlay
	 * event and returns the new overlay.
	 * 
	 * @param cell
	 *            Cell to add the overlay for.
	 * @param overlay
	 *            Overlay to be added for the cell.
	 */
	public ICellOverlay addCellOverlay(Object cell, ICellOverlay overlay)
	{
		ICellOverlay[] arr = getCellOverlays(cell);

		if (arr == null)
		{
			arr = new ICellOverlay[] { overlay };
		}
		else
		{
			ICellOverlay[] arr2 = new ICellOverlay[arr.length + 1];
			System.arraycopy(arr, 0, arr2, 0, arr.length);
			arr2[arr.length] = overlay;
			arr = arr2;
		}

		_overlays.put(cell, arr);
		CellState state = _graph.getView().getState(cell);

		if (state != null)
		{
			_updateCellOverlayComponent(state, overlay);
		}

		_eventSource.fireEvent(new EventObj(Event.ADD_OVERLAY, "cell",
				cell, "overlay", overlay));

		return overlay;
	}

	/**
	 * Returns the array of overlays for the given cell or null, if no overlays
	 * are defined.
	 * 
	 * @param cell
	 *            Cell whose overlays should be returned.
	 */
	public ICellOverlay[] getCellOverlays(Object cell)
	{
		return _overlays.get(cell);
	}

	/**
	 * Removes and returns the given overlay from the given cell. This method
	 * fires a remove overlay event. If no overlay is given, then all overlays
	 * are removed using removeOverlays.
	 * 
	 * @param cell
	 *            Cell whose overlay should be removed.
	 * @param overlay
	 *            Optional overlay to be removed.
	 */
	public ICellOverlay removeCellOverlay(Object cell, ICellOverlay overlay)
	{
		if (overlay == null)
		{
			removeCellOverlays(cell);
		}
		else
		{
			ICellOverlay[] arr = getCellOverlays(cell);

			if (arr != null)
			{
				// TODO: Use arraycopy from/to same array to speed this up
				List<ICellOverlay> list = new ArrayList<ICellOverlay>(
						Arrays.asList(arr));

				if (list.remove(overlay))
				{
					_removeCellOverlayComponent(overlay, cell);
				}

				arr = list.toArray(new ICellOverlay[list.size()]);
				_overlays.put(cell, arr);
			}
		}

		return overlay;
	}

	/**
	 * Removes all overlays from the given cell. This method fires a
	 * removeoverlay event for each removed overlay and returns the array of
	 * overlays that was removed from the cell.
	 * 
	 * @param cell
	 *            Cell whose overlays should be removed.
	 */
	public ICellOverlay[] removeCellOverlays(Object cell)
	{
		ICellOverlay[] ovls = _overlays.remove(cell);

		if (ovls != null)
		{
			// Removes the overlays from the cell hierarchy
			for (int i = 0; i < ovls.length; i++)
			{
				_removeCellOverlayComponent(ovls[i], cell);
			}
		}

		return ovls;
	}

	/**
	 * Notified when an overlay has been removed from the graph. This
	 * implementation removes the given overlay from its parent if it is a
	 * component inside a component hierarchy.
	 */
	protected void _removeCellOverlayComponent(ICellOverlay overlay,
			Object cell)
	{
		if (overlay instanceof Component)
		{
			Component comp = (Component) overlay;

			if (comp.getParent() != null)
			{
				comp.setVisible(false);
				comp.getParent().remove(comp);
				_eventSource.fireEvent(new EventObj(Event.REMOVE_OVERLAY,
						"cell", cell, "overlay", overlay));
			}
		}
	}

	/**
	 * Notified when an overlay has been removed from the graph. This
	 * implementation removes the given overlay from its parent if it is a
	 * component inside a component hierarchy.
	 */
	protected void _updateCellOverlayComponent(CellState state,
			ICellOverlay overlay)
	{
		if (overlay instanceof Component)
		{
			Component comp = (Component) overlay;

			if (comp.getParent() == null)
			{
				getGraphControl().add(comp, 0);
			}

			Rect rect = overlay.getBounds(state);

			if (rect != null)
			{
				comp.setBounds(rect.getRectangle());
				comp.setVisible(true);
			}
			else
			{
				comp.setVisible(false);
			}
		}
	}

	/**
	 * Removes all overlays in the graph.
	 */
	public void clearCellOverlays()
	{
		clearCellOverlays(null);
	}

	/**
	 * Removes all overlays in the graph for the given cell and all its
	 * descendants. If no cell is specified then all overlays are removed from
	 * the graph. This implementation uses removeOverlays to remove the overlays
	 * from the individual cells.
	 * 
	 * @param cell
	 *            Optional cell that represents the root of the subtree to
	 *            remove the overlays from. Default is the root in the model.
	 */
	public void clearCellOverlays(Object cell)
	{
		IGraphModel model = _graph.getModel();

		if (cell == null)
		{
			cell = model.getRoot();
		}

		removeCellOverlays(cell);

		// Recursively removes all overlays from the children
		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(cell, i);
			clearCellOverlays(child); // recurse
		}
	}

	/**
	 * Creates an overlay for the given cell using the warning and image or
	 * warningImage and returns the new overlay. If the warning is null or a
	 * zero length string, then all overlays are removed from the cell instead.
	 * 
	 * @param cell
	 *            Cell whose warning should be set.
	 * @param warning
	 *            String that represents the warning to be displayed.
	 */
	public ICellOverlay setCellWarning(Object cell, String warning)
	{
		return setCellWarning(cell, warning, null, false);
	}

	/**
	 * Creates an overlay for the given cell using the warning and image or
	 * warningImage and returns the new overlay. If the warning is null or a
	 * zero length string, then all overlays are removed from the cell instead.
	 * 
	 * @param cell
	 *            Cell whose warning should be set.
	 * @param warning
	 *            String that represents the warning to be displayed.
	 * @param icon
	 *            Optional image to be used for the overlay. Default is
	 *            warningImageBasename.
	 */
	public ICellOverlay setCellWarning(Object cell, String warning,
			ImageIcon icon)
	{
		return setCellWarning(cell, warning, icon, false);
	}

	/**
	 * Creates an overlay for the given cell using the warning and image or
	 * warningImage and returns the new overlay. If the warning is null or a
	 * zero length string, then all overlays are removed from the cell instead.
	 * 
	 * @param cell
	 *            Cell whose warning should be set.
	 * @param warning
	 *            String that represents the warning to be displayed.
	 * @param icon
	 *            Optional image to be used for the overlay. Default is
	 *            warningImageBasename.
	 * @param select
	 *            Optional boolean indicating if a click on the overlay should
	 *            select the corresponding cell. Default is false.
	 */
	public ICellOverlay setCellWarning(final Object cell, String warning,
			ImageIcon icon, boolean select)
	{
		if (warning != null && warning.length() > 0)
		{
			icon = (icon != null) ? icon : _warningIcon;

			// Creates the overlay with the image and warning
			CellOverlay overlay = new CellOverlay(icon, warning);

			// Adds a handler for single mouseclicks to select the cell
			if (select)
			{
				overlay.addMouseListener(new MouseAdapter()
				{
					/**
					 * Selects the associated cell in the graph
					 */
					public void mousePressed(MouseEvent e)
					{
						if (getGraph().isEnabled())
						{
							getGraph().setSelectionCell(cell);
						}
					}
				});

				overlay.setCursor(new Cursor(Cursor.HAND_CURSOR));
			}

			// Sets and returns the overlay in the graph
			return addCellOverlay(cell, overlay);
		}
		else
		{
			removeCellOverlays(cell);
		}

		return null;
	}

	/**
	 * Returns a hashtable with all entries from the overlays variable where a
	 * cell still exists in the model. The entries are removed from the global
	 * hashtable so that the remaining entries reflect those whose cell have
	 * been removed from the model. If no state is available for a given cell
	 * then its overlays are temporarly removed from the rendering control, but
	 * kept in the result.
	 */
	public Hashtable<Object, ICellOverlay[]> updateCellOverlays(Object cell)
	{
		Hashtable<Object, ICellOverlay[]> result = new Hashtable<Object, ICellOverlay[]>();
		ICellOverlay[] c = _overlays.remove(cell);
		CellState state = getGraph().getView().getState(cell);

		if (c != null)
		{
			if (state != null)
			{
				for (int i = 0; i < c.length; i++)
				{
					_updateCellOverlayComponent(state, c[i]);
				}
			}
			else
			{
				for (int i = 0; i < c.length; i++)
				{
					_removeCellOverlayComponent(c[i], cell);
				}
			}

			result.put(cell, c);
		}

		int childCount = getGraph().getModel().getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			result.putAll(updateCellOverlays(getGraph().getModel().getChildAt(
					cell, i)));
		}

		return result;
	}

	/**
	 * 
	 */
	protected void _paintBackground(Graphics g)
	{
		Rectangle clip = g.getClipBounds();
		Rectangle rect = _paintBackgroundPage(g);

		if (isPageVisible())
		{
			g.clipRect(rect.x + 1, rect.y + 1, rect.width - 1, rect.height - 1);
		}

		// Paints the clipped background image
		_paintBackgroundImage(g);

		// Paints the grid directly onto the graphics
		_paintGrid(g);
		g.setClip(clip);
	}

	/**
	 * 
	 */
	protected Rectangle _paintBackgroundPage(Graphics g)
	{
		Point2d translate = _graph.getView().getTranslate();
		double scale = _graph.getView().getScale();

		int x0 = (int) Math.round(translate.getX() * scale) - 1;
		int y0 = (int) Math.round(translate.getY() * scale) - 1;

		Dimension d = _getPreferredSizeForPage();
		int w = (int) Math.round(d.width * scale) + 2;
		int h = (int) Math.round(d.height * scale) + 2;

		if (isPageVisible())
		{
			// Draws the background behind the page
			Color c = getPageBackgroundColor();
			
			if (c != null)
			{
				g.setColor(c);
				Utils.fillClippedRect(g, 0, 0, getGraphControl().getWidth(),
						getGraphControl().getHeight());
			}

			// Draws the page drop shadow
			c = getPageShadowColor();
			
			if (c != null)
			{
				g.setColor(c);
				Utils.fillClippedRect(g, x0 + w, y0 + 6, 6, h - 6);
				Utils.fillClippedRect(g, x0 + 8, y0 + h, w - 2, 6);
			}

			// Draws the page
			Color bg = getBackground();

			if (getViewport().isOpaque())
			{
				bg = getViewport().getBackground();
			}

			g.setColor(bg);
			Utils.fillClippedRect(g, x0 + 1, y0 + 1, w, h);

			// Draws the page border
			c = getPageBorderColor();
			
			if (c != null)
			{
				g.setColor(c);
				g.drawRect(x0, y0, w, h);
			}
		}

		if (isPageBreaksVisible()
				&& (_horizontalPageCount > 1 || _verticalPageCount > 1))
		{
			// Draws the pagebreaks
			// TODO: Use clipping
			Graphics2D g2 = (Graphics2D) g;
			Stroke previousStroke = g2.getStroke();

			g2.setStroke(new BasicStroke(1, BasicStroke.CAP_BUTT,
					BasicStroke.JOIN_MITER, 10.0f, new float[] { 1, 2 }, 0));
			g2.setColor(_pageBreakColor);

			for (int i = 1; i <= _horizontalPageCount - 1; i++)
			{
				int dx = i * w / _horizontalPageCount;
				g2.drawLine(x0 + dx, y0 + 1, x0 + dx, y0 + h);
			}

			for (int i = 1; i <= _verticalPageCount - 1; i++)
			{
				int dy = i * h / _verticalPageCount;
				g2.drawLine(x0 + 1, y0 + dy, x0 + w, y0 + dy);
			}

			// Restores the graphics
			g2.setStroke(previousStroke);
		}

		return new Rectangle(x0, y0, w, h);
	}

	/**
	 * 
	 */
	protected void _paintBackgroundImage(Graphics g)
	{
		if (_backgroundImage != null)
		{
			Point2d translate = _graph.getView().getTranslate();
			double scale = _graph.getView().getScale();

			g.drawImage(_backgroundImage.getImage(),
					(int) (translate.getX() * scale),
					(int) (translate.getY() * scale),
					(int) (_backgroundImage.getIconWidth() * scale),
					(int) (_backgroundImage.getIconHeight() * scale), this);
		}
	}

	/**
	 * Paints the grid onto the given graphics object.
	 */
	protected void _paintGrid(Graphics g)
	{
		if (isGridVisible())
		{
			g.setColor(getGridColor());
			Rectangle clip = g.getClipBounds();

			if (clip == null)
			{
				clip = getGraphControl().getBounds();
			}

			double left = clip.getX();
			double top = clip.getY();
			double right = left + clip.getWidth();
			double bottom = top + clip.getHeight();

			// Double the grid line spacing if smaller than half the gridsize
			int style = getGridStyle();
			int gridSize = _graph.getGridSize();
			int minStepping = gridSize;

			// Smaller stepping for certain styles
			if (style == GRID_STYLE_CROSS || style == GRID_STYLE_DOT)
			{
				minStepping /= 2;
			}

			// Fetches some global display state information
			Point2d trans = _graph.getView().getTranslate();
			double scale = _graph.getView().getScale();
			double tx = trans.getX() * scale;
			double ty = trans.getY() * scale;

			// Sets the distance of the grid lines in pixels
			double stepping = gridSize * scale;

			if (stepping < minStepping)
			{
				int count = (int) Math
						.round(Math.ceil(minStepping / stepping) / 2) * 2;
				stepping = count * stepping;
			}

			double xs = Math.floor((left - tx) / stepping) * stepping + tx;
			double xe = Math.ceil(right / stepping) * stepping;
			double ys = Math.floor((top - ty) / stepping) * stepping + ty;
			double ye = Math.ceil(bottom / stepping) * stepping;

			switch (style)
			{
				case GRID_STYLE_CROSS:
				{
					// Sets the dot size
					int cs = (stepping > 16.0) ? 2 : 1;

					for (double x = xs; x <= xe; x += stepping)
					{
						for (double y = ys; y <= ye; y += stepping)
						{
							// FIXME: Workaround for rounding errors when adding
							// stepping to
							// xs or ys multiple times (leads to double grid lines
							// when zoom
							// is set to eg. 121%)
							x = Math.round((x - tx) / stepping) * stepping + tx;
							y = Math.round((y - ty) / stepping) * stepping + ty;

							int ix = (int) Math.round(x);
							int iy = (int) Math.round(y);
							g.drawLine(ix - cs, iy, ix + cs, iy);
							g.drawLine(ix, iy - cs, ix, iy + cs);
						}
					}

					break;
				}
				case GRID_STYLE_LINE:
				{
					xe += (int) Math.ceil(stepping);
					ye += (int) Math.ceil(stepping);

					int ixs = (int) Math.round(xs);
					int ixe = (int) Math.round(xe);
					int iys = (int) Math.round(ys);
					int iye = (int) Math.round(ye);

					for (double x = xs; x <= xe; x += stepping)
					{
						// FIXME: Workaround for rounding errors when adding
						// stepping to
						// xs or ys multiple times (leads to double grid lines when
						// zoom
						// is set to eg. 121%)
						x = Math.round((x - tx) / stepping) * stepping + tx;

						int ix = (int) Math.round(x);
						g.drawLine(ix, iys, ix, iye);
					}

					for (double y = ys; y <= ye; y += stepping)
					{

						// FIXME: Workaround for rounding errors when adding
						// stepping to
						// xs or ys multiple times (leads to double grid lines when
						// zoom
						// is set to eg. 121%)
						y = Math.round((y - ty) / stepping) * stepping + ty;

						int iy = (int) Math.round(y);
						g.drawLine(ixs, iy, ixe, iy);
					}

					break;
				}
				case GRID_STYLE_DASHED:
				{
					Graphics2D g2 = (Graphics2D) g;
					Stroke stroke = g2.getStroke();

					xe += (int) Math.ceil(stepping);
					ye += (int) Math.ceil(stepping);

					int ixs = (int) Math.round(xs);
					int ixe = (int) Math.round(xe);
					int iys = (int) Math.round(ys);
					int iye = (int) Math.round(ye);

					// Creates a set of strokes with individual dash offsets
					// for each direction
					Stroke[] strokes = new Stroke[] {
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 3,
											1 }, Math.max(0, iys) % 4),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 2,
											2 }, Math.max(0, iys) % 4),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 1,
											1 }, 0),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 2,
											2 }, Math.max(0, iys) % 4) };

					for (double x = xs; x <= xe; x += stepping)
					{
						g2.setStroke(strokes[((int) (x / stepping))
								% strokes.length]);

						// FIXME: Workaround for rounding errors when adding
						// stepping to
						// xs or ys multiple times (leads to double grid lines when
						// zoom
						// is set to eg. 121%)
						double xx = Math.round((x - tx) / stepping) * stepping
								+ tx;

						int ix = (int) Math.round(xx);
						g.drawLine(ix, iys, ix, iye);
					}

					strokes = new Stroke[] {
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 3,
											1 }, Math.max(0, ixs) % 4),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 2,
											2 }, Math.max(0, ixs) % 4),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 1,
											1 }, 0),
							new BasicStroke(1, BasicStroke.CAP_BUTT,
									BasicStroke.JOIN_MITER, 1, new float[] { 2,
											2 }, Math.max(0, ixs) % 4) };

					for (double y = ys; y <= ye; y += stepping)
					{
						g2.setStroke(strokes[((int) (y / stepping))
								% strokes.length]);

						// FIXME: Workaround for rounding errors when adding
						// stepping to
						// xs or ys multiple times (leads to double grid lines when
						// zoom
						// is set to eg. 121%)
						double yy = Math.round((y - ty) / stepping) * stepping
								+ ty;

						int iy = (int) Math.round(yy);
						g.drawLine(ixs, iy, ixe, iy);
					}

					g2.setStroke(stroke);

					break;
				}
				default: // DOT_GRID_MODE
				{
					for (double x = xs; x <= xe; x += stepping)
					{

						for (double y = ys; y <= ye; y += stepping)
						{
							// FIXME: Workaround for rounding errors when adding
							// stepping to
							// xs or ys multiple times (leads to double grid lines
							// when zoom
							// is set to eg. 121%)
							x = Math.round((x - tx) / stepping) * stepping + tx;
							y = Math.round((y - ty) / stepping) * stepping + ty;

							int ix = (int) Math.round(x);
							int iy = (int) Math.round(y);
							g.drawLine(ix, iy, ix, iy);
						}
					}
				}
			}
		}
	}

	//
	// Triple Buffering
	//

	/**
	 * Updates the buffer (if one exists) and repaints the given cell state.
	 */
	public void redraw(CellState state)
	{
		if (state != null)
		{
			Rectangle dirty = state.getBoundingBox().getRectangle();
			repaintTripleBuffer(new Rectangle(dirty));
			dirty = SwingUtilities.convertRectangle(_graphControl, dirty, this);
			repaint(dirty);
		}
	}

	/**
	 * Checks if the triple buffer exists and creates a new one if it does not.
	 * Also compares the size of the buffer with the size of the graph and drops
	 * the buffer if it has a different size.
	 */
	public void checkTripleBuffer()
	{
		Rect bounds = _graph.getGraphBounds();
		int width = (int) Math.ceil(bounds.getX() + bounds.getWidth() + 2);
		int height = (int) Math.ceil(bounds.getY() + bounds.getHeight() + 2);

		if (_tripleBuffer != null)
		{
			if (_tripleBuffer.getWidth() != width
					|| _tripleBuffer.getHeight() != height)
			{
				// Resizes the buffer (destroys existing and creates new)
				destroyTripleBuffer();
			}
		}

		if (_tripleBuffer == null)
		{
			_createTripleBuffer(width, height);
		}
	}

	/**
	 * Creates the tripleBufferGraphics and tripleBuffer for the given dimension
	 * and draws the complete graph onto the triplebuffer.
	 * 
	 * @param width
	 * @param height
	 */
	protected void _createTripleBuffer(int width, int height)
	{
		try
		{
			_tripleBuffer = Utils.createBufferedImage(width, height, null);
			_tripleBufferGraphics = _tripleBuffer.createGraphics();
			Utils.setAntiAlias(_tripleBufferGraphics, _antiAlias, _textAntiAlias);

			// Repaints the complete buffer
			repaintTripleBuffer(null);
		}
		catch (OutOfMemoryError error)
		{
			// ignore
		}
	}

	/**
	 * Destroys the tripleBuffer and tripleBufferGraphics objects.
	 */
	public void destroyTripleBuffer()
	{
		if (_tripleBuffer != null)
		{
			_tripleBuffer = null;
			_tripleBufferGraphics.dispose();
			_tripleBufferGraphics = null;
		}
	}

	/**
	 * Clears and repaints the triple buffer at the given rectangle or repaints
	 * the complete buffer if no rectangle is specified.
	 * 
	 * @param dirty
	 */
	public void repaintTripleBuffer(Rectangle dirty)
	{
		if (_tripleBuffered && _tripleBufferGraphics != null)
		{
			if (dirty == null)
			{
				dirty = new Rectangle(_tripleBuffer.getWidth(),
						_tripleBuffer.getHeight());
			}

			// Clears and repaints the dirty rectangle using the
			// graphics canvas as a renderer
			Utils.clearRect(_tripleBufferGraphics, dirty, null);
			_tripleBufferGraphics.setClip(dirty);
			_graphControl.drawGraph(_tripleBufferGraphics, true);
			_tripleBufferGraphics.setClip(null);
		}
	}

	//
	// Redirected to event source
	//

	/**
	 * @return Returns true if event dispatching is enabled in the event source.
	 * @see graph.util.EventSource#isEventsEnabled()
	 */
	public boolean isEventsEnabled()
	{
		return _eventSource.isEventsEnabled();
	}

	/**
	 * @param eventsEnabled
	 * @see graph.util.EventSource#setEventsEnabled(boolean)
	 */
	public void setEventsEnabled(boolean eventsEnabled)
	{
		_eventSource.setEventsEnabled(eventsEnabled);
	}

	/**
	 * @param eventName
	 * @param listener
	 * @see graph.util.EventSource#addListener(java.lang.String,
	 *      graph.util.EventSource.IEventListener)
	 */
	public void addListener(String eventName, IEventListener listener)
	{
		_eventSource.addListener(eventName, listener);
	}

	/**
	 * @param listener
	 *            Listener instance.
	 */
	public void removeListener(IEventListener listener)
	{
		_eventSource.removeListener(listener);
	}

	/**
	 * @param eventName
	 *            Name of the event.
	 * @param listener
	 *            Listener instance.
	 */
	public void removeListener(IEventListener listener, String eventName)
	{
		_eventSource.removeListener(listener, eventName);
	}

}