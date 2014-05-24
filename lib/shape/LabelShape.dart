package graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.util.Constants;
//import graph.util.Rect;
//import graph.util.Utils;
//import graph.view.CellState;

//import java.awt.Color;
//import java.awt.GradientPaint;
//import java.awt.Rectangle;
//import java.awt.geom.GeneralPath;
//import java.util.Map;

public class LabelShape extends ImageShape
{

	/**
	 * 
	 */
	public void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		super.paintShape(canvas, state);

		if (Utils.isTrue(state.getStyle(), Constants.STYLE_GLASS, false))
		{
			drawGlassEffect(canvas, state);
		}
	}

	/**
	 * Draws the glass effect
	 */
	public static void drawGlassEffect(Graphics2DCanvas canvas,
			CellState state)
	{
		double size = 0.4;
		canvas.getGraphics().setPaint(
				new GradientPaint((float) state.getX(), (float) state.getY(),
						new Color(1, 1, 1, 0.9f), (float) (state.getX()),
						(float) (state.getY() + state.getHeight() * size),
						new Color(1, 1, 1, 0.3f)));

		float sw = (float) (Utils.getFloat(state.getStyle(),
				Constants.STYLE_STROKEWIDTH, 1) * canvas.getScale() / 2);

		GeneralPath path = new GeneralPath();
		path.moveTo((float) state.getX() - sw, (float) state.getY() - sw);
		path.lineTo((float) state.getX() - sw,
				(float) (state.getY() + state.getHeight() * size));
		path.quadTo((float) (state.getX() + state.getWidth() * 0.5),
				(float) (state.getY() + state.getHeight() * 0.7),
				(float) (state.getX() + state.getWidth() + sw),
				(float) (state.getY() + state.getHeight() * size));
		path.lineTo((float) (state.getX() + state.getWidth() + sw),
				(float) state.getY() - sw);
		path.closePath();

		canvas.getGraphics().fill(path);
	}

	/**
	 * 
	 */
	public Rectangle getImageBounds(Graphics2DCanvas canvas, CellState state)
	{
		Map<String, Object> style = state.getStyle();
		double scale = canvas.getScale();
		String imgAlign = Utils.getString(style,
				Constants.STYLE_IMAGE_ALIGN, Constants.ALIGN_LEFT);
		String imgValign = Utils.getString(style,
				Constants.STYLE_IMAGE_VERTICAL_ALIGN,
				Constants.ALIGN_MIDDLE);
		int imgWidth = (int) (Utils.getInt(style,
				Constants.STYLE_IMAGE_WIDTH, Constants.DEFAULT_IMAGESIZE) * scale);
		int imgHeight = (int) (Utils.getInt(style,
				Constants.STYLE_IMAGE_HEIGHT, Constants.DEFAULT_IMAGESIZE) * scale);
		int spacing = (int) (Utils
				.getInt(style, Constants.STYLE_SPACING, 2) * scale);

		Rect imageBounds = new Rect(state);

		if (imgAlign.equals(Constants.ALIGN_CENTER))
		{
			imageBounds.setX(imageBounds.getX()
					+ (imageBounds.getWidth() - imgWidth) / 2);
		}
		else if (imgAlign.equals(Constants.ALIGN_RIGHT))
		{
			imageBounds.setX(imageBounds.getX() + imageBounds.getWidth()
					- imgWidth - spacing - 2);
		}
		else
		// LEFT
		{
			imageBounds.setX(imageBounds.getX() + spacing + 4);
		}

		if (imgValign.equals(Constants.ALIGN_TOP))
		{
			imageBounds.setY(imageBounds.getY() + spacing);
		}
		else if (imgValign.equals(Constants.ALIGN_BOTTOM))
		{
			imageBounds.setY(imageBounds.getY() + imageBounds.getHeight()
					- imgHeight - spacing);
		}
		else
		// MIDDLE
		{
			imageBounds.setY(imageBounds.getY()
					+ (imageBounds.getHeight() - imgHeight) / 2);
		}

		imageBounds.setWidth(imgWidth);
		imageBounds.setHeight(imgHeight);

		return imageBounds.getRectangle();
	}

	/**
	 * 
	 */
	public Color getFillColor(Graphics2DCanvas canvas, CellState state)
	{
		return Utils.getColor(state.getStyle(), Constants.STYLE_FILLCOLOR);
	}

	/**
	 * 
	 */
	public Color getStrokeColor(Graphics2DCanvas canvas, CellState state)
	{
		return Utils
				.getColor(state.getStyle(), Constants.STYLE_STROKECOLOR);
	}

	/**
	 * 
	 */
	public boolean hasGradient(Graphics2DCanvas canvas, CellState state)
	{
		return true;
	}

}
