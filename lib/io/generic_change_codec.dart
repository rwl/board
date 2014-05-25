/**
 * Copyright (c) 2006, Gaudenz Alder
 */
part of graph.io;

//import java.util.Map;

//import org.w3c.dom.Node;

/**
 * Codec for mxChildChanges. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
class GenericChangeCodec extends ObjectCodec
{
	/**
	 * 
	 */
	String _fieldname;

	/**
	 * Constructs a new model codec.
	 */
	GenericChangeCodec(Object template, String fieldname)
	{
		this(template, new List<String> { "model", "previous" },
				new List<String> { "cell" }, null, fieldname);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	GenericChangeCodec(Object template, List<String> exclude,
			List<String> idrefs, Map<String, String> mapping, String fieldname)
	{
		super(template, exclude, idrefs, mapping);

		this._fieldname = fieldname;
	}

	/* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
	@Override
	Object afterDecode(Codec dec, Node node, Object obj)
	{
		Object cell = _getFieldValue(obj, "cell");

		if (cell is Node)
		{
			_setFieldValue(obj, "cell", dec.decodeCell((Node) cell, false));
		}

		_setFieldValue(obj, "previous", _getFieldValue(obj, _fieldname));

		return obj;
	}

}
