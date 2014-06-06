/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.swing.view;

//import java.awt.AlphaComposite;
//import java.awt.Composite;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;

/**
 * Represents the current state of a cell in a given graph view.
 */
class CellStatePreview {
  Map<CellState, Point2d> _deltas = new LinkedHashMap<CellState, Point2d>();

  int _count = 0;

  GraphComponent _graphComponent;

  /**
   * Specifies if cell states should be cloned or changed in-place.
   */
  bool _cloned;

  float _opacity = 1;

  List<CellState> _cellStates;

  /**
   * Constructs a new state preview. The paint handler to invoke the paint
   * method must be installed elsewhere.
   */
  CellStatePreview(GraphComponent graphComponent, bool cloned) {
    this._graphComponent = graphComponent;
    this._cloned = cloned;
  }

  bool isCloned() {
    return _cloned;
  }

  void setCloned(bool value) {
    _cloned = value;
  }

  bool isEmpty() {
    return _count == 0;
  }

  int getCount() {
    return _count;
  }

  Map<CellState, Point2d> getDeltas() {
    return _deltas;
  }

  void setOpacity(float value) {
    _opacity = value;
  }

  float getOpacity() {
    return _opacity;
  }

  //	Point2d moveState(CellState state, double dx, double dy)
  //	{
  //		return moveState(state, dx, dy, true, true);
  //	}

  Point2d moveState(CellState state, double dx, double dy, [bool add = true, bool includeEdges = true]) {
    Point2d delta = _deltas.get(state);

    if (delta == null) {
      delta = new Point2d(dx, dy);
      _deltas.put(state, delta);
      _count++;
    } else {
      if (add) {
        delta.setX(delta.getX() + dx);
        delta.setY(delta.getY() + dy);
      } else {
        delta.setX(dx);
        delta.setY(dy);
      }
    }

    if (includeEdges) {
      addEdges(state);
    }

    return delta;
  }

  /**
   * Returns a dirty rectangle to be repainted in GraphControl.
   */
  Rect show() {
    Graph graph = _graphComponent.getGraph();
    IGraphModel model = graph.getModel();

    // Stores a copy of the cell states
    List<CellState> previousStates = null;

    if (isCloned()) {
      previousStates = new LinkedList<CellState>();
      Iterator<CellState> it = _deltas.keySet().iterator();

      while (it.moveNext()) {
        CellState state = it.current();
        previousStates.addAll(snapshot(state));
      }
    }

    // Translates the states in step
    Iterator<CellState> it = _deltas.keySet().iterator();

    while (it.moveNext()) {
      CellState state = it.current();
      Point2d delta = _deltas.get(state);
      CellState parentState = graph.getView().getState(model.getParent(state.getCell()));
      _translateState(parentState, state, delta.getX(), delta.getY());
    }

    // Revalidates the states in step
    Rect dirty = null;
    it = _deltas.keySet().iterator();

    while (it.moveNext()) {
      CellState state = it.current();
      Point2d delta = _deltas.get(state);
      CellState parentState = graph.getView().getState(model.getParent(state.getCell()));
      Rect tmp = _revalidateState(parentState, state, delta.getX(), delta.getY());

      if (dirty != null) {
        dirty.add(tmp);
      } else {
        dirty = tmp;
      }
    }

    // Takes a snapshot of the states for later drawing. If the states
    // are not cloned then this does nothing and just expects a repaint
    // of the dirty rectangle.
    if (previousStates != null) {
      _cellStates = new LinkedList<CellState>();
      it = _deltas.keySet().iterator();

      while (it.moveNext()) {
        CellState state = it.current();
        _cellStates.addAll(snapshot(state));
      }

      // Restores the previous states
      restore(previousStates);
    }

    if (dirty != null) {
      dirty.grow(2);
    }

    return dirty;
  }

  void restore(List<CellState> snapshot) {
    Graph graph = _graphComponent.getGraph();
    Iterator<CellState> it = snapshot.iterator();

    while (it.moveNext()) {
      CellState state = it.current();
      CellState orig = graph.getView().getState(state.getCell());

      if (orig != null && orig != state) {
        restoreState(orig, state);
      }
    }
  }

  void restoreState(CellState state, CellState from) {
    state.setLabelBounds(from.getLabelBounds());
    state.setAbsolutePoints(from.getAbsolutePoints());
    state.setOrigin(from.getOrigin());
    state.setAbsoluteOffset(from.getAbsoluteOffset());
    state.setBoundingBox(from.getBoundingBox());
    state.setTerminalDistance(from.getTerminalDistance());
    state.setSegments(from.getSegments());
    state.setLength(from.getLength());
    state.setX(from.getX());
    state.setY(from.getY());
    state.setWidth(from.getWidth());
    state.setHeight(from.getHeight());
  }

  List<CellState> snapshot(CellState state) {
    List<CellState> result = new LinkedList<CellState>();

    if (state != null) {
      result.add(state.clone() as CellState);

      Graph graph = _graphComponent.getGraph();
      IGraphModel model = graph.getModel();
      Object cell = state.getCell();
      int childCount = model.getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        result.addAll(snapshot(graph.getView().getState(model.getChildAt(cell, i))));
      }
    }

    return result;
  }

  /**
   *
   */
  void _translateState(CellState parentState, CellState state, double dx, double dy) {
    if (state != null) {
      Graph graph = _graphComponent.getGraph();
      IGraphModel model = graph.getModel();
      Object cell = state.getCell();

      if (model.isVertex(cell)) {
        state.getView().updateCellState(state);
        Geometry geo = graph.getCellGeometry(cell);

        // Moves selection cells and non-relative vertices in
        // the first phase so that edge terminal points will
        // be updated in the second phase
        if ((dx != 0 || dy != 0) && geo != null && (!geo.isRelative() || _deltas.get(state) != null)) {
          state.setX(state.getX() + dx);
          state.setY(state.getY() + dy);
        }
      }

      int childCount = model.getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        _translateState(state, graph.getView().getState(model.getChildAt(cell, i)), dx, dy);
      }
    }
  }

  /**
   *
   */
  Rect _revalidateState(CellState parentState, CellState state, double dx, double dy) {
    Rect dirty = null;

    if (state != null) {
      Graph graph = _graphComponent.getGraph();
      IGraphModel model = graph.getModel();
      Object cell = state.getCell();

      // Updates the edge terminal points and restores the
      // (relative) positions of any (relative) children
      if (model.isEdge(cell)) {
        state.getView().updateCellState(state);
      }

      dirty = state.getView().getBoundingBox(state, false);

      // Moves selection vertices which are relative
      Geometry geo = graph.getCellGeometry(cell);

      if ((dx != 0 || dy != 0) && geo != null && geo.isRelative() && model.isVertex(cell) && (parentState == null || model.isVertex(parentState.getCell()) || _deltas.get(state) != null)) {
        state.setX(state.getX() + dx);
        state.setY(state.getY() + dy);

        // TODO: Check this change
        dirty.setX(dirty.getX() + dx);
        dirty.setY(dirty.getY() + dy);

        graph.getView().updateLabelBounds(state);
      }

      int childCount = model.getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        Rect tmp = _revalidateState(state, graph.getView().getState(model.getChildAt(cell, i)), dx, dy);

        if (dirty != null) {
          dirty.add(tmp);
        } else {
          dirty = tmp;
        }
      }
    }

    return dirty;
  }

  void addEdges(CellState state) {
    Graph graph = _graphComponent.getGraph();
    IGraphModel model = graph.getModel();
    Object cell = state.getCell();
    int edgeCount = model.getEdgeCount(cell);

    for (int i = 0; i < edgeCount; i++) {
      CellState state2 = graph.getView().getState(model.getEdgeAt(cell, i));

      if (state2 != null) {
        moveState(state2, 0, 0);
      }
    }
  }

  void paint(Graphics g) {
    if (_cellStates != null && _cellStates.length > 0) {
      Graphics2DCanvas canvas = _graphComponent.getCanvas();

      // Sets antialiasing
      if (_graphComponent.isAntiAlias()) {
        Utils.setAntiAlias(g as Graphics2D, true, true);
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

  float _getOpacityForCell(Object cell) {
    return _opacity;
  }

  /**
   * Draws the preview using the graphics canvas.
   */
  void _paintPreview(Graphics2DCanvas canvas) {
    Composite previousComposite = canvas.getGraphics().getComposite();

    // Paints the preview states
    Iterator<CellState> it = _cellStates.iterator();

    while (it.moveNext()) {
      CellState state = it.current();
      canvas.getGraphics().setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, _getOpacityForCell(state.getCell())));
      _paintPreviewState(canvas, state);
    }

    canvas.getGraphics().setComposite(previousComposite);
  }

  /**
   * Draws the preview using the graphics canvas.
   */
  void _paintPreviewState(Graphics2DCanvas canvas, CellState state) {
    _graphComponent.getGraph().drawState(canvas, state, state.getCell() != _graphComponent.getCellEditor().getEditingCell());
  }
}
