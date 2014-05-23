/**
 * $Id: GraphTransferHandler.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2008, Gaudenz Alder
 */
package graph.swing.handler;

import graph.swing.GraphComponent;
import graph.swing.util.GraphTransferable;
import graph.util.CellRenderer;
import graph.util.Point2d;
import graph.util.Rect;
import graph.view.Graph;

import java.awt.Color;
import java.awt.Image;
import java.awt.Point;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.Transferable;

import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.TransferHandler;

/**
 * 
 */
public class GraphTransferHandler extends TransferHandler
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -6443287704811197675L;

	/**
	 * Boolean that specifies if an image of the cells should be created for
	 * each transferable. Default is true.
	 */
	public static boolean DEFAULT_TRANSFER_IMAGE_ENABLED = true;

	/**
	 * Specifies the background color of the transfer image. If no
	 * color is given here then the background color of the enclosing
	 * graph component is used. Default is Color.WHITE.
	 */
	public static Color DEFAULT_BACKGROUNDCOLOR = Color.WHITE;

	/**
	 * Reference to the original cells for removal after a move.
	 */
	protected Object[] originalCells;

	/**
	 * Reference to the last imported cell array.
	 */
	protected Transferable lastImported;

	/**
	 * Sets the value for the initialImportCount. Default is 1. Updated in
	 * exportDone to contain 0 after a cut and 1 after a copy.
	 */
	protected int initialImportCount = 1;

	/**
	 * Counter for the last imported cell array.
	 */
	protected int importCount = 0;

	/**
	 * Specifies if a transfer image should be created for the transferable.
	 * Default is DEFAULT_TRANSFER_IMAGE.
	 */
	protected boolean transferImageEnabled = DEFAULT_TRANSFER_IMAGE_ENABLED;

	/**
	 * Specifies the background color for the transfer image. Default is
	 * DEFAULT_BACKGROUNDCOLOR.
	 */
	protected Color transferImageBackground = DEFAULT_BACKGROUNDCOLOR;

	/**
	 * 
	 */
	protected Point location;

	/**
	 * 
	 */
	protected Point offset;

	/**
	 * 
	 */
	public int getImportCount()
	{
		return importCount;
	}

	/**
	 * 
	 */
	public void setImportCount(int value)
	{
		importCount = value;
	}

	/**
	 * 
	 */
	public void setTransferImageEnabled(boolean transferImageEnabled)
	{
		this.transferImageEnabled = transferImageEnabled;
	}

	/**
	 * 
	 */
	public boolean isTransferImageEnabled()
	{
		return this.transferImageEnabled;
	}

	/**
	 * 
	 */
	public void setTransferImageBackground(Color transferImageBackground)
	{
		this.transferImageBackground = transferImageBackground;
	}

	/**
	 * 
	 */
	public Color getTransferImageBackground()
	{
		return this.transferImageBackground;
	}

	/**
	 * Returns true if the DnD operation started from this handler.
	 */
	public boolean isLocalDrag()
	{
		return originalCells != null;
	}

	/**
	 * 
	 */
	public void setLocation(Point value)
	{
		location = value;
	}

	/**
	 * 
	 */
	public void setOffset(Point value)
	{
		offset = value;
	}

	/**
	 * 
	 */
	public boolean canImport(JComponent comp, DataFlavor[] flavors)
	{
		for (int i = 0; i < flavors.length; i++)
		{
			if (flavors[i] != null
					&& flavors[i].equals(GraphTransferable.dataFlavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * (non-Javadoc)
	 * 
	 * @see javax.swing.TransferHandler#createTransferable(javax.swing.JComponent)
	 */
	public Transferable createTransferable(JComponent c)
	{
		if (c instanceof GraphComponent)
		{
			GraphComponent graphComponent = (GraphComponent) c;
			Graph graph = graphComponent.getGraph();

			if (!graph.isSelectionEmpty())
			{
				originalCells = graphComponent.getExportableCells(graph
						.getSelectionCells());

				if (originalCells.length > 0)
				{
					ImageIcon icon = (transferImageEnabled) ? createTransferableImage(
							graphComponent, originalCells) : null;

					return createGraphTransferable(graphComponent,
							originalCells, icon);
				}
			}
		}

		return null;
	}

	/**
	 * 
	 */
	public GraphTransferable createGraphTransferable(
			GraphComponent graphComponent, Object[] cells, ImageIcon icon)
	{
		Graph graph = graphComponent.getGraph();
		Point2d tr = graph.getView().getTranslate();
		double scale = graph.getView().getScale();

		Rect bounds = graph.getPaintBounds(cells);

		// Removes the scale and translation from the bounds
		bounds.setX(bounds.getX() / scale - tr.getX());
		bounds.setY(bounds.getY() / scale - tr.getY());
		bounds.setWidth(bounds.getWidth() / scale);
		bounds.setHeight(bounds.getHeight() / scale);

		return createGraphTransferable(graphComponent, cells, bounds, icon);
	}

	/**
	 * 
	 */
	public GraphTransferable createGraphTransferable(
			GraphComponent graphComponent, Object[] cells,
			Rect bounds, ImageIcon icon)
	{
		return new GraphTransferable(graphComponent.getGraph().cloneCells(
				cells), bounds, icon);
	}

	/**
	 * 
	 */
	public ImageIcon createTransferableImage(GraphComponent graphComponent,
			Object[] cells)
	{
		ImageIcon icon = null;
		Color bg = (transferImageBackground != null) ? transferImageBackground
				: graphComponent.getBackground();
		Image img = CellRenderer.createBufferedImage(
				graphComponent.getGraph(), cells, 1, bg,
				graphComponent.isAntiAlias(), null, graphComponent.getCanvas());

		if (img != null)
		{
			icon = new ImageIcon(img);
		}

		return icon;
	}

	/**
	 * 
	 */
	public void exportDone(JComponent c, Transferable data, int action)
	{
		initialImportCount = 1;
		
		if (c instanceof GraphComponent
				&& data instanceof GraphTransferable)
		{
			// Requires that the graph handler resets the location to null if the drag leaves the
			// component. This is the condition to identify a cross-component move.
			boolean isLocalDrop = location != null;

			if (action == TransferHandler.MOVE && !isLocalDrop)
			{
				removeCells((GraphComponent) c, originalCells);
				initialImportCount = 0;
			}
		}

		originalCells = null;
		location = null;
		offset = null;
	}

	/**
	 * 
	 */
	protected void removeCells(GraphComponent graphComponent, Object[] cells)
	{
		graphComponent.getGraph().removeCells(cells);
	}

	/**
	 * 
	 */
	public int getSourceActions(JComponent c)
	{
		return COPY_OR_MOVE;
	}

	/**
	 * Checks if the GraphTransferable data flavour is supported and calls
	 * importGraphTransferable if possible.
	 */
	public boolean importData(JComponent c, Transferable t)
	{
		boolean result = false;

		if (isLocalDrag())
		{
			// Enables visual feedback on the Mac
			result = true;
		}
		else
		{
			try
			{
				updateImportCount(t);

				if (c instanceof GraphComponent)
				{
					GraphComponent graphComponent = (GraphComponent) c;

					if (graphComponent.isEnabled()
							&& t.isDataFlavorSupported(GraphTransferable.dataFlavor))
					{
						GraphTransferable gt = (GraphTransferable) t
								.getTransferData(GraphTransferable.dataFlavor);

						if (gt.getCells() != null)
						{
							result = importGraphTransferable(graphComponent, gt);
						}

					}
				}
			}
			catch (Exception ex)
			{
				ex.printStackTrace();
			}
		}

		return result;
	}

	/**
	 * Counts the number of times that the given transferable has been imported.
	 */
	protected void updateImportCount(Transferable t)
	{
		if (lastImported != t)
		{
			importCount = initialImportCount;
		}
		else
		{
			importCount++;
		}

		lastImported = t;
	}

	/**
	 * Returns true if the cells have been imported using importCells.
	 */
	protected boolean importGraphTransferable(GraphComponent graphComponent,
			GraphTransferable gt)
	{
		boolean result = false;

		try
		{
			Graph graph = graphComponent.getGraph();
			double scale = graph.getView().getScale();
			Rect bounds = gt.getBounds();
			double dx = 0, dy = 0;

			// Computes the offset for the placement of the imported cells
			if (location != null && bounds != null)
			{
				Point2d translate = graph.getView().getTranslate();

				dx = location.getX() - (bounds.getX() + translate.getX())
						* scale;
				dy = location.getY() - (bounds.getY() + translate.getY())
						* scale;

				// Keeps the cells aligned to the grid
				dx = graph.snap(dx / scale);
				dy = graph.snap(dy / scale);
			}
			else
			{
				int gs = graph.getGridSize();

				dx = importCount * gs;
				dy = importCount * gs;
			}

			if (offset != null)
			{
				dx += offset.x;
				dy += offset.y;
			}

			importCells(graphComponent, gt, dx, dy);
			location = null;
			offset = null;
			result = true;

			// Requests the focus after an import
			graphComponent.requestFocus();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}

		return result;
	}

	/**
	 * Returns the drop target for the given transferable and location.
	 */
	protected Object getDropTarget(GraphComponent graphComponent,
			GraphTransferable gt)
	{
		Object[] cells = gt.getCells();
		Object target = null;

		// Finds the target cell at the given location and checks if the
		// target is not already the parent of the first imported cell
		if (location != null)
		{
			target = graphComponent.getGraph().getDropTarget(cells, location,
					graphComponent.getCellAt(location.x, location.y));

			if (cells.length > 0
					&& graphComponent.getGraph().getModel().getParent(cells[0]) == target)
			{
				target = null;
			}
		}

		return target;
	}

	/**
	 * Gets a drop target using getDropTarget and imports the cells using
	 * Graph.splitEdge or GraphComponent.importCells depending on the
	 * drop target and the return values of Graph.isSplitEnabled and
	 * Graph.isSplitTarget. Selects and returns the cells that have been
	 * imported.
	 */
	protected Object[] importCells(GraphComponent graphComponent,
			GraphTransferable gt, double dx, double dy)
	{
		Object target = getDropTarget(graphComponent, gt);
		Graph graph = graphComponent.getGraph();
		Object[] cells = gt.getCells();

		cells = graphComponent.getImportableCells(cells);

		if (graph.isSplitEnabled() && graph.isSplitTarget(target, cells))
		{
			graph.splitEdge(target, cells, dx, dy);
		}
		else
		{
			cells = graphComponent.importCells(cells, dx, dy, target, location);
			graph.setSelectionCells(cells);
		}

		return cells;
	}

}
