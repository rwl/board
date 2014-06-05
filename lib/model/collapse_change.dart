part of graph.model;

class CollapseChange extends AtomicGraphModelChange {

  Object cell;

  bool collapsed, previous;

  CollapseChange([GraphModel model = null, Object cell = null, bool collapsed = false]) : super(model) {
    this.cell = cell;
    this.collapsed = collapsed;
    this.previous = this.collapsed;
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

  void setCollapsed(bool value) {
    collapsed = value;
  }

  bool isCollapsed() {
    return collapsed;
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
    collapsed = previous;
    previous = (model as GraphModel)._collapsedStateForCellChanged(cell, previous);
  }

}
