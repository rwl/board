/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.util;

/**
 * Contains all global constants.
 */
class Event {

  /**
	 * 
	 */
  static final String DONE = "done";

  /**
	 * 
	 */
  static final String ADD_CELLS = "addCells";

  /**
	 * 
	 */
  static final String CELLS_ADDED = "cellsAdded";

  /**
	 * 
	 */
  static final String ALIGN_CELLS = "alignCells";

  /**
	 * 
	 */
  static final String CONNECT_CELL = "connectCell";

  /**
	 * 
	 */
  static final String CONNECT = "connect";

  /**
	 * 
	 */
  static final String CELL_CONNECTED = "cellConnected";

  /**
	 * 
	 */
  static final String FLIP_EDGE = "flipEdge";

  /**
	 * 
	 */
  static final String FOLD_CELLS = "foldCells";

  /**
	 * 
	 */
  static final String CELLS_FOLDED = "cellsFolded";

  /**
	 * 
	 */
  static final String GROUP_CELLS = "groupCells";

  /**
	 * 
	 */
  static final String UNGROUP_CELLS = "ungroupCells";

  /**
	 * 
	 */
  static final String REMOVE_CELLS_FROM_PARENT = "removeCellsFromParent";

  /**
	 * 
	 */
  static final String MOVE_CELLS = "moveCells";

  /**
	 * 
	 */
  static final String CELLS_MOVED = "cellsMoved";

  /**
	 * 
	 */
  static final String ORDER_CELLS = "orderCells";

  /**
	 * 
	 */
  static final String CELLS_ORDERED = "cellsOrdered";

  /**
	 * 
	 */
  static final String REMOVE_CELLS = "removeCells";

  /**
	 * 
	 */
  static final String CELLS_REMOVED = "cellsRemoved";

  /**
	 * 
	 */
  static final String REPAINT = "repaint";

  /**
	 * 
	 */
  static final String RESIZE_CELLS = "resizeCells";

  /**
	 * 
	 */
  static final String CELLS_RESIZED = "cellsResized";

  /**
	 * 
	 */
  static final String SPLIT_EDGE = "splitEdge";

  /**
	 * 
	 */
  static final String TOGGLE_CELLS = "toggleCells";

  /**
	 * 
	 */
  static final String CELLS_TOGGLED = "cellsToggled";

  /**
	 * 
	 */
  static final String UPDATE_CELL_SIZE = "updateCellSize";

  /**
	 * 
	 */
  static final String LABEL_CHANGED = "labelChanged";

  /**
	 * 
	 */
  static final String ADD_OVERLAY = "addOverlay";

  /**
	 * 
	 */
  static final String REMOVE_OVERLAY = "removeOverlay";

  /**
	 * 
	 */
  static final String BEFORE_PAINT = "beforePaint";

  /**
	 * 
	 */
  static final String PAINT = "paint";

  /**
	 * 
	 */
  static final String AFTER_PAINT = "afterPaint";

  /**
	 * 
	 */
  static final String START_EDITING = "startEditing";

  /**
	 * 
	 */
  static final String UNDO = "undo";

  /**
	 * 
	 */
  static final String REDO = "redo";

  /**
	 * 
	 */
  static final String UP = "up";

  /**
	 * 
	 */
  static final String DOWN = "down";

  /**
	 * 
	 */
  static final String SCALE = "scale";

  /**
	 * 
	 */
  static final String TRANSLATE = "translate";

  /**
	 * 
	 */
  static final String SCALE_AND_TRANSLATE = "scaleAndTranslate";

  /**
	 * Holds the name for the change event. First and only argument in the
	 * argument array is the list of mxAtomicGraphChanges that have been
	 * executed on the model.
	 */
  static final String CHANGE = "change";

  /**
	 * Holds the name for the execute event. First and only argument in the
	 * argument array is the mxAtomicGraphChange that has been executed on the 
	 * model. This event fires before the change event.
	 */
  static final String EXECUTE = "execute";

  /**
	 * Holds the name for the beforeUndo event. First and only argument in the
	 * argument array is the current edit that is currently in progress in the 
	 * model. This event fires before notify is called on the currentEdit in
	 * the model.
	 */
  static final String BEFORE_UNDO = "beforeUndo";

  /**
	 * Holds the name for the norify event. First and only argument in the
	 * argument array is the list of mxAtomicGraphChanges that have been
	 * executed on the model. This event fires after the change event.
	 */
  static final String NOTIFY = "notify";

  /**
	 * Holds the name for the beginUpdate event. This event has no arguments and
	 * fires after the updateLevel has been changed in model.
	 */
  static final String BEGIN_UPDATE = "beginUpdate";

  /**
	 * Holds the name for the endUpdate event. This event has no arguments and fires
	 * after the updateLevel has been changed in the model. First argument is the
	 * currentEdit.
	 */
  static final String END_UPDATE = "endUpdate";

  /**
	 * 
	 */
  static final String INSERT = "insert";

  /**
	 * 
	 */
  static final String ADD = "add";

  /**
	 * 
	 */
  static final String CLEAR = "clear";

  /**
	 * 
	 */
  static final String FIRED = "fired";

  /**
	 * 
	 */
  static final String SELECT = "select";

  /**
	 * Holds the name for the mark event, which fires after a cell has been
	 * marked. First and only argument in the array is the cell state that has
	 * been marked or null, if no state has been marked.
	 * 
	 * To add a mark listener to the cell marker:
	 * 
	 * <code>
	 * addListener(
	 *   Event.MARK, new mxEventListener()
	 *   {
	 *     public void invoke(Object source, List<Object> args)
	 *     {
	 *       cellMarked((CellMarker) source, (CellState) args[0]);
	 *     }
	 *   });
	 * </code>
	 */
  static String MARK = "mark";

  /**
	 * 
	 */
  static String ROOT = "root";

  /**
	 * 
	 */
  static String LAYOUT_CELLS = "layoutCells";

  /**
	 * 
	 */
  static String START = "start";

  /**
	 * 
	 */
  static String CONTINUE = "continue";

  /**
	 * 
	 */
  static String STOP = "stop";

}
