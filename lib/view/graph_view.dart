/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.view;

//import java.awt.geom.Line2D;
//import java.util.ArrayList;
//import java.util.Hashtable;
//import java.util.List;
//import java.util.Map;

/**
 * Implements a view for the graph. This class is in charge of computing the
 * absolute coordinates for the relative child geometries, the points for
 * perimeters and edge styles and keeping them cached in cell states for
 * faster retrieval. The states are updated whenever the model or the view
 * state (translate, scale) changes. The scale and translate are honoured in
 * the bounds.
 * 
 * This class fires the following events:
 * 
 * Event.UNDO fires after the root was changed in setCurrentRoot. The
 * <code>edit</code> property contains the UndoableEdit which contains the
 * CurrentRootChange.
 * 
 * Event.SCALE_AND_TRANSLATE fires after the scale and transle have been
 * changed in scaleAndTranslate. The <code>scale</code>, <code>previousScale</code>,
 * <code>translate</code> and <code>previousTranslate</code> properties contain
 * the new and previous scale and translate, respectively.
 * 
 * Event.SCALE fires after the scale was changed in setScale. The
 * <code>scale</code> and <code>previousScale</code> properties contain the
 * new and previous scale.
 * 
 * Event.TRANSLATE fires after the translate was changed in setTranslate. The
 * <code>translate</code> and <code>previousTranslate</code> properties contain
 * the new and previous value for translate.
 * 
 * Event.UP and Event.DOWN fire if the current root is changed by executing
 * a CurrentRootChange. The event name depends on the location of the root
 * in the cell hierarchy with respect to the current root. The
 * <code>root</code> and <code>previous</code> properties contain the new and
 * previous root, respectively.
 */
class GraphView extends EventSource {
  /**
	 *
	 */
  static Point2d _EMPTY_POINT = new Point2d();

  /**
	 * Reference to the enclosing graph.
	 */
  Graph _graph;

  /**
	 * Cell that acts as the root of the displayed cell hierarchy.
	 */
  Object _currentRoot = null;

  /**
	 * Caches the current bounds of the graph.
	 */
  Rect _graphBounds = new Rect();

  /**
	 * Specifies the scale. Default is 1 (100%).
	 */
  double _scale = 1;

  /**
	 * Point that specifies the current translation. Default is a new
	 * empty point.
	 */
  Point2d _translate = new Point2d(0, 0);

  /**
	 * Maps from cells to cell states.
	 */
  Map<Object, CellState> _states = new Map<Object, CellState>();

  /**
	 * Constructs a new view for the given graph.
	 * 
	 * @param graph Reference to the enclosing graph.
	 */
  GraphView(Graph graph) {
    this._graph = graph;
  }

  /**
	 * Returns the enclosing graph.
	 * 
	 * @return Returns the enclosing graph.
	 */
  Graph getGraph() {
    return _graph;
  }

  /**
	 * Returns the dictionary that maps from cells to states.
	 */
  Map<Object, CellState> getStates() {
    return _states;
  }

  /**
	 * Returns the dictionary that maps from cells to states.
	 */
  void setStates(Map<Object, CellState> states) {
    this._states = states;
  }

  /**
	 * Returns the cached diagram bounds.
	 * 
	 * @return Returns the diagram bounds.
	 */
  Rect getGraphBounds() {
    return _graphBounds;
  }

  /**
	 * Sets the graph bounds.
	 */
  void setGraphBounds(Rect value) {
    _graphBounds = value;
  }

  /**
	 * Returns the current root.
	 */
  Object getCurrentRoot() {
    return _currentRoot;
  }

  /**
	 * Sets and returns the current root and fires an undo event.
	 * 
	 * @param root Cell that specifies the root of the displayed cell hierarchy.
	 * @return Returns the object that represents the current root.
	 */
  Object setCurrentRoot(Object root) {
    if (_currentRoot != root) {
      CurrentRootChange change = new CurrentRootChange(this, root);
      change.execute();
      UndoableEdit edit = new UndoableEdit(this, false);
      edit.add(change);
      fireEvent(new EventObj(Event.UNDO, ["edit", edit]));
    }

    return root;
  }

  /**
	 * Sets the scale and translation. Fires a "scaleAndTranslate"
	 * event after calling revalidate. Revalidate is only called if
	 * isEventsEnabled.
	 * 
	 * @param scale Decimal value that specifies the new scale (1 is 100%).
	 * @param dx X-coordinate of the translation.
	 * @param dy Y-coordinate of the translation.
	 */
  void scaleAndTranslate(double scale, double dx, double dy) {
    double previousScale = this._scale;
    Object previousTranslate = _translate.clone();

    if (scale != this._scale || dx != _translate.getX() || dy != _translate.getY()) {
      this._scale = scale;
      _translate = new Point2d(dx, dy);

      if (isEventsEnabled()) {
        revalidate();
      }
    }

    fireEvent(new EventObj(Event.SCALE_AND_TRANSLATE, ["scale", scale, "previousScale", previousScale, "translate", _translate, "previousTranslate", previousTranslate]));
  }

  /**
	 * Returns the current scale.
	 * 
	 * @return Returns the scale.
	 */
  double getScale() {
    return _scale;
  }

  /**
	 * Sets the current scale and revalidates the view. Fires a "scale"
	 * event after calling revalidate. Revalidate is only called if
	 * isEventsEnabled.
	 * 
	 * @param value New scale to be used.
	 */
  void setScale(double value) {
    double previousScale = _scale;

    if (_scale != value) {
      _scale = value;

      if (isEventsEnabled()) {
        revalidate();
      }
    }

    fireEvent(new EventObj(Event.SCALE, ["scale", _scale, "previousScale", previousScale]));
  }

  /**
	 * Returns the current translation.
	 * 
	 * @return Returns the translation.
	 */
  Point2d getTranslate() {
    return _translate;
  }

  /**
	 * Sets the current translation and invalidates the view. Fires
	 * a property change event for "translate" after calling
	 * revalidate. Revalidate is only called if isEventsEnabled.
	 * 
	 * @param value New translation to be used.
	 */
  void setTranslate(Point2d value) {
    Object previousTranslate = _translate.clone();

    if (value != null && (value.getX() != _translate.getX() || value.getY() != _translate.getY())) {
      _translate = value;

      if (isEventsEnabled()) {
        revalidate();
      }
    }

    fireEvent(new EventObj(Event.TRANSLATE, ["translate", _translate, "previousTranslate", previousTranslate]));
  }

  /**
	 * Returns the bounding box for an array of cells or null, if no cells are
	 * specified.
	 * 
	 * @param cells
	 * @return Returns the bounding box for the given cells.
	 */
  //	Rect getBounds(List<Object> cells)
  //	{
  //		return getBounds(cells, false);
  //	}

  /**
	 * Returns the bounding box for an array of cells or null, if no cells are
	 * specified.
	 * 
	 * @param cells
	 * @return Returns the bounding box for the given cells.
	 */
  //	Rect getBoundingBox(List<Object> cells)
  //	{
  //		return getBounds(cells, true);
  //	}

  /**
	 * Returns the bounding box for an array of cells or null, if no cells are
	 * specified.
	 * 
	 * @param cells
	 * @return Returns the bounding box for the given cells.
	 */
  Rect getBounds(List<Object> cells, [bool boundingBox = false]) {
    Rect result = null;

    if (cells != null && cells.length > 0) {
      IGraphModel model = _graph.getModel();

      for (int i = 0; i < cells.length; i++) {
        if (model.isVertex(cells[i]) || model.isEdge(cells[i])) {
          CellState state = getState(cells[i]);

          if (state != null) {
            Rect tmp = (boundingBox) ? state.getBoundingBox() : state;

            if (tmp != null) {
              if (result == null) {
                result = new Rect(tmp);
              } else {
                result.add(tmp);
              }
            }
          }
        }
      }
    }

    return result;
  }

  /**
	 * Removes all existing cell states and invokes validate.
	 */
  void reload() {
    _states.clear();
    validate();
  }

  /**
	 * 
	 */
  void revalidate() {
    invalidate();
    validate();
  }

  /**
	 * Invalidates all cell states.
	 */
  //	void invalidate()
  //	{
  //		invalidate(null);
  //	}

  /**
	 * Removes the state of the given cell and all descendants if the given
	 * cell is not the current root.
	 * 
	 * @param cell
	 * @param force
	 * @param recurse
	 */
  void clear(Object cell, bool force, bool recurse) {
    removeState(cell);

    if (recurse && (force || cell != _currentRoot)) {
      IGraphModel model = _graph.getModel();
      int childCount = model.getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        clear(model.getChildAt(cell, i), force, recurse);
      }
    } else {
      invalidate(cell);
    }
  }

  /**
	 * Invalidates the state of the given cell, all its descendants and
	 * connected edges.
	 */
  void invalidate([Object cell = null]) {
    IGraphModel model = _graph.getModel();
    cell = (cell != null) ? cell : model.getRoot();
    CellState state = getState(cell);

    if (state == null || !state.isInvalid()) {
      if (state != null) {
        state.setInvalid(true);
      }

      // Recursively invalidates all descendants
      int childCount = model.getChildCount(cell);

      for (int i = 0; i < childCount; i++) {
        Object child = model.getChildAt(cell, i);
        invalidate(child);
      }

      // Propagates invalidation to all connected edges
      int edgeCount = model.getEdgeCount(cell);

      for (int i = 0; i < edgeCount; i++) {
        invalidate(model.getEdgeAt(cell, i));
      }
    }
  }

  /**
	 * First validates all bounds and then validates all points recursively on
	 * all visible cells.
	 */
  void validate() {
    Rect graphBounds = getBoundingBox(validateCellState(validateCell((_currentRoot != null) ? _currentRoot : _graph.getModel().getRoot())));
    setGraphBounds((graphBounds != null) ? graphBounds : new Rect());
  }

  /**
	 * Shortcut to validateCell with visible set to true.
	 */
  //	Rect getBoundingBox(CellState state)
  //	{
  //		return getBoundingBox(state, true);
  //	}

  /**
	 * Returns the bounding box of the shape and the label for the given
	 * cell state and its children if recurse is true.
	 * 
	 * @param state Cell state whose bounding box should be returned.
	 * @param recurse bool indicating if the children should be included.
	 */
  Rect getBoundingBox(CellState state, [bool recurse = true]) {
    Rect bbox = null;

    if (state != null) {
      if (state.getBoundingBox() != null) {
        bbox = state.getBoundingBox().clone() as Rect;
      }

      if (recurse) {
        IGraphModel model = _graph.getModel();
        int childCount = model.getChildCount(state._cell);

        for (int i = 0; i < childCount; i++) {
          Rect bounds = getBoundingBox(getState(model.getChildAt(state._cell, i)), true);

          if (bounds != null) {
            if (bbox == null) {
              bbox = bounds;
            } else {
              bbox.add(bounds);
            }
          }
        }
      }
    }

    return bbox;
  }

  /**
	 * Shortcut to validateCell with visible set to true.
	 */
  //	Object validateCell(Object cell)
  //	{
  //		return validateCell(cell, true);
  //	}

  /**
	 * Recursively creates the cell state for the given cell if visible is true and
	 * the given cell is visible. If the cell is not visible but the state exists
	 * then it is removed using removeState.
	 * 
	 * @param cell Cell whose cell state should be created.
	 * @param visible bool indicating if the cell should be visible.
	 */
  Object validateCell(Object cell, [bool visible = true]) {
    if (cell != null) {
      visible = visible && _graph.isCellVisible(cell);
      CellState state = getState(cell, visible);

      if (state != null && !visible) {
        removeState(cell);
      } else {
        IGraphModel model = _graph.getModel();
        int childCount = model.getChildCount(cell);

        for (int i = 0; i < childCount; i++) {
          validateCell(model.getChildAt(cell, i), visible && (!_graph.isCellCollapsed(cell) || cell == _currentRoot));
        }
      }
    }

    return cell;
  }

  /**
	 * Shortcut to validateCellState with recurse set to true.
	 */
  //	CellState validateCellState(Object cell)
  //	{
  //		return validateCellState(cell, true);
  //	}

  /**
	 * Validates the cell state for the given cell.
	 * 
	 * @param cell Cell whose cell state should be validated.
	 * @param recurse bool indicating if the children of the cell should be
	 * validated.
	 */
  CellState validateCellState(Object cell, [bool recurse = true]) {
    CellState state = null;

    if (cell != null) {
      state = getState(cell);

      if (state != null) {
        IGraphModel model = _graph.getModel();

        if (state.isInvalid()) {
          state.setInvalid(false);

          if (cell != _currentRoot) {
            validateCellState(model.getParent(cell), false);
          }

          state.setVisibleTerminalState(validateCellState(getVisibleTerminal(cell, true), false), true);
          state.setVisibleTerminalState(validateCellState(getVisibleTerminal(cell, false), false), false);

          updateCellState(state);

          if (model.isEdge(cell) || model.isVertex(cell)) {
            updateLabelBounds(state);
            updateBoundingBox(state);
          }
        }

        if (recurse) {
          int childCount = model.getChildCount(cell);

          for (int i = 0; i < childCount; i++) {
            validateCellState(model.getChildAt(cell, i));
          }
        }
      }
    }

    return state;
  }

  /**
	 * Updates the given cell state.
	 * 
	 * @param state Cell state to be updated.
	 */
  void updateCellState(CellState state) {
    state.getAbsoluteOffset().setX(0);
    state.getAbsoluteOffset().setY(0);
    state.getOrigin().setX(0);
    state.getOrigin().setY(0);
    state.setLength(0);

    if (state.getCell() != _currentRoot) {
      IGraphModel model = _graph.getModel();
      CellState pState = getState(model.getParent(state.getCell()));

      if (pState != null && pState.getCell() != _currentRoot) {
        state.getOrigin().setX(state.getOrigin().getX() + pState.getOrigin().getX());
        state.getOrigin().setY(state.getOrigin().getY() + pState.getOrigin().getY());
      }

      Point2d offset = _graph.getChildOffsetForCell(state.getCell());

      if (offset != null) {
        state.getOrigin().setX(state.getOrigin().getX() + offset.getX());
        state.getOrigin().setY(state.getOrigin().getY() + offset.getY());
      }

      Geometry geo = _graph.getCellGeometry(state.getCell());

      if (geo != null) {
        if (!model.isEdge(state._cell)) {
          Point2d origin = state.getOrigin();
          offset = geo.getOffset();

          if (offset == null) {
            offset = _EMPTY_POINT;
          }

          if (geo.isRelative() && pState != null) {
            if (model.isEdge(pState._cell)) {
              Point2d orig = getPoint(pState, geo);

              if (orig != null) {
                origin.setX(origin.getX() + (orig.getX() / _scale) - _translate.getX());
                origin.setY(origin.getY() + (orig.getY() / _scale) - _translate.getY());
              }
            } else {
              origin.setX(origin.getX() + geo.getX() * pState.getWidth() / _scale + offset.getX());
              origin.setY(origin.getY() + geo.getY() * pState.getHeight() / _scale + offset.getY());
            }
          } else {
            state.setAbsoluteOffset(new Point2d(_scale * offset.getX(), _scale * offset.getY()));
            origin.setX(origin.getX() + geo.getX());
            origin.setY(origin.getY() + geo.getY());
          }
        }

        state.setX(_scale * (_translate.getX() + state.getOrigin().getX()));
        state.setY(_scale * (_translate.getY() + state.getOrigin().getY()));
        state.setWidth(_scale * geo.getWidth());
        state.setHeight(_scale * geo.getHeight());

        if (model.isVertex(state.getCell())) {
          updateVertexState(state, geo);
        }

        if (model.isEdge(state.getCell())) {
          updateEdgeState(state, geo);
        }

        // Updates the cached label
        updateLabel(state);
      }
    }
  }

  /**
	 * Validates the given cell state.
	 */
  void updateVertexState(CellState state, Geometry geo) {
    // LATER: Add support for rotation
    updateVertexLabelOffset(state);
  }

  /**
	 * Validates the given cell state.
	 */
  void updateEdgeState(CellState state, Geometry geo) {
    CellState source = state.getVisibleTerminalState(true);
    CellState target = state.getVisibleTerminalState(false);

    // This will remove edges with no terminals and no terminal points
    // as such edges are invalid and produce NPEs in the edge styles.
    // Also removes connected edges that have no visible terminals.
    if ((_graph.getModel().getTerminal(state.getCell(), true) != null && source == null) || (source == null && geo.getTerminalPoint(true) == null) || (_graph.getModel().getTerminal(state.getCell(), false) != null && target == null) || (target == null && geo.getTerminalPoint(false) == null)) {
      clear(state._cell, true, true);
    } else {
      updateFixedTerminalPoints(state, source, target);
      updatePoints(state, geo.getPoints(), source, target);
      updateFloatingTerminalPoints(state, source, target);

      if (state.getCell() != getCurrentRoot() && (state.getAbsolutePointCount() < 2 || state.getAbsolutePoint(0) == null || state.getAbsolutePoint(state.getAbsolutePointCount() - 1) == null)) {
        // This will remove edges with invalid points from the list of states in the view.
        // Happens if the one of the terminals and the corresponding terminal point is null.
        clear(state.getCell(), true, true);
      } else {
        updateEdgeBounds(state);
        state.setAbsoluteOffset(getPoint(state, geo));
      }
    }
  }

  /**
	 * Updates the absoluteOffset of the given vertex cell state. This takes
	 * into account the label position styles.
	 * 
	 * @param state Cell state whose absolute offset should be updated.
	 */
  void updateVertexLabelOffset(CellState state) {
    String horizontal = Utils.getString(state.getStyle(), Constants.STYLE_LABEL_POSITION, Constants.ALIGN_CENTER);

    if (horizontal == Constants.ALIGN_LEFT) {
      state._absoluteOffset.setX(state._absoluteOffset.getX() - state.getWidth());
    } else if (horizontal == Constants.ALIGN_RIGHT) {
      state._absoluteOffset.setX(state._absoluteOffset.getX() + state.getWidth());
    }

    String vertical = Utils.getString(state.getStyle(), Constants.STYLE_VERTICAL_LABEL_POSITION, Constants.ALIGN_MIDDLE);

    if (vertical == Constants.ALIGN_TOP) {
      state._absoluteOffset.setY(state._absoluteOffset.getY() - state.getHeight());
    } else if (vertical == Constants.ALIGN_BOTTOM) {
      state._absoluteOffset.setY(state._absoluteOffset.getY() + state.getHeight());
    }
  }

  /**
	 * Updates the label of the given state.
	 */
  void updateLabel(CellState state) {
    String label = _graph.getLabel(state.getCell());
    Map<String, Object> style = state.getStyle();

    // Applies word wrapping to non-HTML labels and stores the result in the state
    if (label != null && label.length > 0 && !_graph.isHtmlLabel(state.getCell()) && !_graph.getModel().isEdge(state.getCell()) && Utils.getString(style, Constants.STYLE_WHITE_SPACE, "nowrap") == "wrap") {
      double w = getWordWrapWidth(state);

      // The lines for wrapping within the given width are calculated for no
      // scale. The reason for this is the granularity of actual displayed
      // font can cause the displayed lines to change based on scale. A factor
      // is used to allow for different overalls widths, it ensures the largest
      // font size/scale factor still stays within the bounds. All this ensures
      // the wrapped lines are constant overing scaling, at the expense the
      // label bounds will vary.
      List<String> lines = Utils.wordWrap(label, Utils.getFontMetrics(Utils.getFont(state.getStyle())), w * Constants.LABEL_SCALE_BUFFER);

      if (lines.length > 0) {
        StringBuffer buffer = new StringBuffer();

        for (String line in lines) {
          buffer.write(line + '\n');
        }

        label = buffer.toString().substring(0, buffer.length - 1);
      }
    }

    state.setLabel(label);
  }

  /**
	 * Returns the width for wrapping the label of the given state at
	 * scale 1.
	 */
  double getWordWrapWidth(CellState state) {
    Map<String, Object> style = state.getStyle();
    bool horizontal = Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true);
    double w = 0;

    // Computes the available width for the wrapped label
    if (horizontal) {
      w = (state.getWidth() / _scale) - 2 * Constants.LABEL_INSET - 2 * Utils.getDouble(style, Constants.STYLE_SPACING) - Utils.getDouble(style, Constants.STYLE_SPACING_LEFT) - Utils.getDouble(style, Constants.STYLE_SPACING_RIGHT);
    } else {
      w = (state.getHeight() / _scale) - 2 * Constants.LABEL_INSET - 2 * Utils.getDouble(style, Constants.STYLE_SPACING) - Utils.getDouble(style, Constants.STYLE_SPACING_TOP) + Utils.getDouble(style, Constants.STYLE_SPACING_BOTTOM);
    }

    return w;
  }

  /**
	 * Updates the label bounds in the given state.
	 */
  void updateLabelBounds(CellState state) {
    Object cell = state.getCell();
    Map<String, Object> style = state.getStyle();
    String overflow = Utils.getString(style, Constants.STYLE_OVERFLOW, "");

    if (overflow == "fill") {
      state.setLabelBounds(new Rect(state));
    } else if (state.getLabel() != null) {
      // For edges, the width of the geometry is used for wrapping HTML
      // labels or no wrapping is applied if the width is set to 0
      Rect vertexBounds = state;

      if (_graph.getModel().isEdge(cell)) {
        Geometry geo = _graph.getCellGeometry(cell);

        if (geo != null && geo.getWidth() > 0) {
          vertexBounds = new Rect(0, 0, geo.getWidth() * this.getScale(), 0);
        } else {
          vertexBounds = null;
        }
      }

      state.setLabelBounds(Utils.getLabelPaintBounds(state.getLabel(), style, _graph.isHtmlLabel(cell), state.getAbsoluteOffset(), vertexBounds, _scale, _graph.getModel().isEdge(cell)));

      if (overflow == "width") {
        state.getLabelBounds().setX(state.getX());
        state.getLabelBounds().setWidth(state.getWidth());
      }
    }
  }

  /**
	 * Updates the bounding box in the given cell state.
	 *  
	 * @param state Cell state whose bounding box should be
	 * updated.
	 */
  Rect updateBoundingBox(CellState state) {
    // Gets the cell bounds and adds shadows and markers
    Rect rect = new Rect(state);
    Map<String, Object> style = state.getStyle();

    // Adds extra pixels for the marker and stroke assuming
    // that the border stroke is centered around the bounds
    // and the first pixel is drawn inside the bounds
    double strokeWidth = Math.max(1, math.round(Utils.getInt(style, Constants.STYLE_STROKEWIDTH, 1) * _scale));
    strokeWidth -= Math.max(1, strokeWidth / 2);

    if (_graph.getModel().isEdge(state.getCell())) {
      int ms = 0;

      if (style.containsKey(Constants.STYLE_ENDARROW) || style.containsKey(Constants.STYLE_STARTARROW)) {
        ms = math.round(Constants.DEFAULT_MARKERSIZE * _scale) as int;
      }

      // Adds the strokewidth
      rect.grow(ms + strokeWidth);

      // Adds worst case border for an arrow shape
      if (Utils.getString(style, Constants.STYLE_SHAPE, "") == Constants.SHAPE_ARROW) {
        rect.grow(Constants.ARROW_WIDTH / 2);
      }
    } else {
      rect.grow(strokeWidth);
    }

    // Adds extra pixels for the shadow
    if (Utils.isTrue(style, Constants.STYLE_SHADOW)) {
      rect.setWidth(rect.getWidth() + Constants.SHADOW_OFFSETX);
      rect.setHeight(rect.getHeight() + Constants.SHADOW_OFFSETY);
    }

    // Adds oversize images in labels
    if (Utils.getString(style, Constants.STYLE_SHAPE, "") == Constants.SHAPE_LABEL) {
      if (Utils.getString(style, Constants.STYLE_IMAGE) != null) {
        double w = Utils.getInt(style, Constants.STYLE_IMAGE_WIDTH, Constants.DEFAULT_IMAGESIZE) * _scale;
        double h = Utils.getInt(style, Constants.STYLE_IMAGE_HEIGHT, Constants.DEFAULT_IMAGESIZE) * _scale;

        double x = state.getX();
        double y = 0;

        String imgAlign = Utils.getString(style, Constants.STYLE_IMAGE_ALIGN, Constants.ALIGN_LEFT);
        String imgValign = Utils.getString(style, Constants.STYLE_IMAGE_VERTICAL_ALIGN, Constants.ALIGN_MIDDLE);

        if (imgAlign == Constants.ALIGN_RIGHT) {
          x += state.getWidth() - w;
        } else if (imgAlign == Constants.ALIGN_CENTER) {
          x += (state.getWidth() - w) / 2;
        }

        if (imgValign == Constants.ALIGN_TOP) {
          y = state.getY();
        } else if (imgValign == Constants.ALIGN_BOTTOM) {
          y = state.getY() + state.getHeight() - h;
        } else // MIDDLE
        {
          y = state.getY() + (state.getHeight() - h) / 2;
        }

        rect.add(new Rect(x, y, w, h));
      }
    }

    // Adds the rotated bounds to the bounding box if the
    // shape is rotated
    double rotation = Utils.getDouble(style, Constants.STYLE_ROTATION);
    Rect bbox = Utils.getBoundingBox(rect, rotation);

    // Add the rotated bounding box to the non-rotated so
    // that all handles are also covered
    rect.add(bbox);

    // Unifies the cell bounds and the label bounds
    if (!_graph.isLabelClipped(state.getCell())) {
      rect.add(state.getLabelBounds());
    }

    state.setBoundingBox(rect);

    return rect;
  }

  /**
	 * Sets the initial absolute terminal points in the given state before the edge
	 * style is computed.
	 * 
	 * @param edge Cell state whose initial terminal points should be updated.
	 * @param source Cell state which represents the source terminal.
	 * @param target Cell state which represents the target terminal.
	 */
  void updateFixedTerminalPoints(CellState edge, CellState source, CellState target) {
    updateFixedTerminalPoint(edge, source, true, _graph.getConnectionConstraint(edge, source, true));
    updateFixedTerminalPoint(edge, target, false, _graph.getConnectionConstraint(edge, target, false));
  }

  /**
	 * Sets the fixed source or target terminal point on the given edge.
	 * 
	 * @param edge Cell state whose initial terminal points should be
	 * updated.
	 */
  void updateFixedTerminalPoint(CellState edge, CellState terminal, bool source, ConnectionConstraint constraint) {
    Point2d pt = null;

    if (constraint != null) {
      pt = _graph.getConnectionPoint(terminal, constraint);
    }

    if (pt == null && terminal == null) {
      Point2d orig = edge.getOrigin();
      Geometry geo = _graph.getCellGeometry(edge._cell);
      pt = geo.getTerminalPoint(source);

      if (pt != null) {
        pt = new Point2d(_scale * (_translate.getX() + pt.getX() + orig.getX()), _scale * (_translate.getY() + pt.getY() + orig.getY()));
      }
    }

    edge.setAbsoluteTerminalPoint(pt, source);
  }

  /**
	 * Updates the absolute points in the given state using the specified array
	 * of points as the relative points.
	 * 
	 * @param edge Cell state whose absolute points should be updated.
	 * @param points Array of points that constitute the relative points.
	 * @param source Cell state that represents the source terminal.
	 * @param target Cell state that represents the target terminal.
	 */
  void updatePoints(CellState edge, List<Point2d> points, CellState source, CellState target) {
    if (edge != null) {
      List<Point2d> pts = new List<Point2d>();
      pts.add(edge.getAbsolutePoint(0));
      EdgeStyleFunction edgeStyle = getEdgeStyle(edge, points, source, target);

      if (edgeStyle != null) {
        CellState src = getTerminalPort(edge, source, true);
        CellState trg = getTerminalPort(edge, target, false);

        edgeStyle(edge, src, trg, points, pts);
      } else if (points != null) {
        for (int i = 0; i < points.length; i++) {
          pts.add(transformControlPoint(edge, points[i]));
        }
      }

      pts.add(edge.getAbsolutePoint(edge.getAbsolutePointCount() - 1));
      edge.setAbsolutePoints(pts);
    }
  }

  /**
	 * Transforms the given control point to an absolute point.
	 */
  Point2d transformControlPoint(CellState state, Point2d pt) {
    Point2d origin = state.getOrigin();

    return new Point2d(_scale * (pt.getX() + _translate.getX() + origin.getX()), _scale * (pt.getY() + _translate.getY() + origin.getY()));
  }

  /**
	 * Returns the edge style function to be used to compute the absolute
	 * points for the given state, control points and terminals.
	 */
  EdgeStyleFunction getEdgeStyle(CellState edge, List<Point2d> points, Object source, Object target) {
    Object edgeStyle = null;

    if (source != null && source == target) {
      edgeStyle = edge.getStyle().get(Constants.STYLE_LOOP);

      if (edgeStyle == null) {
        edgeStyle = _graph.getDefaultLoopStyle();
      }
    } else if (!Utils.isTrue(edge.getStyle(), Constants.STYLE_NOEDGESTYLE, false)) {
      edgeStyle = edge.getStyle().get(Constants.STYLE_EDGE);
    }

    // Converts string values to objects
    if (edgeStyle is String) {
      String str = edgeStyle.toString();
      Object tmp = StyleRegistry.getValue(str);

      if (tmp == null) {
        tmp = Utils.eval(str);
      }

      edgeStyle = tmp;
    }

    if (edgeStyle is EdgeStyleFunction) {
      return edgeStyle as EdgeStyleFunction;
    }

    return null;
  }

  /**
	 * Updates the terminal points in the given state after the edge style was
	 * computed for the edge.
	 * 
	 * @param state Cell state whose terminal points should be updated.
	 * @param source Cell state that represents the source terminal.
	 * @param target Cell state that represents the target terminal.
	 */
  void updateFloatingTerminalPoints(CellState state, CellState source, CellState target) {
    Point2d p0 = state.getAbsolutePoint(0);
    Point2d pe = state.getAbsolutePoint(state.getAbsolutePointCount() - 1);

    if (pe == null && target != null) {
      updateFloatingTerminalPoint(state, target, source, false);
    }

    if (p0 == null && source != null) {
      updateFloatingTerminalPoint(state, source, target, true);
    }
  }

  /**
	 * Updates the absolute terminal point in the given state for the given
	 * start and end state, where start is the source if source is true.
	 * 
	 * @param edge Cell state whose terminal point should be updated.
	 * @param start Cell state for the terminal on "this" side of the edge.
	 * @param end Cell state for the terminal on the other side of the edge.
	 * @param source bool indicating if start is the source terminal state.
	 */
  void updateFloatingTerminalPoint(CellState edge, CellState start, CellState end, bool source) {
    start = getTerminalPort(edge, start, source);
    Point2d next = getNextPoint(edge, end, source);
    double border = Utils.getDouble(edge.getStyle(), Constants.STYLE_PERIMETER_SPACING);
    border += Utils.getDouble(edge.getStyle(), (source) ? Constants.STYLE_SOURCE_PERIMETER_SPACING : Constants.STYLE_TARGET_PERIMETER_SPACING);
    Point2d pt = getPerimeterPoint(start, next, _graph.isOrthogonal(edge), border);
    edge.setAbsoluteTerminalPoint(pt, source);
  }

  /**
	 * Returns a cell state that represents the source or target terminal or
	 * port for the given edge.
	 */
  CellState getTerminalPort(CellState state, CellState terminal, bool source) {
    String key = (source) ? Constants.STYLE_SOURCE_PORT : Constants.STYLE_TARGET_PORT;
    String id = Utils.getString(state._style, key);

    if (id != null && _graph.getModel() is GraphModel) {
      CellState tmp = getState((_graph.getModel() as GraphModel).getCell(id));

      // Only uses ports where a cell state exists
      if (tmp != null) {
        terminal = tmp;
      }
    }

    return terminal;
  }

  /**
	 * Returns a point that defines the location of the intersection point between
	 * the perimeter and the line between the center of the shape and the given point.
	 */
  //	Point2d getPerimeterPoint(CellState terminal, Point2d next,
  //			bool orthogonal)
  //	{
  //		return getPerimeterPoint(terminal, next, orthogonal, 0);
  //	}

  /**
	 * Returns a point that defines the location of the intersection point between
	 * the perimeter and the line between the center of the shape and the given point.
	 * 
	 * @param terminal Cell state for the source or target terminal.
	 * @param next Point that lies outside of the given terminal.
	 * @param orthogonal bool that specifies if the orthogonal projection onto
	 * the perimeter should be returned. If this is false then the intersection
	 * of the perimeter and the line between the next and the center point is
	 * returned.
	 * @param border Optional border between the perimeter and the shape.
	 */
  Point2d getPerimeterPoint(CellState terminal, Point2d next, bool orthogonal, [double border = 0.0]) {
    Point2d point = null;

    if (terminal != null) {
      PerimeterFunction perimeter = getPerimeterFunction(terminal);

      if (perimeter != null && next != null) {
        Rect bounds = getPerimeterBounds(terminal, border);

        if (bounds.getWidth() > 0 || bounds.getHeight() > 0) {
          point = perimeter(bounds, terminal, next, orthogonal);
        }
      }

      if (point == null) {
        point = getPoint(terminal);
      }
    }

    return point;
  }

  /**
	 * Returns the x-coordinate of the center point for automatic routing.
	 * 
	 * @return Returns the x-coordinate of the routing center point.
	 */
  double getRoutingCenterX(CellState state) {
    double f = (state.getStyle() != null) ? Utils.getFloat(state.getStyle(), Constants.STYLE_ROUTING_CENTER_X) : 0;

    return state.getCenterX() + f * state.getWidth();
  }

  /**
	 * Returns the y-coordinate of the center point for automatic routing.
	 * 
	 * @return Returns the y-coordinate of the routing center point.
	 */
  double getRoutingCenterY(CellState state) {
    double f = (state.getStyle() != null) ? Utils.getFloat(state.getStyle(), Constants.STYLE_ROUTING_CENTER_Y) : 0;

    return state.getCenterY() + f * state.getHeight();
  }

  /**
	 * Returns the perimeter bounds for the given terminal, edge pair.
	 */
  Rect getPerimeterBounds(CellState terminal, double border) {
    if (terminal != null) {
      border += Utils.getDouble(terminal.getStyle(), Constants.STYLE_PERIMETER_SPACING);
    }

    return terminal.getPerimeterBounds(border * _scale);
  }

  /**
	 * Returns the perimeter function for the given state.
	 */
  PerimeterFunction getPerimeterFunction(CellState state) {
    Object perimeter = state.getStyle().get(Constants.STYLE_PERIMETER);

    // Converts string values to objects
    if (perimeter is String) {
      String str = perimeter.toString();
      Object tmp = StyleRegistry.getValue(str);

      if (tmp == null) {
        tmp = Utils.eval(str);
      }

      perimeter = tmp;
    }

    if (perimeter is PerimeterFunction) {
      return perimeter as PerimeterFunction;
    }

    return null;
  }

  /**
	 * Returns the nearest point in the list of absolute points or the center
	 * of the opposite terminal.
	 * 
	 * @param edge Cell state that represents the edge.
	 * @param opposite Cell state that represents the opposite terminal.
	 * @param source bool indicating if the next point for the source or target
	 * should be returned.
	 * @return Returns the nearest point of the opposite side.
	 */
  Point2d getNextPoint(CellState edge, CellState opposite, bool source) {
    List<Point2d> pts = edge.getAbsolutePoints();
    Point2d point = null;

    if (pts != null && (source || pts.length > 2 || opposite == null)) {
      int count = pts.length;
      int index = (source) ? Math.min(1, count - 1) : Math.max(0, count - 2);
      point = pts[index];
    }

    if (point == null && opposite != null) {
      point = new Point2d(opposite.getCenterX(), opposite.getCenterY());
    }

    return point;
  }

  /**
	 * Returns the nearest ancestor terminal that is visible. The edge appears
	 * to be connected to this terminal on the display.
	 * 
	 * @param edge Cell whose visible terminal should be returned.
	 * @param source bool that specifies if the source or target terminal
	 * should be returned.
	 * @return Returns the visible source or target terminal.
	 */
  Object getVisibleTerminal(Object edge, bool source) {
    IGraphModel model = _graph.getModel();
    Object result = model.getTerminal(edge, source);
    Object best = result;

    while (result != null && result != _currentRoot) {
      if (!_graph.isCellVisible(best) || _graph.isCellCollapsed(result)) {
        best = result;
      }

      result = model.getParent(result);
    }

    // Checks if the result is not a layer
    if (model.getParent(best) == model.getRoot()) {
      best = null;
    }

    return best;
  }

  /**
	 * Updates the given state using the bounding box of the absolute points.
	 * Also updates terminal distance, length and segments.
	 * 
	 * @param state Cell state whose bounds should be updated.
	 */
  void updateEdgeBounds(CellState state) {
    List<Point2d> points = state.getAbsolutePoints();
    Point2d p0 = points[0];
    Point2d pe = points[points.length - 1];

    if (p0.getX() != pe.getX() || p0.getY() != pe.getY()) {
      double dx = pe.getX() - p0.getX();
      double dy = pe.getY() - p0.getY();
      state.setTerminalDistance(Math.sqrt(dx * dx + dy * dy));
    } else {
      state.setTerminalDistance(0);
    }

    double length = 0.0;
    List<double> segments = new List<double>(points.length - 1);
    Point2d pt = p0;

    double minX = pt.getX();
    double minY = pt.getY();
    double maxX = minX;
    double maxY = minY;

    for (int i = 1; i < points.length; i++) {
      Point2d tmp = points[i];

      if (tmp != null) {
        double dx = pt.getX() - tmp.getX();
        double dy = pt.getY() - tmp.getY();

        double segment = Math.sqrt(dx * dx + dy * dy);
        segments[i - 1] = segment;
        length += segment;
        pt = tmp;

        minX = Math.min(pt.getX(), minX);
        minY = Math.min(pt.getY(), minY);
        maxX = Math.max(pt.getX(), maxX);
        maxY = Math.max(pt.getY(), maxY);
      }
    }

    state.setLength(length);
    state.setSegments(segments);
    double markerSize = 1; // TODO: include marker size

    state.setX(minX);
    state.setY(minY);
    state.setWidth(Math.max(markerSize, maxX - minX));
    state.setHeight(Math.max(markerSize, maxY - minY));
  }

  /**
	 * Returns the absolute center point along the given edge.
	 */
  //	Point2d getPoint(CellState state)
  //	{
  //		return getPoint(state, null);
  //	}

  /**
	 * Returns the absolute point on the edge for the given relative
	 * geometry as a point. The edge is represented by the given cell state.
	 * 
	 * @param state Represents the state of the parent edge.
	 * @param geometry Optional geometry that represents the relative location.
	 * @return Returns the mxpoint that represents the absolute location
	 * of the given relative geometry.
	 */
  Point2d getPoint(CellState state, [Geometry geometry = null]) {
    double x = state.getCenterX();
    double y = state.getCenterY();

    if (state.getSegments() != null && (geometry == null || geometry.isRelative())) {
      double gx = (geometry != null) ? geometry.getX() / 2 : 0;
      int pointCount = state.getAbsolutePointCount();
      double dist = (gx + 0.5) * state.getLength();
      List<double> segments = state.getSegments();
      double segment = segments[0];
      double length = 0;
      int index = 1;

      while (dist > length + segment && index < pointCount - 1) {
        length += segment;
        segment = segments[index++];
      }

      double factor = (segment == 0) ? 0 : (dist - length) / segment;
      Point2d p0 = state.getAbsolutePoint(index - 1);
      Point2d pe = state.getAbsolutePoint(index);

      if (p0 != null && pe != null) {
        double gy = 0;
        double offsetX = 0;
        double offsetY = 0;

        if (geometry != null) {
          gy = geometry.getY();
          Point2d offset = geometry.getOffset();

          if (offset != null) {
            offsetX = offset.getX();
            offsetY = offset.getY();
          }
        }

        double dx = pe.getX() - p0.getX();
        double dy = pe.getY() - p0.getY();
        double nx = (segment == 0) ? 0 : dy / segment;
        double ny = (segment == 0) ? 0 : dx / segment;

        x = p0.getX() + dx * factor + (nx * gy + offsetX) * _scale;
        y = p0.getY() + dy * factor - (ny * gy - offsetY) * _scale;
      }
    } else if (geometry != null) {
      Point2d offset = geometry.getOffset();

      if (offset != null) {
        x += offset.getX();
        y += offset.getY();
      }
    }

    return new Point2d(x, y);
  }

  /**
	 * Gets the relative point that describes the given, absolute label
	 * position for the given edge state.
	 */
  Point2d getRelativePoint(CellState edgeState, double x, double y) {
    IGraphModel model = _graph.getModel();
    Geometry geometry = model.getGeometry(edgeState.getCell());

    if (geometry != null) {
      int pointCount = edgeState.getAbsolutePointCount();

      if (geometry.isRelative() && pointCount > 1) {
        double totalLength = edgeState.getLength();
        List<double> segments = edgeState.getSegments();

        // Works which line segment the point of the label is closest to
        Point2d p0 = edgeState.getAbsolutePoint(0);
        Point2d pe = edgeState.getAbsolutePoint(1);
        Line2D line = new Line2D.Double(p0.getPoint(), pe.getPoint());
        double minDist = line.ptSegDistSq(x, y);

        int index = 0;
        double tmp = 0;
        double length = 0;

        for (int i = 2; i < pointCount; i++) {
          tmp += segments[i - 2];
          pe = edgeState.getAbsolutePoint(i);

          line = new Line2D.Double(p0.getPoint(), pe.getPoint());
          double dist = line.ptSegDistSq(x, y);

          if (dist < minDist) {
            minDist = dist;
            index = i - 1;
            length = tmp;
          }

          p0 = pe;
        }

        double seg = segments[index];
        p0 = edgeState.getAbsolutePoint(index);
        pe = edgeState.getAbsolutePoint(index + 1);

        double x2 = p0.getX();
        double y2 = p0.getY();

        double x1 = pe.getX();
        double y1 = pe.getY();

        double px = x;
        double py = y;

        double xSegment = x2 - x1;
        double ySegment = y2 - y1;

        px -= x1;
        py -= y1;
        double projlenSq = 0;

        px = xSegment - px;
        py = ySegment - py;
        double dotprod = px * xSegment + py * ySegment;

        if (dotprod <= 0.0) {
          projlenSq = 0;
        } else {
          projlenSq = dotprod * dotprod / (xSegment * xSegment + ySegment * ySegment);
        }

        double projlen = Math.sqrt(projlenSq);

        if (projlen > seg) {
          projlen = seg;
        }

        double yDistance = Line2D.ptLineDist(p0.getX(), p0.getY(), pe.getX(), pe.getY(), x, y);
        int direction = Line2D.relativeCCW(p0.getX(), p0.getY(), pe.getX(), pe.getY(), x, y);

        if (direction == -1) {
          yDistance = -yDistance;
        }

        // Constructs the relative point for the label
        return new Point2d(math.round(((totalLength / 2 - length - projlen) / totalLength) * -2), math.round(yDistance / _scale));
      }
    }

    return new Point2d();
  }

  /**
	 * Returns the states for the given array of cells. The array contains all
	 * states that are not null, that is, the returned array may have less
	 * elements than the given array.
	 */
  List<CellState> getCellStates(List<Object> cells) {
    List<CellState> result = new List<CellState>(cells.length);

    for (int i = 0; i < cells.length; i++) {
      CellState state = getState(cells[i]);

      if (state != null) {
        result.add(state);
      }
    }

    //List<CellState> resultArray = new List<CellState>(result.length);
    return result;//.toArray(resultArray);
  }

  /**
	 * Returns the state for the given cell or null if no state is defined for
	 * the cell.
	 * 
	 * @param cell Cell whose state should be returned.
	 * @return Returns the state for the given cell.
	 */
  //	CellState getState(Object cell)
  //	{
  //		return getState(cell, false);
  //	}

  /**
	 * Returns the cell state for the given cell. If create is true, then
	 * the state is created if it does not yet exist.
	 * 
	 * @param cell Cell for which a new state should be returned.
	 * @param create bool indicating if a new state should be created if it
	 * does not yet exist.
	 * @return Returns the state for the given cell.
	 */
  CellState getState(Object cell, [bool create = false]) {
    CellState state = null;

    if (cell != null) {
      state = _states[cell];

      if (state == null && create && _graph.isCellVisible(cell)) {
        state = createState(cell);
        _states[cell] = state;
      }
    }

    return state;
  }

  /**
	 * Removes and returns the CellState for the given cell.
	 * 
	 * @param cell Cell for which the CellState should be removed.
	 * @return Returns the CellState that has been removed.
	 */
  CellState removeState(Object cell) {
    return (cell != null) ? _states.remove(cell) as CellState : null;
  }

  /**
	 * Creates and returns a cell state for the given cell.
	 * 
	 * @param cell Cell for which a new state should be created.
	 * @return Returns a new state for the given cell.
	 */
  CellState createState(Object cell) {
    return new CellState(this, cell, _graph.getCellStyle(cell));
  }

}


/**
 * Action to change the current root in a view.
 */
class CurrentRootChange implements UndoableChange {

  /**
   * 
   */
  GraphView view;

  /**
   * 
   */
  Object root, previous;

  /**
   * 
   */
  bool up;

  /**
   * Constructs a change of the current root in the given view.
   */
  CurrentRootChange(GraphView view, Object root) {
    this.view = view;
    this.root = root;
    this.previous = this.root;
    this.up = (root == null);

    if (!up) {
      Object tmp = view.getCurrentRoot();
      IGraphModel model = view._graph.getModel();

      while (tmp != null) {
        if (tmp == root) {
          up = true;
          break;
        }

        tmp = model.getParent(tmp);
      }
    }
  }

  /**
   * Returns the graph view where the change happened.
   */
  GraphView getView() {
    return view;
  }

  /**
   * Returns the root.
   */
  Object getRoot() {
    return root;
  }

  /**
   * Returns the previous root.
   */
  Object getPrevious() {
    return previous;
  }

  /**
   * Returns true if the drilling went upwards.
   */
  bool isUp() {
    return up;
  }

  /**
   * Changes the current root of the view.
   */
  void execute() {
    Object tmp = view.getCurrentRoot();
    view._currentRoot = previous;
    previous = tmp;

    Point2d translate = view._graph.getTranslateForRoot(view.getCurrentRoot());

    if (translate != null) {
      view._translate = new Point2d(-translate.getX(), translate.getY());
    }

    // Removes all existing cell states and revalidates
    view.reload();
    up = !up;

    String eventName = (up) ? Event.UP : Event.DOWN;
    view.fireEvent(new EventObj(eventName, ["root", view._currentRoot, "previous", previous]));
  }

}
