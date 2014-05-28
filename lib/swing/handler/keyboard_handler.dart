/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.handler;

//import javax.swing.ActionMap;
//import javax.swing.InputMap;
//import javax.swing.JComponent;
//import javax.swing.KeyStroke;
//import javax.swing.SwingUtilities;
//import javax.swing.TransferHandler;
//import javax.swing.UIManager;

/**
 * @author Administrator
 * 
 */
class KeyboardHandler {

  /**
	 * 
	 * @param graphComponent
	 */
  KeyboardHandler(GraphComponent graphComponent) {
    _installKeyboardActions(graphComponent);
  }

  /**
	 * Invoked as part from the boilerplate install block.
	 */
  void _installKeyboardActions(GraphComponent graphComponent) {
    InputMap inputMap = _getInputMap(JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT);
    SwingUtilities.replaceUIInputMap(graphComponent, JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT, inputMap);

    inputMap = _getInputMap(JComponent.WHEN_FOCUSED);
    SwingUtilities.replaceUIInputMap(graphComponent, JComponent.WHEN_FOCUSED, inputMap);
    SwingUtilities.replaceUIActionMap(graphComponent, _createActionMap());
  }

  /**
	 * Return JTree's input map.
	 */
  InputMap _getInputMap(int condition) {
    InputMap map = null;

    if (condition == JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT) {
      map = UIManager.get("ScrollPane.ancestorInputMap") as InputMap;
    } else if (condition == JComponent.WHEN_FOCUSED) {
      map = new InputMap();

      map.put(KeyStroke.getKeyStroke("F2"), "edit");
      map.put(KeyStroke.getKeyStroke("DELETE"), "delete");
      map.put(KeyStroke.getKeyStroke("UP"), "selectParent");
      map.put(KeyStroke.getKeyStroke("DOWN"), "selectChild");
      map.put(KeyStroke.getKeyStroke("RIGHT"), "selectNext");
      map.put(KeyStroke.getKeyStroke("LEFT"), "selectPrevious");
      map.put(KeyStroke.getKeyStroke("PAGE_DOWN"), "enterGroup");
      map.put(KeyStroke.getKeyStroke("PAGE_UP"), "exitGroup");
      map.put(KeyStroke.getKeyStroke("HOME"), "home");
      map.put(KeyStroke.getKeyStroke("ENTER"), "expand");
      map.put(KeyStroke.getKeyStroke("BACK_SPACE"), "collapse");
      map.put(KeyStroke.getKeyStroke("control A"), "selectAll");
      map.put(KeyStroke.getKeyStroke("control D"), "selectNone");
      map.put(KeyStroke.getKeyStroke("control X"), "cut");
      map.put(KeyStroke.getKeyStroke("CUT"), "cut");
      map.put(KeyStroke.getKeyStroke("control C"), "copy");
      map.put(KeyStroke.getKeyStroke("COPY"), "copy");
      map.put(KeyStroke.getKeyStroke("control V"), "paste");
      map.put(KeyStroke.getKeyStroke("PASTE"), "paste");
      map.put(KeyStroke.getKeyStroke("control G"), "group");
      map.put(KeyStroke.getKeyStroke("control U"), "ungroup");
      map.put(KeyStroke.getKeyStroke("control ADD"), "zoomIn");
      map.put(KeyStroke.getKeyStroke("control SUBTRACT"), "zoomOut");
    }

    return map;
  }

  /**
	 * Return the mapping between JTree's input map and JGraph's actions.
	 */
  ActionMap _createActionMap() {
    ActionMap map = UIManager.get("ScrollPane.actionMap") as ActionMap;

    map.put("edit", GraphActions.getEditAction());
    map.put("delete", GraphActions.getDeleteAction());
    map.put("home", GraphActions.getHomeAction());
    map.put("enterGroup", GraphActions.getEnterGroupAction());
    map.put("exitGroup", GraphActions.getExitGroupAction());
    map.put("collapse", GraphActions.getCollapseAction());
    map.put("expand", GraphActions.getExpandAction());
    map.put("toBack", GraphActions.getToBackAction());
    map.put("toFront", GraphActions.getToFrontAction());
    map.put("selectNone", GraphActions.getSelectNoneAction());
    map.put("selectAll", GraphActions.getSelectAllAction());
    map.put("selectNext", GraphActions.getSelectNextAction());
    map.put("selectPrevious", GraphActions.getSelectPreviousAction());
    map.put("selectParent", GraphActions.getSelectParentAction());
    map.put("selectChild", GraphActions.getSelectChildAction());
    map.put("cut", TransferHandler.getCutAction());
    map.put("copy", TransferHandler.getCopyAction());
    map.put("paste", TransferHandler.getPasteAction());
    map.put("group", GraphActions.getGroupAction());
    map.put("ungroup", GraphActions.getUngroupAction());
    map.put("zoomIn", GraphActions.getZoomInAction());
    map.put("zoomOut", GraphActions.getZoomOutAction());

    return map;
  }

}
