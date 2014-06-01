/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.util;

//import java.awt.Color;
//import java.util.HashMap;
//import java.util.regex.Pattern;

/**
 * Contains various helper methods for use with Graph.
 */
class HtmlColor {

  /**
	 * HTML color lookup table. Supports the 147 CSS color names.
	 */
  static HashMap<String, awt.Color> _htmlColors = new HashMap<String, awt.Color>();

  static final RegExp _rgbRegex = new RegExp(r"rgba?\\([^)]*\\)", caseSensitive: false);

  /**
	 * 
	 */
  static String hexString(awt.Color color) {
    int r = color.getRed();
    int g = color.getGreen();
    int b = color.getBlue();

    return String.format("#%02X%02X%02X", r, g, b);
  }

  /**
	 * Returns a hex representation for the given color.
	 * 
	 * @param color
	 *            Color to return the hex string for.
	 * @return Returns a hex string for the given color.
	 */
  static String getHexColorString(Color color) {
    return int.toHexString((color.getRGB() & 0x00FFFFFF) | (color.getAlpha() << 24));
  }

  /**
	 * Convert a string representing a 24/32bit hex color value into a Color
	 * object. All 147 CSS color names and none are also supported. None returns
	 * null.
	 * Examples of possible hex color values are: #C3D9FF, #6482B9 and #774400,
	 * but note that you do not include the "#" in the string passed in
	 * 
	 * @param str
	 *            the 24/32bit hex string value (ARGB)
	 * @return java.awt.Color (24bit RGB on JDK 1.1, 24/32bit ARGB on JDK1.2)
	 * @exception FormatException
	 *                if the specified string cannot be interpreted as a
	 *                hexidecimal integer
	 */
  static Color parseColor(String str) //throws NumberFormatException
  {
    if (str == null || str.equals(Constants.NONE)) {
      return null;
    } else if (_rgbRegex.matcher(str).matches()) {
      return _parseRgb(str);
    } else if (!str.startsWith("#")) {
      Color result = _htmlColors.get(str);

      // LATER: Return the result even if it's null to avoid invalid color codes
      if (result != null) {
        return result;
      }
    } else if (str.length == 4) {
      // Adds support for special short notation of hex colors, eg. #abc=#aabbcc
      str = new String(['#', str.charAt(1), str.charAt(1), str.charAt(2), str.charAt(2), str.charAt(3), str.charAt(3)]);
    }

    int value = 0;
    try {
      String tmp = str;

      if (tmp.startsWith("#")) {
        tmp = tmp.substring(1);
      }

      value = Long.parse(tmp, 16) as int;
    } on FormatException catch (nfe) {
      try {
        value = Long.decode(str).intValue();
      } on FormatException catch (e) {
        // ignores exception and returns black
      }
    }

    return new Color(value);
  }

  static Color _parseRgb(String rgbString) {
    List<String> values = rgbString.split("[,()]");

    String red = values[1].trim();
    String green = values[2].trim();
    String blue = values[3].trim();
    String alpha = "1.0";

    if (values.length >= 5) {
      alpha = values[4].trim();
    }

    return new Color(_parseValue(red, 255), _parseValue(green, 255), _parseValue(blue, 255), _parseAlpha(alpha));
  }

  static float _parseValue(String val, int max) {
    if (val.endsWith("%")) {
      return (float)(_parsePercent(val) * max / max);
    }

    return (float)(int.parseInt(val) / max);
  }

  static double _parsePercent(String perc) {
    return int.parseInt(perc.substring(0, perc.length - 1)) / 100.0;
  }

  static float _parseAlpha(String alpha) {
    return Float.parseFloat(alpha);
  }

  /**
	 * Initializes HTML color table.
	 */
  init() {
    _htmlColors.put("aliceblue", parseColor("#F0F8FF"));
    _htmlColors.put("antiquewhite", parseColor("#FAEBD7"));
    _htmlColors.put("aqua", parseColor("#00FFFF"));
    _htmlColors.put("aquamarine", parseColor("#7FFFD4"));
    _htmlColors.put("azure", parseColor("#F0FFFF"));
    _htmlColors.put("beige", parseColor("#F5F5DC"));
    _htmlColors.put("bisque", parseColor("#FFE4C4"));
    _htmlColors.put("black", parseColor("#000000"));
    _htmlColors.put("blanchedalmond", parseColor("#FFEBCD"));
    _htmlColors.put("blue", parseColor("#0000FF"));
    _htmlColors.put("blueviolet", parseColor("#8A2BE2"));
    _htmlColors.put("brown", parseColor("#A52A2A"));
    _htmlColors.put("burlywood", parseColor("#DEB887"));
    _htmlColors.put("cadetblue", parseColor("#5F9EA0"));
    _htmlColors.put("chartreuse", parseColor("#7FFF00"));
    _htmlColors.put("chocolate", parseColor("#D2691E"));
    _htmlColors.put("coral", parseColor("#FF7F50"));
    _htmlColors.put("cornflowerblue", parseColor("#6495ED"));
    _htmlColors.put("cornsilk", parseColor("#FFF8DC"));
    _htmlColors.put("crimson", parseColor("#DC143C"));
    _htmlColors.put("cyan", parseColor("#00FFFF"));
    _htmlColors.put("darkblue", parseColor("#00008B"));
    _htmlColors.put("darkcyan", parseColor("#008B8B"));
    _htmlColors.put("darkgoldenrod", parseColor("#B8860B"));
    _htmlColors.put("darkgray", parseColor("#A9A9A9"));
    _htmlColors.put("darkgrey", parseColor("#A9A9A9"));
    _htmlColors.put("darkgreen", parseColor("#006400"));
    _htmlColors.put("darkkhaki", parseColor("#BDB76B"));
    _htmlColors.put("darkmagenta", parseColor("#8B008B"));
    _htmlColors.put("darkolivegreen", parseColor("#556B2F"));
    _htmlColors.put("darkorange", parseColor("#FF8C00"));
    _htmlColors.put("darkorchid", parseColor("#9932CC"));
    _htmlColors.put("darkred", parseColor("#8B0000"));
    _htmlColors.put("darksalmon", parseColor("#E9967A"));
    _htmlColors.put("darkseagreen", parseColor("#8FBC8F"));
    _htmlColors.put("darkslateblue", parseColor("#483D8B"));
    _htmlColors.put("darkslategray", parseColor("#2F4F4F"));
    _htmlColors.put("darkslategrey", parseColor("#2F4F4F"));
    _htmlColors.put("darkturquoise", parseColor("#00CED1"));
    _htmlColors.put("darkviolet", parseColor("#9400D3"));
    _htmlColors.put("deeppink", parseColor("#FF1493"));
    _htmlColors.put("deepskyblue", parseColor("#00BFFF"));
    _htmlColors.put("dimgray", parseColor("#696969"));
    _htmlColors.put("dimgrey", parseColor("#696969"));
    _htmlColors.put("dodgerblue", parseColor("#1E90FF"));
    _htmlColors.put("firebrick", parseColor("#B22222"));
    _htmlColors.put("floralwhite", parseColor("#FFFAF0"));
    _htmlColors.put("forestgreen", parseColor("#228B22"));
    _htmlColors.put("fuchsia", parseColor("#FF00FF"));
    _htmlColors.put("gainsboro", parseColor("#DCDCDC"));
    _htmlColors.put("ghostwhite", parseColor("#F8F8FF"));
    _htmlColors.put("gold", parseColor("#FFD700"));
    _htmlColors.put("goldenrod", parseColor("#DAA520"));
    _htmlColors.put("gray", parseColor("#808080"));
    _htmlColors.put("grey", parseColor("#808080"));
    _htmlColors.put("green", parseColor("#008000"));
    _htmlColors.put("greenyellow", parseColor("#ADFF2F"));
    _htmlColors.put("honeydew", parseColor("#F0FFF0"));
    _htmlColors.put("hotpink", parseColor("#FF69B4"));
    _htmlColors.put("indianred ", parseColor("#CD5C5C"));
    _htmlColors.put("indigo ", parseColor("#4B0082"));
    _htmlColors.put("ivory", parseColor("#FFFFF0"));
    _htmlColors.put("khaki", parseColor("#F0E68C"));
    _htmlColors.put("lavender", parseColor("#E6E6FA"));
    _htmlColors.put("lavenderblush", parseColor("#FFF0F5"));
    _htmlColors.put("lawngreen", parseColor("#7CFC00"));
    _htmlColors.put("lemonchiffon", parseColor("#FFFACD"));
    _htmlColors.put("lightblue", parseColor("#ADD8E6"));
    _htmlColors.put("lightcoral", parseColor("#F08080"));
    _htmlColors.put("lightcyan", parseColor("#E0FFFF"));
    _htmlColors.put("lightgoldenrodyellow", parseColor("#FAFAD2"));
    _htmlColors.put("lightgray", parseColor("#D3D3D3"));
    _htmlColors.put("lightgrey", parseColor("#D3D3D3"));
    _htmlColors.put("lightgreen", parseColor("#90EE90"));
    _htmlColors.put("lightpink", parseColor("#FFB6C1"));
    _htmlColors.put("lightsalmon", parseColor("#FFA07A"));
    _htmlColors.put("lightseagreen", parseColor("#20B2AA"));
    _htmlColors.put("lightskyblue", parseColor("#87CEFA"));
    _htmlColors.put("lightslategray", parseColor("#778899"));
    _htmlColors.put("lightslategrey", parseColor("#778899"));
    _htmlColors.put("lightsteelblue", parseColor("#B0C4DE"));
    _htmlColors.put("lightyellow", parseColor("#FFFFE0"));
    _htmlColors.put("lime", parseColor("#00FF00"));
    _htmlColors.put("limegreen", parseColor("#32CD32"));
    _htmlColors.put("linen", parseColor("#FAF0E6"));
    _htmlColors.put("magenta", parseColor("#FF00FF"));
    _htmlColors.put("maroon", parseColor("#800000"));
    _htmlColors.put("mediumaquamarine", parseColor("#66CDAA"));
    _htmlColors.put("mediumblue", parseColor("#0000CD"));
    _htmlColors.put("mediumorchid", parseColor("#BA55D3"));
    _htmlColors.put("mediumpurple", parseColor("#9370DB"));
    _htmlColors.put("mediumseagreen", parseColor("#3CB371"));
    _htmlColors.put("mediumslateblue", parseColor("#7B68EE"));
    _htmlColors.put("mediumspringgreen", parseColor("#00FA9A"));
    _htmlColors.put("mediumturquoise", parseColor("#48D1CC"));
    _htmlColors.put("mediumvioletred", parseColor("#C71585"));
    _htmlColors.put("midnightblue", parseColor("#191970"));
    _htmlColors.put("mintcream", parseColor("#F5FFFA"));
    _htmlColors.put("mistyrose", parseColor("#FFE4E1"));
    _htmlColors.put("moccasin", parseColor("#FFE4B5"));
    _htmlColors.put("navajowhite", parseColor("#FFDEAD"));
    _htmlColors.put("navy", parseColor("#000080"));
    _htmlColors.put("oldlace", parseColor("#FDF5E6"));
    _htmlColors.put("olive", parseColor("#808000"));
    _htmlColors.put("olivedrab", parseColor("#6B8E23"));
    _htmlColors.put("orange", parseColor("#FFA500"));
    _htmlColors.put("orangered", parseColor("#FF4500"));
    _htmlColors.put("orchid", parseColor("#DA70D6"));
    _htmlColors.put("palegoldenrod", parseColor("#EEE8AA"));
    _htmlColors.put("palegreen", parseColor("#98FB98"));
    _htmlColors.put("paleturquoise", parseColor("#AFEEEE"));
    _htmlColors.put("palevioletred", parseColor("#DB7093"));
    _htmlColors.put("papayawhip", parseColor("#FFEFD5"));
    _htmlColors.put("peachpuff", parseColor("#FFDAB9"));
    _htmlColors.put("peru", parseColor("#CD853F"));
    _htmlColors.put("pink", parseColor("#FFC0CB"));
    _htmlColors.put("plum", parseColor("#DDA0DD"));
    _htmlColors.put("powderblue", parseColor("#B0E0E6"));
    _htmlColors.put("purple", parseColor("#800080"));
    _htmlColors.put("red", parseColor("#FF0000"));
    _htmlColors.put("rosybrown", parseColor("#BC8F8F"));
    _htmlColors.put("royalblue", parseColor("#4169E1"));
    _htmlColors.put("saddlebrown", parseColor("#8B4513"));
    _htmlColors.put("salmon", parseColor("#FA8072"));
    _htmlColors.put("sandybrown", parseColor("#F4A460"));
    _htmlColors.put("seagreen", parseColor("#2E8B57"));
    _htmlColors.put("seashell", parseColor("#FFF5EE"));
    _htmlColors.put("sienna", parseColor("#A0522D"));
    _htmlColors.put("silver", parseColor("#C0C0C0"));
    _htmlColors.put("skyblue", parseColor("#87CEEB"));
    _htmlColors.put("slateblue", parseColor("#6A5ACD"));
    _htmlColors.put("slategray", parseColor("#708090"));
    _htmlColors.put("slategrey", parseColor("#708090"));
    _htmlColors.put("snow", parseColor("#FFFAFA"));
    _htmlColors.put("springgreen", parseColor("#00FF7F"));
    _htmlColors.put("steelblue", parseColor("#4682B4"));
    _htmlColors.put("tan", parseColor("#D2B48C"));
    _htmlColors.put("teal", parseColor("#008080"));
    _htmlColors.put("thistle", parseColor("#D8BFD8"));
    _htmlColors.put("tomato", parseColor("#FF6347"));
    _htmlColors.put("turquoise", parseColor("#40E0D0"));
    _htmlColors.put("violet", parseColor("#EE82EE"));
    _htmlColors.put("wheat", parseColor("#F5DEB3"));
    _htmlColors.put("white", parseColor("#FFFFFF"));
    _htmlColors.put("whitesmoke", parseColor("#F5F5F5"));
    _htmlColors.put("yellow", parseColor("#FFFF00"));
    _htmlColors.put("yellowgreen", parseColor("#9ACD32"));
  }

}
