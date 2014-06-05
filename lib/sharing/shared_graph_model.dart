/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.sharing;


//import org.w3c.dom.Node;

/**
 * Implements a diagram that may be shared among multiple sessions.
 */
class SharedGraphModel extends SharedState {

  /**
   * 
   */
  GraphModel _model;

  /**
   * 
   */
  Codec _codec;

  /**
   * Whether remote changes should be significant in the
   * local command history. Default is true.
   */
  bool _significantRemoteChanges = true;

  /**
   * Constructs a new diagram with the given model.
   * 
   * @param model Initial model of the diagram.
   */
  SharedGraphModel(GraphModel model) : super(null) // Overrides getState
  {
    _codec = new SharedGraphModelCodec(this);
    this._model = model;
  }

  /**
   * @return the model
   */
  GraphModel getModel() {
    return _model;
  }

  /**
   * @return the significantRemoteChanges
   */
  bool isSignificantRemoteChanges() {
    return _significantRemoteChanges;
  }

  /**
   * @param significantRemoteChanges the significantRemoteChanges to set
   */
  void setSignificantRemoteChanges(bool significantRemoteChanges) {
    this._significantRemoteChanges = significantRemoteChanges;
  }

  /**
   * Returns the initial state of the diagram.
   */
  String getState() {
    return XmlUtils.getXml(_codec.encode(_model));
  }

  /**
   * 
   */
  /*synchronized*/ void addDelta(String edits) {
    // Edits are not added to the history. They are sent straight out to
    // all sessions and the model is updated so the next session will get
    // these edits via the new state of the model in getState.
  }

  /**
   * 
   */
  String _processEdit(Node node) {
    List<AtomicGraphModelChange> changes = _decodeChanges(node.firstChild);

    if (changes.length > 0) {
      UndoableEdit edit = _createUndoableEdit(changes);

      // No notify event here to avoid the edit from being encoded and transmitted
      // LATER: Remove changes property (deprecated)
      _model.fireEvent(new EventObj(Event.CHANGE, ["edit", edit, "changes", changes]));
      _model.fireEvent(new EventObj(Event.UNDO, ["edit", edit]));
      fireEvent(new EventObj(Event.FIRED, ["edit", edit]));
    }

    return super._processEdit(node);
  }

  /**
   * Creates a new UndoableEdit that implements the notify function to fire
   * a change and notify event via the model.
   */
  UndoableEdit _createUndoableEdit(List<AtomicGraphModelChange> changes) {
    throw new Exception();
    UndoableEdit edit = new SharedGraphModelUndoableEdit(this, _significantRemoteChanges);

    for (int i = 0; i < changes.length; i++) {
      edit.add(changes[i]);
    }

    return edit;
  }

  /**
   * Adds removed cells to the codec object lookup for references to the removed
   * cells after this point in time.
   */
  List<AtomicGraphModelChange> _decodeChanges(Node node) {
    // Updates the document in the existing codec
    _codec.setDocument(node.ownerDocument);

    //LinkedList<AtomicGraphModelChange> changes = new LinkedList<AtomicGraphModelChange>();
    Queue<AtomicGraphModelChange> changes = new Queue<AtomicGraphModelChange>();

    while (node != null) {
      Object change;

      if (node.nodeName == "RootChange") {
        // Handles the special case were no ids should be
        // resolved in the existing model. This change will
        // replace all registered ids and cells from the
        // model and insert a new cell hierarchy instead.
        Codec tmp = new Codec(node.ownerDocument);
        change = tmp.decode(node);
      } else {
        change = _codec.decode(node);
      }

      if (change is AtomicGraphModelChange) {
        AtomicGraphModelChange ac = change as AtomicGraphModelChange;

        ac.setModel(_model);
        ac.execute();

        // Workaround for references not being resolved if cells have
        // been removed from the model prior to being referenced. This
        // adds removed cells in the codec object lookup table.
        if (ac is ChildChange && ac.getParent() == null) {
          cellRemoved(ac.getChild());
        }

        changes.add(ac);
      }

      node = node.nextNode;
    }

    return new List<AtomicGraphModelChange>.from(changes);
  }

  /**
   * Adds removed cells to the codec object lookup for references to the removed
   * cells after this point in time.
   */
  void cellRemoved(Object cell) {
    _codec.putObject((cell as ICell).getId(), cell);

    int childCount = _model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      cellRemoved(_model.getChildAt(cell, i));
    }
  }

}

class SharedGraphModelCodec extends Codec {

  SharedGraphModel _sharedGraphModel;

  SharedGraphModelCodec(this._sharedGraphModel);

  Object lookup(String id)
  {
    return _sharedGraphModel._model.getCell(id);
  }
}

class SharedGraphModelUndoableEdit extends UndoableEdit {
  
  SharedGraphModelUndoableEdit(Object source, bool significant) : super(source, significant);
  
  void dispatch()
  {
    // LATER: Remove changes property (deprecated)
    (source as GraphModel).fireEvent(new EventObj(
        Event.CHANGE, ["edit", this, "changes", changes]));
    (source as GraphModel).fireEvent(new EventObj(
        Event.NOTIFY, ["edit", this, "changes", changes]));
  }
}