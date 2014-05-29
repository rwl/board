/*

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
part of graph.util.svg;

//import java.io.IOException;

/**
 * This class represents a NormalizingReader which handles Strings.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StringNormalizingReader.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 */
class StringNormalizingReader extends NormalizingReader
{

	/**
	 * The characters.
	 */
	String string;

	/**
	 * The length of the string.
	 */
	int length;

	/**
	 * The index of the next character.
	 */
	int next;

	/**
	 * The current line in the stream.
	 */
	int line = 1;

	/**
	 * The current column in the stream.
	 */
	int column;

	/**
	 * Creates a new StringNormalizingReader.
	 * @param s The string to read.
	 */
	StringNormalizingReader(String s)
	{
		string = s;
		length = s.length;
	}

	/**
	 * Read a single character.  This method will block until a
	 * character is available, an I/O error occurs, or the end of the
	 * stream is reached.
	 */
	int read() //throws IOException
	{
		int result = (length == next) ? -1 : string.charAt(next++);
		if (result <= 13)
		{
			switch (result)
			{
				case 13:
					column = 0;
					line++;
					int c = (length == next) ? -1 : string.charAt(next);
					if (c == 10)
					{
						next++;
					}
					return 10;

				case 10:
					column = 0;
					line++;
			}
		}
		return result;
	}

	/**
	 * Returns the current line in the stream.
	 */
	int getLine()
	{
		return line;
	}

	/**
	 * Returns the current column in the stream.
	 */
	int getColumn()
	{
		return column;
	}

	/**
	 * Close the stream.
	 */
	void close() //throws IOException
	{
		string = null;
	}
}
