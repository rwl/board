/**
 * Copyright (c) 2010-2012, JGraph Ltd
 */
part of graph.io;

//import java.io.BufferedReader;
//import java.io.StringReader;

/**
 * Represents the different states in the parse of a file.
 */
class GDParseState {
  final _value;

  const GDParseState._internal(this._value);

  toString() => '$_value';

  static const START = const GDParseState._internal('START');
  static const NUM_NODES = const GDParseState._internal('NUM_NODES');
  static const PARSING_NODES = const GDParseState._internal('PARSING_NODES');
  static const PARSING_EDGES = const GDParseState._internal('PARSING_EDGES');
}

/**
 * Parses a GD .txt file and imports it in the given graph.<br/>
 * This class depends from the classes contained in
 * graph.io.gd.
 */
class GdCodec {

  /**
   * Map with the vertex cells added in the addNode method.
   */
  static HashMap<String, Object> _cellsMap = new HashMap<String, Object>();

  /**
   * Parses simple GD format and populate the specified graph
   * @param input GD file to be parsed
   * @param graph Graph where the parsed graph is included.
   */
  static void decode(String input, Graph graph) {
    //BufferedReader br = new BufferedReader(new StringReader(input));
    GDParseState state = GDParseState.START;
    Object parent = graph.getDefaultParent();

    graph.getModel().beginUpdate();

    try {
      //String line = br.readLine().trim();
      //while (line != null) {
      for (String line in input.split("\n")) {
        switch (state) {
          case GDParseState.START:
            if (!line.startsWith("#")) {
              state = GDParseState.NUM_NODES;
            } else {
              break;
            }
            continue;
            
          case GDParseState.NUM_NODES:
            if (!line.startsWith("#")) {
              int numVertices = int.parse(line);

              for (int i = 0; i < numVertices; i++) {
                String label = i.toString();
                Object vertex = graph.insertVertex(parent, label, label, 0.0, 0.0, 10.0, 10.0);

                _cellsMap[label] = vertex;
              }
            } else {
              state = GDParseState.PARSING_EDGES;
            }
            break;
            
          case GDParseState.PARSING_NODES:
            if (line.startsWith("# Edges")) {
              state = GDParseState.PARSING_EDGES;
            } else if (line != "") {
              List<String> items = line.split(",");
              if (items.length != 5) {
                throw new Exception("Error in parsing");
              } else {
                double x = double.parse(items[1]);
                double y = double.parse(items[2]);
                double width = double.parse(items[3]);
                double height = double.parse(items[4]);


                //Set the node name as label.
                String label = items[0];

                //Insert a new vertex in the graph
                Object vertex = graph.insertVertex(parent, label, label, x - width / 2.0, y - height / 2.0, width, height);

                _cellsMap[label] = vertex;
              }
            }
            break;

          case GDParseState.PARSING_EDGES:
            if (line != "") {
              List<String> items = line.split(" ");
              if (items.length != 2) {
                throw new Exception("Error in parsing");
              } else {
                Object source = _cellsMap[items[0]];
                Object target = _cellsMap[items[1]];

                graph.insertEdge(parent, null, "", source, target);
              }
            }
            break;
        }

        //line = br.readLine();
      }
    } on Exception catch (e, st) {
      print(st);
    } finally {
      graph.getModel().endUpdate();
    }
  }

  /**
   * Generates a GD text output with the cells in the graph.
   * The implementation only uses the cells located in the default parent.
   * @param graph Graph with the cells.
   * @return The GD document generated.
   */
  static String encode(Graph graph) {
    StringBuffer builder = new StringBuffer();

    Object parent = graph.getDefaultParent();
    List<Object> vertices = GraphModel.getChildCells(graph.getModel(), parent, true, false);

    builder.write("# Number of Nodes (0-${vertices.length - 1})");
    builder.write(vertices.length.toString());

    // TODO

    return builder.toString();
  }
}
