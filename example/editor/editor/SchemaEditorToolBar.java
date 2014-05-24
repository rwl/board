package graph.examples.swing.editor;

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JToolBar;
import javax.swing.TransferHandler;

import graph.examples.swing.editor.EditorActions.HistoryAction;
import graph.examples.swing.editor.EditorActions.NewAction;
import graph.examples.swing.editor.EditorActions.OpenAction;
import graph.examples.swing.editor.EditorActions.PrintAction;
import graph.examples.swing.editor.EditorActions.SaveAction;
import graph.swing.GraphComponent;
import graph.swing.util.GraphActions;
import graph.util.Event;
import graph.util.EventObject;
import graph.util.Resources;
import graph.util.EventSource.IEventListener;
import graph.view.GraphView;

public class SchemaEditorToolBar extends JToolBar
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -3979320704834605323L;

	/**
	 * 
	 * @param frame
	 * @param orientation
	 */
	private boolean ignoreZoomChange = false;

	/**
	 * 
	 */
	public SchemaEditorToolBar(final BasicGraphEditor editor, int orientation)
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
