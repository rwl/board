/**
 * $Id: ImageCanvas.java,v 1.1 2012/11/15 13:26:47 gaudenz Exp $
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
package graph.canvas;

import graph.util.Utils;
import graph.view.CellState;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.image.BufferedImage;

/**
 * An implementation of a canvas that uses Graphics2D for painting. To use an
 * image canvas for an existing graphics canvas and create an image the
 * following code is used:
 * 
 * <code>BufferedImage image = CellRenderer.createBufferedImage(graph, cells, 1, Color.white, true, null, canvas);</code> 
 */
public class ImageCanvas implements ICanvas
{

	/**
	 * 
	 */
	protected Graphics2DCanvas _canvas;

	/**
	 * 
	 */
	protected Graphics2D _previousGraphics;

	/**
	 * 
	 */
	protected BufferedImage _image;

	/**
	 * 
	 */
	public ImageCanvas(Graphics2DCanvas canvas, int width, int height,
			Color background, boolean antiAlias)
	{
		this._canvas = canvas;
		_previousGraphics = canvas.getGraphics();
		_image = Utils.createBufferedImage(width, height, background);

		if (_image != null)
		{
			Graphics2D g = _image.createGraphics();
			Utils.setAntiAlias(g, antiAlias, true);
			canvas.setGraphics(g);
		}
	}

	/**
	 * 
	 */
	public Graphics2DCanvas getGraphicsCanvas()
	{
		return _canvas;
	}

	/**
	 * 
	 */
	public BufferedImage getImage()
	{
		return _image;
	}

	/**
	 * 
	 */
	public Object drawCell(CellState state)
	{
		return _canvas.drawCell(state);
	}

	/**
	 * 
	 */
	public Object drawLabel(String label, CellState state, boolean html)
	{
		return _canvas.drawLabel(label, state, html);
	}

	/**
	 * 
	 */
	public double getScale()
	{
		return _canvas.getScale();
	}

	/**
	 * 
	 */
	public Point getTranslate()
	{
		return _canvas.getTranslate();
	}

	/**
	 * 
	 */
	public void setScale(double scale)
	{
		_canvas.setScale(scale);
	}

	/**
	 * 
	 */
	public void setTranslate(int dx, int dy)
	{
		_canvas.setTranslate(dx, dy);
	}

	/**
	 * 
	 */
	public BufferedImage destroy()
	{
		BufferedImage tmp = _image;

		if (_canvas.getGraphics() != null)
		{
			_canvas.getGraphics().dispose();
		}
		
		_canvas.setGraphics(_previousGraphics);

		_previousGraphics = null;
		_canvas = null;
		_image = null;

		return tmp;
	}

}
