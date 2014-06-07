part of graph.swing;

//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

//import javax.swing.SwingUtilities;

/**
 * 
 */
class MouseRedirector {//implements MouseListener, MouseMotionListener {

  GraphComponent graphComponent;

  MouseRedirector(GraphComponent graphComponent) {
    this.graphComponent = graphComponent;
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
   */
  void mouseClicked(MouseEvent e) {
    graphComponent.getGraphControl().dispatchEvent(SwingUtilities.convertMouseEvent(e.getComponent(), e, graphComponent.getGraphControl()));
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
   */
  void mouseEntered(MouseEvent e) {
    // Redirecting this would cause problems on the Mac
    // and is technically incorrect anyway
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
   */
  void mouseExited(MouseEvent e) {
    mouseClicked(e);
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseListener#mousePressed(java.awt.event.MouseEvent)
   */
  void mousePressed(MouseEvent e) {
    mouseClicked(e);
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseListener#mouseReleased(java.awt.event.MouseEvent)
   */
  void mouseReleased(MouseEvent e) {
    mouseClicked(e);
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseMotionListener#mouseDragged(java.awt.event.MouseEvent
   * )
   */
  void mouseDragged(MouseEvent e) {
    mouseClicked(e);
  }

  /*
   * (non-Javadoc)
   * 
   * @see
   * java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent
   * )
   */
  void mouseMoved(MouseEvent e) {
    mouseClicked(e);
  }

}
