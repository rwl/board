part of graph.util.png;

class RGB extends PngEncodeParam
{

	/** Constructs an instance of <code>PNGEncodeParam.RGB</code>. */
	RGB()
	{
	}

	// bKGD chunk

	private bool backgroundSet = false;

	/**
	 * Suppresses the 'bKGD' chunk from being output.
	 */
	void unsetBackground()
	{
		backgroundSet = false;
	}

	/**
	 * Returns true if a 'bKGD' chunk will be output.
	 */
	bool isBackgroundSet()
	{
		return backgroundSet;
	}

	/**
	 * Sets the desired bit depth for an RGB image.  The bit
	 * depth must be 8 or 16.
	 */
	void setBitDepth(int bitDepth)
	{
		if (bitDepth != 8 && bitDepth != 16)
		{
			throw new RuntimeException();
		}
		this._bitDepth = bitDepth;
		_bitDepthSet = true;
	}

	// bKGD chunk

	private int[] backgroundRGB;

	/**
	 * Sets the RGB value of the suggested background color.
	 * The <code>rgb</code> parameter should have 3 entries.
	 *
	 * <p> The 'bKGD' chunk will encode this information.
	 */
	void setBackgroundRGB(int[] rgb)
	{
		if (rgb.length != 3)
		{
			throw new RuntimeException();
		}
		backgroundRGB = rgb;
		backgroundSet = true;
	}

	/**
	 * Returns the RGB value of the suggested background color.
	 *
	 * <p> If the background color has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the background color is not set.
	 */
	int[] getBackgroundRGB()
	{
		if (!backgroundSet)
		{
			throw new IllegalStateException("PNGEncodeParam9");
		}
		return backgroundRGB;
	}

	// tRNS chunk

	private int[] transparency;

	/**
	 * Sets the RGB value to be used to denote transparency.
	 *
	 * <p> Setting this attribute will cause the alpha channel
	 * of the input image to be ignored.
	 *
	 * <p> The 'tRNS' chunk will encode this information.
	 */
	void setTransparentRGB(int[] transparentRGB)
	{
		transparency = (transparentRGB.clone());
		transparencySet = true;
	}

	/**
	 * Returns the RGB value to be used to denote transparency.
	 *
	 * <p> If the transparent color has not previously been set,
	 * or has been unset, an <code>IllegalStateException</code>
	 * will be thrown.
	 *
	 * @throws IllegalStateException if the transparent color is not set.
	 */
	int[] getTransparentRGB()
	{
		if (!transparencySet)
		{
			throw new IllegalStateException("PNGEncodeParam10");
		}
		return (transparency.clone());
	}
}