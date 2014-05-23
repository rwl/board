/**
 * $Id: GraphMlKey.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2010 David Benson, Gaudenz Alder
 */
package graph.io.graphml;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Represents a Key element in the GML Structure.
 */
public class GraphMlKey
{
	/**
	 * Possibles values for the keyFor Attribute
	 */
	public enum keyForValues
	{
		GRAPH, NODE, EDGE, HYPEREDGE, PORT, ENDPOINT, ALL
	}

	/**
	 * Possibles values for the keyType Attribute.
	 */
	public enum keyTypeValues
	{
		BOOLEAN, INT, LONG, FLOAT, DOUBLE, STRING
	}

	private String _keyDefault;

	private String _keyId;

	private keyForValues _keyFor;

	private String _keyName;

	private keyTypeValues _keyType;

	/**
	 * Construct a key with the given parameters.
	 * @param keyId Key's ID
	 * @param keyFor Scope of the key.
	 * @param keyName Key Name
	 * @param keyType Type of the values represented for this key.
	 */
	public GraphMlKey(String keyId, keyForValues keyFor, String keyName,
			keyTypeValues keyType)
	{
		this._keyId = keyId;
		this._keyFor = keyFor;
		this._keyName = keyName;
		this._keyType = keyType;
		this._keyDefault = _defaultValue();
	}

	/**
	 * Construct a key from a xml key element.
	 * @param keyElement Xml key element.
	 */
	public GraphMlKey(Element keyElement)
	{
		this._keyId = keyElement.getAttribute(GraphMlConstants.ID);
		this._keyFor = enumForValue(keyElement
				.getAttribute(GraphMlConstants.KEY_FOR));
		this._keyName = keyElement.getAttribute(GraphMlConstants.KEY_NAME);
		this._keyType = enumTypeValue(keyElement
				.getAttribute(GraphMlConstants.KEY_TYPE));
		this._keyDefault = _defaultValue();
	}

	public String getKeyDefault()
	{
		return _keyDefault;
	}

	public void setKeyDefault(String keyDefault)
	{
		this._keyDefault = keyDefault;
	}

	public keyForValues getKeyFor()
	{
		return _keyFor;
	}

	public void setKeyFor(keyForValues keyFor)
	{
		this._keyFor = keyFor;
	}

	public String getKeyId()
	{
		return _keyId;
	}

	public void setKeyId(String keyId)
	{
		this._keyId = keyId;
	}

	public String getKeyName()
	{
		return _keyName;
	}

	public void setKeyName(String keyName)
	{
		this._keyName = keyName;
	}

	public keyTypeValues getKeyType()
	{
		return _keyType;
	}

	public void setKeyType(keyTypeValues keyType)
	{
		this._keyType = keyType;
	}

	/**
	 * Returns the default value of the keyDefault attribute according
	 * the keyType.
	 */
	private String _defaultValue()
	{
		String val = "";
		switch (this._keyType)
		{
			case BOOLEAN:
			{
				val = "false";
				break;
			}
			case DOUBLE:
			{
				val = "0";
				break;
			}
			case FLOAT:
			{
				val = "0";
				break;
			}
			case INT:
			{
				val = "0";
				break;
			}
			case LONG:
			{
				val = "0";
				break;
			}
			case STRING:
			{
				val = "";
				break;
			}
		}
		return val;
	}

	/**
	 * Generates a Key Element from this class.
	 * @param document Document where the key Element will be inserted.
	 * @return Returns the generated Elements.
	 */
	public Element generateElement(Document document)
	{
		Element key = document.createElement(GraphMlConstants.KEY);
		
		if (!_keyName.equals(""))
		{
			key.setAttribute(GraphMlConstants.KEY_NAME, _keyName);
		}
		key.setAttribute(GraphMlConstants.ID, _keyId);
		
		if (!_keyName.equals(""))
		{
			key.setAttribute(GraphMlConstants.KEY_FOR, stringForValue(_keyFor));
		}
		
		if (!_keyName.equals(""))
		{
			key.setAttribute(GraphMlConstants.KEY_TYPE, stringTypeValue(_keyType));
		}
		
		if (!_keyName.equals(""))
		{
			key.setTextContent(_keyDefault);
		}
		
		return key;
	}

	/**
	 * Converts a String value in its corresponding enum value for the
	 * keyFor attribute.
	 * @param value Value in String representation.
	 * @return Returns the value in its enum representation.
	 */
	public keyForValues enumForValue(String value)
	{
		keyForValues enumVal = keyForValues.ALL;
		
		if (value.equals(GraphMlConstants.GRAPH))
		{
			enumVal = keyForValues.GRAPH;
		}
		else if (value.equals(GraphMlConstants.NODE))
		{
			enumVal = keyForValues.NODE;
		}
		else if (value.equals(GraphMlConstants.EDGE))
		{
			enumVal = keyForValues.EDGE;
		}
		else if (value.equals(GraphMlConstants.HYPEREDGE))
		{
			enumVal = keyForValues.HYPEREDGE;
		}
		else if (value.equals(GraphMlConstants.PORT))
		{
			enumVal = keyForValues.PORT;
		}
		else if (value.equals(GraphMlConstants.ENDPOINT))
		{
			enumVal = keyForValues.ENDPOINT;
		}
		else if (value.equals(GraphMlConstants.ALL))
		{
			enumVal = keyForValues.ALL;
		}
		
		return enumVal;
	}

	/**
	 * Converts a enum value in its corresponding String value for the
	 * keyFor attribute.
	 * @param value Value in enum representation.
	 * @return Returns the value in its String representation.
	 */
	public String stringForValue(keyForValues value)
	{

		String val = GraphMlConstants.ALL;
		
		switch (value)
		{
			case GRAPH:
			{
				val = GraphMlConstants.GRAPH;
				break;
			}
			case NODE:
			{
				val = GraphMlConstants.NODE;
				break;
			}
			case EDGE:
			{
				val = GraphMlConstants.EDGE;
				break;
			}
			case HYPEREDGE:
			{
				val = GraphMlConstants.HYPEREDGE;
				break;
			}
			case PORT:
			{
				val = GraphMlConstants.PORT;
				break;
			}
			case ENDPOINT:
			{
				val = GraphMlConstants.ENDPOINT;
				break;
			}
			case ALL:
			{
				val = GraphMlConstants.ALL;
				break;
			}
		}

		return val;
	}

	/**
	 * Converts a String value in its corresponding enum value for the
	 * keyType attribute.
	 * @param value Value in String representation.
	 * @return Returns the value in its enum representation.
	 */
	public keyTypeValues enumTypeValue(String value)
	{
		keyTypeValues enumVal = keyTypeValues.STRING;
		
		if (value.equals("boolean"))
		{
			enumVal = keyTypeValues.BOOLEAN;
		}
		else if (value.equals("double"))
		{
			enumVal = keyTypeValues.DOUBLE;
		}
		else if (value.equals("float"))
		{
			enumVal = keyTypeValues.FLOAT;
		}
		else if (value.equals("int"))
		{
			enumVal = keyTypeValues.INT;
		}
		else if (value.equals("long"))
		{
			enumVal = keyTypeValues.LONG;
		}
		else if (value.equals("string"))
		{
			enumVal = keyTypeValues.STRING;
		}
		
		return enumVal;
	}

	/**
	 * Converts a enum value in its corresponding string value for the
	 * keyType attribute.
	 * @param value Value in enum representation.
	 * @return Returns the value in its String representation.
	 */
	public String stringTypeValue(keyTypeValues value)
	{
		String val = "string";
		
		switch (value)
		{
			case BOOLEAN:
			{
				val = "boolean";
				break;
			}
			case DOUBLE:
			{
				val = "double";
				break;
			}
			case FLOAT:
			{
				val = "float";
				break;
			}
			case INT:
			{
				val = "int";
				break;
			}
			case LONG:
			{
				val = "long";
				break;
			}
			case STRING:
			{
				val = "string";
				break;
			}
		}

		return val;
	}
}
