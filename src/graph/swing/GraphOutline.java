/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing;

//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.Point2d;
//import graph.util.Rect;
//import graph.util.Utils;
//import graph.util.EventSource.IEventListener;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Dimension;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.AdjustmentEvent;
//import java.awt.event.AdjustmentListener;
//import java.awt.event.ComponentAdapter;
//import java.awt.event.ComponentEvent;
//import java.awt.event.ComponentListener;
//import java.awt.geom.AffineTransform;
//import java.awt.image.BufferedImage;

//import javax.swing.JComponent;

/**
 * An outline view for a specific graph component.
 */
public class GraphOutline extends JComponent
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -2521103946905154267L;

	/**
	 * 
	 */
	public static Color DEFAULT_ZOOMHANDLE_FILL = new Color(0, 255, 255);

	/**
	 * 
	 */
	protected GraphComponent _graphComponent;

	/**
	 * TODO: Not yet implemented.
	 */
	protected BufferedImage _tripleBuffer;

	/**
	 * Holds the graphics of the triple buffer.
	 */
	protected Graphics2D _tripleBufferGraphics;

	/**
	 * True if the triple buffer needs a full repaint.
	 */
	protected boolean _repaintBuffer = false;

	/**
	 * Clip of the triple buffer to be repainted.
	 */
	protected Rect _repaintClip = null;

	/**
	 * 
	 */
	protected boolean _tripleBuffered = true;

	/**
	 * 
	 */
	protected Rectangle _finderBounds = new Rectangle();

	/**
	 * 
	 */
	protected Point _zoomHandleLocation = null;

	/**
	 * 
	 */
	protected boolean _finderVisible = true;

	/**
	 * 
	 */
	protected boolean _zoomHandleVisible = true;

	/**
	 * 
	 */
	protected boolean _useScaledInstance = false;

	/**
	 * 
	 */
	protected boolean _antiAlias = false;

	/**
	 * 
	 */
	protected boolean _drawLabels = false;

	/**
	 * Specifies if the outline should be zoomed to the page if the graph
	 * component is in page layout mode. Default is true.
	 */
	protected boolean _fitPage = true;

	/**
	 * Not yet implemented.
	 * 
	 * Border to add around the page bounds if wholePage is true.
	 * Default is 4.
	 */
	protected int _outlineBorder = 10;

	/**
	 * 
	 */
	protected MouseTracker _tracker = new MouseTracker(this);

	/**
	 * 
	 */
	protected double _scale = 1;

	/**
	 * 
	 */
	protected Point _translate = new Point();

	/**
	 * 
	 */
	protected transient boolean _zoomGesture = false;

	/**
	 * 
	 */
	protected IEventListener _repaintHandler = new IEventListener()
	{
		public void invoke(Object source, EventObj evt)
		{
			updateScaleAndTranslate();
			Rect dirty = (Rect) evt.getProperty("region");

			if (dirty != null)
			{
				_repaintClip = new Rect(dirty);
			}
			else
			{
				_repaintBuffer = true;
			}

			if (dirty != null)
			{
				updateFinder(true);

				dirty.grow(1 / _scale);

				dirty.setX(dirty.getX() * _scale + _translate.x);
				dirty.setY(dirty.getY() * _scale + _translate.y);
				dirty.setWidth(dirty.getWidth() * _scale);
				dirty.setHeight(dirty.getHeight() * _scale);

				repaint(dirty.getRectangle());
			}
			else
			{
				updateFinder(false);
				repaint();
			}
		}
	};

	/**
	 * 
	 */
	protected ComponentListener _componentHandler = new ComponentAdapter()
	{
		public void componentResized(ComponentEvent e)
		{
			if (updateScaleAndTranslate())
			{
				_repaintBuffer = true;
				updateFinder(false);
				repaint();
			}
			else
			{
				updateFinder(true);
			}
		}
	};

	/**
	 * 
	 */
	protected AdjustmentListener _adjustmentHandler = new AdjustmentListener()
	{

		/**
		 * 
		 */
		public void adjustmentValueChanged(AdjustmentEvent e)
		{
			if (updateScaleAndTranslate())
			{
				_repaintBuffer = true;
				updateFinder(false);
				repaint();
			}
			else
			{
				updateFinder(true);
			}
		}

	};

	/**
	 * 
	 */
	public GraphOutline(GraphComponent graphComponent)
	{
		addComponentListener(_componentHandler);
		addMouseMotionListener(_tracker);
		addMouseListener(_tracker);
		setGraphComponent(graphComponent);
		setEnabled(true);
		setOpaque(true);
	}

	/**
	 * Fires a property change event for <code>tripleBuffered</code>.
	 * 
	 * @param tripleBuffered the tripleBuffered to set
	 */
	public void setTripleBuffered(boolean tripleBuffered)
	{
		boolean oldValue = this._tripleBuffered;
		this._tripleBuffered = tripleBuffered;

		if (!tripleBuffered)
		{
			destroyTripleBuffer();
		}

		firePropertyChange("tripleBuffered", oldValue, tripleBuffered);
	}

	/**
	 * 
	 */
	public boolean isTripleBuffered()
	{
		return _tripleBuffered;
	}

	/**
	 * Fires a property change event for <code>drawLabels</code>.
	 * 
	 * @param drawLabels the drawLabels to set
	 */
	public void setDrawLabels(boolean drawLabels)
	{
		boolean oldValue = this._drawLabels;
		this._drawLabels = drawLabels;
		repaintTripleBuffer(null);

		firePropertyChange("drawLabels", oldValue, drawLabels);
	}

	/**
	 * 
	 */
	public boolean isDrawLabels()
	{
		return _drawLabels;
	}

	/**
	 * Fires a property change event for <code>antiAlias</code>.
	 * 
	 * @param antiAlias the antiAlias to set
	 */
	public void setAntiAlias(boolean antiAlias)
	{
		boolean oldValue = this._antiAlias;
		this._antiAlias = antiAlias;
		repaintTripleBuffer(null);

		firePropertyChange("antiAlias", oldValue, antiAlias);
	}

	/**
	 * @return the antiAlias
	 */
	public boolean isAntiAlias()
	{
		return _antiAlias;
	}

	/**
	 * 
	 */
	public void setVisible(boolean visible)
	{
		super.setVisible(visible);

		// Frees memory if the outline is hidden
		if (!visible)
		{
			destroyTripleBuffer();
		}
	}

	/**
	 * 
	 */
	public void setFinderVisible(boolean visible)
	{
		_finderVisible = visible;
	}

	/**
	 * 
	 */
	public void setZoomHandleVisible(boolean visible)
	{
		_zoomHandleVisible = visible;
	}

	/**
	 * Fires a property change event for <code>fitPage</code>.
	 * 
	 * @param fitPage the fitPage to set
	 */
	public void setFitPage(boolean fitPage)
	{
		boolean oldValue = this._fitPage;
		this._fitPage = fitPage;

		if (updateScaleAndTranslate())
		{
			_repaintBuffer = true;
			updateFinder(false);
		}

		firePropertyChange("fitPage", oldValue, fitPage);
	}

	/**
	 * 
	 */
	public boolean isFitPage()
	{
		return _fitPage;
	}

	/**
	 * 
	 */
	public GraphComponent getGraphComponent()
	{
		return _graphComponent;
	}

	/**
	 * Fires a property change event for <code>graphComponent</code>.
	 * 
	 * @param graphComponent the graphComponent to set
	 */
	public void setGraphComponent(GraphComponent graphComponent)
	{
		GraphComponent oldValue = this._graphComponent;

		if (this._graphComponent != null)
		{
			this._graphComponent.getGraph().removeListener(_repaintHandler);
			this._graphComponent.getGraphControl().removeComponentListener(
					_componentHandler);
			this._graphComponent.getHorizontalScrollBar()
					.removeAdjustmentListener(_adjustmentHandler);
			this._graphComponent.getVerticalScrollBar()
					.removeAdjustmentListener(_adjustmentHandler);
		}

		this._graphComponent = graphComponent;

		if (this._graphComponent != null)
		{
			this._graphComponent.getGraph().addListener(Event.REPAINT,
					_repaintHandler);
			this._graphComponent.getGraphControl().addComponentListener(
					_componentHandler);
			this._graphComponent.getHorizontalScrollBar().addAdjustmentListener(
					_adjustmentHandler);
			this._graphComponent.getVerticalScrollBar().addAdjustmentListener(
					_adjustmentHandler);
		}

		if (updateScaleAndTranslate())
		{
			_repaintBuffer = true;
			repaint();
		}

		firePropertyChange("graphComponent", oldValue, graphComponent);
	}

	/**
	 * Checks if the triple buffer exists and creates a new one if
	 * it does not. Also compares the size of the buffer with the
	 * size of the graph and drops the buffer if it has a
	 * different size.
	 */
	public void checkTripleBuffer()
	{
		if (_tripleBuffer != null)
		{
			if (_tripleBuffer.getWidth() != getWidth()
					|| _tripleBuffer.getHeight() != getHeight())
			{
				// Resizes the buffer (destroys existing and creates new)
				destroyTripleBuffer();
			}
		}

		if (_tripleBuffer == null)
		{
			_createTripleBuffer(getWidth(), getHeight());
		}
	}

	/**
	 * Creates the tripleBufferGraphics and tripleBuffer for the given
	 * dimension and draws the complete graph onto the triplebuffer.
	 * 
	 * @param width
	 * @param height
	 */
	protected void _createTripleBuffer(int width, int height)
	{
		try
		{
			_tripleBuffer = Utils.createBufferedImage(width, height, null);
			_tripleBufferGraphics = _tripleBuffer.createGraphics();

			// Repaints the complete buffer
			repaintTripleBuffer(null);
		}
		catch (OutOfMemoryError error)
		{
			// ignore
		}
	}

	/**
	 * Destroys the tripleBuffer and tripleBufferGraphics objects.
	 */
	public void destroyTripleBuffer()
	{
		if (_tripleBuffer != null)
		{
			_tripleBuffer = null;
			_tripleBufferGraphics.dispose();
			_tripleBufferGraphics = null;
		}
	}

	/**
	 * Clears and repaints the triple buffer at the given rectangle or repaints
	 * the complete buffer if no rectangle is specified.
	 * 
	 * @param clip
	 */
	public void repaintTripleBuffer(Rectangle clip)
	{
		if (_tripleBuffered && _tripleBufferGraphics != null)
		{
			if (clip == null)
			{
				clip = new Rectangle(_tripleBuffer.getWidth(),
						_tripleBuffer.getHeight());
			}

			// Clears and repaints the dirty rectangle using the
			// graphics canvas of the graph component as a renderer
			Utils.clearRect(_tripleBufferGraphics, clip, null);
			_tripleBufferGraphics.setClip(clip);
			paintGraph(_tripleBufferGraphics);
			_tripleBufferGraphics.setClip(null);

			_repaintBuffer = false;
			_repaintClip = null;
		}
	}

	/**
	 * 
	 */
	public void updateFinder(boolean repaint)
	{
		Rectangle rect = _graphComponent.getViewport().getViewRect();

		int x = (int) Math.round(rect.x * _scale);
		int y = (int) Math.round(rect.y * _scale);
		int w = (int) Math.round((rect.x + rect.width) * _scale) - x;
		int h = (int) Math.round((rect.y + rect.height) * _scale) - y;

		updateFinderBounds(new Rectangle(x + _translate.x, y + _translate.y,
				w + 1, h + 1), repaint);
	}

	/**
	 * 
	 */
	public void updateFinderBounds(Rectangle bounds, boolean repaint)
	{
		if (bounds != null && !bounds.equals(_finderBounds))
		{
			Rectangle old = new Rectangle(_finderBounds);
			_finderBounds = bounds;

			// LATER: Fix repaint region to be smaller
			if (repaint)
			{
				old = old.union(_finderBounds);
				old.grow(3, 3);
				repaint(old);
			}
		}
	}

	/**
	 * 
	 */
	public void paintComponent(Graphics g)
	{
		super.paintComponent(g);
		_paintBackground(g);

		if (_graphComponent != null)
		{
			// Creates or destroys the triple buffer as needed
			if (_tripleBuffered)
			{
				checkTripleBuffer();
			}
			else if (_tripleBuffer != null)
			{
				destroyTripleBuffer();
			}

			// Updates the dirty region from the buffered graph image
			if (_tripleBuffer != null)
			{
				if (_repaintBuffer)
				{
					repaintTripleBuffer(null);
				}
				else if (_repaintClip != null)
				{
					_repaintClip.grow(1 / _scale);

					_repaintClip.setX(_repaintClip.getX() * _scale + _translate.x);
					_repaintClip.setY(_repaintClip.getY() * _scale + _translate.y);
					_repaintClip.setWidth(_repaintClip.getWidth() * _scale);
					_repaintClip.setHeight(_repaintClip.getHeight() * _scale);

					repaintTripleBuffer(_repaintClip.getRectangle());
				}

				Utils.drawImageClip(g, _tripleBuffer, this);
			}

			// Paints the graph directly onto the graphics
			else
			{
				paintGraph(g);
			}

			_paintForeground(g);
		}
	}

	/**
	 * Paints the background.
	 */
	protected void _paintBackground(Graphics g)
	{
		if (_graphComponent != null)
		{
			Graphics2D g2 = (Graphics2D) g;
			AffineTransform tx = g2.getTransform();

			try
			{
				// Draws the background of the outline if a graph exists 
				g.setColor(_graphComponent.getPageBackgroundColor());
				Utils.fillClippedRect(g, 0, 0, getWidth(), getHeight());

				g2.translate(_translate.x, _translate.y);
				g2.scale(_scale, _scale);

				// Draws the scaled page background
				if (!_graphComponent.isPageVisible())
				{
					Color bg = _graphComponent.getBackground();

					if (_graphComponent.getViewport().isOpaque())
					{
						bg = _graphComponent.getViewport().getBackground();
					}

					g.setColor(bg);
					Dimension size = _graphComponent.getGraphControl().getSize();

					// Paints the background of the drawing surface
					Utils.fillClippedRect(g, 0, 0, size.width, size.height);
					g.setColor(g.getColor().darker().darker());
					g.drawRect(0, 0, size.width, size.height);
				}
				else
				{
					// Paints the page background using the graphics scaling
					_graphComponent._paintBackgroundPage(g);
				}
			}
			finally
			{
				g2.setTransform(tx);
			}
		}
		else
		{
			// Draws the background of the outline if no graph exists 
			g.setColor(getBackground());
			Utils.fillClippedRect(g, 0, 0, getWidth(), getHeight());
		}
	}

	/**
	 * Paints the graph outline.
	 */
	public void paintGraph(Graphics g)
	{
		if (_graphComponent != null)
		{
			Graphics2D g2 = (Graphics2D) g;
			AffineTransform tx = g2.getTransform();

			try
			{
				Point tr = _graphComponent.getGraphControl().getTranslate();
				g2.translate(_translate.x + tr.getX() * _scale,
						_translate.y + tr.getY() * _scale);
				g2.scale(_scale, _scale);

				// Draws the scaled graph
				_graphComponent.getGraphControl().drawGraph(g2, _drawLabels);
			}
			finally
			{
				g2.setTransform(tx);
			}
		}
	}

	/**
	 * Paints the foreground. Foreground is dynamic and should never be made
	 * part of the triple buffer. It is painted on top of the buffer.
	 */
	protected void _paintForeground(Graphics g)
	{
		if (_graphComponent != null)
		{
			Graphics2D g2 = (Graphics2D) g;

			Stroke stroke = g2.getStroke();
			g.setColor(Color.BLUE);
			g2.setStroke(new BasicStroke(3));
			g.drawRect(_finderBounds.x, _finderBounds.y, _finderBounds.width,
					_finderBounds.height);

			if (_zoomHandleVisible)
			{
				g2.setStroke(stroke);
				g.setColor(DEFAULT_ZOOMHANDLE_FILL);
				g.fillRect(_finderBounds.x + _finderBounds.width - 6, _finderBounds.y
						+ _finderBounds.height - 6, 8, 8);
				g.setColor(Color.BLACK);
				g.drawRect(_finderBounds.x + _finderBounds.width - 6, _finderBounds.y
						+ _finderBounds.height - 6, 8, 8);
			}
		}
	}

	/**
	 * Returns true if the scale or translate has changed.
	 */
	public boolean updateScaleAndTranslate()
	{
		double newScale = 1;
		int dx = 0;
		int dy = 0;

		if (this._graphComponent != null)
		{
			Dimension graphSize = _graphComponent.getGraphControl().getSize();
			Dimension outlineSize = getSize();

			int gw = (int) graphSize.getWidth();
			int gh = (int) graphSize.getHeight();

			if (gw > 0 && gh > 0)
			{
				boolean magnifyPage = _graphComponent.isPageVisible()
						&& isFitPage()
						&& _graphComponent.getHorizontalScrollBar().isVisible()
						&& _graphComponent.getVerticalScrollBar().isVisible();
				double graphScale = _graphComponent.getGraph().getView()
						.getScale();
				Point2d trans = _graphComponent.getGraph().getView()
						.getTranslate();

				int w = (int) outlineSize.getWidth() - 2 * _outlineBorder;
				int h = (int) outlineSize.getHeight() - 2 * _outlineBorder;

				if (magnifyPage)
				{
					gw -= 2 * Math.round(trans.getX() * graphScale);
					gh -= 2 * Math.round(trans.getY() * graphScale);
				}

				newScale = Math.min((double) w / gw, (double) h / gh);

				dx += (int) Math
						.round((outlineSize.getWidth() - gw * newScale) / 2);
				dy += (int) Math
						.round((outlineSize.getHeight() - gh * newScale) / 2);

				if (magnifyPage)
				{
					dx -= Math.round(trans.getX() * newScale * graphScale);
					dy -= Math.round(trans.getY() * newScale * graphScale);
				}
			}
		}

		if (newScale != _scale || _translate.x != dx || _translate.y != dy)
		{
			_scale = newScale;
			_translate.setLocation(dx, dy);

			return true;
		}
		else
		{
			return false;
		}
	}

}
