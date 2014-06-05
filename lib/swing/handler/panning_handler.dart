/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import java.awt.Point;
//import java.awt.awt.Rectangle;
//import java.awt.event.MouseEvent;

/**
 * 
 */
class PanningHandler extends MouseAdapter {

  /**
   * 
   */
  //	static final long serialVersionUID = 7969814728058376339L;

  /**
   * 
   */
  GraphComponent _graphComponent;

  /**
   * 
   */
  bool _enabled = true;

  /**
   * 
   */
  /*transient*/ awt.Point _start;

  /**
   * 
   * @param graphComponent
   */
  PanningHandler(GraphComponent graphComponent) {
    this._graphComponent = graphComponent;

    graphComponent.getGraphControl().addMouseListener(this);
    graphComponent.getGraphControl().addMouseMotionListener(this);
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
  void mousePressed(MouseEvent e) {
    if (isEnabled() && !e.isConsumed() && _graphComponent.isPanningEvent(e) && !e.isPopupTrigger()) {
      _start = e.getPoint();
    }
  }

  /**
   * 
   */
  void mouseDragged(MouseEvent e) {
    if (!e.isConsumed() && _start != null) {
      int dx = e.getX() - _start.x;
      int dy = e.getY() - _start.y;

      awt.Rectangle r = _graphComponent.getViewport().getViewRect();

      int right = r.x + ((dx > 0) ? 0 : r.width) - dx;
      int bottom = r.y + ((dy > 0) ? 0 : r.height) - dy;

      _graphComponent.getGraphControl().scrollRectToVisible(new awt.Rectangle(right, bottom, 0, 0));

      e.consume();
    }
  }

  /**
   * 
   */
  void mouseReleased(MouseEvent e) {
    if (!e.isConsumed() && _start != null) {
      int dx = math.abs(_start.x - e.getX());
      int dy = math.abs(_start.y - e.getY());

      if (_graphComponent.isSignificant(dx, dy)) {
        e.consume();
      }
    }

    _start = null;
  }

  /**
   * Whether or not panning is currently active
   * @return Whether or not panning is currently active
   */
  bool isActive() {
    return (_start != null);
  }
}
