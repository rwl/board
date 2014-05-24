/**
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
part of graph.io.graphml;

//import java.util.HashMap;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;

/**
 * This is a singleton class that contains a map with the key elements of the
 * document. The key elements are wrapped in instances of mxGmlKey and
 * may to be access by ID.
 */
class GraphMlKeyManager
{
	/**
	 * Map with the key elements of the document.<br/>
	 * The key is the key's ID.
	 */
	private HashMap<String, GraphMlKey> _keyMap = new HashMap<String, GraphMlKey>();

	private static GraphMlKeyManager _keyManager = null;

	/**
	 * Singleton pattern requires private constructor.
	 */
	private GraphMlKeyManager()
	{
	}

	/**
	 * Returns the instance of mxGmlKeyManager.
	 * If no instance has been created until the moment, a new instance is
	 * returned.
	 * This method don't load the map.
	 * @return An instance of mxGmlKeyManager.
	 */
	static GraphMlKeyManager getInstance()
	{
		if (_keyManager == null)
		{
			_keyManager = new GraphMlKeyManager();
		}
		return _keyManager;
	}

	/**
	 * Load the map with the key elements in the document.<br/>
	 * The keys are wrapped for instances of mxGmlKey.
	 * @param doc Document with the keys.
	 */
	void initialise(Document doc)
	{
		NodeList gmlKeys = doc.getElementsByTagName(GraphMlConstants.KEY);

		int keyLength = gmlKeys.getLength();

		for (int i = 0; i < keyLength; i++)
		{
			Element key = (Element) gmlKeys.item(i);
			String keyId = key.getAttribute(GraphMlConstants.ID);
			GraphMlKey keyElement = new GraphMlKey(key);
			_keyMap.put(keyId, keyElement);
		}
	}

	HashMap<String, GraphMlKey> getKeyMap()
	{
		return _keyMap;
	}

	void setKeyMap(HashMap<String, GraphMlKey> keyMap)
	{
		this._keyMap = keyMap;
	}
}
