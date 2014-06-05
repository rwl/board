part of graph.model;

class GeometryChange extends AtomicGraphModelChange {

  Object cell;

  Geometry geometry, previous;

  GeometryChange([GraphModel model = null, this.cell = null, this.geometry = null]) : super(model) {
    this.previous = this.geometry;
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

  void setGeometry(Geometry value) {
    geometry = value;
  }

  /**
   * Returns the geometry.
   */
  Geometry getGeometry() {
    return geometry;
  }

  void setPrevious(Geometry value) {
    previous = value;
  }

  /**
   * Returns the previous.
   */
  Geometry getPrevious() {
    return previous;
  }

  /**
   * Changes the root of the model.
   */
  void execute() {
    geometry = previous;
    previous = (model as GraphModel)._geometryForCellChanged(cell, previous);
  }

}
