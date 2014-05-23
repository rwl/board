package graph.examples.swing.editor;

import javax.swing.JMenu;
import javax.swing.JPopupMenu;
import javax.swing.TransferHandler;

import graph.examples.swing.editor.EditorActions.HistoryAction;
import graph.swing.util.GraphActions;
import graph.util.Resources;

public class EditorPopupMenu extends JPopupMenu
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -3132749140550242191L;

	public EditorPopupMenu(BasicGraphEditor editor)
	{
		boolean selected = !editor.getGraphComponent().getGraph()
				.isSelectionEmpty();

		add(editor.bind(Resources.get("undo"), new HistoryAction(true),
				"/com/graph/examples/swing/images/undo.gif"));

		addSeparator();

		add(
				editor.bind(Resources.get("cut"), TransferHandler
						.getCutAction(),
						"/com/graph/examples/swing/images/cut.gif"))
				.setEnabled(selected);
		add(
				editor.bind(Resources.get("copy"), TransferHandler
						.getCopyAction(),
						"/com/graph/examples/swing/images/copy.gif"))
				.setEnabled(selected);
		add(editor.bind(Resources.get("paste"), TransferHandler
				.getPasteAction(),
				"/com/graph/examples/swing/images/paste.gif"));

		addSeparator();

		add(
				editor.bind(Resources.get("delete"), GraphActions
						.getDeleteAction(),
						"/com/graph/examples/swing/images/delete.gif"))
				.setEnabled(selected);

		addSeparator();

		// Creates the format menu
		JMenu menu = (JMenu) add(new JMenu(Resources.get("format")));

		EditorMenuBar.populateFormatMenu(menu, editor);

		// Creates the shape menu
		menu = (JMenu) add(new JMenu(Resources.get("shape")));

		EditorMenuBar.populateShapeMenu(menu, editor);

		addSeparator();

		add(
				editor.bind(Resources.get("edit"), GraphActions
						.getEditAction())).setEnabled(selected);

		addSeparator();

		add(editor.bind(Resources.get("selectVertices"), GraphActions
				.getSelectVerticesAction()));
		add(editor.bind(Resources.get("selectEdges"), GraphActions
				.getSelectEdgesAction()));

		addSeparator();

		add(editor.bind(Resources.get("selectAll"), GraphActions
				.getSelectAllAction()));
	}

}
