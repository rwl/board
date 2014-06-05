part of graph.util.png;

class Palette extends PngEncodeParam
{

	/** Constructs an instance of <code>PNGEncodeParam.Palette</code>. */
	Palette()
	{
	}

	// bKGD chunk

	bool backgroundSet = false;

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
   * Sets the desired bit depth for a palette image.  The bit
   * depth must be one of 1, 2, 4, or 8, or else an
   * <code>ArgumentError</code> will be thrown.
   */
	void setBitDepth(int bitDepth)
	{
		if (bitDepth != 1 && bitDepth != 2 && bitDepth != 4
				&& bitDepth != 8)
		{
			throw new ArgumentError("PNGEncodeParam2");
		}
		this._bitDepth = bitDepth;
		_bitDepthSet = true;
	}

	// PLTE chunk

	List<int> palette = null;

	bool paletteSet = false;

	/**
   * Sets the RGB palette of the image to be encoded.
   * The <code>rgb</code> parameter contains alternating
   * R, G, B values for each color index used in the image.
   * The number of elements must be a multiple of 3 between
   * 3 and 3*256.
   *
   * <p> The 'PLTE' chunk will encode this information.
   *
   * @param rgb An array of <code>int</code>s.
   */
	void setPalette(List<int> rgb)
	{
		if (rgb.length < 1 * 3 || rgb.length > 256 * 3)
		{
			throw new ArgumentError("PNGEncodeParam0");
		}
		if ((rgb.length % 3) != 0)
		{
			throw new ArgumentError("PNGEncodeParam1");
		}

		palette = (rgb.clone());
		paletteSet = true;
	}

	/**
   * Returns the current RGB palette.
   *
   * <p> If the palette has not previously been set, or has been
   * unset, an <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the palette is not set.
   *
   * @return An array of <code>int</code>s.
   */
	List<int> getPalette()
	{
		if (!paletteSet)
		{
			throw new IllegalStateException("PNGEncodeParam3");
		}
		return (palette.clone());
	}

	/**
   * Suppresses the 'PLTE' chunk from being output.
   */
	void unsetPalette()
	{
		palette = null;
		paletteSet = false;
	}

	/**
   * Returns true if a 'PLTE' chunk will be output.
   */
	bool isPaletteSet()
	{
		return paletteSet;
	}

	// bKGD chunk

	int backgroundPaletteIndex;

	/**
   * Sets the palette index of the suggested background color.
   *
   * <p> The 'bKGD' chunk will encode this information.
   */
	void setBackgroundPaletteIndex(int index)
	{
		backgroundPaletteIndex = index;
		backgroundSet = true;
	}

	/**
   * Returns the palette index of the suggested background color.
   *
   * <p> If the background palette index has not previously been
   * set, or has been unset, an
   * <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the palette index is not set.
   */
	int getBackgroundPaletteIndex()
	{
		if (!backgroundSet)
		{
			throw new IllegalStateException("PNGEncodeParam4");
		}
		return backgroundPaletteIndex;
	}

	// tRNS chunk

	List<int> transparency;

	/**
   * Sets the alpha values associated with each palette entry.
   * The <code>alpha</code> parameter should have as many entries
   * as there are RGB triples in the palette.
   *
   * <p> The 'tRNS' chunk will encode this information.
   */
	void setPaletteTransparency(List<byte> alpha)
	{
		transparency = new int[alpha.length];
		for (int i = 0; i < alpha.length; i++)
		{
			transparency[i] = alpha[i] & 0xff;
		}
		transparencySet = true;
	}

	/**
   * Returns the alpha values associated with each palette entry.
   *
   * <p> If the palette transparency has not previously been
   * set, or has been unset, an
   * <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the palette transparency is
   *        not set.
   */
	List<byte> getPaletteTransparency()
	{
		if (!transparencySet)
		{
			throw new IllegalStateException("PNGEncodeParam5");
		}
		List<byte> alpha = new byte[transparency.length];
		for (int i = 0; i < alpha.length; i++)
		{
			alpha[i] = (byte) transparency[i];
		}
		return alpha;
	}
}