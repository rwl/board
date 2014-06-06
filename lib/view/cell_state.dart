/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.view;


/**
 * Represents the current state of a cell in a given graph view.
 */
class CellState extends Rect {

  /**
   * Reference to the enclosing graph view.
   */
  GraphView _view;

  /**
   * Reference to the cell that is represented by this state.
   */
  Object _cell;

  /**
   * Holds the current label value, including newlines which result from
   * word wrapping.
   */
  String _label;

  /**
   * Contains an array of key, value pairs that represent the style of the
   * cell.
   */
  Map<String, Object> _style;

  /**
   * Holds the origin for all child cells.
   */
  Point2d _origin = new Point2d();

  /**
   * List of mxPoints that represent the absolute points of an edge.
   */
  List<Point2d> _absolutePoints;

  /**
   * Holds the absolute offset. For edges, this is the absolute coordinates
   * of the label position. For vertices, this is the offset of the label
   * relative to the top, left corner of the vertex.
   */
  Point2d _absoluteOffset = new Point2d();

  /**
   * Caches the distance between the end points and the length of an edge.
   */
  double _terminalDistance, _length;

  /**
   * Array of numbers that represent the cached length of each segment of the
   * edge.
   */
  List<double> _segments;

  /**
   * Holds the rectangle which contains the label.
   */
  Rect _labelBounds;

  /**
   * Holds the largest rectangle which contains all rendering for this cell.
   */
  Rect _boundingBox;

  /**
   * Specifies if the state is invalid. Default is true.
   */
  bool _invalid = true;

  /**
   * Caches the visible source and target terminal states.
   */
  CellState _visibleSourceState, _visibleTargetState;

  /**
   * Constructs an empty cell state.
   */
//  CellState() {
//    this(null, null, null);
//  }

  /**
   * Constructs a new object that represents the current state of the given
   * cell in the specified view.
   * 
   * @param view Graph view that contains the state.
   * @param cell Cell that this state represents.
   * @param style Array of key, value pairs that constitute the style.
   */
  CellState([GraphView view=null, Object cell=null, Map<String, Object> style=null]) {
    setView(view);
    setCell(cell);
    setStyle(style);
  }

  /**
   * Returns true if the state is invalid.
   */
  bool isInvalid() {
    return _invalid;
  }

  /**
   * Sets the invalid state.
   */
  void setInvalid(bool invalid) {
    this._invalid = invalid;
  }

  /**
   * Returns the enclosing graph view.
   * 
   * @return the view
   */
  GraphView getView() {
    return _view;
  }

  /**
   * Sets the enclosing graph view. 
   *
   * @param view the view to set
   */
  void setView(GraphView view) {
    this._view = view;
  }

  /**
   * Returns the current label.
   */
  String getLabel() {
    return _label;
  }

  /**
   * Returns the current label.
   */
  void setLabel(String value) {
    _label = value;
  }

  /**
   * Returns the cell that is represented by this state.
   * 
   * @return the cell
   */
  Object getCell() {
    return _cell;
  }

  /**
   * Sets the cell that this state represents.
   * 
   * @param cell the cell to set
   */
  void setCell(Object cell) {
    this._cell = cell;
  }

  /**
   * Returns the cell style as a map of key, value pairs.
   * 
   * @return the style
   */
  Map<String, Object> getStyle() {
    return _style;
  }

  /**
   * Sets the cell style as a map of key, value pairs.
   * 
   * @param style the style to set
   */
  void setStyle(Map<String, Object> style) {
    this._style = style;
  }

  /**
   * Returns the origin for the children.
   * 
   * @return the origin
   */
  Point2d getOrigin() {
    return _origin;
  }

  /**
   * Sets the origin for the children.
   * 
   * @param origin the origin to set
   */
  void setOrigin(Point2d origin) {
    this._origin = origin;
  }

  /**
   * Returns the absolute point at the given index.
   * 
   * @return the Point2d at the given index
   */
  Point2d getAbsolutePoint(int index) {
    return _absolutePoints[index];
  }

  /**
   * Returns the absolute point at the given index.
   * 
   * @return the Point2d at the given index
   */
  Point2d setAbsolutePoint(int index, Point2d point) {
    return _absolutePoints[index] = point;
  }

  /**
   * Returns the number of absolute points.
   * 
   * @return the absolutePoints
   */
  int getAbsolutePointCount() {
    return (_absolutePoints != null) ? _absolutePoints.length : 0;
  }

  /**
   * Returns the absolute points.
   * 
   * @return the absolutePoints
   */
  List<Point2d> getAbsolutePoints() {
    return _absolutePoints;
  }

  /**
   * Returns the absolute points.
   * 
   * @param absolutePoints the absolutePoints to set
   */
  void setAbsolutePoints(List<Point2d> absolutePoints) {
    this._absolutePoints = absolutePoints;
  }

  /**
   * Returns the absolute offset.
   * 
   * @return the absoluteOffset
   */
  Point2d getAbsoluteOffset() {
    return _absoluteOffset;
  }

  /**
   * Returns the absolute offset.
   * 
   * @param absoluteOffset the absoluteOffset to set
   */
  void setAbsoluteOffset(Point2d absoluteOffset) {
    this._absoluteOffset = absoluteOffset;
  }

  /**
   * Returns the terminal distance.
   * 
   * @return the terminalDistance
   */
  double getTerminalDistance() {
    return _terminalDistance;
  }

  /**
   * Sets the terminal distance.
   * 
   * @param terminalDistance the terminalDistance to set
   */
  void setTerminalDistance(double terminalDistance) {
    this._terminalDistance = terminalDistance;
  }

  /**
   * Returns the length.
   * 
   * @return the length
   */
  double getLength() {
    return _length;
  }

  /**
   * Sets the length.
   * 
   * @param length the length to set
   */
  void setLength(double length) {
    this._length = length;
  }

  /**
   * Returns the length of the segments.
   * 
   * @return the segments
   */
  List<double> getSegments() {
    return _segments;
  }

  /**
   * Sets the length of the segments.
   * 
   * @param segments the segments to set
   */
  void setSegments(List<double> segments) {
    this._segments = segments;
  }

  /**
   * Returns the label bounds.
   * 
   * @return Returns the label bounds for this state.
   */
  Rect getLabelBounds() {
    return _labelBounds;
  }

  /**
   * Sets the label bounds.
   * 
   * @param labelBounds
   */
  void setLabelBounds(Rect labelBounds) {
    this._labelBounds = labelBounds;
  }

  /**
   * Returns the bounding box.
   * 
   * @return Returns the bounding box for this state.
   */
  Rect getBoundingBox() {
    return _boundingBox;
  }

  /**
   * Sets the bounding box.
   * 
   * @param boundingBox
   */
  void setBoundingBox(Rect boundingBox) {
    this._boundingBox = boundingBox;
  }

  /**
   * Returns the rectangle that should be used as the perimeter of the cell.
   * This implementation adds the perimeter spacing to the rectangle
   * defined by this cell state.
   * 
   * @return Returns the rectangle that defines the perimeter.
   */
//  Rect getPerimeterBounds() {
//    return getPerimeterBounds(0);
//  }

  /**
   * Returns the rectangle that should be used as the perimeter of the cell.
   * 
   * @return Returns the rectangle that defines the perimeter.
   */
  Rect getPerimeterBounds([double border=0.0]) {
    Rect bounds = new Rect.rectangle(getRectangle());

    if (border != 0) {
      bounds.grow(border);
    }

    return bounds;
  }

  /**
   * Sets the first or last point in the list of points depending on isSource.
   * 
   * @param point Point that represents the terminal point.
   * @param isSource bool that specifies if the first or last point should
   * be assigned.
   */
  void setAbsoluteTerminalPoint(Point2d point, bool isSource) {
    if (isSource) {
      if (_absolutePoints == null) {
        _absolutePoints = new List<Point2d>();
      }

      if (_absolutePoints.length == 0) {
        _absolutePoints.add(point);
      } else {
        _absolutePoints[0] = point;
      }
    } else {
      if (_absolutePoints == null) {
        _absolutePoints = new List<Point2d>();
        _absolutePoints.add(null);
        _absolutePoints.add(point);
      } else if (_absolutePoints.length == 1) {
        _absolutePoints.add(point);
      } else {
        _absolutePoints[_absolutePoints.length - 1] = point;
      }
    }
  }

  /**
   * Returns the visible source or target terminal cell.
   * 
   * @param source bool that specifies if the source or target cell should be
   * returned.
   */
  Object getVisibleTerminal(bool source) {
    CellState tmp = getVisibleTerminalState(source);

    return (tmp != null) ? tmp.getCell() : null;
  }

  /**
   * Returns the visible source or target terminal state.
   * 
   * @param bool that specifies if the source or target state should be
   * returned.
   */
  CellState getVisibleTerminalState(bool source) {
    return (source) ? _visibleSourceState : _visibleTargetState;
  }

  /**
   * Sets the visible source or target terminal state.
   * 
   * @param terminalState Cell state that represents the terminal.
   * @param source bool that specifies if the source or target state should be set.
   */
  void setVisibleTerminalState(CellState terminalState, bool source) {
    if (source) {
      _visibleSourceState = terminalState;
    } else {
      _visibleTargetState = terminalState;
    }
  }

  /**
   * Returns a clone of this state where all members are deeply cloned
   * except the view and cell references, which are copied with no
   * cloning to the new instance.
   */
  Object clone() {
    CellState clone = new CellState(_view, _cell, _style);

    if (_label != null) {
      clone._label = _label;
    }

    if (_absolutePoints != null) {
      clone._absolutePoints = new List<Point2d>();

      for (int i = 0; i < _absolutePoints.length; i++) {
        clone._absolutePoints.add(_absolutePoints[i].clone() as Point2d);
      }
    }

    if (_origin != null) {
      clone._origin = _origin.clone() as Point2d;
    }

    if (_absoluteOffset != null) {
      clone._absoluteOffset = _absoluteOffset.clone() as Point2d;
    }

    if (_labelBounds != null) {
      clone._labelBounds = _labelBounds.clone() as Rect;
    }

    if (_boundingBox != null) {
      clone._boundingBox = _boundingBox.clone() as Rect;
    }

    clone._terminalDistance = _terminalDistance;
    clone._segments = _segments;
    clone._length = _length;
    clone.x = this.x;
    clone.y = this.y;
    clone.width = this.width;
    clone.height = this.height;

    return clone;
  }

}
