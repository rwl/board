package graph.canvas;

//import graph.util.Constants;

//import java.awt.Color;
//import java.awt.Graphics2D;
//import java.awt.Paint;

/**
 * 
 */
class _CanvasState implements Cloneable
{
	/**
	 * 
	 */
	protected double alpha = 1;

	/**
	 * 
	 */
	protected double scale = 1;

	/**
	 * 
	 */
	protected double dx = 0;

	/**
	 * 
	 */
	protected double dy = 0;

	/**
	 * 
	 */
	protected double theta = 0;

	/**
	 * 
	 */
	protected double rotationCx = 0;

	/**
	 * 
	 */
	protected double rotationCy = 0;

	/**
	 * 
	 */
	protected boolean flipV = false;

	/**
	 * 
	 */
	protected boolean flipH = false;

	/**
	 * 
	 */
	protected double miterLimit = 10;

	/**
	 * 
	 */
	protected int fontStyle = 0;

	/**
	 * 
	 */
	protected double fontSize = Constants.DEFAULT_FONTSIZE;

	/**
	 * 
	 */
	protected String fontFamily = Constants.DEFAULT_FONTFAMILIES;

	/**
	 * 
	 */
	protected String fontColorValue = "#000000";

	/**
	 * 
	 */
	protected Color fontColor;

	/**
	 * 
	 */
	protected String fontBackgroundColorValue;

	/**
	 * 
	 */
	protected Color fontBackgroundColor;

	/**
	 * 
	 */
	protected String fontBorderColorValue;

	/**
	 * 
	 */
	protected Color fontBorderColor;

	/**
	 * 
	 */
	protected String lineCap = "flat";

	/**
	 * 
	 */
	protected String lineJoin = "miter";

	/**
	 * 
	 */
	protected double strokeWidth = 1;

	/**
	 * 
	 */
	protected String strokeColorValue;

	/**
	 * 
	 */
	protected Color strokeColor;

	/**
	 * 
	 */
	protected String fillColorValue;

	/**
	 * 
	 */
	protected Color fillColor;

	/**
	 * 
	 */
	protected Paint gradientPaint;

	/**
	 * 
	 */
	protected boolean dashed = false;

	/**
	 * 
	 */
	protected float[] dashPattern = { 3, 3 };

	/**
	 * 
	 */
	protected boolean shadow = false;

	/**
	 * 
	 */
	protected String shadowColorValue = Constants.W3C_SHADOWCOLOR;

	/**
	 * 
	 */
	protected Color shadowColor;

	/**
	 * 
	 */
	protected double shadowAlpha = 1;

	/**
	 * 
	 */
	protected double shadowOffsetX = Constants.SHADOW_OFFSETX;

	/**
	 * 
	 */
	protected double shadowOffsetY = Constants.SHADOW_OFFSETY;

	/**
	 * Stores the actual state.
	 */
	protected transient Graphics2D g;

	/**
	 * 
	 */
	public Object clone() throws CloneNotSupportedException
	{
		return super.clone();
	}

}