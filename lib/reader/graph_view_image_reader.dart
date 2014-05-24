/**
 * Copyright (c) 2007, Gaudenz Alder
 */

part of graph.reader;

//import java.awt.Color;
//import java.awt.image.BufferedImage;
//import java.io.FileInputStream;
//import java.io.IOException;
//import java.util.Map;

//import javax.xml.parsers.ParserConfigurationException;
//import javax.xml.parsers.SAXParser;
//import javax.xml.parsers.SAXParserFactory;

//import org.xml.sax.InputSource;
//import org.xml.sax.SAXException;
//import org.xml.sax.XMLReader;

/**
 * A converter that renders display XML data onto a graphics canvas. This
 * reader can only be used to generate images for encoded graph views.
 */
class GraphViewImageReader extends GraphViewReader
{

	/**
	 * Specifies the background color. Default is null.
	 */
	Color _background;

	/**
	 * Specifies if the image should be anti-aliased. Default is true.
	 */
	bool _antiAlias;

	/**
	 * Specifies the border which is added to the size of the graph. Default is
	 * 0.
	 */
	int _border;

	/**
	 * Specifies the border which is added to the size of the graph. Default is
	 * true.
	 */
	bool _cropping;

	/**
	 * Defines the clip to be drawn. Default is null.
	 */
	Rect _clip;

	/**
	 * Constructs a new reader with a transparent background.
	 */
	GraphViewImageReader()
	{
		this(null);
	}

	/**
	 * Constructs a new reader with the given background color.
	 */
	GraphViewImageReader(Color background)
	{
		this(background, 0);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	GraphViewImageReader(Color background, int border)
	{
		this(background, border, true);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	GraphViewImageReader(Color background, int border,
			bool antiAlias)
	{
		this(background, border, antiAlias, true);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	GraphViewImageReader(Color background, int border,
			bool antiAlias, bool cropping)
	{
		setBackground(background);
		setBorder(border);
		setAntiAlias(antiAlias);
		setCropping(cropping);
	}

	/**
	 * 
	 */
	Color getBackground()
	{
		return _background;
	}

	/**
	 * 
	 */
	void setBackground(Color background)
	{
		this._background = background;
	}

	/**
	 * 
	 */
	int getBorder()
	{
		return _border;
	}

	/**
	 * 
	 */
	void setBorder(int border)
	{
		this._border = border;
	}

	/**
	 * 
	 */
	bool isAntiAlias()
	{
		return _antiAlias;
	}

	/**
	 * 
	 */
	void setAntiAlias(bool antiAlias)
	{
		this._antiAlias = antiAlias;
	}

	/**
	 * Specifies the optional clipping rectangle.
	 */
	bool isCropping()
	{
		return _cropping;
	}

	/**
	 * 
	 */
	void setCropping(bool value)
	{
		this._cropping = value;
	}

	/**
	 * 
	 */
	Rect getClip()
	{
		return _clip;
	}

	/**
	 * 
	 */
	void setClip(Rect value)
	{
		this._clip = value;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * graph.reader.GraphViewReader#createCanvas(java.util.Hashtable)
	 */
	ICanvas createCanvas(Map<String, Object> attrs)
	{
		int width = 0;
		int height = 0;
		int dx = 0;
		int dy = 0;

		Rect tmp = getClip();

		if (tmp != null)
		{
			dx -= (int) tmp.getX();
			dy -= (int) tmp.getY();
			width = (int) tmp.getWidth();
			height = (int) tmp.getHeight();
		}
		else
		{
			int x = (int) Math.round(Utils.getDouble(attrs, "x"));
			int y = (int) Math.round(Utils.getDouble(attrs, "y"));
			width = (int) (Math.round(Utils.getDouble(attrs, "width")))
					+ _border + 3;
			height = (int) (Math.round(Utils.getDouble(attrs, "height")))
					+ _border + 3;

			if (isCropping())
			{
				dx = -x + 3;
				dy = -y + 3;
			}
			else
			{
				width += x;
				height += y;
			}
		}

		ImageCanvas canvas = new ImageCanvas(_createGraphicsCanvas(), width,
				height, getBackground(), isAntiAlias());
		canvas.setTranslate(dx, dy);

		return canvas;
	}

	/**
	 * Hook that creates the graphics canvas.
	 */
	Graphics2DCanvas _createGraphicsCanvas()
	{
		return new Graphics2DCanvas();
	}

	/**
	 * Creates the image for the given display XML file. (Note: The XML file is
	 * an encoded GraphView, not GraphModel.)
	 * 
	 * @param filename
	 *            Filename of the display XML file.
	 * @return Returns an image representing the display XML file.
	 */
	static BufferedImage convert(String filename,
			GraphViewImageReader viewReader)
			throws ParserConfigurationException, SAXException, IOException
	{
		return convert(new InputSource(new FileInputStream(filename)),
				viewReader);
	}

	/**
	 * Creates the image for the given display XML input source. (Note: The XML
	 * is an encoded GraphView, not GraphModel.)
	 * 
	 * @param inputSource
	 *            Input source that contains the display XML.
	 * @return Returns an image representing the display XML input source.
	 */
	static BufferedImage convert(InputSource inputSource,
			GraphViewImageReader viewReader)
			throws ParserConfigurationException, SAXException, IOException
	{
		BufferedImage result = null;
		SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
		XMLReader reader = parser.getXMLReader();

		reader.setContentHandler(viewReader);
		reader.parse(inputSource);

		if (viewReader.getCanvas() instanceof ImageCanvas)
		{
			result = ((ImageCanvas) viewReader.getCanvas()).destroy();
		}

		return result;
	}

}
