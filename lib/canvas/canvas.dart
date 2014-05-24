/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
library graph.canvas;

/**
 * This package contains various implementations for painting a graph using
 * different technologies, such as Graphics2D, HTML, SVG or VML.
 */

//import graph.view.CellState;

//import java.awt.Point;

part 'basic_canvas.dart';
part 'graphics2d_canvas.dart';
part 'graphics_canvas2d.dart';
part 'html_canvas.dart';
part 'canvas2d.dart';
part 'image_canvas.dart';
part 'svg_canvas.dart';
part 'vml_canvas.dart';

/**
 * Defines the requirements for a canvas that paints the vertices and edges of
 * a graph.
 */
public interface ICanvas
{
	/**
	 * Sets the translation for the following drawing requests.
	 */
	void setTranslate(int x, int y);

	/**
	 * Returns the current translation.
	 * 
	 * @return Returns the current translation.
	 */
	Point getTranslate();

	/**
	 * Sets the scale for the following drawing requests.
	 */
	void setScale(double scale);

	/**
	 * Returns the scale.
	 */
	double getScale();

	/**
	 * Draws the given cell.
	 * 
	 * @param state State of the cell to be painted.
	 * @return Object that represents the cell.
	 */
	Object drawCell(CellState state);

	/**
	 * Draws the given label.
	 * 
	 * @param text String that represents the label.
	 * @param state State of the cell whose label is to be painted.
	 * @param html Specifies if the label contains HTML markup.
	 * @return Object that represents the label.
	 */
	Object drawLabel(String text, CellState state, boolean html);

}
