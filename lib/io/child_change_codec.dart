/**
 * Copyright (c) 2006, Gaudenz Alder
 */
part of graph.io;

//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Codec for mxChildChanges. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
class ChildChangeCodec extends ObjectCodec {

  /**
	 * Constructs a new model codec.
	 */
//  ChildChangeCodec() {
//    this(new ChildChange(), ["model", "child", "previousIndex"], ["parent", "previous"], null);
//  }

  /**
	 * Constructs a new model codec for the given arguments.
	 */
  ChildChangeCodec([Object template=null, List<String> exclude=null, List<String> idrefs=null,
      Map<String, String> mapping=null]) : super(template) {
    if (template == null) {
      this._template = new ChildChange();
    }
    if (exclude == null) {
      exclude = ["model", "child", "previousIndex"];
    }
    if (idrefs == null) {
      idrefs = ["parent", "previous"];
    }
    _init(exclude, idrefs, mapping);
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#isReference(java.lang.Object, java.lang.String, java.lang.Object, boolean)
	 */
  //	@Override
  bool isReference(Object obj, String attr, Object value, bool isWrite) {
    if (attr == "child" && obj is ChildChange && (obj.getPrevious() != null || !isWrite)) {
      return true;
    }

    return _idrefs.contains(attr);
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterEncode(graph.io.Codec, java.lang.Object, org.w3c.dom.Node)
	 */
  //	@Override
  Node afterEncode(Codec enc, Object obj, Node node) {
    if (obj is ChildChange) {
      ChildChange change = obj;
      Object child = change.getChild();

      if (isReference(obj, "child", child, true)) {
        // Encodes as reference (id)
        Codec.setAttribute(node, "child", enc.getId(child));
      } else {
        // At this point, the encoder is no longer able to know which cells
        // are new, so we have to encode the complete cell hierarchy and
        // ignore the ones that are already there at decoding time. Note:
        // This can only be resolved by moving the notify event into the
        // execute of the edit.
        enc.encodeCell(child as ICell, node, true);
      }
    }

    return node;
  }

  /**
	 * Reads the cells into the graph model. All cells are children of the root
	 * element in the node.
	 */
  Node beforeDecode(Codec dec, Node node, Object into) {
    if (into is ChildChange) {
      ChildChange change = into;

      if (node.firstChild != null && node.firstChild.nodeType == Node.ELEMENT_NODE) {
        // Makes sure the original node isn't modified
        node = node.clone(true);

        Node tmp = node.firstChild;
        change.setChild(dec.decodeCell(tmp, false));

        Node tmp2 = tmp.nextNode;
        //tmp.getParentNode().removeChild(tmp);
        tmp.remove();
        tmp = tmp2;

        while (tmp != null) {
          tmp2 = tmp.nextNode;

          if (tmp.nodeType == Node.ELEMENT_NODE) {
            // Ignores all existing cells because those do not need
            // to be re-inserted into the model. Since the encoded
            // version of these cells contains the new parent, this
            // would leave to an inconsistent state on the model
            // (ie. a parent change without a call to
            // parentForCellChanged).
            String id = (tmp as Element).getAttribute("id");

            if (dec.lookup(id) == null) {
              dec.decodeCell(tmp, true);
            }
          }

          //tmp.getParentNode().removeChild(tmp);
          tmp.remove();
          tmp = tmp2;
        }
      } else {
        String childRef = (node as Element).getAttribute("child");
        change.setChild(dec.getObject(childRef) as ICell);
      }
    }

    return node;
  }

  /* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
  //	@Override
  Object afterDecode(Codec dec, Node node, Object obj) {
    if (obj is ChildChange) {
      ChildChange change = obj;

      // Cells are encoded here after a complete transaction so the previous
      // parent must be restored on the cell for the case where the cell was
      // added. This is needed for the local model to identify the cell as a
      // new cell and register the ID.
      (change.getChild() as ICell).setParent(change.getPrevious() as ICell);
      change.setPrevious(change.getParent());
      change.setPreviousIndex(change.getIndex());
    }

    return obj;
  }

}
