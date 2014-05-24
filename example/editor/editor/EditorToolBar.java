package graph.examples.swing.editor;

import java.awt.Dimension;
import java.awt.GraphicsEnvironment;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JToolBar;
import javax.swing.TransferHandler;

import graph.examples.swing.editor.EditorActions.ColorAction;
import graph.examples.swing.editor.EditorActions.FontStyleAction;
import graph.examples.swing.editor.EditorActions.HistoryAction;
import graph.examples.swing.editor.EditorActions.KeyValueAction;
import graph.examples.swing.editor.EditorActions.NewAction;
import graph.examples.swing.editor.EditorActions.OpenAction;
import graph.examples.swing.editor.EditorActions.PrintAction;
import graph.examples.swing.editor.EditorActions.SaveAction;
import graph.swing.GraphComponent;
import graph.swing.util.GraphActions;
import graph.util.Constants;
import graph.util.Event;
import graph.util.EventObject;
import graph.util.Resources;
import graph.util.EventSource.IEventListener;
import graph.view.Graph;
import graph.view.GraphView;

public class EditorToolBar extends JToolBar
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -8015443128436394471L;

	/**
	 * 
	 * @param frame
	 * @param orientation
	 */
	private boolean ignoreZoomChange = false;

	/**
	 * 
	 */
	public EditorToolBar(final BasicGraphEditor editor, int orientation)
	{
		super(orientation);
		setBorder(BorderFactory.createCompoundBorder(BorderFactory
				.createEmptyBorder(3, 3, 3, 3), getBorder()));
		setFloatable(false);

		add(editor.bind("New", new NewAction(),
				"/com/graph/examples/swing/images/new.gif"));
		add(editor.bind("Open", new OpenAction(),
				"/com/graph/examples/swing/images/open.gif"));
		add(editor.bind("Save", new SaveAction(false),
				"/com/graph/examples/swing/images/save.gif"));

		addSeparator();

		add(editor.bind("Print", new PrintAction(),
				"/com/graph/examples/swing/images/print.gif"));

		addSeparator();

		add(editor.bind("Cut", TransferHandler.getCutAction(),
				"/com/graph/examples/swing/images/cut.gif"));
		add(editor.bind("Copy", TransferHandler.getCopyAction(),
				"/com/graph/examples/swing/images/copy.gif"));
		add(editor.bind("Paste", TransferHandler.getPasteAction(),
				"/com/graph/examples/swing/images/paste.gif"));

		addSeparator();

		add(editor.bind("Delete", GraphActions.getDeleteAction(),
				"/com/graph/examples/swing/images/delete.gif"));

		addSeparator();

		add(editor.bind("Undo", new HistoryAction(true),
				"/com/graph/examples/swing/images/undo.gif"));
		add(editor.bind("Redo", new HistoryAction(false),
				"/com/graph/examples/swing/images/redo.gif"));

		addSeparator();

		// Gets the list of available fonts from the local graphics environment
		// and adds some frequently used fonts at the beginning of the list
		GraphicsEnvironment env = GraphicsEnvironment
				.getLocalGraphicsEnvironment();
		List<String> fonts = new ArrayList<String>();
		fonts.addAll(Arrays.asList(new String[] { "Helvetica", "Verdana",
				"Times New Roman", "Garamond", "Courier New", "-" }));
		fonts.addAll(Arrays.asList(env.getAvailableFontFamilyNames()));

		final JComboBox fontCombo = new JComboBox(fonts.toArray());
		fontCombo.setEditable(true);
		fontCombo.setMinimumSize(new Dimension(120, 0));
		fontCombo.setPreferredSize(new Dimension(120, 0));
		fontCombo.setMaximumSize(new Dimension(120, 100));
		add(fontCombo);

		fontCombo.addActionListener(new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				String font = fontCombo.getSelectedItem().toString();

				if (font != null && !font.equals("-"))
				{
					Graph graph = editor.getGraphComponent().getGraph();
					graph.setCellStyles(Constants.STYLE_FONTFAMILY, font);
				}
			}
		});

		final JComboBox sizeCombo = new JComboBox(new Object[] { "6pt", "8pt",
				"9pt", "10pt", "12pt", "14pt", "18pt", "24pt", "30pt", "36pt",
				"48pt", "60pt" });
		sizeCombo.setEditable(true);
		sizeCombo.setMinimumSize(new Dimension(65, 0));
		sizeCombo.setPreferredSize(new Dimension(65, 0));
		sizeCombo.setMaximumSize(new Dimension(65, 100));
		add(sizeCombo);

		sizeCombo.addActionListener(new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				Graph graph = editor.getGraphComponent().getGraph();
				graph.setCellStyles(Constants.STYLE_FONTSIZE, sizeCombo
						.getSelectedItem().toString().replace("pt", ""));
			}
		});

		addSeparator();

		add(editor.bind("Bold", new FontStyleAction(true),
				"/com/graph/examples/swing/images/bold.gif"));
		add(editor.bind("Italic", new FontStyleAction(false),
				"/com/graph/examples/swing/images/italic.gif"));

		addSeparator();

		add(editor.bind("Left", new KeyValueAction(Constants.STYLE_ALIGN,
				Constants.ALIGN_LEFT),
				"/com/graph/examples/swing/images/left.gif"));
		add(editor.bind("Center", new KeyValueAction(Constants.STYLE_ALIGN,
				Constants.ALIGN_CENTER),
				"/com/graph/examples/swing/images/center.gif"));
		add(editor.bind("Right", new KeyValueAction(Constants.STYLE_ALIGN,
				Constants.ALIGN_RIGHT),
				"/com/graph/examples/swing/images/right.gif"));

		addSeparator();

		add(editor.bind("Font", new ColorAction("Font",
				Constants.STYLE_FONTCOLOR),
				"/com/graph/examples/swing/images/fontcolor.gif"));
		add(editor.bind("Stroke", new ColorAction("Stroke",
				Constants.STYLE_STROKECOLOR),
				"/com/graph/examples/swing/images/linecolor.gif"));
		add(editor.bind("Fill", new ColorAction("Fill",
				Constants.STYLE_FILLCOLOR),
				"/com/graph/examples/swing/images/fillcolor.gif"));

		addSeparator();

		final GraphView view = editor.getGraphComponent().getGraph()
				.getView();
		final JComboBox zoomCombo = new JComboBox(new Object[] { "400%",
				"200%", "150%", "100%", "75%", "50%", Resources.get("page"),
				Resources.get("width"), Resources.get("actualSize") });
		zoomCombo.setEditable(true);
		zoomCombo.setMinimumSize(new Dimension(75, 0));
		zoomCombo.setPreferredSize(new Dimension(75, 0));
		zoomCombo.setMaximumSize(new Dimension(75, 100));
		zoomCombo.setMaximumRowCount(9);
		add(zoomCombo);

		// Sets the zoom in the zoom combo the current value
		IEventListener scaleTracker = new IEventListener()
		{
			/**
			 * 
			 */
			public void invoke(Object sender, EventObject evt)
			{
				ignoreZoomChange = true;

				try
				{
					zoomCombo.setSelectedItem((int) Math.round(100 * view
							.getScale())
							+ "%");
				}
				finally
				{
					ignoreZoomChange = false;
				}
			}
		};

		// Installs the scale tracker to update the value in the combo box
		// if the zoom is changed from outside the combo box
		view.getGraph().getView().addListener(Event.SCALE, scaleTracker);
		view.getGraph().getView().addListener(Event.SCALE_AND_TRANSLATE,
				scaleTracker);

		// Invokes once to sync with the actual zoom value
		scaleTracker.invoke(null, null);

		zoomCombo.addActionListener(new ActionListener()
		{
			/**
			 * 
			 */
			public void actionPerformed(ActionEvent e)
			{
				GraphComponent graphComponent = editor.getGraphComponent();

				// Zoomcombo is changed when the scale is changed in the diagram
				// but the change is ignored here
				if (!ignoreZoomChange)
				{
					String zoom = zoomCombo.getSelectedItem().toString();

					if (zoom.equals(Resources.get("page")))
					{
						graphComponent.setPageVisible(true);
						graphComponent
								.setZoomPolicy(GraphComponent.ZOOM_POLICY_PAGE);
					}
					else if (zoom.equals(Resources.get("width")))
					{
						graphComponent.setPageVisible(true);
						graphComponent
								.setZoomPolicy(GraphComponent.ZOOM_POLICY_WIDTH);
					}
					else if (zoom.equals(Resources.get("actualSize")))
					{
						graphComponent.zoomActual();
					}
					else
					{
						try
						{
							zoom = zoom.replace("%", "");
							double scale = Math.min(16, Math.max(0.01,
									Double.parseDouble(zoom) / 100));
							graphComponent.zoomTo(scale, graphComponent
									.isCenterZoom());
						}
						catch (Exception ex)
						{
							JOptionPane.showMessageDialog(editor, ex
									.getMessage());
						}
					}
				}
			}
		});
	}
}
