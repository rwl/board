/**
 * $Id: TerminalChangeCodec.java,v 1.1 2012/11/15 13:26:47 gaudenz Exp $
 * Copyright (c) 2006, Gaudenz Alder
 */
package graph.io;

import graph.model.GraphModel.TerminalChange;

import java.util.Map;

import org.w3c.dom.Node;

/**
 * Codec for mxChildChanges. This class is created and registered
 * dynamically at load time and used implicitely via Codec
 * and the CodecRegistry.
 */
public class TerminalChangeCodec extends ObjectCodec
{

	/**
	 * Constructs a new model codec.
	 */
	public TerminalChangeCodec()
	{
		this(new TerminalChange(), new String[] { "model", "previous" },
				new String[] { "cell", "terminal" }, null);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	public TerminalChangeCodec(Object template, String[] exclude,
			String[] idrefs, Map<String, String> mapping)
	{
		super(template, exclude, idrefs, mapping);
	}

	/* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
	@Override
	public Object afterDecode(Codec dec, Node node, Object obj)
	{
		if (obj instanceof TerminalChange)
		{
			TerminalChange change = (TerminalChange) obj;

			change.setPrevious(change.getTerminal());
		}

		return obj;
	}

}
