/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import graph.canvas.Graphics2DCanvas;
//import graph.view.CellState;

//import java.util.Map;

public interface ITextShape
{
	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, String text, CellState state,
			Map<String, Object> style);

}
