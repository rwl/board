package graph.swing.view;

import java.io.Writer;

import javax.swing.text.html.HTMLDocument;
import javax.swing.text.html.HTMLWriter;

/**
 * Subclassed to make setLineLength visible for the custom editor kit.
 */
class NoLinefeedHtmlWriter extends HTMLWriter
{
	public NoLinefeedHtmlWriter(Writer buf, HTMLDocument doc, int pos,
			int len)
	{
		super(buf, doc, pos, len);
	}

	protected void setLineLength(int l)
	{
		super.setLineLength(l);
	}
}