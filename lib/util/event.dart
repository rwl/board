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
  static const String DONE = "done";

  /**
   * 
   */
  static const String ADD_CELLS = "addCells";

  /**
   * 
   */
  static const String CELLS_ADDED = "cellsAdded";

  /**
   * 
   */
  static const String ALIGN_CELLS = "alignCells";

  /**
   * 
   */
  static const String CONNECT_CELL = "connectCell";

  /**
   * 
   */
  static const String CONNECT = "connect";

  /**
   * 
   */
  static const String CELL_CONNECTED = "cellConnected";

  /**
   * 
   */
  static const String FLIP_EDGE = "flipEdge";

  /**
   * 
   */
  static const String FOLD_CELLS = "foldCells";

  /**
   * 
   */
  static const String CELLS_FOLDED = "cellsFolded";

  /**
   * 
   */
  static const String GROUP_CELLS = "groupCells";

  /**
   * 
   */
  static const String UNGROUP_CELLS = "ungroupCells";

  /**
   * 
   */
  static const String REMOVE_CELLS_FROM_PARENT = "removeCellsFromParent";

  /**
   * 
   */
  static const String MOVE_CELLS = "moveCells";

  /**
   * 
   */
  static const String CELLS_MOVED = "cellsMoved";

  /**
   * 
   */
  static const String ORDER_CELLS = "orderCells";

  /**
   * 
   */
  static const String CELLS_ORDERED = "cellsOrdered";

  /**
   * 
   */
  static const String REMOVE_CELLS = "removeCells";

  /**
   * 
   */
  static const String CELLS_REMOVED = "cellsRemoved";

  /**
   * 
   */
  static const String REPAINT = "repaint";

  /**
   * 
   */
  static const String RESIZE_CELLS = "resizeCells";

  /**
   * 
   */
  static const String CELLS_RESIZED = "cellsResized";

  /**
   * 
   */
  static const String SPLIT_EDGE = "splitEdge";

  /**
   * 
   */
  static const String TOGGLE_CELLS = "toggleCells";

  /**
   * 
   */
  static const String CELLS_TOGGLED = "cellsToggled";

  /**
   * 
   */
  static const String UPDATE_CELL_SIZE = "updateCellSize";

  /**
   * 
   */
  static const String LABEL_CHANGED = "labelChanged";

  /**
   * 
   */
  static const String ADD_OVERLAY = "addOverlay";

  /**
   * 
   */
  static const String REMOVE_OVERLAY = "removeOverlay";

  /**
   * 
   */
  static const String BEFORE_PAINT = "beforePaint";

  /**
   * 
   */
  static const String PAINT = "paint";

  /**
   * 
   */
  static const String AFTER_PAINT = "afterPaint";

  /**
   * 
   */
  static const String START_EDITING = "startEditing";

  /**
   * 
   */
  static const String UNDO = "undo";

  /**
   * 
   */
  static const String REDO = "redo";

  /**
   * 
   */
  static const String UP = "up";

  /**
   * 
   */
  static const String DOWN = "down";

  /**
   * 
   */
  static const String SCALE = "scale";

  /**
   * 
   */
  static const String TRANSLATE = "translate";

  /**
   * 
   */
  static const String SCALE_AND_TRANSLATE = "scaleAndTranslate";

  /**
   * Holds the name for the change event. First and only argument in the
   * argument array is the list of mxAtomicGraphChanges that have been
   * executed on the model.
   */
  static const String CHANGE = "change";

  /**
   * Holds the name for the execute event. First and only argument in the
   * argument array is the mxAtomicGraphChange that has been executed on the 
   * model. This event fires before the change event.
   */
  static const String EXECUTE = "execute";

  /**
   * Holds the name for the beforeUndo event. First and only argument in the
   * argument array is the current edit that is currently in progress in the 
   * model. This event fires before notify is called on the currentEdit in
   * the model.
   */
  static const String BEFORE_UNDO = "beforeUndo";

  /**
   * Holds the name for the norify event. First and only argument in the
   * argument array is the list of mxAtomicGraphChanges that have been
   * executed on the model. This event fires after the change event.
   */
  static const String NOTIFY = "notify";

  /**
   * Holds the name for the beginUpdate event. This event has no arguments and
   * fires after the updateLevel has been changed in model.
   */
  static const String BEGIN_UPDATE = "beginUpdate";

  /**
   * Holds the name for the endUpdate event. This event has no arguments and fires
   * after the updateLevel has been changed in the model. First argument is the
   * currentEdit.
   */
  static const String END_UPDATE = "endUpdate";

  /**
   * 
   */
  static const String INSERT = "insert";

  /**
   * 
   */
  static const String ADD = "add";

  /**
   * 
   */
  static const String CLEAR = "clear";

  /**
   * 
   */
  static const String FIRED = "fired";

  /**
   * 
   */
  static const String SELECT = "select";

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
