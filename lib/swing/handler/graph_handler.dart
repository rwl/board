/**
 * Copyright (c) 2008-2012, JGraph Ltd
 * 
 * Known issue: Drag image size depends on the initial position and may sometimes
 * not align with the grid when dragging. This is because the rounding of the width
 * and height at the initial position may be different than that at the current
 * position as the left and bottom side of the shape must align to the grid lines.
 */
part of graph.swing.handler;

//import java.awt.AlphaComposite;
//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Image;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.datatransfer.Transferable;
//import java.awt.dnd.DnDConstants;
//import java.awt.dnd.DragGestureEvent;
//import java.awt.dnd.DragGestureListener;
//import java.awt.dnd.DragSource;
//import java.awt.dnd.DragSourceAdapter;
//import java.awt.dnd.DragSourceDropEvent;
//import java.awt.dnd.DropTarget;
//import java.awt.dnd.DropTargetDragEvent;
//import java.awt.dnd.DropTargetDropEvent;
//import java.awt.dnd.DropTargetEvent;
//import java.awt.dnd.DropTargetListener;
//import java.awt.event.InputEvent;
//import java.awt.event.MouseEvent;
//import java.beans.PropertyChangeEvent;
//import java.beans.PropertyChangeListener;
//import java.util.TooManyListenersException;

//import javax.swing.ImageIcon;
//import javax.swing.JComponent;
//import javax.swing.SwingUtilities;
//import javax.swing.TransferHandler;

class GraphHandler extends MouseAdapter implements DropTargetListener {

  /**
	 * 
	 */
  //	static final long serialVersionUID = 3241109976696510225L;

  /**
	 * Default is Cursor.DEFAULT_CURSOR.
	 */
  static Cursor DEFAULT_CURSOR = new Cursor(Cursor.DEFAULT_CURSOR);

  /**
	 * Default is Cursor.MOVE_CURSOR.
	 */
  static Cursor MOVE_CURSOR = new Cursor(Cursor.MOVE_CURSOR);

  /**
	 * Default is Cursor.HAND_CURSOR.
	 */
  static Cursor FOLD_CURSOR = new Cursor(Cursor.HAND_CURSOR);

  /**
	 * Reference to the enclosing graph component.
	 */
  GraphComponent _graphComponent;

  /**
	 * Specifies if the handler is enabled. Default is true.
	 */
  bool _enabled = true;

  /**
	 * Specifies if cloning by control-drag is enabled. Default is true.
	 */
  bool _cloneEnabled = true;

  /**
	 * Specifies if moving is enabled. Default is true.
	 */
  bool _moveEnabled = true;

  /**
	 * Specifies if moving is enabled. Default is true.
	 */
  bool _selectEnabled = true;

  /**
	 * Specifies if the cell marker should be called (for splitting edges and
	 * dropping cells into groups). Default is true.
	 */
  bool _markerEnabled = true;

  /**
	 * Specifies if cells may be moved out of their parents. Default is true.
	 */
  bool _removeCellsFromParent = true;

  /**
	 * 
	 */
  MovePreview _movePreview;

  /**
	 * Specifies if live preview should be used if possible. Default is false.
	 */
  bool _livePreview = false;

  /**
	 * Specifies if an image should be used for preview. Default is true.
	 */
  bool _imagePreview = true;

  /**
	 * Specifies if the preview should be centered around the mouse cursor if there
	 * was no mouse click to define the offset within the shape (eg. drag from
	 * external source). Default is true.
	 */
  bool _centerPreview = true;

  /**
	 * Specifies if this handler should be painted on top of all other components.
	 * Default is true.
	 */
  bool _keepOnTop = true;

  /**
	 * Holds the cells that are being moved by this handler.
	 */
  /*transient*/ List<Object> _cells;

  /**
	 * Holds the image that is being used for the preview.
	 */
  /*transient*/ ImageIcon _dragImage;

  /**
	 * Holds the start location of the mouse gesture.
	 */
  /*transient*/ Point _first;

  /**
	 * 
	 */
  /*transient*/ Object _cell;

  /**
	 * 
	 */
  /*transient*/ Object _initialCell;

  /**
	 * 
	 */
  /*transient*/ List<Object> _dragCells;

  /**
	 * 
	 */
  /*transient*/ CellMarker _marker;

  /**
	 * 
	 */
  /*transient*/ bool _canImport;

  /**
	 * Scaled, translated bounds of the selection cells.
	 */
  /*transient*/ Rect _cellBounds;

  /**
	 * Scaled, translated bounding box of the selection cells.
	 */
  /*transient*/ Rect _bbox;

  /**
	 * Unscaled, untranslated bounding box of the selection cells.
	 */
  /*transient*/ Rect _transferBounds;

  /**
	 * 
	 */
  /*transient*/ bool _visible = false;

  /**
	 * 
	 */
  /*transient*/ Rectangle _previewBounds = null;

  /**
	 * Workaround for alt-key-state not correct in mouseReleased. Note: State
	 * of the alt-key is not available during drag-and-drop.
	 */
  /*transient*/ bool _gridEnabledEvent = false;

  /**
	 * Workaround for shift-key-state not correct in mouseReleased.
	 */
  /*transient*/ bool _constrainedEvent = false;

  /**
	 * Reference to the current drop target.
	 */
  /*transient*/ DropTarget _currentDropTarget = null;

  /**
	 * 
	 * @param graphComponent
	 */
  GraphHandler(final GraphComponent graphComponent) {
    this._graphComponent = graphComponent;
    _marker = _createMarker();
    _movePreview = _createMovePreview();

    // Installs the paint handler
    graphComponent.addListener(Event.AFTER_PAINT, (Object sender, EventObj evt) {
      Graphics g = evt.getProperty("g") as Graphics;
      paint(g);
    });

    // Listens to all mouse events on the rendering control
    graphComponent.getGraphControl().addMouseListener(this);
    graphComponent.getGraphControl().addMouseMotionListener(this);

    // Drag target creates preview image
    _installDragGestureHandler();

    // Listens to dropped graph cells
    _installDropTargetHandler();

    // Listens to changes of the transferhandler
    graphComponent.addPropertyChangeListener((PropertyChangeEvent evt) {
      if (evt.getPropertyName().equals("transferHandler")) {
        if (_currentDropTarget != null) {
          _currentDropTarget.removeDropTargetListener(this);
        }

        _installDropTargetHandler();
      }
    });

    setVisible(false);
  }

  /**
	 * 
	 */
  void _installDragGestureHandler() {
    DragGestureListener dragGestureListener = (DragGestureEvent e) {
      if (_graphComponent.isDragEnabled() && _first != null) {
        final TransferHandler th = _graphComponent.getTransferHandler();

        if (th is GraphTransferHandler) {
          final GraphTransferable t = (th as GraphTransferHandler).createTransferable(_graphComponent) as GraphTransferable;

          if (t != null) {
            e.startDrag(null, SwingConstants.EMPTY_IMAGE, new Point(), t, new GraphHandlerDragSourceAdapter(this, t, th));
          }
        }
      }
    };

    DragSource dragSource = new DragSource();
    dragSource.createDefaultDragGestureRecognizer(_graphComponent.getGraphControl(), (isCloneEnabled()) ? DnDConstants.ACTION_COPY_OR_MOVE : DnDConstants.ACTION_MOVE, dragGestureListener);
  }

  /**
	 * 
	 */
  void _installDropTargetHandler() {
    DropTarget dropTarget = _graphComponent.getDropTarget();

    try {
      if (dropTarget != null) {
        dropTarget.addDropTargetListener(this);
        _currentDropTarget = dropTarget;
      }
    } on TooManyListenersException catch (tmle) {
      // should not happen... swing drop target is multicast
    }
  }

  /**
	 * 
	 */
  bool isVisible() {
    return _visible;
  }

  /**
	 * 
	 */
  void setVisible(bool value) {
    if (_visible != value) {
      _visible = value;

      if (_previewBounds != null) {
        _graphComponent.getGraphControl().repaint(_previewBounds);
      }
    }
  }

  /**
	 * 
	 */
  void setPreviewBounds(Rectangle bounds) {
    if ((bounds == null && _previewBounds != null) || (bounds != null && _previewBounds == null) || (bounds != null && _previewBounds != null && !bounds.equals(_previewBounds))) {
      Rectangle dirty = null;

      if (isVisible()) {
        dirty = _previewBounds;

        if (dirty != null) {
          dirty.add(bounds);
        } else {
          dirty = bounds;
        }
      }

      _previewBounds = bounds;

      if (dirty != null) {
        _graphComponent.getGraphControl().repaint(dirty.x - 1, dirty.y - 1, dirty.width + 2, dirty.height + 2);
      }
    }
  }

  /**
	 * 
	 */
  MovePreview _createMovePreview() {
    return new MovePreview(_graphComponent);
  }

  /**
	 * 
	 */
  MovePreview getMovePreview() {
    return _movePreview;
  }

  /**
	 * 
	 */
  CellMarker _createMarker() {
    CellMarker marker = new GraphHandlerCellMarker(this, graphComponent, Color.BLUE);

    // Swimlane content area will not be transparent drop targets
    marker.setSwimlaneContentEnabled(true);

    return marker;
  }

  /**
	 * 
	 */
  GraphComponent getGraphComponent() {
    return _graphComponent;
  }

  /**
	 * 
	 */
  bool isEnabled() {
    return _enabled;
  }

  /**
	 * 
	 */
  void setEnabled(bool value) {
    _enabled = value;
  }

  /**
	 * 
	 */
  bool isCloneEnabled() {
    return _cloneEnabled;
  }

  /**
	 * 
	 */
  void setCloneEnabled(bool value) {
    _cloneEnabled = value;
  }

  /**
	 * 
	 */
  bool isMoveEnabled() {
    return _moveEnabled;
  }

  /**
	 * 
	 */
  void setMoveEnabled(bool value) {
    _moveEnabled = value;
  }

  /**
	 * 
	 */
  bool isMarkerEnabled() {
    return _markerEnabled;
  }

  /**
	 * 
	 */
  void setMarkerEnabled(bool value) {
    _markerEnabled = value;
  }

  /**
	 * 
	 */
  CellMarker getMarker() {
    return _marker;
  }

  /**
	 * 
	 */
  void setMarker(CellMarker value) {
    _marker = value;
  }

  /**
	 * 
	 */
  bool isSelectEnabled() {
    return _selectEnabled;
  }

  /**
	 * 
	 */
  void setSelectEnabled(bool value) {
    _selectEnabled = value;
  }

  /**
	 * 
	 */
  bool isRemoveCellsFromParent() {
    return _removeCellsFromParent;
  }

  /**
	 * 
	 */
  void setRemoveCellsFromParent(bool value) {
    _removeCellsFromParent = value;
  }

  /**
	 * 
	 */
  bool isLivePreview() {
    return _livePreview;
  }

  /**
	 * 
	 */
  void setLivePreview(bool value) {
    _livePreview = value;
  }

  /**
	 * 
	 */
  bool isImagePreview() {
    return _imagePreview;
  }

  /**
	 * 
	 */
  void setImagePreview(bool value) {
    _imagePreview = value;
  }

  /**
	 * 
	 */
  bool isCenterPreview() {
    return _centerPreview;
  }

  /**
	 * 
	 */
  void setCenterPreview(bool value) {
    _centerPreview = value;
  }

  /**
	 * 
	 */
  void updateDragImage(List<Object> cells) {
    _dragImage = null;

    if (cells != null && cells.length > 0) {
      Image img = CellRenderer.createBufferedImage(_graphComponent.getGraph(), cells, _graphComponent.getGraph().getView().getScale(), null, _graphComponent.isAntiAlias(), null, _graphComponent.getCanvas());

      if (img != null) {
        _dragImage = new ImageIcon(img);
        _previewBounds.setSize(_dragImage.getIconWidth(), _dragImage.getIconHeight());
      }
    }
  }

  /**
	 * 
	 */
  void mouseMoved(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()) {
      Cursor cursor = _getCursor(e);

      if (cursor != null) {
        _graphComponent.getGraphControl().setCursor(cursor);
        e.consume();
      } else {
        _graphComponent.getGraphControl().setCursor(DEFAULT_CURSOR);
      }
    }
  }

  /**
	 * 
	 */
  Cursor _getCursor(MouseEvent e) {
    Cursor cursor = null;

    if (isMoveEnabled()) {
      Object cell = _graphComponent.getCellAt(e.getX(), e.getY(), false);

      if (cell != null) {
        if (_graphComponent.isFoldingEnabled() && _graphComponent.hitFoldingIcon(cell, e.getX(), e.getY())) {
          cursor = FOLD_CURSOR;
        } else if (_graphComponent.getGraph().isCellMovable(cell)) {
          cursor = MOVE_CURSOR;
        }
      }
    }

    return cursor;
  }

  /**
	 * 
	 */
  void dragEnter(DropTargetDragEvent e) {
    JComponent component = _getDropTarget(e);
    TransferHandler th = component.getTransferHandler();
    bool isLocal = th is GraphTransferHandler && (th as GraphTransferHandler).isLocalDrag();

    if (isLocal) {
      _canImport = true;
    } else {
      _canImport = _graphComponent.isImportEnabled() && th.canImport(component, e.getCurrentDataFlavors());
    }

    if (_canImport) {
      _transferBounds = null;
      setVisible(false);

      try {
        Transferable t = e.getTransferable();

        if (t.isDataFlavorSupported(GraphTransferable.dataFlavor)) {
          GraphTransferable gt = (t as GraphTransferable).getTransferData(GraphTransferable.dataFlavor);
          _dragCells = gt.getCells();

          if (gt.getBounds() != null) {
            Graph graph = _graphComponent.getGraph();
            double scale = graph.getView().getScale();
            _transferBounds = gt.getBounds();
            int w = math.ceil((_transferBounds.getWidth() + 1) * scale) as int;
            int h = math.ceil((_transferBounds.getHeight() + 1) * scale) as int;
            setPreviewBounds(new Rectangle(_transferBounds.getX() as int, _transferBounds.getY() as int, w, h));

            if (_imagePreview) {
              // Does not render fixed cells for local preview
              // but ignores movable state for non-local previews
              if (isLocal) {
                if (!isLivePreview()) {
                  updateDragImage(graph.getMovableCells(_dragCells));
                }
              } else {
                List<Object> tmp = _graphComponent.getImportableCells(_dragCells);
                updateDragImage(tmp);

                // Shows no drag icon if import is allowed but none
                // of the cells can be imported
                if (tmp == null || tmp.length == 0) {
                  _canImport = false;
                  e.rejectDrag();

                  return;
                }
              }
            }

            setVisible(true);
          }
        }

        e.acceptDrag(TransferHandler.COPY_OR_MOVE);
      } on Exception catch (ex) {
        // do nothing
        ex.printStackTrace();
      }

    } else {
      e.rejectDrag();
    }
  }

  /**
	 * 
	 */
  void mousePressed(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed() && !_graphComponent.isForceMarqueeEvent(e)) {
      _cell = _graphComponent.getCellAt(e.getX(), e.getY(), false);
      _initialCell = _cell;

      if (_cell != null) {
        if (isSelectEnabled() && !_graphComponent.getGraph().isCellSelected(_cell)) {
          _graphComponent.selectCellForEvent(_cell, e);
          _cell = null;
        }

        // Starts move if the cell under the mouse is movable and/or any
        // cells of the selection are movable
        if (isMoveEnabled() && !e.isPopupTrigger()) {
          start(e);
          e.consume();
        }
      } else if (e.isPopupTrigger()) {
        _graphComponent.getGraph().clearSelection();
      }
    }
  }

  /**
	 * 
	 */
  List<Object> getCells(Object initialCell) {
    Graph graph = _graphComponent.getGraph();

    return graph.getMovableCells(graph.getSelectionCells());
  }

  /**
	 * 
	 */
  void start(MouseEvent e) {
    if (isLivePreview()) {
      _movePreview.start(e, _graphComponent.getGraph().getView().getState(_initialCell));
    } else {
      Graph graph = _graphComponent.getGraph();

      // Constructs an array with cells that are indeed movable
      _cells = getCells(_initialCell);
      _cellBounds = graph.getView().getBounds(_cells);

      if (_cellBounds != null) {
        // Updates the size of the graph handler that is in
        // charge of painting all other handlers
        _bbox = graph.getView().getBoundingBox(_cells);

        Rectangle bounds = _cellBounds.getRectangle();
        bounds.width += 1;
        bounds.height += 1;
        setPreviewBounds(bounds);
      }
    }

    _first = e.getPoint();
  }

  /**
	 * 
	 */
  void dropActionChanged(DropTargetDragEvent e) {
    // do nothing
  }

  /**
	 * 
	 * @param e
	 */
  void dragOver(DropTargetDragEvent e) {
    if (_canImport) {
      mouseDragged(_createEvent(e));
      GraphTransferHandler handler = _getGraphTransferHandler(e);

      if (handler != null) {
        Graph graph = _graphComponent.getGraph();
        double scale = graph.getView().getScale();
        Point pt = SwingUtilities.convertPoint(_graphComponent, e.getLocation(), _graphComponent.getGraphControl());

        pt = _graphComponent.snapScaledPoint(new Point2d(pt)).getPoint();
        handler.setLocation(new Point(pt));

        int dx = 0;
        int dy = 0;

        // Centers the preview image
        if (_centerPreview && _transferBounds != null) {
          dx -= math.round(_transferBounds.getWidth() * scale / 2);
          dy -= math.round(_transferBounds.getHeight() * scale / 2);
        }

        // Sets the drop offset so that the location in the transfer
        // handler reflects the actual mouse position
        handler.setOffset(new Point(graph.snap(dx / scale) as int, graph.snap(dy / scale) as int));
        pt.translate(dx, dy);

        // Shifts the preview so that overlapping parts do not
        // affect the centering
        if (_transferBounds != null && _dragImage != null) {
          dx = math.round((_dragImage.getIconWidth() - 2 - _transferBounds.getWidth() * scale) / 2) as int;
          dy = math.round((_dragImage.getIconHeight() - 2 - _transferBounds.getHeight() * scale) / 2) as int;
          pt.translate(-dx, -dy);
        }

        if (!handler.isLocalDrag() && _previewBounds != null) {
          setPreviewBounds(new Rectangle(pt, _previewBounds.getSize()));
        }
      }
    } else {
      e.rejectDrag();
    }
  }

  /**
	 * 
	 */
  Point convertPoint(Point pt) {
    pt = SwingUtilities.convertPoint(_graphComponent, pt, _graphComponent.getGraphControl());

    pt.x -= _graphComponent.getHorizontalScrollBar().getValue();
    pt.y -= _graphComponent.getVerticalScrollBar().getValue();

    return pt;
  }

  /**
	 * 
	 */
  void mouseDragged(MouseEvent e) {
    // LATER: Check scrollborder, use scroll-increments, do not
    // scroll when over ruler dragging from library
    if (_graphComponent.isAutoScroll()) {
      _graphComponent.getGraphControl().scrollRectToVisible(new Rectangle(e.getPoint()));
    }

    if (!e.isConsumed()) {
      _gridEnabledEvent = _graphComponent.isGridEnabledEvent(e);
      _constrainedEvent = _graphComponent.isConstrainedEvent(e);

      if (_constrainedEvent && _first != null) {
        int x = e.getX();
        int y = e.getY();

        if (math.abs(e.getX() - _first.x) > math.abs(e.getY() - _first.y)) {
          y = _first.y;
        } else {
          x = _first.x;
        }

        e = new MouseEvent(e.getComponent(), e.getID(), e.getWhen(), e.getModifiers(), x, y, e.getClickCount(), e.isPopupTrigger(), e.getButton());
      }

      if (isVisible() && isMarkerEnabled()) {
        _marker.process(e);
      }

      if (_first != null) {
        if (_movePreview.isActive()) {
          double dx = e.getX() - _first.x;
          double dy = e.getY() - _first.y;

          if (_graphComponent.isGridEnabledEvent(e)) {
            Graph graph = _graphComponent.getGraph();

            dx = graph.snap(dx);
            dy = graph.snap(dy);
          }

          bool clone = isCloneEnabled() && _graphComponent.isCloneEvent(e);
          _movePreview.update(e, dx, dy, clone);
          e.consume();
        } else if (_cellBounds != null) {
          double dx = e.getX() - _first.x;
          double dy = e.getY() - _first.y;

          if (_previewBounds != null) {
            setPreviewBounds(new Rectangle(_getPreviewLocation(e, _gridEnabledEvent), _previewBounds.getSize()));
          }

          if (!isVisible() && _graphComponent.isSignificant(dx, dy)) {
            if (_imagePreview && _dragImage == null && !_graphComponent.isDragEnabled()) {
              updateDragImage(_cells);
            }

            setVisible(true);
          }

          e.consume();
        }
      }
    }
  }

  /**
	 * 
	 */
  Point _getPreviewLocation(MouseEvent e, bool gridEnabled) {
    int x = 0;
    int y = 0;

    if (_first != null && _cellBounds != null) {
      Graph graph = _graphComponent.getGraph();
      double scale = graph.getView().getScale();
      Point2d trans = graph.getView().getTranslate();

      // LATER: Drag image _size_ depends on the initial position and may sometimes
      // not align with the grid when dragging. This is because the rounding of the width
      // and height at the initial position may be different than that at the current
      // position as the left and bottom side of the shape must align to the grid lines.
      // Only fix is a full repaint of the drag cells at each new mouse location.
      double dx = e.getX() - _first.x;
      double dy = e.getY() - _first.y;

      double dxg = ((_cellBounds.getX() + dx) / scale) - trans.getX();
      double dyg = ((_cellBounds.getY() + dy) / scale) - trans.getY();

      if (gridEnabled) {
        dxg = graph.snap(dxg);
        dyg = graph.snap(dyg);
      }

      x = (math.round((dxg + trans.getX()) * scale) as int) + (math.round(_bbox.getX()) as int) - (math.round(_cellBounds.getX()) as int);
      y = (math.round((dyg + trans.getY()) * scale) as int) + (math.round(_bbox.getY()) as int) - (math.round(_cellBounds.getY()) as int);
    }

    return new Point(x, y);
  }

  /**
	 * 
	 * @param e
	 */
  void dragExit(DropTargetEvent e) {
    GraphTransferHandler handler = _getGraphTransferHandler(e);

    if (handler != null) {
      handler.setLocation(null);
    }

    _dragCells = null;
    setVisible(false);
    _marker.reset();
    reset();
  }

  /**
	 * 
	 * @param e
	 */
  void drop(DropTargetDropEvent e) {
    if (_canImport) {
      GraphTransferHandler handler = _getGraphTransferHandler(e);
      MouseEvent event = _createEvent(e);

      // Ignores the event in mouseReleased if it is
      // handled by the transfer handler as a drop
      if (handler != null && !handler.isLocalDrag()) {
        event.consume();
      }

      mouseReleased(event);
    }
  }

  /**
	 * 
	 */
  void mouseReleased(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed()) {
      Graph graph = _graphComponent.getGraph();
      double dx = 0;
      double dy = 0;

      if (_first != null && (_cellBounds != null || _movePreview.isActive())) {
        double scale = graph.getView().getScale();
        Point2d trans = graph.getView().getTranslate();

        // TODO: Simplify math below, this was copy pasted from
        // getPreviewLocation with the rounding removed
        dx = e.getX() - _first.x;
        dy = e.getY() - _first.y;

        if (_cellBounds != null) {
          double dxg = ((_cellBounds.getX() + dx) / scale) - trans.getX();
          double dyg = ((_cellBounds.getY() + dy) / scale) - trans.getY();

          if (_gridEnabledEvent) {
            dxg = graph.snap(dxg);
            dyg = graph.snap(dyg);
          }

          double x = ((dxg + trans.getX()) * scale) + (_bbox.getX()) - (_cellBounds.getX());
          double y = ((dyg + trans.getY()) * scale) + (_bbox.getY()) - (_cellBounds.getY());

          dx = math.round((x - _bbox.getX()) / scale);
          dy = math.round((y - _bbox.getY()) / scale);
        }
      }

      if (_first == null || !_graphComponent.isSignificant(e.getX() - _first.x, e.getY() - _first.y)) {
        // Delayed handling of selection
        if (_cell != null && !e.isPopupTrigger() && isSelectEnabled() && (_first != null || !isMoveEnabled())) {
          _graphComponent.selectCellForEvent(_cell, e);
        }

        // Delayed folding for cell that was initially under the mouse
        if (_graphComponent.isFoldingEnabled() && _graphComponent.hitFoldingIcon(_initialCell, e.getX(), e.getY())) {
          _fold(_initialCell);
        } else {
          // Handles selection if no cell was initially under the mouse
          Object tmp = _graphComponent.getCellAt(e.getX(), e.getY(), _graphComponent.isSwimlaneSelectionEnabled());

          if (_cell == null && _first == null) {
            if (tmp == null) {
              if (!_graphComponent.isToggleEvent(e)) {
                graph.clearSelection();
              }
            } else if (graph.isSwimlane(tmp) && _graphComponent.getCanvas().hitSwimlaneContent(_graphComponent, graph.getView().getState(tmp), e.getX(), e.getY())) {
              _graphComponent.selectCellForEvent(tmp, e);
            }
          }

          if (_graphComponent.isFoldingEnabled() && _graphComponent.hitFoldingIcon(tmp, e.getX(), e.getY())) {
            _fold(tmp);
            e.consume();
          }
        }
      } else if (_movePreview.isActive()) {
        if (_graphComponent.isConstrainedEvent(e)) {
          if (math.abs(dx) > math.abs(dy)) {
            dy = 0;
          } else {
            dx = 0;
          }
        }

        CellState markedState = _marker.getMarkedState();
        Object target = (markedState != null) ? markedState.getCell() : null;

        // FIXME: Cell is null if selection was carried out, need other variable
        //trace("cell", cell);

        if (target == null && isRemoveCellsFromParent() && _shouldRemoveCellFromParent(graph.getModel().getParent(_initialCell), _cells, e)) {
          target = graph.getDefaultParent();
        }

        bool clone = isCloneEnabled() && _graphComponent.isCloneEvent(e);
        List<Object> result = _movePreview.stop(true, e, dx, dy, clone, target);

        if (_cells != result) {
          graph.setSelectionCells(result);
        }

        e.consume();
      } else if (isVisible()) {
        if (_constrainedEvent) {
          if (math.abs(dx) > math.abs(dy)) {
            dy = 0;
          } else {
            dx = 0;
          }
        }

        CellState targetState = _marker.getValidState();
        Object target = (targetState != null) ? targetState.getCell() : null;

        if (graph.isSplitEnabled() && graph.isSplitTarget(target, _cells)) {
          graph.splitEdge(target, _cells, dx, dy);
        } else {
          _moveCells(_cells, dx, dy, target, e);
        }

        e.consume();
      }
    }

    reset();
  }

  /**
	 * 
	 */
  void _fold(Object cell) {
    bool collapse = !_graphComponent.getGraph().isCellCollapsed(cell);
    _graphComponent.getGraph().foldCells(collapse, false, [cell]);
  }

  /**
	 * 
	 */
  void reset() {
    if (_movePreview.isActive()) {
      _movePreview.stop(false, null, 0, 0, false, null);
    }

    setVisible(false);
    _marker.reset();
    _initialCell = null;
    _dragCells = null;
    _dragImage = null;
    _cells = null;
    _first = null;
    _cell = null;
  }

  /**
	 * Returns true if the given cells should be removed from the parent for the specified
	 * mousereleased event.
	 */
  bool _shouldRemoveCellFromParent(Object parent, List<Object> cells, MouseEvent e) {
    if (_graphComponent.getGraph().getModel().isVertex(parent)) {
      CellState pState = _graphComponent.getGraph().getView().getState(parent);

      return pState != null && !pState.contains(e.getX(), e.getY());
    }

    return false;
  }

  /**
	 * 
	 * @param dx
	 * @param dy
	 * @param e
	 */
  void _moveCells(List<Object> cells, double dx, double dy, Object target, MouseEvent e) {
    Graph graph = _graphComponent.getGraph();
    bool clone = e.isControlDown() && isCloneEnabled();

    if (clone) {
      cells = graph.getCloneableCells(cells);
    }

    if (cells.length > 0) {
      // Removes cells from parent
      if (target == null && isRemoveCellsFromParent() && _shouldRemoveCellFromParent(graph.getModel().getParent(_initialCell), cells, e)) {
        target = graph.getDefaultParent();
      }

      List<Object> tmp = graph.moveCells(cells, dx, dy, clone, target, e.getPoint());

      if (isSelectEnabled() && clone && tmp != null && tmp.length == cells.length) {
        graph.setSelectionCells(tmp);
      }
    }
  }

  /**
	 *
	 */
  void paint(Graphics g) {
    if (isVisible() && _previewBounds != null) {
      if (_dragImage != null) {
        // LATER: Clipping with Utils doesnt fix the problem
        // of the drawImage being painted over the scrollbars
        Graphics2D tmp = g.create() as Graphics2D;

        if (_graphComponent.getPreviewAlpha() < 1) {
          tmp.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, _graphComponent.getPreviewAlpha()));
        }

        tmp.drawImage(_dragImage.getImage(), _previewBounds.x, _previewBounds.y, _dragImage.getIconWidth(), _dragImage.getIconHeight(), null);
        tmp.dispose();
      } else if (!_imagePreview) {
        SwingConstants.PREVIEW_BORDER.paintBorder(_graphComponent, g, _previewBounds.x, _previewBounds.y, _previewBounds.width, _previewBounds.height);
      }
    }
  }

  /**
	 * 
	 */
  MouseEvent _createEvent(DropTargetEvent e) {
    JComponent component = _getDropTarget(e);
    Point location = null;
    int action = 0;

    if (e is DropTargetDropEvent) {
      location = (e as DropTargetDropEvent).getLocation();
      action = (e as DropTargetDropEvent).getDropAction();
    } else if (e is DropTargetDragEvent) {
      location = (e as DropTargetDragEvent).getLocation();
      action = (e as DropTargetDragEvent).getDropAction();
    }

    if (location != null) {
      location = convertPoint(location);
      Rectangle r = _graphComponent.getViewport().getViewRect();
      location.translate(r.x, r.y);
    }

    // LATER: Fetch state of modifier keys from event or via global
    // key listener using Toolkit.getDefaultToolkit().addAWTEventListener(
    // new AWTEventListener() {...}, AWTEvent.KEY_EVENT_MASK). Problem
    // is the event does not contain the modifier keys and the global
    // handler is not called during drag and drop.
    int mod = (action == TransferHandler.COPY) ? InputEvent.CTRL_MASK : 0;

    return new MouseEvent(component, 0, System.currentTimeMillis(), mod, location.x, location.y, 1, false, MouseEvent.BUTTON1);
  }

  /**
	 * Helper method to return the component for a drop target event.
	 */
  static /*final*/ GraphTransferHandler _getGraphTransferHandler(DropTargetEvent e) {
    JComponent component = _getDropTarget(e);
    TransferHandler transferHandler = component.getTransferHandler();

    if (transferHandler is GraphTransferHandler) {
      return transferHandler as GraphTransferHandler;
    }

    return null;
  }

  /**
	 * Helper method to return the component for a drop target event.
	 */
  static /*final*/ JComponent _getDropTarget(DropTargetEvent e) {
    return e.getDropTargetContext().getComponent() as JComponent;
  }

}

class GraphHandlerDragSourceAdapter extends DragSourceAdapter {
  /**
     *
     */
  final mxGraphHandler graphHandler;
  final mxGraphTransferable t;
  final TransferHandler th;

  GraphHandlerDragSourceAdapter(this.graphHandler, this.t, this.th);

  /**
     *
     */
  void dragDropEnd(DragSourceDropEvent dsde) {
    (th as GraphTransferHandler).exportDone(graphHandler.graphComponent, t, TransferHandler.NONE);
    graphHandler.first = null;
  }
}

class GraphHandlerCellMarker extends CellMarker {

  final mxGraphHandler graphHandler;

  GraphHandlerCellMarker(this.graphHandler, GraphComponent graphComponent, Color validColor) : super(graphComponent, validColor);

  /**
     *
     */
  boolean isEnabled() {
    return graphComponent.getGraph().isDropEnabled();
  }

  /**
     *
     */
  Object getCell(MouseEvent e) {
    mxIGraphModel model = graphComponent.getGraph().getModel();
    TransferHandler th = graphComponent.getTransferHandler();
    boolean isLocal = th is mxGraphTransferHandler && (th as mxGraphTransferHandler).isLocalDrag();

    mxGraph graph = graphComponent.getGraph();
    Object cell = super.getCell(e);
    List<Object> cells = (isLocal) ? graph.getSelectionCells() : graphHandler.dragCells;
    cell = graph.getDropTarget(cells, e.getPoint(), cell);

    // Checks if parent is dropped into child
    Object parent = cell;

    while (parent != null) {
      if (mxUtils.contains(cells, parent)) {
        return null;
      }

      parent = model.getParent(parent);
    }

    boolean clone = graphComponent.isCloneEvent(e) && graphHandler.isCloneEnabled();

    if (isLocal && cell != null && cells.length > 0 && !clone && graph.getModel().getParent(cells[0]) == cell) {
      cell = null;
    }

    return cell;
  }
}
