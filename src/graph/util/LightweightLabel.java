/**
 * $Id: LightweightLabel.java,v 1.1 2012/11/15 13:26:39 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.util;

import java.awt.Font;
import java.awt.Rectangle;

import javax.swing.JLabel;
import javax.swing.SwingConstants;

/**
 * @author Administrator
 * 
 */
public class LightweightLabel extends JLabel
{

	/**
	 * 
	 */
	private static final long serialVersionUID = -6771477489533614010L;

	/**
	 * 
	 */
	protected static LightweightLabel _sharedInstance;

	/**
	 * Initializes the shared instance.
	 */
	static
	{
		try
		{
			_sharedInstance = new LightweightLabel();
		}
		catch (Exception e)
		{
			// ignore
		}
	}

	/**
	 * 
	 */
	public static LightweightLabel getSharedInstance()
	{
		return _sharedInstance;
	}

	/**
	 * 
	 * 
	 */
	public LightweightLabel()
	{
		setFont(new Font(Constants.DEFAULT_FONTFAMILY, 0,
				Constants.DEFAULT_FONTSIZE));
		setVerticalAlignment(SwingConstants.TOP);
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void validate()
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void revalidate()
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void repaint(long tm, int x, int y, int width, int height)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void repaint(Rectangle r)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	protected void firePropertyChange(String propertyName, Object oldValue,
			Object newValue)
	{
		// Strings get interned...
		if (propertyName == "text" || propertyName == "font")
		{
			super.firePropertyChange(propertyName, oldValue, newValue);
		}
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, byte oldValue,
			byte newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, char oldValue,
			char newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, short oldValue,
			short newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, int oldValue,
			int newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, long oldValue,
			long newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, float oldValue,
			float newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, double oldValue,
			double newValue)
	{
	}

	/**
	 * Overridden for performance reasons.
	 * 
	 */
	public void firePropertyChange(String propertyName, boolean oldValue,
			boolean newValue)
	{
	}

}
