part of graph.swing;

import '../view/view.dart' show GraphView;

//import java.awt.Cursor;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

//import javax.swing.JScrollBar;

/**
 *
 */
class MouseTracker implements MouseListener, MouseMotionListener
{
	/**
	 * 
	 */
	final GraphOutline graphOutline;

	/**
	 * @param graphOutline
	 */
	MouseTracker(GraphOutline graphOutline) {
		this.graphOutline = graphOutline;
	}

	/**
	 * 
	 */
	Point start = null;

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mousePressed(java.awt.event.MouseEvent)
	 */
	void mousePressed(MouseEvent e)
	{
		this.graphOutline._zoomGesture = hitZoomHandle(e.getX(), e.getY());

		if (this.graphOutline._graphComponent != null && !e.isConsumed()
				&& !e.isPopupTrigger()
				&& (this.graphOutline._finderBounds.contains(e.getPoint()) || this.graphOutline._zoomGesture))
		{
			start = e.getPoint();
		}
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseDragged(java.awt.event.MouseEvent)
	 */
	void mouseDragged(MouseEvent e)
	{
		if (this.graphOutline.isEnabled() && start != null)
		{
			if (this.graphOutline._zoomGesture)
			{
				Rectangle bounds = this.graphOutline._graphComponent.getViewport()
						.getViewRect();
				double viewRatio = bounds.getWidth() / bounds.getHeight();

				bounds = new Rectangle(this.graphOutline._finderBounds);
				bounds.width = (int) Math
						.max(0, (e.getX() - bounds.getX()));
				bounds.height = (int) Math.max(0,
						(bounds.getWidth() / viewRatio));

				this.graphOutline.updateFinderBounds(bounds, true);
			}
			else
			{
				// TODO: To enable constrained moving, that is, moving
				// into only x- or y-direction when shift is pressed,
				// we need the location of the first mouse event, since
				// the movement can not be constrained for incremental
				// steps as used below.
				int dx = (int) ((e.getX() - start.getX()) / this.graphOutline._scale);
				int dy = (int) ((e.getY() - start.getY()) / this.graphOutline._scale);

				// Keeps current location as start for delta movement
				// of the scrollbars
				start = e.getPoint();

				this.graphOutline._graphComponent.getHorizontalScrollBar().setValue(
						this.graphOutline._graphComponent.getHorizontalScrollBar().getValue()
								+ dx);
				this.graphOutline._graphComponent.getVerticalScrollBar().setValue(
						this.graphOutline._graphComponent.getVerticalScrollBar().getValue()
								+ dy);
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseReleased(java.awt.event.MouseEvent)
	 */
	void mouseReleased(MouseEvent e)
	{
		if (start != null)
		{
			if (this.graphOutline._zoomGesture)
			{
				double dx = e.getX() - start.getX();
				double w = this.graphOutline._finderBounds.getWidth();

				final JScrollBar hs = this.graphOutline._graphComponent
						.getHorizontalScrollBar();
				final double sx;

				if (hs != null)
				{
					sx = (double) hs.getValue() / hs.getMaximum();
				}
				else
				{
					sx = 0;
				}

				final JScrollBar vs = this.graphOutline._graphComponent.getVerticalScrollBar();
				final double sy;

				if (vs != null)
				{
					sy = (double) vs.getValue() / vs.getMaximum();
				}
				else
				{
					sy = 0;
				}

				GraphView view = this.graphOutline._graphComponent.getGraph().getView();
				double scale = view.getScale();
				double newScale = scale - (dx * scale) / w;
				double factor = newScale / scale;
				view.setScale(newScale);

				if (hs != null)
				{
					hs.setValue((int) (sx * hs.getMaximum() * factor));
				}

				if (vs != null)
				{
					vs.setValue((int) (sy * vs.getMaximum() * factor));
				}
			}

			this.graphOutline._zoomGesture = false;
			start = null;
		}
	}

	/**
	 * 
	 */
	bool hitZoomHandle(int x, int y)
	{
		return new Rectangle(this.graphOutline._finderBounds.x + this.graphOutline._finderBounds.width - 6,
				this.graphOutline._finderBounds.y + this.graphOutline._finderBounds.height - 6, 8, 8).contains(x,
				y);
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent)
	 */
	void mouseMoved(MouseEvent e)
	{
		if (hitZoomHandle(e.getX(), e.getY()))
		{
			this.graphOutline.setCursor(new Cursor(Cursor.HAND_CURSOR));
		}
		else if (this.graphOutline._finderBounds.contains(e.getPoint()))
		{
			this.graphOutline.setCursor(new Cursor(Cursor.MOVE_CURSOR));
		}
		else
		{
			this.graphOutline.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
		}
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
	 */
	void mouseClicked(MouseEvent e)
	{
		// ignore
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
	void mouseEntered(MouseEvent e)
	{
		// ignore
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
	void mouseExited(MouseEvent e)
	{
		// ignore
	}

}