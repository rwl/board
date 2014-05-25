/**
 * Copyright (c) 2006, Gaudenz Alder
 */
part of graph.io;

//import java.lang.reflect.Array;
//import java.lang.reflect.Field;
//import java.lang.reflect.Method;
//import java.lang.reflect.Modifier;
//import java.util.Collection;
//import java.util.HashMap;
//import java.util.HashSet;
//import java.util.Hashtable;
//import java.util.Iterator;
//import java.util.Map;
//import java.util.Set;

//import org.w3c.dom.Element;
//import org.w3c.dom.NamedNodeMap;
//import org.w3c.dom.Node;

/**
 * Generic codec for Java objects. See below for a detailed description of
 * the encoding/decoding scheme.
 * 
 * Note: Since booleans are numbers in JavaScript, all bool values are
 * encoded into 1 for true and 0 for false.
 */
@SuppressWarnings("unchecked")
class ObjectCodec
{

	/**
	 * Immutable empty set.
	 */
	static Set<String> _EMPTY_SET = new HashSet<String>();

	/**
	 * Holds the template object associated with this codec.
	 */
	Object _template;

	/**
	 * Array containing the variable names that should be ignored by the codec.
	 */
	Set<String> _exclude;

	/**
	 * Array containing the variable names that should be turned into or
	 * converted from references. See <Codec.getId> and <Codec.getObject>.
	 */
	Set<String> _idrefs;

	/**
	 * Maps from from fieldnames to XML attribute names.
	 */
	Map<String, String> _mapping;

	/**
	 * Maps from from XML attribute names to fieldnames.
	 */
	Map<String, String> _reverse;

	/**
	 * Caches accessors for the given method names.
	 */
	Map<String, Method> _accessors;

	/**
	 * Caches fields for faster access.
	 */
	Map<Class, Map<String, Field>> _fields;

	/**
	 * Constructs a new codec for the specified template object.
	 */
	ObjectCodec(Object template)
	{
		this(template, null, null, null);
	}

	/**
	 * Constructs a new codec for the specified template object. The variables
	 * in the optional exclude array are ignored by the codec. Variables in the
	 * optional idrefs array are turned into references in the XML. The
	 * optional mapping may be used to map from variable names to XML
	 * attributes. The argument is created as follows:
	 * 
	 * @param template Prototypical instance of the object to be encoded/decoded.
	 * @param exclude Optional array of fieldnames to be ignored.
	 * @param idrefs Optional array of fieldnames to be converted to/from references.
	 * @param mapping Optional mapping from field- to attributenames.
	 */
	ObjectCodec(Object template, List<String> exclude, List<String> idrefs,
			Map<String, String> mapping)
	{
		this._template = template;

		if (exclude != null)
		{
			this._exclude = new HashSet<String>();

			for (int i = 0; i < exclude.length; i++)
			{
				this._exclude.add(exclude[i]);
			}
		}
		else
		{
			this._exclude = _EMPTY_SET;
		}

		if (idrefs != null)
		{
			this._idrefs = new HashSet<String>();

			for (int i = 0; i < idrefs.length; i++)
			{
				this._idrefs.add(idrefs[i]);
			}
		}
		else
		{
			this._idrefs = _EMPTY_SET;
		}

		if (mapping == null)
		{
			mapping = new Hashtable<String, String>();
		}

		this._mapping = mapping;

		_reverse = new Hashtable<String, String>();
		Iterator<Map.Entry<String, String>> it = mapping.entrySet().iterator();

		while (it.hasNext())
		{
			Map.Entry<String, String> e = it.next();
			_reverse.put(e.getValue(), e.getKey());
		}
	}

	/**
	 * Returns the name used for the nodenames and lookup of the codec when
	 * classes are encoded and nodes are decoded. For classes to work with
	 * this the codec registry automatically adds an alias for the classname
	 * if that is different than what this returns. The default implementation
	 * returns the classname of the template class.
	 * 
	 * Here is an example on how to use this for renaming Cell nodes:
	 * <code>
	 * CodecRegistry.register(new CellCodec()
	 * {
	 *   public String getName()
	 *   {
	 *     return "anotherName";
	 *   }
	 * });
	 * </code>
	 */
	String getName()
	{
		return CodecRegistry.getName(getTemplate());
	}

	/**
	 * Returns the template object associated with this codec.
	 * 
	 * @return Returns the template object.
	 */
	Object getTemplate()
	{
		return _template;
	}

	/**
	 * Returns a new instance of the template object for representing the given
	 * node.
	 * 
	 * @param node XML node that the object is going to represent.
	 * @return Returns a new template instance.
	 */
	Object _cloneTemplate(Node node)
	{
		Object obj = null;

		try
		{
			if (_template.getClass().isEnum())
			{
				obj = _template.getClass().getEnumConstants()[0];
			}
			else
			{
				obj = _template.getClass().newInstance();
			}

			// Special case: Check if the collection
			// should be a map. This is if the first
			// child has an "as"-attribute. This
			// assumes that all childs will have
			// as attributes in this case. This is
			// required because in JavaScript, the
			// map and array object are the same.
			if (obj is Collection)
			{
				node = node.getFirstChild();

				// Skips text nodes
				while (node != null && !(node is Element))
				{
					node = node.getNextSibling();
				}

				if (node != null && node is Element
						&& ((Element) node).hasAttribute("as"))
				{
					obj = new Hashtable<Object, Object>();
				}
			}
		}
		on InstantiationException catch (e)
		{
			// ignore
			e.printStackTrace();
		}
		on IllegalAccessException catch (e)
		{
			// ignore
			e.printStackTrace();
		}

		return obj;
	}

	/**
	 * Returns true if the given attribute is to be ignored by the codec. This
	 * implementation returns true if the given fieldname is in
	 * {@link #_exclude}.
	 * 
	 * @param obj Object instance that contains the field.
	 * @param attr Fieldname of the field.
	 * @param value Value of the field.
	 * @param write Boolean indicating if the field is being encoded or
	 * decoded. write is true if the field is being encoded, else it is
	 * being decoded.
	 * @return Returns true if the given attribute should be ignored.
	 */
	bool isExcluded(Object obj, String attr, Object value,
			bool write)
	{
		return _exclude.contains(attr);
	}

	/**
	 * Returns true if the given fieldname is to be treated as a textual
	 * reference (ID). This implementation returns true if the given fieldname
	 * is in {@link #_idrefs}.
	 * 
	 * @param obj Object instance that contains the field.
	 * @param attr Fieldname of the field.
	 * @param value Value of the field.
	 * @param isWrite Boolean indicating if the field is being encoded or
	 * decoded. isWrite is true if the field is being encoded, else it is being
	 * decoded.
	 * @return Returns true if the given attribute should be handled as a
	 * reference.
	 */
	bool isReference(Object obj, String attr, Object value,
			bool isWrite)
	{
		return _idrefs.contains(attr);
	}

	/**
	 * Encodes the specified object and returns a node representing then given
	 * object. Calls beforeEncode after creating the node and afterEncode
	 * with the resulting node after processing.
	 * 
	 * Enc is a reference to the calling encoder. It is used to encode complex
	 * objects and create references.
	 * 
	 * This implementation encodes all variables of an object according to the
	 * following rules:
	 * 
	 * <ul>
	 * <li>If the variable name is in {@link #_exclude} then it is ignored.</li>
	 * <li>If the variable name is in {@link #_idrefs} then
	 * {@link Codec#getId(Object)} is used to replace the object with its ID.
	 * </li>
	 * <li>The variable name is mapped using {@link #_mapping}.</li>
	 * <li>If obj is an array and the variable name is numeric (ie. an index) then it
	 * is not encoded.</li>
	 * <li>If the value is an object, then the codec is used to create a child
	 * node with the variable name encoded into the "as" attribute.</li>
	 * <li>Else, if {@link graph.io.Codec#isEncodeDefaults()} is true or
	 * the value differs from the template value, then ...
	 * <ul>
	 * <li>... if obj is not an array, then the value is mapped to an
	 * attribute.</li>
	 * <li>... else if obj is an array, the value is mapped to an add child
	 * with a value attribute or a text child node, if the value is a function.
	 * </li>
	 * </ul>
	 * </li>
	 * </ul>
	 * 
	 * If no ID exists for a variable in {@link #_idrefs} or if an object cannot be
	 * encoded, a warning is printed to System.err.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object to be encoded.
	 * @return Returns the resulting XML node that represents the given object. 
	 */
	Node encode(Codec enc, Object obj)
	{
		Node node = enc._document.createElement(getName());

		obj = beforeEncode(enc, obj, node);
		_encodeObject(enc, obj, node);

		return afterEncode(enc, obj, node);
	}

	/**
	 * Encodes the value of each member in then given obj
	 * into the given node using {@link #_encodeFields(Codec, Object, Node)}
	 * and {@link #_encodeElements(Codec, Object, Node)}.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object to be encoded.
	 * @param node XML node that contains the encoded object.
	 */
	void _encodeObject(Codec enc, Object obj, Node node)
	{
		Codec.setAttribute(node, "id", enc.getId(obj));
		_encodeFields(enc, obj, node);
		_encodeElements(enc, obj, node);
	}

	/**
	 * Encodes the declared fields of the given object into the given node.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object whose fields should be encoded.
	 * @param node XML node that contains the encoded object.
	 */
	void _encodeFields(Codec enc, Object obj, Node node)
	{
		// LATER: Use PropertyDescriptors in Introspector.getBeanInfo(clazz)
		// see http://forum.jgraph.com/questions/1424
		Class<?> type = obj.getClass();

		while (type != null)
		{
			Field[] fields = type.getDeclaredFields();

			for (int i = 0; i < fields.length; i++)
			{
				Field f = fields[i];

				if ((f.getModifiers() & Modifier.TRANSIENT) != Modifier.TRANSIENT)
				{
					String fieldname = f.getName();
					Object value = _getFieldValue(obj, fieldname);
					_encodeValue(enc, obj, fieldname, value, node);
				}
			}

			type = type.getSuperclass();
		}
	}

	/**
	 * Encodes the child objects of arrays, maps and collections.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object whose child objects should be encoded.
	 * @param node XML node that contains the encoded object.
	 */
	void _encodeElements(Codec enc, Object obj, Node node)
	{
		if (obj.getClass().isArray())
		{
			List<Object> tmp = (List<Object>) obj;

			for (int i = 0; i < tmp.length; i++)
			{
				_encodeValue(enc, obj, null, tmp[i], node);
			}
		}
		else if (obj is Map)
		{
			Iterator<Map.Entry> it = ((Map) obj).entrySet().iterator();

			while (it.hasNext())
			{
				Map.Entry e = it.next();
				_encodeValue(enc, obj, String.valueOf(e.getKey()), e.getValue(),
						node);
			}
		}
		else if (obj is Collection)
		{
			Iterator<?> it = ((Collection<?>) obj).iterator();

			while (it.hasNext())
			{
				Object value = it.next();
				_encodeValue(enc, obj, null, value, node);
			}
		}
	}

	/**
	 * Converts the given value according to the mappings
	 * and id-refs in this codec and uses
	 * {@link #_writeAttribute(Codec, Object, String, Object, Node)}
	 * to write the attribute into the given node.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object whose field is going to be encoded.
	 * @param fieldname Name if the field to be encoded.
	 * @param value Value of the property to be encoded.
	 * @param node XML node that contains the encoded object.
	 */
	void _encodeValue(Codec enc, Object obj, String fieldname,
			Object value, Node node)
	{
		if (value != null && !isExcluded(obj, fieldname, value, true))
		{
			if (isReference(obj, fieldname, value, true))
			{
				Object tmp = enc.getId(value);

				if (tmp == null)
				{
					System.err.println("ObjectCodec.encode: No ID for "
							+ getName() + "." + fieldname + "=" + value);
					return; // exit
				}

				value = tmp;
			}

			Object defaultValue = _getFieldValue(_template, fieldname);

			if (fieldname == null || enc.isEncodeDefaults()
					|| defaultValue == null || !defaultValue.equals(value))
			{
				_writeAttribute(enc, obj, _getAttributeName(fieldname), value,
						node);
			}
		}
	}

	/**
	 * Returns true if the given object is a primitive value.
	 * 
	 * @param value Object that should be checked.
	 * @return Returns true if the given object is a primitive value.
	 */
	bool _isPrimitiveValue(Object value)
	{
		return value is String || value is Boolean
				|| value is Character || value is Byte
				|| value is Short || value is Integer
				|| value is Long || value is Float
				|| value is Double || value.getClass().isPrimitive();
	}

	/**
	 * Writes the given value into node using writePrimitiveAttribute
	 * or writeComplexAttribute depending on the type of the value.
	 */
	void _writeAttribute(Codec enc, Object obj, String attr,
			Object value, Node node)
	{
		value = _convertValueToXml(value);

		if (_isPrimitiveValue(value))
		{
			_writePrimitiveAttribute(enc, obj, attr, value, node);
		}
		else
		{
			_writeComplexAttribute(enc, obj, attr, value, node);
		}
	}

	/**
	 * Writes the given value as an attribute of the given node.
	 */
	void _writePrimitiveAttribute(Codec enc, Object obj,
			String attr, Object value, Node node)
	{
		if (attr == null || obj is Map)
		{
			Node child = enc._document.createElement("add");

			if (attr != null)
			{
				Codec.setAttribute(child, "as", attr);
			}

			Codec.setAttribute(child, "value", value);
			node.appendChild(child);
		}
		else
		{
			Codec.setAttribute(node, attr, value);
		}
	}

	/**
	 * Writes the given value as a child node of the given node.
	 */
	void _writeComplexAttribute(Codec enc, Object obj, String attr,
			Object value, Node node)
	{
		Node child = enc.encode(value);

		if (child != null)
		{
			if (attr != null)
			{
				Codec.setAttribute(child, "as", attr);
			}

			node.appendChild(child);
		}
		else
		{
			System.err.println("ObjectCodec.encode: No node for " + getName()
					+ "." + attr + ": " + value);
		}
	}

	/**
	 * Converts true to "1" and false to "0". All other values are ignored.
	 */
	Object _convertValueToXml(Object value)
	{
		if (value is Boolean)
		{
			value = ((Boolean) value).booleanValue() ? "1" : "0";
		}

		return value;
	}

	/**
	 * Converts XML attribute values to object of the given type.
	 */
	Object _convertValueFromXml(Class<?> type, Object value)
	{
		if (value is String)
		{
			String tmp = (String) value;

			if (type.equals(boolean.class) || type == Boolean.class)
			{
				if (tmp.equals("1") || tmp.equals("0"))
				{
					tmp = (tmp.equals("1")) ? "true" : "false";
				}

				value = Boolean.valueOf(tmp);
			}
			else if (type.equals(char.class) || type == Character.class)
			{
				value = Character.valueOf(tmp.charAt(0));
			}
			else if (type.equals(byte.class) || type == Byte.class)
			{
				value = Byte.valueOf(tmp);
			}
			else if (type.equals(short.class) || type == Short.class)
			{
				value = Short.valueOf(tmp);
			}
			else if (type.equals(int.class) || type == Integer.class)
			{
				value = Integer.valueOf(tmp);
			}
			else if (type.equals(long.class) || type == Long.class)
			{
				value = Long.valueOf(tmp);
			}
			else if (type.equals(float.class) || type == Float.class)
			{
				value = Float.valueOf(tmp);
			}
			else if (type.equals(double.class) || type == Double.class)
			{
				value = Double.valueOf(tmp);
			}
		}

		return value;
	}

	/**
	 * Returns the XML node attribute name for the given Java field name. That
	 * is, it returns the mapping of the field name.
	 */
	String _getAttributeName(String fieldname)
	{
		if (fieldname != null)
		{
			Object mapped = _mapping.get(fieldname);

			if (mapped != null)
			{
				fieldname = mapped.toString();
			}
		}

		return fieldname;
	}

	/**
	 * Returns the Java field name for the given XML attribute name. That is, it
	 * returns the reverse mapping of the attribute name.
	 * 
	 * @param attributename
	 *            The attribute name to be mapped.
	 * @return String that represents the mapped field name.
	 */
	String _getFieldName(String attributename)
	{
		if (attributename != null)
		{
			Object mapped = _reverse.get(attributename);

			if (mapped != null)
			{
				attributename = mapped.toString();
			}
		}

		return attributename;
	}

	/**
	 * Returns the field with the specified name.
	 */
	Field _getField(Object obj, String fieldname)
	{
		Class<?> type = obj.getClass();

		// Creates the fields cache
		if (_fields == null)
		{
			_fields = new HashMap<Class, Map<String, Field>>();
		}

		// Creates the fields cache entry for the given type
		Map<String, Field> map = _fields.get(type);

		if (map == null)
		{
			map = new HashMap<String, Field>();
			_fields.put(type, map);
		}

		// Tries to get cached field
		Field field = map.get(fieldname);

		if (field != null)
		{
			return field;
		}

		while (type != null)
		{
			try
			{
				field = type.getDeclaredField(fieldname);

				if (field != null)
				{
					// Adds field to fields cache
					map.put(fieldname, field);

					return field;
				}
			}
			on Exception catch (e)
			{
				// ignore
			}

			type = type.getSuperclass();
		}

		return null;
	}

	/**
	 * Returns the accessor (getter, setter) for the specified field.
	 */
	Method _getAccessor(Object obj, Field field, bool isGetter)
	{
		String name = field.getName();
		name = name.substring(0, 1).toUpperCase() + name.substring(1);

		if (!isGetter)
		{
			name = "set" + name;
		}
		else if (boolean.class.isAssignableFrom(field.getType()))
		{
			name = "is" + name;
		}
		else
		{
			name = "get" + name;
		}

		Method method = (_accessors != null) ? _accessors.get(name) : null;

		if (method == null)
		{
			try
			{
				if (isGetter)
				{
					method = _getMethod(obj, name, null);
				}
				else
				{
					method = _getMethod(obj, name,
							new Class[] { field.getType() });
				}
			}
			on Exception catch (e1)
			{
				// ignore
			}

			// Adds accessor to cache
			if (method != null)
			{
				if (_accessors == null)
				{
					_accessors = new Hashtable<String, Method>();
				}

				_accessors.put(name, method);
			}
		}

		return method;
	}

	/**
	 * Returns the method with the specified signature.
	 */
	Method _getMethod(Object obj, String methodname, Class[] params)
	{
		Class<?> type = obj.getClass();

		while (type != null)
		{
			try
			{
				Method method = type.getDeclaredMethod(methodname, params);

				if (method != null)
				{
					return method;
				}
			}
			on Exception catch (e)
			{
				// ignore
			}

			type = type.getSuperclass();
		}
		return null;
	}

	/**
	 * Returns the value of the field with the specified name in the specified
	 * object instance.
	 */
	Object _getFieldValue(Object obj, String fieldname)
	{
		Object value = null;

		if (obj != null && fieldname != null)
		{
			Field field = _getField(obj, fieldname);

			try
			{
				if (field != null)
				{
					if (Modifier.isPublic(field.getModifiers()))
					{
						value = field.get(obj);
					}
					else
					{
						value = _getFieldValueWithAccessor(obj, field);
					}
				}
			}
			on IllegalAccessException catch (e1)
			{
				value = _getFieldValueWithAccessor(obj, field);
			}
			on Exception catch (e)
			{
				// ignore
			}
		}

		return value;
	}

	/**
	 * Returns the value of the field using the accessor for the field if one exists.
	 */
	Object _getFieldValueWithAccessor(Object obj, Field field)
	{
		Object value = null;

		if (field != null)
		{
			try
			{
				Method method = _getAccessor(obj, field, true);

				if (method != null)
				{
					value = method.invoke(obj, (List<Object>) null);
				}
			}
			on Exception catch (e2)
			{
				// ignore
			}
		}

		return value;
	}

	/**
	 * Sets the value of the field with the specified name
	 * in the specified object instance.
	 */
	void _setFieldValue(Object obj, String fieldname, Object value)
	{
		Field field = null;

		try
		{
			field = _getField(obj, fieldname);

			if (field != null)
			{
				if (field.getType() == Boolean.class)
				{
					value = (value.equals("1") || String.valueOf(value)
							.equalsIgnoreCase("true")) ? Boolean.TRUE
							: Boolean.FALSE;
				}

				if (Modifier.isPublic(field.getModifiers()))
				{
					field.set(obj, value);
				}
				else
				{
					_setFieldValueWithAccessor(obj, field, value);
				}
			}
		}
		on IllegalAccessException catch (e1)
		{
			_setFieldValueWithAccessor(obj, field, value);
		}
		on Exception catch (e)
		{
			// ignore
		}
	}

	/**
	 * Sets the value of the given field using the accessor if one exists.
	 */
	void _setFieldValueWithAccessor(Object obj, Field field,
			Object value)
	{
		if (field != null)
		{
			try
			{
				Method method = _getAccessor(obj, field, false);

				if (method != null)
				{
					Class<?> type = method.getParameterTypes()[0];
					value = _convertValueFromXml(type, value);

					// Converts collection to a typed array before setting
					if (type.isArray() && value is Collection)
					{
						Collection<?> coll = (Collection<?>) value;
						value = coll.toArray((List<Object>) Array.newInstance(
								type.getComponentType(), coll.size()));
					}

					method.invoke(obj, new List<Object> { value });
				}
			}
			on Exception catch (e2)
			{
				System.err.println("setFieldValue: " + e2 + " on "
						+ obj.getClass().getSimpleName() + "."
						+ field.getName() + " ("
						+ field.getType().getSimpleName() + ") = " + value
						+ " (" + value.getClass().getSimpleName() + ")");
			}
		}
	}

	/**
	 * Hook for subclassers to pre-process the object before encoding. This
	 * returns the input object. The return value of this function is used in
	 * encode to perform the default encoding into the given node.
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object to be encoded.
	 * @param node XML node to encode the object into.
	 * @return Returns the object to be encoded by the default encoding.
	 */
	Object beforeEncode(Codec enc, Object obj, Node node)
	{
		return obj;
	}

	/**
	 * Hook for subclassers to post-process the node for the given object after
	 * encoding and return the post-processed node. This implementation returns
	 * the input node. The return value of this method is returned to the
	 * encoder from <encode>.
	 * 
	 * Parameters:
	 * 
	 * @param enc Codec that controls the encoding process.
	 * @param obj Object to be encoded.
	 * @param node XML node that represents the default encoding.
	 * @return Returns the resulting node of the encoding.
	 */
	Node afterEncode(Codec enc, Object obj, Node node)
	{
		return node;
	}

	/**
	 * Parses the given node into the object or returns a new object
	 * representing the given node.
	 * 
	 * @param dec Codec that controls the encoding process.
	 * @param node XML node to be decoded.
	 * @return Returns the resulting object that represents the given XML node.
	 */
	Object decode(Codec dec, Node node)
	{
		return decode(dec, node, null);
	}

	/**
	 * Parses the given node into the object or returns a new object
	 * representing the given node.
	 * 
	 * Dec is a reference to the calling decoder. It is used to decode complex
	 * objects and resolve references.
	 * 
	 * If a node has an id attribute then the object cache is checked for the
	 * object. If the object is not yet in the cache then it is constructed
	 * using the constructor of <template> and cached in <Codec.objects>.
	 * 
	 * This implementation decodes all attributes and childs of a node according
	 * to the following rules:
	 *  - If the variable name is in <exclude> or if the attribute name is "id"
	 * or "as" then it is ignored. - If the variable name is in <idrefs> then
	 * <Codec.getObject> is used to replace the reference with an object. -
	 * The variable name is mapped using a reverse <mapping>. - If the value has
	 * a child node, then the codec is used to create a child object with the
	 * variable name taken from the "as" attribute. - If the object is an array
	 * and the variable name is empty then the value or child object is appended
	 * to the array. - If an add child has no value or the object is not an
	 * array then the child text content is evaluated using <Utils.eval>.
	 * 
	 * If no object exists for an ID in <idrefs> a warning is issued in
	 * System.err.
	 * 
	 * @param dec Codec that controls the encoding process.
	 * @param node XML node to be decoded.
	 * @param into Optional object to encode the node into.
	 * @return Returns the resulting object that represents the given XML node
	 * or the object given to the method as the into parameter.
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

			node = beforeDecode(dec, node, obj);
			_decodeNode(dec, node, obj);
			obj = afterDecode(dec, node, obj);
		}

		return obj;
	}

	/**
	 * Calls decodeAttributes and decodeChildren for the given node.
	 */
	void _decodeNode(Codec dec, Node node, Object obj)
	{
		if (node != null)
		{
			_decodeAttributes(dec, node, obj);
			_decodeChildren(dec, node, obj);
		}
	}

	/**
	 * Decodes all attributes of the given node using decodeAttribute.
	 */
	void _decodeAttributes(Codec dec, Node node, Object obj)
	{
		NamedNodeMap attrs = node.getAttributes();

		if (attrs != null)
		{
			for (int i = 0; i < attrs.getLength(); i++)
			{
				Node attr = attrs.item(i);
				_decodeAttribute(dec, attr, obj);
			}
		}
	}

	/**
	 * Reads the given attribute into the specified object.
	 */
	void _decodeAttribute(Codec dec, Node attr, Object obj)
	{
		String name = attr.getNodeName();

		if (!name.equalsIgnoreCase("as") && !name.equalsIgnoreCase("id"))
		{
			Object value = attr.getNodeValue();
			String fieldname = _getFieldName(name);

			if (isReference(obj, fieldname, value, false))
			{
				Object tmp = dec.getObject(String.valueOf(value));

				if (tmp == null)
				{
					System.err.println("ObjectCodec.decode: No object for "
							+ getName() + "." + fieldname + "=" + value);
					return; // exit
				}

				value = tmp;
			}

			if (!isExcluded(obj, fieldname, value, false))
			{
				_setFieldValue(obj, fieldname, value);
			}
		}
	}

	/**
	 * Decodec all children of the given node using decodeChild.
	 */
	void _decodeChildren(Codec dec, Node node, Object obj)
	{
		Node child = node.getFirstChild();

		while (child != null)
		{
			if (child.getNodeType() == Node.ELEMENT_NODE
					&& !processInclude(dec, child, obj))
			{
				_decodeChild(dec, child, obj);
			}

			child = child.getNextSibling();
		}
	}

	/**
	 * Reads the specified child into the given object.
	 */
	void _decodeChild(Codec dec, Node child, Object obj)
	{
		String fieldname = _getFieldName(((Element) child).getAttribute("as"));

		if (fieldname == null || !isExcluded(obj, fieldname, child, false))
		{
			Object template = _getFieldTemplate(obj, fieldname, child);
			Object value = null;

			if (child.getNodeName().equals("add"))
			{
				value = ((Element) child).getAttribute("value");

				if (value == null)
				{
					value = child.getTextContent();
				}
			}
			else
			{
				value = dec.decode(child, template);
				// System.out.println("Decoded " + child.getNodeName() + "."
				// + fieldname + "=" + value);
			}

			_addObjectValue(obj, fieldname, value, template);
		}
	}

	/**
	 * Returns the template instance for the given field. This returns the
	 * value of the field, null if the value is an array or an empty collection
	 * if the value is a collection. The value is then used to populate the
	 * field for a new instance. For strongly typed languages it may be
	 * required to override this to return the correct collection instance
	 * based on the encoded child.
	 */
	Object _getFieldTemplate(Object obj, String fieldname, Node child)
	{
		Object template = _getFieldValue(obj, fieldname);

		// Arrays are replaced completely
		if (template != null && template.getClass().isArray())
		{
			template = null;
		}
		// Collections are cleared
		else if (template is Collection)
		{
			((Collection<?>) template).clear();
		}

		return template;
	}

	/**
	 * Sets the decoded child node as a value of the given object. If the
	 * object is a map, then the value is added with the given fieldname as a
	 * key. If the fieldname is not empty, then setFieldValue is called or
	 * else, if the object is a collection, the value is added to the
	 * collection. For strongly typed languages it may be required to
	 * override this with the correct code to add an entry to an object.
	 */
	void _addObjectValue(Object obj, String fieldname, Object value,
			Object template)
	{
		if (value != null && !value.equals(template))
		{
			if (fieldname != null && obj is Map)
			{
				((Map) obj).put(fieldname, value);
			}
			else if (fieldname != null && fieldname.length() > 0)
			{
				_setFieldValue(obj, fieldname, value);
			}
			// Arrays are treated as collections and
			// converted in setFieldValue
			else if (obj is Collection)
			{
				((Collection) obj).add(value);
			}
		}
	}

	/**
	 * Returns true if the given node is an include directive and executes the
	 * include by decoding the XML document. Returns false if the given node is
	 * not an include directive.
	 * 
	 * @param dec Codec that controls the encoding/decoding process.
	 * @param node XML node to be checked.
	 * @param into Optional object to pass-thru to the codec.
	 * @return Returns true if the given node was processed as an include.
	 */
	bool processInclude(Codec dec, Node node, Object into)
	{
		if (node.getNodeType() == Node.ELEMENT_NODE
				&& node.getNodeName().equalsIgnoreCase("include"))
		{
			String name = ((Element) node).getAttribute("name");

			if (name != null)
			{
				try
				{
					Node xml = Utils.loadDocument(
							ObjectCodec.class.getResource(name).toString())
							.getDocumentElement();

					if (xml != null)
					{
						dec.decode(xml, into);
					}
				}
				on Exception catch (e)
				{
					System.err.println("Cannot process include: " + name);
				}
			}

			return true;
		}

		return false;
	}

	/**
	 * Hook for subclassers to pre-process the node for the specified object
	 * and return the node to be used for further processing by
	 * {@link #decode(Codec, Node)}. The object is created based on the
	 * template in the calling method and is never null.
	 * 
	 * This implementation returns the input node. The return value of this
	 * function is used in {@link #decode(Codec, Node)} to perform the
	 * default decoding into the given object.
	 * 
	 * @param dec Codec that controls the decoding process.
	 * @param node XML node to be decoded.
	 * @param obj Object to encode the node into.
	 * @return Returns the node used for the default decoding.
	 */
	Node beforeDecode(Codec dec, Node node, Object obj)
	{
		return node;
	}

	/**
	 * Hook for subclassers to post-process the object after decoding. This
	 * implementation returns the given object without any changes. The return
	 * value of this method is returned to the decoder from
	 * {@link #decode(Codec, Node)}.
	 * 
	 * @param dec Codec that controls the decoding process.
	 * @param node XML node to be decoded.
	 * @param obj Object that represents the default decoding.
	 * @return Returns the result of the decoding process.
	 */
	Object afterDecode(Codec dec, Node node, Object obj)
	{
		return obj;
	}

}
