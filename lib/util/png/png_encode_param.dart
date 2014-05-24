/* $Id: PngEncodeParam.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
   
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
/*
 * Copyright (c) 2001 Sun Microsystems, Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * 
 * -Redistributions of source code must retain the above copyright notice, this 
 * list of conditions and the following disclaimer.
 *
 * -Redistribution in binary form must reproduct the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * Neither the name of Sun Microsystems, Inc. or the names of contributors may
 * be used to endorse or promote products derived from this software without
 * specific prior written permission.
 * 
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN AND ITS LICENSORS SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING
 * OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
 * INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
 * CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
 * OR INABILITY TO USE SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 * 
 * You acknowledge that Software is not designed,licensed or intended for use in 
 * the design, construction, operation or maintenance of any nuclear facility.
 */
part of graph.util.png;

//import java.awt.image.ColorModel;
//import java.awt.image.IndexColorModel;
//import java.awt.image.RenderedImage;
//import java.awt.image.SampleModel;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.List;

/**
 * An instance of <code>ImageEncodeParam</code> for encoding images in
 * the PNG format.
 *
 * <p><b> This class is not a committed part of the JAI API.  It may
 * be removed or changed in future releases of JAI.</b>
 *
 * @version $Id: PngEncodeParam.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 */
public abstract class PngEncodeParam
{

	/** Constant for use with the sRGB chunk. */
	static final int INTENT_PERCEPTUAL = 0;

	/** Constant for use with the sRGB chunk. */
	static final int INTENT_RELATIVE = 1;

	/** Constant for use with the sRGB chunk. */
	static final int INTENT_SATURATION = 2;

	/** Constant for use with the sRGB chunk. */
	static final int INTENT_ABSOLUTE = 3;

	/** Constant for use in filtering. */
	static final int PNG_FILTER_NONE = 0;

	/** Constant for use in filtering. */
	static final int PNG_FILTER_SUB = 1;

	/** Constant for use in filtering. */
	static final int PNG_FILTER_UP = 2;

	/** Constant for use in filtering. */
	static final int PNG_FILTER_AVERAGE = 3;

	/** Constant for use in filtering. */
	static final int PNG_FILTER_PAETH = 4;

	/**
	 * Returns an instance of <code>PNGEncodeParam.Palette</code>,
	 * <code>PNGEncodeParam.Gray</code>, or
	 * <code>PNGEncodeParam.RGB</code> appropriate for encoding
	 * the given image.
	 *
	 * <p> If the image has an <code>IndexColorModel</code>, an
	 * instance of <code>PNGEncodeParam.Palette</code> is returned.
	 * Otherwise, if the image has 1 or 2 bands an instance of
	 * <code>PNGEncodeParam.Gray</code> is returned.  In all other
	 * cases an instance of <code>PNGEncodeParam.RGB</code> is
	 * returned.
	 *
	 * <p> Note that this method does not provide any guarantee that
	 * the given image will be successfully encoded by the PNG
	 * encoder, as it only performs a very superficial analysis of
	 * the image structure.
	 */
	static PngEncodeParam getDefaultEncodeParam(RenderedImage im)
	{
		ColorModel colorModel = im.getColorModel();
		if (colorModel is IndexColorModel)
		{
			return new Palette();
		}

		SampleModel sampleModel = im.getSampleModel();
		int numBands = sampleModel.getNumBands();

		if (numBands == 1 || numBands == 2)
		{
			return new Gray();
		}
		else
		{
			return new RGB();
		}
	}

	int _bitDepth;

	bool _bitDepthSet = false;

	/**
	 * Sets the desired bit depth of an image.
	 */
	abstract void setBitDepth(int bitDepth);

	/**
	 * Returns the desired bit depth for a grayscale image.
	 *
	 * <p> If the bit depth has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the bit depth is not set.
	 */
	int getBitDepth()
	{
		if (!_bitDepthSet)
		{
			throw new IllegalStateException("PNGEncodeParam11");
		}
		return _bitDepth;
	}

	/**
	 * Suppresses the setting of the bit depth of a grayscale image.
	 * The depth of the encoded image will be inferred from the source
	 * image bit depth, rounded up to the next power of 2 between 1
	 * and 16.
	 */
	void unsetBitDepth()
	{
		_bitDepthSet = false;
	}

	private bool _useInterlacing = false;

	/**
	 * Turns Adam7 interlacing on or off.
	 */
	void setInterlacing(bool useInterlacing)
	{
		this._useInterlacing = useInterlacing;
	}

	/**
	 * Returns <code>true</code> if Adam7 interlacing will be used.
	 */
	bool getInterlacing()
	{
		return _useInterlacing;
	}

	// bKGD chunk - delegate to subclasses

	// In JAI 1.0, 'backgroundSet' was private.  The JDK 1.2 compiler
	// was lenient and incorrectly allowed this variable to be
	// accessed from the subclasses.  The JDK 1.3 compiler correctly
	// flags this as a use of a non-static variable in a static
	// context.  Changing 'backgroundSet' to protected would have
	// solved the problem, but would have introduced a visible API
	// change.  Thus we are forced to adopt the solution of placing a
	// separate private variable in each subclass and providing
	// separate implementations of 'unsetBackground' and
	// 'isBackgroundSet' in each concrete subclass.

	/**
	 * Suppresses the 'bKGD' chunk from being output.
	 * For API compatibility with JAI 1.0, the superclass
	 * defines this method to throw a <code>RuntimeException</code>;
	 * accordingly, subclasses must provide their own implementations.
	 */
	void unsetBackground()
	{
		throw new RuntimeException("PNGEncodeParam23");
	}

	/**
	 * Returns true if a 'bKGD' chunk will be output.
	 * For API compatibility with JAI 1.0, the superclass
	 * defines this method to throw a <code>RuntimeException</code>;
	 * accordingly, subclasses must provide their own implementations.
	 */
	bool isBackgroundSet()
	{
		throw new RuntimeException("PNGEncodeParam24");
	}

	// cHRM chunk

	private float[] _chromaticity = null;

	private bool _chromaticitySet = false;

	/**
	 * Sets the white point and primary chromaticities in CIE (x, y)
	 * space.
	 *
	 * <p> The <code>chromaticity</code> parameter should be a
	 * <code>float</code> array of length 8 containing the white point
	 * X and Y, red X and Y, green X and Y, and blue X and Y values in
	 * order.
	 *
	 * <p> The 'cHRM' chunk will encode this information.
	 */
	void setChromaticity(float[] chromaticity)
	{
		if (chromaticity.length != 8)
		{
			throw new IllegalArgumentException();
		}
		this._chromaticity = (chromaticity.clone());
		_chromaticitySet = true;
	}

	/**
	 * A convenience method that calls the array version.
	 */
	void setChromaticity(float whitePointX, float whitePointY,
			float redX, float redY, float greenX, float greenY, float blueX,
			float blueY)
	{
		float[] chroma = new float[8];
		chroma[0] = whitePointX;
		chroma[1] = whitePointY;
		chroma[2] = redX;
		chroma[3] = redY;
		chroma[4] = greenX;
		chroma[5] = greenY;
		chroma[6] = blueX;
		chroma[7] = blueY;
		setChromaticity(chroma);
	}

	/**
	 * Returns the white point and primary chromaticities in
	 * CIE (x, y) space.
	 *
	 * <p> See the documentation for the <code>setChromaticity</code>
	 * method for the format of the returned data.
	 *
	 * <p> If the chromaticity has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the chromaticity is not set.
	 */
	float[] getChromaticity()
	{
		if (!_chromaticitySet)
		{
			throw new IllegalStateException("PNGEncodeParam12");
		}
		return (_chromaticity.clone());
	}

	/**
	 * Suppresses the 'cHRM' chunk from being output.
	 */
	void unsetChromaticity()
	{
		_chromaticity = null;
		_chromaticitySet = false;
	}

	/**
	 * Returns true if a 'cHRM' chunk will be output.
	 */
	bool isChromaticitySet()
	{
		return _chromaticitySet;
	}

	// gAMA chunk

	private float _gamma;

	private bool _gammaSet = false;

	/**
	 * Sets the file gamma value for the image.
	 *
	 * <p> The 'gAMA' chunk will encode this information.
	 */
	void setGamma(float gamma)
	{
		this._gamma = gamma;
		_gammaSet = true;
	}

	/**
	 * Returns the file gamma value for the image.
	 *
	 * <p> If the file gamma has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the gamma is not set.
	 */
	float getGamma()
	{
		if (!_gammaSet)
		{
			throw new IllegalStateException("PNGEncodeParam13");
		}
		return _gamma;
	}

	/**
	 * Suppresses the 'gAMA' chunk from being output.
	 */
	void unsetGamma()
	{
		_gammaSet = false;
	}

	/**
	 * Returns true if a 'gAMA' chunk will be output.
	 */
	bool isGammaSet()
	{
		return _gammaSet;
	}

	// hIST chunk

	private int[] _paletteHistogram = null;

	private bool _paletteHistogramSet = false;

	/**
	 * Sets the palette histogram to be stored with this image.
	 * The histogram consists of an array of integers, one per
	 * palette entry.
	 *
	 * <p> The 'hIST' chunk will encode this information.
	 */
	void setPaletteHistogram(int[] paletteHistogram)
	{
		this._paletteHistogram = (paletteHistogram.clone());
		_paletteHistogramSet = true;
	}

	/**
	 * Returns the palette histogram to be stored with this image.
	 *
	 * <p> If the histogram has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the histogram is not set.
	 */
	int[] getPaletteHistogram()
	{
		if (!_paletteHistogramSet)
		{
			throw new IllegalStateException("PNGEncodeParam14");
		}
		return _paletteHistogram;
	}

	/**
	 * Suppresses the 'hIST' chunk from being output.
	 */
	void unsetPaletteHistogram()
	{
		_paletteHistogram = null;
		_paletteHistogramSet = false;
	}

	/**
	 * Returns true if a 'hIST' chunk will be output.
	 */
	bool isPaletteHistogramSet()
	{
		return _paletteHistogramSet;
	}

	// iCCP chunk

	private byte[] _ICCProfileData = null;

	private bool _ICCProfileDataSet = false;

	/**
	 * Sets the ICC profile data to be stored with this image.
	 * The profile is represented in raw binary form.
	 *
	 * <p> The 'iCCP' chunk will encode this information.
	 */
	void setICCProfileData(byte[] ICCProfileData)
	{
		this._ICCProfileData = (ICCProfileData.clone());
		_ICCProfileDataSet = true;
	}

	/**
	 * Returns the ICC profile data to be stored with this image.
	 *
	 * <p> If the ICC profile has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the ICC profile is not set.
	 */
	byte[] getICCProfileData()
	{
		if (!_ICCProfileDataSet)
		{
			throw new IllegalStateException("PNGEncodeParam15");
		}
		return (_ICCProfileData.clone());
	}

	/**
	 * Suppresses the 'iCCP' chunk from being output.
	 */
	void unsetICCProfileData()
	{
		_ICCProfileData = null;
		_ICCProfileDataSet = false;
	}

	/**
	 * Returns true if a 'iCCP' chunk will be output.
	 */
	bool isICCProfileDataSet()
	{
		return _ICCProfileDataSet;
	}

	// pHYS chunk

	private int[] _physicalDimension = null;

	private bool _physicalDimensionSet = false;

	/**
	 * Sets the physical dimension information to be stored with this
	 * image.  The physicalDimension parameter should be a 3-entry
	 * array containing the number of pixels per unit in the X
	 * direction, the number of pixels per unit in the Y direction,
	 * and the unit specifier (0 = unknown, 1 = meters).
	 *
	 * <p> The 'pHYS' chunk will encode this information.
	 */
	void setPhysicalDimension(int[] physicalDimension)
	{
		this._physicalDimension = (physicalDimension.clone());
		_physicalDimensionSet = true;
	}

	/**
	 * A convenience method that calls the array version.
	 */
	void setPhysicalDimension(int xPixelsPerUnit, int yPixelsPerUnit,
			int unitSpecifier)
	{
		int[] pd = new int[3];
		pd[0] = xPixelsPerUnit;
		pd[1] = yPixelsPerUnit;
		pd[2] = unitSpecifier;

		setPhysicalDimension(pd);
	}

	/**
	 * Returns the physical dimension information to be stored
	 * with this image.
	 *
	 * <p> If the physical dimension information has not previously
	 * been set, or has been unset, an
	 * <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the physical dimension information
	 *        is not set.
	 */
	int[] getPhysicalDimension()
	{
		if (!_physicalDimensionSet)
		{
			throw new IllegalStateException("PNGEncodeParam16");
		}
		return (_physicalDimension.clone());
	}

	/**
	 * Suppresses the 'pHYS' chunk from being output.
	 */
	void unsetPhysicalDimension()
	{
		_physicalDimension = null;
		_physicalDimensionSet = false;
	}

	/**
	 * Returns true if a 'pHYS' chunk will be output.
	 */
	bool isPhysicalDimensionSet()
	{
		return _physicalDimensionSet;
	}

	// sPLT chunk

	private PngSuggestedPaletteEntry[] _suggestedPalette = null;

	private bool _suggestedPaletteSet = false;

	/**
	 * Sets the suggested palette information to be stored with this
	 * image.  The information is passed to this method as an array of
	 * <code>PNGSuggestedPaletteEntry</code> objects.
	 *
	 * <p> The 'sPLT' chunk will encode this information.
	 */
	void setSuggestedPalette(PngSuggestedPaletteEntry[] palette)
	{
		_suggestedPalette = (palette.clone());
		_suggestedPaletteSet = true;
	}

	/**
	 * Returns the suggested palette information to be stored with this
	 * image.
	 *
	 * <p> If the suggested palette information has not previously
	 * been set, or has been unset, an
	 * <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the suggested palette
	 *        information is not set.
	 */
	PngSuggestedPaletteEntry[] getSuggestedPalette()
	{
		if (!_suggestedPaletteSet)
		{
			throw new IllegalStateException("PNGEncodeParam17");
		}
		return (_suggestedPalette.clone());
	}

	/**
	 * Suppresses the 'sPLT' chunk from being output.
	 */
	void unsetSuggestedPalette()
	{
		_suggestedPalette = null;
		_suggestedPaletteSet = false;
	}

	/**
	 * Returns true if a 'sPLT' chunk will be output.
	 */
	bool isSuggestedPaletteSet()
	{
		return _suggestedPaletteSet;
	}

	// sBIT chunk

	private int[] _significantBits = null;

	private bool _significantBitsSet = false;

	/**
	 * Sets the number of significant bits for each band of the image.
	 *
	 * <p> The number of entries in the <code>significantBits</code>
	 * array must be equal to the number of output bands in the image:
	 * 1 for a gray image, 2 for gray+alpha, 3 for index or truecolor,
	 * and 4 for truecolor+alpha.
	 *
	 * <p> The 'sBIT' chunk will encode this information.
	 */
	void setSignificantBits(int[] significantBits)
	{
		this._significantBits = (significantBits.clone());
		_significantBitsSet = true;
	}

	/**
	 * Returns the number of significant bits for each band of the image.
	 *
	 * <p> If the significant bits values have not previously been
	 * set, or have been unset, an <code>IllegalStateException</code>
	 * will be thrown.
	 *
	 * @throws IllegalStateException if the significant bits values are
	 *        not set.
	 */
	int[] getSignificantBits()
	{
		if (!_significantBitsSet)
		{
			throw new IllegalStateException("PNGEncodeParam18");
		}
		return _significantBits.clone();
	}

	/**
	 * Suppresses the 'sBIT' chunk from being output.
	 */
	void unsetSignificantBits()
	{
		_significantBits = null;
		_significantBitsSet = false;
	}

	/**
	 * Returns true if an 'sBIT' chunk will be output.
	 */
	bool isSignificantBitsSet()
	{
		return _significantBitsSet;
	}

	// sRGB chunk

	private int _SRGBIntent;

	private bool _SRGBIntentSet = false;

	/**
	 * Sets the sRGB rendering intent to be stored with this image.
	 * The legal values are 0 = Perceptual, 1 = Relative Colorimetric,
	 * 2 = Saturation, and 3 = Absolute Colorimetric.  Refer to the
	 * PNG specification for information on these values.
	 *
	 * <p> The 'sRGB' chunk will encode this information.
	 */
	void setSRGBIntent(int SRGBIntent)
	{
		this._SRGBIntent = SRGBIntent;
		_SRGBIntentSet = true;
	}

	/**
	 * Returns the sRGB rendering intent to be stored with this image.
	 *
	 * <p> If the sRGB intent has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the sRGB intent is not set.
	 */
	int getSRGBIntent()
	{
		if (!_SRGBIntentSet)
		{
			throw new IllegalStateException("PNGEncodeParam19");
		}
		return _SRGBIntent;
	}

	/**
	 * Suppresses the 'sRGB' chunk from being output.
	 */
	void unsetSRGBIntent()
	{
		_SRGBIntentSet = false;
	}

	/**
	 * Returns true if an 'sRGB' chunk will be output.
	 */
	bool isSRGBIntentSet()
	{
		return _SRGBIntentSet;
	}

	// tEXt chunk

	private String[] _text = null;

	private bool _textSet = false;

	/**
	 * Sets the textual data to be stored in uncompressed form with this
	 * image.  The data is passed to this method as an array of
	 * <code>String</code>s.
	 *
	 * <p> The 'tEXt' chunk will encode this information.
	 */
	void setText(String[] text)
	{
		this._text = text;
		_textSet = true;
	}

	/**
	 * Returns the text strings to be stored in uncompressed form with this
	 * image as an array of <code>String</code>s.
	 *
	 * <p> If the text strings have not previously been set, or have been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the text strings are not set.
	 */
	String[] getText()
	{
		if (!_textSet)
		{
			throw new IllegalStateException("PNGEncodeParam20");
		}
		return _text;
	}

	/**
	 * Suppresses the 'tEXt' chunk from being output.
	 */
	void unsetText()
	{
		_text = null;
		_textSet = false;
	}

	/**
	 * Returns true if a 'tEXt' chunk will be output.
	 */
	bool isTextSet()
	{
		return _textSet;
	}

	// tIME chunk

	private Date _modificationTime;

	private bool _modificationTimeSet = false;

	/**
	 * Sets the modification time, as a <code>Date</code>, to be
	 * stored with this image.  The internal storage format will use
	 * UTC regardless of how the <code>modificationTime</code>
	 * parameter was created.
	 *
	 * <p> The 'tIME' chunk will encode this information.
	 */
	void setModificationTime(Date modificationTime)
	{
		this._modificationTime = modificationTime;
		_modificationTimeSet = true;
	}

	/**
	 * Returns the modification time to be stored with this image.
	 *
	 * <p> If the bit depth has not previously been set, or has been
	 * unset, an <code>IllegalStateException</code> will be thrown.
	 *
	 * @throws IllegalStateException if the bit depth is not set.
	 */
	Date getModificationTime()
	{
		if (!_modificationTimeSet)
		{
			throw new IllegalStateException("PNGEncodeParam21");
		}
		return _modificationTime;
	}

	/**
	 * Suppresses the 'tIME' chunk from being output.
	 */
	void unsetModificationTime()
	{
		_modificationTime = null;
		_modificationTimeSet = false;
	}

	/**
	 * Returns true if a 'tIME' chunk will be output.
	 */
	bool isModificationTimeSet()
	{
		return _modificationTimeSet;
	}

	// tRNS chunk

	bool transparencySet = false;

	/**
	 * Suppresses the 'tRNS' chunk from being output.
	 */
	void unsetTransparency()
	{
		transparencySet = false;
	}

	/**
	 * Returns true if a 'tRNS' chunk will be output.
	 */
	bool isTransparencySet()
	{
		return transparencySet;
	}

	// zTXT chunk

	private String[] _zText = null;

	private bool _zTextSet = false;

	/**
	 * Sets the text strings to be stored in compressed form with this
	 * image.  The data is passed to this method as an array of
	 * <code>String</code>s.
	 *
	 * <p> The 'zTXt' chunk will encode this information.
	 */
	void setCompressedText(String[] text)
	{
		this._zText = text;
		_zTextSet = true;
	}

	/**
	 * Returns the text strings to be stored in compressed form with
	 * this image as an array of <code>String</code>s.
	 *
	 * <p> If the compressed text strings have not previously been
	 * set, or have been unset, an <code>IllegalStateException</code>
	 * will be thrown.
	 *
	 * @throws IllegalStateException if the compressed text strings are
	 *        not set.
	 */
	String[] getCompressedText()
	{
		if (!_zTextSet)
		{
			throw new IllegalStateException("PNGEncodeParam22");
		}
		return _zText;
	}

	/**
	 * Suppresses the 'zTXt' chunk from being output.
	 */
	void unsetCompressedText()
	{
		_zText = null;
		_zTextSet = false;
	}

	/**
	 * Returns true if a 'zTXT' chunk will be output.
	 */
	bool isCompressedTextSet()
	{
		return _zTextSet;
	}

	// Other chunk types

	List<String> chunkType = new List<String>();

	List<byte[]> chunkData = new List<byte[]>();

	/**
	 * Adds a private chunk, in binary form, to the list of chunks to
	 * be stored with this image.
	 *
	 * @param type a 4-character String giving the chunk type name.
	 * @param data an array of <code>byte</code>s containing the
	 *        chunk data.
	 */
	synchronized void addPrivateChunk(String type, byte[] data)
	{
		chunkType.add(type);
		chunkData.add(data.clone());
	}

	/**
	 * Returns the number of private chunks to be written to the
	 * output file.
	 */
	synchronized int getNumPrivateChunks()
	{
		return chunkType.size();
	}

	/**
	 * Returns the type of the private chunk at a given index, as a
	 * 4-character <code>String</code>.  The index must be smaller
	 * than the return value of <code>getNumPrivateChunks</code>.
	 */
	synchronized String getPrivateChunkType(int index)
	{
		return chunkType.get(index);
	}

	/**
	 * Returns the data associated of the private chunk at a given
	 * index, as an array of <code>byte</code>s.  The index must be
	 * smaller than the return value of
	 * <code>getNumPrivateChunks</code>.
	 */
	synchronized byte[] getPrivateChunkData(int index)
	{
		return chunkData.get(index);
	}

	/**
	 * Remove all private chunks associated with this parameter instance
	 * whose 'safe-to-copy' bit is not set.  This may be advisable when
	 * transcoding PNG images.
	 */
	synchronized void removeUnsafeToCopyPrivateChunks()
	{
		List<String> newChunkType = new List<String>();
		List<byte[]> newChunkData = new List<byte[]>();

		int len = getNumPrivateChunks();
		for (int i = 0; i < len; i++)
		{
			String type = getPrivateChunkType(i);
			char lastChar = type.charAt(3);
			if (lastChar >= 'a' && lastChar <= 'z')
			{
				newChunkType.add(type);
				newChunkData.add(getPrivateChunkData(i));
			}
		}

		chunkType = newChunkType;
		chunkData = newChunkData;
	}

	/**
	 * Remove all private chunks associated with this parameter instance.
	 */
	synchronized void removeAllPrivateChunks()
	{
		chunkType = new List<String>();
		chunkData = new List<byte[]>();
	}

	/**
	 * An abs() function for use by the Paeth predictor.
	 */
	private static final int _abs(int x)
	{
		return (x < 0) ? -x : x;
	}

	/**
	 * The Paeth predictor routine used in PNG encoding.  This routine
	 * is included as a convenience to subclasses that override the
	 * <code>filterRow</code> method.
	 */
	static final int paethPredictor(int a, int b, int c)
	{
		int p = a + b - c;
		int pa = _abs(p - a);
		int pb = _abs(p - b);
		int pc = _abs(p - c);

		if ((pa <= pb) && (pa <= pc))
		{
			return a;
		}
		else if (pb <= pc)
		{
			return b;
		}
		else
		{
			return c;
		}
	}

	/**
	 * Performs filtering on a row of an image.  This method may be
	 * overridden in order to provide a custom algorithm for choosing
	 * the filter type for a given row.
	 *
	 * <p> The method is supplied with the current and previous rows
	 * of the image.  For the first row of the image, or of an
	 * interlacing pass, the previous row array will be filled with
	 * zeros as required by the PNG specification.
	 *
	 * <p> The method is also supplied with five scratch arrays.
	 * These arrays may be used within the method for any purpose.
	 * At method exit, the array at the index given by the return
	 * value of the method should contain the filtered data.  The
	 * return value will also be used as the filter type.
	 *
	 * <p> The default implementation of the method performs a trial
	 * encoding with each of the filter types, and computes the sum of
	 * absolute values of the differences between the raw bytes of the
	 * current row and the predicted values.  The index of the filter
	 * producing the smallest result is returned.
	 *
	 * <p> As an example, to perform only 'sub' filtering, this method
	 * could be implemented (non-optimally) as follows:
	 *
	 * <pre>
	 * for (int i = bytesPerPixel; i < bytesPerRow + bytesPerPixel; i++) {
	 *     int curr = currRow[i] & 0xff;
	 *     int left = currRow[i - bytesPerPixel] & 0xff;
	 *     scratchRow[PNG_FILTER_SUB][i] = (byte)(curr - left);
	 * }
	 * return PNG_FILTER_SUB;
	 * </pre>
	 *
	 * @param currRow The current row as an array of <code>byte</code>s
	 *        of length at least <code>bytesPerRow + bytesPerPixel</code>.
	 *        The pixel data starts at index <code>bytesPerPixel</code>;
	 *        the initial <code>bytesPerPixel</code> bytes are zero.
	 * @param prevRow The current row as an array of <code>byte</code>s
	 *        The pixel data starts at index <code>bytesPerPixel</code>;
	 *        the initial <code>bytesPerPixel</code> bytes are zero.
	 * @param scratchRows An array of 5 <code>byte</code> arrays of
	 *        length at least <code>bytesPerRow +
	 *        bytesPerPixel</code>, useable to hold temporary results.
	 *        The filtered row will be returned as one of the entries
	 *        of this array.  The returned filtered data should start
	 *        at index <code>bytesPerPixel</code>; The initial
	 *        <code>bytesPerPixel</code> bytes are not used.
	 * @param bytesPerRow The number of bytes in the image row.
	 *        This value will always be greater than 0.
	 * @param bytesPerPixel The number of bytes representing a single
	 *        pixel, rounded up to an integer.  This is the 'bpp' parameter
	 *        described in the PNG specification.
	 *
	 * @return The filter type to be used.  The entry of
	 *         <code>scratchRows[]</code> at this index holds the
	 *         filtered data.  */
	int filterRow(byte[] currRow, byte[] prevRow, byte[][] scratchRows,
			int bytesPerRow, int bytesPerPixel)
	{

		int[] badness = { 0, 0, 0, 0, 0 };
		int curr, left, up, upleft, diff;
		int pa, pb, pc;
		for (int i = bytesPerPixel; i < bytesPerRow + bytesPerPixel; i++)
		{
			curr = currRow[i] & 0xff;
			left = currRow[i - bytesPerPixel] & 0xff;
			up = prevRow[i] & 0xff;
			upleft = prevRow[i - bytesPerPixel] & 0xff;

			// no filter
			badness[0] += curr;

			// sub filter
			diff = curr - left;
			scratchRows[1][i] = (byte) diff;
			badness[1] += (diff > 0) ? diff : -diff;

			// up filter
			diff = curr - up;
			scratchRows[2][i] = (byte) diff;
			badness[2] += (diff >= 0) ? diff : -diff;

			// average filter
			diff = curr - ((left + up) >> 1);
			scratchRows[3][i] = (byte) diff;
			badness[3] += (diff >= 0) ? diff : -diff;

			// paeth filter

			// Original code much simplier but doesn't take full
			// advantage of relationship between pa/b/c and
			// information gleaned in abs operations.
			/// pa = up  -upleft;
			/// pb = left-upleft;
			/// pc = pa+pb;
			/// pa = abs(pa);
			/// pb = abs(pb);
			/// pc = abs(pc);
			/// if ((pa <= pb) && (pa <= pc))
			///   diff = curr-left;
			/// else if (pb <= pc)
			///   diff = curr-up;
			/// else
			///   diff = curr-upleft;

			pa = up - upleft;
			pb = left - upleft;
			if (pa < 0)
			{
				if (pb < 0)
				{
					// both pa & pb neg so pc is always greater than or
					// equal to pa or pb;
					if (pa >= pb) // since pa & pb neg check sense is reversed.
						diff = curr - left;
					else
						diff = curr - up;
				}
				else
				{
					// pa neg pb pos so we must compute pc...
					pc = pa + pb;
					pa = -pa;
					if (pa <= pb) // pc is positive and less than pb
						if (pa <= pc)
							diff = curr - left;
						else
							diff = curr - upleft;
					else
					// pc is negative and less than or equal to pa,
					// but since pa is greater than pb this isn't an issue...
					if (pb <= -pc)
						diff = curr - up;
					else
						diff = curr - upleft;
				}
			}
			else
			{
				if (pb < 0)
				{
					pb = -pb; // make it positive...
					if (pa <= pb)
					{
						// pc would be negative and less than or equal to pb
						pc = pb - pa;
						if (pa <= pc)
							diff = curr - left;
						else if (pb == pc)
							// if pa is zero then pc==pb otherwise
							// pc must be less than pb.
							diff = curr - up;
						else
							diff = curr - upleft;
					}
					else
					{
						// pc would be positive and less than pa.
						pc = pa - pb;
						if (pb <= pc)
							diff = curr - up;
						else
							diff = curr - upleft;
					}
				}
				else
				{
					// both pos so pa+pb is always greater than pa/pb
					if (pa <= pb)
						diff = curr - left;
					else
						diff = curr - up;
				}
			}
			scratchRows[4][i] = (byte) diff;
			badness[4] += (diff >= 0) ? diff : -diff;
		}
		int filterType = 0;
		int minBadness = badness[0];

		for (int i = 1; i < 5; i++)
		{
			if (badness[i] < minBadness)
			{
				minBadness = badness[i];
				filterType = i;
			}
		}

		if (filterType == 0)
		{
			System.arraycopy(currRow, bytesPerPixel, scratchRows[0],
					bytesPerPixel, bytesPerRow);
		}

		return filterType;
	}
}
