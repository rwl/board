/**
 * Copyright (c) 2008-2012, JGraph Ltd
 */
part of graph.swing.handler;

//import graph.model.Geometry;
//import graph.swing.GraphComponent;
//import graph.swing.util.SwingConstants;
//import graph.util.Constants;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.view.CellState;
//import graph.view.Graph;

//import java.awt.Color;
//import java.awt.Cursor;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.MouseEvent;

//import javax.swing.JComponent;
//import javax.swing.JPanel;

/**
 * 
 */
public class VertexHandler extends CellHandler
{

	/**
	 * 
	 */
	public static Cursor[] CURSORS = new Cursor[] {
			new Cursor(Cursor.NW_RESIZE_CURSOR),
			new Cursor(Cursor.N_RESIZE_CURSOR),
			new Cursor(Cursor.NE_RESIZE_CURSOR),
			new Cursor(Cursor.W_RESIZE_CURSOR),
			new Cursor(Cursor.E_RESIZE_CURSOR),
			new Cursor(Cursor.SW_RESIZE_CURSOR),
			new Cursor(Cursor.S_RESIZE_CURSOR),
			new Cursor(Cursor.SE_RESIZE_CURSOR), new Cursor(Cursor.MOVE_CURSOR) };

	/**
	 * Workaround for alt-key-state not correct in mouseReleased.
	 */
	protected transient boolean _gridEnabledEvent = false;

	/**
	 * Workaround for shift-key-state not correct in mouseReleased.
	 */
	protected transient boolean _constrainedEvent = false;

	/**
	 * 
	 * @param graphComponent
	 * @param state
	 */
	public VertexHandler(GraphComponent graphComponent, CellState state)
	{
		super(graphComponent, state);
	}

	/**
	 * 
	 */
	protected Rectangle[] _createHandles()
	{
		Rectangle[] h = null;

		if (_graphComponent.getGraph().isCellResizable(getState().getCell()))
		{
			Rectangle bounds = getState().getRectangle();
			int half = Constants.HANDLE_SIZE / 2;

			int left = bounds.x - half;
			int top = bounds.y - half;

			int w2 = bounds.x + (bounds.width / 2) - half;
			int h2 = bounds.y + (bounds.height / 2) - half;

			int right = bounds.x + bounds.width - half;
			int bottom = bounds.y + bounds.height - half;

			h = new Rectangle[9];

			int s = Constants.HANDLE_SIZE;
			h[0] = new Rectangle(left, top, s, s);
			h[1] = new Rectangle(w2, top, s, s);
			h[2] = new Rectangle(right, top, s, s);
			h[3] = new Rectangle(left, h2, s, s);
			h[4] = new Rectangle(right, h2, s, s);
			h[5] = new Rectangle(left, bottom, s, s);
			h[6] = new Rectangle(w2, bottom, s, s);
			h[7] = new Rectangle(right, bottom, s, s);
		}
		else
		{
			h = new Rectangle[1];
		}

		int s = Constants.LABEL_HANDLE_SIZE;
		Rect bounds = _state.getLabelBounds();
		h[h.length - 1] = new Rectangle((int) (bounds.getX()
				+ bounds.getWidth() / 2 - s), (int) (bounds.getY()
				+ bounds.getHeight() / 2 - s), 2 * s, 2 * s);

		return h;
	}

	/**
	 * 
	 */
	protected JComponent _createPreview()
	{
		JPanel preview = new JPanel();
		preview.setBorder(SwingConstants.PREVIEW_BORDER);
		preview.setOpaque(false);
		preview.setVisible(false);

		return preview;
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (!e.isConsumed() && _first != null)
		{
			_gridEnabledEvent = _graphComponent.isGridEnabledEvent(e);
			_constrainedEvent = _graphComponent.isConstrainedEvent(e);

			double dx = e.getX() - _first.x;
			double dy = e.getY() - _first.y;

			if (isLabel(_index))
			{
				Point2d pt = new Point2d(e.getPoint());

				if (_gridEnabledEvent)
				{
					pt = _graphComponent.snapScaledPoint(pt);
				}

				int idx = (int) Math.round(pt.getX() - _first.x);
				int idy = (int) Math.round(pt.getY() - _first.y);

				if (_constrainedEvent)
				{
					if (Math.abs(idx) > Math.abs(idy))
					{
						idy = 0;
					}
					else
					{
						idx = 0;
					}
				}

				Rectangle rect = _state.getLabelBounds().getRectangle();
				rect.translate(idx, idy);
				_preview.setBounds(rect);
			}
			else
			{
				Graph graph = _graphComponent.getGraph();
				double scale = graph.getView().getScale();

				if (_gridEnabledEvent)
				{
					dx = graph.snap(dx / scale) * scale;
					dy = graph.snap(dy / scale) * scale;
				}

				Rect bounds = _union(getState(), dx, dy, _index);
				bounds.setWidth(bounds.getWidth() + 1);
				bounds.setHeight(bounds.getHeight() + 1);
				_preview.setBounds(bounds.getRectangle());
			}

			if (!_preview.isVisible() && _graphComponent.isSignificant(dx, dy))
			{
				_preview.setVisible(true);
			}

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		if (!e.isConsumed() && _first != null)
		{
			if (_preview != null && _preview.isVisible())
			{
				if (isLabel(_index))
				{
					_moveLabel(e);
				}
				else
				{
					_resizeCell(e);
				}
			}

			e.consume();
		}

		super.mouseReleased(e);
	}

	/**
	 * 
	 */
	protected void _moveLabel(MouseEvent e)
	{
		Graph graph = _graphComponent.getGraph();
		Geometry geometry = graph.getModel().getGeometry(_state.getCell());

		if (geometry != null)
		{
			double scale = graph.getView().getScale();
			Point2d pt = new Point2d(e.getPoint());

			if (_gridEnabledEvent)
			{
				pt = _graphComponent.snapScaledPoint(pt);
			}

			double dx = (pt.getX() - _first.x) / scale;
			double dy = (pt.getY() - _first.y) / scale;

			if (_constrainedEvent)
			{
				if (Math.abs(dx) > Math.abs(dy))
				{
					dy = 0;
				}
				else
				{
					dx = 0;
				}
			}

			Point2d offset = geometry.getOffset();

			if (offset == null)
			{
				offset = new Point2d();
			}

			dx += offset.getX();
			dy += offset.getY();

			geometry = (Geometry) geometry.clone();
			geometry.setOffset(new Point2d(Math.round(dx), Math.round(dy)));
			graph.getModel().setGeometry(_state.getCell(), geometry);
		}
	}

	/**
	 * 
	 * @param e
	 */
	protected void _resizeCell(MouseEvent e)
	{
		Graph graph = _graphComponent.getGraph();
		double scale = graph.getView().getScale();

		Object cell = _state.getCell();
		Geometry geometry = graph.getModel().getGeometry(cell);

		if (geometry != null)
		{
			double dx = (e.getX() - _first.x) / scale;
			double dy = (e.getY() - _first.y) / scale;

			if (isLabel(_index))
			{
				geometry = (Geometry) geometry.clone();

				if (geometry.getOffset() != null)
				{
					dx += geometry.getOffset().getX();
					dy += geometry.getOffset().getY();
				}

				if (_gridEnabledEvent)
				{
					dx = graph.snap(dx);
					dy = graph.snap(dy);
				}

				geometry.setOffset(new Point2d(dx, dy));
				graph.getModel().setGeometry(cell, geometry);
			}
			else
			{
				Rect bounds = _union(geometry, dx, dy, _index);
				Rectangle rect = bounds.getRectangle();

				// Snaps new bounds to grid (unscaled)
				if (_gridEnabledEvent)
				{
					int x = (int) graph.snap(rect.x);
					int y = (int) graph.snap(rect.y);
					rect.width = (int) graph.snap(rect.width - x + rect.x);
					rect.height = (int) graph.snap(rect.height - y + rect.y);
					rect.x = x;
					rect.y = y;
				}

				graph.resizeCell(cell, new Rect(rect));
			}
		}
	}

	/**
	 * 
	 */
	protected Cursor _getCursor(MouseEvent e, int index)
	{
		if (index >= 0 && index <= CURSORS.length)
		{
			return CURSORS[index];
		}

		return null;
	}

	/**
	 * 
	 * @param bounds
	 * @param dx
	 * @param dy
	 * @param index
	 */
	protected Rect _union(Rect bounds, double dx, double dy,
			int index)
	{
		double left = bounds.getX();
		double right = left + bounds.getWidth();
		double top = bounds.getY();
		double bottom = top + bounds.getHeight();

		if (index > 4 /* Bottom Row */)
		{
			bottom = bottom + dy;
		}
		else if (index < 3 /* Top Row */)
		{
			top = top + dy;
		}

		if (index == 0 || index == 3 || index == 5 /* Left */)
		{
			left += dx;
		}
		else if (index == 2 || index == 4 || index == 7 /* Right */)
		{
			right += dx;
		}

		double width = right - left;
		double height = bottom - top;

		// Flips over left side
		if (width < 0)
		{
			left += width;
			width = Math.abs(width);
		}

		// Flips over top side
		if (height < 0)
		{
			top += height;
			height = Math.abs(height);
		}

		return new Rect(left, top, width, height);
	}

	/**
	 * 
	 */
	public Color getSelectionColor()
	{
		return SwingConstants.VERTEX_SELECTION_COLOR;
	}

	/**
	 * 
	 */
	public Stroke getSelectionStroke()
	{
		return SwingConstants.VERTEX_SELECTION_STROKE;
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		Rectangle bounds = getState().getRectangle();

		if (g.hitClip(bounds.x, bounds.y, bounds.width, bounds.height))
		{
			Graphics2D g2 = (Graphics2D) g;

			Stroke stroke = g2.getStroke();
			g2.setStroke(getSelectionStroke());
			g.setColor(getSelectionColor());
			g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			g2.setStroke(stroke);
		}

		super.paint(g);
	}

}
