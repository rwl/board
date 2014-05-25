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
//import java.util.MissingResourceException;

/**
 * This class is the superclass of all parsers. It provides localization
 * and error handling methods.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractParser.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 */
public abstract class AbstractParser implements Parser
{

	/**
	 * The default resource bundle base name.
	 */
	static final String BUNDLE_CLASSNAME = "org.apache.batik.parser.resources.Messages";

	/**
	 * The error handler.
	 */
	ErrorHandler errorHandler = new DefaultErrorHandler();

	/**
	 * The normalizing reader.
	 */
	NormalizingReader reader;

	/**
	 * The current character.
	 */
	int current;

	/**
	 * Returns the current character value.
	 */
	int getCurrent()
	{
		return current;
	}

	/**
	 * Allow an application to register an error event handler.
	 *
	 * <p>If the application does not register an error event handler,
	 * all error events reported by the parser will cause an exception
	 * to be thrown.
	 *
	 * <p>Applications may register a new or different handler in the
	 * middle of a parse, and the parser must begin using the new
	 * handler immediately.</p>
	 * @param handler The error handler.
	 */
	void setErrorHandler(ErrorHandler handler)
	{
		errorHandler = handler;
	}

	/**
	 * Parses the given string.
	 */
	void parse(String s) //throws ParseException
	{
		try
		{
			reader = new StringNormalizingReader(s);
			doParse();
		}
		on IOException catch (e)
		{
			errorHandler.error(new ParseException(createErrorMessage(
					"io.exception", null), e));
		}
	}

	/**
	 * Method responsible for actually parsing data after AbstractParser
	 * has initialized itself.
	 */
	abstract void doParse() //throws ParseException, IOException;

	/**
	 * Signals an error to the error handler.
	 * @param key The message key in the resource bundle.
	 * @param args The message arguments.
	 */
	void reportError(String key, List<Object> args) //throws ParseException
	{
		errorHandler.error(new ParseException(createErrorMessage(key, args),
				reader.getLine(), reader.getColumn()));
	}

	/**
	 * simple api to call often reported error.
	 * Just a wrapper for reportError().
	 *
	 * @param expectedChar what caller expected
	 * @param currentChar what caller found
	 */
	void reportCharacterExpectedError(char expectedChar,
			int currentChar)
	{
		reportError("character.expected", new List<Object> {
				new Character(expectedChar), new Integer(currentChar) });

	}

	/**
	 * simple api to call often reported error.
	 * Just a wrapper for reportError().
	 *
	 * @param currentChar what the caller found and didnt expect
	 */
	void reportUnexpectedCharacterError(int currentChar)
	{
		reportError("character.unexpected", new List<Object> { new Integer(
				currentChar) });

	}

	/**
	 * Returns a localized error message.
	 * @param key The message key in the resource bundle.
	 * @param args The message arguments.
	 */
	String createErrorMessage(String key, List<Object> args)
	{
		try
		{
			// TODO Replace with mx localisation
			// return formatMessage(key, args);
			return "";
		}
		on MissingResourceException catch (e)
		{
			return key;
		}
	}

	/**
	 * Returns the resource bundle base name.
	 * @return BUNDLE_CLASSNAME.
	 */
	String getBundleClassName()
	{
		return BUNDLE_CLASSNAME;
	}

	/**
	 * Skips the whitespaces in the current reader.
	 */
	void skipSpaces() //throws IOException
	{
		for (;;)
		{
			switch (current)
			{
				default:
					return;
				case 0x20:
				case 0x09:
				case 0x0D:
				case 0x0A:
			}
			current = reader.read();
		}
	}

	/**
	 * Skips the whitespaces and an optional comma.
	 */
	void skipCommaSpaces() //throws IOException
	{
		wsp1: for (;;)
		{
			switch (current)
			{
				default:
					break wsp1;
				case 0x20:
				case 0x9:
				case 0xD:
				case 0xA:
			}
			current = reader.read();
		}
		if (current == ',')
		{
			wsp2: for (;;)
			{
				switch (current = reader.read())
				{
					default:
						break wsp2;
					case 0x20:
					case 0x9:
					case 0xD:
					case 0xA:
				}
			}
		}
	}
}
