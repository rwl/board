package graph.swing;

//import graph.canvas.Graphics2DCanvas;
//import graph.canvas.ICanvas;
//import graph.model.IGraphModel;
//import graph.util.Constants;
//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.Rect;
//import graph.util.Resources;
//import graph.util.Utils;
//import graph.view.CellState;

//import java.awt.Dimension;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.RenderingHints;
//import java.awt.event.MouseAdapter;
//import java.awt.event.MouseEvent;

//import javax.swing.ImageIcon;
//import javax.swing.JComponent;

/**
 * 
 * @author gaudenz
 * 
 */
public class GraphControl extends JComponent
{

	/**
	 * 
	 */
	private final GraphComponent graphComponent;

	/**
	 * 
	 */
	private static final long serialVersionUID = -8916603170766739124L;

	/**
	 * Specifies a translation for painting. This should only be used during
	 * mouse drags and must be reset after any interactive repaints. Default
	 * is (0,0). This should not be null.
	 */
	protected Point translate = new Point(0, 0);

	/**
	 * @param graphComponent TODO
	 * 
	 */
	public GraphControl(GraphComponent graphComponent)
	{
		this.graphComponent = graphComponent;
		addMouseListener(new MouseAdapter()
		{
			public void mouseReleased(MouseEvent e)
			{
				if (translate.x != 0 || translate.y != 0)
				{
					translate = new Point(0, 0);
					repaint();
				}
			}
		});
	}

	/**
	 * Returns the translate.
	 */
	public Point getTranslate()
	{
		return translate;
	}

	/**
	 * Sets the translate.
	 */
	public void setTranslate(Point value)
	{
		translate = value;
	}

	/**
	 * 
	 */
	public GraphComponent getGraphContainer()
	{
		return this.graphComponent;
	}

	/**
	 * Overrides parent method to add extend flag for making the control
	 * larger during previews.
	 */
	public void scrollRectToVisible(Rectangle aRect, boolean extend)
	{
		super.scrollRectToVisible(aRect);

		if (extend)
		{
			extendComponent(aRect);
		}
	}

	/**
	 * Implements extension of the component in all directions. For
	 * extension below the origin (into negative space) the translate will
	 * temporaly be used and reset with the next mouse released event.
	 */
	protected void extendComponent(Rectangle rect)
	{
		int right = rect.x + rect.width;
		int bottom = rect.y + rect.height;

		Dimension d = new Dimension(getPreferredSize());
		Dimension sp = this.graphComponent._getScaledPreferredSizeForGraph();
		Rect min = this.graphComponent._graph.getMinimumGraphSize();
		double scale = this.graphComponent._graph.getView().getScale();
		boolean update = false;

		if (rect.x < 0)
		{
			translate.x = Math.max(translate.x, Math.max(0, -rect.x));
			d.width = sp.width;

			if (min != null)
			{
				d.width = (int) Math.max(d.width,
						Math.round(min.getWidth() * scale));
			}

			d.width += translate.x;
			update = true;
		}
		else if (right > getWidth())
		{
			d.width = Math.max(right, getWidth());
			update = true;
		}

		if (rect.y < 0)
		{
			translate.y = Math.max(translate.y, Math.max(0, -rect.y));
			d.height = sp.height;

			if (min != null)
			{
				d.height = (int) Math.max(d.height,
						Math.round(min.getHeight() * scale));
			}

			d.height += translate.y;
			update = true;
		}
		else if (bottom > getHeight())
		{
			d.height = Math.max(bottom, getHeight());
			update = true;
		}

		if (update)
		{
			setPreferredSize(d);
			setMinimumSize(d);
			revalidate();
		}
	}

	/**
	 * 
	 */
	public String getToolTipText(MouseEvent e)
	{
		String tip = this.graphComponent.getSelectionCellsHandler().getToolTipText(e);

		if (tip == null)
		{
			Object cell = this.graphComponent.getCellAt(e.getX(), e.getY());

			if (cell != null)
			{
				if (this.graphComponent.hitFoldingIcon(cell, e.getX(), e.getY()))
				{
					tip = Resources.get("collapse-expand");
				}
				else
				{
					tip = this.graphComponent._graph.getToolTipForCell(cell);
				}
			}
		}

		if (tip != null && tip.length() > 0)
		{
			return tip;
		}

		return super.getToolTipText(e);
	}

	/**
	 * Updates the preferred size for the given scale if the page size
	 * should be preferred or the page is visible.
	 */
	public void updatePreferredSize()
	{
		double scale = this.graphComponent._graph.getView().getScale();
		Dimension d = null;

		if (this.graphComponent._preferPageSize || this.graphComponent._pageVisible)
		{
			Dimension page = this.graphComponent._getPreferredSizeForPage();

			if (!this.graphComponent._preferPageSize)
			{
				page.width += 2 * this.graphComponent.getHorizontalPageBorder();
				page.height += 2 * this.graphComponent.getVerticalPageBorder();
			}

			d = new Dimension((int) (page.width * scale),
					(int) (page.height * scale));
		}
		else
		{
			d = this.graphComponent._getScaledPreferredSizeForGraph();
		}

		Rect min = this.graphComponent._graph.getMinimumGraphSize();

		if (min != null)
		{
			d.width = (int) Math.max(d.width,
					Math.round(min.getWidth() * scale));
			d.height = (int) Math.max(d.height,
					Math.round(min.getHeight() * scale));
		}

		if (!getPreferredSize().equals(d))
		{
			setPreferredSize(d);
			setMinimumSize(d);
			revalidate();
		}
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		g.translate(translate.x, translate.y);
		this.graphComponent._eventSource.fireEvent(new EventObj(Event.BEFORE_PAINT, "g",
				g));
		super.paint(g);
		this.graphComponent._eventSource
				.fireEvent(new EventObj(Event.AFTER_PAINT, "g", g));
		g.translate(-translate.x, -translate.y);
	}

	/**
	 * 
	 */
	public void paintComponent(Graphics g)
	{
		super.paintComponent(g);

		// Draws the background
		this.graphComponent._paintBackground(g);

		// Creates or destroys the triple buffer as needed
		if (this.graphComponent._tripleBuffered)
		{
			this.graphComponent.checkTripleBuffer();
		}
		else if (this.graphComponent._tripleBuffer != null)
		{
			this.graphComponent.destroyTripleBuffer();
		}

		// Paints the buffer in the canvas onto the dirty region
		if (this.graphComponent._tripleBuffer != null)
		{
			Utils.drawImageClip(g, this.graphComponent._tripleBuffer, this);
		}

		// Paints the graph directly onto the graphics
		else
		{
			Graphics2D g2 = (Graphics2D) g;
			RenderingHints tmp = g2.getRenderingHints();

			// Sets the graphics in the canvas
			try
			{
				Utils.setAntiAlias(g2, this.graphComponent._antiAlias, this.graphComponent._textAntiAlias);
				drawGraph(g2, true);
			}
			finally
			{
				// Restores the graphics state
				g2.setRenderingHints(tmp);
			}
		}

		this.graphComponent._eventSource.fireEvent(new EventObj(Event.PAINT, "g", g));
	}

	/**
	 * 
	 */
	public void drawGraph(Graphics2D g, boolean drawLabels)
	{
		Graphics2D previousGraphics = this.graphComponent._canvas.getGraphics();
		boolean previousDrawLabels = this.graphComponent._canvas.isDrawLabels();
		Point previousTranslate = this.graphComponent._canvas.getTranslate();
		double previousScale = this.graphComponent._canvas.getScale();

		try
		{
			this.graphComponent._canvas.setScale(this.graphComponent._graph.getView().getScale());
			this.graphComponent._canvas.setDrawLabels(drawLabels);
			this.graphComponent._canvas.setTranslate(0, 0);
			this.graphComponent._canvas.setGraphics(g);

			// Draws the graph using the graphics canvas
			drawFromRootCell();
		}
		finally
		{
			this.graphComponent._canvas.setScale(previousScale);
			this.graphComponent._canvas.setTranslate(previousTranslate.x, previousTranslate.y);
			this.graphComponent._canvas.setDrawLabels(previousDrawLabels);
			this.graphComponent._canvas.setGraphics(previousGraphics);
		}
	}

	/**
	 * Hook to draw the root cell into the canvas.
	 */
	protected void drawFromRootCell()
	{
		drawCell(this.graphComponent._canvas, this.graphComponent._graph.getModel().getRoot());
	}

	/**
	 * 
	 */
	protected boolean hitClip(Graphics2DCanvas canvas, CellState state)
	{
		Rectangle rect = getExtendedCellBounds(state);

		return (rect == null || canvas.getGraphics().hitClip(rect.x,
				rect.y, rect.width, rect.height));
	}

	/**
	 * @param state the cached state of the cell whose extended bounds are to be calculated
	 * @return the bounds of the cell, including the label and shadow and allowing for rotation
	 */
	protected Rectangle getExtendedCellBounds(CellState state)
	{
		Rectangle rect = null;

		// Takes rotation into account
		double rotation = Utils.getDouble(state.getStyle(),
				Constants.STYLE_ROTATION);
		Rect tmp = Utils.getBoundingBox(new Rect(state),
				rotation);

		// Adds scaled stroke width
		int border = (int) Math
				.ceil(Utils.getDouble(state.getStyle(),
						Constants.STYLE_STROKEWIDTH)
						* this.graphComponent._graph.getView().getScale()) + 1;
		tmp.grow(border);

		if (Utils.isTrue(state.getStyle(), Constants.STYLE_SHADOW))
		{
			tmp.setWidth(tmp.getWidth() + Constants.SHADOW_OFFSETX);
			tmp.setHeight(tmp.getHeight() + Constants.SHADOW_OFFSETX);
		}

		// Adds the bounds of the label
		if (state.getLabelBounds() != null)
		{
			tmp.add(state.getLabelBounds());
		}

		rect = tmp.getRectangle();
		return rect;
	}

	/**
	 * Draws the given cell onto the specified canvas. This is a modified
	 * version of Graph.drawCell which paints the label only if the
	 * corresponding cell is not being edited and invokes the cellDrawn hook
	 * after all descendants have been painted.
	 * 
	 * @param canvas
	 *            Canvas onto which the cell should be drawn.
	 * @param cell
	 *            Cell that should be drawn onto the canvas.
	 */
	public void drawCell(ICanvas canvas, Object cell)
	{
		CellState state = this.graphComponent._graph.getView().getState(cell);

		if (state != null
				&& isCellDisplayable(state.getCell())
				&& (!(canvas instanceof Graphics2DCanvas) || hitClip(
						(Graphics2DCanvas) canvas, state)))
		{
			this.graphComponent._graph.drawState(canvas, state,
					cell != this.graphComponent._cellEditor.getEditingCell());
		}

		// Handles special ordering for edges (all in foreground
		// or background) or draws all children in order
		boolean edgesFirst = this.graphComponent._graph.isKeepEdgesInBackground();
		boolean edgesLast = this.graphComponent._graph.isKeepEdgesInForeground();

		if (edgesFirst)
		{
			drawChildren(cell, true, false);
		}

		drawChildren(cell, !edgesFirst && !edgesLast, true);

		if (edgesLast)
		{
			drawChildren(cell, true, false);
		}

		if (state != null)
		{
			cellDrawn(canvas, state);
		}
	}

	/**
	 * Draws the child edges and/or all other children in the given cell
	 * depending on the boolean arguments.
	 */
	protected void drawChildren(Object cell, boolean edges, boolean others)
	{
		IGraphModel model = this.graphComponent._graph.getModel();
		int childCount = model.getChildCount(cell);

		for (int i = 0; i < childCount; i++)
		{
			Object child = model.getChildAt(cell, i);
			boolean isEdge = model.isEdge(child);

			if ((others && !isEdge) || (edges && isEdge))
			{
				drawCell(this.graphComponent._canvas, model.getChildAt(cell, i));
			}
		}
	}

	/**
	 * 
	 */
	protected void cellDrawn(ICanvas canvas, CellState state)
	{
		if (this.graphComponent.isFoldingEnabled() && canvas instanceof Graphics2DCanvas)
		{
			IGraphModel model = this.graphComponent._graph.getModel();
			Graphics2DCanvas g2c = (Graphics2DCanvas) canvas;
			Graphics2D g2 = g2c.getGraphics();

			// Draws the collapse/expand icons
			boolean isEdge = model.isEdge(state.getCell());

			if (state.getCell() != this.graphComponent._graph.getCurrentRoot()
					&& (model.isVertex(state.getCell()) || isEdge))
			{
				ImageIcon icon = this.graphComponent.getFoldingIcon(state);

				if (icon != null)
				{
					Rectangle bounds = this.graphComponent.getFoldingIconBounds(state, icon);
					g2.drawImage(icon.getImage(), bounds.x, bounds.y,
							bounds.width, bounds.height, this);
				}
			}
		}
	}

	/**
	 * Returns true if the given cell is not the current root or the root in
	 * the model. This can be overridden to not render certain cells in the
	 * graph display.
	 */
	protected boolean isCellDisplayable(Object cell)
	{
		return cell != this.graphComponent._graph.getView().getCurrentRoot()
				&& cell != this.graphComponent._graph.getModel().getRoot();
	}

}