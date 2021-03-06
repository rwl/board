/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.io;


/**
 * Singleton class that acts as a global registry for codecs. See
 * {@link Codec} for an example.
 */
class CodecRegistry {

  /**
   * Maps from constructor names to codecs.
   */
  static Map<String, ObjectCodec> _codecs = new Map<String, ObjectCodec>();

  /**
   * Maps from classnames to codecnames.
   */
  static Map<String, String> _aliases = new Map<String, String>();

  /**
   * Holds the list of known packages. Packages are used to prefix short
   * class names (eg. Cell) in XML markup.
   */
  static List<String> _packages = new List<String>();

  // Registers the known codecs and package names
  static init() {
    addPackage("graph");
    addPackage("graph.util");
    addPackage("graph.model");
    addPackage("graph.view");
    addPackage("java.lang");
    addPackage("java.util");

    register(new ObjectCodec(new List<Object>()));
    register(new ModelCodec());
    register(new CellCodec());
    register(new StylesheetCodec());

    register(new RootChangeCodec());
    register(new ChildChangeCodec());
    register(new TerminalChangeCodec());
    register(new GenericChangeCodec(new ValueChange(), "value"));
    register(new GenericChangeCodec(new StyleChange(), "style"));
    register(new GenericChangeCodec(new GeometryChange(), "geometry"));
    register(new GenericChangeCodec(new CollapseChange(), "collapsed"));
    register(new GenericChangeCodec(new VisibleChange(), "visible"));
  }

  /**
   * Registers a new codec and associates the name of the template constructor
   * in the codec with the codec object. Automatically creates an alias if the
   * codename and the classname are not equal.
   */
  static ObjectCodec register(ObjectCodec codec) {
    if (codec != null) {
      String name = codec.getName();
      _codecs[name] = codec;

      String classname = getName(codec.getTemplate());

      if (classname != name) {
        addAlias(classname, name);
      }
    }

    return codec;
  }

  /**
   * Adds an alias for mapping a classname to a codecname.
   */
  static void addAlias(String classname, String codecname) {
    _aliases[classname] = codecname;
  }

  /**
   * Returns a codec that handles the given object, which can be an object
   * instance or an XML node.
   * 
   * @param name Java class name.
   */
  static ObjectCodec getCodec(String name) {
    String tmp = _aliases[name];

    if (tmp != null) {
      name = tmp;
    }

    ObjectCodec codec = _codecs[name];

    // Registers a new default codec for the given name
    // if no codec has been previously defined.
    if (codec == null) {
      Object instance = getInstanceForName(name);

      if (instance != null) {
        try {
          codec = new ObjectCodec(instance);
          register(codec);
        } on Exception catch (e) {
          // ignore
        }
      }
    }

    return codec;
  }

  /**
   * Adds the given package name to the list of known package names.
   * 
   * @param packagename Name of the package to be added.
   */
  static void addPackage(String packagename) {
    _packages.add(packagename);
  }

  /**
   * Creates and returns a new instance for the given class name.
   * 
   * @param name Name of the class to be instantiated.
   * @return Returns a new instance of the given class.
   */
  /*static Object getInstanceForName(String name)
	{
		Class<?> clazz = getClassForName(name);

		if (clazz != null)
		{
			if (clazz.isEnum())
			{
				// For an enum, use the first constant as the default instance
				return clazz.getEnumConstants()[0];
			}
			else
			{
				try
				{
					return clazz.newInstance();
				}
				on Exception catch (e)
				{
					// ignore
				}
			}
		}

		return null;
	}*/

  /**
   * Returns a class that corresponds to the given name.
   * 
   * @param name
   * @return Returns the class for the given name.
   */
  static ClassMirror /*<?>*/ getClassForName(String name) {
    try {
      return Class.forName(name);
    } on Exception catch (e) {
      // ignore
    }

    for (int i = 0; i < _packages.length; i++) {
      try {
        String s = _packages[i];

        return Class.forName(s + "." + name);
      } on Exception catch (e) {
        // ignore
      }
    }

    return null;
  }

  /**
   * Returns the name that identifies the codec associated
   * with the given instance..
   *
   * The I/O system uses unqualified classnames, eg. for a
   * <code>graph.model.Cell</code> this returns
   * <code>Cell</code>.
   * 
   * @param instance Instance whose node name should be returned.
   * @return Returns a string that identifies the codec.
   */
  /*static String getName(Object instance)
	{
		Class<? extends Object> type = instance.getClass();

		if (type.isArray() || Collection.class.isAssignableFrom(type)
				|| Map.class.isAssignableFrom(type))
		{
			return "Array";
		}
		else
		{
			if (_packages.contains(type.getPackage().getName()))
			{
				return type.getSimpleName();
			}
			else
			{
				return type.getName();
			}
		}
	}*/

}
