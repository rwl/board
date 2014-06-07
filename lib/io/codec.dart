/**
 * Copyright (c) 2012, JGraph Ltd
 */
part of graph.io;


//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * XML codec for Java object graphs. In order to resolve forward references
 * when reading files the XML document that contains the data must be passed
 * to the constructor.
 */
class Codec {

  /**
   * Holds the owner document of the codec.
   */
  Document _document;

  /**
   * Maps from IDs to objects.
   */
  Map<String, Object> _objects = new Map<String, Object>();

  /**
   * Specifies if default values should be encoded. Default is false.
   */
  bool _encodeDefaults = false;

  /**
   * Constructs an XML encoder/decoder with a new owner document.
   */
  //	Codec()
  //	{
  //		this(DomUtils.createDocument());
  //	}

  /**
   * Constructs an XML encoder/decoder for the specified owner document.
   * 
   * @param document Optional XML document that contains the data. If no document
   * is specified then a new document is created using Utils.createDocument
   */
  Codec([Document document = null]) {
    if (document == null) {
      document = DomUtils.createDocument();
    }

    this._document = document;
  }

  /**
   * Returns the owner document of the codec.
   * 
   * @return Returns the owner document.
   */
  Document getDocument() {
    return _document;
  }

  /**
   * Sets the owner document of the codec.
   */
  void setDocument(Document value) {
    _document = value;
  }

  /**
   * Returns if default values of member variables should be encoded.
   */
  bool isEncodeDefaults() {
    return _encodeDefaults;
  }

  /**
   * Sets if default values of member variables should be encoded.
   */
  void setEncodeDefaults(bool encodeDefaults) {
    this._encodeDefaults = encodeDefaults;
  }

  /**
   * Returns the object lookup table.
   */
  Map<String, Object> getObjects() {
    return _objects;
  }

  /**
   * Assoiates the given object with the given ID.
   * 
   * @param id ID for the object to be associated with.
   * @param object Object to be associated with the ID.
   * @return Returns the given object.
   */
  Object putObject(String id, Object object) {
    return _objects[id] = object;
  }

  /**
   * Returns the decoded object for the element with the specified ID in
   * {@link #_document}. If the object is not known then {@link #lookup(String)}
   * is used to find an object. If no object is found, then the element with
   * the respective ID from the document is parsed using {@link #decode(Node)}.
   * 
   * @param id ID of the object to be returned.
   * @return Returns the object for the given ID.
   */
  Object getObject(String id) {
    Object obj = null;

    if (id != null) {
      obj = _objects[id];

      if (obj == null) {
        obj = lookup(id);

        if (obj == null) {
          Node node = getElementById(id);

          if (node != null) {
            obj = decode(node);
          }
        }
      }
    }

    return obj;
  }

  /**
   * Hook for subclassers to implement a custom lookup mechanism for cell IDs.
   * This implementation always returns null.
   * 
   * @param id ID of the object to be returned.
   * @return Returns the object for the given ID.
   */
  Object lookup(String id) {
    return null;
  }

  /**
   * Returns the element with the given ID from the document.
   * 
   * @param id ID of the element to be returned.
   * @return Returns the element for the given ID.
   */
  //	Node getElementById(String id)
  //	{
  //		return getElementById(id, null);
  //	}

  /**
   * Returns the element with the given ID from document. The optional attr
   * argument specifies the name of the ID attribute. Default is "id". The
   * XPath expression used to find the element is [@attr='arg'] where attr
   * is the name of the ID attribute and arg is the given id.
   * 
   * Parameters:
   * 
   * id - String that contains the ID.
   * attr - Optional string for the attributename. Default is id.
   */
  Node getElementById(String id, [String attr = null]) {
    if (attr == null) {
      attr = "id";
    }

    String expr = "//*[@" + attr + "='" + id + "']";

    return Utils.selectSingleNode(_document, expr);
  }

  /**
   * Returns the ID of the specified object. This implementation calls
   * reference first and if that returns null handles the object as an
   * Cell by returning their IDs using Cell.getId. If no ID exists for
   * the given cell, then an on-the-fly ID is generated using
   * CellPath.create.
   * 
   * @param obj Object to return the ID for.
   * @return Returns the ID for the given object.
   */
  String getId(Object obj) {
    String id = null;

    if (obj != null) {
      id = reference(obj);

      if (id == null && obj is ICell) {
        id = obj.getId();

        if (id == null) {
          // Uses an on-the-fly Id
          id = CellPath.create(obj);

          if (id.length == 0) {
            id = "root";
          }
        }
      }
    }

    return id;
  }

  /**
   * Hook for subclassers to implement a custom method for retrieving IDs from
   * objects. This implementation always returns null.
   * 
   * @param obj Object whose ID should be returned.
   * @return Returns the ID for the given object.
   */
  String reference(Object obj) {
    return null;
  }

  /**
   * Encodes the specified object and returns the resulting XML node.
   * 
   * @param obj Object to be encoded.
   * @return Returns an XML node that represents the given object.
   */
  Node encode(Object obj) {
    Node node = null;

    if (obj != null) {
      String name = CodecRegistry.getName(obj);
      ObjectCodec enc = CodecRegistry.getCodec(name);

      if (enc != null) {
        node = enc.encode(this, obj);
      } else {
        if (obj is Node) {
          node = obj.clone(true);
        } else {
          print("No codec for " + name);
        }
      }
    }

    return node;
  }

  /**
   * Decodes the given XML node using {@link #decode(Node, Object)}.
   * 
   * @param node XML node to be decoded.
   * @return Returns an object that represents the given node.
   */
  //	Object decode(Node node)
  //	{
  //		return decode(node, null);
  //	}

  /**
   * Decodes the given XML node. The optional "into" argument specifies an
   * existing object to be used. If no object is given, then a new
   * instance is created using the constructor from the codec.
   * 
   * The function returns the passed in object or the new instance if no
   * object was given.
   * 
   * @param node XML node to be decoded.
   * @param into Optional object to be decodec into.
   * @return Returns an object that represents the given node.
   */
  Object decode(Node node, [Object into = null]) {
    Object obj = null;

    if (node != null && node.nodeType == Node.ELEMENT_NODE) {
      ObjectCodec codec = CodecRegistry.getCodec(node.nodeName);

      try {
        if (codec != null) {
          obj = codec.decode(this, node, into);
        } else {
          obj = node.clone(true);
          (obj as Element).attributes.remove("as");
        }
      } on Exception catch (e, st) {
        print("Cannot decode ${node.nodeName}: $e");
        print(st);
      }
    }

    return obj;
  }

  /**
   * Encoding of cell hierarchies is built-into the core, but is a
   * higher-level function that needs to be explicitely used by the
   * respective object encoders (eg. ModelCodec, ChildChangeCodec
   * and RootChangeCodec). This implementation writes the given cell
   * and its children as a (flat) sequence into the given node. The
   * children are not encoded if the optional includeChildren is false.
   * The function is in charge of adding the result into the given node
   * and has no return value.
   * 
   * @param cell Cell to be encoded.
   * @param node Parent XML node to add the encoded cell into.
   * @param includeChildren bool indicating if the method
   * should include all descendents.
   */
  void encodeCell(ICell cell, Node node, bool includeChildren) {
    node.append(encode(cell));

    if (includeChildren) {
      int childCount = cell.getChildCount();

      for (int i = 0; i < childCount; i++) {
        encodeCell(cell.getChildAt(i), node, includeChildren);
      }
    }
  }

  /**
   * Decodes cells that have been encoded using inversion, ie. where the
   * user object is the enclosing node in the XML, and restores the group
   * and graph structure in the cells. Returns a new <Cell> instance
   * that represents the given node.
   * 
   * @param node XML node that contains the cell data.
   * @param restoreStructures bool indicating whether the graph
   * structure should be restored by calling insert and insertEdge on the
   * parent and terminals, respectively.
   * @return Graph cell that represents the given node.
   */
  ICell decodeCell(Node node, bool restoreStructures) {
    ICell cell = null;

    if (node != null && node.nodeType == Node.ELEMENT_NODE) {
      // Tries to find a codec for the given node name. If that does
      // not return a codec then the node is the user object (an XML node
      // that contains the Cell, aka inversion).
      ObjectCodec decoder = CodecRegistry.getCodec(node.nodeName);

      // Tries to find the codec for the cell inside the user object.
      // This assumes all node names inside the user object are either
      // not registered or they correspond to a class for cells.
      if (!(decoder is CellCodec)) {
        Node child = node.firstChild;

        while (child != null && !(decoder is CellCodec)) {
          decoder = CodecRegistry.getCodec(child.nodeName);
          child = child.nextNode;
        }

        throw new UnimplementedError("Cell.class.getSimpleName()");
        String name;// = Cell.class.getSimpleName();
        decoder = CodecRegistry.getCodec(name);
      }

      if (!(decoder is CellCodec)) {
        throw new UnimplementedError("Cell.class.getSimpleName()");
        String name;// = Cell.class.getSimpleName();
        decoder = CodecRegistry.getCodec(name);
      }

      cell = decoder.decode(this, node) as ICell;

      if (restoreStructures) {
        insertIntoGraph(cell);
      }
    }

    return cell;
  }

  /**
   * Inserts the given cell into its parent and terminal cells.
   */
  void insertIntoGraph(ICell cell) {
    ICell parent = cell.getParent();
    ICell source = cell.getTerminal(true);
    ICell target = cell.getTerminal(false);

    // Fixes possible inconsistencies during insert into graph
    cell.setTerminal(null, false);
    cell.setTerminal(null, true);
    cell.setParent(null);

    if (parent != null) {
      parent.insert(cell);
    }

    if (source != null) {
      source.insertEdge(cell, true);
    }

    if (target != null) {
      target.insertEdge(cell, false);
    }
  }

  /**
   * Sets the attribute on the specified node to value. This is a
   * helper method that makes sure the attribute and value arguments
   * are not null.
   *
   * @param node XML node to set the attribute for.
   * @param attribute Name of the attribute whose value should be set.
   * @param value New value of the attribute.
   */
  static void setAttribute(Node node, String attribute, Object value) {
    if (node.nodeType == Node.ELEMENT_NODE && attribute != null && value != null) {
      (node as Element).setAttribute(attribute, value.toString());
    }
  }

}
