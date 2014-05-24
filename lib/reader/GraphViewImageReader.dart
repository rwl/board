/**
 * Copyright (c) 2007, Gaudenz Alder
 */

package graph.reader;

//import graph.canvas.Graphics2DCanvas;
//import graph.canvas.ICanvas;
//import graph.canvas.ImageCanvas;
//import graph.util.Rect;
//import graph.util.Utils;

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
public class GraphViewImageReader extends GraphViewReader
{

	/**
	 * Specifies the background color. Default is null.
	 */
	protected Color _background;

	/**
	 * Specifies if the image should be anti-aliased. Default is true.
	 */
	protected boolean _antiAlias;

	/**
	 * Specifies the border which is added to the size of the graph. Default is
	 * 0.
	 */
	protected int _border;

	/**
	 * Specifies the border which is added to the size of the graph. Default is
	 * true.
	 */
	protected boolean _cropping;

	/**
	 * Defines the clip to be drawn. Default is null.
	 */
	protected Rect _clip;

	/**
	 * Constructs a new reader with a transparent background.
	 */
	public GraphViewImageReader()
	{
		this(null);
	}

	/**
	 * Constructs a new reader with the given background color.
	 */
	public GraphViewImageReader(Color background)
	{
		this(background, 0);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	public GraphViewImageReader(Color background, int border)
	{
		this(background, border, true);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	public GraphViewImageReader(Color background, int border,
			boolean antiAlias)
	{
		this(background, border, antiAlias, true);
	}

	/**
	 * Constructs a new reader with a transparent background.
	 */
	public GraphViewImageReader(Color background, int border,
			boolean antiAlias, boolean cropping)
	{
		setBackground(background);
		setBorder(border);
		setAntiAlias(antiAlias);
		setCropping(cropping);
	}

	/**
	 * 
	 */
	public Color getBackground()
	{
		return _background;
	}

	/**
	 * 
	 */
	public void setBackground(Color background)
	{
		this._background = background;
	}

	/**
	 * 
	 */
	public int getBorder()
	{
		return _border;
	}

	/**
	 * 
	 */
	public void setBorder(int border)
	{
		this._border = border;
	}

	/**
	 * 
	 */
	public boolean isAntiAlias()
	{
		return _antiAlias;
	}

	/**
	 * 
	 */
	public void setAntiAlias(boolean antiAlias)
	{
		this._antiAlias = antiAlias;
	}

	/**
	 * Specifies the optional clipping rectangle.
	 */
	public boolean isCropping()
	{
		return _cropping;
	}

	/**
	 * 
	 */
	public void setCropping(boolean value)
	{
		this._cropping = value;
	}

	/**
	 * 
	 */
	public Rect getClip()
	{
		return _clip;
	}

	/**
	 * 
	 */
	public void setClip(Rect value)
	{
		this._clip = value;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * graph.reader.GraphViewReader#createCanvas(java.util.Hashtable)
	 */
	public ICanvas createCanvas(Map<String, Object> attrs)
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
	protected Graphics2DCanvas _createGraphicsCanvas()
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
	public static BufferedImage convert(String filename,
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
	public static BufferedImage convert(InputSource inputSource,
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
