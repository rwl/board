/**
 * Copyright (c) 2008, Gaudenz Alder
 */
part of graph.swing.util;

//import java.awt.datatransfer.DataFlavor;
//import java.awt.datatransfer.Transferable;
//import java.awt.datatransfer.UnsupportedFlavorException;
//import java.awt.image.RenderedImage;
//import java.io.ByteArrayInputStream;
//import java.io.ByteArrayOutputStream;
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.Reader;
//import java.io.Serializable;
//import java.io.StringReader;

//import javax.imageio.ImageIO;
//import javax.swing.ImageIcon;
//import javax.swing.plaf.UIResource;

/**
 *
 */
class GraphTransferable implements Transferable, UIResource,
		Serializable
{

	/**
	 * 
	 */
//	static final long serialVersionUID = 5123819419918087664L;

	/**
	 * Global switch to disable image support in transferables. Set this to false as a workaround
	 * for Data translation failed: not an image format in Java 1.7 on Mac OS X.
	 */
	static bool enableImageSupport = true;

	/**
	 * Serialized Data Flavor. Use the following code to switch to local 
	 * reference flavor:
	 * <code>
	 * try
	 * {
	 *   GraphTransferable.dataFlavor = new DataFlavor(DataFlavor.javaJVMLocalObjectMimeType
	 *     + "; class=graph.swing.util.GraphTransferable");
	 * }
	 * catch (ClassNotFoundException cnfe)
	 * {
	 *   // do nothing
	 * }
	 * </code>
	 * 
	 * If you get a class not found exception, try the following instead:
	 * <code>
	 * GraphTransferable.dataFlavor = new DataFlavor(DataFlavor.javaJVMLocalObjectMimeType
	 *   + "; class=graph.swing.util.GraphTransferable", null,
	 *   new graph.swing.util.GraphTransferable(null, null).getClass().getClassLoader());
	 * </code>
	 */
	static DataFlavor dataFlavor;

	/**
	 * 
	 */
	static List<DataFlavor> _htmlFlavors;

	/**
	 * 
	 */
	static List<DataFlavor> _stringFlavors;

	/**
	 * 
	 */
	static List<DataFlavor> _plainFlavors;

	/**
	 * 
	 */
	static List<DataFlavor> _imageFlavors;

	/**
	 * 
	 */
	List<Object> _cells;

	/**
	 * 
	 */
	Rect _bounds;

	/**
	 * 
	 */
	ImageIcon _image;

	/**
	 * 
	 */
	GraphTransferable(List<Object> cells, Rect bounds)
	{
		this(cells, bounds, null);
	}

	/**
	 * 
	 */
	GraphTransferable(List<Object> cells, Rect bounds,
			ImageIcon image)
	{
		this._cells = cells;
		this._bounds = bounds;
		this._image = image;
	}

	/**
	 * @return Returns the cells.
	 */
	List<Object> getCells()
	{
		return _cells;
	}

	/**
	 * Returns the unscaled, untranslated bounding box of the cells.
	 */
	Rect getBounds()
	{
		return _bounds;
	}

	/**
	 * 
	 */
	ImageIcon getImage()
	{
		return _image;
	}

	/**
	 * 
	 */
    List<DataFlavor> getTransferDataFlavors()
	{
        List<DataFlavor> richerFlavors = _getRicherFlavors();

		int nRicher = (richerFlavors != null) ? richerFlavors.length : 0;
		int nHtml = (_isHtmlSupported()) ? _htmlFlavors.length : 0;
		int nPlain = (_isPlainSupported()) ? _plainFlavors.length : 0;
		int nString = (_isPlainSupported()) ? _stringFlavors.length : 0;
		int nImage = (isImageSupported()) ? _imageFlavors.length : 0;
		int nFlavors = nRicher + nHtml + nPlain + nString + nImage;

        List<DataFlavor> flavors = new List<DataFlavor>(nFlavors);

		// fill in the array
		int nDone = 0;

		if (nRicher > 0)
		{
			System.arraycopy(richerFlavors, 0, flavors, nDone, nRicher);
			nDone += nRicher;
		}

		if (nHtml > 0)
		{
			System.arraycopy(_htmlFlavors, 0, flavors, nDone, nHtml);
			nDone += nHtml;
		}

		if (nPlain > 0)
		{
			System.arraycopy(_plainFlavors, 0, flavors, nDone, nPlain);
			nDone += nPlain;
		}

		if (nString > 0)
		{
			System.arraycopy(_stringFlavors, 0, flavors, nDone, nString);
			nDone += nString;
		}

		if (nImage > 0)
		{
			System.arraycopy(_imageFlavors, 0, flavors, nDone, nImage);
			nDone += nImage;
		}

		return flavors;
	}

	/**
	 * Some subclasses will have flavors that are more descriptive than HTML or
	 * plain text. If this method returns a non-null value, it will be placed at
	 * the start of the array of supported flavors.
	 */
    List<DataFlavor> _getRicherFlavors()
	{
		return [ dataFlavor ];
	}

	/**
	 * Returns whether or not the specified data flavor is supported for this
	 * object.
	 * 
	 * @param flavor
	 *            the requested flavor for the data
	 * @return bool indicating whether or not the data flavor is supported
	 */
	bool isDataFlavorSupported(DataFlavor flavor)
	{
        List<DataFlavor> flavors = getTransferDataFlavors();

		for (int i = 0; i < flavors.length; i++)
		{
			if (flavors[i] != null && flavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Returns an object which represents the data to be transferred. The class
	 * of the object returned is defined by the representation class of the
	 * flavor.
	 * 
	 * @param flavor
	 *            the requested flavor for the data
	 * @see DataFlavor#getRepresentationClass
	 * @exception IOException
	 *                if the data is no longer available in the requested
	 *                flavor.
	 * @exception UnsupportedFlavorException
	 *                if the requested data flavor is not supported.
	 */
	Object getTransferData(DataFlavor flavor)
			//throws UnsupportedFlavorException, IOException
	{
		if (_isRicherFlavor(flavor))
		{
			return getRicherData(flavor);
		}
		else if (_isImageFlavor(flavor))
		{
			if (_image != null && _image.getImage() is RenderedImage)
			{
				if (flavor.equals(DataFlavor.imageFlavor))
				{
					return _image.getImage();
				}
				else
				{
					ByteArrayOutputStream stream = new ByteArrayOutputStream();
					ImageIO.write(_image.getImage() as RenderedImage, "bmp",
							stream);

					return new ByteArrayInputStream(stream.toByteArray());
				}
			}
		}
		else if (_isHtmlFlavor(flavor))
		{
			String data = _getHtmlData();
			data = (data == null) ? "" : data;

			if (flavor.getRepresentationClass() is String)
			{
				return data;
			}
			else if (flavor.getRepresentationClass() is Reader)
			{
				return new StringReader(data);
			}
			else if (flavor.getRepresentationClass() is InputStream)
			{
				return new ByteArrayInputStream(data.getBytes());
			}
			// fall through to unsupported
		}
		else if (_isPlainFlavor(flavor))
		{
			String data = _getPlainData();
			data = (data == null) ? "" : data;

			if (flavor.getRepresentationClass() is String)
			{
				return data;
			}
			else if (flavor.getRepresentationClass() is Reader)
			{
				return new StringReader(data);
			}
			else if (flavor.getRepresentationClass() is InputStream)
			{
				return new ByteArrayInputStream(data.getBytes());
			}
			// fall through to unsupported

		}
		else if (_isStringFlavor(flavor))
		{
			String data = _getPlainData();
			data = (data == null) ? "" : data;

			return data;
		}

		throw new UnsupportedFlavorException(flavor);
	}

	/**
	 * 
	 * @param flavor
	 * @return Returns true if the given flavor is a richer flavor of this
	 * transferable.
	 */
	bool _isRicherFlavor(DataFlavor flavor)
	{
		List<DataFlavor> richerFlavors = _getRicherFlavors();
		int nFlavors = (richerFlavors != null) ? richerFlavors.length : 0;

		for (int i = 0; i < nFlavors; i++)
		{
			if (richerFlavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * 
	 * @param flavor
	 * @return the richer data flavor of this and the specified
	 * @throws UnsupportedFlavorException
	 */
	Object getRicherData(DataFlavor flavor)
			//throws UnsupportedFlavorException
	{
		if (flavor.equals(dataFlavor))
		{
			return this;
		}
		else
		{
			throw new UnsupportedFlavorException(flavor);
		}
	}

	/**
	 * Returns whether or not the specified data flavor is an HTML flavor that
	 * is supported.
	 * 
	 * @param flavor
	 *            the requested flavor for the data
	 * @return bool indicating whether or not the data flavor is supported
	 */
	bool _isHtmlFlavor(DataFlavor flavor)
	{
		List<DataFlavor> flavors = _htmlFlavors;

		for (int i = 0; i < flavors.length; i++)
		{
			if (flavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Whether the HTML flavors are offered. If so, the method getHTMLData
	 * should be implemented to provide something reasonable.
	 */
	bool _isHtmlSupported()
	{
		return false;
	}

	/**
	 * Fetch the data in a text/html format
	 */
	String _getHtmlData()
	{
		return null;
	}

	/**
	 * 
	 * @param flavor
	 * @return Returns true if the given flavor is an image flavor of this
	 * transferable.
	 */
	bool _isImageFlavor(DataFlavor flavor)
	{
		int nFlavors = (_imageFlavors != null) ? _imageFlavors.length : 0;

		for (int i = 0; i < nFlavors; i++)
		{
			if (_imageFlavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * 
	 */
	bool isImageSupported()
	{
		return enableImageSupport && _image != null;
	}

	/**
	 * Returns whether or not the specified data flavor is an plain flavor that
	 * is supported.
	 * 
	 * @param flavor
	 *            the requested flavor for the data
	 * @return bool indicating whether or not the data flavor is supported
	 */
	bool _isPlainFlavor(DataFlavor flavor)
	{
		List<DataFlavor> flavors = _plainFlavors;

		for (int i = 0; i < flavors.length; i++)
		{
			if (flavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Whether the plain text flavors are offered. If so, the method
	 * getPlainData should be implemented to provide something reasonable.
	 */
	bool _isPlainSupported()
	{
		return false;
	}

	/**
	 * Fetch the data in a text/plain format.
	 */
	String _getPlainData()
	{
		return null;
	}

	/**
	 * Returns whether or not the specified data flavor is a String flavor that
	 * is supported.
	 * 
	 * @param flavor
	 *            the requested flavor for the data
	 * @return bool indicating whether or not the data flavor is supported
	 */
	bool _isStringFlavor(DataFlavor flavor)
	{
		List<DataFlavor> flavors = _stringFlavors;

		for (int i = 0; i < flavors.length; i++)
		{
			if (flavors[i].equals(flavor))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Local Machine Reference Data Flavor.
	 */
	static init()
	{
		try
		{
			_htmlFlavors = new List<DataFlavor>(3);
			_htmlFlavors[0] = new DataFlavor("text/html;class=java.lang.String");
			_htmlFlavors[1] = new DataFlavor("text/html;class=java.io.Reader");
			_htmlFlavors[2] = new DataFlavor(
					"text/html;charset=unicode;class=java.io.InputStream");

			_plainFlavors = new List<DataFlavor>(3);
			_plainFlavors[0] = new DataFlavor(
					"text/plain;class=java.lang.String");
			_plainFlavors[1] = new DataFlavor("text/plain;class=java.io.Reader");
			_plainFlavors[2] = new DataFlavor(
					"text/plain;charset=unicode;class=java.io.InputStream");

			_stringFlavors = new List<DataFlavor>(2);
			_stringFlavors[0] = new DataFlavor(
					DataFlavor.javaJVMLocalObjectMimeType
							+ ";class=java.lang.String");
			_stringFlavors[1] = DataFlavor.stringFlavor;

			_imageFlavors = new List<DataFlavor>(2);
			_imageFlavors[0] = DataFlavor.imageFlavor;
			_imageFlavors[1] = new DataFlavor("image/png");
		}
		on ClassNotFoundException catch (cle)
		{
			System.err
					.println("error initializing javax.swing.plaf.basic.BasicTranserable");
		}

		try
		{
			dataFlavor = new DataFlavor(DataFlavor.javaSerializedObjectMimeType
					+ "; class=graph.swing.util.GraphTransferable");
		}
		on ClassNotFoundException catch (cnfe)
		{
			// do nothing
		}
	}

}
