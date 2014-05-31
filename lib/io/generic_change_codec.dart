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
class GenericChangeCodec extends ObjectCodec {
  /**
	 * 
	 */
  String _fieldname;

//  static const _DEFAULT_EXCLUDE = ["model", "previous"];
//  static const _DEFAULT_IDREFS = ["cell"];

  /**
	 * Constructs a new model codec.
	 */
  //	GenericChangeCodec(Object template, String fieldname)
  //	{
  //		this(template, [ "model", "previous" ],
  //				[ "cell" ], null, fieldname);
  //	}

  /**
	 * Constructs a new model codec for the given arguments.
	 */
  GenericChangeCodec(Object template, String fieldname, [List<String> exclude = null,
      List<String> idrefs = null, Map<String, String> mapping = null]) : super(template) {
    this._fieldname = fieldname;
    if (exclude == null) {
      exclude = ["model", "previous"];
    }
    if (idrefs == null) {
      idrefs = ["cell"];
    }
    _init(exclude, idrefs, mapping);
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
  //	@Override
  Object afterDecode(Codec dec, Node node, Object obj) {
    Object cell = _getFieldValue(obj, "cell");

    if (cell is Node) {
      _setFieldValue(obj, "cell", dec.decodeCell(cell as Node, false));
    }

    _setFieldValue(obj, "previous", _getFieldValue(obj, _fieldname));

    return obj;
  }

}
