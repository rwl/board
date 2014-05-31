part of graph.layout;

//import java.util.ArrayList;
//import java.util.List;

class CircleLayout extends GraphLayout {

  /**
	 * int specifying the size of the radius. Default is 100.
	 */
  double _radius;

  /**
	 * bool specifying if the circle should be moved to the top,
	 * left corner specified by x0 and y0. Default is false.
	 */
  bool _moveCircle = true;

  /**
	 * int specifying the left coordinate of the circle.
	 * Default is 0.
	 */
  double _x0 = 0.0;

  /**
	 * int specifying the top coordinate of the circle.
	 * Default is 0.
	 */
  double _y0 = 0.0;

  /**
	 * Specifies if all edge points of traversed edges should be removed.
	 * Default is true.
	 */
  bool _resetEdges = false;

  /**
	 *  Specifies if the STYLE_NOEDGESTYLE flag should be set on edges that are
	 * modified by the result. Default is true.
	 */
  bool _disableEdgeStyle = true;

  /**
	 * Constructs a new stack layout layout for the specified graph,
	 * spacing, orientation and offset.
	 */
  //	CircleLayout(Graph graph)
  //	{
  //		this(graph, 100);
  //	}

  /**
	 * Constructs a new stack layout layout for the specified graph,
	 * spacing, orientation and offset.
	 */
  CircleLayout(Graph graph, [double radius = 100.0]) : super(graph) {
    this._radius = radius;
  }

  /**
	 * @return the radius
	 */
  double getRadius() {
    return _radius;
  }

  /**
	 * @param radius the radius to set
	 */
  void setRadius(double radius) {
    this._radius = radius;
  }

  /**
	 * @return the moveCircle
	 */
  bool isMoveCircle() {
    return _moveCircle;
  }

  /**
	 * @param moveCircle the moveCircle to set
	 */
  void setMoveCircle(bool moveCircle) {
    this._moveCircle = moveCircle;
  }

  /**
	 * @return the x0
	 */
  double getX0() {
    return _x0;
  }

  /**
	 * @param x0 the x0 to set
	 */
  void setX0(double x0) {
    this._x0 = x0;
  }

  /**
	 * @return the y0
	 */
  double getY0() {
    return _y0;
  }

  /**
	 * @param y0 the y0 to set
	 */
  void setY0(double y0) {
    this._y0 = y0;
  }

  /**
	 * @return the resetEdges
	 */
  bool isResetEdges() {
    return _resetEdges;
  }

  /**
	 * @param resetEdges the resetEdges to set
	 */
  void setResetEdges(bool resetEdges) {
    this._resetEdges = resetEdges;
  }

  /**
	 * @return the disableEdgeStyle
	 */
  bool isDisableEdgeStyle() {
    return _disableEdgeStyle;
  }

  /**
	 * @param disableEdgeStyle the disableEdgeStyle to set
	 */
  void setDisableEdgeStyle(bool disableEdgeStyle) {
    this._disableEdgeStyle = disableEdgeStyle;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.layout.IGraphLayout#execute(java.lang.Object)
	 */
  void execute(Object parent) {
    IGraphModel model = graph.getModel();

    // Moves the vertices to build a circle. Makes sure the
    // radius is large enough for the vertices to not
    // overlap
    model.beginUpdate();
    try {
      // Gets all vertices inside the parent and finds
      // the maximum dimension of the largest vertex
      double max = 0.0;
      double top = null;
      double left = null;
      List<Object> vertices = new List<Object>();
      int childCount = model.getChildCount(parent);

      for (int i = 0; i < childCount; i++) {
        Object cell = model.getChildAt(parent, i);

        if (!isVertexIgnored(cell)) {
          vertices.add(cell);
          Rect bounds = getVertexBounds(cell);

          if (top == null) {
            top = bounds.getY();
          } else {
            top = Math.min(top, bounds.getY());
          }

          if (left == null) {
            left = bounds.getX();
          } else {
            left = Math.min(left, bounds.getX());
          }

          max = Math.max(max, Math.max(bounds.getWidth(), bounds.getHeight()));
        } else if (!isEdgeIgnored(cell)) {
          if (isResetEdges()) {
            graph.resetEdge(cell);
          }

          if (isDisableEdgeStyle()) {
            setEdgeStyleEnabled(cell, false);
          }
        }
      }

      int vertexCount = vertices.length;
      double r = Math.max(vertexCount * max / Math.PI, _radius);

      // Moves the circle to the specified origin
      if (_moveCircle) {
        left = _x0;
        top = _y0;
      }

      circle(vertices, r, left, top);
    } finally {
      model.endUpdate();
    }
  }

  /**
	 * Executes the circular layout for the specified array
	 * of vertices and the given radius.
	 */
  void circle(List<Object> vertices, double r, double left, double top) {
    int vertexCount = vertices.length;
    double phi = 2 * Math.PI / vertexCount;

    for (int i = 0; i < vertexCount; i++) {
      if (isVertexMovable(vertices[i])) {
        setVertexLocation(vertices[i], left + r + r * Math.sin(i * phi), top + r + r * Math.cos(i * phi));
      }
    }
  }

}
