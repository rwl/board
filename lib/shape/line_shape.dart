part of graph.shape;

class LineShape extends BasicShape {

  void paintShape(Graphics2DCanvas canvas, CellState state) {
    if (_configureGraphics(canvas, state, false)) {
      bool rounded = Utils.isTrue(state.getStyle(), Constants.STYLE_ROUNDED, false)
          && canvas.getScale() > Constants.MIN_SCALE_FOR_ROUNDED_LINES;

      canvas.paintPolyline(createPoints(canvas, state), rounded);
    }
  }

  List<Point2d> createPoints(Graphics2DCanvas canvas, CellState state) {
    String direction = Utils.getString(state.getStyle(), Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST);

    Point2d p0, pe;

    if (direction == Constants.DIRECTION_EAST || direction == Constants.DIRECTION_WEST) {
      double mid = state.getCenterY();
      p0 = new Point2d(state.getX(), mid);
      pe = new Point2d(state.getX() + state.getWidth(), mid);
    } else {
      double mid = state.getCenterX();
      p0 = new Point2d(mid, state.getY());
      pe = new Point2d(mid, state.getY() + state.getHeight());
    }

    List<Point2d> points = [p0, pe];

    return points;
  }

}
