part of graph.canvas;

//import java.awt.Point;
//import java.awt.image.BufferedImage;
//import java.util.Hashtable;
//import java.util.Map;

public abstract class BasicCanvas implements ICanvas
{

	/**
	 * Specifies if image aspect should be preserved in drawImage. Default is true.
	 */
	static bool PRESERVE_IMAGE_ASPECT = true;

	/**
	 * Defines the default value for the imageBasePath in all GDI canvases.
	 * Default is an empty string.
	 */
	static String DEFAULT_IMAGEBASEPATH = "";

	/**
	 * Defines the base path for images with relative paths. Trailing slash
	 * is required. Default value is DEFAULT_IMAGEBASEPATH.
	 */
	String _imageBasePath = DEFAULT_IMAGEBASEPATH;

	/**
	 * Specifies the current translation. Default is (0,0).
	 */
	Point _translate = new Point();

	/**
	 * Specifies the current scale. Default is 1.
	 */
	double _scale = 1;

	/**
	 * Specifies whether labels should be painted. Default is true.
	 */
	bool _drawLabels = true;

	/**
	 * Cache for images.
	 */
	Hashtable<String, BufferedImage> _imageCache = new Hashtable<String, BufferedImage>();

	/**
	 * Sets the current translate.
	 */
	void setTranslate(int dx, int dy)
	{
		_translate = new Point(dx, dy);
	}

	/**
	 * Returns the current translate.
	 */
	Point getTranslate()
	{
		return _translate;
	}

	/**
	 * 
	 */
	void setScale(double scale)
	{
		this._scale = scale;
	}

	/**
	 * 
	 */
	double getScale()
	{
		return _scale;
	}

	/**
	 * 
	 */
	void setDrawLabels(bool drawLabels)
	{
		this._drawLabels = drawLabels;
	}

	/**
	 * 
	 */
	String getImageBasePath()
	{
		return _imageBasePath;
	}

	/**
	 * 
	 */
	void setImageBasePath(String imageBasePath)
	{
		this._imageBasePath = imageBasePath;
	}

	/**
	 * 
	 */
	bool isDrawLabels()
	{
		return _drawLabels;
	}

	/**
	 * Returns an image instance for the given URL. If the URL has
	 * been loaded before than an instance of the same instance is
	 * returned as in the previous call.
	 */
	BufferedImage loadImage(String image)
	{
		BufferedImage img = _imageCache.get(image);

		if (img == null)
		{
			img = Utils.loadImage(image);

			if (img != null)
			{
				_imageCache.put(image, img);
			}
		}

		return img;
	}

	/**
	 * 
	 */
	void flushImageCache()
	{
		_imageCache.clear();
	}

	/**
	 * Gets the image path from the given style. If the path is relative (does
	 * not start with a slash) then it is appended to the imageBasePath.
	 */
	String getImageForStyle(Map<String, Object> style)
	{
		String filename = Utils.getString(style, Constants.STYLE_IMAGE);

		if (filename != null && !filename.startsWith("/") && !filename.startsWith("file:/"))
		{
			filename = _imageBasePath + filename;
		}

		return filename;
	}

}
