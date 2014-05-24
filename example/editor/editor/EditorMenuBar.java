package graph.examples.swing.editor;

import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

import javax.swing.AbstractAction;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.SwingUtilities;
import javax.swing.TransferHandler;
import javax.swing.UIManager;

import graph.analysis.StructuralException;
import graph.analysis.GraphProperties.GraphType;
import graph.analysis.AnalysisGraph;
import graph.analysis.GraphProperties;
import graph.analysis.GraphStructure;
import graph.analysis.Traversal;
import graph.costfunction.CostFunction;
import graph.examples.swing.editor.EditorActions.AlignCellsAction;
import graph.examples.swing.editor.EditorActions.AutosizeAction;
import graph.examples.swing.editor.EditorActions.BackgroundAction;
import graph.examples.swing.editor.EditorActions.BackgroundImageAction;
import graph.examples.swing.editor.EditorActions.ColorAction;
import graph.examples.swing.editor.EditorActions.ExitAction;
import graph.examples.swing.editor.EditorActions.GridColorAction;
import graph.examples.swing.editor.EditorActions.GridStyleAction;
import graph.examples.swing.editor.EditorActions.HistoryAction;
import graph.examples.swing.editor.EditorActions.ImportAction;
import graph.examples.swing.editor.EditorActions.KeyValueAction;
import graph.examples.swing.editor.EditorActions.NewAction;
import graph.examples.swing.editor.EditorActions.OpenAction;
import graph.examples.swing.editor.EditorActions.PageBackgroundAction;
import graph.examples.swing.editor.EditorActions.PageSetupAction;
import graph.examples.swing.editor.EditorActions.PrintAction;
import graph.examples.swing.editor.EditorActions.PromptPropertyAction;
import graph.examples.swing.editor.EditorActions.PromptValueAction;
import graph.examples.swing.editor.EditorActions.SaveAction;
import graph.examples.swing.editor.EditorActions.ScaleAction;
import graph.examples.swing.editor.EditorActions.SelectShortestPathAction;
import graph.examples.swing.editor.EditorActions.SelectSpanningTreeAction;
import graph.examples.swing.editor.EditorActions.SetLabelPositionAction;
import graph.examples.swing.editor.EditorActions.SetStyleAction;
import graph.examples.swing.editor.EditorActions.StyleAction;
import graph.examples.swing.editor.EditorActions.StylesheetAction;
import graph.examples.swing.editor.EditorActions.ToggleAction;
import graph.examples.swing.editor.EditorActions.ToggleConnectModeAction;
import graph.examples.swing.editor.EditorActions.ToggleCreateTargetItem;
import graph.examples.swing.editor.EditorActions.ToggleDirtyAction;
import graph.examples.swing.editor.EditorActions.ToggleGridItem;
import graph.examples.swing.editor.EditorActions.ToggleOutlineItem;
import graph.examples.swing.editor.EditorActions.TogglePropertyItem;
import graph.examples.swing.editor.EditorActions.ToggleRulersItem;
import graph.examples.swing.editor.EditorActions.WarningAction;
import graph.examples.swing.editor.EditorActions.ZoomPolicyAction;
import graph.model.IGraphModel;
import graph.swing.GraphComponent;
import graph.swing.util.GraphActions;
import graph.util.Constants;
import graph.util.Point;
import graph.util.Resources;
import graph.view.Graph;
import graph.view.GraphView;

public class EditorMenuBar extends JMenuBar
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 4060203894740766714L;

	public enum AnalyzeType
	{
		IS_CONNECTED, IS_SIMPLE, IS_CYCLIC_DIRECTED, IS_CYCLIC_UNDIRECTED, COMPLEMENTARY, REGULARITY, COMPONENTS, MAKE_CONNECTED, MAKE_SIMPLE, IS_TREE, ONE_SPANNING_TREE, IS_DIRECTED, GET_CUT_VERTEXES, GET_CUT_EDGES, GET_SOURCES, GET_SINKS, PLANARITY, IS_BICONNECTED, GET_BICONNECTED, SPANNING_TREE, FLOYD_ROY_WARSHALL
	}

	public EditorMenuBar(final BasicGraphEditor editor)
	{
		final GraphComponent graphComponent = editor.getGraphComponent();
		final Graph graph = graphComponent.getGraph();
		AnalysisGraph aGraph = new AnalysisGraph();

		JMenu menu = null;
		JMenu submenu = null;

		// Creates the file menu
		menu = add(new JMenu(Resources.get("file")));

		menu.add(editor.bind(Resources.get("new"), new NewAction(), "/com/graph/examples/swing/images/new.gif"));
		menu.add(editor.bind(Resources.get("openFile"), new OpenAction(), "/com/graph/examples/swing/images/open.gif"));
		menu.add(editor.bind(Resources.get("importStencil"), new ImportAction(), "/com/graph/examples/swing/images/open.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("save"), new SaveAction(false), "/com/graph/examples/swing/images/save.gif"));
		menu.add(editor.bind(Resources.get("saveAs"), new SaveAction(true), "/com/graph/examples/swing/images/saveas.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("pageSetup"), new PageSetupAction(), "/com/graph/examples/swing/images/pagesetup.gif"));
		menu.add(editor.bind(Resources.get("print"), new PrintAction(), "/com/graph/examples/swing/images/print.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("exit"), new ExitAction()));

		// Creates the edit menu
		menu = add(new JMenu(Resources.get("edit")));

		menu.add(editor.bind(Resources.get("undo"), new HistoryAction(true), "/com/graph/examples/swing/images/undo.gif"));
		menu.add(editor.bind(Resources.get("redo"), new HistoryAction(false), "/com/graph/examples/swing/images/redo.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("cut"), TransferHandler.getCutAction(), "/com/graph/examples/swing/images/cut.gif"));
		menu.add(editor.bind(Resources.get("copy"), TransferHandler.getCopyAction(), "/com/graph/examples/swing/images/copy.gif"));
		menu.add(editor.bind(Resources.get("paste"), TransferHandler.getPasteAction(), "/com/graph/examples/swing/images/paste.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("delete"), GraphActions.getDeleteAction(), "/com/graph/examples/swing/images/delete.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("selectAll"), GraphActions.getSelectAllAction()));
		menu.add(editor.bind(Resources.get("selectNone"), GraphActions.getSelectNoneAction()));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("warning"), new WarningAction()));
		menu.add(editor.bind(Resources.get("edit"), GraphActions.getEditAction()));

		// Creates the view menu
		menu = add(new JMenu(Resources.get("view")));

		JMenuItem item = menu.add(new TogglePropertyItem(graphComponent, Resources.get("pageLayout"), "PageVisible", true,
				new ActionListener()
				{
					/**
					 * 
					 */
					public void actionPerformed(ActionEvent e)
					{
						if (graphComponent.isPageVisible() && graphComponent.isCenterPage())
						{
							graphComponent.zoomAndCenter();
						}
						else
						{
							graphComponent.getGraphControl().updatePreferredSize();
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
					final GraphComponent graphComponent = editor.getGraphComponent();
					TogglePropertyItem toggleItem = (TogglePropertyItem) e.getSource();

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
						Point tr = graphComponent.getGraph().getView().getTranslate();

						if (tr.getX() != 0 || tr.getY() != 0)
						{
							graphComponent.getGraph().getView().setTranslate(new Point());
						}
					}
				}
			}
		});

		menu.add(new TogglePropertyItem(graphComponent, Resources.get("antialias"), "AntiAlias", true));

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

		menu.add(editor.bind(Resources.get("zoomIn"), GraphActions.getZoomInAction()));
		menu.add(editor.bind(Resources.get("zoomOut"), GraphActions.getZoomOutAction()));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("page"), new ZoomPolicyAction(GraphComponent.ZOOM_POLICY_PAGE)));
		menu.add(editor.bind(Resources.get("width"), new ZoomPolicyAction(GraphComponent.ZOOM_POLICY_WIDTH)));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("actualSize"), GraphActions.getZoomActualAction()));

		// Creates the format menu
		menu = add(new JMenu(Resources.get("format")));

		populateFormatMenu(menu, editor);

		// Creates the shape menu
		menu = add(new JMenu(Resources.get("shape")));

		populateShapeMenu(menu, editor);

		// Creates the diagram menu
		menu = add(new JMenu(Resources.get("diagram")));

		menu.add(new ToggleOutlineItem(editor, Resources.get("outline")));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("background")));

		submenu.add(editor.bind(Resources.get("backgroundColor"), new BackgroundAction()));
		submenu.add(editor.bind(Resources.get("backgroundImage"), new BackgroundImageAction()));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("pageBackground"), new PageBackgroundAction()));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("grid")));

		submenu.add(editor.bind(Resources.get("gridSize"), new PromptPropertyAction(graph, "Grid Size", "GridSize")));
		submenu.add(editor.bind(Resources.get("gridColor"), new GridColorAction()));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("dashed"), new GridStyleAction(GraphComponent.GRID_STYLE_DASHED)));
		submenu.add(editor.bind(Resources.get("dot"), new GridStyleAction(GraphComponent.GRID_STYLE_DOT)));
		submenu.add(editor.bind(Resources.get("line"), new GridStyleAction(GraphComponent.GRID_STYLE_LINE)));
		submenu.add(editor.bind(Resources.get("cross"), new GridStyleAction(GraphComponent.GRID_STYLE_CROSS)));

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

		submenu.add(editor.graphLayout("placeEdgeLabels", false));
		submenu.add(editor.graphLayout("parallelEdges", false));

		submenu.addSeparator();

		submenu.add(editor.graphLayout("organicLayout", true));
		submenu.add(editor.graphLayout("circleLayout", true));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("selection")));

		submenu.add(editor.bind(Resources.get("selectPath"), new SelectShortestPathAction(false)));
		submenu.add(editor.bind(Resources.get("selectDirectedPath"), new SelectShortestPathAction(true)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("selectTree"), new SelectSpanningTreeAction(false)));
		submenu.add(editor.bind(Resources.get("selectDirectedTree"), new SelectSpanningTreeAction(true)));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("stylesheet")));

		submenu.add(editor.bind(Resources.get("basicStyle"),
				new StylesheetAction("/com/graph/examples/swing/resources/basic-style.xml")));
		submenu.add(editor.bind(Resources.get("defaultStyle"), new StylesheetAction(
				"/com/graph/examples/swing/resources/default-style.xml")));

		// Creates the options menu
		menu = add(new JMenu(Resources.get("options")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("display")));
		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("buffering"), "TripleBuffered", true));

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("preferPageSize"), "PreferPageSize", true, new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				graphComponent.zoomAndCenter();
			}
		}));

		// TODO: This feature is not yet implemented
		//submenu.add(new TogglePropertyItem(graphComponent, Resources
		//		.get("pageBreaks"), "PageBreaksVisible", true));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("tolerance"), new PromptPropertyAction(graphComponent, "Tolerance")));

		submenu.add(editor.bind(Resources.get("dirty"), new ToggleDirtyAction()));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("zoom")));

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("centerZoom"), "CenterZoom", true));
		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("zoomToSelection"), "KeepSelectionVisibleOnZoom", true));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("centerPage"), "CenterPage", true, new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				if (graphComponent.isPageVisible() && graphComponent.isCenterPage())
				{
					graphComponent.zoomAndCenter();
				}
			}
		}));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("dragAndDrop")));

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("dragEnabled"), "DragEnabled"));
		submenu.add(new TogglePropertyItem(graph, Resources.get("dropEnabled"), "DropEnabled"));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graphComponent.getGraphHandler(), Resources.get("imagePreview"), "ImagePreview"));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("labels")));

		submenu.add(new TogglePropertyItem(graph, Resources.get("htmlLabels"), "HtmlLabels", true));
		submenu.add(new TogglePropertyItem(graph, Resources.get("showLabels"), "LabelsVisible", true));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graph, Resources.get("moveEdgeLabels"), "EdgeLabelsMovable"));
		submenu.add(new TogglePropertyItem(graph, Resources.get("moveVertexLabels"), "VertexLabelsMovable"));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("handleReturn"), "EnterStopsCellEditing"));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("connections")));

		submenu.add(new TogglePropertyItem(graphComponent, Resources.get("connectable"), "Connectable"));
		submenu.add(new TogglePropertyItem(graph, Resources.get("connectableEdges"), "ConnectableEdges"));

		submenu.addSeparator();

		submenu.add(new ToggleCreateTargetItem(editor, Resources.get("createTarget")));
		submenu.add(new TogglePropertyItem(graph, Resources.get("disconnectOnMove"), "DisconnectOnMove"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("connectMode"), new ToggleConnectModeAction()));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("validation")));

		submenu.add(new TogglePropertyItem(graph, Resources.get("allowDanglingEdges"), "AllowDanglingEdges"));
		submenu.add(new TogglePropertyItem(graph, Resources.get("cloneInvalidEdges"), "CloneInvalidEdges"));

		submenu.addSeparator();

		submenu.add(new TogglePropertyItem(graph, Resources.get("allowLoops"), "AllowLoops"));
		submenu.add(new TogglePropertyItem(graph, Resources.get("multigraph"), "Multigraph"));

		// Creates the window menu
		menu = add(new JMenu(Resources.get("window")));

		UIManager.LookAndFeelInfo[] lafs = UIManager.getInstalledLookAndFeels();

		for (int i = 0; i < lafs.length; i++)
		{
			final String clazz = lafs[i].getClassName();
			
			menu.add(new AbstractAction(lafs[i].getName())
			{
				/**
				 * 
				 */
				private static final long serialVersionUID = 7588919504149148501L;

				public void actionPerformed(ActionEvent e)
				{
					editor.setLookAndFeel(clazz);
				}
			});
		}

		// Creates a developer menu
		menu = add(new JMenu("Generate"));
		menu.add(editor.bind("Null Graph", new InsertGraph(GraphType.NULL, aGraph)));
		menu.add(editor.bind("Complete Graph", new InsertGraph(GraphType.COMPLETE, aGraph)));
		menu.add(editor.bind("Grid", new InsertGraph(GraphType.GRID, aGraph)));
		menu.add(editor.bind("Bipartite", new InsertGraph(GraphType.BIPARTITE, aGraph)));
		menu.add(editor.bind("Complete Bipartite", new InsertGraph(GraphType.COMPLETE_BIPARTITE, aGraph)));
		menu.add(editor.bind("Knight's Graph", new InsertGraph(GraphType.KNIGHT, aGraph)));
		menu.add(editor.bind("King's Graph", new InsertGraph(GraphType.KING, aGraph)));
		menu.add(editor.bind("Petersen", new InsertGraph(GraphType.PETERSEN, aGraph)));
		menu.add(editor.bind("Path", new InsertGraph(GraphType.PATH, aGraph)));
		menu.add(editor.bind("Star", new InsertGraph(GraphType.STAR, aGraph)));
		menu.add(editor.bind("Wheel", new InsertGraph(GraphType.WHEEL, aGraph)));
		menu.add(editor.bind("Friendship Windmill", new InsertGraph(GraphType.FRIENDSHIP_WINDMILL, aGraph)));
		menu.add(editor.bind("Full Windmill", new InsertGraph(GraphType.FULL_WINDMILL, aGraph)));
		menu.add(editor.bind("Knight's Tour", new InsertGraph(GraphType.KNIGHT_TOUR, aGraph)));
		menu.addSeparator();
		menu.add(editor.bind("Simple Random", new InsertGraph(GraphType.SIMPLE_RANDOM, aGraph)));
		menu.add(editor.bind("Simple Random Tree", new InsertGraph(GraphType.SIMPLE_RANDOM_TREE, aGraph)));
		menu.addSeparator();
		menu.add(editor.bind("Reset Style", new InsertGraph(GraphType.RESET_STYLE, aGraph)));

		menu = add(new JMenu("Analyze"));
		menu.add(editor.bind("Is Connected", new AnalyzeGraph(AnalyzeType.IS_CONNECTED, aGraph)));
		menu.add(editor.bind("Is Simple", new AnalyzeGraph(AnalyzeType.IS_SIMPLE, aGraph)));
		menu.add(editor.bind("Is Directed Cyclic", new AnalyzeGraph(AnalyzeType.IS_CYCLIC_DIRECTED, aGraph)));
		menu.add(editor.bind("Is Undirected Cyclic", new AnalyzeGraph(AnalyzeType.IS_CYCLIC_UNDIRECTED, aGraph)));
		menu.add(editor.bind("BFS Directed", new InsertGraph(GraphType.BFS_DIR, aGraph)));
		menu.add(editor.bind("BFS Undirected", new InsertGraph(GraphType.BFS_UNDIR, aGraph)));
		menu.add(editor.bind("DFS Directed", new InsertGraph(GraphType.DFS_DIR, aGraph)));
		menu.add(editor.bind("DFS Undirected", new InsertGraph(GraphType.DFS_UNDIR, aGraph)));
		menu.add(editor.bind("Complementary", new AnalyzeGraph(AnalyzeType.COMPLEMENTARY, aGraph)));
		menu.add(editor.bind("Regularity", new AnalyzeGraph(AnalyzeType.REGULARITY, aGraph)));
		menu.add(editor.bind("Dijkstra", new InsertGraph(GraphType.DIJKSTRA, aGraph)));
		menu.add(editor.bind("Bellman-Ford", new InsertGraph(GraphType.BELLMAN_FORD, aGraph)));
		menu.add(editor.bind("Floyd-Roy-Warshall", new AnalyzeGraph(AnalyzeType.FLOYD_ROY_WARSHALL, aGraph)));
		menu.add(editor.bind("Get Components", new AnalyzeGraph(AnalyzeType.COMPONENTS, aGraph)));
		menu.add(editor.bind("Make Connected", new AnalyzeGraph(AnalyzeType.MAKE_CONNECTED, aGraph)));
		menu.add(editor.bind("Make Simple", new AnalyzeGraph(AnalyzeType.MAKE_SIMPLE, aGraph)));
		menu.add(editor.bind("Is Tree", new AnalyzeGraph(AnalyzeType.IS_TREE, aGraph)));
		menu.add(editor.bind("One Spanning Tree", new AnalyzeGraph(AnalyzeType.ONE_SPANNING_TREE, aGraph)));
		menu.add(editor.bind("Make tree directed", new InsertGraph(GraphType.MAKE_TREE_DIRECTED, aGraph)));
		menu.add(editor.bind("Is directed", new AnalyzeGraph(AnalyzeType.IS_DIRECTED, aGraph)));
		menu.add(editor.bind("Indegree", new InsertGraph(GraphType.INDEGREE, aGraph)));
		menu.add(editor.bind("Outdegree", new InsertGraph(GraphType.OUTDEGREE, aGraph)));
		menu.add(editor.bind("Is cut vertex", new InsertGraph(GraphType.IS_CUT_VERTEX, aGraph)));
		menu.add(editor.bind("Get cut vertices", new AnalyzeGraph(AnalyzeType.GET_CUT_VERTEXES, aGraph)));
		menu.add(editor.bind("Get cut edges", new AnalyzeGraph(AnalyzeType.GET_CUT_EDGES, aGraph)));
		menu.add(editor.bind("Get sources", new AnalyzeGraph(AnalyzeType.GET_SOURCES, aGraph)));
		menu.add(editor.bind("Get sinks", new AnalyzeGraph(AnalyzeType.GET_SINKS, aGraph)));
		menu.add(editor.bind("Is biconnected", new AnalyzeGraph(AnalyzeType.IS_BICONNECTED, aGraph)));

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

	/**
	 * Adds menu items to the given shape menu. This is factored out because
	 * the shape menu appears in the menubar and also in the popupmenu.
	 */
	public static void populateShapeMenu(JMenu menu, BasicGraphEditor editor)
	{
		menu.add(editor.bind(Resources.get("home"), GraphActions.getHomeAction(), "/com/graph/examples/swing/images/house.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("exitGroup"), GraphActions.getExitGroupAction(), "/com/graph/examples/swing/images/up.gif"));
		menu.add(editor.bind(Resources.get("enterGroup"), GraphActions.getEnterGroupAction(),
				"/com/graph/examples/swing/images/down.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("group"), GraphActions.getGroupAction(), "/com/graph/examples/swing/images/group.gif"));
		menu.add(editor.bind(Resources.get("ungroup"), GraphActions.getUngroupAction(),
				"/com/graph/examples/swing/images/ungroup.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("removeFromGroup"), GraphActions.getRemoveFromParentAction()));

		menu.add(editor.bind(Resources.get("updateGroupBounds"), GraphActions.getUpdateGroupBoundsAction()));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("collapse"), GraphActions.getCollapseAction(),
				"/com/graph/examples/swing/images/collapse.gif"));
		menu.add(editor.bind(Resources.get("expand"), GraphActions.getExpandAction(), "/com/graph/examples/swing/images/expand.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("toBack"), GraphActions.getToBackAction(), "/com/graph/examples/swing/images/toback.gif"));
		menu.add(editor.bind(Resources.get("toFront"), GraphActions.getToFrontAction(),
				"/com/graph/examples/swing/images/tofront.gif"));

		menu.addSeparator();

		JMenu submenu = (JMenu) menu.add(new JMenu(Resources.get("align")));

		submenu.add(editor.bind(Resources.get("left"), new AlignCellsAction(Constants.ALIGN_LEFT),
				"/com/graph/examples/swing/images/alignleft.gif"));
		submenu.add(editor.bind(Resources.get("center"), new AlignCellsAction(Constants.ALIGN_CENTER),
				"/com/graph/examples/swing/images/aligncenter.gif"));
		submenu.add(editor.bind(Resources.get("right"), new AlignCellsAction(Constants.ALIGN_RIGHT),
				"/com/graph/examples/swing/images/alignright.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("top"), new AlignCellsAction(Constants.ALIGN_TOP),
				"/com/graph/examples/swing/images/aligntop.gif"));
		submenu.add(editor.bind(Resources.get("middle"), new AlignCellsAction(Constants.ALIGN_MIDDLE),
				"/com/graph/examples/swing/images/alignmiddle.gif"));
		submenu.add(editor.bind(Resources.get("bottom"), new AlignCellsAction(Constants.ALIGN_BOTTOM),
				"/com/graph/examples/swing/images/alignbottom.gif"));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("autosize"), new AutosizeAction()));

	}

	/**
	 * Adds menu items to the given format menu. This is factored out because
	 * the format menu appears in the menubar and also in the popupmenu.
	 */
	public static void populateFormatMenu(JMenu menu, BasicGraphEditor editor)
	{
		JMenu submenu = (JMenu) menu.add(new JMenu(Resources.get("background")));

		submenu.add(editor.bind(Resources.get("fillcolor"), new ColorAction("Fillcolor", Constants.STYLE_FILLCOLOR),
				"/com/graph/examples/swing/images/fillcolor.gif"));
		submenu.add(editor.bind(Resources.get("gradient"), new ColorAction("Gradient", Constants.STYLE_GRADIENTCOLOR)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("image"), new PromptValueAction(Constants.STYLE_IMAGE, "Image")));
		submenu.add(editor.bind(Resources.get("shadow"), new ToggleAction(Constants.STYLE_SHADOW)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("opacity"), new PromptValueAction(Constants.STYLE_OPACITY, "Opacity (0-100)")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("label")));

		submenu.add(editor.bind(Resources.get("fontcolor"), new ColorAction("Fontcolor", Constants.STYLE_FONTCOLOR),
				"/com/graph/examples/swing/images/fontcolor.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("labelFill"), new ColorAction("Label Fill", Constants.STYLE_LABEL_BACKGROUNDCOLOR)));
		submenu.add(editor.bind(Resources.get("labelBorder"), new ColorAction("Label Border", Constants.STYLE_LABEL_BORDERCOLOR)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("rotateLabel"), new ToggleAction(Constants.STYLE_HORIZONTAL, true)));

		submenu.add(editor.bind(Resources.get("textOpacity"), new PromptValueAction(Constants.STYLE_TEXT_OPACITY, "Opacity (0-100)")));

		submenu.addSeparator();

		JMenu subsubmenu = (JMenu) submenu.add(new JMenu(Resources.get("position")));

		subsubmenu.add(editor.bind(Resources.get("top"), new SetLabelPositionAction(Constants.ALIGN_TOP, Constants.ALIGN_BOTTOM)));
		subsubmenu.add(editor.bind(Resources.get("middle"),
				new SetLabelPositionAction(Constants.ALIGN_MIDDLE, Constants.ALIGN_MIDDLE)));
		subsubmenu.add(editor.bind(Resources.get("bottom"), new SetLabelPositionAction(Constants.ALIGN_BOTTOM, Constants.ALIGN_TOP)));

		subsubmenu.addSeparator();

		subsubmenu.add(editor.bind(Resources.get("left"), new SetLabelPositionAction(Constants.ALIGN_LEFT, Constants.ALIGN_RIGHT)));
		subsubmenu.add(editor.bind(Resources.get("center"),
				new SetLabelPositionAction(Constants.ALIGN_CENTER, Constants.ALIGN_CENTER)));
		subsubmenu.add(editor.bind(Resources.get("right"), new SetLabelPositionAction(Constants.ALIGN_RIGHT, Constants.ALIGN_LEFT)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("wordWrap"), new KeyValueAction(Constants.STYLE_WHITE_SPACE, "wrap")));
		submenu.add(editor.bind(Resources.get("noWordWrap"), new KeyValueAction(Constants.STYLE_WHITE_SPACE, null)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("hide"), new ToggleAction(Constants.STYLE_NOLABEL)));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("line")));

		submenu.add(editor.bind(Resources.get("linecolor"), new ColorAction("Linecolor", Constants.STYLE_STROKECOLOR),
				"/com/graph/examples/swing/images/linecolor.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("orthogonal"), new ToggleAction(Constants.STYLE_ORTHOGONAL)));
		submenu.add(editor.bind(Resources.get("dashed"), new ToggleAction(Constants.STYLE_DASHED)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("linewidth"), new PromptValueAction(Constants.STYLE_STROKEWIDTH, "Linewidth")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("connector")));

		submenu.add(editor.bind(Resources.get("straight"), new SetStyleAction("straight"),
				"/com/graph/examples/swing/images/straight.gif"));

		submenu.add(editor.bind(Resources.get("horizontal"), new SetStyleAction(""), "/com/graph/examples/swing/images/connect.gif"));
		submenu.add(editor.bind(Resources.get("vertical"), new SetStyleAction("vertical"),
				"/com/graph/examples/swing/images/vertical.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("entityRelation"), new SetStyleAction("edgeStyle=EdgeStyle.EntityRelation"),
				"/com/graph/examples/swing/images/entity.gif"));
		submenu.add(editor.bind(Resources.get("arrow"), new SetStyleAction("arrow"), "/com/graph/examples/swing/images/arrow.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("plain"), new ToggleAction(Constants.STYLE_NOEDGESTYLE)));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("linestart")));

		submenu.add(editor.bind(Resources.get("open"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.ARROW_OPEN),
				"/com/graph/examples/swing/images/open_start.gif"));
		submenu.add(editor.bind(Resources.get("classic"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.ARROW_CLASSIC),
				"/com/graph/examples/swing/images/classic_start.gif"));
		submenu.add(editor.bind(Resources.get("block"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.ARROW_BLOCK),
				"/com/graph/examples/swing/images/block_start.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("diamond"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.ARROW_DIAMOND),
				"/com/graph/examples/swing/images/diamond_start.gif"));
		submenu.add(editor.bind(Resources.get("oval"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.ARROW_OVAL),
				"/com/graph/examples/swing/images/oval_start.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("none"), new KeyValueAction(Constants.STYLE_STARTARROW, Constants.NONE)));
		submenu.add(editor.bind(Resources.get("size"), new PromptValueAction(Constants.STYLE_STARTSIZE, "Linestart Size")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("lineend")));

		submenu.add(editor.bind(Resources.get("open"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.ARROW_OPEN),
				"/com/graph/examples/swing/images/open_end.gif"));
		submenu.add(editor.bind(Resources.get("classic"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.ARROW_CLASSIC),
				"/com/graph/examples/swing/images/classic_end.gif"));
		submenu.add(editor.bind(Resources.get("block"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.ARROW_BLOCK),
				"/com/graph/examples/swing/images/block_end.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("diamond"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.ARROW_DIAMOND),
				"/com/graph/examples/swing/images/diamond_end.gif"));
		submenu.add(editor.bind(Resources.get("oval"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.ARROW_OVAL),
				"/com/graph/examples/swing/images/oval_end.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("none"), new KeyValueAction(Constants.STYLE_ENDARROW, Constants.NONE)));
		submenu.add(editor.bind(Resources.get("size"), new PromptValueAction(Constants.STYLE_ENDSIZE, "Lineend Size")));

		menu.addSeparator();

		submenu = (JMenu) menu.add(new JMenu(Resources.get("alignment")));

		submenu.add(editor.bind(Resources.get("left"), new KeyValueAction(Constants.STYLE_ALIGN, Constants.ALIGN_LEFT),
				"/com/graph/examples/swing/images/left.gif"));
		submenu.add(editor.bind(Resources.get("center"), new KeyValueAction(Constants.STYLE_ALIGN, Constants.ALIGN_CENTER),
				"/com/graph/examples/swing/images/center.gif"));
		submenu.add(editor.bind(Resources.get("right"), new KeyValueAction(Constants.STYLE_ALIGN, Constants.ALIGN_RIGHT),
				"/com/graph/examples/swing/images/right.gif"));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("top"), new KeyValueAction(Constants.STYLE_VERTICAL_ALIGN, Constants.ALIGN_TOP),
				"/com/graph/examples/swing/images/top.gif"));
		submenu.add(editor.bind(Resources.get("middle"), new KeyValueAction(Constants.STYLE_VERTICAL_ALIGN, Constants.ALIGN_MIDDLE),
				"/com/graph/examples/swing/images/middle.gif"));
		submenu.add(editor.bind(Resources.get("bottom"), new KeyValueAction(Constants.STYLE_VERTICAL_ALIGN, Constants.ALIGN_BOTTOM),
				"/com/graph/examples/swing/images/bottom.gif"));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("spacing")));

		submenu.add(editor.bind(Resources.get("top"), new PromptValueAction(Constants.STYLE_SPACING_TOP, "Top Spacing")));
		submenu.add(editor.bind(Resources.get("right"), new PromptValueAction(Constants.STYLE_SPACING_RIGHT, "Right Spacing")));
		submenu.add(editor.bind(Resources.get("bottom"), new PromptValueAction(Constants.STYLE_SPACING_BOTTOM, "Bottom Spacing")));
		submenu.add(editor.bind(Resources.get("left"), new PromptValueAction(Constants.STYLE_SPACING_LEFT, "Left Spacing")));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("global"), new PromptValueAction(Constants.STYLE_SPACING, "Spacing")));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("sourceSpacing"), new PromptValueAction(Constants.STYLE_SOURCE_PERIMETER_SPACING,
				Resources.get("sourceSpacing"))));
		submenu.add(editor.bind(Resources.get("targetSpacing"), new PromptValueAction(Constants.STYLE_TARGET_PERIMETER_SPACING,
				Resources.get("targetSpacing"))));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("perimeter"), new PromptValueAction(Constants.STYLE_PERIMETER_SPACING,
				"Perimeter Spacing")));

		submenu = (JMenu) menu.add(new JMenu(Resources.get("direction")));

		submenu.add(editor.bind(Resources.get("north"), new KeyValueAction(Constants.STYLE_DIRECTION, Constants.DIRECTION_NORTH)));
		submenu.add(editor.bind(Resources.get("east"), new KeyValueAction(Constants.STYLE_DIRECTION, Constants.DIRECTION_EAST)));
		submenu.add(editor.bind(Resources.get("south"), new KeyValueAction(Constants.STYLE_DIRECTION, Constants.DIRECTION_SOUTH)));
		submenu.add(editor.bind(Resources.get("west"), new KeyValueAction(Constants.STYLE_DIRECTION, Constants.DIRECTION_WEST)));

		submenu.addSeparator();

		submenu.add(editor.bind(Resources.get("rotation"), new PromptValueAction(Constants.STYLE_ROTATION, "Rotation (0-360)")));

		menu.addSeparator();

		menu.add(editor.bind(Resources.get("rounded"), new ToggleAction(Constants.STYLE_ROUNDED)));

		menu.add(editor.bind(Resources.get("style"), new StyleAction()));
	}

	/**
	 *
	 */
	public static class InsertGraph extends AbstractAction
	{

		/**
		 * 
		 */
		private static final long serialVersionUID = 4010463992665008365L;

		/**
		 * 
		 */
		protected GraphType graphType;

		protected AnalysisGraph aGraph;

		/**
		 * @param aGraph 
		 * 
		 */
		public InsertGraph(GraphType tree, AnalysisGraph aGraph)
		{
			this.graphType = tree;
			this.aGraph = aGraph;
		}

		/**
		 * 
		 */
		public void actionPerformed(ActionEvent e)
		{
			if (e.getSource() instanceof GraphComponent)
			{
				GraphComponent graphComponent = (GraphComponent) e.getSource();
				Graph graph = graphComponent.getGraph();

				// dialog = new FactoryConfigDialog();
				String dialogText = "";
				if (graphType == GraphType.NULL)
					dialogText = "Configure null graph";
				else if (graphType == GraphType.COMPLETE)
					dialogText = "Configure complete graph";
				else if (graphType == GraphType.NREGULAR)
					dialogText = "Configure n-regular graph";
				else if (graphType == GraphType.GRID)
					dialogText = "Configure grid graph";
				else if (graphType == GraphType.BIPARTITE)
					dialogText = "Configure bipartite graph";
				else if (graphType == GraphType.COMPLETE_BIPARTITE)
					dialogText = "Configure complete bipartite graph";
				else if (graphType == GraphType.BFS_DIR)
					dialogText = "Configure BFS algorithm";
				else if (graphType == GraphType.BFS_UNDIR)
					dialogText = "Configure BFS algorithm";
				else if (graphType == GraphType.DFS_DIR)
					dialogText = "Configure DFS algorithm";
				else if (graphType == GraphType.DFS_UNDIR)
					dialogText = "Configure DFS algorithm";
				else if (graphType == GraphType.DIJKSTRA)
					dialogText = "Configure Dijkstra's algorithm";
				else if (graphType == GraphType.BELLMAN_FORD)
					dialogText = "Configure Bellman-Ford algorithm";
				else if (graphType == GraphType.MAKE_TREE_DIRECTED)
					dialogText = "Configure make tree directed algorithm";
				else if (graphType == GraphType.KNIGHT_TOUR)
					dialogText = "Configure knight's tour";
				else if (graphType == GraphType.GET_ADJ_MATRIX)
					dialogText = "Configure adjacency matrix";
				else if (graphType == GraphType.FROM_ADJ_MATRIX)
					dialogText = "Input adjacency matrix";
				else if (graphType == GraphType.PETERSEN)
					dialogText = "Configure Petersen graph";
				else if (graphType == GraphType.WHEEL)
					dialogText = "Configure Wheel graph";
				else if (graphType == GraphType.STAR)
					dialogText = "Configure Star graph";
				else if (graphType == GraphType.PATH)
					dialogText = "Configure Path graph";
				else if (graphType == GraphType.FRIENDSHIP_WINDMILL)
					dialogText = "Configure Friendship Windmill graph";
				else if (graphType == GraphType.INDEGREE)
					dialogText = "Configure indegree analysis";
				else if (graphType == GraphType.OUTDEGREE)
					dialogText = "Configure outdegree analysis";
				GraphConfigDialog dialog = new GraphConfigDialog(graphType, dialogText);
				dialog.configureLayout(graph, graphType, aGraph);
				dialog.setModal(true);
				Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
				Dimension frameSize = dialog.getSize();
				dialog.setLocation(screenSize.width / 2 - (frameSize.width / 2), screenSize.height / 2 - (frameSize.height / 2));
				dialog.setVisible(true);
			}
		}
	}

	/**
	 *
	 */
	public static class AnalyzeGraph extends AbstractAction
	{
		/**
		 * 
		 */
		private static final long serialVersionUID = 6926170745240507985L;

		AnalysisGraph aGraph;

		/**
		 * 
		 */
		protected AnalyzeType analyzeType;

		/**
		 * Examples for calling analysis methods from GraphStructure 
		 */
		public AnalyzeGraph(AnalyzeType analyzeType, AnalysisGraph aGraph)
		{
			this.analyzeType = analyzeType;
			this.aGraph = aGraph;
		}

		public void actionPerformed(ActionEvent e)
		{
			if (e.getSource() instanceof GraphComponent)
			{
				GraphComponent graphComponent = (GraphComponent) e.getSource();
				Graph graph = graphComponent.getGraph();

				if (analyzeType == AnalyzeType.IS_CONNECTED)
				{
					boolean isConnected = GraphStructure.isConnected(aGraph);

					if (isConnected)
					{
						System.out.println("The graph is connected");
					}
					else
					{
						System.out.println("The graph is not connected");
					}
				}
				else if (analyzeType == AnalyzeType.IS_SIMPLE)
				{
					boolean isSimple = GraphStructure.isSimple(aGraph);

					if (isSimple)
					{
						System.out.println("The graph is simple");
					}
					else
					{
						System.out.println("The graph is not simple");
					}
				}
				else if (analyzeType == AnalyzeType.IS_CYCLIC_DIRECTED)
				{
					boolean isCyclicDirected = GraphStructure.isCyclicDirected(aGraph);

					if (isCyclicDirected)
					{
						System.out.println("The graph is cyclic directed");
					}
					else
					{
						System.out.println("The graph is acyclic directed");
					}
				}
				else if (analyzeType == AnalyzeType.IS_CYCLIC_UNDIRECTED)
				{
					boolean isCyclicUndirected = GraphStructure.isCyclicUndirected(aGraph);

					if (isCyclicUndirected)
					{
						System.out.println("The graph is cyclic undirected");
					}
					else
					{
						System.out.println("The graph is acyclic undirected");
					}
				}
				else if (analyzeType == AnalyzeType.COMPLEMENTARY)
				{
					graph.getModel().beginUpdate();

					GraphStructure.complementaryGraph(aGraph);

					GraphStructure.setDefaultGraphStyle(aGraph, true);
					graph.getModel().endUpdate();
				}
				else if (analyzeType == AnalyzeType.REGULARITY)
				{
					try
					{
						int regularity = GraphStructure.regularity(aGraph);
						System.out.println("Graph regularity is: " + regularity);
					}
					catch (StructuralException e1)
					{
						System.out.println("The graph is irregular");
					}
				}
				else if (analyzeType == AnalyzeType.COMPONENTS)
				{
					Object[][] components = GraphStructure.getGraphComponents(aGraph);
					IGraphModel model = aGraph.getGraph().getModel();

					for (int i = 0; i < components.length; i++)
					{
						System.out.print("Component " + i + " :");

						for (int j = 0; j < components[i].length; j++)
						{
							System.out.print(" " + model.getValue(components[i][j]));
						}

						System.out.println(".");
					}

					System.out.println("Number of components: " + components.length);

				}
				else if (analyzeType == AnalyzeType.MAKE_CONNECTED)
				{
					graph.getModel().beginUpdate();

					if (!GraphStructure.isConnected(aGraph))
					{
						GraphStructure.makeConnected(aGraph);
						GraphStructure.setDefaultGraphStyle(aGraph, false);
					}

					graph.getModel().endUpdate();
				}
				else if (analyzeType == AnalyzeType.MAKE_SIMPLE)
				{
					GraphStructure.makeSimple(aGraph);
				}
				else if (analyzeType == AnalyzeType.IS_TREE)
				{
					boolean isTree = GraphStructure.isTree(aGraph);

					if (isTree)
					{
						System.out.println("The graph is a tree");
					}
					else
					{
						System.out.println("The graph is not a tree");
					}
				}
				else if (analyzeType == AnalyzeType.ONE_SPANNING_TREE)
				{
					try
					{
						graph.getModel().beginUpdate();
						aGraph.getGenerator().oneSpanningTree(aGraph, true, true);
						GraphStructure.setDefaultGraphStyle(aGraph, false);
						graph.getModel().endUpdate();
					}
					catch (StructuralException e1)
					{
						System.out.println("The graph must be simple and connected");
					}
				}
				else if (analyzeType == AnalyzeType.IS_DIRECTED)
				{
					boolean isDirected = GraphProperties.isDirected(aGraph.getProperties(), GraphProperties.DEFAULT_DIRECTED);

					if (isDirected)
					{
						System.out.println("The graph is directed.");
					}
					else
					{
						System.out.println("The graph is undirected.");
					}
				}
				else if (analyzeType == AnalyzeType.GET_CUT_VERTEXES)
				{
					Object[] cutVertices = GraphStructure.getCutVertices(aGraph);

					System.out.print("Cut vertices of the graph are: [");
					IGraphModel model = aGraph.getGraph().getModel();

					for (int i = 0; i < cutVertices.length; i++)
					{
						System.out.print(" " + model.getValue(cutVertices[i]));
					}

					System.out.println(" ]");
				}
				else if (analyzeType == AnalyzeType.GET_CUT_EDGES)
				{
					Object[] cutEdges = GraphStructure.getCutEdges(aGraph);

					System.out.print("Cut edges of the graph are: [");
					IGraphModel model = aGraph.getGraph().getModel();

					for (int i = 0; i < cutEdges.length; i++)
					{
						System.out.print(" " + Integer.parseInt((String) model.getValue(aGraph.getTerminal(cutEdges[i], true))) + "-"
								+ Integer.parseInt((String) model.getValue(aGraph.getTerminal(cutEdges[i], false))));
					}

					System.out.println(" ]");
				}
				else if (analyzeType == AnalyzeType.GET_SOURCES)
				{
					try
					{
						Object[] sourceVertices = GraphStructure.getSourceVertices(aGraph);
						System.out.print("Source vertices of the graph are: [");
						IGraphModel model = aGraph.getGraph().getModel();

						for (int i = 0; i < sourceVertices.length; i++)
						{
							System.out.print(" " + model.getValue(sourceVertices[i]));
						}

						System.out.println(" ]");
					}
					catch (StructuralException e1)
					{
						System.out.println(e1);
					}
				}
				else if (analyzeType == AnalyzeType.GET_SINKS)
				{
					try
					{
						Object[] sinkVertices = GraphStructure.getSinkVertices(aGraph);
						System.out.print("Sink vertices of the graph are: [");
						IGraphModel model = aGraph.getGraph().getModel();

						for (int i = 0; i < sinkVertices.length; i++)
						{
							System.out.print(" " + model.getValue(sinkVertices[i]));
						}

						System.out.println(" ]");
					}
					catch (StructuralException e1)
					{
						System.out.println(e1);
					}
				}
				else if (analyzeType == AnalyzeType.PLANARITY)
				{
					//TODO implement
				}
				else if (analyzeType == AnalyzeType.IS_BICONNECTED)
				{
					boolean isBiconnected = GraphStructure.isBiconnected(aGraph);

					if (isBiconnected)
					{
						System.out.println("The graph is biconnected.");
					}
					else
					{
						System.out.println("The graph is not biconnected.");
					}
				}
				else if (analyzeType == AnalyzeType.GET_BICONNECTED)
				{
					//TODO implement
				}
				else if (analyzeType == AnalyzeType.SPANNING_TREE)
				{
					//TODO implement
				}
				else if (analyzeType == AnalyzeType.FLOYD_ROY_WARSHALL)
				{
					
					ArrayList<Object[][]> FWIresult = new ArrayList<Object[][]>();
					try
					{
						//only this line is needed to get the result from Floyd-Roy-Warshall, the rest is code for displaying the result
						FWIresult = Traversal.floydRoyWarshall(aGraph);

						Object[][] dist = FWIresult.get(0);
						Object[][] paths = FWIresult.get(1);
						Object[] vertices = aGraph.getChildVertices(aGraph.getGraph().getDefaultParent());
						int vertexNum = vertices.length;
						System.out.println("Distances are:");

						for (int i = 0; i < vertexNum; i++)
						{
							System.out.print("[");

							for (int j = 0; j < vertexNum; j++)
							{
								System.out.print(" " + Math.round((Double) dist[i][j] * 100.0) / 100.0);
							}

							System.out.println("] ");
						}

						System.out.println("Path info:");

						CostFunction costFunction = aGraph.getGenerator().getCostFunction();
						GraphView view = aGraph.getGraph().getView();

						for (int i = 0; i < vertexNum; i++)
						{
							System.out.print("[");

							for (int j = 0; j < vertexNum; j++)
							{
								if (paths[i][j] != null)
								{
									System.out.print(" " + costFunction.getCost(view.getState(paths[i][j])));
								}
								else
								{
									System.out.print(" -");
								}
							}

							System.out.println(" ]");
						}

						try
						{
							Object[] path = Traversal.getWFIPath(aGraph, FWIresult, vertices[0], vertices[vertexNum - 1]);
							System.out.print("The path from " + costFunction.getCost(view.getState(vertices[0])) + " to "
									+ costFunction.getCost((view.getState(vertices[vertexNum - 1]))) + " is:");

							for (int i = 0; i < path.length; i++)
							{
								System.out.print(" " + costFunction.getCost(view.getState(path[i])));
							}

							System.out.println();
						}
						catch (StructuralException e1)
						{
							System.out.println(e1);
						}
					}
					catch (StructuralException e2)
					{
						System.out.println(e2);
					}
				}
			}
		}
	};
};