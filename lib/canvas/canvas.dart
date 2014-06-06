/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 */
library graph.canvas;

/**
 * This package contains various implementations for painting a graph using
 * different technologies, such as Graphics2D, HTML, SVG or VML.
 */

import 'dart:html';
import 'dart:collection' show HashMap;
import 'dart:math' as Math;

//import 'package:color/color.dart' as color;
import 'package:image/image.dart' as image;
import 'package:crypto/crypto.dart';

import '../util/java/math.dart' as math;
import '../util/awt/awt.dart' as awt;

//import '../shape/shape.dart' show ActorShape;
//import '../shape/shape.dart' show ArrowShape;
//import '../shape/shape.dart' show CloudShape;
//import '../shape/shape.dart' show ConnectorShape;
//import '../shape/shape.dart' show CurveShape;
//import '../shape/shape.dart' show CylinderShape;
//import '../shape/shape.dart' show DefaultTextShape;
//import '../shape/shape.dart' show DoubleEllipseShape;
//import '../shape/shape.dart' show DoubleRectangleShape;
//import '../shape/shape.dart' show EllipseShape;
//import '../shape/shape.dart' show HexagonShape;
//import '../shape/shape.dart' show HtmlTextShape;
//import '../shape/shape.dart' show IShape;
//import '../shape/shape.dart' show ITextShape;
//import '../shape/shape.dart' show ImageShape;
//import '../shape/shape.dart' show LabelShape;
//import '../shape/shape.dart' show LineShape;
//import '../shape/shape.dart' show RectangleShape;
//import '../shape/shape.dart' show RhombusShape;
//import '../shape/shape.dart' show StencilRegistry;
//import '../shape/shape.dart' show SwimlaneShape;
//import '../shape/shape.dart' show TriangleShape;
import '../shape/shape.dart';

import '../swing/util/util.dart' show SwingConstants;

import '../view/view.dart' show CellState;

import '../util/util.dart' show Constants, Utils, LightweightLabel, Point2d, Rect, Base64;

//import java.awt.Point;

part 'basic_canvas.dart';
part 'graphics2d_canvas.dart';
part 'graphics_canvas2d.dart';
part 'html_canvas.dart';
part 'canvas2d.dart';
part 'image_canvas.dart';
part 'svg_canvas.dart';
part 'vml_canvas.dart';

/**
 * Defines the requirements for a canvas that paints the vertices and edges of
 * a graph.
 */
abstract class ICanvas {
  /**
   * Sets the translation for the following drawing requests.
   */
  void setTranslate(int x, int y);

  /**
   * Returns the current translation.
   * 
   * @return Returns the current translation.
   */
  awt.Point getTranslate();

  /**
   * Sets the scale for the following drawing requests.
   */
  void setScale(double scale);

  /**
   * Returns the scale.
   */
  double getScale();

  /**
   * Draws the given cell.
   * 
   * @param state State of the cell to be painted.
   * @return Object that represents the cell.
   */
  Object drawCell(CellState state);

  /**
   * Draws the given label.
   * 
   * @param text String that represents the label.
   * @param state State of the cell whose label is to be painted.
   * @param html Specifies if the label contains HTML markup.
   * @return Object that represents the label.
   */
  Object drawLabel(String text, CellState state, bool html);

}
