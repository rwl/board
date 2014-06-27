library graph.swing.view;
/**
 * This package contains all classes required for interaction, namely the
 * CellEditor used for in-place editing and the mxInteractiveCanvas, which
 * defines the requirements for a canvas that supports hit-detection on shapes.
 */

import '../../util/awt/awt.dart' as awt;

import '../../canvas/canvas.dart' show Graphics2DCanvas;

import '../../model/model.dart' show Geometry;
import '../../model/model.dart' show IGraphModel;

import '../../swing/swing.dart' show GraphComponent;

import '../../shape/shape.dart' show BasicShape;
import '../../shape/shape.dart' show IShape;

import '../../util/util.dart' show Constants;
import '../../util/util.dart' show Utils;
import '../../util/util.dart' show Point2d;
import '../../util/util.dart' show Rect;
import '../../util/util.dart' show Utils;
import '../../view/view.dart' show Graph;

import '../../view/view.dart' show CellState;

part 'cell_editor.dart';
part 'cell_state_preview.dart';
part 'interactive_canvas.dart';
part 'no_linefeed_html_editor_kit.dart';
part 'no_linefeed_html_writer.dart';
