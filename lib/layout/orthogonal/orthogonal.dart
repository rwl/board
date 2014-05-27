/**
 * Copyright (c) 2008-2009, JGraph Ltd
 */
library graph.layout.orthogonal;

import '../../layout/layout.dart' show GraphLayout;
import '../../layout/orthogonal/model/model.dart' show OrthogonalModel;
import '../../view/view.dart' show Graph;

/**
 *
 */
/**
*
*/
class OrthogonalLayout extends GraphLayout
{

  /**
   * 
   */
  OrthogonalModel _orthModel;

  /**
   * Whether or not to route the edges along grid lines only, if the grid
   * is enabled. Default is false
   */
  bool _routeToGrid = false;
  
  /**
   * 
   */
  OrthogonalLayout(Graph graph) : super(graph)
  {
     _orthModel = new OrthogonalModel(graph);
  }

  /**
   * 
   */
  void execute(Object parent)
  {
     // Create the rectangulation
     
  }

}
