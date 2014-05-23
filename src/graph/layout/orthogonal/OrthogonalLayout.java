/**
 * $Id: OrthogonalLayout.java,v 1.1 2012/11/15 13:26:49 gaudenz Exp $
 * Copyright (c) 2008-2009, JGraph Ltd
 */
package graph.layout.orthogonal;

import graph.layout.GraphLayout;
import graph.layout.orthogonal.model.OrthogonalModel;
import graph.view.Graph;

/**
 *
 */
/**
*
*/
public class OrthogonalLayout extends GraphLayout
{

  /**
   * 
   */
  protected OrthogonalModel orthModel;

  /**
   * Whether or not to route the edges along grid lines only, if the grid
   * is enabled. Default is false
   */
  protected boolean routeToGrid = false;
  
  /**
   * 
   */
  public OrthogonalLayout(Graph graph)
  {
     super(graph);
     orthModel = new OrthogonalModel(graph);
  }

  /**
   * 
   */
  public void execute(Object parent)
  {
     // Create the rectangulation
     
  }

}
