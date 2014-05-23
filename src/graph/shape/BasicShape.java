/**
 * $Id: BasicShape.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
package graph.shape;

import graph.canvas.Graphics2DCanvas;
import graph.util.Constants;
import graph.util.Rect;
import graph.util.Utils;
import graph.view.CellState;

import java.awt.Color;
import java.awt.Paint;
import java.awt.Shape;
import java.util.Map;

public class BasicShape implements IShape
{

	/**
	 * 
	 */
	public void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		Shape shape = createShape(canvas, state);

		if (shape != null)
		{
			// Paints the background
			if (_configureGraphics(canvas, state, true))
			{
				canvas.fillShape(shape, hasShadow(canvas, state));
			}

			// Paints the foreground
			if (_configureGraphics(canvas, state, false))
			{
				canvas.getGraphics().draw(shape);
			}
		}
	}

	/**
	 * 
	 */
	public Shape createShape(Graphics2DCanvas canvas, CellState state)
	{
		return null;
	}

	/**
	 * Configures the graphics object ready to paint.
	 * @param canvas the canvas to be painted to
	 * @param state the state of cell to be painted
	 * @param background whether or not this is the background stage of 
	 * 			the shape paint
	 * @return whether or not the shape is ready to be drawn
	 */
	protected boolean _configureGraphics(Graphics2DCanvas canvas,
			CellState state, boolean background)
	{
		Map<String, Object> style = state.getStyle();

		if (background)
		{
			// Paints the background of the shape
			Paint fillPaint = hasGradient(canvas, state) ? canvas
					.createFillPaint(_getGradientBounds(canvas, state), style)
					: null;

			if (fillPaint != null)
			{
				canvas.getGraphics().setPaint(fillPaint);

				return true;
			}
			else
			{
				Color color = getFillColor(canvas, state);
				canvas.getGraphics().setColor(color);

				return color != null;
			}
		}
		else
		{
			canvas.getGraphics().setPaint(null);
			Color color = getStrokeColor(canvas, state);
			canvas.getGraphics().setColor(color);
			canvas.getGraphics().setStroke(canvas.createStroke(style));

			return color != null;
		}
	}

	/**
	 * 
	 */
	protected Rect _getGradientBounds(Graphics2DCanvas canvas,
			CellState state)
	{
		return state;
	}

	/**
	 * 
	 */
	public boolean hasGradient(Graphics2DCanvas canvas, CellState state)
	{
		return true;
	}

	/**
	 * 
	 */
	public boolean hasShadow(Graphics2DCanvas canvas, CellState state)
	{
		return Utils
				.isTrue(state.getStyle(), Constants.STYLE_SHADOW, false);
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

}
