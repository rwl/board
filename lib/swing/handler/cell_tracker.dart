/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import java.awt.Color;
//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

/**
 * Event handler that highlights cells. Inherits from CellMarker.
 */
class CellTracker extends CellMarker implements MouseListener,
		MouseMotionListener
{

	/**
	 * 
	 */
	static final long serialVersionUID = 7372144804885125688L;

	/**
	 * Constructs an event handler that highlights cells.
	 */
	CellTracker(GraphComponent graphComponent, Color color)
	{
		super(graphComponent, color);

		graphComponent.getGraphControl().addMouseListener(this);
		graphComponent.getGraphControl().addMouseMotionListener(this);
	}

	/**
	 * 
	 */
	void destroy()
	{
		_graphComponent.getGraphControl().removeMouseListener(this);
		_graphComponent.getGraphControl().removeMouseMotionListener(this);
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
	 */
	void mouseClicked(MouseEvent e)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
	void mouseEntered(MouseEvent e)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
	void mouseExited(MouseEvent e)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mousePressed(java.awt.event.MouseEvent)
	 */
	void mousePressed(MouseEvent e)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseListener#mouseReleased(java.awt.event.MouseEvent)
	 */
	void mouseReleased(MouseEvent e)
	{
		reset();
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseDragged(java.awt.event.MouseEvent)
	 */
	void mouseDragged(MouseEvent e)
	{
		// empty
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent)
	 */
	void mouseMoved(MouseEvent e)
	{
		process(e);
	}

}
