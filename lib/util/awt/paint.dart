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

//import java.awt.geom.AffineTransform;
//import java.awt.geom.Point2D;
//import java.awt.geom.Rectangle2D;
//import java.awt.image.ColorModel;
//

/**
 * @author Pavel Dolgov
 */
abstract class Transparency {

    static final int OPAQUE = 1;

    static final int BITMASK = 2;

    static final int TRANSLUCENT = 3;

    int getTransparency();

}

abstract class Paint extends Transparency {
}

class GradientPaint implements Paint {
  /**
   * The start point color
   */
  Color color1;

  /**
   * The end color point
   */
  Color color2;

  /**
   * The location of the start point
   */
  Point point1;

  /**
   * The location of the end point
   */
  Point point2;

  /**
   * The indicator of cycle filling. If TRUE filling repeated outside points
   * stripe, if FALSE solid color filling outside.
   */
  bool cyclic;

  GradientPaint(this.point1, this.color1, this.point2, this.color2, [this.cyclic = false]) {
    if (point1 == null || point2 == null) {
      throw new ArgumentError("Point is null");
    }
    if (color1 == null || color2 == null) {
      throw new ArgumentError("Point is null");
    }
  }

  factory GradientPaint.at(double x1, double y1, Color color1, double x2, double y2, Color color2, [bool cyclic=false]) {
    return new GradientPaint(new Point(x1, y1), color1, new Point(x2, y2), color2, cyclic);
  }

  /*GradientPaint(double x1, double y1, Color color1, double x2, double y2, Color color2) {
        this(x1, y1, color1, x2, y2, color2, false);
    }

    GradientPaint(Point2D point1, Color color1, Point2D point2, Color color2) {
        this(point1, color1, point2, color2, false);
    }

    PaintContext createContext(ColorModel cm, Rectangle deviceBounds,
            Rectangle2D userBounds, AffineTransform t, RenderingHints hints) {
        return new GradientPaintContext(cm, t, point1, color1, point2, color2, cyclic);
    }*/

  Color getColor1() {
    return color1;
  }

  Color getColor2() {
    return color2;
  }

  Point getPoint1() {
    return point1;
  }

  Point getPoint2() {
    return point2;
  }

  int getTransparency() {
    int a1 = color1.getAlpha();
    int a2 = color2.getAlpha();
    return (a1 == 0xFF && a2 == 0xFF) ? Transparency.OPAQUE : Transparency.TRANSLUCENT;
  }

  bool isCyclic() {
    return cyclic;
  }
}
