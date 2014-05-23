/**
 * $Id: ITextShape.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
package graph.shape;

import graph.canvas.Graphics2DCanvas;
import graph.view.CellState;

import java.util.Map;

public interface ITextShape
{
	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, String text, CellState state,
			Map<String, Object> style);

}
