part of graph.layout;


class PartitionLayout extends GraphLayout {

  /**
   * bool indicating the direction in which the space is partitioned.
   * Default is true.
   */
  bool horizontal;

  /**
   * int that specifies the absolute spacing in pixels between the
   * children. Default is 0.
   */
  int spacing;

  /**
   * int that specifies the absolute inset in pixels for the parent that
   * contains the children. Default is 0.
   */
  int border;

  /**
   * bool that specifies if vertices should be resized. Default is true.
   */
  bool resizeVertices = true;

  /**
   * Constructs a new stack layout layout for the specified graph,
   * spacing, orientation and offset.
   */
  //	PartitionLayout(Graph graph)
  //	{
  //		this(graph, true);
  //	}

  /**
   * Constructs a new stack layout layout for the specified graph,
   * spacing, orientation and offset.
   */
  //	PartitionLayout(Graph graph, bool horizontal)
  //	{
  //		this(graph, horizontal, 0);
  //	}

  /**
   * Constructs a new stack layout layout for the specified graph,
   * spacing, orientation and offset.
   */
  //	PartitionLayout(Graph graph, bool horizontal, int spacing)
  //	{
  //		this(graph, horizontal, spacing, 0);
  //	}

  /**
   * Constructs a new stack layout layout for the specified graph,
   * spacing, orientation and offset.
   */
  PartitionLayout(Graph graph, [bool horizontal = true, int spacing = 0, int border = 0]) : super(graph) {
    this.horizontal = horizontal;
    this.spacing = spacing;
    this.border = border;
  }

  /*
   * (non-Javadoc)
   * @see graph.layout.GraphLayout#move(java.lang.Object, double, double)
   */
  void moveCell(Object cell, double x, double y) {
    IGraphModel model = graph.getModel();
    Object parent = model.getParent(cell);

    if (cell is ICell && parent is ICell) {
      int i = 0;
      double last = 0.0;
      int childCount = model.getChildCount(parent);

      // Finds index of the closest swimlane
      // TODO: Take into account the orientation
      for (i = 0; i < childCount; i++) {
        Object child = model.getChildAt(parent, i);
        Rect bounds = getVertexBounds(child);

        if (bounds != null) {
          double tmp = bounds.getX() + bounds.getWidth() / 2;

          if (last < x && tmp > x) {
            break;
          }

          last = tmp;
        }
      }

      // Changes child order in parent
      int idx = parent.getIndex(cell);
      idx = Math.max(0, i - ((i > idx) ? 1 : 0));

      model.add(parent, cell, idx);
    }
  }

  /**
   * Hook for subclassers to return the container size.
   */
  Rect getContainerSize() {
    return new Rect();
  }

  /*
   * (non-Javadoc)
   * @see graph.layout.IGraphLayout#execute(java.lang.Object)
   */
  void execute(Object parent) {
    IGraphModel model = graph.getModel();
    Geometry pgeo = model.getGeometry(parent);

    // Handles special case where the parent is either a layer with no
    // geometry or the current root of the view in which case the size
    // of the graph's container will be used.
    if (pgeo == null && model.getParent(parent) == model.getRoot() || parent == graph.getView().getCurrentRoot()) {
      Rect tmp = getContainerSize();
      pgeo = new Geometry(0.0, 0.0, tmp.getWidth(), tmp.getHeight());
    }

    if (pgeo != null) {
      int childCount = model.getChildCount(parent);
      List<Object> children = new List<Object>(childCount);

      for (int i = 0; i < childCount; i++) {
        Object child = model.getChildAt(parent, i);

        if (!isVertexIgnored(child) && isVertexMovable(child)) {
          children.add(child);
        }
      }

      int n = children.length;

      if (n > 0) {
        double x0 = border.toDouble();
        double y0 = border.toDouble();
        double other = (horizontal) ? pgeo.getHeight() : pgeo.getWidth();
        other -= 2 * border;

        Rect size = graph.getStartSize(parent);

        other -= (horizontal) ? size.getHeight() : size.getWidth();
        x0 = x0 + size.getWidth();
        y0 = y0 + size.getHeight();

        double tmp = (border + (n - 1) * spacing).toDouble();
        double value = (horizontal) ? ((pgeo.getWidth() - x0 - tmp) / n) : ((pgeo.getHeight() - y0 - tmp) / n);

        // Avoids negative values, that is values where the sum of the
        // spacing plus the border is larger then the available space
        if (value > 0) {
          model.beginUpdate();
          try {
            for (int i = 0; i < n; i++) {
              Object child = children[i];
              Geometry geo = model.getGeometry(child);

              if (geo != null) {
                geo = geo.clone() as Geometry;
                geo.setX(x0);
                geo.setY(y0);

                if (horizontal) {
                  if (resizeVertices) {
                    geo.setWidth(value);
                    geo.setHeight(other);
                  }

                  x0 += value + spacing;
                } else {
                  if (resizeVertices) {
                    geo.setHeight(value);
                    geo.setWidth(other);
                  }

                  y0 += value + spacing;
                }

                model.setGeometry(child, geo);
              }
            }
          } finally {
            model.endUpdate();
          }
        }
      }
    }
  }

}
