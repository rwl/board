part of graph.swing.util;

//import java.awt.Cursor;
//import java.awt.Graphics;

//import javax.swing.ImageIcon;
//import javax.swing.JComponent;

abstract class ICellOverlay {

  Rect getBounds(CellState state);

}

class CellOverlay extends JComponent implements ICellOverlay {

  ImageIcon _imageIcon;

  /**
   * Holds the horizontal alignment for the overlay.
   * Default is ALIGN_RIGHT. For edges, the overlay
   * always appears in the center of the edge.
   */
  Object _align = Constants.ALIGN_RIGHT;

  /**
   * Holds the vertical alignment for the overlay.
   * Default is bottom. For edges, the overlay
   * always appears in the center of the edge.
   */
  Object _verticalAlign = Constants.ALIGN_BOTTOM;

  /**
   * Defines the overlapping for the overlay, that is,
   * the proportional distance from the origin to the
   * point defined by the alignment. Default is 0.5.
   */
  double _defaultOverlap = 0.5;

  CellOverlay(ImageIcon icon, String warning) {
    this._imageIcon = icon;
    setToolTipText(warning);
    setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
  }

  /**
   * @return the alignment of the overlay, see <code>Constants.ALIGN_*****</code>
   */
  Object getAlign() {
    return _align;
  }

  /**
   * @param value the alignment to set, see <code>Constants.ALIGN_*****</code>
   */
  void setAlign(Object value) {
    _align = value;
  }

  /**
   * @return the vertical alignment, see <code>Constants.ALIGN_*****</code>
   */
  Object getVerticalAlign() {
    return _verticalAlign;
  }

  /**
   * @param value the vertical alignment to set, see <code>Constants.ALIGN_*****</code>
   */
  void setVerticalAlign(Object value) {
    _verticalAlign = value;
  }

  void paint(Graphics g) {
    g.drawImage(_imageIcon.getImage(), 0, 0, getWidth(), getHeight(), this);
  }

  /*
   * (non-Javadoc)
   * @see graph.swing.util.mxIOverlay#getBounds(graph.view.CellState)
   */
  Rect getBounds(CellState state) {
    bool isEdge = state.getView().getGraph().getModel().isEdge(state.getCell());
    double s = state.getView().getScale();
    Point2d pt = null;

    int w = _imageIcon.getIconWidth();
    int h = _imageIcon.getIconHeight();

    if (isEdge) {
      int n = state.getAbsolutePointCount();

      if (n % 2 == 1) {
        pt = state.getAbsolutePoint(n / 2 + 1);
      } else {
        int idx = n / 2;
        Point2d p0 = state.getAbsolutePoint(idx - 1);
        Point2d p1 = state.getAbsolutePoint(idx);
        pt = new Point2d(p0.getX() + (p1.getX() - p0.getX()) / 2, p0.getY() + (p1.getY() - p0.getY()) / 2);
      }
    } else {
      pt = new Point2d();

      if (_align.equals(Constants.ALIGN_LEFT)) {
        pt.setX(state.getX());
      } else if (_align.equals(Constants.ALIGN_CENTER)) {
        pt.setX(state.getX() + state.getWidth() / 2);
      } else {
        pt.setX(state.getX() + state.getWidth());
      }

      if (_verticalAlign.equals(Constants.ALIGN_TOP)) {
        pt.setY(state.getY());
      } else if (_verticalAlign.equals(Constants.ALIGN_MIDDLE)) {
        pt.setY(state.getY() + state.getHeight() / 2);
      } else {
        pt.setY(state.getY() + state.getHeight());
      }
    }

    return new Rect(pt.getX() - w * _defaultOverlap * s, pt.getY() - h * _defaultOverlap * s, w * s, h * s);
  }

}
