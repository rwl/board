/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Dimension;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.Rectangle;
//import java.awt.Stroke;
//import java.awt.event.AdjustmentEvent;
//import java.awt.event.AdjustmentListener;
//import java.awt.event.ComponentAdapter;
//import java.awt.event.ComponentEvent;
//import java.awt.event.ComponentListener;
//import java.awt.geom.AffineTransform;
//import java.awt.image.BufferedImage;

//import javax.swing.JComponent;

/**
 * An outline view for a specific graph component.
 */
class GraphOutline {//extends JComponent {

  static awt.Color DEFAULT_ZOOMHANDLE_FILL = new awt.Color(0, 255, 255);

  GraphComponent _graphComponent;

  /**
   * TODO: Not yet implemented.
   */
  image.Image _tripleBuffer;

  /**
   * Holds the graphics of the triple buffer.
   */
  Graphics2D _tripleBufferGraphics;

  /**
   * True if the triple buffer needs a full repaint.
   */
  bool _repaintBuffer = false;

  /**
   * Clip of the triple buffer to be repainted.
   */
  Rect _repaintClip = null;

  bool _tripleBuffered = true;

  awt.Rectangle _finderBounds = new awt.Rectangle();

  awt.Point _zoomHandleLocation = null;

  bool _finderVisible = true;

  bool _zoomHandleVisible = true;

  bool _useScaledInstance = false;

  bool _antiAlias = false;

  bool _drawLabels = false;

  /**
   * Specifies if the outline should be zoomed to the page if the graph
   * component is in page layout mode. Default is true.
   */
  bool _fitPage = true;

  /**
   * Not yet implemented.
   * 
   * Border to add around the page bounds if wholePage is true.
   * Default is 4.
   */
  int _outlineBorder = 10;

  MouseTracker _tracker;

  double _scale = 1;

  awt.Point _translate = new awt.Point();

  /*transient*/ bool _zoomGesture = false;

  IEventListener _repaintHandler;

  ComponentListener _componentHandler;

  AdjustmentListener _adjustmentHandler;

  GraphOutline(GraphComponent graphComponent) {
    _tracker = new MouseTracker(this);
    _repaintHandler = (Object source, EventObj evt) {
      updateScaleAndTranslate();
      Rect dirty = evt.getProperty("region") as Rect;

      if (dirty != null) {
        _repaintClip = new Rect(dirty);
      } else {
        _repaintBuffer = true;
      }

      if (dirty != null) {
        updateFinder(true);

        dirty.grow(1 / _scale);

        dirty.setX(dirty.getX() * _scale + _translate.x);
        dirty.setY(dirty.getY() * _scale + _translate.y);
        dirty.setWidth(dirty.getWidth() * _scale);
        dirty.setHeight(dirty.getHeight() * _scale);

        repaint(dirty.getRectangle());
      } else {
        updateFinder(false);
        repaint();
      }
    };
    _componentHandler = ResizedComponentAdapter(this);
    _adjustmentHandler = new AdjustmentValueListener(this);

    addComponentListener(_componentHandler);
    addMouseMotionListener(_tracker);
    addMouseListener(_tracker);
    setGraphComponent(graphComponent);
    setEnabled(true);
    setOpaque(true);
  }

  /**
   * Fires a property change event for <code>tripleBuffered</code>.
   * 
   * @param tripleBuffered the tripleBuffered to set
   */
  void setTripleBuffered(bool tripleBuffered) {
    bool oldValue = this._tripleBuffered;
    this._tripleBuffered = tripleBuffered;

    if (!tripleBuffered) {
      destroyTripleBuffer();
    }

    firePropertyChange("tripleBuffered", oldValue, tripleBuffered);
  }

  bool isTripleBuffered() {
    return _tripleBuffered;
  }

  /**
   * Fires a property change event for <code>drawLabels</code>.
   * 
   * @param drawLabels the drawLabels to set
   */
  void setDrawLabels(bool drawLabels) {
    bool oldValue = this._drawLabels;
    this._drawLabels = drawLabels;
    repaintTripleBuffer(null);

    firePropertyChange("drawLabels", oldValue, drawLabels);
  }

  bool isDrawLabels() {
    return _drawLabels;
  }

  /**
   * Fires a property change event for <code>antiAlias</code>.
   * 
   * @param antiAlias the antiAlias to set
   */
  void setAntiAlias(bool antiAlias) {
    bool oldValue = this._antiAlias;
    this._antiAlias = antiAlias;
    repaintTripleBuffer(null);

    firePropertyChange("antiAlias", oldValue, antiAlias);
  }

  /**
   * @return the antiAlias
   */
  bool isAntiAlias() {
    return _antiAlias;
  }

  void setVisible(bool visible) {
    super.setVisible(visible);

    // Frees memory if the outline is hidden
    if (!visible) {
      destroyTripleBuffer();
    }
  }

  void setFinderVisible(bool visible) {
    _finderVisible = visible;
  }

  void setZoomHandleVisible(bool visible) {
    _zoomHandleVisible = visible;
  }

  /**
   * Fires a property change event for <code>fitPage</code>.
   * 
   * @param fitPage the fitPage to set
   */
  void setFitPage(bool fitPage) {
    bool oldValue = this._fitPage;
    this._fitPage = fitPage;

    if (updateScaleAndTranslate()) {
      _repaintBuffer = true;
      updateFinder(false);
    }

    firePropertyChange("fitPage", oldValue, fitPage);
  }

  bool isFitPage() {
    return _fitPage;
  }

  GraphComponent getGraphComponent() {
    return _graphComponent;
  }

  /**
   * Fires a property change event for <code>graphComponent</code>.
   * 
   * @param graphComponent the graphComponent to set
   */
  void setGraphComponent(GraphComponent graphComponent) {
    GraphComponent oldValue = this._graphComponent;

    if (this._graphComponent != null) {
      this._graphComponent.getGraph().removeListener(_repaintHandler);
      this._graphComponent.getGraphControl().removeComponentListener(_componentHandler);
      this._graphComponent.getHorizontalScrollBar().removeAdjustmentListener(_adjustmentHandler);
      this._graphComponent.getVerticalScrollBar().removeAdjustmentListener(_adjustmentHandler);
    }

    this._graphComponent = graphComponent;

    if (this._graphComponent != null) {
      this._graphComponent.getGraph().addListener(Event.REPAINT, _repaintHandler);
      this._graphComponent.getGraphControl().addComponentListener(_componentHandler);
      this._graphComponent.getHorizontalScrollBar().addAdjustmentListener(_adjustmentHandler);
      this._graphComponent.getVerticalScrollBar().addAdjustmentListener(_adjustmentHandler);
    }

    if (updateScaleAndTranslate()) {
      _repaintBuffer = true;
      repaint();
    }

    firePropertyChange("graphComponent", oldValue, graphComponent);
  }

  /**
   * Checks if the triple buffer exists and creates a new one if
   * it does not. Also compares the size of the buffer with the
   * size of the graph and drops the buffer if it has a
   * different size.
   */
  void checkTripleBuffer() {
    if (_tripleBuffer != null) {
      if (_tripleBuffer.getWidth() != getWidth() || _tripleBuffer.getHeight() != getHeight()) {
        // Resizes the buffer (destroys existing and creates new)
        destroyTripleBuffer();
      }
    }

    if (_tripleBuffer == null) {
      _createTripleBuffer(getWidth(), getHeight());
    }
  }

  /**
   * Creates the tripleBufferGraphics and tripleBuffer for the given
   * dimension and draws the complete graph onto the triplebuffer.
   * 
   * @param width
   * @param height
   */
  void _createTripleBuffer(int width, int height) {
    try {
      _tripleBuffer = Utils.createBufferedImage(width, height, null);
      _tripleBufferGraphics = _tripleBuffer.createGraphics();

      // Repaints the complete buffer
      repaintTripleBuffer(null);
    } on OutOfMemoryError catch (error) {
      // ignore
    }
  }

  /**
   * Destroys the tripleBuffer and tripleBufferGraphics objects.
   */
  void destroyTripleBuffer() {
    if (_tripleBuffer != null) {
      _tripleBuffer = null;
      _tripleBufferGraphics.dispose();
      _tripleBufferGraphics = null;
    }
  }

  /**
   * Clears and repaints the triple buffer at the given rectangle or repaints
   * the complete buffer if no rectangle is specified.
   * 
   * @param clip
   */
  void repaintTripleBuffer(awt.Rectangle clip) {
    if (_tripleBuffered && _tripleBufferGraphics != null) {
      if (clip == null) {
        clip = new awt.Rectangle(_tripleBuffer.getWidth(), _tripleBuffer.getHeight());
      }

      // Clears and repaints the dirty rectangle using the
      // graphics canvas of the graph component as a renderer
      Utils.clearRect(_tripleBufferGraphics, clip, null);
      _tripleBufferGraphics.setClip(clip);
      paintGraph(_tripleBufferGraphics);
      _tripleBufferGraphics.setClip(null);

      _repaintBuffer = false;
      _repaintClip = null;
    }
  }

  void updateFinder(bool repaint) {
    awt.Rectangle rect = _graphComponent.getViewport().getViewRect();

    int x = math.round(rect.x * _scale) as int;
    int y = math.round(rect.y * _scale) as int;
    int w = (math.round((rect.x + rect.width) * _scale) as int) - x;
    int h = (math.round((rect.y + rect.height) * _scale) as int) - y;

    updateFinderBounds(new awt.Rectangle(x + _translate.x, y + _translate.y, w + 1, h + 1), repaint);
  }

  void updateFinderBounds(awt.Rectangle bounds, bool repaint) {
    if (bounds != null && bounds != _finderBounds) {
      awt.Rectangle old = new awt.Rectangle.from(_finderBounds);
      _finderBounds = bounds;

      // LATER: Fix repaint region to be smaller
      if (repaint) {
        old = old.union(_finderBounds);
        old.grow(3, 3);
        repaint(old);
      }
    }
  }

  void paintComponent(Graphics g) {
    super.paintComponent(g);
    _paintBackground(g);

    if (_graphComponent != null) {
      // Creates or destroys the triple buffer as needed
      if (_tripleBuffered) {
        checkTripleBuffer();
      } else if (_tripleBuffer != null) {
        destroyTripleBuffer();
      }

      // Updates the dirty region from the buffered graph image
      if (_tripleBuffer != null) {
        if (_repaintBuffer) {
          repaintTripleBuffer(null);
        } else if (_repaintClip != null) {
          _repaintClip.grow(1 / _scale);

          _repaintClip.setX(_repaintClip.getX() * _scale + _translate.x);
          _repaintClip.setY(_repaintClip.getY() * _scale + _translate.y);
          _repaintClip.setWidth(_repaintClip.getWidth() * _scale);
          _repaintClip.setHeight(_repaintClip.getHeight() * _scale);

          repaintTripleBuffer(_repaintClip.getRectangle());
        }

        Utils.drawImageClip(g, _tripleBuffer, this);
      } // Paints the graph directly onto the graphics
      else {
        paintGraph(g);
      }

      _paintForeground(g);
    }
  }

  /**
   * Paints the background.
   */
  void _paintBackground(Graphics g) {
    if (_graphComponent != null) {
      Graphics2D g2 = g as Graphics2D;
      AffineTransform tx = g2.getTransform();

      try {
        // Draws the background of the outline if a graph exists
        g.setColor(_graphComponent.getPageBackgroundColor());
        Utils.fillClippedRect(g, 0, 0, getWidth(), getHeight());

        g2.translate(_translate.x, _translate.y);
        g2.scale(_scale, _scale);

        // Draws the scaled page background
        if (!_graphComponent.isPageVisible()) {
          awt.Color bg = _graphComponent.getBackground();

          if (_graphComponent.getViewport().isOpaque()) {
            bg = _graphComponent.getViewport().getBackground();
          }

          g.setColor(bg);
          awt.Dimension size = _graphComponent.getGraphControl().getSize();

          // Paints the background of the drawing surface
          Utils.fillClippedRect(g, 0, 0, size.width, size.height);
          g.setColor(g.getColor().darker().darker());
          g.drawRect(0, 0, size.width, size.height);
        } else {
          // Paints the page background using the graphics scaling
          _graphComponent._paintBackgroundPage(g);
        }
      } finally {
        g2.setTransform(tx);
      }
    } else {
      // Draws the background of the outline if no graph exists
      g.setColor(getBackground());
      Utils.fillClippedRect(g, 0, 0, getWidth(), getHeight());
    }
  }

  /**
   * Paints the graph outline.
   */
  void paintGraph(Graphics g) {
    if (_graphComponent != null) {
      Graphics2D g2 = g as Graphics2D;
      AffineTransform tx = g2.getTransform();

      try {
        awt.Point tr = _graphComponent.getGraphControl().getTranslate();
        g2.translate(_translate.x + tr.getX() * _scale, _translate.y + tr.getY() * _scale);
        g2.scale(_scale, _scale);

        // Draws the scaled graph
        _graphComponent.getGraphControl().drawGraph(g2, _drawLabels);
      } finally {
        g2.setTransform(tx);
      }
    }
  }

  /**
   * Paints the foreground. Foreground is dynamic and should never be made
   * part of the triple buffer. It is painted on top of the buffer.
   */
  void _paintForeground(Graphics g) {
    if (_graphComponent != null) {
      Graphics2D g2 = g as Graphics2D;

      Stroke stroke = g2.getStroke();
      g.setColor(Color.BLUE);
      g2.setStroke(new BasicStroke(3));
      g.drawRect(_finderBounds.x, _finderBounds.y, _finderBounds.width, _finderBounds.height);

      if (_zoomHandleVisible) {
        g2.setStroke(stroke);
        g.setColor(DEFAULT_ZOOMHANDLE_FILL);
        g.fillRect(_finderBounds.x + _finderBounds.width - 6, _finderBounds.y + _finderBounds.height - 6, 8, 8);
        g.setColor(awt.Color.BLACK);
        g.drawRect(_finderBounds.x + _finderBounds.width - 6, _finderBounds.y + _finderBounds.height - 6, 8, 8);
      }
    }
  }

  /**
   * Returns true if the scale or translate has changed.
   */
  bool updateScaleAndTranslate() {
    double newScale = 1;
    int dx = 0;
    int dy = 0;

    if (this._graphComponent != null) {
      awt.Dimension graphSize = _graphComponent.getGraphControl().getSize();
      awt.Dimension outlineSize = getSize();

      int gw = graphSize.getWidth() as int;
      int gh = graphSize.getHeight() as int;

      if (gw > 0 && gh > 0) {
        bool magnifyPage = _graphComponent.isPageVisible() && isFitPage() && _graphComponent.getHorizontalScrollBar().isVisible() && _graphComponent.getVerticalScrollBar().isVisible();
        double graphScale = _graphComponent.getGraph().getView().getScale();
        Point2d trans = _graphComponent.getGraph().getView().getTranslate();

        int w = (outlineSize.getWidth() as int) - 2 * _outlineBorder;
        int h = (outlineSize.getHeight() as int) - 2 * _outlineBorder;

        if (magnifyPage) {
          gw -= 2 * math.round(trans.getX() * graphScale);
          gh -= 2 * math.round(trans.getY() * graphScale);
        }

        newScale = Math.min((w as double) / gw, (h as double) / gh);

        dx += math.round((outlineSize.getWidth() - gw * newScale) / 2) as int;
        dy += math.round((outlineSize.getHeight() - gh * newScale) / 2) as int;

        if (magnifyPage) {
          dx -= math.round(trans.getX() * newScale * graphScale);
          dy -= math.round(trans.getY() * newScale * graphScale);
        }
      }
    }

    if (newScale != _scale || _translate.x != dx || _translate.y != dy) {
      _scale = newScale;
      _translate.setLocation(dx, dy);

      return true;
    } else {
      return false;
    }
  }

}

class ResizedComponentAdapter {//extends ComponentAdapter {

  final GraphOutline graphOutline;

  ResizedComponentAdapter(this.graphOutline);

  void componentResized(ComponentEvent e) {
    if (graphOutline.updateScaleAndTranslate()) {
      graphOutline.repaintBuffer = true;
      graphOutline.updateFinder(false);
      graphOutline.repaint();
    } else {
      graphOutline.updateFinder(true);
    }
  }
}

class AdjustmentValueListener {//implements AdjustmentListener {

  final GraphOutline graphOutline;

  AdjustmentValueListener(this.graphOutline);

  void adjustmentValueChanged(AdjustmentEvent e) {
    if (graphOutline.updateScaleAndTranslate()) {
      graphOutline.repaintBuffer = true;
      graphOutline.updateFinder(false);
      graphOutline.repaint();
    } else {
      graphOutline.updateFinder(true);
    }
  }
}
