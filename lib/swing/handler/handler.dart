library graph.swing.handler;
/**
 * This package contains all classes required for mouse event handling in
 * JFC/Swing. The classes implement rubberband selection, mouse tracking,
 * creating connections, handling vertices and edges, moving cells, panning
 * and keystroke handling.
 */
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, ImageElement, window;//MouseEvent, Element, DivElement, ImageElement;
import 'dart:html' as html;

import 'package:dart_web_toolkit/ui.dart' as ui;
import 'package:dart_web_toolkit/event.dart' as event;
import 'package:dart_web_toolkit/util.dart' as util;

import '../../util/awt/awt.dart' as awt;

import '../../util/property_change/property_change.dart';

import '../../swing/swing.dart' show GraphComponent;
import '../../swing/swing.dart' show GraphControl;
import '../../swing/util/util.dart' show MouseAdapter;
import '../../swing/util/util.dart' show SwingConstants;
import '../../swing/util/util.dart' show GraphTransferable;
import '../../swing/util/util.dart' show GraphActions;
import '../../swing/view/view.dart' show CellStatePreview;

import '../../canvas/canvas.dart' show Graphics2DCanvas;

import '../../model/model.dart' show Cell;
import '../../model/model.dart' show Geometry;
import '../../model/model.dart' show ICell;
import '../../model/model.dart' show IGraphModel;

import '../../util/util.dart' show Point2d;
import '../../util/util.dart' show Rect;
import '../../util/util.dart' show Constants;
import '../../util/util.dart' show Event;
import '../../util/util.dart' show EventObj;
import '../../util/util.dart' show EventSource;
import '../../util/util.dart' show Utils;
import '../../util/util.dart' show IEventListener;
import '../../util/util.dart' show Resources;
import '../../util/util.dart' show CellRenderer;

import '../../view/view.dart' show CellState;
import '../../view/view.dart' show GraphView;
import '../../view/view.dart' show Graph;
import '../../view/view.dart' show ConnectionConstraint;

part 'cell_handler.dart';
part 'cell_marker.dart';
part 'cell_tracker.dart';
part 'connection_handler.dart';
part 'connect_preview.dart';
part 'edge_handler.dart';
part 'elbow_edge_handler.dart';
part 'graph_handler.dart';
part 'graph_transfer_handler.dart';
part 'insert_handler.dart';
part 'keyboard_handler.dart';
part 'move_preview.dart';
part 'panning_handler.dart';
part 'rotation_handler.dart';
part 'rubberband.dart';
part 'selection_cells_handler.dart';
part 'vertex_handler.dart';
