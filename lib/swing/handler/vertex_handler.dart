/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.harmony.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.MouseEvent;

//import javax.swing.JComponent;
//import javax.swing.JPanel;

/**
 * 
 */
class VertexHandler extends CellHandler {

  /**
	 * 
	 */
  static List<Cursor> CURSORS = [new Cursor(Cursor.NW_RESIZE_CURSOR), new Cursor(Cursor.N_RESIZE_CURSOR), new Cursor(Cursor.NE_RESIZE_CURSOR), new Cursor(Cursor.W_RESIZE_CURSOR), new Cursor(Cursor.E_RESIZE_CURSOR), new Cursor(Cursor.SW_RESIZE_CURSOR), new Cursor(Cursor.S_RESIZE_CURSOR), new Cursor(Cursor.SE_RESIZE_CURSOR), new Cursor(Cursor.MOVE_CURSOR)];

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
	 * @param graphComponent
	 * @param state
	 */
  VertexHandler(GraphComponent graphComponent, CellState state) : super(graphComponent, state);

  /**
	 * 
	 */
  List<harmony.Rectangle> _createHandles() {
    List<harmony.Rectangle> h = null;

    if (_graphComponent.getGraph().isCellResizable(getState().getCell())) {
      harmony.Rectangle bounds = getState().getRectangle();
      int half = Constants.HANDLE_SIZE / 2;

      int left = bounds.x - half;
      int top = bounds.y - half;

      int w2 = bounds.x + (bounds.width / 2) - half;
      int h2 = bounds.y + (bounds.height / 2) - half;

      int right = bounds.x + bounds.width - half;
      int bottom = bounds.y + bounds.height - half;

      h = new List<harmony.Rectangle>(9);

      int s = Constants.HANDLE_SIZE;
      h[0] = new harmony.Rectangle(left, top, s, s);
      h[1] = new harmony.Rectangle(w2, top, s, s);
      h[2] = new harmony.Rectangle(right, top, s, s);
      h[3] = new harmony.Rectangle(left, h2, s, s);
      h[4] = new harmony.Rectangle(right, h2, s, s);
      h[5] = new harmony.Rectangle(left, bottom, s, s);
      h[6] = new harmony.Rectangle(w2, bottom, s, s);
      h[7] = new harmony.Rectangle(right, bottom, s, s);
    } else {
      h = new List<harmony.Rectangle>(1);
    }

    int s = Constants.LABEL_HANDLE_SIZE;
    Rect bounds = _state.getLabelBounds();
    h[h.length - 1] = new harmony.Rectangle((int)(bounds.getX() + bounds.getWidth() / 2 - s), (int)(bounds.getY() + bounds.getHeight() / 2 - s), 2 * s, 2 * s);

    return h;
  }

  /**
	 * 
	 */
  JComponent _createPreview() {
    JPanel preview = new JPanel();
    preview.setBorder(SwingConstants.PREVIEW_BORDER);
    preview.setOpaque(false);
    preview.setVisible(false);

    return preview;
  }

  /**
	 * 
	 */
  void mouseDragged(MouseEvent e) {
    if (!e.isConsumed() && _first != null) {
      _gridEnabledEvent = _graphComponent.isGridEnabledEvent(e);
      _constrainedEvent = _graphComponent.isConstrainedEvent(e);

      double dx = e.getX() - _first.x;
      double dy = e.getY() - _first.y;

      if (isLabel(_index)) {
        Point2d pt = new Point2d(e.getPoint());

        if (_gridEnabledEvent) {
          pt = _graphComponent.snapScaledPoint(pt);
        }

        int idx = math.round(pt.getX() - _first.x) as int;
        int idy = math.round(pt.getY() - _first.y) as int;

        if (_constrainedEvent) {
          if (math.abs(idx) > math.abs(idy)) {
            idy = 0;
          } else {
            idx = 0;
          }
        }

        harmony.Rectangle rect = _state.getLabelBounds().getRectangle();
        rect.translate(idx, idy);
        _preview.setBounds(rect);
      } else {
        Graph graph = _graphComponent.getGraph();
        double scale = graph.getView().getScale();

        if (_gridEnabledEvent) {
          dx = graph.snap(dx / scale) * scale;
          dy = graph.snap(dy / scale) * scale;
        }

        Rect bounds = _union(getState(), dx, dy, _index);
        bounds.setWidth(bounds.getWidth() + 1);
        bounds.setHeight(bounds.getHeight() + 1);
        _preview.setBounds(bounds.getRectangle());
      }

      if (!_preview.isVisible() && _graphComponent.isSignificant(dx, dy)) {
        _preview.setVisible(true);
      }

      e.consume();
    }
  }

  /**
	 * 
	 */
  void mouseReleased(MouseEvent e) {
    if (!e.isConsumed() && _first != null) {
      if (_preview != null && _preview.isVisible()) {
        if (isLabel(_index)) {
          _moveLabel(e);
        } else {
          _resizeCell(e);
        }
      }

      e.consume();
    }

    super.mouseReleased(e);
  }

  /**
	 * 
	 */
  void _moveLabel(MouseEvent e) {
    Graph graph = _graphComponent.getGraph();
    Geometry geometry = graph.getModel().getGeometry(_state.getCell());

    if (geometry != null) {
      double scale = graph.getView().getScale();
      Point2d pt = new Point2d(e.getPoint());

      if (_gridEnabledEvent) {
        pt = _graphComponent.snapScaledPoint(pt);
      }

      double dx = (pt.getX() - _first.x) / scale;
      double dy = (pt.getY() - _first.y) / scale;

      if (_constrainedEvent) {
        if (math.abs(dx) > math.abs(dy)) {
          dy = 0;
        } else {
          dx = 0;
        }
      }

      Point2d offset = geometry.getOffset();

      if (offset == null) {
        offset = new Point2d();
      }

      dx += offset.getX();
      dy += offset.getY();

      geometry = geometry.clone() as Geometry;
      geometry.setOffset(new Point2d(math.round(dx), math.round(dy)));
      graph.getModel().setGeometry(_state.getCell(), geometry);
    }
  }

  /**
	 * 
	 * @param e
	 */
  void _resizeCell(MouseEvent e) {
    Graph graph = _graphComponent.getGraph();
    double scale = graph.getView().getScale();

    Object cell = _state.getCell();
    Geometry geometry = graph.getModel().getGeometry(cell);

    if (geometry != null) {
      double dx = (e.getX() - _first.x) / scale;
      double dy = (e.getY() - _first.y) / scale;

      if (isLabel(_index)) {
        geometry = geometry.clone() as Geometry;

        if (geometry.getOffset() != null) {
          dx += geometry.getOffset().getX();
          dy += geometry.getOffset().getY();
        }

        if (_gridEnabledEvent) {
          dx = graph.snap(dx);
          dy = graph.snap(dy);
        }

        geometry.setOffset(new Point2d(dx, dy));
        graph.getModel().setGeometry(cell, geometry);
      } else {
        Rect bounds = _union(geometry, dx, dy, _index);
        harmony.Rectangle rect = bounds.getRectangle();

        // Snaps new bounds to grid (unscaled)
        if (_gridEnabledEvent) {
          int x = graph.snap(rect.x) as int;
          int y = graph.snap(rect.y) as int;
          rect.width = graph.snap(rect.width - x + rect.x) as int;
          rect.height = graph.snap(rect.height - y + rect.y) as int;
          rect.x = x;
          rect.y = y;
        }

        graph.resizeCell(cell, new Rect(rect));
      }
    }
  }

  /**
	 * 
	 */
  Cursor _getCursor(MouseEvent e, int index) {
    if (index >= 0 && index <= CURSORS.length) {
      return CURSORS[index];
    }

    return null;
  }

  /**
	 * 
	 * @param bounds
	 * @param dx
	 * @param dy
	 * @param index
	 */
  Rect _union(Rect bounds, double dx, double dy, int index) {
    double left = bounds.getX();
    double right = left + bounds.getWidth();
    double top = bounds.getY();
    double bottom = top + bounds.getHeight();

    if (index > 4 /* Bottom Row */) {
      bottom = bottom + dy;
    } else if (index < 3 /* Top Row */) {
      top = top + dy;
    }

    if (index == 0 || index == 3 || index == 5 /* Left */) {
      left += dx;
    } else if (index == 2 || index == 4 || index == 7 /* Right */) {
      right += dx;
    }

    double width = right - left;
    double height = bottom - top;

    // Flips over left side
    if (width < 0) {
      left += width;
      width = math.abs(width);
    }

    // Flips over top side
    if (height < 0) {
      top += height;
      height = math.abs(height);
    }

    return new Rect(left, top, width, height);
  }

  /**
	 * 
	 */
  Color getSelectionColor() {
    return SwingConstants.VERTEX_SELECTION_COLOR;
  }

  /**
	 * 
	 */
  Stroke getSelectionStroke() {
    return SwingConstants.VERTEX_SELECTION_STROKE;
  }

  /**
	 * 
	 */
  void paint(Graphics g) {
    harmony.Rectangle bounds = getState().getRectangle();

    if (g.hitClip(bounds.x, bounds.y, bounds.width, bounds.height)) {
      Graphics2D g2 = g as Graphics2D;

      Stroke stroke = g2.getStroke();
      g2.setStroke(getSelectionStroke());
      g.setColor(getSelectionColor());
      g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
      g2.setStroke(stroke);
    }

    super.paint(g);
  }

}
