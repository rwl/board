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
class TerminalChangeCodec extends ObjectCodec {
  
  /**
	 * Constructs a new model codec for the given arguments.
	 */
  TerminalChangeCodec([Object template=null, List<String> exclude = null,
      List<String> idrefs = null, Map<String, String> mapping = null]) : super(template) {
    if (template == null) {
      this._template = new TerminalChange();
    }
    if (exclude == null) {
      exclude = ["model", "previous"];
    }
    if (idrefs == null) {
      idrefs = ["cell", "terminal"];
    }
    _init(exclude, idrefs, mapping);
  }

  //@Override
  Object afterDecode(Codec dec, Node node, Object obj) {
    if (obj is TerminalChange) {
      TerminalChange change = obj as TerminalChange;

      change.setPrevious(change.getTerminal());
    }

    return obj;
  }

}
