package graph.swing.util;

//import graph.util.Constants;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.view.CellState;

//import java.awt.Cursor;
//import java.awt.Graphics;

//import javax.swing.ImageIcon;
//import javax.swing.JComponent;

public class CellOverlay extends JComponent implements ICellOverlay
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 921991820491141221L;

	/**
	 * 
	 */
	protected ImageIcon _imageIcon;

	/**
	 * Holds the horizontal alignment for the overlay.
	 * Default is ALIGN_RIGHT. For edges, the overlay
	 * always appears in the center of the edge.
	 */
	protected Object _align = Constants.ALIGN_RIGHT;

	/**
	 * Holds the vertical alignment for the overlay.
	 * Default is bottom. For edges, the overlay
	 * always appears in the center of the edge.
	 */
	protected Object _verticalAlign = Constants.ALIGN_BOTTOM;

	/**
	 * Defines the overlapping for the overlay, that is,
	 * the proportional distance from the origin to the
	 * point defined by the alignment. Default is 0.5.
	 */
	protected double _defaultOverlap = 0.5;

	/**
	 * 
	 */
	public CellOverlay(ImageIcon icon, String warning)
	{
		this._imageIcon = icon;
		setToolTipText(warning);
		setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
	}

	/**
	 * @return the alignment of the overlay, see <code>Constants.ALIGN_*****</code>
	 */
	public Object getAlign()
	{
		return _align;
	}

	/**
	 * @param value the alignment to set, see <code>Constants.ALIGN_*****</code>
	 */
	public void setAlign(Object value)
	{
		_align = value;
	}

	/**
	 * @return the vertical alignment, see <code>Constants.ALIGN_*****</code>
	 */
	public Object getVerticalAlign()
	{
		return _verticalAlign;
	}

	/**
	 * @param value the vertical alignment to set, see <code>Constants.ALIGN_*****</code>
	 */
	public void setVerticalAlign(Object value)
	{
		_verticalAlign = value;
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		g.drawImage(_imageIcon.getImage(), 0, 0, getWidth(), getHeight(), this);
	}

	/*
	 * (non-Javadoc)
	 * @see graph.swing.util.mxIOverlay#getBounds(graph.view.CellState)
	 */
	public Rect getBounds(CellState state)
	{
		boolean isEdge = state.getView().getGraph().getModel()
				.isEdge(state.getCell());
		double s = state.getView().getScale();
		Point2d pt = null;

		int w = _imageIcon.getIconWidth();
		int h = _imageIcon.getIconHeight();

		if (isEdge)
		{
			int n = state.getAbsolutePointCount();

			if (n % 2 == 1)
			{
				pt = state.getAbsolutePoint(n / 2 + 1);
			}
			else
			{
				int idx = n / 2;
				Point2d p0 = state.getAbsolutePoint(idx - 1);
				Point2d p1 = state.getAbsolutePoint(idx);
				pt = new Point2d(p0.getX() + (p1.getX() - p0.getX()) / 2,
						p0.getY() + (p1.getY() - p0.getY()) / 2);
			}
		}
		else
		{
			pt = new Point2d();

			if (_align.equals(Constants.ALIGN_LEFT))
			{
				pt.setX(state.getX());
			}
			else if (_align.equals(Constants.ALIGN_CENTER))
			{
				pt.setX(state.getX() + state.getWidth() / 2);
			}
			else
			{
				pt.setX(state.getX() + state.getWidth());
			}

			if (_verticalAlign.equals(Constants.ALIGN_TOP))
			{
				pt.setY(state.getY());
			}
			else if (_verticalAlign.equals(Constants.ALIGN_MIDDLE))
			{
				pt.setY(state.getY() + state.getHeight() / 2);
			}
			else
			{
				pt.setY(state.getY() + state.getHeight());
			}
		}

		return new Rect(pt.getX() - w * _defaultOverlap * s, pt.getY()
				- h * _defaultOverlap * s, w * s, h * s);
	}

}
