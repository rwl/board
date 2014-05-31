/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.util;

//import java.awt.Font;
//import java.awt.harmony.Rectangle;

//import javax.swing.JLabel;
//import javax.swing.SwingConstants;

/**
 * @author Administrator
 * 
 */
class LightweightLabel //extends JLabel
{

  /**
	 * 
	 */
  //	private static final long serialVersionUID = -6771477489533614010L;

  /**
	 * 
	 */
  static LightweightLabel _sharedInstance;

  /**
	 * Initializes the shared instance.
	 */
  /*static
	{
		try
		{
			_sharedInstance = new LightweightLabel();
		}
		on Exception catch (e)
		{
			// ignore
		}
	}*/

  /**
	 * 
	 */
  /*static LightweightLabel getSharedInstance()
	{
		return _sharedInstance;
	}*/

  /**
	 * 
	 * 
	 */
  LightweightLabel() {
    setFont(new Font(Constants.DEFAULT_FONTFAMILY, 0, Constants.DEFAULT_FONTSIZE));
    setVerticalAlignment(SwingConstants.TOP);
  }

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  void validate() {
  }

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  void revalidate() {
  }

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  //	void repaint(long tm, int x, int y, int width, int height)
  //	{
  //	}

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  //	void repaint(harmony.Rectangle r)
  //	{
  //	}

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  void firePropertyChange(String propertyName, Object oldValue, Object newValue) {
    // Strings get interned...
    if (propertyName == "text" || propertyName == "font") {
      super.firePropertyChange(propertyName, oldValue, newValue);
    }
  }

  /**
	 * Overridden for performance reasons.
	 * 
	 */
  //	void firePropertyChange(String propertyName, byte oldValue,
  //			byte newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, char oldValue,
  //			char newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, short oldValue,
  //			short newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, int oldValue,
  //			int newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, long oldValue,
  //			long newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, float oldValue,
  //			float newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, double oldValue,
  //			double newValue)
  //	{
  //	}
  //
  //	/**
  //	 * Overridden for performance reasons.
  //	 *
  //	 */
  //	void firePropertyChange(String propertyName, bool oldValue,
  //			bool newValue)
  //	{
  //	}

}
