/**
 * Copyright (c) 2009-2010, Gaudenz Alder, David Benson
 */
part of graph.swing;

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
class GraphComponent extends JScrollPane implements Printable {

  /**
	 * 
	 */
  //	static final long serialVersionUID = -30203858391633447L;

  /**
	 * 
	 */
  static final int GRID_STYLE_DOT = 0;

  /**
	 * 
	 */
  static final int GRID_STYLE_CROSS = 1;

  /**
	 * 
	 */
  static final int GRID_STYLE_LINE = 2;

  /**
	 * 
	 */
  static final int GRID_STYLE_DASHED = 3;

  /**
	 * 
	 */
  static final int ZOOM_POLICY_NONE = 0;

  /**
	 * 
	 */
  static final int ZOOM_POLICY_PAGE = 1;

  /**
	 * 
	 */
  static final int ZOOM_POLICY_WIDTH = 2;

  /**
	 * 
	 */
  static ImageIcon DEFAULT_EXPANDED_ICON = null;

  /**
	 * 
	 */
  static ImageIcon DEFAULT_COLLAPSED_ICON = null;

  /**
	 * 
	 */
  static ImageIcon DEFAULT_WARNING_ICON = null;

  /**
	 * Specifies the default page scale. Default is 1.4
	 */
  static final double DEFAULT_PAGESCALE = 1.4;

  /**
	 * Loads the collapse and expand icons.
	 */
  static init() {
    DEFAULT_EXPANDED_ICON = new ImageIcon(GraphComponent//.class
    .getResource("/com/mxgraph/swing/images/expanded.gif"));
    DEFAULT_COLLAPSED_ICON = new ImageIcon(GraphComponent//.class
    .getResource("/com/mxgraph/swing/images/collapsed.gif"));
    DEFAULT_WARNING_ICON = new ImageIcon(GraphComponent//.class
    .getResource("/com/mxgraph/swing/images/warning.gif"));
  }

  /**
	 * 
	 */
  Graph _graph;

  /**
	 * 
	 */
  GraphControl _graphControl;

  /**
	 * 
	 */
  EventSource _eventSource = new EventSource(this);

  /**
	 * 
	 */
  ICellEditor _cellEditor;

  /**
	 * 
	 */
  ConnectionHandler _connectionHandler;

  /**
	 * 
	 */
  PanningHandler _panningHandler;

  /**
	 * 
	 */
  SelectionCellsHandler _selectionCellsHandler;

  /**
	 * 
	 */
  GraphHandler _graphHandler;

  /**
	 * The transparency of previewed cells from 0.0. to 0.1. 0.0 indicates
	 * transparent, 1.0 indicates opaque. Default is 1.
	 */
  float _previewAlpha = 0.5;

  /**
	 * Specifies the <Image> to be returned by <getBackgroundImage>. Default
	 * is null.
	 */
  ImageIcon _backgroundImage;

  /**
	 * Background page format.
	 */
  PageFormat _pageFormat = new PageFormat();

  /**
	 * 
	 */
  InteractiveCanvas _canvas;

  /**
	 * 
	 */
  BufferedImage _tripleBuffer;

  /**
	 * 
	 */
  Graphics2D _tripleBufferGraphics;

  /**
	 * Defines the scaling for the background page metrics. Default is
	 * {@link #DEFAULT_PAGESCALE}.
	 */
  double _pageScale = DEFAULT_PAGESCALE;

  /**
	 * Specifies if the background page should be visible. Default is false.
	 */
  bool _pageVisible = false;

  /**
	 * If the pageFormat should be used to determine the minimal graph bounds
	 * even if the page is not visible (see pageVisible). Default is false.
	 */
  bool _preferPageSize = false;

  /**
	 * Specifies if a dashed line should be drawn between multiple pages.
	 */
  bool _pageBreaksVisible = true;

  /**
	 * Specifies the color of page breaks
	 */
  Color _pageBreakColor = Color.darkGray;

  /**
	 * Specifies the number of pages in the horizontal direction.
	 */
  int _horizontalPageCount = 1;

  /**
	 * Specifies the number of pages in the vertical direction.
	 */
  int _verticalPageCount = 1;

  /**
	 * Specifies if the background page should be centered by automatically
	 * setting the translate in the view. Default is true. This does only apply
	 * if pageVisible is true.
	 */
  bool _centerPage = true;

  /**
	 * Color of the background area if layout view.
	 */
  Color _pageBackgroundColor = new Color(144, 153, 174);

  /**
	 * 
	 */
  Color _pageShadowColor = new Color(110, 120, 140);

  /**
	 * 
	 */
  Color _pageBorderColor = Color.black;

  /**
	 * Specifies if the grid is visible. Default is false.
	 */
  bool _gridVisible = false;

  /**
	 * 
	 */
  Color _gridColor = new Color(192, 192, 192);

  /**
	 * Whether or not to scroll the scrollable container the graph exists in if
	 * a suitable handler is active and the graph bounds already exist extended
	 * in the direction of mouse travel.
	 */
  bool _autoScroll = true;

  /**
	 * Whether to extend the graph bounds and scroll towards the limit of those
	 * new bounds in the direction of mouse travel if a handler is active while
	 * the mouse leaves the container that the graph exists in.
	 */
  bool _autoExtend = true;

  /**
	 * 
	 */
  bool _dragEnabled = true;

  /**
	 * 
	 */
  bool _importEnabled = true;

  /**
	 * 
	 */
  bool _exportEnabled = true;

  /**
	 * Specifies if folding (collapse and expand via an image icon in the graph
	 * should be enabled). Default is true.
	 */
  bool _foldingEnabled = true;

  /**
	 * Specifies the tolerance for mouse clicks. Default is 4.
	 */
  int _tolerance = 4;

  /**
	 * Specifies if swimlanes are selected when the mouse is released over the
	 * swimlanes content area. Default is true.
	 */
  bool _swimlaneSelectionEnabled = true;

  /**
	 * Specifies if the content area should be transparent to events. Default is
	 * true.
	 */
  bool _transparentSwimlaneContent = true;

  /**
	 * 
	 */
  int _gridStyle = GRID_STYLE_DOT;

  /**
	 * 
	 */
  ImageIcon _expandedIcon = DEFAULT_EXPANDED_ICON;

  /**
	 * 
	 */
  ImageIcon _collapsedIcon = DEFAULT_COLLAPSED_ICON;

  /**
	 * 
	 */
  ImageIcon _warningIcon = DEFAULT_WARNING_ICON;

  /**
	 * 
	 */
  bool _antiAlias = true;

  /**
	 * 
	 */
  bool _textAntiAlias = true;

  /**
	 * Specifies <escape> should be invoked when the escape key is pressed.
	 * Default is true.
	 */
  bool _escapeEnabled = true;

  /**
	 * If true, when editing is to be stopped by way of selection changing, data
	 * in diagram changing or other means stopCellEditing is invoked, and
	 * changes are saved. This is implemented in a mouse listener in this class.
	 * Default is true.
	 */
  bool _invokesStopCellEditing = true;

  /**
	 * If true, pressing the enter key without pressing control will stop
	 * editing and accept the new value. This is used in <mxKeyHandler> to stop
	 * cell editing. Default is false.
	 */
  bool _enterStopsCellEditing = false;

  /**
	 * Specifies the zoom policy. Default is ZOOM_POLICY_PAGE. The zoom policy
	 * does only apply if pageVisible is true.
	 */
  int _zoomPolicy = ZOOM_POLICY_PAGE;

  /**
	 * Internal flag to not reset zoomPolicy when zoom was set automatically.
	 */
  /*transient*/ bool _zooming = false;

  /**
	 * Specifies the factor used for zoomIn and zoomOut. Default is 1.2 (120%).
	 */
  double _zoomFactor = 1.2;

  /**
	 * Specifies if the viewport should automatically contain the selection
	 * cells after a zoom operation. Default is false.
	 */
  bool _keepSelectionVisibleOnZoom = false;

  /**
	 * Specifies if the zoom operations should go into the center of the actual
	 * diagram rather than going from top, left. Default is true.
	 */
  bool _centerZoom = true;

  /**
	 * Specifies if an image buffer should be used for painting the component.
	 * Default is false.
	 */
  bool _tripleBuffered = false;

  /**
	 * Used for debugging the dirty region.
	 */
  bool showDirtyRectangle = false;

  /**
	 * Maps from cells to lists of heavyweights.
	 */
  Hashtable<Object, List<Component>> _components = new Hashtable<Object, List<Component>>();

  /**
	 * Maps from cells to lists of overlays.
	 */
  Hashtable<Object, List<ICellOverlay>> _overlays = new Hashtable<Object, List<ICellOverlay>>();

  /**
	 * bool flag to disable centering after the first time.
	 */
  /*transient*/ bool _centerOnResize = true;

  /**
	 * Updates the heavyweight component structure after any changes.
	 */
  IEventListener _updateHandler = (Object sender, EventObj evt) {
    updateComponents();
    _graphControl.updatePreferredSize();
  };

  /**
	 * 
	 */
  IEventListener _repaintHandler = (Object source, EventObj evt) {
    Rect dirty = evt.getProperty("region") as Rect;
    awt.Rectangle rect = (dirty != null) ? dirty.getRectangle() : null;

    if (rect != null) {
      rect.grow(1, 1);
    }

    // Updates the triple buffer
    repaintTripleBuffer(rect);

    // Repaints the control using the optional triple buffer
    _graphControl.repaint((rect != null) ? rect : getViewport().getViewRect());

    // ----------------------------------------------------------
    // Shows the dirty region as a red rectangle (for debugging)
    JPanel panel = getClientProperty("dirty") as JPanel;

    if (showDirtyRectangle) {
      if (panel == null) {
        panel = new JPanel();
        panel.setOpaque(false);
        panel.setBorder(BorderFactory.createLineBorder(Color.RED));

        putClientProperty("dirty", panel);
        _graphControl.add(panel);
      }

      if (dirty != null) {
        panel.setBounds(dirty.getRectangle());
      }

      panel.setVisible(dirty != null);
    } else if (panel != null && panel.getParent() != null) {
      panel.getParent().remove(panel);
      putClientProperty("dirty", null);
      repaint();
    }
    // ----------------------------------------------------------
  };

  /**
	 * 
	 */
  PropertyChangeListener _viewChangeHandler = (PropertyChangeEvent evt) {
    if (evt.getPropertyName().equals("view")) {
      GraphView oldView = evt.getOldValue() as GraphView;
      GraphView newView = evt.getNewValue() as GraphView;

      if (oldView != null) {
        oldView.removeListener(_updateHandler);
      }

      if (newView != null) {
        newView.addListener(Event.SCALE, _updateHandler);
        newView.addListener(Event.TRANSLATE, _updateHandler);
        newView.addListener(Event.SCALE_AND_TRANSLATE, _updateHandler);
        newView.addListener(Event.UP, _updateHandler);
        newView.addListener(Event.DOWN, _updateHandler);
      }
    } else if (evt.getPropertyName().equals("model")) {
      GraphModel oldModel = evt.getOldValue() as GraphModel;
      GraphModel newModel = evt.getNewValue() as GraphModel;

      if (oldModel != null) {
        oldModel.removeListener(_updateHandler);
      }

      if (newModel != null) {
        newModel.addListener(Event.CHANGE, _updateHandler);
      }
    }
  };

  /**
	 * Resets the zoom policy if the scale is changed manually.
	 */
  IEventListener _scaleHandler = (Object sender, EventObj evt) {
    if (!_zooming) {
      _zoomPolicy = ZOOM_POLICY_NONE;
    }
  };

  /**
	 * 
	 * @param graph
	 */
  GraphComponent(Graph graph) {
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
  void _installFocusHandler() {
    _graphControl.addMouseListener(new FocusMouseAdapter(this));
  }

  /**
	 * Handles escape keystrokes.
	 */
  void _installKeyHandler() {
    addKeyListener(new EscapeKeyAdapter(this));
  }

  /**
	 * Applies the zoom policy if the size of the component changes.
	 */
  void _installResizeHandler() {
    addComponentListener(new ResizeComponentAdapter(this));
  }

  /**
	 * Adds handling of edit and stop-edit events after all other handlers have
	 * been installed.
	 */
  void _installDoubleClickHandler() {
    _graphControl.addMouseListener(new DoubleClickMouseAdapter(this));
  }

  /**
	 * 
	 */
  ICellEditor _createCellEditor() {
    return new CellEditor(this);
  }

  /**
	 * 
	 */
  void setGraph(Graph value) {
    Graph oldValue = _graph;

    // Uninstalls listeners for existing graph
    if (_graph != null) {
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
  Graph getGraph() {
    return _graph;
  }

  /**
	 * Creates the inner control that handles tooltips, preferred size and can
	 * draw cells onto a canvas.
	 */
  GraphControl _createGraphControl() {
    return new GraphControl(this);
  }

  /**
	 * 
	 * @return Returns the control that renders the graph.
	 */
  GraphControl getGraphControl() {
    return _graphControl;
  }

  /**
	 * Creates the connection-, panning and graphhandler (in this order).
	 */
  void _createHandlers() {
    setTransferHandler(_createTransferHandler());
    _panningHandler = _createPanningHandler();
    _selectionCellsHandler = _createSelectionCellsHandler();
    _connectionHandler = _createConnectionHandler();
    _graphHandler = _createGraphHandler();
  }

  /**
	 * 
	 */
  TransferHandler _createTransferHandler() {
    return new GraphTransferHandler();
  }

  /**
	 *
	 */
  SelectionCellsHandler _createSelectionCellsHandler() {
    return new SelectionCellsHandler(this);
  }

  /**
	 *
	 */
  GraphHandler _createGraphHandler() {
    return new GraphHandler(this);
  }

  /**
	 * 
	 */
  SelectionCellsHandler getSelectionCellsHandler() {
    return _selectionCellsHandler;
  }

  /**
	 * 
	 */
  GraphHandler getGraphHandler() {
    return _graphHandler;
  }

  /**
	 *
	 */
  ConnectionHandler _createConnectionHandler() {
    return new ConnectionHandler(this);
  }

  /**
	 * 
	 */
  ConnectionHandler getConnectionHandler() {
    return _connectionHandler;
  }

  /**
	 *
	 */
  PanningHandler _createPanningHandler() {
    return new PanningHandler(this);
  }

  /**
	 * 
	 */
  PanningHandler getPanningHandler() {
    return _panningHandler;
  }

  /**
	 * 
	 */
  bool isEditing() {
    return getCellEditor().getEditingCell() != null;
  }

  /**
	 * 
	 */
  ICellEditor getCellEditor() {
    return _cellEditor;
  }

  /**
	 * 
	 */
  void setCellEditor(ICellEditor value) {
    ICellEditor oldValue = _cellEditor;
    _cellEditor = value;

    firePropertyChange("cellEditor", oldValue, _cellEditor);
  }

  /**
	 * @return the tolerance
	 */
  int getTolerance() {
    return _tolerance;
  }

  /**
	 * @param value
	 *            the tolerance to set
	 */
  void setTolerance(int value) {
    int oldValue = _tolerance;
    _tolerance = value;

    firePropertyChange("tolerance", oldValue, _tolerance);
  }

  /**
	 * 
	 */
  PageFormat getPageFormat() {
    return _pageFormat;
  }

  /**
	 * 
	 */
  void setPageFormat(PageFormat value) {
    PageFormat oldValue = _pageFormat;
    _pageFormat = value;

    firePropertyChange("pageFormat", oldValue, _pageFormat);
  }

  /**
	 * 
	 */
  double getPageScale() {
    return _pageScale;
  }

  /**
	 * 
	 */
  void setPageScale(double value) {
    double oldValue = _pageScale;
    _pageScale = value;

    firePropertyChange("pageScale", oldValue, _pageScale);
  }

  /**
	 * Returns the size of the area that layouts can operate in.
	 */
  Rect getLayoutAreaSize() {
    if (_pageVisible) {
      awt.Dimension d = _getPreferredSizeForPage();

      return new Rect(new awt.Rectangle(d));
    } else {
      return new Rect(new awt.Rectangle(_graphControl.getSize()));
    }
  }

  /**
	 * 
	 */
  ImageIcon getBackgroundImage() {
    return _backgroundImage;
  }

  /**
	 * 
	 */
  void setBackgroundImage(ImageIcon value) {
    ImageIcon oldValue = _backgroundImage;
    _backgroundImage = value;

    firePropertyChange("backgroundImage", oldValue, _backgroundImage);
  }

  /**
	 * @return the pageVisible
	 */
  bool isPageVisible() {
    return _pageVisible;
  }

  /**
	 * Fires a property change event for <code>pageVisible</code>. zoomAndCenter
	 * should be called if this is set to true.
	 * 
	 * @param value
	 *            the pageVisible to set
	 */
  void setPageVisible(bool value) {
    bool oldValue = _pageVisible;
    _pageVisible = value;

    firePropertyChange("pageVisible", oldValue, _pageVisible);
  }

  /**
	 * @return the preferPageSize
	 */
  bool isPreferPageSize() {
    return _preferPageSize;
  }

  /**
	 * Fires a property change event for <code>preferPageSize</code>.
	 * 
	 * @param value
	 *            the preferPageSize to set
	 */
  void setPreferPageSize(bool value) {
    bool oldValue = _preferPageSize;
    _preferPageSize = value;

    firePropertyChange("preferPageSize", oldValue, _preferPageSize);
  }

  /**
	 * @return the pageBreaksVisible
	 */
  bool isPageBreaksVisible() {
    return _pageBreaksVisible;
  }

  /**
	 * @param value
	 *            the pageBreaksVisible to set
	 */
  void setPageBreaksVisible(bool value) {
    bool oldValue = _pageBreaksVisible;
    _pageBreaksVisible = value;

    firePropertyChange("pageBreaksVisible", oldValue, _pageBreaksVisible);
  }

  /**
	 * @return the pageBreakColor
	 */
  Color getPageBreakColor() {
    return _pageBreakColor;
  }

  /**
	 * @param pageBreakColor the pageBreakColor to set
	 */
  void setPageBreakColor(Color pageBreakColor) {
    this._pageBreakColor = pageBreakColor;
  }

  /**
	 * @param value
	 *            the horizontalPageCount to set
	 */
  void setHorizontalPageCount(int value) {
    int oldValue = _horizontalPageCount;
    _horizontalPageCount = value;

    firePropertyChange("horizontalPageCount", oldValue, _horizontalPageCount);
  }

  /**
	 * 
	 */
  int getHorizontalPageCount() {
    return _horizontalPageCount;
  }

  /**
	 * @param value
	 *            the verticalPageCount to set
	 */
  void setVerticalPageCount(int value) {
    int oldValue = _verticalPageCount;
    _verticalPageCount = value;

    firePropertyChange("verticalPageCount", oldValue, _verticalPageCount);
  }

  /**
	 * 
	 */
  int getVerticalPageCount() {
    return _verticalPageCount;
  }

  /**
	 * @return the centerPage
	 */
  bool isCenterPage() {
    return _centerPage;
  }

  /**
	 * zoomAndCenter should be called if this is set to true.
	 * 
	 * @param value
	 *            the centerPage to set
	 */
  void setCenterPage(bool value) {
    bool oldValue = _centerPage;
    _centerPage = value;

    firePropertyChange("centerPage", oldValue, _centerPage);
  }

  /**
	 * @return the pageBackgroundColor
	 */
  Color getPageBackgroundColor() {
    return _pageBackgroundColor;
  }

  /**
	 * Sets the color that appears behind the page.
	 * 
	 * @param value
	 *            the pageBackgroundColor to set
	 */
  void setPageBackgroundColor(Color value) {
    Color oldValue = _pageBackgroundColor;
    _pageBackgroundColor = value;

    firePropertyChange("pageBackgroundColor", oldValue, _pageBackgroundColor);
  }

  /**
	 * @return the pageShadowColor
	 */
  Color getPageShadowColor() {
    return _pageShadowColor;
  }

  /**
	 * @param value
	 *            the pageShadowColor to set
	 */
  void setPageShadowColor(Color value) {
    Color oldValue = _pageShadowColor;
    _pageShadowColor = value;

    firePropertyChange("pageShadowColor", oldValue, _pageShadowColor);
  }

  /**
	 * @return the pageShadowColor
	 */
  Color getPageBorderColor() {
    return _pageBorderColor;
  }

  /**
	 * @param value
	 *            the pageBorderColor to set
	 */
  void setPageBorderColor(Color value) {
    Color oldValue = _pageBorderColor;
    _pageBorderColor = value;

    firePropertyChange("pageBorderColor", oldValue, _pageBorderColor);
  }

  /**
	 * @return the keepSelectionVisibleOnZoom
	 */
  bool isKeepSelectionVisibleOnZoom() {
    return _keepSelectionVisibleOnZoom;
  }

  /**
	 * @param value
	 *            the keepSelectionVisibleOnZoom to set
	 */
  void setKeepSelectionVisibleOnZoom(bool value) {
    bool oldValue = _keepSelectionVisibleOnZoom;
    _keepSelectionVisibleOnZoom = value;

    firePropertyChange("keepSelectionVisibleOnZoom", oldValue, _keepSelectionVisibleOnZoom);
  }

  /**
	 * @return the zoomFactor
	 */
  double getZoomFactor() {
    return _zoomFactor;
  }

  /**
	 * @param value
	 *            the zoomFactor to set
	 */
  void setZoomFactor(double value) {
    double oldValue = _zoomFactor;
    _zoomFactor = value;

    firePropertyChange("zoomFactor", oldValue, _zoomFactor);
  }

  /**
	 * @return the centerZoom
	 */
  bool isCenterZoom() {
    return _centerZoom;
  }

  /**
	 * @param value
	 *            the centerZoom to set
	 */
  void setCenterZoom(bool value) {
    bool oldValue = _centerZoom;
    _centerZoom = value;

    firePropertyChange("centerZoom", oldValue, _centerZoom);
  }

  /**
	 * 
	 */
  void setZoomPolicy(int value) {
    int oldValue = _zoomPolicy;
    _zoomPolicy = value;

    if (_zoomPolicy != ZOOM_POLICY_NONE) {
      zoom(_zoomPolicy == ZOOM_POLICY_PAGE, true);
    }

    firePropertyChange("zoomPolicy", oldValue, _zoomPolicy);
  }

  /**
	 * 
	 */
  int getZoomPolicy() {
    return _zoomPolicy;
  }

  /**
	 * Callback to process an escape keystroke.
	 * 
	 * @param e
	 */
  void escape(KeyEvent e) {
    if (_selectionCellsHandler != null) {
      _selectionCellsHandler.reset();
    }

    if (_connectionHandler != null) {
      _connectionHandler.reset();
    }

    if (_graphHandler != null) {
      _graphHandler.reset();
    }

    if (_cellEditor != null) {
      _cellEditor.stopEditing(true);
    }
  }

  /**
	 * Clones and inserts the given cells into the graph using the move method
	 * and returns the inserted cells. This shortcut is used if cells are
	 * inserted via datatransfer.
	 */
  List<Object> importCells(List<Object> cells, double dx, double dy, Object target, awt.Point location) {
    return _graph.moveCells(cells, dx, dy, true, target, location);
  }

  /**
	 * Refreshes the display and handles.
	 */
  void refresh() {
    _graph.refresh();
    _selectionCellsHandler.refresh();
  }

  /**
	 * Returns an Point2d representing the given event in the unscaled,
	 * non-translated coordinate space and applies the grid.
	 */
  //	Point2d getPointForEvent(MouseEvent e)
  //	{
  //		return getPointForEvent(e, true);
  //	}

  /**
	 * Returns an Point2d representing the given event in the unscaled,
	 * non-translated coordinate space and applies the grid.
	 */
  Point2d getPointForEvent(MouseEvent e, [bool addOffset = true]) {
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
  void startEditing() {
    startEditingAtCell(null);
  }

  /**
	 * 
	 */
  //	void startEditingAtCell(Object cell)
  //	{
  //		startEditingAtCell(cell, null);
  //	}

  /**
	 * 
	 */
  void startEditingAtCell(Object cell, [EventObject evt = null]) {
    if (cell == null) {
      cell = _graph.getSelectionCell();

      if (cell != null && !_graph.isCellEditable(cell)) {
        cell = null;
      }
    }

    if (cell != null) {
      _eventSource.fireEvent(new EventObj(Event.START_EDITING, "cell", cell, "event", evt));
      _cellEditor.startEditing(cell, evt);
    }
  }

  /**
	 * 
	 */
  String getEditingValue(Object cell, EventObject trigger) {
    return _graph.convertValueToString(cell);
  }

  /**
	 * 
	 */
  void stopEditing(bool cancel) {
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
  Object labelChanged(Object cell, Object value, EventObject evt) {
    IGraphModel model = _graph.getModel();

    model.beginUpdate();
    try {
      _graph.cellLabelChanged(cell, value, _graph.isAutoSizeCell(cell));
      _eventSource.fireEvent(new EventObj(Event.LABEL_CHANGED, "cell", cell, "value", value, "event", evt));
    } finally {
      model.endUpdate();
    }

    return cell;
  }

  /**
	 * Returns the (unscaled) preferred size for the current page format (scaled
	 * by pageScale).
	 */
  awt.Dimension _getPreferredSizeForPage() {
    return new awt.Dimension(math.round(_pageFormat.getWidth() * _pageScale * _horizontalPageCount) as int, math.round(_pageFormat.getHeight() * _pageScale * _verticalPageCount) as int);
  }

  /**
	 * Returns the vertical border between the page and the control.
	 */
  int getVerticalPageBorder() {
    return math.round(_pageFormat.getWidth() * _pageScale) as int;
  }

  /**
	 * Returns the horizontal border between the page and the control.
	 */
  int getHorizontalPageBorder() {
    return math.round(0.5 * _pageFormat.getHeight() * _pageScale) as int;
  }

  /**
	 * Returns the scaled preferred size for the current graph.
	 */
  awt.Dimension _getScaledPreferredSizeForGraph() {
    Rect bounds = _graph.getGraphBounds();
    int border = _graph.getBorder();

    return new awt.Dimension((math.round(bounds.getX() + bounds.getWidth()) as int) + border + 1, (math.round(bounds.getY() as int) + bounds.getHeight()) + border + 1);
  }

  /**
	 * Should be called by a hook inside GraphView/Graph
	 */
  Point2d _getPageTranslate(double scale) {
    awt.Dimension d = _getPreferredSizeForPage();
    awt.Dimension bd = new awt.Dimension(d);

    if (!_preferPageSize) {
      bd.width += 2 * getHorizontalPageBorder();
      bd.height += 2 * getVerticalPageBorder();
    }

    double width = Math.max(bd.width, (getViewport().getWidth() - 8) / scale);
    double height = Math.max(bd.height, (getViewport().getHeight() - 8) / scale);

    double dx = Math.max(0, (width - d.width) / 2);
    double dy = Math.max(0, (height - d.height) / 2);

    return new Point2d(dx, dy);
  }

  /**
	 * Invoked after the component was resized to update the zoom if the zoom
	 * policy is not none and/or update the translation of the diagram if
	 * pageVisible and centerPage are true.
	 */
  void zoomAndCenter() {
    if (_zoomPolicy != ZOOM_POLICY_NONE) {
      // Centers only on the initial zoom call
      zoom(_zoomPolicy == ZOOM_POLICY_PAGE, _centerOnResize || _zoomPolicy == ZOOM_POLICY_PAGE);
      _centerOnResize = false;
    } else if (_pageVisible && _centerPage) {
      Point2d translate = _getPageTranslate(_graph.getView().getScale());
      _graph.getView().setTranslate(translate);
    } else {
      getGraphControl().updatePreferredSize();
    }
  }

  /**
	 * Zooms into the graph by zoomFactor.
	 */
  void zoomIn() {
    zoom(_zoomFactor);
  }

  /**
	 * Function: zoomOut
	 * 
	 * Zooms out of the graph by <zoomFactor>.
	 */
  void zoomOut() {
    zoom(1 / _zoomFactor);
  }

  /**
	 * 
	 */
  void zoomBy(double factor) {
    GraphView view = _graph.getView();
    double newScale = (double)((int)(view.getScale() * 100 * factor)) / 100;

    if (newScale != view.getScale() && newScale > 0.04) {
      Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(newScale) : new Point2d();
      _graph.getView().scaleAndTranslate(newScale, translate.getX(), translate.getY());

      if (_keepSelectionVisibleOnZoom && !_graph.isSelectionEmpty()) {
        getGraphControl().scrollRectToVisible(view.getBoundingBox(_graph.getSelectionCells()).getRectangle());
      } else {
        _maintainScrollBar(true, factor, _centerZoom);
        _maintainScrollBar(false, factor, _centerZoom);
      }
    }
  }

  /**
	 * 
	 */
  void zoomTo(final double newScale, final bool center) {
    GraphView view = _graph.getView();
    final double scale = view.getScale();

    Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(newScale) : new Point2d();
    _graph.getView().scaleAndTranslate(newScale, translate.getX(), translate.getY());

    // Causes two repaints on the scrollpane, namely one for the scale
    // change with the new preferred size and one for the change of
    // the scrollbar position. The latter cannot be done immediately
    // because the scrollbar keeps the value <= max - extent, and if
    // max is changed the value change will trigger a syncScrollPane
    // WithViewport in BasicScrollPaneUI, which will update the value
    // for the previous maximum (ie. it must be invoked later).
    SwingUtilities.invokeLater(() {
      _maintainScrollBar(true, newScale / scale, center);
      _maintainScrollBar(false, newScale / scale, center);
    });
  }

  /**
	 * Function: zoomActual
	 * 
	 * Resets the zoom and panning in the view.
	 */
  void zoomActual() {
    Point2d translate = (_pageVisible && _centerPage) ? _getPageTranslate(1) : new Point2d();
    _graph.getView().scaleAndTranslate(1, translate.getX(), translate.getY());

    if (isPageVisible()) {
      // Causes two repaints, see zoomTo for more details
      SwingUtilities.invokeLater(() {
        awt.Dimension pageSize = _getPreferredSizeForPage();

        if (getViewport().getWidth() > pageSize.getWidth()) {
          scrollToCenter(true);
        } else {
          JScrollBar scrollBar = getHorizontalScrollBar();

          if (scrollBar != null) {
            scrollBar.setValue((scrollBar.getMaximum() / 3) - 4);
          }
        }

        if (getViewport().getHeight() > pageSize.getHeight()) {
          scrollToCenter(false);
        } else {
          JScrollBar scrollBar = getVerticalScrollBar();

          if (scrollBar != null) {
            scrollBar.setValue((scrollBar.getMaximum() / 4) - 4);
          }
        }
      });
    }
  }

  /**
	 * 
	 */
  void zoom(final bool page, final bool center) {
    if (_pageVisible && !_zooming) {
      _zooming = true;

      try {
        int off = (getPageShadowColor() != null) ? 8 : 0;

        // Adds some extra space for the shadow and border
        double width = getViewport().getWidth() - off;
        double height = getViewport().getHeight() - off;

        awt.Dimension d = _getPreferredSizeForPage();
        double pageWidth = d.width;
        double pageHeight = d.height;

        double scaleX = width / pageWidth;
        double scaleY = (page) ? height / pageHeight : scaleX;

        // Rounds the new scale to 5% steps
        final double newScale = (double)((int)(Math.min(scaleX, scaleY) * 20)) / 20;

        if (newScale > 0) {
          GraphView graphView = _graph.getView();
          final double scale = graphView.getScale();
          Point2d translate = (_centerPage) ? _getPageTranslate(newScale) : new Point2d();
          graphView.scaleAndTranslate(newScale, translate.getX(), translate.getY());

          // Causes two repaints, see zoomTo for more details
          final double factor = newScale / scale;

          SwingUtilities.invokeLater(() {
            if (center) {
              if (page) {
                scrollToCenter(true);
                scrollToCenter(false);
              } else {
                scrollToCenter(true);
                _maintainScrollBar(false, factor, false);
              }
            } else if (factor != 1) {
              _maintainScrollBar(true, factor, false);
              _maintainScrollBar(false, factor, false);
            }
          });
        }
      } finally {
        _zooming = false;
      }
    }
  }

  /**
	 *
	 */
  void _maintainScrollBar(bool horizontal, double factor, bool center) {
    JScrollBar scrollBar = (horizontal) ? getHorizontalScrollBar() : getVerticalScrollBar();

    if (scrollBar != null) {
      BoundedRangeModel model = scrollBar.getModel();
      int newValue = (math.round(model.getValue() * factor) as int) + (math.round((center) ? (model.getExtent() * (factor - 1) / 2) : 0) as int);
      model.setValue(newValue);
    }
  }

  /**
	 * 
	 */
  void scrollToCenter(bool horizontal) {
    JScrollBar scrollBar = (horizontal) ? getHorizontalScrollBar() : getVerticalScrollBar();

    if (scrollBar != null) {
      final BoundedRangeModel model = scrollBar.getModel();
      final int newValue = ((model.getMaximum()) / 2) - model.getExtent() / 2;
      model.setValue(newValue);
    }
  }

  /**
	 * Scrolls the graph so that it shows the given cell.
	 * 
	 * @param cell
	 */
  //	void scrollCellToVisible(Object cell)
  //	{
  //		scrollCellToVisible(cell, false);
  //	}

  /**
	 * Scrolls the graph so that it shows the given cell.
	 * 
	 * @param cell
	 */
  void scrollCellToVisible(Object cell, [bool center = false]) {
    CellState state = _graph.getView().getState(cell);

    if (state != null) {
      Rect bounds = state;

      if (center) {
        bounds = bounds.clone() as Rect;

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
  //	Object getCellAt(int x, int y)
  //	{
  //		return getCellAt(x, y, true);
  //	}

  /**
	 * 
	 * @param x
	 * @param y
	 * @param hitSwimlaneContent
	 * @return Returns the cell at the given location.
	 */
  //	Object getCellAt(int x, int y, [bool hitSwimlaneContent=true])
  //	{
  //		return getCellAt(x, y, hitSwimlaneContent, null);
  //	}

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
  Object getCellAt(int x, int y, [bool hitSwimlaneContent = true, Object parent = null]) {
    if (parent == null) {
      parent = _graph.getDefaultParent();
    }

    if (parent != null) {
      awt.Point previousTranslate = _canvas.getTranslate();
      double previousScale = _canvas.getScale();

      try {
        _canvas.setScale(_graph.getView().getScale());
        _canvas.setTranslate(0, 0);

        IGraphModel model = _graph.getModel();
        GraphView view = _graph.getView();

        awt.Rectangle hit = new awt.Rectangle(x, y, 1, 1);
        int childCount = model.getChildCount(parent);

        for (int i = childCount - 1; i >= 0; i--) {
          Object cell = model.getChildAt(parent, i);
          Object result = getCellAt(x, y, hitSwimlaneContent, cell);

          if (result != null) {
            return result;
          } else if (_graph.isCellVisible(cell)) {
            CellState state = view.getState(cell);

            if (state != null && _canvas.intersects(this, hit, state) && (!_graph.isSwimlane(cell) || hitSwimlaneContent || (_transparentSwimlaneContent && !_canvas.hitSwimlaneContent(this, state, x, y)))) {
              return cell;
            }
          }
        }
      } finally {
        _canvas.setScale(previousScale);
        _canvas.setTranslate(previousTranslate.x, previousTranslate.y);
      }
    }

    return null;
  }

  /**
	 * 
	 */
  void setSwimlaneSelectionEnabled(bool value) {
    bool oldValue = _swimlaneSelectionEnabled;
    _swimlaneSelectionEnabled = value;

    firePropertyChange("swimlaneSelectionEnabled", oldValue, _swimlaneSelectionEnabled);
  }

  /**
	 * 
	 */
  bool isSwimlaneSelectionEnabled() {
    return _swimlaneSelectionEnabled;
  }

  /**
	 * 
	 */
  List<Object> selectRegion(awt.Rectangle rect, MouseEvent e) {
    List<Object> cells = getCells(rect);

    if (cells.length > 0) {
      selectCellsForEvent(cells, e);
    } else if (!_graph.isSelectionEmpty() && !e.isConsumed()) {
      _graph.clearSelection();
    }

    return cells;
  }

  /**
	 * Returns the cells inside the given rectangle.
	 * 
	 * @return Returns the cells inside the given rectangle.
	 */
  //	List<Object> getCells(awt.Rectangle rect)
  //	{
  //		return getCells(rect, null);
  //	}

  /**
	 * Returns the children of the given parent that are contained in the given
	 * rectangle (x, y, width, height). The result is added to the optional
	 * result array, which is returned from the function. If no result array is
	 * specified then a new array is created and returned.
	 * 
	 * @return Returns the children inside the given rectangle.
	 */
  List<Object> getCells(awt.Rectangle rect, [Object parent = null]) {
    Collection<Object> result = new List<Object>();

    if (rect.width > 0 || rect.height > 0) {
      if (parent == null) {
        parent = _graph.getDefaultParent();
      }

      if (parent != null) {
        awt.Point previousTranslate = _canvas.getTranslate();
        double previousScale = _canvas.getScale();

        try {
          _canvas.setScale(_graph.getView().getScale());
          _canvas.setTranslate(0, 0);

          IGraphModel model = _graph.getModel();
          GraphView view = _graph.getView();

          int childCount = model.getChildCount(parent);

          for (int i = 0; i < childCount; i++) {
            Object cell = model.getChildAt(parent, i);
            CellState state = view.getState(cell);

            if (_graph.isCellVisible(cell) && state != null) {
              if (_canvas.contains(this, rect, state)) {
                result.add(cell);
              } else {
                result.addAll(Arrays.asList(getCells(rect, cell)));
              }
            }
          }
        } finally {
          _canvas.setScale(previousScale);
          _canvas.setTranslate(previousTranslate.x, previousTranslate.y);
        }
      }
    }

    return result.toArray();
  }

  /**
	 * Selects the cells for the given event.
	 */
  void selectCellsForEvent(List<Object> cells, MouseEvent event) {
    if (isToggleEvent(event)) {
      _graph.addSelectionCells(cells);
    } else {
      _graph.setSelectionCells(cells);
    }
  }

  /**
	 * Selects the cell for the given event.
	 */
  void selectCellForEvent(Object cell, MouseEvent e) {
    bool isSelected = _graph.isCellSelected(cell);

    if (isToggleEvent(e)) {
      if (isSelected) {
        _graph.removeSelectionCell(cell);
      } else {
        _graph.addSelectionCell(cell);
      }
    } else if (!isSelected || _graph.getSelectionCount() != 1) {
      _graph.setSelectionCell(cell);
    }
  }

  /**
	 * Returns true if the absolute value of one of the given parameters is
	 * greater than the tolerance.
	 */
  bool isSignificant(double dx, double dy) {
    return math.abs(dx) > _tolerance || math.abs(dy) > _tolerance;
  }

  /**
	 * Returns the icon used to display the collapsed state of the specified
	 * cell state. This returns null for all edges.
	 */
  ImageIcon getFoldingIcon(CellState state) {
    if (state != null && isFoldingEnabled() && !getGraph().getModel().isEdge(state.getCell())) {
      Object cell = state.getCell();
      bool tmp = _graph.isCellCollapsed(cell);

      if (_graph.isCellFoldable(cell, !tmp)) {
        return (tmp) ? _collapsedIcon : _expandedIcon;
      }
    }

    return null;
  }

  /**
	 * 
	 */
  awt.Rectangle getFoldingIconBounds(CellState state, ImageIcon icon) {
    IGraphModel model = _graph.getModel();
    bool isEdge = model.isEdge(state.getCell());
    double scale = getGraph().getView().getScale();

    int x = math.round(state.getX() + 4 * scale) as int;
    int y = math.round(state.getY() + 4 * scale) as int;
    int w = Math.max(8, icon.getIconWidth() * scale) as int;
    int h = Math.max(8, icon.getIconHeight() * scale) as int;

    if (isEdge) {
      Point2d pt = _graph.getView().getPoint(state);

      x = (pt.getX() as int) - w / 2;
      y = (pt.getY() as int) - h / 2;
    }

    return new awt.Rectangle(x, y, w, h);
  }

  /**
	 *
	 */
  bool hitFoldingIcon(Object cell, int x, int y) {
    if (cell != null) {
      IGraphModel model = _graph.getModel();

      // Draws the collapse/expand icons
      bool isEdge = model.isEdge(cell);

      if (_foldingEnabled && (model.isVertex(cell) || isEdge)) {
        CellState state = _graph.getView().getState(cell);

        if (state != null) {
          ImageIcon icon = getFoldingIcon(state);

          if (icon != null) {
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
  void setToolTips(bool enabled) {
    if (enabled) {
      ToolTipManager.sharedInstance().registerComponent(_graphControl);
    } else {
      ToolTipManager.sharedInstance().unregisterComponent(_graphControl);
    }
  }

  /**
	 * 
	 */
  bool isConnectable() {
    return _connectionHandler.isEnabled();
  }

  /**
	 * @param connectable
	 */
  void setConnectable(bool connectable) {
    _connectionHandler.setEnabled(connectable);
  }

  /**
	 * 
	 */
  bool isPanning() {
    return _panningHandler.isEnabled();
  }

  /**
	 * @param enabled
	 */
  void setPanning(bool enabled) {
    _panningHandler.setEnabled(enabled);
  }

  /**
	 * @return the autoScroll
	 */
  bool isAutoScroll() {
    return _autoScroll;
  }

  /**
	 * @param value
	 *            the autoScroll to set
	 */
  void setAutoScroll(bool value) {
    _autoScroll = value;
  }

  /**
	 * @return the autoExtend
	 */
  bool isAutoExtend() {
    return _autoExtend;
  }

  /**
	 * @param value
	 *            the autoExtend to set
	 */
  void setAutoExtend(bool value) {
    _autoExtend = value;
  }

  /**
	 * @return the escapeEnabled
	 */
  bool isEscapeEnabled() {
    return _escapeEnabled;
  }

  /**
	 * @param value
	 *            the escapeEnabled to set
	 */
  void setEscapeEnabled(bool value) {
    bool oldValue = _escapeEnabled;
    _escapeEnabled = value;

    firePropertyChange("escapeEnabled", oldValue, _escapeEnabled);
  }

  /**
	 * @return the escapeEnabled
	 */
  bool isInvokesStopCellEditing() {
    return _invokesStopCellEditing;
  }

  /**
	 * @param value
	 *            the invokesStopCellEditing to set
	 */
  void setInvokesStopCellEditing(bool value) {
    bool oldValue = _invokesStopCellEditing;
    _invokesStopCellEditing = value;

    firePropertyChange("invokesStopCellEditing", oldValue, _invokesStopCellEditing);
  }

  /**
	 * @return the enterStopsCellEditing
	 */
  bool isEnterStopsCellEditing() {
    return _enterStopsCellEditing;
  }

  /**
	 * @param value
	 *            the enterStopsCellEditing to set
	 */
  void setEnterStopsCellEditing(bool value) {
    bool oldValue = _enterStopsCellEditing;
    _enterStopsCellEditing = value;

    firePropertyChange("enterStopsCellEditing", oldValue, _enterStopsCellEditing);
  }

  /**
	 * @return the dragEnabled
	 */
  bool isDragEnabled() {
    return _dragEnabled;
  }

  /**
	 * @param value
	 *            the dragEnabled to set
	 */
  void setDragEnabled(bool value) {
    bool oldValue = _dragEnabled;
    _dragEnabled = value;

    firePropertyChange("dragEnabled", oldValue, _dragEnabled);
  }

  /**
	 * @return the gridVisible
	 */
  bool isGridVisible() {
    return _gridVisible;
  }

  /**
	 * Fires a property change event for <code>gridVisible</code>.
	 * 
	 * @param value
	 *            the gridVisible to set
	 */
  void setGridVisible(bool value) {
    bool oldValue = _gridVisible;
    _gridVisible = value;

    firePropertyChange("gridVisible", oldValue, _gridVisible);
  }

  /**
	 * @return the gridVisible
	 */
  bool isAntiAlias() {
    return _antiAlias;
  }

  /**
	 * Fires a property change event for <code>antiAlias</code>.
	 * 
	 * @param value
	 *            the antiAlias to set
	 */
  void setAntiAlias(bool value) {
    bool oldValue = _antiAlias;
    _antiAlias = value;

    firePropertyChange("antiAlias", oldValue, _antiAlias);
  }

  /**
	 * @return the gridVisible
	 */
  bool isTextAntiAlias() {
    return _antiAlias;
  }

  /**
	 * Fires a property change event for <code>textAntiAlias</code>.
	 * 
	 * @param value
	 *            the textAntiAlias to set
	 */
  void setTextAntiAlias(bool value) {
    bool oldValue = _textAntiAlias;
    _textAntiAlias = value;

    firePropertyChange("textAntiAlias", oldValue, _textAntiAlias);
  }

  /**
	 * 
	 */
  float getPreviewAlpha() {
    return _previewAlpha;
  }

  /**
	 * 
	 */
  void setPreviewAlpha(float value) {
    float oldValue = _previewAlpha;
    _previewAlpha = value;

    firePropertyChange("previewAlpha", oldValue, _previewAlpha);
  }

  /**
	 * @return the tripleBuffered
	 */
  bool isTripleBuffered() {
    return _tripleBuffered;
  }

  /**
	 * Hook for dynamic triple buffering condition.
	 */
  bool isForceTripleBuffered() {
    // LATER: Dynamic condition (cell density) to use triple
    // buffering for a large number of cells on a small rect
    return false;
  }

  /**
	 * @param value
	 *            the tripleBuffered to set
	 */
  void setTripleBuffered(bool value) {
    bool oldValue = _tripleBuffered;
    _tripleBuffered = value;

    firePropertyChange("tripleBuffered", oldValue, _tripleBuffered);
  }

  /**
	 * @return the gridColor
	 */
  Color getGridColor() {
    return _gridColor;
  }

  /**
	 * Fires a property change event for <code>gridColor</code>.
	 * 
	 * @param value
	 *            the gridColor to set
	 */
  void setGridColor(Color value) {
    Color oldValue = _gridColor;
    _gridColor = value;

    firePropertyChange("gridColor", oldValue, _gridColor);
  }

  /**
	 * @return the gridStyle
	 */
  int getGridStyle() {
    return _gridStyle;
  }

  /**
	 * Fires a property change event for <code>gridStyle</code>.
	 * 
	 * @param value
	 *            the gridStyle to set
	 */
  void setGridStyle(int value) {
    int oldValue = _gridStyle;
    _gridStyle = value;

    firePropertyChange("gridStyle", oldValue, _gridStyle);
  }

  /**
	 * Returns importEnabled.
	 */
  bool isImportEnabled() {
    return _importEnabled;
  }

  /**
	 * Sets importEnabled.
	 */
  void setImportEnabled(bool value) {
    bool oldValue = _importEnabled;
    _importEnabled = value;

    firePropertyChange("importEnabled", oldValue, _importEnabled);
  }

  /**
	 * Returns all cells which may be imported via datatransfer.
	 */
  List<Object> getImportableCells(List<Object> cells) {
    return GraphModel.filterCells(cells, (Object cell) {
      return canImportCell(cell);
    });
  }

  /**
	 * Returns true if the given cell can be imported via datatransfer. This
	 * returns importEnabled.
	 */
  bool canImportCell(Object cell) {
    return isImportEnabled();
  }

  /**
	 * @return the exportEnabled
	 */
  bool isExportEnabled() {
    return _exportEnabled;
  }

  /**
	 * @param value
	 *            the exportEnabled to set
	 */
  void setExportEnabled(bool value) {
    bool oldValue = _exportEnabled;
    _exportEnabled = value;

    firePropertyChange("exportEnabled", oldValue, _exportEnabled);
  }

  /**
	 * Returns all cells which may be exported via datatransfer.
	 */
  List<Object> getExportableCells(List<Object> cells) {
    return GraphModel.filterCells(cells, (Object cell) {
      return canExportCell(cell);
    });
  }

  /**
	 * Returns true if the given cell can be exported via datatransfer.
	 */
  bool canExportCell(Object cell) {
    return isExportEnabled();
  }

  /**
	 * @return the foldingEnabled
	 */
  bool isFoldingEnabled() {
    return _foldingEnabled;
  }

  /**
	 * @param value
	 *            the foldingEnabled to set
	 */
  void setFoldingEnabled(bool value) {
    bool oldValue = _foldingEnabled;
    _foldingEnabled = value;

    firePropertyChange("foldingEnabled", oldValue, _foldingEnabled);
  }

  /**
	 * 
	 */
  bool isEditEvent(MouseEvent e) {
    return (e != null) ? e.getClickCount() == 2 : false;
  }

  /**
	 * 
	 * @param event
	 * @return Returns true if the given event should toggle selected cells.
	 */
  bool isCloneEvent(MouseEvent event) {
    return (event != null) ? event.isControlDown() : false;
  }

  /**
	 * 
	 * @param event
	 * @return Returns true if the given event should toggle selected cells.
	 */
  bool isToggleEvent(MouseEvent event) {
    // NOTE: IsMetaDown always returns true for right-clicks on the Mac, so
    // toggle selection for left mouse buttons requires CMD key to be pressed,
    // but toggle for right mouse buttons requires CTRL to be pressed.
    return (event != null) ? ((Utils.IS_MAC) ? ((SwingUtilities.isLeftMouseButton(event) && event.isMetaDown()) || (SwingUtilities.isRightMouseButton(event) && event.isControlDown())) : event.isControlDown()) : false;
  }

  /**
	 * 
	 * @param event
	 * @return Returns true if the given event allows the grid to be applied.
	 */
  bool isGridEnabledEvent(MouseEvent event) {
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
  bool isPanningEvent(MouseEvent event) {
    return (event != null) ? event.isShiftDown() && event.isControlDown() : false;
  }

  /**
	 * Note: This is not used during drag and drop operations due to limitations
	 * of the underlying API. To enable this for move operations set dragEnabled
	 * to false.
	 * 
	 * @param event
	 * @return Returns true if the given event is constrained.
	 */
  bool isConstrainedEvent(MouseEvent event) {
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
  bool isForceMarqueeEvent(MouseEvent event) {
    return (event != null) ? event.isAltDown() : false;
  }

  /**
	 * 
	 */
  //	Point2d snapScaledPoint(Point2d pt)
  //	{
  //		return snapScaledPoint(pt, 0, 0);
  //	}

  /**
	 * 
	 */
  Point2d snapScaledPoint(Point2d pt, [double dx = 0.0, double dy = 0.0]) {
    if (pt != null) {
      double scale = _graph.getView().getScale();
      Point2d trans = _graph.getView().getTranslate();

      pt.setX((_graph.snap(pt.getX() / scale - trans.getX() + dx / scale) + trans.getX()) * scale - dx);
      pt.setY((_graph.snap(pt.getY() / scale - trans.getY() + dy / scale) + trans.getY()) * scale - dy);
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
  int print(Graphics g, PageFormat printFormat, int page) {
    int result = NO_SUCH_PAGE;

    // Disables double-buffering before printing
    RepaintManager currentManager = RepaintManager.currentManager(this);
    currentManager.setDoubleBufferingEnabled(false);

    // Gets the current state of the view
    GraphView view = _graph.getView();

    // Stores the old state of the view
    bool eventsEnabled = view.isEventsEnabled();
    Point2d translate = view.getTranslate();

    // Disables firing of scale events so that there is no
    // repaint or update of the original graph while pages
    // are being printed
    view.setEventsEnabled(false);

    // Uses the view to create temporary cell states for each cell
    TemporaryCellStates tempStates = new TemporaryCellStates(view, 1 / _pageScale);

    try {
      view.setTranslate(new Point2d(0, 0));

      Graphics2DCanvas canvas = createCanvas();
      canvas.setGraphics(g as Graphics2D);
      canvas.setScale(1 / _pageScale);

      view.revalidate();

      Rect graphBounds = _graph.getGraphBounds();
      awt.Dimension pSize = new awt.Dimension((math.ceil(graphBounds.getX() + graphBounds.getWidth()) as int) + 1, (math.ceil(graphBounds.getY() + graphBounds.getHeight()) as int) + 1);

      int w = printFormat.getImageableWidth() as int;
      int h = printFormat.getImageableHeight() as int;
      int cols = Math.max(math.ceil(((pSize.width - 5) as double) / (w as double)), 1) as int;
      int rows = Math.max(math.ceil(((pSize.height - 5) as double) / (h as double)), 1) as int;

      if (page < cols * rows) {
        int dx = ((page % cols) * printFormat.getImageableWidth()) as int;
        int dy = (Math.floor(page / cols) * printFormat.getImageableHeight()) as int;

        g.translate(-dx + (printFormat.getImageableX() as int), -dy + (printFormat.getImageableY() as int));
        g.setClip(dx, dy, (dx + printFormat.getWidth() as int), (dy + printFormat.getHeight()) as int);

        _graph.drawGraph(canvas);

        result = PAGE_EXISTS;
      }
    } finally {
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
  InteractiveCanvas getCanvas() {
    return _canvas;
  }

  /**
	 * 
	 */
  BufferedImage getTripleBuffer() {
    return _tripleBuffer;
  }

  /**
	 * Hook for subclassers to replace the graphics canvas for rendering and and
	 * printing. This must be overridden to return a custom canvas if there are
	 * any custom shapes.
	 */
  InteractiveCanvas createCanvas() {
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
  CellHandler createHandler(CellState state) {
    if (_graph.getModel().isVertex(state.getCell())) {
      return new VertexHandler(this, state);
    } else if (_graph.getModel().isEdge(state.getCell())) {
      EdgeStyleFunction style = _graph.getView().getEdgeStyle(state, null, null, null);

      if (_graph.isLoop(state) || style == EdgeStyle.ElbowConnector || style == EdgeStyle.SideToSide || style == EdgeStyle.TopToBottom) {
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
  List<Component> createComponents(CellState state) {
    return null;
  }

  /**
	 * 
	 */
  void insertComponent(CellState state, Component c) {
    getGraphControl().add(c, 0);
  }

  /**
	 * 
	 */
  void removeComponent(Component c, Object cell) {
    if (c.getParent() != null) {
      c.getParent().remove(c);
    }
  }

  /**
	 * 
	 */
  void updateComponent(CellState state, Component c) {
    int x = state.getX() as int;
    int y = state.getY() as int;
    int width = state.getWidth() as int;
    int height = state.getHeight() as int;

    awt.Dimension s = c.getMinimumSize();

    if (s.width > width) {
      x -= (s.width - width) / 2;
      width = s.width;
    }

    if (s.height > height) {
      y -= (s.height - height) / 2;
      height = s.height;
    }

    c.setBounds(x, y, width, height);
  }

  /**
	 * 
	 */
  void updateComponents() {
    Object root = _graph.getModel().getRoot();
    Hashtable<Object, List<Component>> result = updateComponents(root);

    // Components now contains the mappings which are no
    // longer used, the result contains the new mappings
    removeAllComponents(_components);
    _components = result;

    if (!_overlays.isEmpty()) {
      Hashtable<Object, List<ICellOverlay>> result2 = updateCellOverlays(root);

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
  void removeAllComponents(Hashtable<Object, List<Component>> map) {
    Iterator<Map.Entry<Object, List<Component>>> it = map.entrySet().iterator();

    while (it.moveNext()) {
      Map.Entry<Object, List<Component>> entry = it.current();
      List<Component> c = entry.getValue();

      for (int i = 0; i < c.length; i++) {
        removeComponent(c[i], entry.getKey());
      }
    }
  }

  /**
	 * 
	 */
  void removeAllOverlays(Hashtable<Object, List<ICellOverlay>> map) {
    Iterator<Map.Entry<Object, List<ICellOverlay>>> it = map.entrySet().iterator();

    while (it.moveNext()) {
      Map.Entry<Object, List<ICellOverlay>> entry = it.current();
      List<ICellOverlay> c = entry.getValue();

      for (int i = 0; i < c.length; i++) {
        _removeCellOverlayComponent(c[i], entry.getKey());
      }
    }
  }

  /**
	 * 
	 */
  Hashtable<Object, List<Component>> updateCellComponents(Object cell) {
    Hashtable<Object, List<Component>> result = new Hashtable<Object, List<Component>>();
    List<Component> c = _components.remove(cell);
    CellState state = getGraph().getView().getState(cell);

    if (state != null) {
      if (c == null) {
        c = createComponents(state);

        if (c != null) {
          for (int i = 0; i < c.length; i++) {
            insertComponent(state, c[i]);
          }
        }
      }

      if (c != null) {
        result.put(cell, c);

        for (int i = 0; i < c.length; i++) {
          updateComponent(state, c[i]);
        }
      }
    } // Puts the component back into the map so that it will be removed
    else if (c != null) {
      _components.put(cell, c);
    }

    int childCount = getGraph().getModel().getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      result.putAll(updateComponents(getGraph().getModel().getChildAt(cell, i)));
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
  String validateGraph() {
    return validateGraph(_graph.getModel().getRoot(), new Hashtable<Object, Object>());
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
  String validateGraphCell(Object cell, Hashtable<Object, Object> context) {
    IGraphModel model = _graph.getModel();
    GraphView view = _graph.getView();
    bool isValid = true;
    int childCount = model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      Object tmp = model.getChildAt(cell, i);
      Hashtable<Object, Object> ctx = context;

      if (_graph.isValidRoot(tmp)) {
        ctx = new Hashtable<Object, Object>();
      }

      String warn = validateGraph(tmp, ctx);

      if (warn != null) {
        String html = warn.replaceAll("\n", "<br>");
        int len = html.length;
        setCellWarning(tmp, html.substring(0, Math.max(0, len - 4)));
      } else {
        setCellWarning(tmp, null);
      }

      isValid = isValid && warn == null;
    }

    StringBuffer warning = new StringBuffer();

    // Adds error for invalid children if collapsed (children invisible)
    if (_graph.isCellCollapsed(cell) && !isValid) {
      warning.append(Resources.get("containsValidationErrors", "Contains Validation Errors") + "\n");
    }

    // Checks edges and cells using the defined multiplicities
    if (model.isEdge(cell)) {
      String tmp = _graph.getEdgeValidationError(cell, model.getTerminal(cell, true), model.getTerminal(cell, false));

      if (tmp != null) {
        warning.append(tmp);
      }
    } else {
      String tmp = _graph.getCellValidationError(cell);

      if (tmp != null) {
        warning.append(tmp);
      }
    }

    // Checks custom validation rules
    String err = _graph.validateCell(cell, context);

    if (err != null) {
      warning.append(err);
    }

    // Updates the display with the warning icons before any potential
    // alerts are displayed
    if (model.getParent(cell) == null) {
      view.validate();
    }

    return (warning.length > 0 || !isValid) ? warning.toString() : null;
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
  ICellOverlay addCellOverlay(Object cell, ICellOverlay overlay) {
    List<ICellOverlay> arr = getCellOverlays(cell);

    if (arr == null) {
      arr = [overlay];
    } else {
      List<ICellOverlay> arr2 = new List<ICellOverlay>(arr.length + 1);
      System.arraycopy(arr, 0, arr2, 0, arr.length);
      arr2[arr.length] = overlay;
      arr = arr2;
    }

    _overlays.put(cell, arr);
    CellState state = _graph.getView().getState(cell);

    if (state != null) {
      _updateCellOverlayComponent(state, overlay);
    }

    _eventSource.fireEvent(new EventObj(Event.ADD_OVERLAY, "cell", cell, "overlay", overlay));

    return overlay;
  }

  /**
	 * Returns the array of overlays for the given cell or null, if no overlays
	 * are defined.
	 * 
	 * @param cell
	 *            Cell whose overlays should be returned.
	 */
  List<ICellOverlay> getCellOverlays(Object cell) {
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
  ICellOverlay removeCellOverlay(Object cell, ICellOverlay overlay) {
    if (overlay == null) {
      removeCellOverlays(cell);
    } else {
      List<ICellOverlay> arr = getCellOverlays(cell);

      if (arr != null) {
        // TODO: Use arraycopy from/to same array to speed this up
        List<ICellOverlay> list = new List<ICellOverlay>(Arrays.asList(arr));

        if (list.remove(overlay)) {
          _removeCellOverlayComponent(overlay, cell);
        }

        arr = list.toArray(new List<ICellOverlay>(list.length));
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
  List<ICellOverlay> removeCellOverlays(Object cell) {
    List<ICellOverlay> ovls = _overlays.remove(cell);

    if (ovls != null) {
      // Removes the overlays from the cell hierarchy
      for (int i = 0; i < ovls.length; i++) {
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
  void _removeCellOverlayComponent(ICellOverlay overlay, Object cell) {
    if (overlay is Component) {
      Component comp = overlay as Component;

      if (comp.getParent() != null) {
        comp.setVisible(false);
        comp.getParent().remove(comp);
        _eventSource.fireEvent(new EventObj(Event.REMOVE_OVERLAY, "cell", cell, "overlay", overlay));
      }
    }
  }

  /**
	 * Notified when an overlay has been removed from the graph. This
	 * implementation removes the given overlay from its parent if it is a
	 * component inside a component hierarchy.
	 */
  void _updateCellOverlayComponent(CellState state, ICellOverlay overlay) {
    if (overlay is Component) {
      Component comp = overlay as Component;

      if (comp.getParent() == null) {
        getGraphControl().add(comp, 0);
      }

      Rect rect = overlay.getBounds(state);

      if (rect != null) {
        comp.setBounds(rect.getRectangle());
        comp.setVisible(true);
      } else {
        comp.setVisible(false);
      }
    }
  }

  /**
	 * Removes all overlays in the graph.
	 */
  //	void clearCellOverlays()
  //	{
  //		clearCellOverlays(null);
  //	}

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
  void clearCellOverlays([Object cell = null]) {
    IGraphModel model = _graph.getModel();

    if (cell == null) {
      cell = model.getRoot();
    }

    removeCellOverlays(cell);

    // Recursively removes all overlays from the children
    int childCount = model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
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
  //	ICellOverlay setCellWarning(Object cell, String warning)
  //	{
  //		return setCellWarning(cell, warning, null, false);
  //	}

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
  //	ICellOverlay setCellWarning(Object cell, String warning,
  //			ImageIcon icon)
  //	{
  //		return setCellWarning(cell, warning, icon, false);
  //	}

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
	 *            Optional bool indicating if a click on the overlay should
	 *            select the corresponding cell. Default is false.
	 */
  ICellOverlay setCellWarning(final Object cell, String warning, [ImageIcon icon = null, bool select = false]) {
    if (warning != null && warning.length > 0) {
      icon = (icon != null) ? icon : _warningIcon;

      // Creates the overlay with the image and warning
      CellOverlay overlay = new CellOverlay(icon, warning);

      // Adds a handler for single mouseclicks to select the cell
      if (select) {
        overlay.addMouseListener(new SelectCellMouseAdapter(this, cell));

        overlay.setCursor(new Cursor(Cursor.HAND_CURSOR));
      }

      // Sets and returns the overlay in the graph
      return addCellOverlay(cell, overlay);
    } else {
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
  Hashtable<Object, List<ICellOverlay>> updateCellOverlays(Object cell) {
    Hashtable<Object, List<ICellOverlay>> result = new Hashtable<Object, List<ICellOverlay>>();
    List<ICellOverlay> c = _overlays.remove(cell);
    CellState state = getGraph().getView().getState(cell);

    if (c != null) {
      if (state != null) {
        for (int i = 0; i < c.length; i++) {
          _updateCellOverlayComponent(state, c[i]);
        }
      } else {
        for (int i = 0; i < c.length; i++) {
          _removeCellOverlayComponent(c[i], cell);
        }
      }

      result.put(cell, c);
    }

    int childCount = getGraph().getModel().getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      result.putAll(updateCellOverlays(getGraph().getModel().getChildAt(cell, i)));
    }

    return result;
  }

  /**
	 * 
	 */
  void _paintBackground(Graphics g) {
    awt.Rectangle clip = g.getClipBounds();
    awt.Rectangle rect = _paintBackgroundPage(g);

    if (isPageVisible()) {
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
  awt.Rectangle _paintBackgroundPage(Graphics g) {
    Point2d translate = _graph.getView().getTranslate();
    double scale = _graph.getView().getScale();

    int x0 = (math.round(translate.getX() * scale) as int) - 1;
    int y0 = (math.round(translate.getY() * scale) as int) - 1;

    awt.Dimension d = _getPreferredSizeForPage();
    int w = (math.round(d.width * scale) as int) + 2;
    int h = (math.round(d.height * scale) as int) + 2;

    if (isPageVisible()) {
      // Draws the background behind the page
      Color c = getPageBackgroundColor();

      if (c != null) {
        g.setColor(c);
        Utils.fillClippedRect(g, 0, 0, getGraphControl().getWidth(), getGraphControl().getHeight());
      }

      // Draws the page drop shadow
      c = getPageShadowColor();

      if (c != null) {
        g.setColor(c);
        Utils.fillClippedRect(g, x0 + w, y0 + 6, 6, h - 6);
        Utils.fillClippedRect(g, x0 + 8, y0 + h, w - 2, 6);
      }

      // Draws the page
      Color bg = getBackground();

      if (getViewport().isOpaque()) {
        bg = getViewport().getBackground();
      }

      g.setColor(bg);
      Utils.fillClippedRect(g, x0 + 1, y0 + 1, w, h);

      // Draws the page border
      c = getPageBorderColor();

      if (c != null) {
        g.setColor(c);
        g.drawRect(x0, y0, w, h);
      }
    }

    if (isPageBreaksVisible() && (_horizontalPageCount > 1 || _verticalPageCount > 1)) {
      // Draws the pagebreaks
      // TODO: Use clipping
      Graphics2D g2 = g as Graphics2D;
      Stroke previousStroke = g2.getStroke();

      g2.setStroke(new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0, [1.0, 2.0], 0));
      g2.setColor(_pageBreakColor);

      for (int i = 1; i <= _horizontalPageCount - 1; i++) {
        int dx = i * w / _horizontalPageCount;
        g2.drawLine(x0 + dx, y0 + 1, x0 + dx, y0 + h);
      }

      for (int i = 1; i <= _verticalPageCount - 1; i++) {
        int dy = i * h / _verticalPageCount;
        g2.drawLine(x0 + 1, y0 + dy, x0 + w, y0 + dy);
      }

      // Restores the graphics
      g2.setStroke(previousStroke);
    }

    return new awt.Rectangle(x0, y0, w, h);
  }

  /**
	 * 
	 */
  void _paintBackgroundImage(Graphics g) {
    if (_backgroundImage != null) {
      Point2d translate = _graph.getView().getTranslate();
      double scale = _graph.getView().getScale();

      g.drawImage(_backgroundImage.getImage(), (int)(translate.getX() * scale), (int)(translate.getY() * scale), (int)(_backgroundImage.getIconWidth() * scale), (int)(_backgroundImage.getIconHeight() * scale), this);
    }
  }

  /**
	 * Paints the grid onto the given graphics object.
	 */
  void _paintGrid(Graphics g) {
    if (isGridVisible()) {
      g.setColor(getGridColor());
      awt.Rectangle clip = g.getClipBounds();

      if (clip == null) {
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
      if (style == GRID_STYLE_CROSS || style == GRID_STYLE_DOT) {
        minStepping /= 2;
      }

      // Fetches some global display state information
      Point2d trans = _graph.getView().getTranslate();
      double scale = _graph.getView().getScale();
      double tx = trans.getX() * scale;
      double ty = trans.getY() * scale;

      // Sets the distance of the grid lines in pixels
      double stepping = gridSize * scale;

      if (stepping < minStepping) {
        int count = (math.round(math.ceil(minStepping / stepping) / 2) as int) * 2;
        stepping = count * stepping;
      }

      double xs = Math.floor((left - tx) / stepping) * stepping + tx;
      double xe = math.ceil(right / stepping) * stepping;
      double ys = Math.floor((top - ty) / stepping) * stepping + ty;
      double ye = math.ceil(bottom / stepping) * stepping;

      switch (style) {
        case GRID_STYLE_CROSS:
          {
            // Sets the dot size
            int cs = (stepping > 16.0) ? 2 : 1;

            for (double x = xs; x <= xe; x += stepping) {
              for (double y = ys; y <= ye; y += stepping) {
                // FIXME: Workaround for rounding errors when adding
                // stepping to
                // xs or ys multiple times (leads to double grid lines
                // when zoom
                // is set to eg. 121%)
                x = math.round((x - tx) / stepping) * stepping + tx;
                y = math.round((y - ty) / stepping) * stepping + ty;

                int ix = math.round(x) as int;
                int iy = math.round(y) as int;
                g.drawLine(ix - cs, iy, ix + cs, iy);
                g.drawLine(ix, iy - cs, ix, iy + cs);
              }
            }

            break;
          }
        case GRID_STYLE_LINE:
          {
            xe += math.ceil(stepping) as int;
            ye += math.ceil(stepping) as int;

            int ixs = math.round(xs) as int;
            int ixe = math.round(xe) as int;
            int iys = math.round(ys) as int;
            int iye = math.round(ye) as int;

            for (double x = xs; x <= xe; x += stepping) {
              // FIXME: Workaround for rounding errors when adding
              // stepping to
              // xs or ys multiple times (leads to double grid lines when
              // zoom
              // is set to eg. 121%)
              x = math.round((x - tx) / stepping) * stepping + tx;

              int ix = math.round(x) as int;
              g.drawLine(ix, iys, ix, iye);
            }

            for (double y = ys; y <= ye; y += stepping) {

              // FIXME: Workaround for rounding errors when adding
              // stepping to
              // xs or ys multiple times (leads to double grid lines when
              // zoom
              // is set to eg. 121%)
              y = math.round((y - ty) / stepping) * stepping + ty;

              int iy = math.round(y) as int;
              g.drawLine(ixs, iy, ixe, iy);
            }

            break;
          }
        case GRID_STYLE_DASHED:
          {
            Graphics2D g2 = g as Graphics2D;
            Stroke stroke = g2.getStroke();

            xe += math.ceil(stepping) as int;
            ye += math.ceil(stepping) as int;

            int ixs = math.round(xs) as int;
            int ixe = math.round(xe) as int;
            int iys = math.round(ys) as int;
            int iye = math.round(ye) as int;

            // Creates a set of strokes with individual dash offsets
            // for each direction
            List<Stroke> strokes = [new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [3.0, 1.0], Math.max(0, iys) % 4), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [2.0, 2.0], Math.max(0, iys) % 4), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [1.0, 1.0], 0), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [2.0, 2.0], Math.max(0, iys) % 4)];

            for (double x = xs; x <= xe; x += stepping) {
              g2.setStroke(strokes[((x / stepping) as int) % strokes.length]);

              // FIXME: Workaround for rounding errors when adding
              // stepping to
              // xs or ys multiple times (leads to double grid lines when
              // zoom
              // is set to eg. 121%)
              double xx = math.round((x - tx) / stepping) * stepping + tx;

              int ix = math.round(xx) as int;
              g.drawLine(ix, iys, ix, iye);
            }

            strokes = [new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [3.0, 1.0], Math.max(0, ixs) % 4), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [2.0, 2.0], Math.max(0, ixs) % 4), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [1.0, 1.0], 0), new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 1, [2.0, 2.0], Math.max(0, ixs) % 4)];

            for (double y = ys; y <= ye; y += stepping) {
              g2.setStroke(strokes[((y / stepping) as int) % strokes.length]);

              // FIXME: Workaround for rounding errors when adding
              // stepping to
              // xs or ys multiple times (leads to double grid lines when
              // zoom
              // is set to eg. 121%)
              double yy = math.round((y - ty) / stepping) * stepping + ty;

              int iy = math.round(yy) as int;
              g.drawLine(ixs, iy, ixe, iy);
            }

            g2.setStroke(stroke);

            break;
          }
        default: // DOT_GRID_MODE
          {
            for (double x = xs; x <= xe; x += stepping) {

              for (double y = ys; y <= ye; y += stepping) {
                // FIXME: Workaround for rounding errors when adding
                // stepping to
                // xs or ys multiple times (leads to double grid lines
                // when zoom
                // is set to eg. 121%)
                x = math.round((x - tx) / stepping) * stepping + tx;
                y = math.round((y - ty) / stepping) * stepping + ty;

                int ix = math.round(x) as int;
                int iy = math.round(y) as int;
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
  void redraw(CellState state) {
    if (state != null) {
      awt.Rectangle dirty = state.getBoundingBox().getRectangle();
      repaintTripleBuffer(new awt.Rectangle(dirty));
      dirty = SwingUtilities.convertRectangle(_graphControl, dirty, this);
      repaint(dirty);
    }
  }

  /**
	 * Checks if the triple buffer exists and creates a new one if it does not.
	 * Also compares the size of the buffer with the size of the graph and drops
	 * the buffer if it has a different size.
	 */
  void checkTripleBuffer() {
    Rect bounds = _graph.getGraphBounds();
    int width = math.ceil(bounds.getX() + bounds.getWidth() + 2) as int;
    int height = math.ceil(bounds.getY() + bounds.getHeight() + 2) as int;

    if (_tripleBuffer != null) {
      if (_tripleBuffer.getWidth() != width || _tripleBuffer.getHeight() != height) {
        // Resizes the buffer (destroys existing and creates new)
        destroyTripleBuffer();
      }
    }

    if (_tripleBuffer == null) {
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
  void _createTripleBuffer(int width, int height) {
    try {
      _tripleBuffer = Utils.createBufferedImage(width, height, null);
      _tripleBufferGraphics = _tripleBuffer.createGraphics();
      Utils.setAntiAlias(_tripleBufferGraphics, _antiAlias, _textAntiAlias);

      // Repaints the complete buffer
      repaintTripleBuffer(null);
    } on OutOfMemoryError catch (error) {
      // ignore
    }
  }

  /**
	 * Destroys the tripleBuffer and tripleBufferGraphics objects.
	 */
  void destroyTripleBuffer() {
    if (_tripleBuffer != null) {
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
  void repaintTripleBuffer(awt.Rectangle dirty) {
    if (_tripleBuffered && _tripleBufferGraphics != null) {
      if (dirty == null) {
        dirty = new awt.Rectangle(_tripleBuffer.getWidth(), _tripleBuffer.getHeight());
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
  bool isEventsEnabled() {
    return _eventSource.isEventsEnabled();
  }

  /**
	 * @param eventsEnabled
	 * @see graph.util.EventSource#setEventsEnabled(boolean)
	 */
  void setEventsEnabled(bool eventsEnabled) {
    _eventSource.setEventsEnabled(eventsEnabled);
  }

  /**
	 * @param eventName
	 * @param listener
	 * @see graph.util.EventSource#addListener(java.lang.String,
	 *      graph.util.EventSource.IEventListener)
	 */
  void addListener(String eventName, IEventListener listener) {
    _eventSource.addListener(eventName, listener);
  }

  /**
	 * @param listener
	 *            Listener instance.
	 */
  //	void removeListener(IEventListener listener)
  //	{
  //		_eventSource.removeListener(listener);
  //	}

  /**
	 * @param eventName
	 *            Name of the event.
	 * @param listener
	 *            Listener instance.
	 */
  void removeListener(IEventListener listener, [String eventName = null]) {
    _eventSource.removeListener(listener, eventName);
  }

}

class DoubleClickMouseAdapter extends MouseAdapter {
  /**
     *
     */
  final GraphComponent graphComponent;

  /**
     * @param mxGraphComponent
     */
  DoubleClickMouseAdapter(this.graphComponent);


  void mouseReleased(MouseEvent e) {
    if (graphComponent.isEnabled()) {
      if (!e.isConsumed() && graphComponent.isEditEvent(e)) {
        Object cell = graphComponent.getCellAt(e.getX(), e.getY(), false);

        if (cell != null && graphComponent.getGraph().isCellEditable(cell)) {
          graphComponent.startEditingAtCell(cell, e);
        }
      } else {
        // Other languages use focus traversal here, in Java
        // we explicitely stop editing after a click elsewhere
        graphComponent.stopEditing(!graphComponent.invokesStopCellEditing);
      }
    }
  }
}

class EscapeKeyAdapter extends KeyAdapter {
  /**
     *
     */
  final GraphComponent graphComponent;

  /**
     * @param mxGraphComponent
     */
  EscapeKeyAdapter(this.graphComponent);

  void keyPressed(KeyEvent e) {
    if (e.getKeyCode() == KeyEvent.VK_ESCAPE && graphComponent.isEscapeEnabled()) {
      graphComponent.escape(e);
    }
  }
}

class FocusMouseAdapter extends MouseAdapter {
  /**
     *
     */
  final mxGraphComponent graphComponent;

  /**
     * @param mxGraphComponent
     */
  FocusMouseAdapter(this.graphComponent);

  void mousePressed(MouseEvent e) {
    if (!graphComponent.hasFocus()) {
      graphComponent.requestFocus();
    }
  }
}

class SelectCellMouseAdapter extends MouseAdapter {

  final GraphComponent graphComponent;
  final Object cell;

  SelectCellMouseAdapter(this.graphComponent, Object cell) {
    this.cell = cell;
  }

  /**
     * Selects the associated cell in the graph
     */
  void mousePressed(MouseEvent e) {
    if (graphComponent.getGraph().isEnabled()) {
      graphComponent.getGraph().setSelectionCell(cell);
    }
  }
}
