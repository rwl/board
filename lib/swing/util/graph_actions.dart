/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.util;

//import java.awt.event.ActionEvent;

//import javax.swing.AbstractAction;
//import javax.swing.Action;

/**
 *
 */
class GraphActions
{

	/**
	 * 
	 */
	static final Action deleteAction = new DeleteAction("delete");

	/**
	 * 
	 */
	static final Action editAction = new EditAction("edit");

	/**
	 * 
	 */
	static final Action groupAction = new GroupAction("group");

	/**
	 * 
	 */
	static final Action ungroupAction = new UngroupAction("ungroup");

	/**
	 * 
	 */
	static final Action removeFromParentAction = new RemoveFromParentAction(
			"removeFromParent");

	/**
	 * 
	 */
	static final Action updateGroupBoundsAction = new UpdateGroupBoundsAction(
			"updateGroupBounds");

	/**
	 * 
	 */
	static final Action selectAllAction = new SelectAction("selectAll");

	/**
	 * 
	 */
	static final Action selectVerticesAction = new SelectAction("vertices");

	/**
	 * 
	 */
	static final Action selectEdgesAction = new SelectAction("edges");

	/**
	 * 
	 */
	static final Action selectNoneAction = new SelectAction("selectNone");

	/**
	 *
	 */
	static final Action selectNextAction = new SelectAction("selectNext");

	/**
	 * 
	 */
	static final Action selectPreviousAction = new SelectAction(
			"selectPrevious");

	/**
	 * 
	 */
	static final Action selectParentAction = new SelectAction("selectParent");

	/**
	 * 
	 */
	static final Action selectChildAction = new SelectAction("selectChild");

	/**
	 * 
	 */
	static final Action collapseAction = new FoldAction("collapse");

	/**
	 * 
	 */
	static final Action expandAction = new FoldAction("expand");

	/**
	 * 
	 */
	static final Action enterGroupAction = new DrillAction("enterGroup");

	/**
	 * 
	 */
	static final Action exitGroupAction = new DrillAction("exitGroup");

	/**
	 * 
	 */
	static final Action homeAction = new DrillAction("home");

	/**
	 * 
	 */
	static final Action zoomActualAction = new ZoomAction("actual");

	/**
	 * 
	 */
	static final Action zoomInAction = new ZoomAction("zoomIn");

	/**
	 * 
	 */
	static final Action zoomOutAction = new ZoomAction("zoomOut");

	/**
	 * 
	 */
	static final Action toBackAction = new LayerAction("toBack");

	/**
	 * 
	 */
	static final Action toFrontAction = new LayerAction("toFront");

	/**
	 * 
	 * @return the delete action
	 */
	static Action getDeleteAction()
	{
		return deleteAction;
	}

	/**
	 * 
	 * @return the edit action
	 */
	static Action getEditAction()
	{
		return editAction;
	}

	/**
	 * 
	 * @return the edit action
	 */
	static Action getGroupAction()
	{
		return groupAction;
	}

	/**
	 * 
	 * @return the edit action
	 */
	static Action getUngroupAction()
	{
		return ungroupAction;
	}

	/**
	 * 
	 * @return the edit action
	 */
	static Action getRemoveFromParentAction()
	{
		return removeFromParentAction;
	}

	/**
	 * 
	 * @return the edit action
	 */
	static Action getUpdateGroupBoundsAction()
	{
		return updateGroupBoundsAction;
	}

	/**
	 * 
	 * @return the select all action
	 */
	static Action getSelectAllAction()
	{
		return selectAllAction;
	}

	/**
	 * 
	 * @return the select vertices action
	 */
	static Action getSelectVerticesAction()
	{
		return selectVerticesAction;
	}

	/**
	 * 
	 * @return the select edges action
	 */
	static Action getSelectEdgesAction()
	{
		return selectEdgesAction;
	}

	/**
	 * 
	 * @return the select none action
	 */
	static Action getSelectNoneAction()
	{
		return selectNoneAction;
	}

	/**
	 * 
	 * @return the select next action
	 */
	static Action getSelectNextAction()
	{
		return selectNextAction;
	}

	/**
	 * 
	 * @return the select previous action
	 */
	static Action getSelectPreviousAction()
	{
		return selectPreviousAction;
	}

	/**
	 * 
	 * @return the select parent action
	 */
	static Action getSelectParentAction()
	{
		return selectParentAction;
	}

	/**
	 * 
	 * @return the select child action
	 */
	static Action getSelectChildAction()
	{
		return selectChildAction;
	}

	/**
	 * 
	 * @return the go into action
	 */
	static Action getEnterGroupAction()
	{
		return enterGroupAction;
	}

	/**
	 * 
	 * @return the go up action
	 */
	static Action getExitGroupAction()
	{
		return exitGroupAction;
	}

	/**
	 * 
	 * @return the home action
	 */
	static Action getHomeAction()
	{
		return homeAction;
	}

	/**
	 * 
	 * @return the collapse action
	 */
	static Action getCollapseAction()
	{
		return collapseAction;
	}

	/**
	 * 
	 * @return the expand action
	 */
	static Action getExpandAction()
	{
		return expandAction;
	}

	/**
	 * 
	 * @return the zoom actual action
	 */
	static Action getZoomActualAction()
	{
		return zoomActualAction;
	}

	/**
	 * 
	 * @return the zoom in action
	 */
	static Action getZoomInAction()
	{
		return zoomInAction;
	}

	/**
	 * 
	 * @return the zoom out action
	 */
	static Action getZoomOutAction()
	{
		return zoomOutAction;
	}

	/**
	 * 
	 * @return the action that moves cell(s) to the backmost layer
	 */
	static Action getToBackAction()
	{
		return toBackAction;
	}

	/**
	 * 
	 * @return the action that moves cell(s) to the frontmost layer
	 */
	static Action getToFrontAction()
	{
		return toFrontAction;
	}

	/**
	 * 
	 * @param e
	 * @return Returns the graph for the given action event.
	 */
	static /*final*/ Graph getGraph(ActionEvent e)
	{
		Object source = e.getSource();

		if (source is GraphComponent)
		{
			return (source as GraphComponent).getGraph();
		}

		return null;
	}

}


/**
 *
 */
class EditAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 4610112721356742702L;

    /**
     *
     * @param name
     */
    EditAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        if (e.getSource() is GraphComponent)
        {
            (e.getSource() as GraphComponent).startEditing();
        }
    }

}

/**
 *
 */
class DeleteAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = -8212339796803275529L;

    /**
     *
     * @param name
     */
    DeleteAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            graph.removeCells();
        }
    }

}

/**
 *
 */
class GroupAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = -4718086600089409092L;

    /**
     *
     * @param name
     */
    public GroupAction(String name) : super(name);

    /**
     *
     */
    int getGroupBorder(Graph graph)
    {
        return 2 * graph.getGridSize();

    }

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            graph.setSelectionCell(graph.groupCells(null,
                getGroupBorder(graph)));
        }
    }

}

/**
 *
 */
class UngroupAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 2247770767961318251L;

    /**
     *
     * @param name
     */
    UngroupAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            graph.setSelectionCells(graph.ungroupCells());
        }
    }

}

/**
 *
 */
class RemoveFromParentAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 7169443038859140811L;

    /**
     *
     * @param name
     */
    RemoveFromParentAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            graph.removeCellsFromParent();
        }
    }

}

/**
 *
 */
class UpdateGroupBoundsAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = -4718086600089409092L;

    /**
     *
     * @param name
     */
    UpdateGroupBoundsAction(String name) : super(name);

    /**
     *
     */
    int getGroupBorder(Graph graph)
    {
        return 2 * graph.getGridSize();
    }

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            graph.updateGroupBounds(null, getGroupBorder(graph));
        }
    }

}

/**
 *
 */
class LayerAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 562519299806253741L;

    /**
     *
     * @param name
     */
    LayerAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            bool toBack = getValue(Action.NAME).toString()
                .equalsIgnoreCase("toBack");
            graph.orderCells(toBack);
        }
    }

}

/**
 *
 */
class FoldAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 4078517503905239901L;

    /**
     *
     * @param name
     */
    FoldAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            bool collapse = getValue(Action.NAME).toString()
            .equalsIgnoreCase("collapse");
            graph.foldCells(collapse);
        }
    }

}

/**
 *
 */
class DrillAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 5464382323663870291L;

    /**
     *
     * @param name
     */
    DrillAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            String name = getValue(Action.NAME).toString();

            if (name.equalsIgnoreCase("enterGroup"))
            {
                graph.enterGroup();
            }
            else if (name.equalsIgnoreCase("exitGroup"))
            {
                graph.exitGroup();
            }
            else
            {
                graph.home();
            }
        }
    }

}

/**
 *
 */
class ZoomAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = -7500195051313272384L;

    /**
     *
     * @param name
     */
    ZoomAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Object source = e.getSource();

        if (source is GraphComponent)
        {
            String name = getValue(Action.NAME).toString();
            GraphComponent graphComponent = source as GraphComponent;

            if (name.equalsIgnoreCase("zoomIn"))
            {
                graphComponent.zoomIn();
            }
            else if (name.equalsIgnoreCase("zoomOut"))
            {
                graphComponent.zoomOut();
            }
            else
            {
                graphComponent.zoomActual();
            }
        }
    }

}

/**
 *
 */
class SelectAction extends AbstractAction
{

    /**
     *
     */
//    private static final long serialVersionUID = 6501585024845668187L;

    /**
     *
     * @param name
     */
    SelectAction(String name) : super(name);

    /**
     *
     */
    void actionPerformed(ActionEvent e)
    {
        Graph graph = getGraph(e);

        if (graph != null)
        {
            String name = getValue(Action.NAME).toString();

            if (name.equalsIgnoreCase("selectAll"))
            {
                graph.selectAll();
            }
            else if (name.equalsIgnoreCase("selectNone"))
            {
                graph.clearSelection();
            }
            else if (name.equalsIgnoreCase("selectNext"))
                {
                    graph.selectNextCell();
                }
                else if (name.equalsIgnoreCase("selectPrevious"))
                    {
                        graph.selectPreviousCell();
                    }
                    else if (name.equalsIgnoreCase("selectParent"))
                        {
                            graph.selectParentCell();
                        }
                        else if (name.equalsIgnoreCase("vertices"))
                            {
                                graph.selectVertices();
                            }
                            else if (name.equalsIgnoreCase("edges"))
                                {
                                    graph.selectEdges();
                                }
                                else
                                {
                                    graph.selectChildCell();
                                }
        }
    }

}
