/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.view;

//import java.awt.BorderLayout;
//import java.awt.Color;
//import java.awt.Component;
//import java.awt.awt.Rectangle;
//import java.awt.event.ActionEvent;
//import java.util.EventObject;

//import javax.swing.AbstractAction;
//import javax.swing.BorderFactory;
//import javax.swing.InputMap;
//import javax.swing.JEditorPane;
//import javax.swing.JPanel;
//import javax.swing.JScrollPane;
//import javax.swing.JTextArea;
//import javax.swing.KeyStroke;
//import javax.swing.text.JTextComponent;

abstract class ICellEditor {

  /**
   * Returns the cell that is currently being edited.
   */
  Object getEditingCell();

  /**
   * Starts editing the given cell.
   */
  void startEditing(Object cell, EventObject trigger);

  /**
   * Stops the current editing.
   */
  void stopEditing(bool cancel);

}

/**
 * To control this editor, use Graph.invokesStopCellEditing, Graph.
 * enterStopsCellEditing and Graph.escapeEnabled.
 */
class CellEditor implements ICellEditor {

  /**
	 * 
	 */
  static final String _CANCEL_EDITING = "cancel-editing";

  /**
	 * 
	 */
  static final String _INSERT_BREAK = "insert-break";

  /**
	 * 
	 */
  static final String _SUBMIT_TEXT = "submit-text";

  /**
	 * 
	 */
  static int DEFAULT_MIN_WIDTH = 100;

  /**
	 * 
	 */
  static int DEFAULT_MIN_HEIGHT = 60;

  /**
	 * 
	 */
  static double DEFAULT_MINIMUM_EDITOR_SCALE = 1;

  /**
	 * 
	 */
  GraphComponent _graphComponent;

  /**
	 * Defines the minimum scale to be used for the editor. Set this to
	 * 0 if the font size in the editor 
	 */
  double _minimumEditorScale = DEFAULT_MINIMUM_EDITOR_SCALE;

  /**
	 * 
	 */
  int _minimumWidth = DEFAULT_MIN_WIDTH;

  /**
	 * 
	 */
  int _minimumHeight = DEFAULT_MIN_HEIGHT;

  /**
	 * 
	 */
  /*transient*/ Object _editingCell;

  /**
	 * 
	 */
  /*transient*/ EventObject _trigger;

  /**
	 * 
	 */
  /*transient*/ JScrollPane _scrollPane;

  /**
	 * Holds the editor for plain text editing.
	 */
  /*transient*/ JTextArea _textArea;

  /**
	 * Holds the editor for HTML editing.
	 */
  /*transient*/ JEditorPane _editorPane;

  /**
	 * Specifies if the text content of the HTML body should be extracted
	 * before and after editing for HTML markup. Default is true.
	 */
  bool _extractHtmlBody = true;

  /**
	 * Specifies if linefeeds should be replaced with BREAKS before editing,
	 * and BREAKS should be replaced with linefeeds after editing. This
	 * value is ignored if extractHtmlBody is false. Default is true.
	 */
  bool _replaceLinefeeds = true;

  /**
	 * Specifies if shift ENTER should submit text if enterStopsCellEditing
	 * is true. Default is false.
	 */
  bool _shiftEnterSubmitsText = false;

  /**
	 * 
	 */
  /*transient*/ Object editorEnterActionMapKey;

  /**
	 * 
	 */
  /*transient*/ Object textEnterActionMapKey;

  /**
	 * 
	 */
  /*transient*/ KeyStroke escapeKeystroke = KeyStroke.getKeyStroke("ESCAPE");

  /**
	 * 
	 */
  /*transient*/ KeyStroke enterKeystroke = KeyStroke.getKeyStroke("ENTER");

  /**
	 * 
	 */
  /*transient*/ KeyStroke shiftEnterKeystroke = KeyStroke.getKeyStroke("shift ENTER");

  /**
	 * 
	 */
  AbstractAction _cancelEditingAction = new CancelEditingAction(this);

  /**
	 * 
	 */
  AbstractAction _textSubmitAction = new TextSubmitAction(this);

  /**
	 * 
	 */
  CellEditor(GraphComponent graphComponent) {
    this._graphComponent = graphComponent;

    // Creates the plain text editor
    _textArea = new JTextArea();
    _textArea.setBorder(BorderFactory.createEmptyBorder(3, 3, 3, 3));
    _textArea.setOpaque(false);

    // Creates the HTML editor
    _editorPane = new JEditorPane();
    _editorPane.setOpaque(false);
    _editorPane.setContentType("text/html");

    // Workaround for inserted linefeeds in HTML markup with
    // lines that are longar than 80 chars
    _editorPane.setEditorKit(new NoLinefeedHtmlEditorKit());

    // Creates the scollpane that contains the editor
    // FIXME: Cursor not visible when scrolling
    _scrollPane = new JScrollPane();
    _scrollPane.setBorder(BorderFactory.createEmptyBorder());
    _scrollPane.getViewport().setOpaque(false);
    _scrollPane.setVisible(false);
    _scrollPane.setOpaque(false);

    // Installs custom actions
    _editorPane.getActionMap().put(_CANCEL_EDITING, _cancelEditingAction);
    _textArea.getActionMap().put(_CANCEL_EDITING, _cancelEditingAction);
    _editorPane.getActionMap().put(_SUBMIT_TEXT, _textSubmitAction);
    _textArea.getActionMap().put(_SUBMIT_TEXT, _textSubmitAction);

    // Remembers the action map key for the enter keystroke
    editorEnterActionMapKey = _editorPane.getInputMap().get(enterKeystroke);
    textEnterActionMapKey = _editorPane.getInputMap().get(enterKeystroke);
  }

  /**
	 * Returns replaceHtmlLinefeeds
	 */
  bool isExtractHtmlBody() {
    return _extractHtmlBody;
  }

  /**
	 * Sets extractHtmlBody
	 */
  void setExtractHtmlBody(bool value) {
    _extractHtmlBody = value;
  }

  /**
	 * Returns replaceHtmlLinefeeds
	 */
  bool isReplaceHtmlLinefeeds() {
    return _replaceLinefeeds;
  }

  /**
	 * Sets replaceHtmlLinefeeds
	 */
  void setReplaceHtmlLinefeeds(bool value) {
    _replaceLinefeeds = value;
  }

  /**
	 * Returns shiftEnterSubmitsText
	 */
  bool isShiftEnterSubmitsText() {
    return _shiftEnterSubmitsText;
  }

  /**
	 * Sets shiftEnterSubmitsText
	 */
  void setShiftEnterSubmitsText(bool value) {
    _shiftEnterSubmitsText = value;
  }

  /**
	 * Installs the keyListener in the textArea and editorPane
	 * for handling the enter keystroke and updating the modified state.
	 */
  void _configureActionMaps() {
    InputMap editorInputMap = _editorPane.getInputMap();
    InputMap textInputMap = _textArea.getInputMap();

    // Adds handling for the escape key to cancel editing
    editorInputMap.put(escapeKeystroke, _cancelEditingAction);
    textInputMap.put(escapeKeystroke, _cancelEditingAction);

    // Adds handling for shift-enter and redirects enter to stop editing
    if (_graphComponent.isEnterStopsCellEditing()) {
      editorInputMap.put(shiftEnterKeystroke, editorEnterActionMapKey);
      textInputMap.put(shiftEnterKeystroke, textEnterActionMapKey);

      editorInputMap.put(enterKeystroke, _SUBMIT_TEXT);
      textInputMap.put(enterKeystroke, _SUBMIT_TEXT);
    } else {
      editorInputMap.put(enterKeystroke, editorEnterActionMapKey);
      textInputMap.put(enterKeystroke, textEnterActionMapKey);

      if (isShiftEnterSubmitsText()) {
        editorInputMap.put(shiftEnterKeystroke, _SUBMIT_TEXT);
        textInputMap.put(shiftEnterKeystroke, _SUBMIT_TEXT);
      } else {
        editorInputMap.remove(shiftEnterKeystroke);
        textInputMap.remove(shiftEnterKeystroke);
      }
    }
  }

  /**
	 * Returns the current editor or null if no editing is in progress.
	 */
  Component getEditor() {
    if (_textArea.getParent() != null) {
      return _textArea;
    } else if (_editingCell != null) {
      return _editorPane;
    }

    return null;
  }

  /**
	 * Returns true if the label bounds of the state should be used for the
	 * editor.
	 */
  bool _useLabelBounds(CellState state) {
    IGraphModel model = state.getView().getGraph().getModel();
    Geometry geometry = model.getGeometry(state.getCell());

    return ((geometry != null && geometry.getOffset() != null && !geometry.isRelative() && (geometry.getOffset().getX() != 0 || geometry.getOffset().getY() != 0)) || model.isEdge(state.getCell()));
  }

  /**
	 * Returns the bounds to be used for the editor.
	 */
  awt.Rectangle getEditorBounds(CellState state, double scale) {
    IGraphModel model = state.getView().getGraph().getModel();
    awt.Rectangle bounds = null;

    if (_useLabelBounds(state)) {
      bounds = state.getLabelBounds().getRectangle();
      bounds.height += 10;
    } else {
      bounds = state.getRectangle();
    }

    // Applies the horizontal and vertical label positions
    if (model.isVertex(state.getCell())) {
      String horizontal = Utils.getString(state.getStyle(), Constants.STYLE_LABEL_POSITION, Constants.ALIGN_CENTER);

      if (horizontal.equals(Constants.ALIGN_LEFT)) {
        bounds.x -= state.getWidth();
      } else if (horizontal.equals(Constants.ALIGN_RIGHT)) {
        bounds.x += state.getWidth();
      }

      String vertical = Utils.getString(state.getStyle(), Constants.STYLE_VERTICAL_LABEL_POSITION, Constants.ALIGN_MIDDLE);

      if (vertical.equals(Constants.ALIGN_TOP)) {
        bounds.y -= state.getHeight();
      } else if (vertical.equals(Constants.ALIGN_BOTTOM)) {
        bounds.y += state.getHeight();
      }
    }

    bounds.setSize(Math.max(bounds.getWidth(), math.round(_minimumWidth * scale)) as int, Math.max(bounds.getHeight(), math.round(_minimumHeight * scale)) as int);

    return bounds;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.swing.view.ICellEditor#startEditing(java.lang.Object, java.util.EventObject)
	 */
  void startEditing(Object cell, EventObject evt) {
    if (_editingCell != null) {
      stopEditing(true);
    }

    CellState state = _graphComponent.getGraph().getView().getState(cell);

    if (state != null) {
      _editingCell = cell;
      _trigger = evt;

      double scale = Math.max(_minimumEditorScale, _graphComponent.getGraph().getView().getScale());
      _scrollPane.setBounds(getEditorBounds(state, scale));
      _scrollPane.setVisible(true);

      String value = _getInitialValue(state, evt);
      JTextComponent currentEditor = null;

      // Configures the style of the in-place editor
      if (_graphComponent.getGraph().isHtmlLabel(cell)) {
        if (isExtractHtmlBody()) {
          value = Utils.getBodyMarkup(value, isReplaceHtmlLinefeeds());
        }

        _editorPane.setDocument(Utils.createHtmlDocumentObject(state.getStyle(), scale));
        _editorPane.setText(value);

        // Workaround for wordwrapping in editor pane
        // FIXME: Cursor not visible at end of line
        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);
        wrapper.add(_editorPane, BorderLayout.CENTER);
        _scrollPane.setViewportView(wrapper);

        currentEditor = _editorPane;
      } else {
        _textArea.setFont(Utils.getFont(state.getStyle(), scale));
        Color fontColor = Utils.getColor(state.getStyle(), Constants.STYLE_FONTCOLOR, Color.black);
        _textArea.setForeground(fontColor);
        _textArea.setText(value);

        _scrollPane.setViewportView(_textArea);
        currentEditor = _textArea;
      }

      _graphComponent.getGraphControl().add(_scrollPane, 0);

      if (_isHideLabel(state)) {
        _graphComponent.redraw(state);
      }

      currentEditor.revalidate();
      currentEditor.requestFocusInWindow();
      currentEditor.selectAll();

      _configureActionMaps();
    }
  }

  /**
	 * 
	 */
  bool _isHideLabel(CellState state) {
    return true;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.swing.view.ICellEditor#stopEditing(boolean)
	 */
  void stopEditing(bool cancel) {
    if (_editingCell != null) {
      _scrollPane.transferFocusUpCycle();
      Object cell = _editingCell;
      _editingCell = null;

      if (!cancel) {
        EventObject trig = _trigger;
        _trigger = null;
        _graphComponent.labelChanged(cell, getCurrentValue(), trig);
      } else {
        CellState state = _graphComponent.getGraph().getView().getState(cell);
        _graphComponent.redraw(state);
      }

      if (_scrollPane.getParent() != null) {
        _scrollPane.setVisible(false);
        _scrollPane.getParent().remove(_scrollPane);
      }

      _graphComponent.requestFocusInWindow();
    }
  }

  /**
	 * Gets the initial editing value for the given cell.
	 */
  String _getInitialValue(CellState state, EventObject trigger) {
    return _graphComponent.getEditingValue(state.getCell(), trigger);
  }

  /**
	 * Returns the current editing value.
	 */
  String getCurrentValue() {
    String result;

    if (_textArea.getParent() != null) {
      result = _textArea.getText();
    } else {
      result = _editorPane.getText();

      if (isExtractHtmlBody()) {
        result = Utils.getBodyMarkup(result, isReplaceHtmlLinefeeds());
      }
    }

    return result;
  }

  /*
	 * (non-Javadoc)
	 * @see graph.swing.view.ICellEditor#getEditingCell()
	 */
  Object getEditingCell() {
    return _editingCell;
  }

  /**
	 * @return the minimumEditorScale
	 */
  double getMinimumEditorScale() {
    return _minimumEditorScale;
  }

  /**
	 * @param minimumEditorScale the minimumEditorScale to set
	 */
  void setMinimumEditorScale(double minimumEditorScale) {
    this._minimumEditorScale = minimumEditorScale;
  }

  /**
	 * @return the minimumWidth
	 */
  int getMinimumWidth() {
    return _minimumWidth;
  }

  /**
	 * @param minimumWidth the minimumWidth to set
	 */
  void setMinimumWidth(int minimumWidth) {
    this._minimumWidth = minimumWidth;
  }

  /**
	 * @return the minimumHeight
	 */
  int getMinimumHeight() {
    return _minimumHeight;
  }

  /**
	 * @param minimumHeight the minimumHeight to set
	 */
  void setMinimumHeight(int minimumHeight) {
    this._minimumHeight = minimumHeight;
  }

}

class CancelEditingAction extends AbstractAction {

  final CellEditor cellEditor;

  CancelEditingAction(this.cellEditor);

  void actionPerformed(ActionEvent e) {
    cellEditor.stopEditing(true);
  }
}

class TextSubmitAction extends AbstractAction {

  final CellEditor cellEditor;

  TextSubmitAction(this.cellEditor);

  void actionPerformed(ActionEvent e) {
    cellEditor.stopEditing(false);
  }
}
