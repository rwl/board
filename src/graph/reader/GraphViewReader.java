/**
 * $Id: GraphViewReader.java,v 1.1 2012/11/15 13:26:45 gaudenz Exp $
 * Copyright (c) 2007, Gaudenz Alder
 */
package graph.reader;

import graph.canvas.ICanvas;
import graph.util.Point2d;
import graph.util.Rect;
import graph.util.Utils;
import graph.view.CellState;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * An abstract converter that renders display XML data onto a canvas.
 */
public abstract class GraphViewReader extends DefaultHandler
{

	/**
	 * Holds the canvas to be used for rendering the graph.
	 */
	protected ICanvas canvas;

	/**
	 * Holds the global scale of the graph. This is set just before
	 * createCanvas is called.
	 */
	protected double scale = 1;

	/**
	 * Specifies if labels should be rendered as HTML markup.
	 */
	protected boolean htmlLabels = false;

	/**
	 * Sets the htmlLabels switch.
	 */
	public void setHtmlLabels(boolean value)
	{
		htmlLabels = value;
	}

	/**
	 * Returns the htmlLabels switch.
	 */
	public boolean isHtmlLabels()
	{
		return htmlLabels;
	}

	/**
	 * Returns the canvas to be used for rendering.
	 * 
	 * @param attrs Specifies the attributes of the new canvas.
	 * @return Returns a new canvas.
	 */
	public abstract ICanvas createCanvas(Map<String, Object> attrs);

	/**
	 * Returns the canvas that is used for rendering the graph.
	 * 
	 * @return Returns the canvas.
	 */
	public ICanvas getCanvas()
	{
		return canvas;
	}

	/* (non-Javadoc)
	 * @see org.xml.sax.helpers.DefaultHandler#startElement(java.lang.String, java.lang.String, java.lang.String, org.xml.sax.Attributes)
	 */
	public void startElement(String uri, String localName, String qName,
			Attributes atts) throws SAXException
	{
		String tagName = qName.toUpperCase();
		Map<String, Object> attrs = new Hashtable<String, Object>();

		for (int i = 0; i < atts.getLength(); i++)
		{
			String name = atts.getQName(i);

			// Workaround for possible null name
			if (name == null || name.length() == 0)
			{
				name = atts.getLocalName(i);
			}

			attrs.put(name, atts.getValue(i));
		}

		parseElement(tagName, attrs);
	}

	/**
	 * Parses the given element and paints it onto the canvas.
	 * 
	 * @param tagName Name of the node to be parsed.
	 * @param attrs Attributes of the node to be parsed.
	 */
	public void parseElement(String tagName, Map<String, Object> attrs)
	{
		if (canvas == null && tagName.equalsIgnoreCase("graph"))
		{
			scale = Utils.getDouble(attrs, "scale", 1);
			canvas = createCanvas(attrs);

			if (canvas != null)
			{
				canvas.setScale(scale);
			}
		}
		else if (canvas != null)
		{
			boolean edge = tagName.equalsIgnoreCase("edge");
			boolean group = tagName.equalsIgnoreCase("group");
			boolean vertex = tagName.equalsIgnoreCase("vertex");

			if ((edge && attrs.containsKey("points"))
					|| ((vertex || group) && attrs.containsKey("x")
							&& attrs.containsKey("y")
							&& attrs.containsKey("width") && attrs
							.containsKey("height")))
			{
				CellState state = new CellState(null, null, attrs);

				String label = parseState(state, edge);
				canvas.drawCell(state);
				canvas.drawLabel(label, state, isHtmlLabels());
			}
		}
	}

	/**
	 * Parses the bounds, absolute points and label information from the style
	 * of the state into its respective fields and returns the label of the
	 * cell.
	 */
	public String parseState(CellState state, boolean edge)
	{
		Map<String, Object> style = state.getStyle();

		// Parses the bounds
		state.setX(Utils.getDouble(style, "x"));
		state.setY(Utils.getDouble(style, "y"));
		state.setWidth(Utils.getDouble(style, "width"));
		state.setHeight(Utils.getDouble(style, "height"));

		// Parses the absolute points list
		List<Point2d> pts = parsePoints(Utils.getString(style, "points"));

		if (pts.size() > 0)
		{
			state.setAbsolutePoints(pts);
		}

		// Parses the label and label bounds
		String label = Utils.getString(style, "label");

		if (label != null && label.length() > 0)
		{
			Point2d offset = new Point2d(Utils.getDouble(style, "dx"),
					Utils.getDouble(style, "dy"));
			Rect vertexBounds = (!edge) ? state : null;
			state.setLabelBounds(Utils.getLabelPaintBounds(label, state
					.getStyle(), Utils.isTrue(style, "html", false), offset,
					vertexBounds, scale));
		}

		return label;
	}

	/**
	 * Parses the list of points into an object-oriented representation.
	 * 
	 * @param pts String containing a list of points.
	 * @return Returns the points as a list of mxPoints.
	 */
	public static List<Point2d> parsePoints(String pts)
	{
		List<Point2d> result = new ArrayList<Point2d>();

		if (pts != null)
		{
			int len = pts.length();
			String tmp = "";
			String x = null;

			for (int i = 0; i < len; i++)
			{
				char c = pts.charAt(i);

				if (c == ',' || c == ' ')
				{
					if (x == null)
					{
						x = tmp;
					}
					else
					{
						result.add(new Point2d(Double.parseDouble(x), Double
								.parseDouble(tmp)));
						x = null;
					}
					tmp = "";
				}
				else
				{
					tmp += c;
				}
			}

			result.add(new Point2d(Double.parseDouble(x), Double
					.parseDouble(tmp)));
		}

		return result;
	}

}
