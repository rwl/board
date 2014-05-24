/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
part of graph.swing.view;

//import graph.canvas.Graphics2DCanvas;
//import graph.shape.BasicShape;
//import graph.shape.IShape;
//import graph.swing.GraphComponent;
//import graph.util.Constants;
//import graph.util.Point2d;
//import graph.util.Utils;
//import graph.view.CellState;

//import java.awt.Dimension;
//import java.awt.Image;
//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.awt.image.ImageObserver;

public class InteractiveCanvas extends Graphics2DCanvas
{
	/**
	 * 
	 */
	protected ImageObserver _imageObserver = null;

	/**
	 * 
	 */
	public InteractiveCanvas()
	{
		this(null);
	}

	/**
	 * 
	 */
	public InteractiveCanvas(ImageObserver imageObserver)
	{
		setImageObserver(imageObserver);
	}

	/**
	 * 
	 */
	public void setImageObserver(ImageObserver value)
	{
		_imageObserver = value;
	}

	/**
	 * 
	 */
	public ImageObserver getImageObserver()
	{
		return _imageObserver;
	}

	/**
	 * Overrides graphics call to use image observer.
	 */
	protected void _drawImageImpl(Image image, int x, int y)
	{
		_g.drawImage(image, x, y, _imageObserver);
	}

	/**
	 * Returns the size for the given image.
	 */
	protected Dimension _getImageSize(Image image)
	{
		return new Dimension(image.getWidth(_imageObserver),
				image.getHeight(_imageObserver));
	}

	/**
	 * 
	 */
	public boolean contains(GraphComponent graphComponent, Rectangle rect,
			CellState state)
	{
		return state != null && state.getX() >= rect.x
				&& state.getY() >= rect.y
				&& state.getX() + state.getWidth() <= rect.x + rect.width
				&& state.getY() + state.getHeight() <= rect.y + rect.height;
	}

	/**
	 * 
	 */
	public boolean intersects(GraphComponent graphComponent, Rectangle rect,
			CellState state)
	{
		if (state != null)
		{
			// Checks if the label intersects
			if (state.getLabelBounds() != null
					&& state.getLabelBounds().getRectangle().intersects(rect))
			{
				return true;
			}

			int pointCount = state.getAbsolutePointCount();

			// Checks if the segments of the edge intersect
			if (pointCount > 0)
			{
				rect = (Rectangle) rect.clone();
				int tolerance = graphComponent.getTolerance();
				rect.grow(tolerance, tolerance);

				Shape realShape = null;

				// FIXME: Check if this should be used for all shapes
				if (Utils.getString(state.getStyle(),
						Constants.STYLE_SHAPE, "").equals(
						Constants.SHAPE_ARROW))
				{
					IShape shape = getShape(state.getStyle());

					if (shape instanceof BasicShape)
					{
						realShape = ((BasicShape) shape).createShape(this,
								state);
					}
				}

				if (realShape != null && realShape.intersects(rect))
				{
					return true;
				}
				else
				{
					Point2d p0 = state.getAbsolutePoint(0);

					for (int i = 0; i < pointCount; i++)
					{
						Point2d p1 = state.getAbsolutePoint(i);

						if (rect.intersectsLine(p0.getX(), p0.getY(),
								p1.getX(), p1.getY()))
						{
							return true;
						}

						p0 = p1;
					}
				}
			}
			else
			{
				// Checks if the bounds of the shape intersect
				return state.getRectangle().intersects(rect);
			}
		}

		return false;
	}

	/**
	 * Returns true if the given point is inside the content area of the given
	 * swimlane. (The content area of swimlanes is transparent to events.) This
	 * implementation does not check if the given state is a swimlane, it is
	 * assumed that the caller has checked this before using this method.
	 */
	public boolean hitSwimlaneContent(GraphComponent graphComponent,
			CellState swimlane, int x, int y)
	{
		if (swimlane != null)
		{
			int start = (int) Math.max(2, Math.round(Utils.getInt(
					swimlane.getStyle(), Constants.STYLE_STARTSIZE,
					Constants.DEFAULT_STARTSIZE)
					* graphComponent.getGraph().getView().getScale()));
			Rectangle rect = swimlane.getRectangle();

			if (Utils.isTrue(swimlane.getStyle(),
					Constants.STYLE_HORIZONTAL, true))
			{
				rect.y += start;
				rect.height -= start;
			}
			else
			{
				rect.x += start;
				rect.width -= start;
			}

			return rect.contains(x, y);
		}

		return false;
	}

}
