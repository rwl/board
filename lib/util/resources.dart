/**
 * Copyright (c) 2010, Gaudenz Alder
 */
part of graph.util;

//import java.util.Iterator;
//import java.util.LinkedList;
//import java.util.Locale;
//import java.util.MissingResourceException;
//import java.util.PropertyResourceBundle;
//import java.util.ResourceBundle;

class Resources {

  /**
	 * Ordered list of the inserted resource bundles.
	 */
  static LinkedList<ResourceBundle> _bundles = new LinkedList<ResourceBundle>();

  /**
	 * Returns the bundles.
	 * 
	 * @return Returns the bundles.
	 */
  static LinkedList<ResourceBundle> getBundles() {
    return _bundles;
  }

  /**
	 * Sets the bundles.
	 * 
	 * @param value
	 *            The bundles to set.
	 */
  static void setBundles(LinkedList<ResourceBundle> value) {
    _bundles = value;
  }

  /**
	 * Adds a resource bundle. This may throw a MissingResourceException that
	 * should be handled in the calling code.
	 * 
	 * @param basename
	 *            The basename of the resource bundle to add.
	 */
  static void add(String basename) {
    _bundles.addFirst(PropertyResourceBundle.getBundle(basename));
  }

  /**
	 * Adds a resource bundle. This may throw a MissingResourceException that
	 * should be handled in the calling code.
	 * 
	 * @param basename
	 *            The basename of the resource bundle to add.
	 */
  //	static void add(String basename, Locale locale)
  //	{
  //		_bundles.addFirst(PropertyResourceBundle.getBundle(basename, locale));
  //	}

  /**
	 * 
	 */
  //	static String get(String key)
  //	{
  //		return get(key, null, null);
  //	}

  /**
	 * 
	 */
  //	static String get(String key, [String defaultValue=null])
  //	{
  //		return get(key, null, defaultValue);
  //	}

  /**
	 * Returns the value for the specified resource key.
	 */
  //	static String get(String key, List<String> params)
  //	{
  //		return get(key, params, null);
  //	}

  /**
	 * Returns the value for the specified resource key.
	 */
  static String get(String key, [List<String> params = null, String defaultValue = null]) {
    String value = _getResource(key);

    // Applies default value if required
    if (value == null) {
      value = defaultValue;
    }

    // Replaces the placeholders with the values in the array
    if (value != null && params != null) {
      StringBuffer result = new StringBuffer();
      String index = null;

      for (int i = 0; i < value.length; i++) {
        char c = value.charAt(i);

        if (c == '{') {
          index = "";
        } else if (index != null && c == '}') {
          int tmp = int.parseInt(index) - 1;

          if (tmp >= 0 && tmp < params.length) {
            result.append(params[tmp]);
          }

          index = null;
        } else if (index != null) {
          index += c;
        } else {
          result.append(c);
        }
      }

      value = result.toString();
    }

    return value;
  }

  /**
	 * Returns the value for <code>key</code> by searching the resource
	 * bundles in inverse order or <code>null</code> if no value can be found
	 * for <code>key</code>.
	 */
  static String _getResource(String key) {
    Iterator<ResourceBundle> it = _bundles.iterator();

    while (it.moveNext()) {
      try {
        return it.next().getString(key);
      } on MissingResourceException catch (mrex) {
        // continue
      }
    }

    return null;
  }

}
