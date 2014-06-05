part of graph.model;

class RootChange extends AtomicGraphModelChange {

  /**
   * Holds the new and previous root cell.
   */
  Object root, previous;

  RootChange([GraphModel model = null, Object root = null]) : super(model) {
    this.root = root;
    previous = root;
  }

  void setRoot(Object value) {
    root = value;
  }

  /**
   * Returns the root.
   */
  Object getRoot() {
    return root;
  }

  void setPrevious(Object value) {
    previous = value;
  }

  /**
   * Returns the previous.
   */
  Object getPrevious() {
    return previous;
  }

  /**
   * Changes the root of the model.
   */
  void execute() {
    root = previous;
    previous = (model as GraphModel)._rootChanged(previous);
  }

}
