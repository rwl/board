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
  static String getHexColorString(awt.Color color) {
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
  static awt.Color parseColor(String str) //throws NumberFormatException
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
      str = "#${str[1]}${str[1]}${str[2]}${str[2]}${str[3]}${str[3]}";
    }

    int value = 0;
    try {
      String tmp = str;

      if (tmp.startsWith("#")) {
        tmp = tmp.substring(1);
      }

      value = /*Long*/int.parse(tmp, radix:16);
    } on FormatException catch (nfe) {
      try {
        value = /*Long*/int.parse(str);
      } on FormatException catch (e) {
        // ignores exception and returns black
      }
    }

    return new awt.Color.rgb(value);
  }

  static awt.Color _parseRgb(String rgbString) {
    List<String> values = rgbString.split("[,()]");

    String red = values[1].trim();
    String green = values[2].trim();
    String blue = values[3].trim();
    String alpha = "1.0";

    if (values.length >= 5) {
      alpha = values[4].trim();
    }

    return new awt.Color.double(_parseValue(red, 255), _parseValue(green, 255), _parseValue(blue, 255), _parseAlpha(alpha));
  }

  static double _parseValue(String val, int max) {
    if (val.endsWith("%")) {
      return (_parsePercent(val) * max / max);
    }

    return (int.parse(val) / max);
  }

  static double _parsePercent(String perc) {
    return int.parse(perc.substring(0, perc.length - 1)) / 100.0;
  }

  static double _parseAlpha(String alpha) {
    return double.parse(alpha);
  }

  /**
	 * Initializes HTML color table.
	 */
  init() {
    _htmlColors["aliceblue"] = parseColor("#F0F8FF");
    _htmlColors["antiquewhite"] = parseColor("#FAEBD7");
    _htmlColors["aqua"] = parseColor("#00FFFF");
    _htmlColors["aquamarine"] = parseColor("#7FFFD4");
    _htmlColors["azure"] = parseColor("#F0FFFF");
    _htmlColors["beige"] = parseColor("#F5F5DC");
    _htmlColors["bisque"] = parseColor("#FFE4C4");
    _htmlColors["black"] = parseColor("#000000");
    _htmlColors["blanchedalmond"] = parseColor("#FFEBCD");
    _htmlColors["blue"] = parseColor("#0000FF");
    _htmlColors["blueviolet"] = parseColor("#8A2BE2");
    _htmlColors["brown"] = parseColor("#A52A2A");
    _htmlColors["burlywood"] = parseColor("#DEB887");
    _htmlColors["cadetblue"] = parseColor("#5F9EA0");
    _htmlColors["chartreuse"] = parseColor("#7FFF00");
    _htmlColors["chocolate"] = parseColor("#D2691E");
    _htmlColors["coral"] = parseColor("#FF7F50");
    _htmlColors["cornflowerblue"] = parseColor("#6495ED");
    _htmlColors["cornsilk"] = parseColor("#FFF8DC");
    _htmlColors["crimson"] = parseColor("#DC143C");
    _htmlColors["cyan"] = parseColor("#00FFFF");
    _htmlColors["darkblue"] = parseColor("#00008B");
    _htmlColors["darkcyan"] = parseColor("#008B8B");
    _htmlColors["darkgoldenrod"] = parseColor("#B8860B");
    _htmlColors["darkgray"] = parseColor("#A9A9A9");
    _htmlColors["darkgrey"] = parseColor("#A9A9A9");
    _htmlColors["darkgreen"] = parseColor("#006400");
    _htmlColors["darkkhaki"] = parseColor("#BDB76B");
    _htmlColors["darkmagenta"] = parseColor("#8B008B");
    _htmlColors["darkolivegreen"] = parseColor("#556B2F");
    _htmlColors["darkorange"] = parseColor("#FF8C00");
    _htmlColors["darkorchid"] = parseColor("#9932CC");
    _htmlColors["darkred"] = parseColor("#8B0000");
    _htmlColors["darksalmon"] = parseColor("#E9967A");
    _htmlColors["darkseagreen"] = parseColor("#8FBC8F");
    _htmlColors["darkslateblue"] = parseColor("#483D8B");
    _htmlColors["darkslategray"] = parseColor("#2F4F4F");
    _htmlColors["darkslategrey"] = parseColor("#2F4F4F");
    _htmlColors["darkturquoise"] = parseColor("#00CED1");
    _htmlColors["darkviolet"] = parseColor("#9400D3");
    _htmlColors["deeppink"] = parseColor("#FF1493");
    _htmlColors["deepskyblue"] = parseColor("#00BFFF");
    _htmlColors["dimgray"] = parseColor("#696969");
    _htmlColors["dimgrey"] = parseColor("#696969");
    _htmlColors["dodgerblue"] = parseColor("#1E90FF");
    _htmlColors["firebrick"] = parseColor("#B22222");
    _htmlColors["floralwhite"] = parseColor("#FFFAF0");
    _htmlColors["forestgreen"] = parseColor("#228B22");
    _htmlColors["fuchsia"] = parseColor("#FF00FF");
    _htmlColors["gainsboro"] = parseColor("#DCDCDC");
    _htmlColors["ghostwhite"] = parseColor("#F8F8FF");
    _htmlColors["gold"] = parseColor("#FFD700");
    _htmlColors["goldenrod"] = parseColor("#DAA520");
    _htmlColors["gray"] = parseColor("#808080");
    _htmlColors["grey"] = parseColor("#808080");
    _htmlColors["green"] = parseColor("#008000");
    _htmlColors["greenyellow"] = parseColor("#ADFF2F");
    _htmlColors["honeydew"] = parseColor("#F0FFF0");
    _htmlColors["hotpink"] = parseColor("#FF69B4");
    _htmlColors["indianred "] = parseColor("#CD5C5C");
    _htmlColors["indigo "] = parseColor("#4B0082");
    _htmlColors["ivory"] = parseColor("#FFFFF0");
    _htmlColors["khaki"] = parseColor("#F0E68C");
    _htmlColors["lavender"] = parseColor("#E6E6FA");
    _htmlColors["lavenderblush"] = parseColor("#FFF0F5");
    _htmlColors["lawngreen"] = parseColor("#7CFC00");
    _htmlColors["lemonchiffon"] = parseColor("#FFFACD");
    _htmlColors["lightblue"] = parseColor("#ADD8E6");
    _htmlColors["lightcoral"] = parseColor("#F08080");
    _htmlColors["lightcyan"] = parseColor("#E0FFFF");
    _htmlColors["lightgoldenrodyellow"] = parseColor("#FAFAD2");
    _htmlColors["lightgray"] = parseColor("#D3D3D3");
    _htmlColors["lightgrey"] = parseColor("#D3D3D3");
    _htmlColors["lightgreen"] = parseColor("#90EE90");
    _htmlColors["lightpink"] = parseColor("#FFB6C1");
    _htmlColors["lightsalmon"] = parseColor("#FFA07A");
    _htmlColors["lightseagreen"] = parseColor("#20B2AA");
    _htmlColors["lightskyblue"] = parseColor("#87CEFA");
    _htmlColors["lightslategray"] = parseColor("#778899");
    _htmlColors["lightslategrey"] = parseColor("#778899");
    _htmlColors["lightsteelblue"] = parseColor("#B0C4DE");
    _htmlColors["lightyellow"] = parseColor("#FFFFE0");
    _htmlColors["lime"] = parseColor("#00FF00");
    _htmlColors["limegreen"] = parseColor("#32CD32");
    _htmlColors["linen"] = parseColor("#FAF0E6");
    _htmlColors["magenta"] = parseColor("#FF00FF");
    _htmlColors["maroon"] = parseColor("#800000");
    _htmlColors["mediumaquamarine"] = parseColor("#66CDAA");
    _htmlColors["mediumblue"] = parseColor("#0000CD");
    _htmlColors["mediumorchid"] = parseColor("#BA55D3");
    _htmlColors["mediumpurple"] = parseColor("#9370DB");
    _htmlColors["mediumseagreen"] = parseColor("#3CB371");
    _htmlColors["mediumslateblue"] = parseColor("#7B68EE");
    _htmlColors["mediumspringgreen"] = parseColor("#00FA9A");
    _htmlColors["mediumturquoise"] = parseColor("#48D1CC");
    _htmlColors["mediumvioletred"] = parseColor("#C71585");
    _htmlColors["midnightblue"] = parseColor("#191970");
    _htmlColors["mintcream"] = parseColor("#F5FFFA");
    _htmlColors["mistyrose"] = parseColor("#FFE4E1");
    _htmlColors["moccasin"] = parseColor("#FFE4B5");
    _htmlColors["navajowhite"] = parseColor("#FFDEAD");
    _htmlColors["navy"] = parseColor("#000080");
    _htmlColors["oldlace"] = parseColor("#FDF5E6");
    _htmlColors["olive"] = parseColor("#808000");
    _htmlColors["olivedrab"] = parseColor("#6B8E23");
    _htmlColors["orange"] = parseColor("#FFA500");
    _htmlColors["orangered"] = parseColor("#FF4500");
    _htmlColors["orchid"] = parseColor("#DA70D6");
    _htmlColors["palegoldenrod"] = parseColor("#EEE8AA");
    _htmlColors["palegreen"] = parseColor("#98FB98");
    _htmlColors["paleturquoise"] = parseColor("#AFEEEE");
    _htmlColors["palevioletred"] = parseColor("#DB7093");
    _htmlColors["papayawhip"] = parseColor("#FFEFD5");
    _htmlColors["peachpuff"] = parseColor("#FFDAB9");
    _htmlColors["peru"] = parseColor("#CD853F");
    _htmlColors["pink"] = parseColor("#FFC0CB");
    _htmlColors["plum"] = parseColor("#DDA0DD");
    _htmlColors["powderblue"] = parseColor("#B0E0E6");
    _htmlColors["purple"] = parseColor("#800080");
    _htmlColors["red"] = parseColor("#FF0000");
    _htmlColors["rosybrown"] = parseColor("#BC8F8F");
    _htmlColors["royalblue"] = parseColor("#4169E1");
    _htmlColors["saddlebrown"] = parseColor("#8B4513");
    _htmlColors["salmon"] = parseColor("#FA8072");
    _htmlColors["sandybrown"] = parseColor("#F4A460");
    _htmlColors["seagreen"] = parseColor("#2E8B57");
    _htmlColors["seashell"] = parseColor("#FFF5EE");
    _htmlColors["sienna"] = parseColor("#A0522D");
    _htmlColors["silver"] = parseColor("#C0C0C0");
    _htmlColors["skyblue"] = parseColor("#87CEEB");
    _htmlColors["slateblue"] = parseColor("#6A5ACD");
    _htmlColors["slategray"] = parseColor("#708090");
    _htmlColors["slategrey"] = parseColor("#708090");
    _htmlColors["snow"] = parseColor("#FFFAFA");
    _htmlColors["springgreen"] = parseColor("#00FF7F");
    _htmlColors["steelblue"] = parseColor("#4682B4");
    _htmlColors["tan"] = parseColor("#D2B48C");
    _htmlColors["teal"] = parseColor("#008080");
    _htmlColors["thistle"] = parseColor("#D8BFD8");
    _htmlColors["tomato"] = parseColor("#FF6347");
    _htmlColors["turquoise"] = parseColor("#40E0D0");
    _htmlColors["violet"] = parseColor("#EE82EE");
    _htmlColors["wheat"] = parseColor("#F5DEB3");
    _htmlColors["white"] = parseColor("#FFFFFF");
    _htmlColors["whitesmoke"] = parseColor("#F5F5F5");
    _htmlColors["yellow"] = parseColor("#FFFF00");
    _htmlColors["yellowgreen"] = parseColor("#9ACD32");
  }

}
