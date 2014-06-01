/**
 * Copyright (c) 2008, Gaudenz Alder
 * 
 * Known issue: Drag image size depends on the initial position and may sometimes
 * not align with the grid when dragging. This is because the rounding of the width
 * and height at the initial position may be different than that at the current
 * position as the left and bottom side of the shape must align to the grid lines.
 */
part of graph.swing.handler;

//import java.awt.Graphics;
//import java.awt.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;
//import java.beans.PropertyChangeEvent;
//import java.beans.PropertyChangeListener;
//import java.util.Iterator;
//import java.util.LinkedHashMap;
//import java.util.Map;

//import javax.swing.SwingUtilities;

class SelectionCellsHandler implements MouseListener, MouseMotionListener {

  /**
	 * 
	 */
  //	static final long serialVersionUID = -882368002120921842L;

  /**
	 * Defines the default value for maxHandlers. Default is 100.
	 */
  static int DEFAULT_MAX_HANDLERS = 100;

  /**
	 * Reference to the enclosing graph component.
	 */
  GraphComponent _graphComponent;

  /**
	 * Specifies if this handler is enabled.
	 */
  bool _enabled = true;

  /**
	 * Specifies if this handler is visible.
	 */
  bool _visible = true;

  /**
	 * Reference to the enclosing graph component.
	 */
  awt.Rectangle _bounds = null;

  /**
	 * Defines the maximum number of handlers to paint individually.
	 * Default is DEFAULT_MAX_HANDLES.
	 */
  int _maxHandlers = DEFAULT_MAX_HANDLERS;

  /**
	 * Maps from cells to handlers in the order of the selection cells.
	 */
  /*transient*/ LinkedHashMap<Object, CellHandler> _handlers = new LinkedHashMap<Object, CellHandler>();

  /**
	 * 
	 */
  /*transient*/ IEventListener _refreshHandler = (Object source, EventObj evt) {
    if (isEnabled()) {
      refresh();
    }
  };

  /**
	 * 
	 */
  /*transient*/ PropertyChangeListener _labelMoveHandler = (PropertyChangeEvent evt) {
    if (evt.getPropertyName().equals("vertexLabelsMovable") || evt.getPropertyName().equals("edgeLabelsMovable")) {
      refresh();
    }
  };

  /**
	 * 
	 * @param graphComponent
	 */
  SelectionCellsHandler(final GraphComponent graphComponent) {
    this._graphComponent = graphComponent;

    // Listens to all mouse events on the rendering control
    graphComponent.getGraphControl().addMouseListener(this);
    graphComponent.getGraphControl().addMouseMotionListener(this);

    // Installs the graph listeners and keeps them in sync
    _addGraphListeners(graphComponent.getGraph());

    graphComponent.addPropertyChangeListener((PropertyChangeEvent evt) {
      if (evt.getPropertyName().equals("graph")) {
        _removeGraphListeners(evt.getOldValue() as Graph);
        _addGraphListeners(evt.getNewValue() as Graph);
      }
    });

    // Installs the paint handler
    graphComponent.addListener(Event.PAINT, (Object sender, EventObj evt) {
      Graphics g = evt.getProperty("g") as Graphics;
      paintHandles(g);
    });
  }

  /**
	 * Installs the listeners to update the handles after any changes.
	 */
  void _addGraphListeners(Graph graph) {
    // LATER: Install change listener for graph model, selection model, view
    if (graph != null) {
      graph.getSelectionModel().addListener(Event.CHANGE, _refreshHandler);
      graph.getModel().addListener(Event.CHANGE, _refreshHandler);
      graph.getView().addListener(Event.SCALE, _refreshHandler);
      graph.getView().addListener(Event.TRANSLATE, _refreshHandler);
      graph.getView().addListener(Event.SCALE_AND_TRANSLATE, _refreshHandler);
      graph.getView().addListener(Event.DOWN, _refreshHandler);
      graph.getView().addListener(Event.UP, _refreshHandler);

      // Refreshes the handles if moveVertexLabels or moveEdgeLabels changes
      graph.addPropertyChangeListener(_labelMoveHandler);
    }
  }

  /**
	 * Removes all installed listeners.
	 */
  void _removeGraphListeners(Graph graph) {
    if (graph != null) {
      graph.getSelectionModel().removeListener(_refreshHandler, Event.CHANGE);
      graph.getModel().removeListener(_refreshHandler, Event.CHANGE);
      graph.getView().removeListener(_refreshHandler, Event.SCALE);
      graph.getView().removeListener(_refreshHandler, Event.TRANSLATE);
      graph.getView().removeListener(_refreshHandler, Event.SCALE_AND_TRANSLATE);
      graph.getView().removeListener(_refreshHandler, Event.DOWN);
      graph.getView().removeListener(_refreshHandler, Event.UP);

      // Refreshes the handles if moveVertexLabels or moveEdgeLabels changes
      graph.removePropertyChangeListener(_labelMoveHandler);
    }
  }

  /**
	 * 
	 */
  GraphComponent getGraphComponent() {
    return _graphComponent;
  }

  /**
	 * 
	 */
  bool isEnabled() {
    return _enabled;
  }

  /**
	 * 
	 */
  void setEnabled(bool value) {
    _enabled = value;
  }

  /**
	 * 
	 */
  bool isVisible() {
    return _visible;
  }

  /**
	 * 
	 */
  void setVisible(bool value) {
    _visible = value;
  }

  /**
	 * 
	 */
  int getMaxHandlers() {
    return _maxHandlers;
  }

  /**
	 * 
	 */
  void setMaxHandlers(int value) {
    _maxHandlers = value;
  }

  /**
	 * 
	 */
  CellHandler getHandler(Object cell) {
    return _handlers.get(cell);
  }

  /**
	 * Dispatches the mousepressed event to the subhandles. This is
	 * called from the connection handler as subhandles have precedence
	 * over the connection handler.
	 */
  void mousePressed(MouseEvent e) {
    if (_graphComponent.isEnabled() && !_graphComponent.isForceMarqueeEvent(e) && isEnabled()) {
      Iterator<CellHandler> it = _handlers.values().iterator();

      while (it.moveNext() && !e.isConsumed()) {
        it.next().mousePressed(e);
      }
    }
  }

  /**
	 * 
	 */
  void mouseMoved(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled()) {
      Iterator<CellHandler> it = _handlers.values().iterator();

      while (it.moveNext() && !e.isConsumed()) {
        it.next().mouseMoved(e);
      }
    }
  }

  /**
	 * 
	 */
  void mouseDragged(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled()) {
      Iterator<CellHandler> it = _handlers.values().iterator();

      while (it.moveNext() && !e.isConsumed()) {
        it.next().mouseDragged(e);
      }
    }
  }

  /**
	 * 
	 */
  void mouseReleased(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled()) {
      Iterator<CellHandler> it = _handlers.values().iterator();

      while (it.moveNext() && !e.isConsumed()) {
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
  String getToolTipText(MouseEvent e) {
    MouseEvent tmp = SwingUtilities.convertMouseEvent(e.getComponent(), e, _graphComponent.getGraphControl());
    Iterator<CellHandler> it = _handlers.values().iterator();
    String tip = null;

    while (it.moveNext() && tip == null) {
      tip = it.next().getToolTipText(tmp);
    }

    return tip;
  }

  /**
	 * 
	 */
  void reset() {
    Iterator<CellHandler> it = _handlers.values().iterator();

    while (it.moveNext()) {
      it.next().reset();
    }
  }

  /**
	 * 
	 */
  void refresh() {
    Graph graph = _graphComponent.getGraph();

    // Creates a new map for the handlers and tries to
    // to reuse existing handlers from the old map
    LinkedHashMap<Object, CellHandler> oldHandlers = _handlers;
    _handlers = new LinkedHashMap<Object, CellHandler>();

    // Creates handles for all selection cells
    List<Object> tmp = graph.getSelectionCells();
    bool handlesVisible = tmp.length <= getMaxHandlers();
    awt.Rectangle handleBounds = null;

    for (int i = 0; i < tmp.length; i++) {
      CellState state = graph.getView().getState(tmp[i]);

      if (state != null && state.getCell() != graph.getView().getCurrentRoot()) {
        CellHandler handler = oldHandlers.remove(tmp[i]);

        if (handler != null) {
          handler.refresh(state);
        } else {
          handler = _graphComponent.createHandler(state);
        }

        if (handler != null) {
          handler.setHandlesVisible(handlesVisible);
          _handlers.put(tmp[i], handler);
          awt.Rectangle bounds = handler.getBounds();
          Stroke stroke = handler.getSelectionStroke();

          if (stroke != null) {
            bounds = stroke.createStrokedShape(bounds).getBounds();
          }

          if (handleBounds == null) {
            handleBounds = bounds;
          } else {
            handleBounds.add(bounds);
          }
        }
      }
    }

    for (CellHandler handler in oldHandlers.values()) {
      handler._destroy();
    }

    awt.Rectangle dirty = _bounds;

    if (handleBounds != null) {
      if (dirty != null) {
        dirty.add(handleBounds);
      } else {
        dirty = handleBounds;
      }
    }

    if (dirty != null) {
      _graphComponent.getGraphControl().repaint(dirty);
    }

    // Stores current bounds for later use
    _bounds = handleBounds;
  }

  /**
	 * 
	 */
  void paintHandles(Graphics g) {
    Iterator<CellHandler> it = _handlers.values().iterator();

    while (it.moveNext()) {
      it.next().paint(g);
    }
  }

  /*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
	 */
  void mouseClicked(MouseEvent arg0) {
    // empty
  }

  /*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
  void mouseEntered(MouseEvent arg0) {
    // empty
  }

  /*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
  void mouseExited(MouseEvent arg0) {
    // empty
  }

}
