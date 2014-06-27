part of graph.swing.handler;

//import java.awt.BasicStroke;
//import java.awt.Color;
//import java.awt.Graphics;
//import java.awt.Graphics2D;
//import java.awt.Point;
//import java.awt.awt.Rectangle;
//import java.awt.event.MouseEvent;

class InsertHandler extends MouseAdapter {

  /**
   * Reference to the enclosing graph component.
   */
  GraphComponent _graphComponent;

  /**
   * Specifies if this handler is enabled. Default is true.
   */
  bool _enabled = true;

  String _style;

  awt.Point _first;

  float _lineWidth = 1;

  Color _lineColor = Color.black;

  bool _rounded = false;

  Rect _current;

  EventSource _eventSource;

  InsertHandler(GraphComponent graphComponent, String style) {
    this._graphComponent = graphComponent;
    this._style = style;

    _eventSource = new EventSource(this);

    // Installs the paint handler
    graphComponent.addListener(Event.AFTER_PAINT, (Object sender, EventObj evt) {
      Graphics g = evt.getProperty("g") as Graphics;
      paint(g);
    });

    // Listens to all mouse events on the rendering control
    graphComponent.getGraphControl().addMouseListener(this);
    graphComponent.getGraphControl().addMouseMotionListener(this);
  }

  GraphComponent getGraphComponent() {
    return _graphComponent;
  }

  bool isEnabled() {
    return _enabled;
  }

  void setEnabled(bool value) {
    _enabled = value;
  }

  bool isStartEvent(MouseEvent e) {
    return true;
  }

  void start(MouseEvent e) {
    _first = e.getPoint();
  }

  void mousePressed(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed() && isStartEvent(e)) {
      start(e);
      e.consume();
    }
  }

  void mouseDragged(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed() && _first != null) {
      Rect dirty = _current;

      _current = new Rect(_first.x, _first.y, 0, 0);
      _current.add(new Rect(e.getX(), e.getY(), 0, 0));

      if (dirty != null) {
        dirty.add(_current);
      } else {
        dirty = _current;
      }

      awt.Rectangle tmp = dirty.getRectangle();
      int b = math.ceil(_lineWidth) as int;
      _graphComponent.getGraphControl().repaint(tmp.x - b, tmp.y - b, tmp.width + 2 * b, tmp.height + 2 * b);

      e.consume();
    }
  }

  void mouseReleased(MouseEvent e) {
    if (_graphComponent.isEnabled() && isEnabled() && !e.isConsumed() && _current != null) {
      Graph graph = _graphComponent.getGraph();
      double scale = graph.getView().getScale();
      Point2d tr = graph.getView().getTranslate();
      _current.setX(_current.getX() / scale - tr.getX());
      _current.setY(_current.getY() / scale - tr.getY());
      _current.setWidth(_current.getWidth() / scale);
      _current.setHeight(_current.getHeight() / scale);

      Object cell = insertCell(_current);
      _eventSource.fireEvent(new EventObj(Event.INSERT, "cell", cell));
      e.consume();
    }

    reset();
  }

  Object insertCell(Rect bounds) {
    // FIXME: Clone prototype cell for insert
    return _graphComponent.getGraph().insertVertex(null, null, "", bounds.getX(), bounds.getY(), bounds.getWidth(), bounds.getHeight(), _style);
  }

  void reset() {
    awt.Rectangle dirty = null;

    if (_current != null) {
      dirty = _current.getRectangle();
    }

    _current = null;
    _first = null;

    if (dirty != null) {
      int b = math.ceil(_lineWidth) as int;
      _graphComponent.getGraphControl().repaint(dirty.x - b, dirty.y - b, dirty.width + 2 * b, dirty.height + 2 * b);
    }
  }

  void paint(Graphics g) {
    if (_first != null && _current != null) {
      (g as Graphics2D).setStroke(new BasicStroke(_lineWidth));
      g.setColor(_lineColor);
      awt.Rectangle rect = _current.getRectangle();

      if (_rounded) {
        g.drawRoundRect(rect.x, rect.y, rect.width, rect.height, 8, 8);
      } else {
        g.drawRect(rect.x, rect.y, rect.width, rect.height);
      }
    }
  }

  /**
   *
   */
  void addListener(String eventName, IEventListener listener) {
    _eventSource.addListener(eventName, listener);
  }

  /**
   *
   */
  void removeListener(IEventListener listener, [String eventName=null]) {
    _eventSource.removeListener(listener, eventName);
  }

}
