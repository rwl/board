/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.swing.util;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Component;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Stroke;
//import java.awt.image.BufferedImage;

//import javax.swing.border.Border;
//import javax.swing.border.LineBorder;

class SwingConstants
{
	/**
	 * Contains an empty image of size 1, 1.
	 */
	static BufferedImage EMPTY_IMAGE;

	static init()
	{
		try
		{
			SwingConstants.EMPTY_IMAGE = new BufferedImage(1, 1,
					BufferedImage.TYPE_INT_RGB);
		}
		on Exception catch (e)
		{
			// Occurs when running on GAE, BufferedImage is a
			// blacklisted class
			SwingConstants.EMPTY_IMAGE = null;
		}
	}
	
	/**
	 * Defines the color to be used for shadows. Default is gray.
	 */
	static Color SHADOW_COLOR;
	
	/**
	 * Specifies the default valid color. Default is green.
	 */
	static Color DEFAULT_VALID_COLOR;

	/**
	 * Specifies the default invalid color. Default is red.
	 */
	static Color DEFAULT_INVALID_COLOR;
	
	/**
	 * Defines the rubberband border color. 
	 */
	static Color RUBBERBAND_BORDERCOLOR;

	/**
	 * Defines the rubberband fill color with an alpha of 80.
	 */
	static Color RUBBERBAND_FILLCOLOR;
	
	/**
	 * Defines the handle border color. Default is black.
	 */
	static Color HANDLE_BORDERCOLOR;

	/**
	 * Defines the handle fill color. Default is green.
	 */
	static Color HANDLE_FILLCOLOR;

	/**
	 * Defines the label handle fill color. Default is yellow.
	 */
	static Color LABEL_HANDLE_FILLCOLOR;

	/**
	 * Defines the connect handle fill color. Default is blue.
	 */
	static Color CONNECT_HANDLE_FILLCOLOR;

	/**
	 * Defines the handle fill color for locked handles. Default is red.
	 */
	static Color LOCKED_HANDLE_FILLCOLOR;
	
	/**
	 * Defines the selection color for edges. Default is green.
	 */
	static Color EDGE_SELECTION_COLOR;

	/**
	 * Defines the selection color for vertices. Default is green.
	 */
	static Color VERTEX_SELECTION_COLOR;
	
	static init2()
	{
		try
		{
			SwingConstants.SHADOW_COLOR = Color.gray;
			SwingConstants.DEFAULT_VALID_COLOR = Color.GREEN;
			SwingConstants.DEFAULT_INVALID_COLOR = Color.RED;
			SwingConstants.RUBBERBAND_BORDERCOLOR = new Color(51, 153, 255);
			SwingConstants.RUBBERBAND_FILLCOLOR = new Color(51, 153, 255, 80);
			SwingConstants.HANDLE_BORDERCOLOR = Color.black;
			SwingConstants.HANDLE_FILLCOLOR = Color.green;
			SwingConstants.LABEL_HANDLE_FILLCOLOR = Color.yellow;
			SwingConstants.LOCKED_HANDLE_FILLCOLOR = Color.red;
			SwingConstants.CONNECT_HANDLE_FILLCOLOR = Color.blue;
			SwingConstants.EDGE_SELECTION_COLOR = Color.green;
			SwingConstants.VERTEX_SELECTION_COLOR = Color.green;
		}
		on Exception catch (e)
		{
			// Occurs when running on GAE, Color is a
			// blacklisted class
			SwingConstants.SHADOW_COLOR = null;
			SwingConstants.DEFAULT_VALID_COLOR = null;
			SwingConstants.DEFAULT_INVALID_COLOR = null;
			SwingConstants.RUBBERBAND_BORDERCOLOR = null;
			SwingConstants.RUBBERBAND_FILLCOLOR = null;
			SwingConstants.HANDLE_BORDERCOLOR = null;
			SwingConstants.HANDLE_FILLCOLOR = null;
			SwingConstants.LABEL_HANDLE_FILLCOLOR = null;
			SwingConstants.LOCKED_HANDLE_FILLCOLOR = null;
			SwingConstants.CONNECT_HANDLE_FILLCOLOR = null;
			SwingConstants.EDGE_SELECTION_COLOR = null;
			SwingConstants.VERTEX_SELECTION_COLOR = null;
		}
	}
	
	/**
	 * Defines the stroke used for painting selected edges. Default is a dashed
	 * line.
	 */
	static Stroke EDGE_SELECTION_STROKE = new BasicStroke(1,
			BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0, [
					3.0, 3.0 ], 0.0);

	/**
	 * Defines the stroke used for painting the border of selected vertices.
	 * Default is a dashed line.
	 */
	static Stroke VERTEX_SELECTION_STROKE = new BasicStroke(1,
			BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0, [
					3.0, 3.0 ], 0.0);

	/**
	 * Defines the stroke used for painting the preview for new and existing edges
	 * that are being changed. Default is a dashed line.
	 */
	static Stroke PREVIEW_STROKE = new BasicStroke(1,
			BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10.0, [
					3.0, 3.0 ], 0.0);

	/**
	 * Defines the border used for painting the preview when vertices are being
	 * resized, or cells and labels are being moved.
	 */
	/*static Border PREVIEW_BORDER = new LineBorder(
			SwingConstants.HANDLE_BORDERCOLOR)
	{
		/**
		 * 
		 */
		private static final long serialVersionUID = 1348016511717964310L;

		public void paintBorder(Component c, Graphics g, int x, int y,
				int width, int height)
		{
			((Graphics2D) g).setStroke(VERTEX_SELECTION_STROKE);
			super.paintBorder(c, g, x, y, width, height);
		}
	};*/
}
