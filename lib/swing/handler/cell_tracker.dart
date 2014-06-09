/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import java.awt.Color;
//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

/**
 * Event handler that highlights cells. Inherits from CellMarker.
 */
class CellTracker extends CellMarker implements event.MouseUpHandler, event.MouseMoveHandler {//MouseListener, MouseMotionListener {

  event.HandlerRegistration _mouseUpRegistration;
  event.HandlerRegistration _mouseMoveRegistration;

  /**
   * Constructs an event handler that highlights cells.
   */
  CellTracker(GraphComponent graphComponent, awt.Color color) : super(graphComponent, color) {
    _mouseUpRegistration = graphComponent.getGraphControl().addMouseUpHandler(this);
    _mouseMoveRegistration = graphComponent.getGraphControl().addMouseMoveHandler(this);
  }

  void destroy() {
    if (_mouseUpRegistration != null) {
      _mouseUpRegistration.removeHandler();
    }
    if (_mouseMoveRegistration != null) {
      _mouseMoveRegistration.removeHandler();
    }
  }

  void onMouseUp(event.MouseEvent e) {
    reset();
  }

  void onMouseMove(event.MouseEvent e) {
    process(e);
  }

}
