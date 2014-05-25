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
class TerminalChangeCodec extends ObjectCodec
{

	/**
	 * Constructs a new model codec.
	 */
	TerminalChangeCodec()
	{
		this(new TerminalChange(), new List<String> { "model", "previous" },
				new List<String> { "cell", "terminal" }, null);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	TerminalChangeCodec(Object template, List<String> exclude,
			List<String> idrefs, Map<String, String> mapping)
	{
		super(template, exclude, idrefs, mapping);
	}

	/* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
	@Override
	Object afterDecode(Codec dec, Node node, Object obj)
	{
		if (obj is TerminalChange)
		{
			TerminalChange change = (TerminalChange) obj;

			change.setPrevious(change.getTerminal());
		}

		return obj;
	}

}
