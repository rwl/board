library graph.sharing;

/**
 * This package contains all classes required for concurrent diagram editing
 * by multiple clients.
 */

import '../sharing/sharing.dart' show DiagramChangeListener;

import '../io/io.dart' show Codec;

import '../model/model.dart' show ChildChange;
import '../model/model.dart' show GraphModel;
import '../model/model.dart' show ICell;
import '../model/model.dart' show AtomicGraphModelChange;

import '../util/util.dart' show Utils;
import '../util/util.dart' show Event;
import '../util/util.dart' show EventObj;
import '../util/util.dart' show UndoableEdit;
import '../util/util.dart' show XmlUtils;
import '../util/util.dart' show EventSource;

part 'session.dart';
part 'shared_graph_model.dart';
part 'shared_state.dart';