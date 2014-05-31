/**
 * Copyright (c) 2006-2013, Gaudenz Alder, David Benson
 */
part of graph.io;

//import java.util.Map;

//import org.w3c.dom.Node;

/**
 * Codec for mxChildChanges. This class is created and registered
 * dynamically at load time and used implicitly via Codec
 * and the CodecRegistry.
 */
class RootChangeCodec extends ObjectCodec {

//  static const List<String> _DEFAULT_EXCLUDE = ["model", "previous", "root"];

  /**
	 * Constructs a new model codec.
	 */
  //	RootChangeCodec()
  //	{
  //		this(new RootChange(), ,
  //				null, null);
  //	}

  /**
	 * Constructs a new model codec for the given arguments.
	 */
  RootChangeCodec([Object template=null, List<String> exclude = null, List<String> idrefs = null,
                   Map<String, String> mapping = null]) : super(template, exclude, idrefs, mapping) {
    if (template == null) {
      this._template = new RootChange();
    }
    if (exclude == null) {
      exclude = ["model", "previous", "root"];
    }
    _init(exclude, idrefs, mapping);
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterEncode(graph.io.Codec, java.lang.Object, org.w3c.dom.Node)
	 */
  //	@Override
  Node afterEncode(Codec enc, Object obj, Node node) {
    if (obj is RootChange) {
      enc.encodeCell((obj as RootChange).getRoot() as ICell, node, true);
    }

    return node;
  }

  /**
	 * Reads the cells into the graph model. All cells are children of the root
	 * element in the node.
	 */
  Node beforeDecode(Codec dec, Node node, Object into) {
    if (into is RootChange) {
      RootChange change = into as RootChange;

      if (node.firstChild != null && node.firstChild.nodeType == Node.ELEMENT_NODE) {
        // Makes sure the original node isn't modified
        node = node.clone(true);

        Node tmp = node.firstChild;
        change.setRoot(dec.decodeCell(tmp, false));

        Node tmp2 = tmp.nextNode;
        //tmp.parentNode.removeChild(tmp);
        tmp.remove();
        tmp = tmp2;

        while (tmp != null) {
          tmp2 = tmp.nextNode;

          if (tmp.nodeType == Node.ELEMENT_NODE) {
            dec.decodeCell(tmp, true);
          }

          //tmp.parentNode.removeChild(tmp);
          tmp.remove();
          tmp = tmp2;
        }
      }
    }

    return node;
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
  //	@Override
  Object afterDecode(Codec dec, Node node, Object obj) {
    if (obj is RootChange) {
      RootChange change = obj as RootChange;
      change.setPrevious(change.getRoot());
    }

    return obj;
  }

}
