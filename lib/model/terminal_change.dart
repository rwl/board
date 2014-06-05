part of graph.model;

class TerminalChange extends AtomicGraphModelChange {

  Object cell, terminal, previous;

  bool source;

  TerminalChange([GraphModel model = null, Object cell = null,
                 Object terminal = null, bool source = false]) : super(model) {
    this.cell = cell;
    this.terminal = terminal;
    this.previous = this.terminal;
    this.source = source;
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

  void setTerminal(Object value) {
    terminal = value;
  }

  /**
   * Returns the terminal.
   */
  Object getTerminal() {
    return terminal;
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

  void setSource(bool value) {
    source = value;
  }

  /**
   * Returns the source.
   */
  bool isSource() {
    return source;
  }

  /**
   * Changes the root of the model.
   */
  void execute() {
    terminal = previous;
    previous = (model as GraphModel)._terminalForCellChanged(cell, previous, source);
  }

}
