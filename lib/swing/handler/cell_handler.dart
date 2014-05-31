/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.MouseEvent;

//import javax.swing.JComponent;

/**
 * @author Administrator
 * 
 */
class CellHandler {
  /**
	 * Reference to the enclosing graph component.
	 */
  GraphComponent _graphComponent;

  /**
	 * Holds the cell state associated with this handler.
	 */
  CellState _state;

  /**
	 * Holds the rectangles that define the handles.
	 */
  List<harmony.Rectangle> _handles;

  /**
	 * Specifies if the handles should be painted. Default is true.
	 */
  bool _handlesVisible = true;

  /**
	 * Holds the bounding box of the handler.
	 */
  /*transient*/ harmony.Rectangle _bounds;

  /**
	 * Holds the component that is used for preview.
	 */
  /*transient*/ JComponent _preview;

  /**
	 * Holds the start location of the mouse gesture.
	 */
  /*transient*/ harmony.Point _first;

  /**
	 * Holds the index of the handle that was clicked.
	 */
  /*transient*/ int _index;

  /**
	 * Constructs a new cell handler for the given cell state.
	 * 
	 * @param graphComponent Enclosing graph component.
	 * @param state Cell state for which the handler is created.
	 */
  CellHandler(GraphComponent graphComponent, CellState state) {
    this._graphComponent = graphComponent;
    refresh(state);
  }

  /**
	 * 
	 */
  bool isActive() {
    return _first != null;
  }

  /**
	 * Refreshes the cell handler.
	 */
  void refresh(CellState state) {
    this._state = state;
    _handles = _createHandles();
    Graph graph = _graphComponent.getGraph();
    Rect tmp = graph.getBoundingBox(state.getCell());

    if (tmp != null) {
      _bounds = tmp.getRectangle();

      if (_handles != null) {
        for (int i = 0; i < _handles.length; i++) {
          if (_isHandleVisible(i)) {
            _bounds.add(_handles[i]);
          }
        }
      }
    }
  }

  /**
	 * 
	 */
  GraphComponent getGraphComponent() {
    return _graphComponent;
  }

  /**
	 * Returns the cell state that is associated with this handler.
	 */
  CellState getState() {
    return _state;
  }

  /**
	 * Returns the index of the current handle.
	 */
  int getIndex() {
    return _index;
  }

  /**
	 * Returns the bounding box of this handler.
	 */
  harmony.Rectangle getBounds() {
    return _bounds;
  }

  /**
	 * Returns true if the label is movable.
	 */
  bool isLabelMovable() {
    Graph graph = _graphComponent.getGraph();
    String label = graph.getLabel(_state.getCell());

    return graph.isLabelMovable(_state.getCell()) && label != null && label.length > 0;
  }

  /**
	 * Returns true if the handles should be painted.
	 */
  bool isHandlesVisible() {
    return _handlesVisible;
  }

  /**
	 * Specifies if the handles should be painted.
	 */
  void setHandlesVisible(bool handlesVisible) {
    this._handlesVisible = handlesVisible;
  }

  /**
	 * Returns true if the given index is the index of the last handle.
	 */
  bool isLabel(int index) {
    return index == _getHandleCount() - 1;
  }

  /**
	 * Creates the rectangles that define the handles.
	 */
  List<harmony.Rectangle> _createHandles() {
    return null;
  }

  /**
	 * Returns the number of handles in this handler.
	 */
  int _getHandleCount() {
    return (_handles != null) ? _handles.length : 0;
  }

  /**
	 * Hook for subclassers to return tooltip texts for certain points on the
	 * handle.
	 */
  String getToolTipText(MouseEvent e) {
    return null;
  }

  /**
	 * Returns the index of the handle at the given location.
	 * 
	 * @param x X-coordinate of the location.
	 * @param y Y-coordinate of the location.
	 * @return Returns the handle index for the given location.
	 */
  int getIndexAt(int x, int y) {
    if (_handles != null && isHandlesVisible()) {
      int tol = _graphComponent.getTolerance();
      harmony.Rectangle rect = new harmony.Rectangle(x - tol / 2, y - tol / 2, tol, tol);

      for (int i = _handles.length - 1; i >= 0; i--) {
        if (_isHandleVisible(i) && _handles[i].intersects(rect)) {
          return i;
        }
      }
    }

    return -1;
  }

  /**
	 * Processes the given event.
	 */
  void mousePressed(MouseEvent e) {
    if (!e.isConsumed()) {
      int tmp = getIndexAt(e.getX(), e.getY());

      if (!_isIgnoredEvent(e) && tmp >= 0 && _isHandleEnabled(tmp)) {
        _graphComponent.stopEditing(true);
        start(e, tmp);
        e.consume();
      }
    }
  }

  /**
	 * Processes the given event.
	 */
  void mouseMoved(MouseEvent e) {
    if (!e.isConsumed() && _handles != null) {
      int index = getIndexAt(e.getX(), e.getY());

      if (index >= 0 && _isHandleEnabled(index)) {
        Cursor cursor = _getCursor(e, index);

        if (cursor != null) {
          _graphComponent.getGraphControl().setCursor(cursor);
          e.consume();
        } else {
          _graphComponent.getGraphControl().setCursor(new Cursor(Cursor.HAND_CURSOR));
        }
      }
    }
  }

  /**
	 * Processes the given event.
	 */
  void mouseDragged(MouseEvent e) {
    // empty
  }

  /**
	 * Processes the given event.
	 */
  void mouseReleased(MouseEvent e) {
    reset();
  }

  /**
	 * Starts handling a gesture at the given handle index.
	 */
  void start(MouseEvent e, int index) {
    this._index = index;
    _first = e.getPoint();
    _preview = _createPreview();

    if (_preview != null) {
      _graphComponent.getGraphControl().add(_preview, 0);
    }
  }

  /**
	 * Returns true if the given event should be ignored.
	 */
  bool _isIgnoredEvent(MouseEvent e) {
    return _graphComponent.isEditEvent(e);
  }

  /**
	 * Creates the preview for this handler.
	 */
  JComponent _createPreview() {
    return null;
  }

  /**
	 * Resets the state of the handler and removes the preview.
	 */
  void reset() {
    if (_preview != null) {
      _preview.setVisible(false);
      _preview.getParent().remove(_preview);
      _preview = null;
    }

    _first = null;
  }

  /**
	 * Returns the cursor for the given event and handle.
	 */
  Cursor _getCursor(MouseEvent e, int index) {
    return null;
  }

  /**
	 * Paints the visible handles of this handler.
	 */
  void paint(Graphics g) {
    if (_handles != null && isHandlesVisible()) {
      for (int i = 0; i < _handles.length; i++) {
        if (_isHandleVisible(i) && g.hitClip(_handles[i].x, _handles[i].y, _handles[i].width, _handles[i].height)) {
          g.setColor(_getHandleFillColor(i));
          g.fillRect(_handles[i].x, _handles[i].y, _handles[i].width, _handles[i].height);

          g.setColor(_getHandleBorderColor(i));
          g.drawRect(_handles[i].x, _handles[i].y, _handles[i].width - 1, _handles[i].height - 1);
        }
      }
    }
  }

  /**
	 * Returns the color used to draw the selection border. This implementation
	 * returns null.
	 */
  Color getSelectionColor() {
    return null;
  }

  /**
	 * Returns the stroke used to draw the selection border. This implementation
	 * returns null.
	 */
  Stroke getSelectionStroke() {
    return null;
  }

  /**
	 * Returns true if the handle at the specified index is enabled.
	 */
  bool _isHandleEnabled(int index) {
    return true;
  }

  /**
	 * Returns true if the handle at the specified index is visible.
	 */
  bool _isHandleVisible(int index) {
    return !isLabel(index) || isLabelMovable();
  }

  /**
	 * Returns the color to be used to fill the handle at the specified index.
	 */
  Color _getHandleFillColor(int index) {
    if (isLabel(index)) {
      return SwingConstants.LABEL_HANDLE_FILLCOLOR;
    }

    return SwingConstants.HANDLE_FILLCOLOR;
  }

  /**
	 * Returns the border color of the handle at the specified index.
	 */
  Color _getHandleBorderColor(int index) {
    return SwingConstants.HANDLE_BORDERCOLOR;
  }

  /**
	 * Invoked when the handler is no longer used. This is an empty
	 * hook for subclassers.
	 */
  void _destroy() {
    // nop
  }

}
