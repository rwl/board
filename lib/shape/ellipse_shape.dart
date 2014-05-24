part of graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../view/view.dart' show CellState;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.geom.Ellipse2D;

class EllipseShape extends BasicShape
{

	/**
	 * 
	 */
	Shape createShape(Graphics2DCanvas canvas, CellState state)
	{
		Rectangle temp = state.getRectangle();

		return new Ellipse2D.Float(temp.x, temp.y, temp.width, temp.height);
	}

}
