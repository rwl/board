package graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.util.Constants;
//import graph.util.Utils;
//import graph.view.CellState;

//import java.awt.Rectangle;

public class DoubleRectangleShape extends RectangleShape
{

	/**
	 * 
	 */
	public void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		super.paintShape(canvas, state);

		int inset = (int) Math.round((Utils.getFloat(state.getStyle(),
				Constants.STYLE_STROKEWIDTH, 1) + 3)
				* canvas.getScale());

		Rectangle rect = state.getRectangle();
		int x = rect.x + inset;
		int y = rect.y + inset;
		int w = rect.width - 2 * inset;
		int h = rect.height - 2 * inset;
		
		canvas.getGraphics().drawRect(x, y, w, h);
	}

}