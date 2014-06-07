part of graph.view;

//import java.awt.Point;

/**
 * Implements a layout manager that updates the layout for a given transaction.
 * The following example installs an automatic tree layout in a graph:
 * 
 * <code>
 * new LayoutManager(graph) {
 * 
 *   CompactTreeLayout layout = new CompactTreeLayout(graph);
 *   
 *   public IGraphLayout getLayout(Object parent)
 *   {
 *     if (graph.getModel().getChildCount(parent) > 0) {
 *       return layout;
 *     }
 *     return null;
 *   }
 * };
 * </code>
 * 
 * This class fires the following event:
 * 
 * Event.LAYOUT_CELLS fires between begin- and endUpdate after all cells have
 * been layouted in layoutCells. The <code>cells</code> property contains all
 * cells that have been passed to layoutCells.
 */
class LayoutManager extends EventSource {

  /**
   * Defines the type of the source or target terminal. The type is a string
   * passed to Cell.is to check if the rule applies to a cell.
   */
  Graph _graph;

  /**
   * Optional string that specifies the value of the attribute to be passed
   * to Cell.is to check if the rule applies to a cell. Default is true.
   */
  bool _enabled = true;

  /**
   * Optional string that specifies the attributename to be passed to
   * Cell.is to check if the rule applies to a cell. Default is true.
   */
  bool _bubbling = true;

  IEventListener _undoHandler;

  IEventListener _moveHandler;

  LayoutManager(Graph graph) {
    _undoHandler = (Object source, EventObj evt) {
      if (isEnabled()) {
        _beforeUndo(evt.getProperty("edit") as UndoableEdit);
      }
    };
    _moveHandler = (Object source, EventObj evt) {
      if (isEnabled()) {
        _cellsMoved(evt.getProperty("cells") as List<Object>, evt.getProperty("location") as svg.Point);
      }
    };
    setGraph(graph);
  }

  /**
   * @return the enabled
   */
  bool isEnabled() {
    return _enabled;
  }

  /**
   * @param value the enabled to set
   */
  void setEnabled(bool value) {
    _enabled = value;
  }

  /**
   * @return the bubbling
   */
  bool isBubbling() {
    return _bubbling;
  }

  /**
   * @param value the bubbling to set
   */
  void setBubbling(bool value) {
    _bubbling = value;
  }

  /**
   * @return the graph
   */
  Graph getGraph() {
    return _graph;
  }

  /**
   * @param value the graph to set
   */
  void setGraph(Graph value) {
    if (_graph != null) {
      IGraphModel model = _graph.getModel();
      model.removeListener(_undoHandler);
      _graph.removeListener(_moveHandler);
    }

    _graph = value;

    if (_graph != null) {
      IGraphModel model = _graph.getModel();
      model.addListener(Event.BEFORE_UNDO, _undoHandler);
      _graph.addListener(Event.MOVE_CELLS, _moveHandler);
    }
  }

  IGraphLayout _getLayout(Object parent) {
    return null;
  }

  void _cellsMoved(List<Object> cells, svg.Point location) {
    if (cells != null && location != null) {
      IGraphModel model = getGraph().getModel();

      // Checks if a layout exists to take care of the moving
      for (int i = 0; i < cells.length; i++) {
        IGraphLayout layout = _getLayout(model.getParent(cells[i]));

        if (layout != null) {
          layout.moveCell(cells[i], location.x, location.y);
        }
      }
    }
  }

  void _beforeUndo(UndoableEdit edit) {
    Iterable<Object> cells = _getCellsForChanges(edit.getChanges());
    IGraphModel model = getGraph().getModel();

    if (isBubbling()) {
      List<Object> tmp = GraphModel.getParents(model, cells);

      while (tmp.length > 0) {
        if (cells is List) {
          (cells as List).addAll(tmp);
        } else if (cells is Set) {
          (cells as Set).addAll(tmp);
        }
        tmp = GraphModel.getParents(model, tmp);
      }
    }

    _layoutCells(new List<Object>.from(Utils.sortCells(cells, false)));
  }

  Iterable<Object> _getCellsForChanges(List<UndoableChange> changes) {
    Set<Object> result = new HashSet<Object>();
    Iterator<UndoableChange> it = changes.iterator;

    while (it.moveNext()) {
      UndoableChange change = it.current;

      if (change is RootChange) {
        return new HashSet<Object>();
      } else {
        result.addAll(_getCellsForChange(change));
      }
    }

    return result;
  }

  Iterable<Object> _getCellsForChange(UndoableChange change) {
    IGraphModel model = getGraph().getModel();
    Set<Object> result = new HashSet<Object>();

    if (change is ChildChange) {
      ChildChange cc = change;
      Object parent = model.getParent(cc.getChild());

      if (cc.getChild() != null) {
        result.add(cc.getChild());
      }

      if (parent != null) {
        result.add(parent);
      }

      if (cc.getPrevious() != null) {
        result.add(cc.getPrevious());
      }
    } else if (change is TerminalChange || change is GeometryChange) {
      Object cell = (change is TerminalChange) ? change.getCell() : (change as GeometryChange).getCell();

      if (cell != null) {
        result.add(cell);
        Object parent = model.getParent(cell);

        if (parent != null) {
          result.add(parent);
        }
      }
    }

    return result;
  }

  void _layoutCells(List<Object> cells) {
    if (cells.length > 0) {
      // Invokes the layouts while removing duplicates
      IGraphModel model = getGraph().getModel();

      model.beginUpdate();
      try {
        for (int i = 0; i < cells.length; i++) {
          if (cells[i] != model.getRoot()) {
            _executeLayout(_getLayout(cells[i]), cells[i]);
          }
        }

        fireEvent(new EventObj(Event.LAYOUT_CELLS, ["cells", cells]));
      } finally {
        model.endUpdate();
      }
    }
  }

  void _executeLayout(IGraphLayout layout, Object parent) {
    if (layout != null && parent != null) {
      layout.execute(parent);
    }
  }

  void destroy() {
    setGraph(null);
  }

}
