/**
 * Copyright (c) 2008-2009, JGraph Ltd
 */
library graph.layout.orthogonal;

import '../../layout.GraphLayout;
import '../../layout.orthogonal.model.OrthogonalModel;
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
  protected OrthogonalModel _orthModel;

  /**
   * Whether or not to route the edges along grid lines only, if the grid
   * is enabled. Default is false
   */
  protected bool _routeToGrid = false;
  
  /**
   * 
   */
  public OrthogonalLayout(Graph graph)
  {
     super(graph);
     _orthModel = new OrthogonalModel(graph);
  }

  /**
   * 
   */
  public void execute(Object parent)
  {
     // Create the rectangulation
     
  }

}
