part of graph.model;

class ValueChange extends AtomicGraphModelChange {

  Object cell, value, previous;

  ValueChange([GraphModel model = null, Object cell = null,
              Object value = null]) : super(model) {
    this.cell = cell;
    this.value = value;
    this.previous = this.value;
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

  void setValue(Object value) {
    this.value = value;
  }

  /**
   * Returns the value.
   */
  Object getValue() {
    return value;
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
    value = previous;
    previous = (model as GraphModel)._valueForCellChanged(cell, previous);
  }

}
