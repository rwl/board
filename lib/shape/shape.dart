library graph.shape;

import '../canvas/canvas.dart' show Graphics2DCanvas;
import '../view/view.dart' show CellState;

part 'actor_shape.dart';
part 'arrow_shape.dart';
part 'basic_shape.dart';
part 'cloud_shape.dart;
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
part 'marker.dart';
part 'text_shape.dart';
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

public interface IShape
{
	/**
	 * 
	 */
	void paintShape(Graphics2DCanvas canvas, CellState state);

}
