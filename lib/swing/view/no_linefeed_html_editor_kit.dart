part of graph.swing.view;

//import java.io.IOException;
//import java.io.Writer;

//import javax.swing.text.BadLocationException;
//import javax.swing.text.Document;
//import javax.swing.text.StyledDocument;
//import javax.swing.text.html.HTMLDocument;
//import javax.swing.text.html.HTMLEditorKit;
//import javax.swing.text.html.MinimalHTMLWriter;

/**
 * Workaround for inserted linefeeds when getting text from HTML editor.
 */
class NoLinefeedHtmlEditorKit extends HTMLEditorKit {
  void write(Writer out, Document doc, int pos, int len) //throws IOException, BadLocationException
  {
    if (doc is HTMLDocument) {
      NoLinefeedHtmlWriter w = new NoLinefeedHtmlWriter(out, doc as HTMLDocument, pos, len);

      // the default behavior of write() was to setLineLength(80) which resulted in
      // the inserting or a CR/LF around the 80ith character in any given
      // line. This was not good because if a merge tag was in that range, it would
      // insert CR/LF in between the merge tag and then the replacement of
      // merge tag with bean values was not working.
      w.setLineLength(Integer.MAX_VALUE);
      w.write();
    } else if (doc is StyledDocument) {
      MinimalHTMLWriter w = new MinimalHTMLWriter(out, doc as StyledDocument, pos, len);
      w.write();
    } else {
      super.write(out, doc, pos, len);
    }
  }
}
