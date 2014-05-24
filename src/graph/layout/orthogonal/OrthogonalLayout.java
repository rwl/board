/**
 * Copyright (c) 2008-2009, JGraph Ltd
 */
part of graph.layout.orthogonal;

//import graph.layout.GraphLayout;
//import graph.layout.orthogonal.model.OrthogonalModel;
//import graph.view.Graph;

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
  protected OrthogonalModel _orthModel;

  /**
   * Whether or not to route the edges along grid lines only, if the grid
   * is enabled. Default is false
   */
  protected boolean _routeToGrid = false;
  
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
