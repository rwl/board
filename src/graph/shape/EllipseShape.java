package graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.view.CellState;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.geom.Ellipse2D;

public class EllipseShape extends BasicShape
{

	/**
	 * 
	 */
	public Shape createShape(Graphics2DCanvas canvas, CellState state)
	{
		Rectangle temp = state.getRectangle();

		return new Ellipse2D.Float(temp.x, temp.y, temp.width, temp.height);
	}

}
