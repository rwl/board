/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import java.util.Map;

abstract class ITextShape
{
	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, String text, CellState state,
			Map<String, Object> style);

}