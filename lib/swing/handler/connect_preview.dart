/**
 * Copyright (c) 2008-2010, Gaudenz Alder, David Benson
 */
part of graph.swing.handler;

//import java.awt.AlphaComposite;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.awt.Rectangle;
//import java.awt.event.MouseEvent;

/**
 * Connection handler creates new connections between cells. This control is used to display the connector
 * icon, while the preview is used to draw the line.
 */
class ConnectPreview extends EventSource {
  /**
	 * 
	 */
  GraphComponent _graphComponent;

  /**
	 * 
	 */
  CellState _previewState;

  /**
	 * 
	 */
  CellState _sourceState;

  /**
	 * 
	 */
  Point2d _startPoint;

  /**
	 * 
	 * @param graphComponent
	 */
  ConnectPreview(GraphComponent graphComponent) {
    this._graphComponent = graphComponent;

    // Installs the paint handler
    graphComponent.addListener(Event.AFTER_PAINT, (Object sender, EventObj evt) {
      Graphics g = evt.getProperty("g") as Graphics;
      paint(g);
    });
  }

  /**
	 * Creates a new instance of mxShape for previewing the edge.
	 */
  Object _createCell(CellState startState, String style) {
    Graph graph = _graphComponent.getGraph();
    ICell cell = (graph.createEdge(null, null, "", (startState != null) ? startState.getCell() : null, null, style)) as ICell;
    (startState.getCell() as ICell).insertEdge(cell, true);

    return cell;
  }

  /**
	 * 
	 */
  bool isActive() {
    return _sourceState != null;
  }

  /**
	 * 
	 */
  CellState getSourceState() {
    return _sourceState;
  }

  /**
	 * 
	 */
  CellState getPreviewState() {
    return _previewState;
  }

  /**
	 * 
	 */
  Point2d getStartPoint() {
    return _startPoint;
  }

  /**
	 * Updates the style of the edge preview from the incoming edge
	 */
  void start(MouseEvent e, CellState startState, String style) {
    Graph graph = _graphComponent.getGraph();
    _sourceState = startState;
    _startPoint = _transformScreenPoint(startState.getCenterX(), startState.getCenterY());
    Object cell = _createCell(startState, style);
    graph.getView().validateCell(cell);
    _previewState = graph.getView().getState(cell);

    fireEvent(new EventObj(Event.START, "event", e, "state", _previewState));
  }

  /**
	 * 
	 */
  void update(MouseEvent e, CellState targetState, double x, double y) {
    Graph graph = _graphComponent.getGraph();
    ICell cell = _previewState.getCell() as ICell;

    Rect dirty = _graphComponent.getGraph().getPaintBounds([_previewState.getCell()]);

    if (cell.getTerminal(false) != null) {
      cell.getTerminal(false).removeEdge(cell, false);
    }

    if (targetState != null) {
      (targetState.getCell() as ICell).insertEdge(cell, false);
    }

    Geometry geo = graph.getCellGeometry(_previewState.getCell());

    geo.setTerminalPoint(_startPoint, true);
    geo.setTerminalPoint(_transformScreenPoint(x, y), false);

    revalidate(_previewState);
    fireEvent(new EventObj(Event.CONTINUE, "event", e, "x", x, "y", y));

    // Repaints the dirty region
    // TODO: Cache the new dirty region for next repaint
    awt.Rectangle tmp = _getDirtyRect(dirty);

    if (tmp != null) {
      _graphComponent.getGraphControl().repaint(tmp);
    } else {
      _graphComponent.getGraphControl().repaint();
    }
  }

  /**
	 * 
	 */
  //	awt.Rectangle _getDirtyRect()
  //	{
  //		return _getDirtyRect(null);
  //	}

  /**
	 * 
	 */
  awt.Rectangle _getDirtyRect([Rect dirty = null]) {
    if (_previewState != null) {
      Rect tmp = _graphComponent.getGraph().getPaintBounds([_previewState.getCell()]);

      if (dirty != null) {
        dirty.add(tmp);
      } else {
        dirty = tmp;
      }

      if (dirty != null) {
        // TODO: Take arrow size into account
        dirty.grow(2);

        return dirty.getRectangle();
      }
    }

    return null;
  }

  /**
	 * 
	 */
  Point2d _transformScreenPoint(double x, double y) {
    Graph graph = _graphComponent.getGraph();
    Point2d tr = graph.getView().getTranslate();
    double scale = graph.getView().getScale();

    return new Point2d(graph.snap(x / scale - tr.getX()), graph.snap(y / scale - tr.getY()));
  }

  /**
	 * 
	 */
  void revalidate(CellState state) {
    state.getView().invalidate(state.getCell());
    state.getView().validateCellState(state.getCell());
  }

  /**
	 * 
	 */
  void paint(Graphics g) {
    if (_previewState != null) {
      Graphics2DCanvas canvas = _graphComponent.getCanvas();

      if (_graphComponent.isAntiAlias()) {
        Utils.setAntiAlias(g as Graphics2D, true, false);
      }

      float alpha = _graphComponent.getPreviewAlpha();

      if (alpha < 1) {
        (g as Graphics2D).setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, alpha));
      }

      Graphics2D previousGraphics = canvas.getGraphics();
      awt.Point previousTranslate = canvas.getTranslate();
      double previousScale = canvas.getScale();

      try {
        canvas.setScale(_graphComponent.getGraph().getView().getScale());
        canvas.setTranslate(0, 0);
        canvas.setGraphics(g as Graphics2D);

        _paintPreview(canvas);
      } finally {
        canvas.setScale(previousScale);
        canvas.setTranslate(previousTranslate.x, previousTranslate.y);
        canvas.setGraphics(previousGraphics);
      }
    }
  }

  /**
	 * Draws the preview using the graphics canvas.
	 */
  void _paintPreview(Graphics2DCanvas canvas) {
    _graphComponent.getGraphControl().drawCell(_graphComponent.getCanvas(), _previewState.getCell());
  }

  /**
	 *
	 */
  //	Object stop(bool commit)
  //	{
  //		return stop(commit, null);
  //	}

  /**
	 *
	 */
  Object stop(bool commit, [MouseEvent e = null]) {
    Object result = (_sourceState != null) ? _sourceState.getCell() : null;

    if (_previewState != null) {
      Graph graph = _graphComponent.getGraph();

      graph.getModel().beginUpdate();
      try {
        ICell cell = _previewState.getCell() as ICell;
        Object src = cell.getTerminal(true);
        Object trg = cell.getTerminal(false);

        if (src != null) {
          (src as ICell).removeEdge(cell, true);
        }

        if (trg != null) {
          (trg as ICell).removeEdge(cell, false);
        }

        if (commit) {
          result = graph.addCell(cell, null, null, src, trg);
        }

        fireEvent(new EventObj(Event.STOP, "event", e, "commit", commit, "cell", (commit) ? result : null));

        // Clears the state before the model commits
        if (_previewState != null) {
          awt.Rectangle dirty = _getDirtyRect();
          graph.getView().clear(cell, false, true);
          _previewState = null;

          if (!commit && dirty != null) {
            _graphComponent.getGraphControl().repaint(dirty);
          }
        }
      } finally {
        graph.getModel().endUpdate();
      }
    }

    _sourceState = null;
    _startPoint = null;

    return result;
  }

}
