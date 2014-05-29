/**
 * Copyright (c) 2006, Gaudenz Alder
 */
part of graph.io;

//import java.util.Iterator;
//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Codec for mxCells. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
class CellCodec extends ObjectCodec {

  /**
	 * Constructs a new cell codec.
	 */
  //	CellCodec()
  //	{
  //		this(new Cell(), null, [ "parent", "source", "target" ],
  //				null);
  //	}

  /**
	 * Constructs a new cell codec for the given template.
	 */
  //	CellCodec(Object template)
  //	{
  //		this(template, null, null, null);
  //	}

  /**
	 * Constructs a new cell codec for the given arguments.
	 */
  CellCodec(Object template, [List<String> exclude = null, List<String> idrefs = null, Map<String, String> mapping = null]) : super(template, exclude, idrefs, mapping);

  /**
	 * Excludes user objects that are XML nodes.
	 */
  bool isExcluded(Object obj, String attr, Object value, bool write) {
    return _exclude.contains(attr) || (write && attr.equals("value") && value is Node && (value as Node).getNodeType() == Node.ELEMENT_NODE);
  }

  /**
	 * Encodes an Cell and wraps the XML up inside the
	 * XML of the user object (inversion).
	 */
  Node afterEncode(Codec enc, Object obj, Node node) {
    if (obj is Cell) {
      Cell cell = obj as Cell;

      if (cell.getValue() is Node) {
        // Wraps the graphical annotation up in the
        // user object (inversion) by putting the
        // result of the default encoding into
        // a clone of the user object (node type 1)
        // and returning this cloned user object.
        Element tmp = node as Element;
        node = enc.getDocument().importNode(cell.getValue() as Node, true);
        node.appendChild(tmp);

        // Moves the id attribute to the outermost
        // XML node, namely the node which denotes
        // the object boundaries in the file.
        String id = tmp.getAttribute("id");
        (node as Element).setAttribute("id", id);
        tmp.removeAttribute("id");
      }
    }

    return node;
  }

  /**
	 * Decodes an Cell and uses the enclosing XML node as
	 * the user object for the cell (inversion).
	 */
  Node beforeDecode(Codec dec, Node node, Object obj) {
    Element inner = node as Element;

    if (obj is Cell) {
      Cell cell = obj as Cell;
      String classname = getName();
      String nodeName = node.getNodeName();

      // Handles aliased names
      if (!nodeName.equals(classname)) {
        String tmp = CodecRegistry._aliases.get(nodeName);

        if (tmp != null) {
          nodeName = tmp;
        }
      }

      if (!nodeName.equals(classname)) {
        // Passes the inner graphical annotation node to the
        // object codec for further processing of the cell.
        Node tmp = inner.getElementsByTagName(classname).item(0);

        if (tmp != null && tmp.getParentNode() == node) {
          inner = tmp as Element;

          // Removes annotation and whitespace from node
          Node tmp2 = tmp.getPreviousSibling();

          while (tmp2 != null && tmp2.getNodeType() == Node.TEXT_NODE) {
            Node tmp3 = tmp2.getPreviousSibling();

            if (tmp2.getTextContent().trim().length == 0) {
              tmp2.getParentNode().removeChild(tmp2);
            }

            tmp2 = tmp3;
          }

          // Removes more whitespace
          tmp2 = tmp.getNextSibling();

          while (tmp2 != null && tmp2.getNodeType() == Node.TEXT_NODE) {
            Node tmp3 = tmp2.getPreviousSibling();

            if (tmp2.getTextContent().trim().length == 0) {
              tmp2.getParentNode().removeChild(tmp2);
            }

            tmp2 = tmp3;
          }

          tmp.getParentNode().removeChild(tmp);
        } else {
          inner = null;
        }

        // Creates the user object out of the XML node
        Element value = node.cloneNode(true) as Element;
        cell.setValue(value);
        String id = value.getAttribute("id");

        if (id != null) {
          cell.setId(id);
          value.removeAttribute("id");
        }
      } else {
        cell.setId((node as Element).getAttribute("id"));
      }

      // Preprocesses and removes all Id-references
      // in order to use the correct encoder (this)
      // for the known references to cells (all).
      if (inner != null && _idrefs != null) {
        Iterator<String> it = _idrefs.iterator();

        while (it.moveNext()) {
          String attr = it.current();
          String ref = inner.getAttribute(attr);

          if (ref != null && ref.length > 0) {
            inner.removeAttribute(attr);
            Object object = dec._objects.get(ref);

            if (object == null) {
              object = dec.lookup(ref);
            }

            if (object == null) {
              // Needs to decode forward reference
              Node element = dec.getElementById(ref);

              if (element != null) {
                ObjectCodec decoder = CodecRegistry.getCodec(element.getNodeName());

                if (decoder == null) {
                  decoder = this;
                }

                object = decoder.decode(dec, element);
              }
            }

            _setFieldValue(obj, attr, object);
          }
        }
      }
    }

    return inner;
  }

}
