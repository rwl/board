part of graph.model;

class VisibleChange extends AtomicGraphModelChange {

  Object cell;

  bool visible, previous;

  VisibleChange([GraphModel model = null, Object cell = null,
                bool visible = false]) : super(model) {
    this.cell = cell;
    this.visible = visible;
    this.previous = this.visible;
  }

  void setCell(Object value) {
    cell = value;
  }

  /**
   * Returns the cell.
   */
  Object getCell() {
    return cell;
  }

  void setVisible(bool value) {
    visible = value;
  }

  /**
   * Returns true if visible.
   */
  bool isVisible() {
    return visible;
  }

  void setPrevious(bool value) {
    previous = value;
  }

  /**
   * Returns the previous.
   */
  bool getPrevious() {
    return previous;
  }

  /**
   * Changes the root of the model.
   */
  void execute() {
    visible = previous;
    previous = (model as GraphModel)._visibleStateForCellChanged(cell, previous);
  }

}
