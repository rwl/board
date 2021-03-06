library graph.shape;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:collection' show HashMap;

import '../util/awt/awt.dart' as awt;
import '../util/java/math.dart' as math;

import '../canvas/canvas.dart' show Graphics2DCanvas;

import '../view/view.dart' show CellState;

import '../util/util.dart' show Constants;
import '../util/util.dart' show Point2d;
import '../util/util.dart' show Rect;
import '../util/util.dart' show Utils;
import '../util/util.dart' show Line;
import '../util/util.dart' show Curve;
import '../util/util.dart' show LightweightLabel;

import '../swing/util/util.dart' show SwingConstants;

// stencil
import '../util/util.dart' show XmlUtils;
//import '../util/svg/svg.dart' show AWTPathProducer;
//import '../util/svg/svg.dart' show AWTPolygonProducer;
//import '../util/svg/svg.dart' show AWTPolylineProducer;
//import '../util/svg/svg.dart' show CSSConstants;
//import '../util/svg/svg.dart' show ExtendedGeneralPath;
import '../canvas/canvas.dart' show GraphicsCanvas2D;

part 'actor_shape.dart';
part 'arrow_shape.dart';
part 'basic_shape.dart';
part 'cloud_shape.dart';
part 'connector_shape.dart';
part 'curve_label_shape.dart';
part 'curve_shape.dart';
part 'cylinder_shape.dart';
part 'default_text_shape.dart';
part 'double_ellipse_shape.dart';
part 'double_rectangle_shape.dart';
part 'ellipse_shape.dart';
part 'hexagon_shape.dart';
part 'html_text_shape.dart';
part 'image_shape.dart';
part 'label_shape.dart';
part 'line_shape.dart';
part 'marker_registry.dart';
part 'rectangle_shape.dart';
part 'rhombus_shape.dart';
part 'stencil.dart';
part 'stencil_registry.dart';
part 'stencil_shape.dart';
part 'swimlane_shape.dart';
part 'triangle_shape.dart';

//typedef void IShape(Graphics2DCanvas canvas, CellState state);

typedef Point2d IMarker(Graphics2DCanvas canvas, CellState state, String type, Point2d pe, double nx, double ny, double size, bool source);

abstract class IShape {
  void paintShape(Graphics2DCanvas canvas, CellState state);
}

//abstract class IMarker {
//  Point2d paintMarker(Graphics2DCanvas canvas, CellState state, String type, Point2d pe, double nx, double ny, double size, bool source);
//}

abstract class ITextShape {
  void paintShape(Graphics2DCanvas canvas, String text, CellState state, Map<String, Object> style);
}
