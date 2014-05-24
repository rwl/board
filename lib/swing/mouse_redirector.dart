part of graph.swing;

//import java.awt.event.MouseEvent;
//import java.awt.event.MouseListener;
//import java.awt.event.MouseMotionListener;

//import javax.swing.SwingUtilities;

/**
 * 
 */
public class MouseRedirector implements MouseListener,
		MouseMotionListener
{

	/**
	 * 
	 */
	protected GraphComponent graphComponent;

	/**
	 * 
	 */
	public MouseRedirector(GraphComponent graphComponent)
	{
		this.graphComponent = graphComponent;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseListener#mouseClicked(java.awt.event.MouseEvent)
	 */
	public void mouseClicked(MouseEvent e)
	{
		graphComponent.getGraphControl().dispatchEvent(
				SwingUtilities.convertMouseEvent(e.getComponent(), e,
						graphComponent.getGraphControl()));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseListener#mouseEntered(java.awt.event.MouseEvent)
	 */
	public void mouseEntered(MouseEvent e)
	{
		// Redirecting this would cause problems on the Mac
		// and is technically incorrect anyway
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseListener#mouseExited(java.awt.event.MouseEvent)
	 */
	public void mouseExited(MouseEvent e)
	{
		mouseClicked(e);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseListener#mousePressed(java.awt.event.MouseEvent)
	 */
	public void mousePressed(MouseEvent e)
	{
		mouseClicked(e);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseListener#mouseReleased(java.awt.event.MouseEvent)
	 */
	public void mouseReleased(MouseEvent e)
	{
		mouseClicked(e);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseMotionListener#mouseDragged(java.awt.event.MouseEvent
	 * )
	 */
	public void mouseDragged(MouseEvent e)
	{
		mouseClicked(e);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * java.awt.event.MouseMotionListener#mouseMoved(java.awt.event.MouseEvent
	 * )
	 */
	public void mouseMoved(MouseEvent e)
	{
		mouseClicked(e);
	}

}