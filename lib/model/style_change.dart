part of graph.model;

class StyleChange extends AtomicGraphModelChange {

  Object cell;

  String style, previous;

  StyleChange([GraphModel model = null, Object cell = null, String style = null]) : super(model) {
    this.cell = cell;
    this.style = style;
    this.previous = this.style;
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

  void setStyle(String value) {
    style = value;
  }

  /**
   * Returns the style.
   */
  String getStyle() {
    return style;
  }

  void setPrevious(String value) {
    previous = value;
  }

  /**
   * Returns the previous.
   */
  String getPrevious() {
    return previous;
  }

  /**
   * Changes the root of the model.
   */
  void execute() {
    style = previous;
    previous = (model as GraphModel)._styleForCellChanged(cell, previous);
  }

}
