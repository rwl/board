/**
 * Copyright (c) 2006-2013, Gaudenz Alder, David Benson
 */
part of graph.io;

import '../model/model.dart' show ICell;

//import java.util.Map;

//import org.w3c.dom.Node;

/**
 * Codec for mxChildChanges. This class is created and registered
 * dynamically at load time and used implicitly via Codec
 * and the CodecRegistry.
 */
class RootChangeCodec extends ObjectCodec
{

	/**
	 * Constructs a new model codec.
	 */
	RootChangeCodec()
	{
		this(new RootChange(), new List<String> { "model", "previous", "root" },
				null, null);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	RootChangeCodec(Object template, List<String> exclude,
			List<String> idrefs, Map<String, String> mapping)
	{
		super(template, exclude, idrefs, mapping);
	}

	/* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterEncode(graph.io.Codec, java.lang.Object, org.w3c.dom.Node)
	 */
	@Override
	Node afterEncode(Codec enc, Object obj, Node node)
	{
		if (obj is RootChange)
		{
			enc.encodeCell((ICell) ((RootChange) obj).getRoot(), node, true);
		}

		return node;
	}

	/**
	 * Reads the cells into the graph model. All cells are children of the root
	 * element in the node.
	 */
	Node beforeDecode(Codec dec, Node node, Object into)
	{
		if (into is RootChange)
		{
			RootChange change = (RootChange) into;

			if (node.getFirstChild() != null
					&& node.getFirstChild().getNodeType() == Node.ELEMENT_NODE)
			{
				// Makes sure the original node isn't modified
				node = node.cloneNode(true);

				Node tmp = node.getFirstChild();
				change.setRoot(dec.decodeCell(tmp, false));

				Node tmp2 = tmp.getNextSibling();
				tmp.getParentNode().removeChild(tmp);
				tmp = tmp2;

				while (tmp != null)
				{
					tmp2 = tmp.getNextSibling();

					if (tmp.getNodeType() == Node.ELEMENT_NODE)
					{
						dec.decodeCell(tmp, true);
					}

					tmp.getParentNode().removeChild(tmp);
					tmp = tmp2;
				}
			}
		}

		return node;
	}

	/* (non-Javadoc)
	 * @see graph.io.ObjectCodec#afterDecode(graph.io.Codec, org.w3c.dom.Node, java.lang.Object)
	 */
	@Override
	Object afterDecode(Codec dec, Node node, Object obj)
	{
		if (obj is RootChange)
		{
			RootChange change = (RootChange) obj;
			change.setPrevious(change.getRoot());
		}

		return obj;
	}

}
