package graph.examples.swing;

import java.awt.BorderLayout;

import javax.swing.ImageIcon;
import javax.swing.JToolBar;
import javax.swing.UIManager;

import graph.examples.swing.editor.BasicGraphEditor;
import graph.examples.swing.editor.EditorPalette;
import graph.examples.swing.editor.SchemaEditorMenuBar;
import graph.examples.swing.editor.SchemaEditorToolBar;
import graph.examples.swing.editor.SchemaGraphComponent;
import graph.model.Cell;
import graph.model.Geometry;
import graph.util.Rectangle;
import graph.view.CellState;
import graph.view.Graph;

public class SchemaEditor extends BasicGraphEditor
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -7007225006753337933L;

	/**
	 * 
	 */
	public SchemaEditor()
	{
		super("Graph for JFC/Swing", new SchemaGraphComponent(new Graph()
		{
			/**
			 * Allows expanding tables
			 */
			public boolean isCellFoldable(Object cell, boolean collapse)
			{
				return model.isVertex(cell);
			}
		})

		{
			/**
			 * 
			 */
			private static final long serialVersionUID = -1194463455177427496L;

			/**
			 * Disables folding icons.
			 */
			public ImageIcon getFoldingIcon(CellState state)
			{
				return null;
			}

		});

		// Creates a single shapes palette
		EditorPalette shapesPalette = insertPalette("Schema");
		graphOutline.setVisible(false);

		Cell tableTemplate = new Cell("New Table", new Geometry(0, 0,
				200, 280), null);
		tableTemplate.getGeometry().setAlternateBounds(
				new Rectangle(0, 0, 140, 25));
		tableTemplate.setVertex(true);

		shapesPalette
				.addTemplate(
						"Table",
						new ImageIcon(
								GraphEditor.class
										.getResource("/com/graph/examples/swing/images/rectangle.png")),
						tableTemplate);

		getGraphComponent().getGraph().setCellsResizable(false);
		getGraphComponent().setConnectable(false);
		getGraphComponent().getGraphHandler().setCloneEnabled(false);
		getGraphComponent().getGraphHandler().setImagePreview(false);

		// Prefers default JComponent event-handling before CellHandler handling
		//getGraphComponent().getGraphHandler().setKeepOnTop(false);

		Graph graph = getGraphComponent().getGraph();
		Object parent = graph.getDefaultParent();
		graph.getModel().beginUpdate();
		try
		{
			Cell v1 = (Cell) graph.insertVertex(parent, null, "Customers",
					20, 20, 200, 280);
			v1.getGeometry().setAlternateBounds(new Rectangle(0, 0, 140, 25));
			Cell v2 = (Cell) graph.insertVertex(parent, null, "Orders",
					280, 20, 200, 280);
			v2.getGeometry().setAlternateBounds(new Rectangle(0, 0, 140, 25));
		}
		finally
		{
			graph.getModel().endUpdate();
		}
	}

	/**
	 * 
	 */
	protected void installToolBar()
	{
		add(new SchemaEditorToolBar(this, JToolBar.HORIZONTAL),
				BorderLayout.NORTH);
	}

	/**
	 * 
	 * @param args
	 */
	public static void main(String[] args)
	{
		try
		{
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		}
		catch (Exception e1)
		{
			e1.printStackTrace();
		}

		SchemaEditor editor = new SchemaEditor();
		editor.createFrame(new SchemaEditorMenuBar(editor)).setVisible(true);
	}

}
