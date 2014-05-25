/**
 * Copyright (c) 2006-2013, JGraph Ltd
 */
part of graph.io;

//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Codec for mxStylesheets. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
class StylesheetCodec extends ObjectCodec
{

	/**
	 * Constructs a new model codec.
	 */
	StylesheetCodec()
	{
		this(new Stylesheet());
	}

	/**
	 * Constructs a new stylesheet codec for the given template.
	 */
	StylesheetCodec(Object template)
	{
		this(template, null, null, null);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	StylesheetCodec(Object template, List<String> exclude,
			List<String> idrefs, Map<String, String> mapping)
	{
		super(template, exclude, idrefs, mapping);
	}

	/**
	 * Encodes the given Stylesheet.
	 */
	Node encode(Codec enc, Object obj)
	{
		Element node = enc._document.createElement(getName());

		if (obj is Stylesheet)
		{
			Stylesheet stylesheet = (Stylesheet) obj;
			Iterator<Map.Entry<String, Map<String, Object>>> it = stylesheet
					.getStyles().entrySet().iterator();

			while (it.hasNext())
			{
				Map.Entry<String, Map<String, Object>> entry = it.next();

				Element styleNode = enc._document.createElement("add");
				String stylename = entry.getKey();
				styleNode.setAttribute("as", stylename);

				Map<String, Object> style = entry.getValue();
				Iterator<Map.Entry<String, Object>> it2 = style.entrySet()
						.iterator();

				while (it2.hasNext())
				{
					Map.Entry<String, Object> entry2 = it2.next();
					Element entryNode = enc._document.createElement("add");
					entryNode.setAttribute("as",
							String.valueOf(entry2.getKey()));
					entryNode.setAttribute("value", _getStringValue(entry2));
					styleNode.appendChild(entryNode);
				}

				if (styleNode.getChildNodes().getLength() > 0)
				{
					node.appendChild(styleNode);
				}
			}
		}

		return node;
	}

	/**
	 * Returns the string for encoding the given value.
	 */
	String _getStringValue(Map.Entry<String, Object> entry)
	{
		if (entry.getValue() is Boolean)
		{
			return ((Boolean) entry.getValue()) ? "1" : "0";
		}

		return entry.getValue().toString();
	}

	/**
	 * Decodes the given Stylesheet.
	 */
	Object decode(Codec dec, Node node, Object into)
	{
		Object obj = null;

		if (node is Element)
		{
			String id = ((Element) node).getAttribute("id");
			obj = dec._objects.get(id);

			if (obj == null)
			{
				obj = into;

				if (obj == null)
				{
					obj = _cloneTemplate(node);
				}

				if (id != null && id.length() > 0)
				{
					dec.putObject(id, obj);
				}
			}

			node = node.getFirstChild();

			while (node != null)
			{
				if (!processInclude(dec, node, obj)
						&& node.getNodeName().equals("add")
						&& node is Element)
				{
					String as = ((Element) node).getAttribute("as");

					if (as != null && as.length() > 0)
					{
						String extend = ((Element) node).getAttribute("extend");
						Map<String, Object> style = (extend != null) ? ((Stylesheet) obj)
								.getStyles().get(extend) : null;

						if (style == null)
						{
							style = new Hashtable<String, Object>();
						}
						else
						{
							style = new Hashtable<String, Object>(style);
						}

						Node entry = node.getFirstChild();

						while (entry != null)
						{
							if (entry is Element)
							{
								Element entryElement = (Element) entry;
								String key = entryElement.getAttribute("as");

								if (entry.getNodeName().equals("add"))
								{
									String text = entry.getTextContent();
									Object value = null;

									if (text != null && text.length() > 0)
									{
										value = Utils.eval(text);
									}
									else
									{
										value = entryElement
												.getAttribute("value");

									}

									if (value != null)
									{
										style.put(key, value);
									}
								}
								else if (entry.getNodeName().equals("remove"))
								{
									style.remove(key);
								}
							}

							entry = entry.getNextSibling();
						}

						((Stylesheet) obj).putCellStyle(as, style);
					}
				}

				node = node.getNextSibling();
			}
		}

		return obj;
	}

}