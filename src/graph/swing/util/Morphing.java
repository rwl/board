/**
 * $Id: Morphing.java,v 1.1 2012/11/15 13:26:46 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.swing.util;

import graph.model.Geometry;
import graph.swing.GraphComponent;
import graph.swing.view.CellStatePreview;
import graph.util.Event;
import graph.util.EventObj;
import graph.util.Point2d;
import graph.util.Rect;
import graph.view.CellState;
import graph.view.Graph;

import java.awt.Graphics;
import java.util.HashMap;
import java.util.Map;

/**
 * Provides animation effects.
 */
public class Morphing extends Animation
{

	/**
	 * Reference to the enclosing graph instance.
	 */
	protected GraphComponent graphComponent;

	/**
	 * Specifies the maximum number of steps for the morphing. Default is
	 * 6.
	 */
	protected int steps;

	/**
	 * Counts the current number of steps of the animation.
	 */
	protected int step;

	/**
	 * Ease-off for movement towards the given vector. Larger values are
	 * slower and smoother. Default is 1.5.
	 */
	protected double ease;

	/**
	 * Maps from cells to origins. 
	 */
	protected Map<Object, Point2d> origins = new HashMap<Object, Point2d>();

	/**
	 * Optional array of cells to limit the animation to. 
	 */
	protected Object[] cells;

	/**
	 * 
	 */
	protected transient Rect dirty;

	/**
	 * 
	 */
	protected transient CellStatePreview preview;

	/**
	 * Constructs a new morphing instance for the given graph.
	 */
	public Morphing(GraphComponent graphComponent)
	{
		this(graphComponent, 6, 1.5, DEFAULT_DELAY);

		// Installs the paint handler
		graphComponent.addListener(Event.AFTER_PAINT, new IEventListener()
		{
			public void invoke(Object sender, EventObj evt)
			{
				Graphics g = (Graphics) evt.getProperty("g");
				paint(g);
			}
		});
	}

	/**
	 * Constructs a new morphing instance for the given graph.
	 */
	public Morphing(GraphComponent graphComponent, int steps, double ease,
			int delay)
	{
		super(delay);
		this.graphComponent = graphComponent;
		this.steps = steps;
		this.ease = ease;
	}

	/**
	 * Returns the number of steps for the animation.
	 */
	public int getSteps()
	{
		return steps;
	}

	/**
	 * Sets the number of steps for the animation.
	 */
	public void setSteps(int value)
	{
		steps = value;
	}

	/**
	 * Returns the easing for the movements.
	 */
	public double getEase()
	{
		return ease;
	}

	/**
	 * Sets the easing for the movements.
	 */
	public void setEase(double value)
	{
		ease = value;
	}

	/**
	 * Optional array of cells to be animated. If this is not specified
	 * then all cells are checked and animated if they have been moved
	 * in the current transaction.
	 */
	public void setCells(Object[] value)
	{
		cells = value;
	}

	/**
	 * Animation step.
	 */
	public void updateAnimation()
	{
		preview = new CellStatePreview(graphComponent, false);

		if (cells != null)
		{
			// Animates the given cells individually without recursion
			for (Object cell : cells)
			{
				animateCell(cell, preview, false);
			}
		}
		else
		{
			// Animates all changed cells by using recursion to find
			// the changed cells but not for the animation itself
			Object root = graphComponent.getGraph().getModel().getRoot();
			animateCell(root, preview, true);
		}

		show(preview);

		if (preview.isEmpty() || step++ >= steps)
		{
			stopAnimation();
		}
	};

	/**
	 * 
	 */
	public void stopAnimation()
	{
		graphComponent.getGraph().getView().revalidate();
		super.stopAnimation();

		preview = null;

		if (dirty != null)
		{
			graphComponent.getGraphControl().repaint(dirty.getRectangle());
		}
	}

	/**
	 * Shows the changes in the given CellStatePreview.
	 */
	protected void show(CellStatePreview preview)
	{
		if (dirty != null)
		{
			graphComponent.getGraphControl().repaint(dirty.getRectangle());
		}
		else
		{
			graphComponent.getGraphControl().repaint();
		}

		dirty = preview.show();

		if (dirty != null)
		{
			graphComponent.getGraphControl().repaint(dirty.getRectangle());
		}
	}

	/**
	 * Animates the given cell state using moveState.
	 */
	protected void animateCell(Object cell, CellStatePreview move,
			boolean recurse)
	{
		Graph graph = graphComponent.getGraph();
		CellState state = graph.getView().getState(cell);
		Point2d delta = null;

		if (state != null)
		{
			// Moves the animated state from where it will be after the model
			// change by subtracting the given delta vector from that location
			delta = getDelta(state);

			if (graph.getModel().isVertex(cell)
					&& (delta.getX() != 0 || delta.getY() != 0))
			{
				Point2d translate = graph.getView().getTranslate();
				double scale = graph.getView().getScale();

				// FIXME: Something wrong with the scale
				delta.setX(delta.getX() + translate.getX() * scale);
				delta.setY(delta.getY() + translate.getY() * scale);

				move.moveState(state, -delta.getX() / ease, -delta.getY()
						/ ease);
			}
		}

		if (recurse && !stopRecursion(state, delta))
		{
			int childCount = graph.getModel().getChildCount(cell);

			for (int i = 0; i < childCount; i++)
			{
				animateCell(graph.getModel().getChildAt(cell, i), move, recurse);
			}
		}
	}

	/**
	 * Returns true if the animation should not recursively find more
	 * deltas for children if the given parent state has been animated.
	 */
	protected boolean stopRecursion(CellState state, Point2d delta)
	{
		return delta != null && (delta.getX() != 0 || delta.getY() != 0);
	}

	/**
	 * Returns the vector between the current rendered state and the future
	 * location of the state after the display will be updated.
	 */
	protected Point2d getDelta(CellState state)
	{
		Graph graph = graphComponent.getGraph();
		Point2d origin = getOriginForCell(state.getCell());
		Point2d translate = graph.getView().getTranslate();
		double scale = graph.getView().getScale();
		Point2d current = new Point2d(state.getX() / scale - translate.getX(),
				state.getY() / scale - translate.getY());

		return new Point2d((origin.getX() - current.getX()) * scale, (origin
				.getY() - current.getY())
				* scale);
	}

	/**
	 * Returns the top, left corner of the given cell.
	 */
	protected Point2d getOriginForCell(Object cell)
	{
		Point2d result = origins.get(cell);

		if (result == null)
		{
			Graph graph = graphComponent.getGraph();

			if (cell != null)
			{
				result = new Point2d(getOriginForCell(graph.getModel()
						.getParent(cell)));
				Geometry geo = graph.getCellGeometry(cell);

				// TODO: Handle offset, relative geometries etc
				if (geo != null)
				{
					result.setX(result.getX() + geo.getX());
					result.setY(result.getY() + geo.getY());
				}
			}

			if (result == null)
			{
				Point2d t = graph.getView().getTranslate();
				result = new Point2d(-t.getX(), -t.getY());
			}

			origins.put(cell, result);
		}

		return result;
	}

	/**
	 *
	 */
	public void paint(Graphics g)
	{
		if (preview != null)
		{
			preview.paint(g);
		}
	}

}
