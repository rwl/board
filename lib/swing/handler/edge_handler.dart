/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.harmony.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.MouseEvent;
//import java.awt.geom.harmony.Line2D;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.List;

//import javax.swing.JComponent;
//import javax.swing.JOptionPane;
//import javax.swing.JPanel;

/**
 *
 */
class EdgeHandler extends CellHandler {
  /**
	 * 
	 */
  bool _cloneEnabled = true;

  /**
	 * 
	 */
  PoList<int> _p;

  /**
	 * 
	 */
  /*transient*/ String _error;

  /**
	 * Workaround for alt-key-state not correct in mouseReleased.
	 */
  /*transient*/ bool _gridEnabledEvent = false;

  /**
	 * Workaround for shift-key-state not correct in mouseReleased.
	 */
  /*transient*/ bool _constrainedEvent = false;

  /**
	 * 
	 */
  CellMarker _marker;

  /**
	 * 
	 * @param graphComponent
	 * @param state
	 */
  EdgeHandler(GraphComponent graphComponent, CellState state) : super(graphComponent, state) {
    _marker = new EdgeHandlerCellMarker(this, graphComponent);
  }

  /**
	 * 
	 */
  void setCloneEnabled(bool cloneEnabled) {
    this._cloneEnabled = cloneEnabled;
  }

  /**
	 * 
	 */
  bool isCloneEnabled() {
    return _cloneEnabled;
  }

  /**
	 * No flip event is ignored.
	 */
  bool _isIgnoredEvent(MouseEvent e) {
    return !_isFlipEvent(e) && super._isIgnoredEvent(e);
  }

  /**
	 * 
	 */
  bool _isFlipEvent(MouseEvent e) {
    return false;
  }

  /**
	 * Returns the error message or an empty string if the connection for the
	 * given source target pair is not valid. Otherwise it returns null.
	 */
  String validateConnection(Object source, Object target) {
    return _graphComponent.getGraph().getEdgeValidationError(_state.getCell(), source, target);
  }

  /**
	 * Returns true if the current index is 0.
	 */
  bool isSource(int index) {
    return index == 0;
  }

  /**
	 * Returns true if the current index is the last index.
	 */
  bool isTarget(int index) {
    return index == _getHandleCount() - 2;
  }

  /**
	 * Hides the middle handle if the edge is not bendable.
	 */
  bool _isHandleVisible(int index) {
    return super._isHandleVisible(index) && (isSource(index) || isTarget(index) || _isCellBendable());
  }

  /**
	 * 
	 */
  bool _isCellBendable() {
    return _graphComponent.getGraph().isCellBendable(_state.getCell());
  }

  /**
	 * 
	 */
  List<harmony.Rectangle> _createHandles() {
    _p = _createPoints(_state);
    List<harmony.Rectangle> h = new List<harmony.Rectangle>(_p.length + 1);

    for (int i = 0; i < h.length - 1; i++) {
      h[i] = _createHandle(_p[i]);
    }

    h[_p.length] = _createHandle(_state.getAbsoluteOffset().getPoint(), Constants.LABEL_HANDLE_SIZE);

    return h;
  }

  /**
	 * 
	 */
  Color _getHandleFillColor(int index) {
    bool source = isSource(index);

    if (source || isTarget(index)) {
      Graph graph = _graphComponent.getGraph();
      Object terminal = graph.getModel().getTerminal(_state.getCell(), source);

      if (terminal == null && !_graphComponent.getGraph().isTerminalPointMovable(_state.getCell(), source)) {
        return SwingConstants.LOCKED_HANDLE_FILLCOLOR;
      } else if (terminal != null) {
        return (_graphComponent.getGraph().isCellDisconnectable(_state.getCell(), terminal, source)) ? SwingConstants.CONNECT_HANDLE_FILLCOLOR : SwingConstants.LOCKED_HANDLE_FILLCOLOR;
      }
    }

    return super._getHandleFillColor(index);
  }

  /**
	 * 
	 * @param x
	 * @param y
	 * @return Returns the inde of the handle at the given location.
	 */
  int getIndexAt(int x, int y) {
    int index = super.getIndexAt(x, y);

    // Makes the complete label a trigger for the label handle
    if (index < 0 && _handles != null && _handlesVisible && isLabelMovable() && _state.getLabelBounds().getRectangle().contains(x, y)) {
      index = _handles.length - 1;
    }

    return index;
  }

  /**
	 * 
	 */
  //	harmony.Rectangle _createHandle(harmony.Point center)
  //	{
  //		return _createHandle(center, Constants.HANDLE_SIZE);
  //	}

  /**
	 * 
	 */
  harmony.Rectangle _createHandle(harmony.Point center, [int size = Constants.HANDLE_SIZE]) {
    return new harmony.Rectangle(center.x - size / 2, center.y - size / 2, size, size);
  }

  /**
	 * 
	 */
  PoList<int> _createPoints(CellState s) {
    List<harmony.Point> pts = new List<harmony.Point>(s.getAbsolutePointCount());

    for (int i = 0; i < pts.length; i++) {
      pts[i] = s.getAbsolutePoint(i).getPoint();
    }

    return pts;
  }

  /**
	 * 
	 */
  JComponent _createPreview() {
    throw new Exception();
    /*JPanel preview = new JPanel()
		{
			public void paint(Graphics g)
			{
				super.paint(g);

				if (!isLabel(_index) && _p != null)
				{
					((Graphics2D) g).setStroke(SwingConstants.PREVIEW_STROKE);

					if (isSource(_index) || isTarget(_index))
					{
						if (_marker.hasValidState()
								|| _graphComponent.getGraph()
										.isAllowDanglingEdges())
						{
							g.setColor(SwingConstants.DEFAULT_VALID_COLOR);
						}
						else
						{
							g.setColor(SwingConstants.DEFAULT_INVALID_COLOR);
						}
					}
					else
					{
						g.setColor(Color.BLACK);
					}

					harmony.Point origin = getLocation();
					harmony.Point last = _p[0];

					for (int i = 1; i < _p.length; i++)
					{
						g.drawLine(last.x - origin.x, last.y - origin.y, _p[i].x
								- origin.x, _p[i].y - origin.y);
						last = _p[i];
					}
				}
			}
		};*/

    if (isLabel(_index)) {
      preview.setBorder(SwingConstants.PREVIEW_BORDER);
    }

    preview.setOpaque(false);
    preview.setVisible(false);

    return preview;
  }

  /**
	 * 
	 * @param point
	 * @param gridEnabled
	 * @return Returns the scaled, translated and grid-aligned point.
	 */
  Point2d _convertPoint(Point2d point, bool gridEnabled) {
    Graph graph = _graphComponent.getGraph();
    double scale = graph.getView().getScale();
    Point2d trans = graph.getView().getTranslate();
    double x = point.getX() / scale - trans.getX();
    double y = point.getY() / scale - trans.getY();

    if (gridEnabled) {
      x = graph.snap(x);
      y = graph.snap(y);
    }

    point.setX(x - _state.getOrigin().getX());
    point.setY(y - _state.getOrigin().getY());

    return point;
  }

  /**
	 * 
	 * @return Returns the bounds of the preview.
	 */
  harmony.Rectangle _getPreviewBounds() {
    harmony.Rectangle bounds = null;

    if (isLabel(_index)) {
      bounds = _state.getLabelBounds().getRectangle();
    } else {
      bounds = new harmony.Rectangle(_p[0]);

      for (int i = 0; i < _p.length; i++) {
        bounds.add(_p[i]);
      }

      bounds.height += 1;
      bounds.width += 1;
    }

    return bounds;
  }

  /**
	 * 
	 */
  void mousePressed(MouseEvent e) {
    super.mousePressed(e);

    bool source = isSource(_index);

    if (source || isTarget(_index)) {
      Graph graph = _graphComponent.getGraph();
      IGraphModel model = graph.getModel();
      Object terminal = model.getTerminal(_state.getCell(), source);

      if ((terminal == null && !graph.isTerminalPointMovable(_state.getCell(), source)) || (terminal != null && !graph.isCellDisconnectable(_state.getCell(), terminal, source))) {
        _first = null;
      }
    }
  }

  /**
	 * 
	 */
  void mouseDragged(MouseEvent e) {
    if (!e.isConsumed() && _first != null) {
      _gridEnabledEvent = _graphComponent.isGridEnabledEvent(e);
      _constrainedEvent = _graphComponent.isConstrainedEvent(e);

      bool _isSource = isSource(_index);
      bool _isTarget = isTarget(_index);

      Object source = null;
      Object target = null;

      if (isLabel(_index)) {
        Point2d abs = _state.getAbsoluteOffset();
        double dx = abs.getX() - _first.x;
        double dy = abs.getY() - _first.y;

        Point2d pt = new Point2d(e.getPoint());

        if (_gridEnabledEvent) {
          pt = _graphComponent.snapScaledPoint(pt, dx, dy);
        }

        if (_constrainedEvent) {
          if (math.abs(e.getX() - _first.x) > math.abs(e.getY() - _first.y)) {
            pt.setY(abs.getY());
          } else {
            pt.setX(abs.getX());
          }
        }

        harmony.Rectangle rect = _getPreviewBounds();
        rect.translate(math.round(pt.getX() - _first.x) as int, math.round(pt.getY() - _first.y) as int);
        _preview.setBounds(rect);
      } else {
        // Clones the cell state and updates the absolute points using
        // the current state of this handle. This is required for
        // computing the correct perimeter points and edge style.
        Geometry geometry = _graphComponent.getGraph().getCellGeometry(_state.getCell());
        CellState clone = _state.clone() as CellState;
        List<Point2d> points = geometry.getPoints();
        GraphView view = clone.getView();

        if (_isSource || _isTarget) {
          _marker.process(e);
          CellState currentState = _marker.getValidState();
          target = _state.getVisibleTerminal(!isSource);

          if (currentState != null) {
            source = currentState.getCell();
          } else {
            Point2d pt = new Point2d(e.getPoint());

            if (_gridEnabledEvent) {
              pt = _graphComponent.snapScaledPoint(pt);
            }

            clone.setAbsoluteTerminalPoint(pt, isSource);
          }

          if (!isSource) {
            Object tmp = source;
            source = target;
            target = tmp;
          }
        } else {
          Point2d point = _convertPoint(new Point2d(e.getPoint()), _gridEnabledEvent);

          if (points == null) {
            points = Arrays.asList([point]);
          } else if (_index - 1 < points.length) {
            points = new List<Point2d>(points);
            points.set(_index - 1, point);
          }

          source = view.getVisibleTerminal(_state.getCell(), true);
          target = view.getVisibleTerminal(_state.getCell(), false);
        }

        // Computes the points for the edge style and terminals
        CellState sourceState = view.getState(source);
        CellState targetState = view.getState(target);

        ConnectionConstraint sourceConstraint = _graphComponent.getGraph().getConnectionConstraint(clone, sourceState, true);
        ConnectionConstraint targetConstraint = _graphComponent.getGraph().getConnectionConstraint(clone, targetState, false);

        /* TODO: Implement mxConstraintHandler
				ConnectionConstraint constraint = constraintHandler.currentConstraint;

				if (constraint == null)
				{
					constraint = new ConnectionConstraint();
				}
				
				if (isSource)
				{
					sourceConstraint = constraint;
				}
				else if (isTarget)
				{
					targetConstraint = constraint;
				}
				*/

        if (!_isSource || sourceState != null) {
          view.updateFixedTerminalPoint(clone, sourceState, true, sourceConstraint);
        }

        if (!_isTarget || targetState != null) {
          view.updateFixedTerminalPoint(clone, targetState, false, targetConstraint);
        }

        view.updatePoints(clone, points, sourceState, targetState);
        view.updateFloatingTerminalPoints(clone, sourceState, targetState);

        // Uses the updated points from the cloned state to draw the preview
        _p = _createPoints(clone);
        _preview.setBounds(_getPreviewBounds());
      }

      if (!_preview.isVisible() && _graphComponent.isSignificant(e.getX() - _first.x, e.getY() - _first.y)) {
        _preview.setVisible(true);
      } else if (_preview.isVisible()) {
        _preview.repaint();
      }

      e.consume();
    }
  }

  /**
	 * 
	 */
  void mouseReleased(MouseEvent e) {
    Graph graph = _graphComponent.getGraph();

    if (!e.isConsumed() && _first != null) {
      double dx = e.getX() - _first.x;
      double dy = e.getY() - _first.y;

      if (_graphComponent.isSignificant(dx, dy)) {
        if (_error != null) {
          if (_error.length > 0) {
            JOptionPane.showMessageDialog(_graphComponent, _error);
          }
        } else if (isLabel(_index)) {
          Point2d abs = _state.getAbsoluteOffset();
          dx = abs.getX() - _first.x;
          dy = abs.getY() - _first.y;

          Point2d pt = new Point2d(e.getPoint());

          if (_gridEnabledEvent) {
            pt = _graphComponent.snapScaledPoint(pt, dx, dy);
          }

          if (_constrainedEvent) {
            if (math.abs(e.getX() - _first.x) > math.abs(e.getY() - _first.y)) {
              pt.setY(abs.getY());
            } else {
              pt.setX(abs.getX());
            }
          }

          _moveLabelTo(_state, pt.getX() + dx, pt.getY() + dy);
        } else if (_marker.hasValidState() && (isSource(_index) || isTarget(_index))) {
          _connect(_state.getCell(), _marker.getValidState().getCell(), isSource(_index), _graphComponent.isCloneEvent(e) && isCloneEnabled());
        } else if ((!isSource(_index) && !isTarget(_index)) || _graphComponent.getGraph().isAllowDanglingEdges()) {
          _movePoint(_state.getCell(), _index, _convertPoint(new Point2d(e.getPoint()), _gridEnabledEvent));
        }

        e.consume();
      }
    }

    if (!e.isConsumed() && _isFlipEvent(e)) {
      graph.flipEdge(_state.getCell());
      e.consume();
    }

    super.mouseReleased(e);
  }

  /**
	 * Extends the implementation to reset the current error and marker.
	 */
  void reset() {
    super.reset();

    _marker.reset();
    _error = null;
  }

  /**
	 * Moves the edges control point with the given index to the given point.
	 */
  void _movePoint(Object edge, int pointIndex, Point2d point) {
    IGraphModel model = _graphComponent.getGraph().getModel();
    Geometry geometry = model.getGeometry(edge);

    if (geometry != null) {
      model.beginUpdate();
      try {
        geometry = geometry.clone() as Geometry;

        if (isSource(_index) || isTarget(_index)) {
          _connect(edge, null, isSource(_index), false);
          geometry.setTerminalPoint(point, isSource(_index));
        } else {
          List<Point2d> pts = geometry.getPoints();

          if (pts == null) {
            pts = new List<Point2d>();
            geometry.setPoints(pts);
          }

          if (pts != null) {
            if (pointIndex <= pts.length) {
              pts.set(pointIndex - 1, point);
            } else if (pointIndex - 1 <= pts.length) {
              pts.add(pointIndex - 1, point);
            }
          }
        }

        model.setGeometry(edge, geometry);
      } finally {
        model.endUpdate();
      }
    }
  }

  /**
	 * Connects the given edge to the given source or target terminal.
	 * 
	 * @param edge
	 * @param terminal
	 * @param isSource
	 */
  void _connect(Object edge, Object terminal, bool isSource, bool isClone) {
    Graph graph = _graphComponent.getGraph();
    IGraphModel model = graph.getModel();

    model.beginUpdate();
    try {
      if (isClone) {
        Object clone = graph.cloneCells([edge])[0];

        Object parent = model.getParent(edge);
        graph.addCells([clone], parent);

        Object other = model.getTerminal(edge, !isSource);
        graph.connectCell(clone, other, !isSource);

        graph.setSelectionCell(clone);
        edge = clone;
      }

      // Passes an empty constraint to reset constraint information
      graph.connectCell(edge, terminal, isSource, new ConnectionConstraint());
    } finally {
      model.endUpdate();
    }
  }

  /**
	 * Moves the label to the given position.
	 */
  void _moveLabelTo(CellState edgeState, double x, double y) {
    Graph graph = _graphComponent.getGraph();
    IGraphModel model = graph.getModel();
    Geometry geometry = model.getGeometry(_state.getCell());

    if (geometry != null) {
      geometry = geometry.clone() as Geometry;

      // Resets the relative location stored inside the geometry
      Point2d pt = graph.getView().getRelativePoint(edgeState, x, y);
      geometry.setX(pt.getX());
      geometry.setY(pt.getY());

      // Resets the offset inside the geometry to find the offset
      // from the resulting point
      double scale = graph.getView().getScale();
      geometry.setOffset(new Point2d(0, 0));
      pt = graph.getView().getPoint(edgeState, geometry);
      geometry.setOffset(new Point2d(math.round((x - pt.getX()) / scale), math.round((y - pt.getY()) / scale)));

      model.setGeometry(edgeState.getCell(), geometry);
    }
  }

  /**
	 * 
	 */
  Cursor _getCursor(MouseEvent e, int index) {
    Cursor cursor = null;

    if (isLabel(index)) {
      cursor = new Cursor(Cursor.MOVE_CURSOR);
    } else {
      cursor = new Cursor(Cursor.HAND_CURSOR);
    }

    return cursor;
  }

  /**
	 * 
	 */
  Color getSelectionColor() {
    return SwingConstants.EDGE_SELECTION_COLOR;
  }

  /**
	 * 
	 */
  Stroke getSelectionStroke() {
    return SwingConstants.EDGE_SELECTION_STROKE;
  }

  /**
	 * 
	 */
  void paint(Graphics g) {
    Graphics2D g2 = g as Graphics2D;

    Stroke stroke = g2.getStroke();
    g2.setStroke(getSelectionStroke());
    g.setColor(getSelectionColor());

    harmony.Point last = _state.getAbsolutePoint(0).getPoint();

    for (int i = 1; i < _state.getAbsolutePointCount(); i++) {
      harmony.Point current = _state.getAbsolutePoint(i).getPoint();
      harmony.Line2D line = new harmony.Line2D.Float(last.x, last.y, current.x, current.y);

      harmony.Rectangle bounds = g2.getStroke().createStrokedShape(line).getBounds();

      if (g.hitClip(bounds.x, bounds.y, bounds.width, bounds.height)) {
        g2.draw(line);
      }

      last = current;
    }

    g2.setStroke(stroke);
    super.paint(g);
  }

}

class EdgeHandlerCellMarker extends CellMarker {

  final mxEdgeHandler edgeHandler;

  //    private static final long serialVersionUID = 8826073441093831764L;

  EdgeHandlerCellMarker(EdgeHandler mxEdgeHandler, GraphComponent graphComponent) : super(graphComponent) {
    edgeHandler = mxEdgeHandler;
  }

  // Only returns edges if they are connectable and never returns
  // the edge that is currently being modified
  Object getCell(MouseEvent e) {
    mxGraph graph = graphComponent.getGraph();
    mxIGraphModel model = graph.getModel();
    Object cell = super.getCell(e);

    if (cell == edgeHandler.state.getCell() || (!graph.isConnectableEdges() && model.isEdge(cell))) {
      cell = null;
    }

    return cell;
  }

  // Sets the highlight color according to isValidConnection
  boolean isValidState(mxCellState state) {
    mxGraphView view = graphComponent.getGraph().getView();
    mxIGraphModel model = graphComponent.getGraph().getModel();
    Object edge = edgeHandler.state.getCell();
    boolean isSource = edgeHandler.isSource(edgeHandler.index);

    mxCellState other = view.getTerminalPort(state, view.getState(model.getTerminal(edge, !isSource)), !isSource);
    Object otherCell = (other != null) ? other.getCell() : null;
    Object source = (isSource) ? state.getCell() : otherCell;
    Object target = (isSource) ? otherCell : state.getCell();

    edgeHandler.error = edgeHandler.validateConnection(source, target);

    return edgeHandler.error == null;
  }
}
