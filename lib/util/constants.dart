/**
 * Copyright (c) 2007-2012, JGraph Ltd
 */
part of graph.util;

/**
 * Contains all global constants.
 */
class Constants {
  /**
   * Defines the number of radians per degree.
   */
  static const double RAD_PER_DEG = 0.0174532;

  /**
   * Defines the number of degrees per radian.
   */
  static const double DEG_PER_RAD = 57.2957795;

  /**
   * Defines the minimum scale at which rounded polylines should be painted.
   * Default is 0.05.
   */
  static const double MIN_SCALE_FOR_ROUNDED_LINES = 0.05;

  /**
   * Defines the portion of the cell which is to be used as a connectable
   * region. Default is 0.3.
   */
  static const double DEFAULT_HOTSPOT = 0.3;

  /**
   * Defines the minimum size in pixels of the portion of the cell which is
   * to be used as a connectable region. Default is 8.
   */
  static const int MIN_HOTSPOT_SIZE = 8;

  /**
   * Defines the maximum size in pixels of the portion of the cell which is
   * to be used as a connectable region. Use 0 for no maximum. Default is 0.
   */
  static const int MAX_HOTSPOT_SIZE = 0;

  /**
   * Defines the SVG namespace.
   */
  static const String NS_SVG = "http://www.w3.org/2000/svg";

  /**
   * Defines the XHTML namespace.
   */
  static const String NS_XHTML = "http://www.w3.org/1999/xhtml";

  /**
   * Defines the XLink namespace.
   */
  static const String NS_XLINK = "http://www.w3.org/1999/xlink";

  /**
   * Comma separated list of default fonts for CSS properties.
   * And the default font family value for new image export.
   * Default is Arial, Helvetica.
   */
  static const String DEFAULT_FONTFAMILIES = "Arial,Helvetica";

  /**
   * Defines the default font family. Default is "Dialog". (To be replaced
   * with Font.DIALOG after EOL of Java 1.5.)
   */
  static const String DEFAULT_FONTFAMILY = "Dialog";

  /**
   * Defines the default font size. Default is 11.
   */
  static const int DEFAULT_FONTSIZE = 11;

  /**
   * Defines the default start size for swimlanes. Default is 40.
   */
  static const int DEFAULT_STARTSIZE = 40;

  /**
   * Default line height for text output. Default is 1.2. This is ignored for HTML in
   * the current version of Java. See
   * http://docs.oracle.com/javase/6/docs/api/index.html?javax/swing/text/html/CSS.html
   */
  static const double LINE_HEIGHT = 1.2;

  /**
   * Specifies if absolute line heights should be used (px) in CSS. Default
   * is false. Set this to true for backwards compatibility.
   */
  static const bool ABSOLUTE_LINE_HEIGHT = false;

  /**
   * Specifies the line spacing. Default is 0.
   */
  static const int LINESPACING = 0;

  /**
   * Whether or not to split whole words when applying word wrapping in Utils.wordWrap.
   */
  static const bool SPLIT_WORDS = true;

  /**
   * Defines the inset in absolute pixels between the label bounding box and
   * the label text. Default is 3.
   */
  static const int LABEL_INSET = 3;

  /**
   * Multiplier to the width that is passed into the word wrapping calculation
   * See Utils.wordWrap for details
   */
  static const double LABEL_SCALE_BUFFER = 0.9;

  /**
   * Defines the default marker size. Default is 6.
   */
  static const int DEFAULT_MARKERSIZE = 6;

  /**
   * Defines the default image size. Default is 24.
   */
  static const int DEFAULT_IMAGESIZE = 24;

  /**
   * Defines the default opacity for stencils shadows. Default is 1.
   */
  static const int STENCIL_SHADOW_OPACITY = 1;

  /**
   * Defines the default shadow color for stencils. Default is "gray".
   */
  static const String STENCIL_SHADOWCOLOR = "gray";

  /**
   * Defines the x-offset to be used for shadows. Default is 2.
   */
  static const int SHADOW_OFFSETX = 2;

  /**
   * Defines the y-offset to be used for shadows. Default is 3.
   */
  static const int SHADOW_OFFSETY = 3;

  /**
   * Defines the color to be used to draw shadows in W3C standards. Default
   * is gray.
   */
  static const String W3C_SHADOWCOLOR = "gray";

  /**
   * Defines the transformation used to draw shadows in SVG.
   */
  static const String SVG_SHADOWTRANSFORM = "translate(2 3)";

  /**
   * Specifies the default dash pattern, 3 pixels solid, 3 pixels clear.
   */
  static /*const*/final List<double> DEFAULT_DASHED_PATTERN = [3.0, 3.0];

  /**
   * Specifies the default distance at 1.0 scale that the label curve is
   * created from its base curve
   */
  static const double DEFAULT_LABEL_BUFFER = 12.0;

  /**
   * Defines the handle size. Default is 7.
   */
  static const int HANDLE_SIZE = 7;

  /**
   * Defines the handle size. Default is 4.
   */
  static const int LABEL_HANDLE_SIZE = 4;

  /**
   * Defines the default value for the connect handle. Default is false.
   */
  static const bool CONNECT_HANDLE_ENABLED = false;

  /**
   * Defines the connect handle size. Default is 8.
   */
  static const int CONNECT_HANDLE_SIZE = 8;

  /**
   * Defines the length of the horizontal segment of an Entity Relation.
   * This can be overridden using Constants.STYLE_SEGMENT style.
   * Default is 30.
   */
  static const int ENTITY_SEGMENT = 30;

  /**
   * Defines the rounding factor for rounded rectangles in percent between
   * 0 and 1. Values should be smaller than 0.5. Default is 0.15.
   */
  static const double RECTANGLE_ROUNDING_FACTOR = 0.15;

  /**
   * Defines the size of the arcs for rounded edges. Default is 10.
   */
  static const double LINE_ARCSIZE = 10.0;

  /**
   * Defines the spacing between the arrow shape and its terminals. Default
   * is 10.
   */
  static const int ARROW_SPACING = 10;

  /**
   * Defines the width of the arrow shape. Default is 30.
   */
  static const int ARROW_WIDTH = 30;

  /**
   * Defines the size of the arrowhead in the arrow shape. Default is 30.
   */
  static const int ARROW_SIZE = 30;

  /**
   * Defines the value for none. Default is "none".
   */
  static const String NONE = "none";

  /**
   * Defines the key for the perimeter style.
   * This is a function that defines the perimeter around a particular shape.
   * Possible values are the functions defined in Perimeter that use the
   * <code>PerimeterFunction</code> interface. Alternatively, the constants
   * in this class that start with <code>PERIMETER_</code> may be used to
   * access perimeter styles in <code>StyleRegistry</code>.
   */
  static const String STYLE_PERIMETER = "perimeter";

  /**
   * Defines the ID of the cell that should be used for computing the
   * perimeter point of the source for an edge. This allows for graphically
   * connecting to a cell while keeping the actual terminal of the edge.
   */
  static const String STYLE_SOURCE_PORT = "sourcePort";

  /**
   * Defines the ID of the cell that should be used for computing the
   * perimeter point of the target for an edge. This allows for graphically
   * connecting to a cell while keeping the actual terminal of the edge.
   */
  static const String STYLE_TARGET_PORT = "targetPort";

  /**
   * Defines the direction(s) that edges are allowed to connect to cells in.
   * Possible values are <code>DIRECTION_NORTH, DIRECTION_SOUTH,
   * DIRECTION_EAST</code> and <code>DIRECTION_WEST</code>.
   *
   */
  static const String STYLE_PORT_CONSTRAINT = "portConstraint";

  /**
   * Defines the key for the opacity style. The type of the value is
   * <code>float</code> and the possible range is 0-100.
   */
  static const String STYLE_OPACITY = "opacity";

  /**
   * Defines the key for the text opacity style. The type of the value is
   * <code>float</code> and the possible range is 0-100.
   */
  static const String STYLE_TEXT_OPACITY = "textOpacity";

  /**
   * Defines the key for the overflow style. Possible values are "visible",
   * "hidden" and "fill". The default value is "visible". This value
   * specifies how overlapping vertex labels are handles. A value of
   * "visible" will show the complete label. A value of "hidden" will clip
   * the label so that it does not overlap the vertex bounds. A value of
   * "fill" will use the vertex bounds for the label.
   *
   * @see graph.view.Graph#isLabelClipped(Object)
   */
  static const String STYLE_OVERFLOW = "overflow";

  /**
	* Defines if the connection points on either end of the edge should be
	* computed so that the edge is vertical or horizontal if possible and
	* if the point is not at a fixed location. Default is false. This is
	* used in Graph.isOrthogonal, which also returns true if the edgeStyle
	* of the edge is an elbow or entity.
	*/
  static const String STYLE_ORTHOGONAL = "orthogonal";

  /**
	* Defines the key for the horizontal relative coordinate connection point
	* of an edge with its source terminal.
	*/
  static const String STYLE_EXIT_X = "exitX";

  /**
	* Defines the key for the vertical relative coordinate connection point
	* of an edge with its source terminal.
	*/
  static const String STYLE_EXIT_Y = "exitY";

  /**
	* Defines if the perimeter should be used to find the exact entry point
	* along the perimeter of the source. Possible values are 0 (false) and
	* 1 (true). Default is 1 (true).
	*/
  static const String STYLE_EXIT_PERIMETER = "exitPerimeter";

  /**
	* Defines the key for the horizontal relative coordinate connection point
	* of an edge with its target terminal.
	*/
  static const String STYLE_ENTRY_X = "entryX";

  /**
	* Defines the key for the vertical relative coordinate connection point
	* of an edge with its target terminal.
	*/
  static const String STYLE_ENTRY_Y = "entryY";

  /**
	* Defines if the perimeter should be used to find the exact entry point
	* along the perimeter of the target. Possible values are 0 (false) and
	* 1 (true). Default is 1 (true).
	*/
  static const String STYLE_ENTRY_PERIMETER = "entryPerimeter";

  /**
   * Defines the key for the white-space style. Possible values are "nowrap"
   * and "wrap". The default value is "nowrap". This value specifies how
   * white-space inside a HTML vertex label should be handled. A value of
   * "nowrap" means the text will never wrap to the next line until a
   * linefeed is encountered. A value of "wrap" means text will wrap when
   * necessary.
   */
  static const String STYLE_WHITE_SPACE = "whiteSpace";

  /**
   * Defines the key for the rotation style. The type of the value is
   * <code>double</code> and the possible range is 0-360.
   */
  static const String STYLE_ROTATION = "rotation";

  /**
   * Defines the key for the fillColor style. The value is a string
   * expression supported by Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_FILLCOLOR = "fillColor";

  /**
   * Defines the key for the gradientColor style. The value is a string
   * expression supported by Utils.parseColor. This is ignored if no fill
   * color is defined.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_GRADIENTCOLOR = "gradientColor";

  /**
   * Defines the key for the gradient direction. Possible values are
   * <code>DIRECTION_EAST</code>, <code>DIRECTION_WEST</code>,
   * <code>DIRECTION_NORTH</code> and <code>DIRECTION_SOUTH</code>. Default
   * is <code>DIRECTION_SOUTH</code>. Generally, and by default in Graph,
   * gradient painting is done from the value of <code>STYLE_FILLCOLOR</code>
   * to the value of <code>STYLE_GRADIENTCOLOR</code>. Taking the example of
   * <code>DIRECTION_NORTH</code>, this means <code>STYLE_FILLCOLOR</code>
   * color at the bottom of paint pattern and
   * <code>STYLE_GRADIENTCOLOR</code> at top, with a gradient in-between.
   */
  static const String STYLE_GRADIENT_DIRECTION = "gradientDirection";

  /**
   * Defines the key for the strokeColor style. The value is a string
   * expression supported by Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_STROKECOLOR = "strokeColor";

  /**
   * Defines the key for the separatorColor style. The value is a string
   * expression supported by Utils.parseColor. This style is only used
   * for SHAPE_SWIMLANE shapes.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_SEPARATORCOLOR = "separatorColor";

  /**
   * Defines the key for the strokeWidth style. The type of the value is
   * <code>float</code> and the possible range is any non-negative value.
   * The value reflects the stroke width in pixels.
   */
  static const String STYLE_STROKEWIDTH = "strokeWidth";

  /**
   * Defines the key for the align style. Possible values are
   * <code>ALIGN_LEFT</code>, <code>ALIGN_CENTER</code> and
   * <code>ALIGN_RIGHT</code>. This value defines how the lines of the label
   * are horizontally aligned. <code>ALIGN_LEFT</code> mean label text lines
   * are aligned to left of the label bounds, <code>ALIGN_RIGHT</code> to the
   * right of the label bounds and <code>ALIGN_CENTER</code> means the
   * center of the text lines are aligned in the center of the label bounds.
   * Note this value doesn't affect the positioning of the overall label
   * bounds relative to the vertex, to move the label bounds horizontally, use
   * <code>STYLE_LABEL_POSITION</code>.
   */
  static const String STYLE_ALIGN = "align";

  /**
   * Defines the key for the verticalAlign style. Possible values are
   * <code>ALIGN_TOP</code>, <code>ALIGN_MIDDLE</code> and
   * <code>ALIGN_BOTTOM</code>. This value defines how the lines of the label
   * are vertically aligned. <code>ALIGN_TOP</code> means the topmost label
   * text line is aligned against the top of the label bounds,
   * <code>ALIGN_BOTTOM</code> means the bottom-most label text line is
   * aligned against the bottom of the label bounds and
   * <code>ALIGN_MIDDLE</code> means there is equal spacing between the
   * topmost text label line and the top of the label bounds and the
   * bottom-most text label line and the bottom of the label bounds. Note
   * this value doesn't affect the positioning of the overall label bounds
   * relative to the vertex, to move the label bounds vertically, use
   * <code>STYLE_VERTICAL_LABEL_POSITION</code>.
   */
  static const String STYLE_VERTICAL_ALIGN = "verticalAlign";

  /**
   * Defines the key for the horizontal label position of vertices. Possible
   * values are <code>ALIGN_LEFT</code>, <code>ALIGN_CENTER</code> and
   * <code>ALIGN_RIGHT</code>. Default is <code>ALIGN_CENTER</code>. The
   * label align defines the position of the label relative to the cell.
   * <code>ALIGN_LEFT</code> means the entire label bounds is placed
   * completely just to the left of the vertex, <code>ALIGN_RIGHT</code>
   * means adjust to the right and <code>ALIGN_CENTER</code> means the label
   * bounds are vertically aligned with the bounds of the vertex. Note this
   * value doesn't affect the positioning of label within the label bounds,
   * to move the label horizontally within the label bounds, use
   * <code>STYLE_ALIGN</code>.
   */
  static const String STYLE_LABEL_POSITION = "labelPosition";

  /**
   * Defines the key for the vertical label position of vertices. Possible
   * values are <code>ALIGN_TOP</code>, <code>ALIGN_BOTTOM</code> and
   * <code>ALIGN_MIDDLE</code>. Default is <code>ALIGN_MIDDLE</code>. The
   * label align defines the position of the label relative to the cell.
   * <code>ALIGN_TOP</code> means the entire label bounds is placed
   * completely just on the top of the vertex, <code>ALIGN_BOTTOM</code>
   * means adjust on the bottom and <code>ALIGN_MIDDLE</code> means the label
   * bounds are horizontally aligned with the bounds of the vertex. Note
   * this value doesn't affect the positioning of label within the label
   * bounds, to move the label vertically within the label bounds, use
   * <code>STYLE_VERTICAL_ALIGN</code>.
   */
  static const String STYLE_VERTICAL_LABEL_POSITION = "verticalLabelPosition";

  /**
   * Defines the key for the align style. Possible values are
   * <code>ALIGN_LEFT</code>, <code>ALIGN_CENTER</code> and
   * <code>ALIGN_RIGHT</code>. The value defines how any image in the vertex
   * label is aligned horizontally within the label bounds of a SHAPE_LABEL
   * shape.
   */
  static const String STYLE_IMAGE_ALIGN = "imageAlign";

  /**
   * Defines the key for the verticalAlign style. Possible values are
   * <code>ALIGN_TOP</code>, <code>ALIGN_MIDDLE</code> and
   * <code>ALIGN_BOTTOM</code>. The value defines how any image in the vertex
   * label is aligned vertically within the label bounds of a SHAPE_LABEL
   * shape.
   */
  static const String STYLE_IMAGE_VERTICAL_ALIGN = "imageVerticalAlign";

  /**
   * Defines the key for the glass style. Possible values are 0 (disabled) and
   * 1(enabled). The default value is 0. This is used in mxLabel.
   */
  static const String STYLE_GLASS = "glass";

  /**
   * Defines the key for the image style. Possible values are any image URL,
   * registered key in mxImageResources or short data URI as defined in
   * ImageBundle.
   * The type of the value is <code>String</code>. This is the path to the
   * image to image that is to be displayed within the label of a vertex. See
   * Graphics2DCanvas.getImageForStyle, loadImage and setImageBasePath on
   * how the image URL is resolved. Finally, Utils.loadImage is used for
   * loading the image for a given value.
   */
  static const String STYLE_IMAGE = "image";

  /**
   * Defines the key for the imageWidth style. The type of this value is
   * <code>int</code>, the value is the image width in pixels and must be
   * greated than 0.
   */
  static const String STYLE_IMAGE_WIDTH = "imageWidth";

  /**
   * Defines the key for the imageHeight style The type of this value is
   * <code>int</code>, the value is the image height in pixels and must be
   * greater than 0.
   */
  static const String STYLE_IMAGE_HEIGHT = "imageHeight";

  /**
   * Defines the key for the image background color. This style is only used
   * for image shapes. Possible values are all HTML color names or HEX codes.
   */
  static const String STYLE_IMAGE_BACKGROUND = "imageBackground";

  /**
   * Defines the key for the image border color. This style is only used for
   * image shapes. Possible values are all HTML color names or HEX codes.
   */
  static const String STYLE_IMAGE_BORDER = "imageBorder";

  /**
   * Defines the key for the horizontal image flip. This style is only used
   * in ImageShape. Possible values are 0 and 1. Default is 0.
   */
  static const String STYLE_IMAGE_FLIPH = "imageFlipH";

  /**
   * Defines the key for the vertical image flip. This style is only used
   * in ImageShape. Possible values are 0 and 1. Default is 0.
   */
  static const String STYLE_IMAGE_FLIPV = "imageFlipV";

  /**
   * Defines the key for the horizontal stencil flip. This style is only used
   * for <StencilShape>. Possible values are 0 and 1. Default is 0.
   */
  static const String STYLE_STENCIL_FLIPH = "stencilFlipH";

  /**
   * Defines the key for the vertical stencil flip. This style is only used
   * for <StencilShape>. Possible values are 0 and 1. Default is 0.
   */
  static const String STYLE_STENCIL_FLIPV = "stencilFlipV";


  /**
   * Defines the key for the horizontal image flip. This style is only used
   * in <ImageShape>. Possible values are 0 and 1. Default is 0.
   */
  static const String STYLE_FLIPH = "flipH";

  /**
   * Variable: STYLE_FLIPV
   *
   * Defines the key for the vertical flip. Possible values are 0 and 1.
   * Default is 0.
   */
  static const String STYLE_FLIPV = "flipV";

  /**
   * Defines the key for the noLabel style. If this is
   * true then no label is visible for a given cell.
   * Possible values are true or false (1 or 0).
   * Default is false.
   */
  static const String STYLE_NOLABEL = "noLabel";

  /**
   * Defines the key for the noEdgeStyle style. If this is
   * true then no edge style is applied for a given edge.
   * Possible values are true or false (1 or 0).
   * Default is false.
   */
  static const String STYLE_NOEDGESTYLE = "noEdgeStyle";

  /**
   * Defines the key for the label background color. The value is a string
   * expression supported by Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_LABEL_BACKGROUNDCOLOR = "labelBackgroundColor";

  /**
   * Defines the key for the label border color. The value is a string
   * expression supported by Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_LABEL_BORDERCOLOR = "labelBorderColor";

  /**
   * Defines the key for the indicatorShape style.
   * Possible values are any of the SHAPE_*
   * constants.
   */
  static const String STYLE_INDICATOR_SHAPE = "indicatorShape";

  /**
   * Defines the key for the indicatorImage style.
   * Possible values are any image URL, the type of the value is
   * <code>String</code>.
   */
  static const String STYLE_INDICATOR_IMAGE = "indicatorImage";

  /**
   * Defines the key for the indicatorColor style. The value is a string
   * expression supported by Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_INDICATOR_COLOR = "indicatorColor";

  /**
   * Defines the key for the indicatorGradientColor style. The value is a
   * string expression supported by Utils.parseColor. This style is only
   * supported in SHAPE_LABEL shapes.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_INDICATOR_GRADIENTCOLOR = "indicatorGradientColor";

  /**
   * Defines the key for the indicatorSpacing style (in px).
   */
  static const String STYLE_INDICATOR_SPACING = "indicatorSpacing";

  /**
   * Defines the key for the indicatorWidth style (in px).
   */
  static const String STYLE_INDICATOR_WIDTH = "indicatorWidth";

  /**
   * Defines the key for the indicatorHeight style (in px).
   */
  static const String STYLE_INDICATOR_HEIGHT = "indicatorHeight";

  /**
   * Defines the key for the shadow style. The type of the value is
   * <code>boolean</code>. This style applies to vertices and arrow style
   * edges.
   */
  static const String STYLE_SHADOW = "shadow";

  /**
   * Defines the key for the segment style. The type of this value is
   * <code>float</code> and the value represents the size of the horizontal
   * segment of the entity relation style. Default is ENTITY_SEGMENT.
   */
  static const String STYLE_SEGMENT = "segment";

  /**
   * Defines the key for the endArrow style.
   * Possible values are all constants in this
   * class that start with ARROW_. This style is
   * supported in the <code>mxConnector</code> shape.
   */
  static const String STYLE_ENDARROW = "endArrow";

  /**
   * Defines the key for the startArrow style.
   * Possible values are all constants in this
   * class that start with ARROW_.
   * See STYLE_ENDARROW.
   * This style is supported in the mxConnector shape.
   */
  static const String STYLE_STARTARROW = "startArrow";

  /**
   * Defines the key for the endSize style. The type of this value is
   * <code>float</code> and the value represents the size of the end
   * marker in pixels.
   */
  static const String STYLE_ENDSIZE = "endSize";

  /**
   * Defines the key for the startSize style. The type of this value is
   * <code>float</code> and the value represents the size of the start marker
   * or the size of the swimlane title region depending on the shape it is
   * used for.
   */
  static const String STYLE_STARTSIZE = "startSize";

  /**
   * Defines the key for the endFill style. Use 0 for no fill or 1
   * (default) for fill. (This style is only exported via <mxImageExport>.)
   */
  static const String STYLE_ENDFILL = "endFill";

  /**
   * Defines the key for the startFill style. Use 0 for no fill or 1
   * (default) for fill. (This style is only exported via <mxImageExport>.)
   */
  static const String STYLE_STARTFILL = "startFill";

  /**
   * Defines the key for the dashed style. The type of this value is
   * <code>boolean</code> and the value determines whether or not an edge or
   * border is drawn with a dashed pattern along the line.
   */
  static const String STYLE_DASHED = "dashed";

  /**
   * Defines the key for the dashed pattern style. The type of this value
   * is <code>List<float></code> and the value specifies the dashed pattern
   * to apply to edges drawn with this style. This style allows the user
   * to specify a custom-defined dash pattern. This is done using a series
   * of numbers. Dash styles are defined in terms of the length of the dash
   * (the drawn part of the stroke) and the length of the space between the
   * dashes. The lengths are relative to the line width: a length of "1" is
   * equal to the line width.
   */
  static const String STYLE_DASH_PATTERN = "dashPattern";

  /**
   * Defines the key for the rounded style. The type of this value is
   * <code>boolean</code>. For edges this determines whether or not joins
   * between edges segments are smoothed to a rounded finish. For vertices
   * that have the rectangle shape, this determines whether or not the
   * rectangle is rounded.
   */
  static const String STYLE_ROUNDED = "rounded";

  /**
   * Defines the key for the source perimeter spacing. The type of this value
   * is <code>double</code>. This is the distance between the source
   * connection point of an edge and the perimeter of the source vertex in
   * pixels. This style only applies to edges.
   */
  static const String STYLE_SOURCE_PERIMETER_SPACING = "sourcePerimeterSpacing";

  /**
   * Defines the key for the target perimeter spacing. The type of this value
   * is <code>double</code>. This is the distance between the target
   * connection point of an edge and the perimeter of the target vertex in
   * pixels. This style only applies to edges.
   */
  static const String STYLE_TARGET_PERIMETER_SPACING = "targetPerimeterSpacing";

  /**
   * Defines the key for the perimeter spacing. This is the distance between
   * the connection point and the perimeter in pixels. When used in a vertex
   * style, this applies to all incoming edges to floating ports (edges that
   * terminate on the perimeter of the vertex). When used in an edge style,
   * this spacing applies to the source and target separately, if they
   * terminate in floating ports (on the perimeter of the vertex).
   */
  static const String STYLE_PERIMETER_SPACING = "perimeterSpacing";

  /**
   * Defines the key for the spacing. The value represents the spacing, in
   * pixels, added to each side of a label in a vertex (style applies to
   * vertices only).
   */
  static const String STYLE_SPACING = "spacing";

  /**
   * Defines the key for the spacingTop style. The value represents the
   * spacing, in pixels, added to the top side of a label in a vertex (style
   * applies to vertices only).
   */
  static const String STYLE_SPACING_TOP = "spacingTop";

  /**
   * Defines the key for the spacingLeft style. The value represents the
   * spacing, in pixels, added to the left side of a label in a vertex (style
   * applies to vertices only).
   */
  static const String STYLE_SPACING_LEFT = "spacingLeft";

  /**
   * Defines the key for the spacingBottom style The value represents the
   * spacing, in pixels, added to the bottom side of a label in a vertex
   * (style applies to vertices only).
   */
  static const String STYLE_SPACING_BOTTOM = "spacingBottom";

  /**
   * Defines the key for the spacingRight style The value represents the
   * spacing, in pixels, added to the right side of a label in a vertex (style
   * applies to vertices only).
   */
  static const String STYLE_SPACING_RIGHT = "spacingRight";

  /**
   * Defines the key for the horizontal style. Possible values are
   * <code>true</code> or <code>false</code>. This value only applies to
   * vertices. If the <code>STYLE_SHAPE</code> is <code>SHAPE_SWIMLANE</code>
   * a value of <code>false</code> indicates that the swimlane should be drawn
   * vertically, <code>true</code> indicates to draw it horizontally. If the
   * shape style does not indicate that this vertex is a swimlane, this value
   * affects only whether the label is drawn horizontally or vertically.
   */
  static const String STYLE_HORIZONTAL = "horizontal";

  /**
   * Defines the key for the direction style. The direction style is used to
   * specify the direction of certain shapes (eg. <code>mxTriangle</code>).
   * Possible values are <code>DIRECTION_EAST</code> (default),
   * <code>DIRECTION_WEST</code>, <code>DIRECTION_NORTH</code> and
   * <code>DIRECTION_SOUTH</code>. This value only applies to vertices.
   */
  static const String STYLE_DIRECTION = "direction";

  /**
   * Defines the key for the elbow style. Possible values are
   * <code>ELBOW_HORIZONTAL</code> and <code>ELBOW_VERTICAL</code>. Default is
   * <code>ELBOW_HORIZONTAL</code>. This defines how the three segment
   * orthogonal edge style leaves its terminal vertices. The vertical style
   * leaves the terminal vertices at the top and bottom sides.
   */
  static const String STYLE_ELBOW = "elbow";

  /**
   * Defines the key for the fontColor style. The value is type
   * <code>String</code> and of the expression supported by
   * Utils.parseColor.
   *
   * @see graph.util.Utils#parseColor(String)
   */
  static const String STYLE_FONTCOLOR = "fontColor";

  /**
   * Defines the key for the fontFamily style. Possible values are names such
   * as Arial; Dialog; Verdana; Times New Roman. The value is of type
   * <code>String</code>.
   */
  static const String STYLE_FONTFAMILY = "fontFamily";

  /**
   * Defines the key for the fontSize style (in points). The type of the value
   * is <code>int</code>.
   */
  static const String STYLE_FONTSIZE = "fontSize";

  /**
   * Defines the key for the fontStyle style. Values may be any logical AND
   * (sum) of FONT_BOLD, FONT_ITALIC, FONT_UNDERLINE and FONT_SHADOW. The type
   * of the value is <code>int</code>.
   */
  static const String STYLE_FONTSTYLE = "fontStyle";

  /**
   * Defines the key for the autosize style. This specifies if a cell should be
   * resized automatically if the value has changed. Possible values are 0 or 1.
   * Default is 0. See Graph.isAutoSizeCell. This is normally combined with
   * STYLE_RESIZABLE to disable manual sizing.
   */
  static const String STYLE_AUTOSIZE = "autosize";

  /**
   * Defines the key for the foldable style. This specifies if a cell is foldable
   * using a folding icon. Possible values are 0 or 1. Default is 1. See
   * Graph.isCellFoldable.
   */
  static const String STYLE_FOLDABLE = "foldable";

  /**
   * Defines the key for the editable style. This specifies if the value of
   * a cell can be edited using the in-place editor. Possible values are 0 or
   * 1. Default is 1. See Graph.isCellEditable.
   */
  static const String STYLE_EDITABLE = "editable";

  /**
   * Defines the key for the bendable style. This specifies if the control
   * points of an edge can be moved. Possible values are 0 or 1. Default is
   * 1. See Graph.isCellBendable.
   */
  static const String STYLE_BENDABLE = "bendable";

  /**
   * Defines the key for the movable style. This specifies if a cell can
   * be moved. Possible values are 0 or 1. Default is 1. See
   * Graph.isCellMovable.
   */
  static const String STYLE_MOVABLE = "movable";

  /**
   * Defines the key for the resizable style. This specifies if a cell can
   * be resized. Possible values are 0 or 1. Default is 1. See
   * Graph.isCellResizable.
   */
  static const String STYLE_RESIZABLE = "resizable";

  /**
   * Defines the key for the cloneable style. This specifies if a cell can
   * be cloned. Possible values are 0 or 1. Default is 1. See
   * Graph.isCellCloneable.
   */
  static const String STYLE_CLONEABLE = "cloneable";

  /**
   * Defines the key for the deletable style. This specifies if a cell can be
   * deleted. Possible values are 0 or 1. Default is 1. See
   * Graph.isCellDeletable.
   */
  static const String STYLE_DELETABLE = "deletable";

  /**
   * Defines the key for the shape style.
   * Possible values are any of the SHAPE_*
   * constants.
   */
  static const String STYLE_SHAPE = "shape";

  /**
   * Takes a function that creates points. Possible values are the
   * functions defined in EdgeStyle.
   */
  static const String STYLE_EDGE = "edgeStyle";

  /**
   * Defines the key for the loop style. Possible values are the
   * functions defined in EdgeStyle.
   */
  static const String STYLE_LOOP = "loopStyle";

  /**
   * Defines the key for the horizontal routing center. Possible values are
   * between -0.5 and 0.5. This is the relative offset from the center used
   * for connecting edges. The type of this value is <code>float</code>.
   */
  static const String STYLE_ROUTING_CENTER_X = "routingCenterX";

  /**
   * Defines the key for the vertical routing center. Possible values are
   * between -0.5 and 0.5. This is the relative offset from the center used
   * for connecting edges. The type of this value is <code>float</code>.
   */
  static const String STYLE_ROUTING_CENTER_Y = "routingCenterY";

  /**
   * FONT_BOLD
   */
  static const int FONT_BOLD = 1;

  /**
   * FONT_ITALIC
   */
  static const int FONT_ITALIC = 2;

  /**
   * FONT_UNDERLINE
   */
  static const int FONT_UNDERLINE = 4;

  /**
   * FONT_SHADOW
   */
  static const int FONT_SHADOW = 8;

  /**
   * SHAPE_RECTANGLE
   */
  static const String SHAPE_RECTANGLE = "rectangle";

  /**
   * SHAPE_ELLIPSE
   */
  static const String SHAPE_ELLIPSE = "ellipse";

  /**
   * SHAPE_DOUBLE_RECTANGLE
   */
  static const String SHAPE_DOUBLE_RECTANGLE = "doubleRectangle";

  /**
   * SHAPE_DOUBLE_ELLIPSE
   */
  static const String SHAPE_DOUBLE_ELLIPSE = "doubleEllipse";

  /**
   * SHAPE_RHOMBUS
   */
  static const String SHAPE_RHOMBUS = "rhombus";

  /**
   * SHAPE_LINE
   */
  static const String SHAPE_LINE = "line";

  /**
   * SHAPE_IMAGE
   */
  static const String SHAPE_IMAGE = "image";

  /**
   * SHAPE_ARROW
   */
  static const String SHAPE_ARROW = "arrow";

  /**
   * SHAPE_ARROW
   */
  static const String SHAPE_CURVE = "curve";

  /**
   * SHAPE_LABEL
   */
  static const String SHAPE_LABEL = "label";

  /**
   * SHAPE_CYLINDER
   */
  static const String SHAPE_CYLINDER = "cylinder";

  /**
   * SHAPE_SWIMLANE
   */
  static const String SHAPE_SWIMLANE = "swimlane";

  /**
   * SHAPE_CONNECTOR
   */
  static const String SHAPE_CONNECTOR = "connector";

  /**
   * SHAPE_ACTOR
   */
  static const String SHAPE_ACTOR = "actor";

  /**
   * SHAPE_CLOUD
   */
  static const String SHAPE_CLOUD = "cloud";

  /**
   * SHAPE_TRIANGLE
   */
  static const String SHAPE_TRIANGLE = "triangle";

  /**
   * SHAPE_HEXAGON
   */
  static const String SHAPE_HEXAGON = "hexagon";

  /**
   * ARROW_CLASSIC
   */
  static const String ARROW_CLASSIC = "classic";

  /**
   * ARROW_BLOCK
   */
  static const String ARROW_BLOCK = "block";

  /**
   * ARROW_OPEN
   */
  static const String ARROW_OPEN = "open";

  /**
   * ARROW_BLOCK
   */
  static const String ARROW_OVAL = "oval";

  /**
   * ARROW_OPEN
   */
  static const String ARROW_DIAMOND = "diamond";

  /**
   * ALIGN_LEFT
   */
  static const String ALIGN_LEFT = "left";

  /**
   * ALIGN_CENTER
   */
  static const String ALIGN_CENTER = "center";

  /**
   * ALIGN_RIGHT
   */
  static const String ALIGN_RIGHT = "right";

  /**
   * ALIGN_TOP
   */
  static const String ALIGN_TOP = "top";

  /**
   * ALIGN_MIDDLE
   */
  static const String ALIGN_MIDDLE = "middle";

  /**
   * ALIGN_BOTTOM
   */
  static const String ALIGN_BOTTOM = "bottom";

  /**
   * DIRECTION_NORTH
   */
  static const String DIRECTION_NORTH = "north";

  /**
   * DIRECTION_SOUTH
   */
  static const String DIRECTION_SOUTH = "south";

  /**
   * DIRECTION_EAST
   */
  static const String DIRECTION_EAST = "east";

  /**
   * DIRECTION_WEST
   */
  static const String DIRECTION_WEST = "west";

  /**
   * DIRECTION_MASK_NONE
   */
  static const int DIRECTION_MASK_NONE = 0x00;

  /**
   * DIRECTION_MASK_WEST
   */
  static const int DIRECTION_MASK_WEST = 0x01;

  /**
   * DIRECTION_MASK_NORTH
   */
  static const int DIRECTION_MASK_NORTH = 0x02;

  /**
   * DIRECTION_MASK_SOUTH
   */
  static const int DIRECTION_MASK_SOUTH = 0x04;

  /**
   * DIRECTION_MASK_EAST
   */
  static const int DIRECTION_MASK_EAST = 0x08;

  /**
   * DIRECTION_MASK_EAST
   */
  static const int DIRECTION_MASK_ALL = 0x0F;

  /**
   * ELBOW_VERTICAL
   */
  static const String ELBOW_VERTICAL = "vertical";

  /**
   * ELBOW_HORIZONTAL
   */
  static const String ELBOW_HORIZONTAL = "horizontal";

  /**
   * Name of the elbow edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_ELBOW = "elbowEdgeStyle";

  /**
   * Name of the entity relation edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_ENTITY_RELATION = "entityRelationEdgeStyle";

  /**
   * Name of the loop edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_LOOP = "loopEdgeStyle";

  /**
   * Name of the side to side edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_SIDETOSIDE = "sideToSideEdgeStyle";

  /**
   * Name of the top to bottom edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_TOPTOBOTTOM = "topToBottomEdgeStyle";

  /**
   * Name of the orthogonal edge style. Can be used as a string value for
   * the STYLE_EDGE style.
   */
  static const String EDGESTYLE_ORTHOGONAL = "orthogonalEdgeStyle";

  /**
   * Name of the generic segment edge style. Can be used as a string value
   * for the STYLE_EDGE style.
   */
  static const String EDGESTYLE_SEGMENT = "segmentEdgeStyle";

  /**
   * Name of the ellipse perimeter. Can be used as a string value
   * for the STYLE_PERIMETER style.
   */
  static const String PERIMETER_ELLIPSE = "ellipsePerimeter";

  /**
   * Name of the rectangle perimeter. Can be used as a string value
   * for the STYLE_PERIMETER style.
   */
  static const String PERIMETER_RECTANGLE = "rectanglePerimeter";

  /**
   * Name of the rhombus perimeter. Can be used as a string value
   * for the STYLE_PERIMETER style.
   */
  static const String PERIMETER_RHOMBUS = "rhombusPerimeter";

  /**
   * Name of the triangle perimeter. Can be used as a string value
   * for the STYLE_PERIMETER style.
   */
  static const String PERIMETER_TRIANGLE = "trianglePerimeter";

  /**
   * Name of the hexagon perimeter. Can be used as a string value
   * for the STYLE_PERIMETER style.
   */
  static const String PERIMETER_HEXAGON = "hexagonPerimeter";

}
