/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../view/view.dart' show CellState;

//import java.util.Map;

public interface ITextShape
{
	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, String text, CellState state,
			Map<String, Object> style);

}
