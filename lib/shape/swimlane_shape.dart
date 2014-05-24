part of graph.shape;

//import java.awt.Rectangle;

class SwimlaneShape extends BasicShape
{

	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		int start = (int) Math.round(Utils.getInt(state.getStyle(),
				Constants.STYLE_STARTSIZE, Constants.DEFAULT_STARTSIZE)
				* canvas.getScale());

		Rectangle tmp = state.getRectangle();

		if (Utils
				.isTrue(state.getStyle(), Constants.STYLE_HORIZONTAL, true))
		{
			if (_configureGraphics(canvas, state, true))
			{
				canvas.fillShape(new Rectangle(tmp.x, tmp.y, tmp.width, Math
						.min(tmp.height, start)));
			}

			if (_configureGraphics(canvas, state, false))
			{
				canvas.getGraphics().drawRect(tmp.x, tmp.y, tmp.width,
						Math.min(tmp.height, start));
				canvas.getGraphics().drawRect(tmp.x, tmp.y + start, tmp.width,
						tmp.height - start);
			}
		}
		else
		{
			if (_configureGraphics(canvas, state, true))
			{
				canvas.fillShape(new Rectangle(tmp.x, tmp.y, Math.min(
						tmp.width, start), tmp.height));
			}

			if (_configureGraphics(canvas, state, false))
			{
				canvas.getGraphics().drawRect(tmp.x, tmp.y,
						Math.min(tmp.width, start), tmp.height);
				canvas.getGraphics().drawRect(tmp.x + start, tmp.y,
						tmp.width - start, tmp.height);
			}
		}

	}

	/**
	 * 
	 */
	Rect _getGradientBounds(Graphics2DCanvas canvas,
			CellState state)
	{
		int start = (int) Math.round(Utils.getInt(state.getStyle(),
				Constants.STYLE_STARTSIZE, Constants.DEFAULT_STARTSIZE)
				* canvas.getScale());
		Rect result = new Rect(state);

		if (Utils
				.isTrue(state.getStyle(), Constants.STYLE_HORIZONTAL, true))
		{
			result.setHeight(Math.min(result.getHeight(), start));
		}
		else
		{
			result.setWidth(Math.min(result.getWidth(), start));
		}

		return result;
	}

}
