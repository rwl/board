/**
 * Copyright (c) 2010, Gaudenz Alder, David Benson
 */
part of graph.shape;

//import java.awt.Color;
//import java.awt.Font;
//import java.awt.FontMetrics;
//import java.awt.Graphics2D;
//import java.awt.Rectangle;

class DefaultTextShape implements ITextShape {

  void paintShape(Graphics2DCanvas canvas, String text, CellState state, Map<String, Object> style) {
    awt.Rectangle rect = state.getLabelBounds().getRectangle();
    Graphics2D g = canvas.getGraphics();

    if (g.getClipBounds() == null || g.getClipBounds().intersects(rect)) {
      bool horizontal = Utils.isTrue(style, Constants.STYLE_HORIZONTAL, true);
      double scale = canvas.getScale();
      int x = rect.x;
      int y = rect.y;
      int w = rect.width;
      int h = rect.height;

      if (!horizontal) {
        g.rotate(-Math.PI / 2, x + w / 2, y + h / 2);
        g.translate(w / 2 - h / 2, h / 2 - w / 2);
      }

      Color fontColor = Utils.getColor(style, Constants.STYLE_FONTCOLOR, Color.black);
      g.setColor(fontColor);

      // Shifts the y-coordinate down by the ascent plus a workaround
      // for the line not starting at the exact vertical location
      Font scaledFont = Utils.getFont(style, scale);
      g.setFont(scaledFont);
      int fontSize = Utils.getInt(style, Constants.STYLE_FONTSIZE, Constants.DEFAULT_FONTSIZE);
      FontMetrics fm = g.getFontMetrics();
      int scaledFontSize = scaledFont.getSize();
      double fontScaleFactor = (scaledFontSize as double) / (fontSize as double);
      // This factor is the amount by which the font is smaller/
      // larger than we expect for the given scale. 1 means it's
      // correct, 0.8 means the font is 0.8 the size we expected
      // when scaled, etc.
      double fontScaleRatio = fontScaleFactor / scale;
      // The y position has to be moved by (1 - ratio) * height / 2
      y += 2 * fm.getMaxAscent() - fm.getHeight() + Constants.LABEL_INSET * scale;

      Object vertAlign = Utils.getString(style, Constants.STYLE_VERTICAL_ALIGN, Constants.ALIGN_MIDDLE);
      double vertAlignProportion = 0.5;

      if (vertAlign == Constants.ALIGN_TOP) {
        vertAlignProportion = 0.0;
      } else if (vertAlign == Constants.ALIGN_BOTTOM) {
        vertAlignProportion = 1.0;
      }

      y += (1.0 - fontScaleRatio) * h * vertAlignProportion;

      // Gets the alignment settings
      Object align = Utils.getString(style, Constants.STYLE_ALIGN, Constants.ALIGN_CENTER);

      if (align == Constants.ALIGN_LEFT) {
        x += Constants.LABEL_INSET * scale;
      } else if (align == Constants.ALIGN_RIGHT) {
        x -= Constants.LABEL_INSET * scale;
      }

      // Draws the text line by line
      List<String> lines = text.split("\n");

      for (int i = 0; i < lines.length; i++) {
        int dx = 0;

        if (align == Constants.ALIGN_CENTER) {
          int sw = fm.stringWidth(lines[i]);

          if (horizontal) {
            dx = ((w - sw) / 2) as int;
          } else {
            dx = ((h - sw) / 2) as int;
          }
        } else if (align == Constants.ALIGN_RIGHT) {
          int sw = fm.stringWidth(lines[i]);
          dx = ((horizontal) ? w : h) - sw;
        }

        g.drawString(lines[i], x + dx, y);
        _postProcessLine(text, lines[i], fm, canvas, x + dx, y);
        y += fm.getHeight() + Constants.LINESPACING;
      }
    }
  }

  /**
   * Hook to add functionality after a line has been drawn
   * @param text the entire label text
   * @param line the line at the specified location
   * @param fm the text font metrics
   * @param canvas the canvas object currently being painted to
   * @param x the x co-ord of the baseline of the text line
   * @param y the y co-ord of the baseline of the text line
   */
  void _postProcessLine(String text, String line, FontMetrics fm, Graphics2DCanvas canvas, int x, int y) {}
}
