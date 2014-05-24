/* $Id: PngImageEncoder.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
   
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

//import java.awt.Rectangle;
//import java.awt.image.ColorModel;
//import java.awt.image.IndexColorModel;
//import java.awt.image.Raster;
//import java.awt.image.RenderedImage;
//import java.awt.image.SampleModel;
//import java.io.ByteArrayOutputStream;
//import java.io.DataOutput;
//import java.io.DataOutputStream;
//import java.io.FilterOutputStream;
//import java.io.IOException;
//import java.io.OutputStream;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.GregorianCalendar;
//import java.util.TimeZone;
//import java.util.zip.Deflater;
//import java.util.zip.DeflaterOutputStream;

class CRC
{

	private static int[] _crcTable = new int[256];

	static
	{
		// Initialize CRC table
		for (int n = 0; n < 256; n++)
		{
			int c = n;
			for (int k = 0; k < 8; k++)
			{
				if ((c & 1) == 1)
				{
					c = 0xedb88320 ^ (c >>> 1);
				}
				else
				{
					c >>>= 1;
				}

				_crcTable[n] = c;
			}
		}
	}

	public static int updateCRC(int crc, byte[] data, int off, int len)
	{
		int c = crc;

		for (int n = 0; n < len; n++)
		{
			c = _crcTable[(c ^ data[off + n]) & 0xff] ^ (c >>> 8);
		}

		return c;
	}
}

class ChunkStream extends OutputStream implements DataOutput
{

	private String _type;

	private ByteArrayOutputStream _baos;

	private DataOutputStream _dos;

	ChunkStream(String type)
	{
		this._type = type;

		this._baos = new ByteArrayOutputStream();
		this._dos = new DataOutputStream(_baos);
	}

	public void write(byte[] b) throws IOException
	{
		_dos.write(b);
	}

	public void write(byte[] b, int off, int len) throws IOException
	{
		_dos.write(b, off, len);
	}

	public void write(int b) throws IOException
	{
		_dos.write(b);
	}

	public void writeBoolean(boolean v) throws IOException
	{
		_dos.writeBoolean(v);
	}

	public void writeByte(int v) throws IOException
	{
		_dos.writeByte(v);
	}

	public void writeBytes(String s) throws IOException
	{
		_dos.writeBytes(s);
	}

	public void writeChar(int v) throws IOException
	{
		_dos.writeChar(v);
	}

	public void writeChars(String s) throws IOException
	{
		_dos.writeChars(s);
	}

	public void writeDouble(double v) throws IOException
	{
		_dos.writeDouble(v);
	}

	public void writeFloat(float v) throws IOException
	{
		_dos.writeFloat(v);
	}

	public void writeInt(int v) throws IOException
	{
		_dos.writeInt(v);
	}

	public void writeLong(long v) throws IOException
	{
		_dos.writeLong(v);
	}

	public void writeShort(int v) throws IOException
	{
		_dos.writeShort(v);
	}

	public void writeUTF(String str) throws IOException
	{
		_dos.writeUTF(str);
	}

	public void writeToStream(DataOutputStream output) throws IOException
	{
		byte[] typeSignature = new byte[4];
		typeSignature[0] = (byte) _type.charAt(0);
		typeSignature[1] = (byte) _type.charAt(1);
		typeSignature[2] = (byte) _type.charAt(2);
		typeSignature[3] = (byte) _type.charAt(3);

		_dos.flush();
		_baos.flush();

		byte[] data = _baos.toByteArray();
		int len = data.length;

		output.writeInt(len);
		output.write(typeSignature);
		output.write(data, 0, len);

		int crc = 0xffffffff;
		crc = CRC.updateCRC(crc, typeSignature, 0, 4);
		crc = CRC.updateCRC(crc, data, 0, len);
		output.writeInt(crc ^ 0xffffffff);
	}

	/**
	 * this doesnt do much, its main purpose is to stop complaints
	 * about 'outputStream not closed...'.
	 * 
	 * @throws IOException
	 */
	public void close() throws IOException
	{

		if (_baos != null)
		{
			_baos.close();
			_baos = null;
		}
		if (_dos != null)
		{
			_dos.close();
			_dos = null;
		}
	}
}

class IDATOutputStream extends FilterOutputStream
{

	private static final byte[] _typeSignature = { (byte) 'I', (byte) 'D',
			(byte) 'A', (byte) 'T' };

	private int _bytesWritten = 0;

	private int _segmentLength;

	byte[] buffer;

	public IDATOutputStream(OutputStream output, int segmentLength)
	{
		super(output);
		this._segmentLength = segmentLength;
		this.buffer = new byte[segmentLength];
	}

	public void close() throws IOException
	{
		flush();
	}

	private void _writeInt(int x) throws IOException
	{
		out.write(x >> 24);
		out.write((x >> 16) & 0xff);
		out.write((x >> 8) & 0xff);
		out.write(x & 0xff);
	}

	public void flush() throws IOException
	{
		// Length
		_writeInt(_bytesWritten);
		// 'IDAT' signature
		out.write(_typeSignature);
		// Data
		out.write(buffer, 0, _bytesWritten);

		int crc = 0xffffffff;
		crc = CRC.updateCRC(crc, _typeSignature, 0, 4);
		crc = CRC.updateCRC(crc, buffer, 0, _bytesWritten);

		// CRC
		_writeInt(crc ^ 0xffffffff);

		// Reset buffer
		_bytesWritten = 0;
	}

	public void write(byte[] b) throws IOException
	{
		this.write(b, 0, b.length);
	}

	public void write(byte[] b, int off, int len) throws IOException
	{
		while (len > 0)
		{
			int bytes = Math.min(_segmentLength - _bytesWritten, len);
			System.arraycopy(b, off, buffer, _bytesWritten, bytes);
			off += bytes;
			len -= bytes;
			_bytesWritten += bytes;

			if (_bytesWritten == _segmentLength)
			{
				flush();
			}
		}
	}

	public void write(int b) throws IOException
	{
		buffer[_bytesWritten++] = (byte) b;
		if (_bytesWritten == _segmentLength)
		{
			flush();
		}
	}
}

/**
 * An ImageEncoder for the PNG file format.
 *
 * @since EA4
 * @version $Id: PngImageEncoder.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 */
public class PngImageEncoder
{

	private static final int PNG_COLOR_GRAY = 0;

	private static final int PNG_COLOR_RGB = 2;

	private static final int PNG_COLOR_PALETTE = 3;

	private static final int PNG_COLOR_GRAY_ALPHA = 4;

	private static final int PNG_COLOR_RGB_ALPHA = 6;

	private static final byte[] magic = { (byte) 137, (byte) 80, (byte) 78,
			(byte) 71, (byte) 13, (byte) 10, (byte) 26, (byte) 10 };

	private PngEncodeParam param;

	private RenderedImage image;

	private int width;

	private int height;

	private int bitDepth;

	private int bitShift;

	private int numBands;

	private int colorType;

	private int bpp; // bytes per pixel, rounded up

	private boolean skipAlpha = false;

	private boolean compressGray = false;

	private boolean interlace;

	private byte[] redPalette = null;

	private byte[] greenPalette = null;

	private byte[] bluePalette = null;

	private byte[] alphaPalette = null;

	private DataOutputStream dataOutput;

	/** The OutputStream associcted with this ImageEncoder. */
	protected OutputStream output;

	public PngImageEncoder(OutputStream output, PngEncodeParam param)
	{
		this.output = output;
		this.param = param;

		this.dataOutput = new DataOutputStream(output);
	}

	/**
	 *
	 */
	public PngEncodeParam getParam()
	{
		return param;
	}

	/**
	 *
	 */
	public void setParam(PngEncodeParam param)
	{
		this.param = param;
	}

	/** Returns the OutputStream associated with this ImageEncoder. */
	public OutputStream getOutputStream()
	{
		return output;
	}

	private void writeMagic() throws IOException
	{
		dataOutput.write(magic);
	}

	private void writeIHDR() throws IOException
	{
		ChunkStream cs = new ChunkStream("IHDR");
		cs.writeInt(width);
		cs.writeInt(height);
		cs.writeByte((byte) bitDepth);
		cs.writeByte((byte) colorType);
		cs.writeByte((byte) 0);
		cs.writeByte((byte) 0);
		cs.writeByte(interlace ? (byte) 1 : (byte) 0);

		cs.writeToStream(dataOutput);
		cs.close();
	}

	private byte[] prevRow = null;

	private byte[] currRow = null;

	private byte[][] filteredRows = null;

	private void encodePass(OutputStream os, Raster ras, int xOffset,
			int yOffset, int xSkip, int ySkip) throws IOException
	{
		int minX = ras.getMinX();
		int minY = ras.getMinY();
		int width = ras.getWidth();
		int height = ras.getHeight();

		xOffset *= numBands;
		xSkip *= numBands;

		int samplesPerByte = 8 / bitDepth;

		int numSamples = width * numBands;
		int[] samples = new int[numSamples];

		int pixels = (numSamples - xOffset + xSkip - 1) / xSkip;
		int bytesPerRow = pixels * numBands;
		if (bitDepth < 8)
		{
			bytesPerRow = (bytesPerRow + samplesPerByte - 1) / samplesPerByte;
		}
		else if (bitDepth == 16)
		{
			bytesPerRow *= 2;
		}

		if (bytesPerRow == 0)
		{
			return;
		}

		currRow = new byte[bytesPerRow + bpp];
		prevRow = new byte[bytesPerRow + bpp];

		filteredRows = new byte[5][bytesPerRow + bpp];

		int maxValue = (1 << bitDepth) - 1;

		for (int row = minY + yOffset; row < minY + height; row += ySkip)
		{
			ras.getPixels(minX, row, width, 1, samples);

			if (compressGray)
			{
				int shift = 8 - bitDepth;
				for (int i = 0; i < width; i++)
				{
					samples[i] >>= shift;
				}
			}

			int count = bpp; // leave first 'bpp' bytes zero
			int pos = 0;
			int tmp = 0;

			switch (bitDepth)
			{
				case 1:
				case 2:
				case 4:
					// Image can only have a single band

					int mask = samplesPerByte - 1;
					for (int s = xOffset; s < numSamples; s += xSkip)
					{
						int shiftSamp = samples[s] >> bitShift;
						int val = shiftSamp > maxValue ? maxValue : shiftSamp;
						tmp = (tmp << bitDepth) | val;

						if (pos++ == mask)
						{
							currRow[count++] = (byte) tmp;
							tmp = 0;
							pos = 0;
						}
					}

					// Left shift the last byte
					if (pos != 0)
					{
						tmp <<= (samplesPerByte - pos) * bitDepth;
						currRow[count++] = (byte) tmp;
					}
					break;

				case 8:
					for (int s = xOffset; s < numSamples; s += xSkip)
					{
						for (int b = 0; b < numBands; b++)
						{
							int sampShift = samples[s + b] >> bitShift;
							currRow[count++] = (byte) (sampShift > maxValue ? maxValue : sampShift);
						}
					}
					break;

				case 16:
					for (int s = xOffset; s < numSamples; s += xSkip)
					{
						for (int b = 0; b < numBands; b++)
						{
							int sampShift = samples[s + b] >> bitShift;
							int val = sampShift > maxValue ? maxValue : sampShift;
							currRow[count++] = (byte) (val >> 8);
							currRow[count++] = (byte) (val & 0xff);
						}
					}
					break;
			}

			// Perform filtering
			int filterType = param.filterRow(currRow, prevRow, filteredRows,
					bytesPerRow, bpp);

			os.write(filterType);
			os.write(filteredRows[filterType], bpp, bytesPerRow);

			// Swap current and previous rows
			byte[] swap = currRow;
			currRow = prevRow;
			prevRow = swap;
		}
	}

	private void writeIDAT() throws IOException
	{
		IDATOutputStream ios = new IDATOutputStream(dataOutput, 8192);
		DeflaterOutputStream dos = new DeflaterOutputStream(ios,
				new Deflater(9));

		// Future work - don't convert entire image to a Raster It
		// might seem that you could just call image.getData() but
		// 'BufferedImage.subImage' doesn't appear to set the Width
		// and height properly of the Child Raster, so the Raster
		// you get back here appears larger than it should.
		// This solves that problem by bounding the raster to the
		// image's bounds...
		Raster ras = image.getData(new Rectangle(image.getMinX(), image
				.getMinY(), image.getWidth(), image.getHeight()));
		// System.out.println("Image: [" +
		//                    image.getMinY()  + ", " +
		//                    image.getMinX()  + ", " +
		//                    image.getWidth()  + ", " +
		//                    image.getHeight() + "]");
		// System.out.println("Ras: [" +
		//                    ras.getMinX()  + ", " +
		//                    ras.getMinY()  + ", " +
		//                    ras.getWidth()  + ", " +
		//                    ras.getHeight() + "]");

		if (skipAlpha)
		{
			int numBands = ras.getNumBands() - 1;
			int[] bandList = new int[numBands];
			for (int i = 0; i < numBands; i++)
			{
				bandList[i] = i;
			}
			ras = ras.createChild(0, 0, ras.getWidth(), ras.getHeight(), 0, 0,
					bandList);
		}

		if (interlace)
		{
			// Interlacing pass 1
			encodePass(dos, ras, 0, 0, 8, 8);
			// Interlacing pass 2
			encodePass(dos, ras, 4, 0, 8, 8);
			// Interlacing pass 3
			encodePass(dos, ras, 0, 4, 4, 8);
			// Interlacing pass 4
			encodePass(dos, ras, 2, 0, 4, 4);
			// Interlacing pass 5
			encodePass(dos, ras, 0, 2, 2, 4);
			// Interlacing pass 6
			encodePass(dos, ras, 1, 0, 2, 2);
			// Interlacing pass 7
			encodePass(dos, ras, 0, 1, 1, 2);
		}
		else
		{
			encodePass(dos, ras, 0, 0, 1, 1);
		}

		dos.finish();
		ios.flush();
	}

	private void writeIEND() throws IOException
	{
		ChunkStream cs = new ChunkStream("IEND");
		cs.writeToStream(dataOutput);
		cs.close();
	}

	private static final float[] srgbChroma = { 0.31270F, 0.329F, 0.64F, 0.33F,
			0.3F, 0.6F, 0.15F, 0.06F };

	private void writeCHRM() throws IOException
	{
		if (param.isChromaticitySet() || param.isSRGBIntentSet())
		{
			ChunkStream cs = new ChunkStream("cHRM");

			float[] chroma;
			if (!param.isSRGBIntentSet())
			{
				chroma = param.getChromaticity();
			}
			else
			{
				chroma = srgbChroma; // SRGB chromaticities
			}

			for (int i = 0; i < 8; i++)
			{
				cs.writeInt((int) (chroma[i] * 100000));
			}
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeGAMA() throws IOException
	{
		if (param.isGammaSet() || param.isSRGBIntentSet())
		{
			ChunkStream cs = new ChunkStream("gAMA");

			float gamma;
			if (!param.isSRGBIntentSet())
			{
				gamma = param.getGamma();
			}
			else
			{
				gamma = 1.0F / 2.2F; // SRGB gamma
			}
			// TD should include the .5 but causes regard to say
			// everything is different.
			cs.writeInt((int) (gamma * 100000/*+0.5*/));
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeICCP() throws IOException
	{
		if (param.isICCProfileDataSet())
		{
			ChunkStream cs = new ChunkStream("iCCP");
			byte[] ICCProfileData = param.getICCProfileData();
			cs.write(ICCProfileData);
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeSBIT() throws IOException
	{
		if (param.isSignificantBitsSet())
		{
			ChunkStream cs = new ChunkStream("sBIT");
			int[] significantBits = param.getSignificantBits();
			int len = significantBits.length;
			for (int i = 0; i < len; i++)
			{
				cs.writeByte(significantBits[i]);
			}
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeSRGB() throws IOException
	{
		if (param.isSRGBIntentSet())
		{
			ChunkStream cs = new ChunkStream("sRGB");

			int intent = param.getSRGBIntent();
			cs.write(intent);
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writePLTE() throws IOException
	{
		if (redPalette == null)
		{
			return;
		}

		ChunkStream cs = new ChunkStream("PLTE");
		for (int i = 0; i < redPalette.length; i++)
		{
			cs.writeByte(redPalette[i]);
			cs.writeByte(greenPalette[i]);
			cs.writeByte(bluePalette[i]);
		}

		cs.writeToStream(dataOutput);
		cs.close();
	}

	private void writeBKGD() throws IOException
	{
		if (param.isBackgroundSet())
		{
			ChunkStream cs = new ChunkStream("bKGD");

			switch (colorType)
			{
				case PNG_COLOR_GRAY:
				case PNG_COLOR_GRAY_ALPHA:
					int gray = ((Gray) param)
							.getBackgroundGray();
					cs.writeShort(gray);
					break;

				case PNG_COLOR_PALETTE:
					int index = ((Palette) param)
							.getBackgroundPaletteIndex();
					cs.writeByte(index);
					break;

				case PNG_COLOR_RGB:
				case PNG_COLOR_RGB_ALPHA:
					int[] rgb = ((RGB) param)
							.getBackgroundRGB();
					cs.writeShort(rgb[0]);
					cs.writeShort(rgb[1]);
					cs.writeShort(rgb[2]);
					break;
			}

			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeHIST() throws IOException
	{
		if (param.isPaletteHistogramSet())
		{
			ChunkStream cs = new ChunkStream("hIST");

			int[] hist = param.getPaletteHistogram();
			for (int i = 0; i < hist.length; i++)
			{
				cs.writeShort(hist[i]);
			}

			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeTRNS() throws IOException
	{
		if (param.isTransparencySet() && (colorType != PNG_COLOR_GRAY_ALPHA)
				&& (colorType != PNG_COLOR_RGB_ALPHA))
		{
			ChunkStream cs = new ChunkStream("tRNS");

			if (param instanceof Palette)
			{
				byte[] t = ((Palette) param)
						.getPaletteTransparency();
				for (int i = 0; i < t.length; i++)
				{
					cs.writeByte(t[i]);
				}
			}
			else if (param instanceof Gray)
			{
				int t = ((Gray) param).getTransparentGray();
				cs.writeShort(t);
			}
			else if (param instanceof RGB)
			{
				int[] t = ((RGB) param).getTransparentRGB();
				cs.writeShort(t[0]);
				cs.writeShort(t[1]);
				cs.writeShort(t[2]);
			}

			cs.writeToStream(dataOutput);
			cs.close();
		}
		else if (colorType == PNG_COLOR_PALETTE)
		{
			int lastEntry = Math.min(255, alphaPalette.length - 1);
			int nonOpaque;
			for (nonOpaque = lastEntry; nonOpaque >= 0; nonOpaque--)
			{
				if (alphaPalette[nonOpaque] != (byte) 255)
				{
					break;
				}
			}

			if (nonOpaque >= 0)
			{
				ChunkStream cs = new ChunkStream("tRNS");
				for (int i = 0; i <= nonOpaque; i++)
				{
					cs.writeByte(alphaPalette[i]);
				}
				cs.writeToStream(dataOutput);
				cs.close();
			}
		}
	}

	private void writePHYS() throws IOException
	{
		if (param.isPhysicalDimensionSet())
		{
			ChunkStream cs = new ChunkStream("pHYs");

			int[] dims = param.getPhysicalDimension();
			cs.writeInt(dims[0]);
			cs.writeInt(dims[1]);
			cs.writeByte((byte) dims[2]);

			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeSPLT() throws IOException
	{
		if (param.isSuggestedPaletteSet())
		{
			ChunkStream cs = new ChunkStream("sPLT");

			System.out.println("sPLT not supported yet.");

			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeTIME() throws IOException
	{
		if (param.isModificationTimeSet())
		{
			ChunkStream cs = new ChunkStream("tIME");

			Date date = param.getModificationTime();
			TimeZone gmt = TimeZone.getTimeZone("GMT");

			GregorianCalendar cal = new GregorianCalendar(gmt);
			cal.setTime(date);

			int year = cal.get(Calendar.YEAR);
			int month = cal.get(Calendar.MONTH);
			int day = cal.get(Calendar.DAY_OF_MONTH);
			int hour = cal.get(Calendar.HOUR_OF_DAY);
			int minute = cal.get(Calendar.MINUTE);
			int second = cal.get(Calendar.SECOND);

			cs.writeShort(year);
			cs.writeByte(month + 1);
			cs.writeByte(day);
			cs.writeByte(hour);
			cs.writeByte(minute);
			cs.writeByte(second);

			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	private void writeTEXT() throws IOException
	{
		if (param.isTextSet())
		{
			String[] text = param.getText();

			for (int i = 0; i < text.length / 2; i++)
			{
				byte[] keyword = text[2 * i].getBytes();
				byte[] value = text[2 * i + 1].getBytes();

				ChunkStream cs = new ChunkStream("tEXt");

				cs.write(keyword, 0, Math.min(keyword.length, 79));
				cs.write(0);
				cs.write(value);

				cs.writeToStream(dataOutput);
				cs.close();
			}
		}
	}

	private void writeZTXT() throws IOException
	{
		if (param.isCompressedTextSet())
		{
			String[] text = param.getCompressedText();

			for (int i = 0; i < text.length / 2; i++)
			{
				byte[] keyword = text[2 * i].getBytes();
				byte[] value = text[2 * i + 1].getBytes();

				ChunkStream cs = new ChunkStream("zTXt");

				cs.write(keyword, 0, Math.min(keyword.length, 79));
				cs.write(0);
				cs.write(0);

				DeflaterOutputStream dos = new DeflaterOutputStream(cs,
						new Deflater(Deflater.BEST_COMPRESSION, true));
				dos.write(value);
				dos.finish();

				cs.writeToStream(dataOutput);
				cs.close();
			}
		}
	}

	private void writePrivateChunks() throws IOException
	{
		int numChunks = param.getNumPrivateChunks();
		for (int i = 0; i < numChunks; i++)
		{
			String type = param.getPrivateChunkType(i);
			byte[] data = param.getPrivateChunkData(i);

			ChunkStream cs = new ChunkStream(type);
			cs.write(data);
			cs.writeToStream(dataOutput);
			cs.close();
		}
	}

	/**
	 * Analyzes a set of palettes and determines if it can be expressed
	 * as a standard set of gray values, with zero or one values being
	 * fully transparent and the rest being fully opaque.  If it
	 * is possible to express the data thusly, the method returns
	 * a suitable instance of PNGEncodeParam.Gray; otherwise it
	 * returns null.
	 */
	private Gray createGrayParam(byte[] redPalette,
			byte[] greenPalette, byte[] bluePalette, byte[] alphaPalette)
	{
		Gray param = new Gray();
		int numTransparent = 0;

		int grayFactor = 255 / ((1 << bitDepth) - 1);
		int entries = 1 << bitDepth;
		for (int i = 0; i < entries; i++)
		{
			byte red = redPalette[i];
			if ((red != i * grayFactor) || (red != greenPalette[i])
					|| (red != bluePalette[i]))
			{
				return null;
			}

			// All alphas must be 255 except at most 1 can be 0
			byte alpha = alphaPalette[i];
			if (alpha == (byte) 0)
			{
				param.setTransparentGray(i);

				++numTransparent;
				if (numTransparent > 1)
				{
					return null;
				}
			}
			else if (alpha != (byte) 255)
			{
				return null;
			}
		}

		return param;
	}

	/**
	 * This method encodes a <code>RenderedImage</code> into PNG.
	 * The stream into which the PNG is dumped is not closed at
	 * the end of the operation, this should be done if needed
	 * by the caller of this method.
	 */
	public void encode(RenderedImage im) throws IOException
	{
		this.image = im;
		this.width = image.getWidth();
		this.height = image.getHeight();

		SampleModel sampleModel = image.getSampleModel();

		int[] sampleSize = sampleModel.getSampleSize();

		// Set bitDepth to a sentinel value
		this.bitDepth = -1;
		this.bitShift = 0;

		// Allow user to override the bit depth of gray images
		if (param instanceof Gray)
		{
			Gray paramg = (Gray) param;
			if (paramg.isBitDepthSet())
			{
				this.bitDepth = paramg.getBitDepth();
			}

			if (paramg.isBitShiftSet())
			{
				this.bitShift = paramg.getBitShift();
			}
		}

		// Get bit depth from image if not set in param
		if (this.bitDepth == -1)
		{
			// Get bit depth from channel 0 of the image

			this.bitDepth = sampleSize[0];
			// Ensure all channels have the same bit depth
			for (int i = 1; i < sampleSize.length; i++)
			{
				if (sampleSize[i] != bitDepth)
				{
					throw new RuntimeException();
				}
			}

			// Round bit depth up to a power of 2
			if (bitDepth > 2 && bitDepth < 4)
			{
				bitDepth = 4;
			}
			else if (bitDepth > 4 && bitDepth < 8)
			{
				bitDepth = 8;
			}
			else if (bitDepth > 8 && bitDepth < 16)
			{
				bitDepth = 16;
			}
			else if (bitDepth > 16)
			{
				throw new RuntimeException();
			}
		}

		this.numBands = sampleModel.getNumBands();
		this.bpp = numBands * ((bitDepth == 16) ? 2 : 1);

		ColorModel colorModel = image.getColorModel();
		if (colorModel instanceof IndexColorModel)
		{
			if (bitDepth < 1 || bitDepth > 8)
			{
				throw new RuntimeException();
			}
			if (sampleModel.getNumBands() != 1)
			{
				throw new RuntimeException();
			}

			IndexColorModel icm = (IndexColorModel) colorModel;
			int size = icm.getMapSize();

			redPalette = new byte[size];
			greenPalette = new byte[size];
			bluePalette = new byte[size];
			alphaPalette = new byte[size];

			icm.getReds(redPalette);
			icm.getGreens(greenPalette);
			icm.getBlues(bluePalette);
			icm.getAlphas(alphaPalette);

			this.bpp = 1;

			if (param == null)
			{
				param = createGrayParam(redPalette, greenPalette, bluePalette,
						alphaPalette);
			}

			// If param is still null, it can't be expressed as gray
			if (param == null)
			{
				param = new Palette();
			}

			if (param instanceof Palette)
			{
				// If palette not set in param, create one from the ColorModel.
				Palette parami = (Palette) param;
				if (parami.isPaletteSet())
				{
					int[] palette = parami.getPalette();
					size = palette.length / 3;

					int index = 0;
					for (int i = 0; i < size; i++)
					{
						redPalette[i] = (byte) palette[index++];
						greenPalette[i] = (byte) palette[index++];
						bluePalette[i] = (byte) palette[index++];
						alphaPalette[i] = (byte) 255;
					}
				}
				this.colorType = PNG_COLOR_PALETTE;
			}
			else if (param instanceof Gray)
			{
				redPalette = greenPalette = bluePalette = alphaPalette = null;
				this.colorType = PNG_COLOR_GRAY;
			}
			else
			{
				throw new RuntimeException();
			}
		}
		else if (numBands == 1)
		{
			if (param == null)
			{
				param = new Gray();
			}
			this.colorType = PNG_COLOR_GRAY;
		}
		else if (numBands == 2)
		{
			if (param == null)
			{
				param = new Gray();
			}

			if (param.isTransparencySet())
			{
				skipAlpha = true;
				numBands = 1;
				if ((sampleSize[0] == 8) && (bitDepth < 8))
				{
					compressGray = true;
				}
				bpp = (bitDepth == 16) ? 2 : 1;
				this.colorType = PNG_COLOR_GRAY;
			}
			else
			{
				if (this.bitDepth < 8)
				{
					this.bitDepth = 8;
				}
				this.colorType = PNG_COLOR_GRAY_ALPHA;
			}
		}
		else if (numBands == 3)
		{
			if (param == null)
			{
				param = new RGB();
			}
			this.colorType = PNG_COLOR_RGB;
		}
		else if (numBands == 4)
		{
			if (param == null)
			{
				param = new RGB();
			}
			if (param.isTransparencySet())
			{
				skipAlpha = true;
				numBands = 3;
				bpp = (bitDepth == 16) ? 6 : 3;
				this.colorType = PNG_COLOR_RGB;
			}
			else
			{
				this.colorType = PNG_COLOR_RGB_ALPHA;
			}
		}

		interlace = param.getInterlacing();

		writeMagic();

		writeIHDR();

		writeCHRM();
		writeGAMA();
		writeICCP();
		writeSBIT();
		writeSRGB();

		writePLTE();

		writeHIST();
		writeTRNS();
		writeBKGD();

		writePHYS();
		writeSPLT();
		writeTIME();
		writeTEXT();
		writeZTXT();

		writePrivateChunks();

		writeIDAT();

		writeIEND();

		dataOutput.flush();
	}
}
