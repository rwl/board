/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.sharing;

//import org.w3c.dom.Node;

/**
 * Implements a session that may be attached to a shared diagram. The session
 * contains a synchronized buffer which is used to hold the pending edits which
 * are to be sent to a specific client. The update mechnism between the server
 * and the client uses HTTP requests (polling). The request is kept on the server
 * for an amount of time or wakes up / returns immediately if the buffer is no
 * longer empty.
 */
class Session implements DiagramChangeListener {
  /**
   * Default timeout is 10000 ms.
   */
  static const int DEFAULT_TIMEOUT = 10000;

  /**
   * Holds the session ID.
   */
  String _id;

  /**
   * Reference to the shared diagram.
   */
  SharedState _diagram;

  /**
   * Holds the send buffer for this session.
   */
  StringBuffer _buffer = new StringBuffer();

  /**
   * Holds the last active time millis.
   */
  int _lastTimeMillis = 0;

  /**
   * Constructs a new session with the given ID.
   * 
   * @param id Specifies the session ID to be used.
   * @param diagram Reference to the shared diagram.
   */
  Session(String id, SharedState diagram) {
    this._id = id;
    this._diagram = diagram;
    this._diagram.addDiagramChangeListener(this);

    _lastTimeMillis = new DateTime.now().millisecondsSinceEpoch;
  }

  /**
   * Returns the session ID.
   */
  String getId() {
    return _id;
  }

  /**
   * Initializes the session buffer and returns a string that represents the
   * state of the session.
   *
   * @return Returns the initial state of the session.
   */
  /*synchronized*/ String init() {
    //synchronized (this) {
			_buffer = new StringBuffer();
			//notify();
		//}

    return getInitialMessage();
  }

  /**
   * Returns an XML string that represents the current state of the session
   * and the shared diagram. A globally unique ID is used as the session's
   * namespace, which is used on the client side to prefix IDs of newly
   * created cells.
   */
  String getInitialMessage() {
    String ns = Utils.getMd5Hash(_id);

    StringBuffer result = new StringBuffer("<message namespace=\"" + ns + "\">");
    result.write("<state>");
    result.write(_diagram.getState());
    result.write("</state>");
    result.write("<delta>");
    result.write(_diagram.getDelta());
    result.write("</delta>");
    result.write("</message>");

    return result.toString();
  }

  /**
   * Posts the change represented by the given XML string to the shared diagram.
   * 
   * @param message XML that represents the change.
   */
  void receive(Node message) {
    //print(getId() + ": " + Utils.getPrettyXml(message));
    Node child = message.firstChild;

    while (child != null) {
      if (child.nodeName == "delta") {
        _diagram.processDelta(this, child);
      }

      child = child.nextNode;
    }
    /*print(Utils.getPrettyXml(new Codec()
				.encode((diagram as SharedGraphModel).getModel())));*/
  }

  /**
   * Returns the changes received by other sessions for the shared diagram.
   * The method returns an empty XML node if no change was received within
   * the given timeout.
   * 
   * @param timeout Time in milliseconds to wait for changes.
   * @return Returns a string representing the changes to the shared diagram.
   */
  String poll([int timeout = DEFAULT_TIMEOUT]) //throws InterruptedException
  {
    _lastTimeMillis = new DateTime.now().millisecondsSinceEpoch;
    StringBuffer result = new StringBuffer("<message>");

    //synchronized (this) {
			if (_buffer.length == 0)
			{
				//wait(timeout);
			}

			if (_buffer.length > 0)
			{
				result.write("<delta>");
				result.write(_buffer.toString());
				result.write("</delta>");
				
				_buffer = new StringBuffer();
			}

			//notify();
		//}

    result.write("</message>");

    return result.toString();
  }

  /**
   * @see DiagramChangeListener#diagramChanged(Object, Node)
   */
  /*synchronized*/ void diagramChanged(Object sender, String edits) {
    if (sender != this) {
      //synchronized (this) {
				_buffer.write(edits);
				//notify();
			//}
    }
  }

  /**
   * Returns the number of milliseconds this session has been inactive.
   */
  int inactiveTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch - _lastTimeMillis;
  }

  /**
   * Destroys the session and removes its listener from the shared diagram.
   */
  void destroy() {
    _diagram.removeDiagramChangeListener(this);
  }

}
