/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.swing.util;

//import java.awt.Graphics;
//import java.util.HashMap;
//import java.util.Map;

/**
 * Provides animation effects.
 */
class Morphing extends Animation {

  /**
	 * Reference to the enclosing graph instance.
	 */
  GraphComponent _graphComponent;

  /**
	 * Specifies the maximum number of steps for the morphing. Default is
	 * 6.
	 */
  int _steps;

  /**
	 * Counts the current number of steps of the animation.
	 */
  int _step;

  /**
	 * Ease-off for movement towards the given vector. Larger values are
	 * slower and smoother. Default is 1.5.
	 */
  double _ease;

  /**
	 * Maps from cells to origins. 
	 */
  Map<Object, Point2d> _origins = new HashMap<Object, Point2d>();

  /**
	 * Optional array of cells to limit the animation to. 
	 */
  List<Object> _cells;

  /**
	 * 
	 */
  /*transient*/ Rect _dirty;

  /**
	 * 
	 */
  /*transient*/ CellStatePreview _preview;

  /**
	 * Constructs a new morphing instance for the given graph.
	 */
  Morphing(GraphComponent graphComponent) {
    this(graphComponent, 6, 1.5, DEFAULT_DELAY);

    // Installs the paint handler
    graphComponent.addListener(Event.AFTER_PAINT, (Object sender, EventObj evt) {
      Graphics g = evt.getProperty("g") as Graphics;
      paint(g);
    });
  }

  /**
	 * Constructs a new morphing instance for the given graph.
	 */
  Morphing(GraphComponent graphComponent, int steps, double ease, int delay) : super(delay) {
    this._graphComponent = graphComponent;
    this._steps = steps;
    this._ease = ease;
  }

  /**
	 * Returns the number of steps for the animation.
	 */
  int getSteps() {
    return _steps;
  }

  /**
	 * Sets the number of steps for the animation.
	 */
  void setSteps(int value) {
    _steps = value;
  }

  /**
	 * Returns the easing for the movements.
	 */
  double getEase() {
    return _ease;
  }

  /**
	 * Sets the easing for the movements.
	 */
  void setEase(double value) {
    _ease = value;
  }

  /**
	 * Optional array of cells to be animated. If this is not specified
	 * then all cells are checked and animated if they have been moved
	 * in the current transaction.
	 */
  void setCells(List<Object> value) {
    _cells = value;
  }

  /**
	 * Animation step.
	 */
  void updateAnimation() {
    _preview = new CellStatePreview(_graphComponent, false);

    if (_cells != null) {
      // Animates the given cells individually without recursion
      for (Object cell in _cells) {
        _animateCell(cell, _preview, false);
      }
    } else {
      // Animates all changed cells by using recursion to find
      // the changed cells but not for the animation itself
      Object root = _graphComponent.getGraph().getModel().getRoot();
      _animateCell(root, _preview, true);
    }

    _show(_preview);

    if (_preview.isEmpty() || _step++ >= _steps) {
      stopAnimation();
    }
  }

  /**
	 * 
	 */
  void stopAnimation() {
    _graphComponent.getGraph().getView().revalidate();
    super.stopAnimation();

    _preview = null;

    if (_dirty != null) {
      _graphComponent.getGraphControl().repaint(_dirty.getRectangle());
    }
  }

  /**
	 * Shows the changes in the given CellStatePreview.
	 */
  void _show(CellStatePreview preview) {
    if (_dirty != null) {
      _graphComponent.getGraphControl().repaint(_dirty.getRectangle());
    } else {
      _graphComponent.getGraphControl().repaint();
    }

    _dirty = preview.show();

    if (_dirty != null) {
      _graphComponent.getGraphControl().repaint(_dirty.getRectangle());
    }
  }

  /**
	 * Animates the given cell state using moveState.
	 */
  void _animateCell(Object cell, CellStatePreview move, bool recurse) {
    Graph graph = _graphComponent.getGraph();
    CellState state = graph.getView().getState(cell);
    Point2d delta = null;

    if (state != null) {
      // Moves the animated state from where it will be after the model
      // change by subtracting the given delta vector from that location
      delta = _getDelta(state);

      if (graph.getModel().isVertex(cell) && (delta.getX() != 0 || delta.getY() != 0)) {
        Point2d translate = graph.getView().getTranslate();
        double scale = graph.getView().getScale();

        // FIXME: Something wrong with the scale
        delta.setX(delta.getX() + translate.getX() * scale);
        delta.setY(delta.getY() + translate.getY() * scale);

        move.moveState(state, -delta.getX() / _ease, -delta.getY() / _ease);
      }
    }

    if (recurse && !_stopRecursion(state, delta)) {
      int childCount = graph.getModel().getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        _animateCell(graph.getModel().getChildAt(cell, i), move, recurse);
      }
    }
  }

  /**
	 * Returns true if the animation should not recursively find more
	 * deltas for children if the given parent state has been animated.
	 */
  bool _stopRecursion(CellState state, Point2d delta) {
    return delta != null && (delta.getX() != 0 || delta.getY() != 0);
  }

  /**
	 * Returns the vector between the current rendered state and the future
	 * location of the state after the display will be updated.
	 */
  Point2d _getDelta(CellState state) {
    Graph graph = _graphComponent.getGraph();
    Point2d origin = _getOriginForCell(state.getCell());
    Point2d translate = graph.getView().getTranslate();
    double scale = graph.getView().getScale();
    Point2d current = new Point2d(state.getX() / scale - translate.getX(), state.getY() / scale - translate.getY());

    return new Point2d((origin.getX() - current.getX()) * scale, (origin.getY() - current.getY()) * scale);
  }

  /**
	 * Returns the top, left corner of the given cell.
	 */
  Point2d _getOriginForCell(Object cell) {
    Point2d result = _origins.get(cell);

    if (result == null) {
      Graph graph = _graphComponent.getGraph();

      if (cell != null) {
        result = new Point2d(_getOriginForCell(graph.getModel().getParent(cell)));
        Geometry geo = graph.getCellGeometry(cell);

        // TODO: Handle offset, relative geometries etc
        if (geo != null) {
          result.setX(result.getX() + geo.getX());
          result.setY(result.getY() + geo.getY());
        }
      }

      if (result == null) {
        Point2d t = graph.getView().getTranslate();
        result = new Point2d(-t.getX(), -t.getY());
      }

      _origins.put(cell, result);
    }

    return result;
  }

  /**
	 *
	 */
  void paint(Graphics g) {
    if (_preview != null) {
      _preview.paint(g);
    }
  }

}
