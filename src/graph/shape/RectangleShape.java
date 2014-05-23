/**
 * $Id: RectangleShape.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2007-2012, JGraph Ltd
 */
package graph.shape;

import graph.canvas.Graphics2DCanvas;
import graph.swing.util.SwingConstants;
import graph.util.Constants;
import graph.util.Utils;
import graph.view.CellState;

import java.awt.Rectangle;
import java.util.Map;

public class RectangleShape extends BasicShape
{

	/**
	 * 
	 */
	public void paintShape(Graphics2DCanvas canvas, CellState state)
	{
		Map<String, Object> style = state.getStyle();

		if (Utils.isTrue(style, Constants.STYLE_ROUNDED, false))
		{
			Rectangle tmp = state.getRectangle();

			int x = tmp.x;
			int y = tmp.y;
			int w = tmp.width;
			int h = tmp.height;
			int radius = getArcSize(w, h);

			boolean shadow = hasShadow(canvas, state);
			int shadowOffsetX = (shadow) ? Constants.SHADOW_OFFSETX : 0;
			int shadowOffsetY = (shadow) ? Constants.SHADOW_OFFSETY : 0;

			if (canvas.getGraphics().hitClip(x, y, w + shadowOffsetX,
					h + shadowOffsetY))
			{
				// Paints the optional shadow
				if (shadow)
				{
					canvas.getGraphics().setColor(SwingConstants.SHADOW_COLOR);
					canvas.getGraphics().fillRoundRect(
							x + Constants.SHADOW_OFFSETX,
							y + Constants.SHADOW_OFFSETY, w, h, radius,
							radius);
				}

				// Paints the background
				if (_configureGraphics(canvas, state, true))
				{
					canvas.getGraphics().fillRoundRect(x, y, w, h, radius,
							radius);
				}

				// Paints the foreground
				if (_configureGraphics(canvas, state, false))
				{
					canvas.getGraphics().drawRoundRect(x, y, w, h, radius,
							radius);
				}
			}
		}
		else
		{
			Rectangle rect = state.getRectangle();

			// Paints the background
			if (_configureGraphics(canvas, state, true))
			{
				canvas.fillShape(rect, hasShadow(canvas, state));
			}

			// Paints the foreground
			if (_configureGraphics(canvas, state, false))
			{
				canvas.getGraphics().drawRect(rect.x, rect.y, rect.width,
						rect.height);
			}
		}
	}

	/**
	 * Computes the arc size for the given dimension.
	 * 
	 * @param w Width of the rectangle.
	 * @param h Height of the rectangle.
	 * @return Returns the arc size for the given dimension.
	 */
	public int getArcSize(int w, int h)
	{
		int arcSize;

		if (w <= h)
		{
			arcSize = (int) Math.round(h
					* Constants.RECTANGLE_ROUNDING_FACTOR);

			if (arcSize > (w / 2))
			{
				arcSize = w / 2;
			}
		}
		else
		{
			arcSize = (int) Math.round(w
					* Constants.RECTANGLE_ROUNDING_FACTOR);

			if (arcSize > (h / 2))
			{
				arcSize = h / 2;
			}
		}
		return arcSize;
	}

}
