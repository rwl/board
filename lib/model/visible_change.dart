part of graph.model;

class VisibleChange extends AtomicGraphModelChange {

  /**
	 *
	 */
  Object cell;

  /**
	 * 
	 */
  bool visible, previous;

  /**
	 * 
	 */
  //	VisibleChange()
  //	{
  //		this(null, null, false);
  //	}

  /**
	 * 
	 */
  VisibleChange([GraphModel model = null, Object cell = null, bool visible = false]) : super(model) {
    this.cell = cell;
    this.visible = visible;
    this.previous = this.visible;
  }

  /**
	 * 
	 */
  void setCell(Object value) {
    cell = value;
  }

  /**
	 * @return the cell
	 */
  Object getCell() {
    return cell;
  }

  /**
	 * 
	 */
  void setVisible(bool value) {
    visible = value;
  }

  /**
	 * @return the visible
	 */
  bool isVisible() {
    return visible;
  }

  /**
	 * 
	 */
  void setPrevious(bool value) {
    previous = value;
  }

  /**
	 * @return the previous
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
