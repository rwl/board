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
class Session implements DiagramChangeListener
{
	/**
	 * Default timeout is 10000 ms.
	 */
	static int DEFAULT_TIMEOUT = 10000;

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
	long _lastTimeMillis = 0;

	/**
	 * Constructs a new session with the given ID.
	 * 
	 * @param id Specifies the session ID to be used.
	 * @param diagram Reference to the shared diagram.
	 */
	Session(String id, SharedState diagram)
	{
		this._id = id;
		this._diagram = diagram;
		this._diagram.addDiagramChangeListener(this);

		_lastTimeMillis = System.currentTimeMillis();
	}

	/**
	 * Returns the session ID.
	 */
	String getId()
	{
		return _id;
	}

	/**
	 * Initializes the session buffer and returns a string that represents the
	 * state of the session.
	 *
	 * @return Returns the initial state of the session.
	 */
	synchronized String init()
	{
		synchronized (this)
		{
			_buffer = new StringBuffer();
			notify();
		}

		return getInitialMessage();
	}

	/**
	 * Returns an XML string that represents the current state of the session
	 * and the shared diagram. A globally unique ID is used as the session's
	 * namespace, which is used on the client side to prefix IDs of newly
	 * created cells.
	 */
	String getInitialMessage()
	{
		String ns = Utils.getMd5Hash(_id);

		StringBuffer result = new StringBuffer("<message namespace=\"" + ns
				+ "\">");
		result.append("<state>");
		result.append(_diagram.getState());
		result.append("</state>");
		result.append("<delta>");
		result.append(_diagram.getDelta());
		result.append("</delta>");
		result.append("</message>");

		return result.toString();
	}

	/**
	 * Posts the change represented by the given XML string to the shared diagram.
	 * 
	 * @param message XML that represents the change.
	 */
	void receive(Node message)
	{
		//System.out.println(getId() + ": " + Utils.getPrettyXml(message));
		Node child = message.getFirstChild();

		while (child != null)
		{
			if (child.getNodeName().equals("delta"))
			{
				_diagram.processDelta(this, child);
			}

			child = child.getNextSibling();
		}
		/*System.out.println(Utils.getPrettyXml(new Codec()
				.encode(((SharedGraphModel) diagram).getModel())));*/
	}

	/**
	 * Returns the changes received by other sessions for the shared diagram.
	 * The method returns an empty XML node if no change was received within
	 * 10 seconds.
	 * 
	 * @return Returns a string representing the changes to the shared diagram.
	 */
	String poll() //throws InterruptedException
	{
		return poll(DEFAULT_TIMEOUT);
	}

	/**
	 * Returns the changes received by other sessions for the shared diagram.
	 * The method returns an empty XML node if no change was received within
	 * the given timeout.
	 * 
	 * @param timeout Time in milliseconds to wait for changes.
	 * @return Returns a string representing the changes to the shared diagram.
	 */
	String poll(long timeout) //throws InterruptedException
	{
		_lastTimeMillis = System.currentTimeMillis();
		StringBuffer result = new StringBuffer("<message>");

		synchronized (this)
		{
			if (_buffer.length() == 0)
			{
				wait(timeout);
			}

			if (_buffer.length() > 0)
			{
				result.append("<delta>");
				result.append(_buffer.toString());
				result.append("</delta>");
				
				_buffer = new StringBuffer();
			}

			notify();
		}

		result.append("</message>");

		return result.toString();
	}

	/*
	 * (non-Javadoc)
	 * @see graph.sharing.mxSharedDiagram.mxDiagramChangeListener#diagramChanged(java.lang.Object, org.w3c.dom.Node)
	 */
	synchronized void diagramChanged(Object sender, String edits)
	{
		if (sender != this)
		{
			synchronized (this)
			{
				_buffer.append(edits);
				notify();
			}
		}
	}

	/**
	 * Returns the number of milliseconds this session has been inactive.
	 */
	long inactiveTimeMillis()
	{
		return System.currentTimeMillis() - _lastTimeMillis;
	}

	/**
	 * Destroys the session and removes its listener from the shared diagram.
	 */
	void destroy()
	{
		_diagram.removeDiagramChangeListener(this);
	}

}