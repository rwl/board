/**
 * Copyright (c) 2010, David Benson, Gaudenz Alder
 */
part of graph.util.png;

//import java.io.BufferedInputStream;
//import java.io.ByteArrayInputStream;
//import java.io.DataInputStream;
//import java.io.InputStream;
//import java.util.Hashtable;
//import java.util.Map;
//import java.util.zip.InflaterInputStream;

/**
 * Utility class to extract the compression text portion of a PNG
 */
class PngTextDecoder
{
	/**
	 * 
	 */
	static final int PNG_CHUNK_ZTXT = 2052348020;

	/**
	 * 
	 */
	static final int PNG_CHUNK_IEND = 1229278788;

	/**
	 * Decodes the zTXt chunk of the given PNG image stream.
	 */
	static Map<String, String> decodeCompressedText(InputStream stream)
	{
		Map<String, String> result = new Hashtable<String, String>();

		if (!stream.markSupported())
		{
			stream = new BufferedInputStream(stream);
		}
		DataInputStream distream = new DataInputStream(stream);

		try
		{
			long magic = distream.readLong();
			if (magic != 0x89504e470d0a1a0aL)
			{
				throw new RuntimeException("PNGImageDecoder0");
			}
		}
		on Exception catch (e)
		{
			e.printStackTrace();
			throw new RuntimeException("PNGImageDecoder1");
		}

		do
		{
			try
			{
				int length = distream.readInt();
				int type = distream.readInt();
				List<byte> data = new byte[length];
				distream.readFully(data);
				distream.readInt(); // Move past the crc

				if (type == PNG_CHUNK_IEND)
				{
					return result;
				}
				else if (type == PNG_CHUNK_ZTXT)
				{
					int currentIndex = 0;
					while ((data[currentIndex++]) != 0)
					{
					}

					String key = new String(data, 0, currentIndex - 1);

					// TODO Add option to decode uncompressed text
					// NOTE Do not comment this line out as the
					// increment of the currentIndex is required
					byte compressType = data[currentIndex++];

					StringBuffer value = new StringBuffer();
					try
					{
						InputStream is = new ByteArrayInputStream(data,
								currentIndex, length);
						InputStream iis = new InflaterInputStream(is);

						int c;
						while ((c = iis.read()) != -1)
						{
							value.append((char) c);
						}

						result.put(String.valueOf(key), String.valueOf(value));
					}
					on Exception catch (e)
					{
						e.printStackTrace();
					}
				}
			}
			on Exception catch (e)
			{
				e.printStackTrace();
				return null;
			}
		}
		while (true);
	}
}