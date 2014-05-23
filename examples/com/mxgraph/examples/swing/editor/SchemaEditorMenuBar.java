package graph.examples.swing.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.AbstractAction;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.SwingUtilities;
import javax.swing.TransferHandler;
import javax.swing.UIManager;

import graph.examples.swing.editor.EditorActions.BackgroundAction;
import graph.examples.swing.editor.EditorActions.BackgroundImageAction;
import graph.examples.swing.editor.EditorActions.ExitAction;
import graph.examples.swing.editor.EditorActions.GridColorAction;
import graph.examples.swing.editor.EditorActions.GridStyleAction;
import graph.examples.swing.editor.EditorActions.HistoryAction;
import graph.examples.swing.editor.EditorActions.NewAction;
import graph.examples.swing.editor.EditorActions.OpenAction;
import graph.examples.swing.editor.EditorActions.PageBackgroundAction;
import graph.examples.swing.editor.EditorActions.PageSetupAction;
import graph.examples.swing.editor.EditorActions.PrintAction;
import graph.examples.swing.editor.EditorActions.PromptPropertyAction;
import graph.examples.swing.editor.EditorActions.SaveAction;
import graph.examples.swing.editor.EditorActions.ScaleAction;
import graph.examples.swing.editor.EditorActions.SelectShortestPathAction;
import graph.examples.swing.editor.EditorActions.SelectSpanningTreeAction;
import graph.examples.swing.editor.EditorActions.StylesheetAction;
import graph.examples.swing.editor.EditorActions.ToggleDirtyAction;
import graph.examples.swing.editor.EditorActions.ToggleGridItem;
import graph.examples.swing.editor.EditorActions.ToggleOutlineItem;
import graph.examples.swing.editor.EditorActions.TogglePropertyItem;
import graph.examples.swing.editor.EditorActions.ToggleRulersItem;
import graph.examples.swing.editor.EditorActions.WarningAction;
import graph.examples.swing.editor.EditorActions.ZoomPolicyAction;
import graph.swing.GraphComponent;
import graph.swing.util.GraphActions;
import graph.util.Point;
import graph.util.Resources;
import graph.view.Graph;

public class SchemaEditorMenuBar extends JMenuBar
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 6776304509649205465L;

	@SuppressWarnings("serial")
	public SchemaEditorMenuBar(final BasicGraphEditor editor)
	{
		final GraphComponent graphComponent = editor.getGraphComponent();
		final Graph graph = graphComponent.getGraph();
		JMenu menu = null;
		JMenu submenu = null;

		// Creates the file menu
		menu = add(new JMenu(Resources.get("file")));

		menu.add(editor.bind(Resources.get("new"), new NewAction(),
				"/com/graph/examples/swing/images/new.gif"));
		menu.add(editor.bind(Resources.get("openFile"), new OpenAction(),
				"/com/graph/examples/swing/images/open.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("save"), new SaveAction(false),
				"/com/graph/examples/swing/images/save.gif"));
		menu.add(editor.bind(Resources.get("saveAs"), new SaveAction(true),
				"/com/graph/examples/swing/images/saveas.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("pageSetup"),
				new PageSetupAction(),
				"/com/graph/examples/swing/images/pagesetup.gif"));
		menu.add(editor.bind(Resources.get("print"), new PrintAction(),
				"/com/graph/examples/swing/images/print.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("exit"), new ExitAction()));

		// Creates the edit menu
		menu = add(new JMenu(Resources.get("edit")));

		menu.add(editor.bind(Resources.get("undo"), new HistoryAction(true),
				"/com/graph/examples/swing/images/undo.gif"));
		menu.add(editor.bind(Resources.get("redo"), new HistoryAction(false),
				"/com/graph/examples/swing/images/redo.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("cut"), TransferHandler
				.getCutAction(), "/com/graph/examples/swing/images/cut.gif"));
		menu.add(editor
				.bind(Resources.get("copy"), TransferHandler.getCopyAction(),
						"/com/graph/examples/swing/images/copy.gif"));
		menu.add(editor.bind(Resources.get("paste"), TransferHandler
				.getPasteAction(),
				"/com/graph/examples/swing/images/paste.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("delete"), GraphActions
				.getDeleteAction(),
				"/com/graph/examples/swing/images/delete.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("selectAll"), GraphActions
				.getSelectAllAction()));
		menu.add(editor.bind(Resources.get("selectNone"), GraphActions
				.getSelectNoneAction()));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("warning"), new WarningAction()));
		menu.add(editor.bind(Resources.get("edit"), GraphActions
				.getEditAction()));

		// Creates the view menu
		menu = add(new JMenu(Resources.get("view")));

		JMenuItem item = menu.add(new TogglePropertyItem(graphComponent,
				Resources.get("pageLayout"), "PageVisible", true,
				new ActionListener()
				{
					/**
					 * 
					 */
					public void actionPerformed(ActionEvent e)
					{
						if (graphComponent.isPageVisible()
								&& graphComponent.isCenterPage())
						{
							graphComponent.zoomAndCenter();
						}
					}
				}));

		item.addActionListener(new ActionListener()
		{
			/*
			 * (non-Javadoc)
			 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
			 */
			public void actionPerformed(ActionEvent e)
			{
				if (e.getSource() instanceof TogglePropertyItem)
				{
					final GraphComponent graphComponent = editor
							.getGraphComponent();
					TogglePropertyItem toggleItem = (TogglePropertyItem) e
							.getSource();

					if (toggleItem.isSelected())
					{
						// Scrolls the view to the center
						SwingUtilities.invokeLater(new Runnable()
						{
							/*
							 * (non-Javadoc)
							 * @see java.lang.Runnable#run()
							 */
							public void run()
							{
								graphComponent.scrollToCenter(true);
								graphComponent.scrollToCenter(false);
							}
						});
					}
					else
					{
						// Resets the translation of the view
						Point tr = graphComponent.getGraph().getView()
								.getTranslate();

						if (tr.getX() != 0 || tr.getY() != 0)
						{
							graphComponent.getGraph().getView().setTranslate(
									new Point());
						}
					}
				}
			}
		});

		menu.add(new TogglePropertyItem(graphComponent, Resources
				.get("antialias"), "AntiAlias", true));

		menu.addSeparator();

		menu.add(new ToggleGridItem(editor, Resources.get("grid")));
		menu.add(new ToggleRulersItem(editor, Resources.get("rulers")));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("zoom")));

		submenu.add(editor.bind("400%", new ScaleAction(4)));
		submenu.add(editor.bind("200%", new ScaleAction(2)));
		submenu.add(editor.bind("150%", new ScaleAction(1.5)));
		submenu.add(editor.bind("100%", new ScaleAction(1)));
		submenu.add(editor.bind("75%", new ScaleAction(0.75)));
		submenu.add(editor.bind("50%", new ScaleAction(0.5)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("custom"), new ScaleAction(0)));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("zoomIn"), GraphActions
				.getZoomInAction()));
		menu.add(editor.bind(Resources.get("zoomOut"), GraphActions
				.getZoomOutAction()));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("page"), new ZoomPolicyAction(
				GraphComponent.ZOOM_POLICY_PAGE)));
		menu.add(editor.bind(Resources.get("width"), new ZoomPolicyAction(
				GraphComponent.ZOOM_POLICY_WIDTH)));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("actualSize"), GraphActions
				.getZoomActualAction()));

		// Creates the diagram menu
		menu = add(new JMenu(Resources.get("diagram")));

		menu.add(new ToggleOutlineItem(editor, Resources.get("outline")));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("background")));

		submenu.add(editor.bind(Resources.get("backgroundColor"),
				new BackgroundAction()));
		submenu.add(editor.bind(Resources.get("backgroundImage"),
				new BackgroundImageAction()));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("pageBackground"),
				new PageBackgroundAction()));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("grid")));

		submenu.add(editor.bind(Resources.get("gridSize"),
				new PromptPropertyAction(graph, "Grid Size", "GridSize")));
		submenu.add(editor.bind(Resources.get("gridColor"),
				new GridColorAction()));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("dashed"), new GridStyleAction(
				GraphComponent.GRID_STYLE_DASHED)));
		submenu.add(editor.bind(Resources.get("dot"), new GridStyleAction(
				GraphComponent.GRID_STYLE_DOT)));
		submenu.add(editor.bind(Resources.get("line"), new GridStyleAction(
				GraphComponent.GRID_STYLE_LINE)));
		submenu.add(editor.bind(Resources.get("cross"), new GridStyleAction(
				GraphComponent.GRID_STYLE_CROSS)));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("layout")));

		submenu.add(editor.graphLayout("verticalHierarchical", true));
		submenu.add(editor.graphLayout("horizontalHierarchical", true));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("verticalPartition", false));
		submenu.add(editor.graphLayout("horizontalPartition", false));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("verticalStack", false));
		submenu.add(editor.graphLayout("horizontalStack", false));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("verticalTree", true));
		submenu.add(editor.graphLayout("horizontalTree", true));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("parallelEdges", false));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("organicLayout", true));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("selection")));

		submenu.add(editor.bind(Resources.get("selectPath"),
				new SelectShortestPathAction(false)));
		submenu.add(editor.bind(Resources.get("selectDirectedPath"),
				new SelectShortestPathAction(true)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("selectTree"),
				new SelectSpanningTreeAction(false)));
		submenu.add(editor.bind(Resources.get("selectDirectedTree"),
				new SelectSpanningTreeAction(true)));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("stylesheet")));

		submenu
				.add(editor
						.bind(
								Resources.get("basicStyle"),
								new StylesheetAction(
										"/com/graph/examples/swing/resources/basic-style.xml")));
		submenu
				.add(editor
						.bind(
								Resources.get("defaultStyle"),
								new StylesheetAction(
										"/com/graph/examples/swing/resources/default-style.xml")));

		// Creates the options menu
		menu = add(new JMenu(Resources.get("options")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("display")));
		submenu.add(new TogglePropertyItem(graphComponent, Resources
				.get("buffering"), "TripleBuffered", true));
		submenu.add(editor.bind(Resources.get("dirty"),
				new ToggleDirtyAction()));

		submenu.addSeparator();

		item = submenu.add(new TogglePropertyItem(graphComponent, Resources
				.get("centerPage"), "CenterPage", true, new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				if (graphComponent.isPageVisible()
						&& graphComponent.isCenterPage())
				{
					graphComponent.zoomAndCenter();
				}
			}
		}));

		submenu.add(new TogglePropertyItem(graphComponent, Resources
				.get("centerZoom"), "CenterZoom", true));
		submenu.add(new TogglePropertyItem(graphComponent, Resources
				.get("zoomToSelection"), "KeepSelectionVisibleOnZoom", true));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graphComponent, Resources
				.get("preferPagesize"), "PreferPageSize", true));

		// This feature is not yet implemented
		//submenu.add(new TogglePropertyItem(graphComponent, Resources
		//		.get("pageBreaks"), "PageBreaksVisible", true));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("tolerance"),
				new PromptPropertyAction(graph, "Tolerance")));

		// Creates the window menu
		menu = add(new JMenu(Resources.get("window")));

		UIManager.LookAndFeelInfo[] lafs = UIManager.getInstalledLookAndFeels();

		for (int i = 0; i < lafs.length; i++)
		{
			final String clazz = lafs[i].getClassName();
			menu.add(new AbstractAction(lafs[i].getName())
			{
				public void actionPerformed(ActionEvent e)
				{
					editor.setLookAndFeel(clazz);
				}
			});
		}

		// Creates the help menu
		menu = add(new JMenu(Resources.get("help")));

		item = menu.add(new JMenuItem(Resources.get("aboutGraphEditor")));
		item.addActionListener(new ActionListener()
		{
			/*
			 * (non-Javadoc)
			 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
			 */
			public void actionPerformed(ActionEvent e)
			{
				editor.about();
			}
		});
	}

}
