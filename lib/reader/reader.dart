library graph.reader;

/**
 * This package contains the classes required to turn an encoded mxGraphView
 * into an image using SAX and without having to create a graph model.
 */

import 'dart:html';

import 'package:xmlstream/xmlstream.dart';
import 'package:image/image.dart' as image;

import '../util/java/math.dart' as math;
import '../util/awt/awt.dart' as awt;
import '../util/xml/xml.dart' as xml;

import '../canvas/canvas.dart' show ICanvas2D, Graphics2DCanvas, ICanvas, ImageCanvas;
//import '../reader/reader.dart' show IElementHandler;
import '../view/view.dart' show CellState;
import '../util/util.dart' show Rect, Utils, Point2d;

part 'dom_output_parser.dart';
part 'graph_view_image_reader.dart';
part 'graph_view_reader.dart';
part 'sax_output_handler.dart';
