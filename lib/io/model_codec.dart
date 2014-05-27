/**
 * Copyright (c) 2006-2013, Gaudenz Alder, David Benson
 */
part of graph.io;

//import java.util.Map;

//import org.w3c.dom.Element;
//import org.w3c.dom.Node;

/**
 * Codec for mxGraphModels. This class is created and registered
 * dynamically at load time and used implicitly via Codec
 * and the CodecRegistry.
 */
class ModelCodec extends ObjectCodec
{

	/**
	 * Constructs a new model codec.
	 */
	ModelCodec()
	{
		this(new GraphModel());
	}

	/**
	 * Constructs a new model codec for the given template.
	 */
	ModelCodec(Object template)
	{
		this(template, null, null, null);
	}

	/**
	 * Constructs a new model codec for the given arguments.
	 */
	ModelCodec(Object template, List<String> exclude, List<String> idrefs,
			Map<String, String> mapping) : super(template, exclude, idrefs, mapping);

	/**
	 * Encodes the given GraphModel by writing a (flat) XML sequence
	 * of cell nodes as produced by the CellCodec. The sequence is
	 * wrapped-up in a node with the name root.
	 */
	void _encodeObject(Codec enc, Object obj, Node node)
	{
		if (obj is GraphModel)
		{
			Node rootNode = enc._document.createElement("root");
			GraphModel model = obj as GraphModel;
			enc.encodeCell(model.getRoot() as ICell, rootNode, true);
			node.appendChild(rootNode);
		}
	}

	/**
	 * Reads the cells into the graph model. All cells are children of the root
	 * element in the node.
	 */
	Node beforeDecode(Codec dec, Node node, Object into)
	{
		if (node is Element)
		{
			Element elt = node as Element;
			GraphModel model = null;

			if (into is GraphModel)
			{
				model = into as GraphModel;
			}
			else
			{
				model = new GraphModel();
			}

			// Reads the cells into the graph model. All cells
			// are children of the root element in the node.
			Node root = elt.getElementsByTagName("root").item(0);
			ICell rootCell = null;

			if (root != null)
			{
				Node tmp = root.getFirstChild();

				while (tmp != null)
				{
					ICell cell = dec.decodeCell(tmp, true);

					if (cell != null && cell.getParent() == null)
					{
						rootCell = cell;
					}

					tmp = tmp.getNextSibling();
				}

				root.getParentNode().removeChild(root);
			}

			// Sets the root on the model if one has been decoded
			if (rootCell != null)
			{
				model.setRoot(rootCell);
			}
		}

		return node;
	}

}
