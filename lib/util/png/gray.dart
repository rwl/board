part of graph.util.png;

class Gray extends PngEncodeParam
{

	/** Constructs an instance of <code>PNGEncodeParam.Gray</code>. */
	Gray()
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
   * Sets the desired bit depth for a grayscale image.  The bit
   * depth must be one of 1, 2, 4, 8, or 16.
   *
   * <p> When encoding a source image of a greater bit depth,
   * pixel values will be clamped to the smaller range after
   * shifting by the value given by <code>getBitShift()</code>.
   * When encoding a source image of a smaller bit depth, pixel
   * values will be shifted and left-filled with zeroes.
   */
	void setBitDepth(int bitDepth)
	{
		if (bitDepth != 1 && bitDepth != 2 && bitDepth != 4
				&& bitDepth != 8 && bitDepth != 16)
		{
			throw new ArgumentError();
		}
		this._bitDepth = bitDepth;
		_bitDepthSet = true;
	}

	// bKGD chunk

	int backgroundPaletteGray;

	/**
   * Sets the suggested gray level of the background.
   *
   * <p> The 'bKGD' chunk will encode this information.
   */
	void setBackgroundGray(int gray)
	{
		backgroundPaletteGray = gray;
		backgroundSet = true;
	}

	/**
   * Returns the suggested gray level of the background.
   *
   * <p> If the background gray level has not previously been
   * set, or has been unset, an
   * <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the background gray level
   *        is not set.
   */
	int getBackgroundGray()
	{
		if (!backgroundSet)
		{
			throw new IllegalStateException("PNGEncodeParam6");
		}
		return backgroundPaletteGray;
	}

	// tRNS chunk

	List<int> transparency;

	/**
   * Sets the gray value to be used to denote transparency.
   *
   * <p> Setting this attribute will cause the alpha channel
   * of the input image to be ignored.
   *
   * <p> The 'tRNS' chunk will encode this information.
   */
	void setTransparentGray(int transparentGray)
	{
		transparency = new int[1];
		transparency[0] = transparentGray;
		transparencySet = true;
	}

	/**
   * Returns the gray value to be used to denote transparency.
   *
   * <p> If the transparent gray value has not previously been
   * set, or has been unset, an
   * <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the transparent gray value
   *        is not set.
   */
	int getTransparentGray()
	{
		if (!transparencySet)
		{
			throw new IllegalStateException("PNGEncodeParam7");
		}
		int gray = transparency[0];
		return gray;
	}

	int bitShift;

	bool bitShiftSet = false;

	/**
   * Sets the desired bit shift for a grayscale image.
   * Pixels in the source image will be shifted right by
   * the given amount prior to being clamped to the maximum
   * value given by the encoded image's bit depth.
   */
	void setBitShift(int bitShift)
	{
		if (bitShift < 0)
		{
			throw new RuntimeException();
		}
		this.bitShift = bitShift;
		bitShiftSet = true;
	}

	/**
   * Returns the desired bit shift for a grayscale image.
   *
   * <p> If the bit shift has not previously been set, or has been
   * unset, an <code>IllegalStateException</code> will be thrown.
   *
   * @throws IllegalStateException if the bit shift is not set.
   */
	int getBitShift()
	{
		if (!bitShiftSet)
		{
			throw new IllegalStateException("PNGEncodeParam8");
		}
		return bitShift;
	}

	/**
   * Suppresses the setting of the bit shift of a grayscale image.
   * Pixels in the source image will not be shifted prior to encoding.
   */
	void unsetBitShift()
	{
		bitShiftSet = false;
	}

	/**
   * Returns true if the bit shift has been set.
   */
	bool isBitShiftSet()
	{
		return bitShiftSet;
	}

	/**
   * Returns true if the bit depth has been set.
   */
	bool isBitDepthSet()
	{
		return _bitDepthSet;
	}
}