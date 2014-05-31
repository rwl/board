
import 'dart:html';
import 'package:dgraph/swing/swing.dart';
import 'package:dgraph/view/view.dart';


main()  {

  final container = document.querySelector("#graph");

  Graph graph = new Graph(container);

//  new Rubberband(graph);

  Object parent = graph.getDefaultParent();

  graph.getModel().beginUpdate();
  try
  {
      Object v1 = graph.insertVertex(parent, null, "Hello", 20, 20, 80,
              30);
      Object v2 = graph.insertVertex(parent, null, "World!", 240, 150,
              80, 30);
      graph.insertEdge(parent, null, "Edge", v1, v2);
  }
  finally
  {
      graph.getModel().endUpdate();
  }

//  GraphComponent graphComponent = new GraphComponent(graph);
//  getContentPane().add(graphComponent);

}
