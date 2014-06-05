/**
 * Copyright (c) 2006, Gaudenz Alder
 */
part of graph.io;


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
  CellCodec([Object template=null, List<String> exclude = null, List<String> idrefs = null,
      Map<String, String> mapping = null]) : super(template) {
    if (template == null) {
      this._template = new Cell();
      if (idrefs == null) {
        idrefs = [ "parent", "source", "target" ];
      }
    }
    _init(exclude, idrefs, mapping);
  }

  /**
   * Excludes user objects that are XML nodes.
   */
  bool isExcluded(Object obj, String attr, Object value, bool write) {
    return _exclude.contains(attr) || (write && attr == "value" && value is Node && value.nodeType == Node.ELEMENT_NODE);
  }

  /**
   * Encodes an Cell and wraps the XML up inside the
   * XML of the user object (inversion).
   */
  Node afterEncode(Codec enc, Object obj, Node node) {
    if (obj is Cell) {
      Cell cell = obj;

      if (cell.getValue() is Node) {
        // Wraps the graphical annotation up in the
        // user object (inversion) by putting the
        // result of the default encoding into
        // a clone of the user object (node type 1)
        // and returning this cloned user object.
        Element tmp = node as Element;
        node = enc.getDocument().importNode(cell.getValue() as Node, true);
        node.append(tmp);

        // Moves the id attribute to the outermost
        // XML node, namely the node which denotes
        // the object boundaries in the file.
        String id = tmp.getAttribute("id");
        (node as Element).setAttribute("id", id);
        tmp.attributes.remove("id");
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
      Cell cell = obj;
      String classname = getName();
      String nodeName = node.nodeName;

      // Handles aliased names
      if (nodeName != classname) {
        String tmp = CodecRegistry._aliases[nodeName];

        if (tmp != null) {
          nodeName = tmp;
        }
      }

      if (nodeName != classname) {
        // Passes the inner graphical annotation node to the
        // object codec for further processing of the cell.
        Node tmp = inner.querySelectorAll(classname)[0];

        if (tmp != null && tmp.parentNode == node) {
          inner = tmp as Element;

          // Removes annotation and whitespace from node
          Node tmp2 = tmp.previousNode;

          while (tmp2 != null && tmp2.nodeType == Node.TEXT_NODE) {
            Node tmp3 = tmp2.previousNode;

            if (tmp2.text.trim().length == 0) {
              //tmp2.parentNode.removeChild(tmp2);
              tmp2.remove();
            }

            tmp2 = tmp3;
          }

          // Removes more whitespace
          tmp2 = tmp.nextNode;

          while (tmp2 != null && tmp2.nodeType == Node.TEXT_NODE) {
            Node tmp3 = tmp2.previousNode;

            if (tmp2.text.trim().length == 0) {
              //tmp2.parentNode.removeChild(tmp2);
              tmp2.remove();
            }

            tmp2 = tmp3;
          }

          //tmp.parentNode.removeChild(tmp);
          tmp.remove();
        } else {
          inner = null;
        }

        // Creates the user object out of the XML node
        Element value = node.clone(true) as Element;
        cell.setValue(value);
        String id = value.getAttribute("id");

        if (id != null) {
          cell.setId(id);
          value.attributes.remove("id");
        }
      } else {
        cell.setId((node as Element).getAttribute("id"));
      }

      // Preprocesses and removes all Id-references
      // in order to use the correct encoder (this)
      // for the known references to cells (all).
      if (inner != null && _idrefs != null) {
        Iterator<String> it = _idrefs.iterator;

        while (it.moveNext()) {
          String attr = it.current;
          String ref = inner.getAttribute(attr);

          if (ref != null && ref.length > 0) {
            inner.attributes.remove(attr);
            Object object = dec._objects[ref];

            if (object == null) {
              object = dec.lookup(ref);
            }

            if (object == null) {
              // Needs to decode forward reference
              Node element = dec.getElementById(ref);

              if (element != null) {
                ObjectCodec decoder = CodecRegistry.getCodec(element.nodeName);

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
