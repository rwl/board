part of graph.shape;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.geom.GeneralPath;

class CloudShape extends BasicShape {

  awt.Shape createShape(Graphics2DCanvas canvas, CellState state) {
    awt.Rectangle temp = state.getRectangle();
    int x = temp.x;
    int y = temp.y;
    int w = temp.width;
    int h = temp.height;
    awt.GeneralPath path = new awt.GeneralPath();

    path.moveTo(x + 0.25 * w, y + 0.25 * h);
    path.curveTo(x + 0.05 * w, y + 0.25 * h, x, y + 0.5 * h, x + 0.16 * w, y + 0.55 * h);
    path.curveTo(x, y + 0.66 * h, x + 0.18 * w, y + 0.9 * h, x + 0.31 * w, y + 0.8 * h);
    path.curveTo(x + 0.4 * w, y + h, x + 0.7 * w, y + h, x + 0.8 * w, y + 0.8 * h);
    path.curveTo(x + w, y + 0.8 * h, x + w, y + 0.6 * h, x + 0.875 * w, y + 0.5 * h);
    path.curveTo(x + w, y + 0.3 * h, x + 0.8 * w, y + 0.1 * h, x + 0.625 * w, y + 0.2 * h);
    path.curveTo(x + 0.5 * w, y + 0.05 * h, x + 0.3 * w, y + 0.05 * h, x + 0.25 * w, y + 0.25 * h);
    path.closePath();

    return path;
  }

}
