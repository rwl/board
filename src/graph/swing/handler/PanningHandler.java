/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import graph.swing.GraphComponent;
//import graph.swing.util.MouseAdapter;

//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.event.MouseEvent;

/**
 * 
 */
public class PanningHandler extends MouseAdapter
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 7969814728058376339L;

	/**
	 * 
	 */
	protected GraphComponent _graphComponent;
	
	/**
	 * 
	 */
	protected boolean _enabled = true;

	/**
	 * 
	 */
	protected transient Point _start;

	/**
	 * 
	 * @param graphComponent
	 */
	public PanningHandler(GraphComponent graphComponent)
	{
		this._graphComponent = graphComponent;

		graphComponent.getGraphControl().addMouseListener(this);
		graphComponent.getGraphControl().addMouseMotionListener(this);
	}

	/**
	 * 
	 */
	public boolean isEnabled()
	{
		return _enabled;
	}

	/**
	 * 
	 */
	public void setEnabled(boolean value)
	{
		_enabled = value;
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		if (isEnabled() && !e.isConsumed() && _graphComponent.isPanningEvent(e)
				&& !e.isPopupTrigger())
		{
			_start = e.getPoint();
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (!e.isConsumed() && _start != null)
		{
			int dx = e.getX() - _start.x;
			int dy = e.getY() - _start.y;

			Rectangle r = _graphComponent.getViewport().getViewRect();

			int right = r.x + ((dx > 0) ? 0 : r.width) - dx;
			int bottom = r.y + ((dy > 0) ? 0 : r.height) - dy;

			_graphComponent.getGraphControl().scrollRectToVisible(
					new Rectangle(right, bottom, 0, 0));

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (!e.isConsumed() && _start != null)
		{
			int dx = Math.abs(_start.x - e.getX());
			int dy = Math.abs(_start.y - e.getY());

			if (_graphComponent.isSignificant(dx, dy))
			{
				e.consume();
			}
		}

		_start = null;
	}

	/**
	 * Whether or not panning is currently active
	 * @return Whether or not panning is currently active
	 */
	public boolean isActive()
	{
		return (_start != null);
	}
}
