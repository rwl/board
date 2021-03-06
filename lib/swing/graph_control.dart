part of graph.swing;

//import java.awt.Dimension;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.RenderingHints;
//import java.awt.event.MouseAdapter;
//import java.awt.event.MouseEvent;

//import javax.swing.ImageIcon;
//import javax.swing.JComponent;

/**
 * 
 * @author gaudenz
 * 
 */
class GraphControl extends ui.FlowPanel {//ui.FocusWidget {//extends JComponent {
  
  /*final *///Element _element;

  final GraphComponent graphComponent;

  /**
   * Specifies a translation for painting. This should only be used during
   * mouse drags and must be reset after any interactive repaints. Default
   * is (0,0). This should not be null.
   */
  awt.Point translate = new awt.Point(0, 0);

  /**
   * @param graphComponent TODO
   * 
   */
  GraphControl(this.graphComponent) {
    addMouseUpHandler(new GraphControlMouseAdapter(this));
  }

  /**
   * Returns the translate.
   */
  awt.Point getTranslate() {
    return translate;
  }

  /**
   * Sets the translate.
   */
  void setTranslate(awt.Point value) {
    translate = value;
  }

  GraphComponent getGraphContainer() {
    return this.graphComponent;
  }

  /**
   * Overrides parent method to add extend flag for making the control
   * larger during previews.
   */
  void scrollRectToVisible(awt.Rectangle aRect, [bool extend=false]) {
    super.scrollRectToVisible(aRect);
    //this.graphComponent.ensureVisible(item);

    if (extend) {
      extendComponent(aRect);
    }
  }

  /**
   * Implements extension of the component in all directions. For
   * extension below the origin (into negative space) the translate will
   * temporaly be used and reset with the next mouse released event.
   */
  void extendComponent(awt.Rectangle rect) {
    int right = rect.x + rect.width;
    int bottom = rect.y + rect.height;

    awt.Dimension d = new awt.Dimension(getPreferredSize());
    awt.Dimension sp = this.graphComponent._getScaledPreferredSizeForGraph();
    Rect min = this.graphComponent._graph.getMinimumGraphSize();
    double scale = this.graphComponent._graph.getView().getScale();
    bool update = false;

    if (rect.x < 0) {
      translate.x = Math.max(translate.x, Math.max(0, -rect.x));
      d.width = sp.width;

      if (min != null) {
        d.width = Math.max(d.width, math.round(min.getWidth() * scale)) as int;
      }

      d.width += translate.x;
      update = true;
    } else if (right > getWidth()) {
      d.width = Math.max(right, getWidth());
      update = true;
    }

    if (rect.y < 0) {
      translate.y = Math.max(translate.y, Math.max(0, -rect.y));
      d.height = sp.height;

      if (min != null) {
        d.height = Math.max(d.height, math.round(min.getHeight() * scale)) as int;
      }

      d.height += translate.y;
      update = true;
    } else if (bottom > getHeight()) {
      d.height = Math.max(bottom, getHeight());
      update = true;
    }

    if (update) {
      setPreferredSize(d);
      setMinimumSize(d);
      revalidate();
    }
  }

  String getToolTipText(event.MouseEvent e) {
    String tip = this.graphComponent.getSelectionCellsHandler().getToolTipText(e);

    if (tip == null) {
      Object cell = this.graphComponent.getCellAt(e.getX(), e.getY());

      if (cell != null) {
        if (this.graphComponent.hitFoldingIcon(cell, e.getX(), e.getY())) {
          tip = Resources.get("collapse-expand");
        } else {
          tip = this.graphComponent._graph.getToolTipForCell(cell);
        }
      }
    }

    if (tip != null && tip.length > 0) {
      return tip;
    }

    return super.getToolTipText(e);
  }

  /**
   * Updates the preferred size for the given scale if the page size
   * should be preferred or the page is visible.
   */
  void updatePreferredSize() {
    double scale = this.graphComponent._graph.getView().getScale();
    awt.Dimension d = null;

    if (this.graphComponent._preferPageSize || this.graphComponent._pageVisible) {
      awt.Dimension page = this.graphComponent._getPreferredSizeForPage();

      if (!this.graphComponent._preferPageSize) {
        page.width += 2 * this.graphComponent.getHorizontalPageBorder();
        page.height += 2 * this.graphComponent.getVerticalPageBorder();
      }

      d = new awt.Dimension((page.width * scale), (page.height * scale));
    } else {
      d = this.graphComponent._getScaledPreferredSizeForGraph();
    }

    Rect min = this.graphComponent._graph.getMinimumGraphSize();

    if (min != null) {
      d.width = Math.max(d.width, math.round(min.getWidth() * scale)) as int;
      d.height = Math.max(d.height, math.round(min.getHeight() * scale)) as int;
    }

    if (!getPreferredSize().equals(d)) {
      setPreferredSize(d);
      setMinimumSize(d);
      revalidate();
    }
  }

  void paint(Graphics g) {
    g.translate(translate.x, translate.y);
    this.graphComponent._eventSource.fireEvent(new EventObj(Event.BEFORE_PAINT, ["g", g]));
    super.paint(g);
    this.graphComponent._eventSource.fireEvent(new EventObj(Event.AFTER_PAINT, ["g", g]));
    g.translate(-translate.x, -translate.y);
  }

  void paintComponent(Graphics g) {
    super.paintComponent(g);

    // Draws the background
    this.graphComponent._paintBackground(g);

    // Creates or destroys the triple buffer as needed
    if (this.graphComponent._tripleBuffered) {
      this.graphComponent.checkTripleBuffer();
    } else if (this.graphComponent._tripleBuffer != null) {
      this.graphComponent.destroyTripleBuffer();
    }

    // Paints the buffer in the canvas onto the dirty region
    if (this.graphComponent._tripleBuffer != null) {
      Utils.drawImageClip(g, this.graphComponent._tripleBuffer, this);
    } // Paints the graph directly onto the graphics
    else {
      Graphics2D g2 = g as Graphics2D;
      RenderingHints tmp = g2.getRenderingHints();

      // Sets the graphics in the canvas
      try {
        Utils.setAntiAlias(g2, this.graphComponent._antiAlias, this.graphComponent._textAntiAlias);
        drawGraph(g2, true);
      } finally {
        // Restores the graphics state
        g2.setRenderingHints(tmp);
      }
    }

    this.graphComponent._eventSource.fireEvent(new EventObj(Event.PAINT, ["g", g]));
  }

  void drawGraph(Graphics2D g, bool drawLabels) {
    Graphics2D previousGraphics = this.graphComponent._canvas.getGraphics();
    bool previousDrawLabels = this.graphComponent._canvas.isDrawLabels();
    awt.Point previousTranslate = this.graphComponent._canvas.getTranslate();
    double previousScale = this.graphComponent._canvas.getScale();

    try {
      this.graphComponent._canvas.setScale(this.graphComponent._graph.getView().getScale());
      this.graphComponent._canvas.setDrawLabels(drawLabels);
      this.graphComponent._canvas.setTranslate(0, 0);
      this.graphComponent._canvas.setGraphics(g);

      // Draws the graph using the graphics canvas
      drawFromRootCell();
    } finally {
      this.graphComponent._canvas.setScale(previousScale);
      this.graphComponent._canvas.setTranslate(previousTranslate.x, previousTranslate.y);
      this.graphComponent._canvas.setDrawLabels(previousDrawLabels);
      this.graphComponent._canvas.setGraphics(previousGraphics);
    }
  }

  /**
   * Hook to draw the root cell into the canvas.
   */
  void drawFromRootCell() {
    drawCell(this.graphComponent._canvas, this.graphComponent._graph.getModel().getRoot());
  }

  bool hitClip(Graphics2DCanvas canvas, CellState state) {
    awt.Rectangle rect = getExtendedCellBounds(state);

    return (rect == null || canvas.getGraphics().hitClip(rect.x, rect.y, rect.width, rect.height));
  }

  /**
   * @param state the cached state of the cell whose extended bounds are to be calculated
   * @return the bounds of the cell, including the label and shadow and allowing for rotation
   */
  awt.Rectangle getExtendedCellBounds(CellState state) {
    awt.Rectangle rect = null;

    // Takes rotation into account
    double rotation = Utils.getDouble(state.getStyle(), Constants.STYLE_ROTATION);
    Rect tmp = Utils.getBoundingBox(new Rect(state), rotation);

    // Adds scaled stroke width
    int border = (math.ceil(Utils.getDouble(state.getStyle(), Constants.STYLE_STROKEWIDTH) * this.graphComponent._graph.getView().getScale()) as int) + 1;
    tmp.grow(border);

    if (Utils.isTrue(state.getStyle(), Constants.STYLE_SHADOW)) {
      tmp.setWidth(tmp.getWidth() + Constants.SHADOW_OFFSETX);
      tmp.setHeight(tmp.getHeight() + Constants.SHADOW_OFFSETX);
    }

    // Adds the bounds of the label
    if (state.getLabelBounds() != null) {
      tmp.add(state.getLabelBounds());
    }

    rect = tmp.getRectangle();
    return rect;
  }

  /**
   * Draws the given cell onto the specified canvas. This is a modified
   * version of Graph.drawCell which paints the label only if the
   * corresponding cell is not being edited and invokes the cellDrawn hook
   * after all descendants have been painted.
   * 
   * @param canvas
   *            Canvas onto which the cell should be drawn.
   * @param cell
   *            Cell that should be drawn onto the canvas.
   */
  void drawCell(ICanvas canvas, Object cell) {
    CellState state = this.graphComponent._graph.getView().getState(cell);

    if (state != null && isCellDisplayable(state.getCell()) && (!(canvas is Graphics2DCanvas) || hitClip(canvas as Graphics2DCanvas, state))) {
      this.graphComponent._graph.drawState(canvas, state, cell != this.graphComponent._cellEditor.getEditingCell());
    }

    // Handles special ordering for edges (all in foreground
    // or background) or draws all children in order
    bool edgesFirst = this.graphComponent._graph.isKeepEdgesInBackground();
    bool edgesLast = this.graphComponent._graph.isKeepEdgesInForeground();

    if (edgesFirst) {
      drawChildren(cell, true, false);
    }

    drawChildren(cell, !edgesFirst && !edgesLast, true);

    if (edgesLast) {
      drawChildren(cell, true, false);
    }

    if (state != null) {
      cellDrawn(canvas, state);
    }
  }

  /**
   * Draws the child edges and/or all other children in the given cell
   * depending on the bool arguments.
   */
  void drawChildren(Object cell, bool edges, bool others) {
    IGraphModel model = this.graphComponent._graph.getModel();
    int childCount = model.getChildCount(cell);

    for (int i = 0; i < childCount; i++) {
      Object child = model.getChildAt(cell, i);
      bool isEdge = model.isEdge(child);

      if ((others && !isEdge) || (edges && isEdge)) {
        drawCell(this.graphComponent._canvas, model.getChildAt(cell, i));
      }
    }
  }

  void cellDrawn(ICanvas canvas, CellState state) {
    if (this.graphComponent.isFoldingEnabled() && canvas is Graphics2DCanvas) {
      IGraphModel model = this.graphComponent._graph.getModel();
      Graphics2DCanvas g2c = canvas as Graphics2DCanvas;
      Graphics2D g2 = g2c.getGraphics();

      // Draws the collapse/expand icons
      bool isEdge = model.isEdge(state.getCell());

      if (state.getCell() != this.graphComponent._graph.getCurrentRoot() && (model.isVertex(state.getCell()) || isEdge)) {
        ImageElement icon = this.graphComponent.getFoldingIcon(state);

        if (icon != null) {
          awt.Rectangle bounds = this.graphComponent.getFoldingIconBounds(state, icon);
          g2.drawImage(icon.getImage(), bounds.x, bounds.y, bounds.width, bounds.height, this);
        }
      }
    }
  }

  /**
   * Returns true if the given cell is not the current root or the root in
   * the model. This can be overridden to not render certain cells in the
   * graph display.
   */
  bool isCellDisplayable(Object cell) {
    return cell != this.graphComponent._graph.getView().getCurrentRoot() && cell != this.graphComponent._graph.getModel().getRoot();
  }
  
  /*Element getElement() {
    return _element;
  }*/

}

class GraphControlMouseAdapter extends event.MouseUpHandler {

  final GraphControl graphControl;

  GraphControlMouseAdapter(this.graphControl);

  void onMouseUp(event.MouseUpEvent e) {
    if (this.graphControl.translate.x != 0 || this.graphControl.translate.y != 0) {
      this.graphControl.translate = new awt.Point(0, 0);
      this.graphControl.repaint();
    }
  }
}
