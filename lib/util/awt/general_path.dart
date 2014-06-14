/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
part of graph.util.awt;

/**
 * @author Denis M. Kishenko
 */
class GeneralPath implements Shape {

  /**
   * The point's types buffer
   */
  List<int> types;

  /**
   * The points buffer
   */
  List<double> points;

  /**
   * The point's type buffer size
   */
  //int typeSize;
  int get typeSize => types.length;

  /**
   * The points buffer size
   */
  //int pointSize;
  int get pointSize => points.length;


  void moveTo(num x, num y) {
    if (typeSize > 0 && types[typeSize - 1] == PathIterator.SEG_MOVETO) {
      points[pointSize - 2] = x;
      points[pointSize - 1] = y;
    } else {
      types.add(PathIterator.SEG_MOVETO);
      points.add(x);
      points.add(y);
    }
  }

  void lineTo(num x, num y) {
    types.add(PathIterator.SEG_LINETO);
    points.add(x);
    points.add(y);
  }

  void quadTo(num x1, num y1, num x2, num y2) {
    types.add(PathIterator.SEG_QUADTO);
    points.add(x1);
    points.add(y1);
    points.add(x2);
    points.add(y2);
  }

  void curveTo(num x1, num y1, num x2, num y2, num x3, num y3) {
    types.add(PathIterator.SEG_CUBICTO);
    points.add(x1);
    points.add(y1);
    points.add(x2);
    points.add(y2);
    points.add(x3);
    points.add(y3);
  }

  void closePath() {
    if (typeSize == 0 || types[typeSize - 1] != PathIterator.SEG_CLOSE) {
      types.add(PathIterator.SEG_CLOSE);
    }
  }

  
  void paint(CanvasRenderingContext2D g) {
    
  }
}

class IllegalPathStateException extends Error {
  String msg;
  IllegalPathStateException(this.msg) : super();
}


abstract class PathIterator {

  //static const int WIND_EVEN_ODD = 0;
  //static const int WIND_NON_ZERO = 1;

  static const int SEG_MOVETO = 0;
  static const int SEG_LINETO = 1;
  static const int SEG_QUADTO = 2;
  static const int SEG_CUBICTO = 3;
  static const int SEG_CLOSE = 4;
}
