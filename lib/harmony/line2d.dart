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
/**
 * @author Denis M. Kishenko
 */
part of graph.harmony;

//import java.awt.Rectangle;
//import java.awt.Shape;
//import java.util.NoSuchElementException;
//
//import org.apache.harmony.awt.internal.nls.Messages;

class Line2D {//implements Shape, Cloneable {

  double x1;
  double y1;
  double x2;
  double y2;

  Line2D(double x1, double y1, double x2, double y2) {
      setLine(x1, y1, x2, y2);
  }

  factory Line2D.between(Point p1, Point p2) {
      return new Line2D(p1.getX(), p1.getY(), p2.getX(), p2.getY());
  }

  double getX1() {
      return x1;
  }

  double getY1() {
      return y1;
  }

  double getX2() {
      return x2;
  }

  double getY2() {
      return y2;
  }

  Point getP1() {
      return new Point(x1, y1);
  }

  Point getP2() {
      return new Point(x2, y2);
  }

  void setLine(double x1, double y1, double x2, double y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
  }

  Rectangle getBounds2D() {
      double rx, ry, rw, rh;
      if (x1 < x2) {
          rx = x1;
          rw = x2 - x1;
      } else {
          rx = x2;
          rw = x1 - x2;
      }
      if (y1 < y2) {
          ry = y1;
          rh = y2 - y1;
      } else {
          ry = y2;
          rh = y1 - y2;
      }
      return new Rectangle(rx, ry, rw, rh);
        }

    void setLineBetween(Point p1, Point p2) {
        setLine(p1.getX(), p1.getY(), p2.getX(), p2.getY());
    }

    void setLineFrom(Line2D line) {
        setLine(line.getX1(), line.getY1(), line.getX2(), line.getY2());
    }

    Rectangle getBounds() {
        return getBounds2D().getBounds();
    }

    static int relativeCCW(double x1, double y1, double x2, double y2, double px, double py) {
        /*
         * A = (x2-x1, y2-y1) P = (px-x1, py-y1)
         */
        x2 -= x1;
        y2 -= y1;
        px -= x1;
        py -= y1;
        double t = px * y2 - py * x2; // PxA
        if (t == 0.0) {
            t = px * x2 + py * y2; // P*A
            if (t > 0.0) {
                px -= x2; // B-A
                py -= y2;
                t = px * x2 + py * y2; // (P-A)*A
                if (t < 0.0) {
                    t = 0.0;
                }
            }
        }

        return t < 0.0 ? -1 : (t > 0.0 ? 1 : 0);
    }

    int relativeCCW_XY(double px, double py) {
        return relativeCCW(getX1(), getY1(), getX2(), getY2(), px, py);
    }

    int relativeCCWPoint(Point p) {
        return relativeCCW(getX1(), getY1(), getX2(), getY2(), p.getX(), p.getY());
    }

    static bool linesIntersect(double x1, double y1, double x2,
            double y2, double x3, double y3, double x4, double y4)
    {
        /*
         * A = (x2-x1, y2-y1) B = (x3-x1, y3-y1) C = (x4-x1, y4-y1) D = (x4-x3,
         * y4-y3) = C-B E = (x1-x3, y1-y3) = -B F = (x2-x3, y2-y3) = A-B
         *
         * Result is ((AxB) * (AxC) <=0) and ((DxE) * (DxF) <= 0)
         *
         * DxE = (C-B)x(-B) = BxB-CxB = BxC DxF = (C-B)x(A-B) = CxA-CxB-BxA+BxB =
         * AxB+BxC-AxC
         */

        x2 -= x1; // A
        y2 -= y1;
        x3 -= x1; // B
        y3 -= y1;
        x4 -= x1; // C
        y4 -= y1;

        double AvB = x2 * y3 - x3 * y2;
        double AvC = x2 * y4 - x4 * y2;

        // Online
        if (AvB == 0.0 && AvC == 0.0) {
            if (x2 != 0.0) {
                return
                    (x4 * x3 <= 0.0) ||
                    ((x3 * x2 >= 0.0) &&
                     (x2 > 0.0 ? x3 <= x2 || x4 <= x2 : x3 >= x2 || x4 >= x2));
            }
            if (y2 != 0.0) {
                return
                    (y4 * y3 <= 0.0) ||
                    ((y3 * y2 >= 0.0) &&
                     (y2 > 0.0 ? y3 <= y2 || y4 <= y2 : y3 >= y2 || y4 >= y2));
            }
            return false;
        }

        double BvC = x3 * y4 - x4 * y3;

        return (AvB * AvC <= 0.0) && (BvC * (AvB + BvC - AvC) <= 0.0);
    }

    bool intersectsLineBetween(double x1, double y1, double x2, double y2) {
        return linesIntersect(x1, y1, x2, y2, getX1(), getY1(), getX2(), getY2());
    }

    bool intersectsLine(Line2D l) {
        return linesIntersect(l.getX1(), l.getY1(), l.getX2(), l.getY2(), getX1(), getY1(), getX2(), getY2());
    }

    static double _ptSegDistSq(double x1, double y1, double x2, double y2, double px, double py) {
        /*
         * A = (x2 - x1, y2 - y1) P = (px - x1, py - y1)
         */
        x2 -= x1; // A = (x2, y2)
        y2 -= y1;
        px -= x1; // P = (px, py)
        py -= y1;
        double dist;
        if (px * x2 + py * y2 <= 0.0) { // P*A
            dist = px * px + py * py;
        } else {
            px = x2 - px; // P = A - P = (x2 - px, y2 - py)
            py = y2 - py;
            if (px * x2 + py * y2 <= 0.0) { // P*A
                dist = px * px + py * py;
            } else {
                dist = px * y2 - py * x2;
                dist = dist * dist / (x2 * x2 + y2 * y2); // pxA/|A|
            }
        }
        if (dist < 0) {
            dist = 0.0;
        }
        return dist;
    }

    static double _ptSegDist(double x1, double y1, double x2, double y2, double px, double py) {
        return Math.sqrt(_ptSegDistSq(x1, y1, x2, y2, px, py));
    }

    double ptSegDistSq(double px, double py) {
        return _ptSegDistSq(getX1(), getY1(), getX2(), getY2(), px, py);
    }

    double ptSegDistSqPoint(Point p) {
        return _ptSegDistSq(getX1(), getY1(), getX2(), getY2(), p.getX(), p.getY());
    }

    double ptSegDist(double px, double py) {
        return _ptSegDist(getX1(), getY1(), getX2(), getY2(), px, py);
    }

    double ptSegDistPoint(Point p) {
        return _ptSegDist(getX1(), getY1(), getX2(), getY2(), p.getX(), p.getY());
    }

    static double pointLineDistSq(double x1, double y1, double x2, double y2, double px, double py) {
        x2 -= x1;
        y2 -= y1;
        px -= x1;
        py -= y1;
        double s = px * y2 - py * x2;
        return s * s / (x2 * x2 + y2 * y2);
    }

    static double pointLineDist(double x1, double y1, double x2, double y2, double px, double py) {
        return Math.sqrt(pointLineDistSq(x1, y1, x2, y2, px, py));
    }

    double ptLineDistSq(double px, double py) {
        return pointLineDistSq(getX1(), getY1(), getX2(), getY2(), px, py);
    }

    double ptLineDistSqPoint(Point p) {
        return pointLineDistSq(getX1(), getY1(), getX2(), getY2(), p.getX(), p.getY());
    }

    double ptLineDist(double px, double py) {
        return pointLineDist(getX1(), getY1(), getX2(), getY2(), px, py);
    }

    double ptLineDistPoint(Point p) {
        return pointLineDist(getX1(), getY1(), getX2(), getY2(), p.getX(), p.getY());
    }

    bool intersects(double rx, double ry, double rw, double rh) {
        return intersectsRect(new Rectangle(rx, ry, rw, rh));
    }

    bool intersectsRect(Rectangle r) {
        return r.intersectsLineBetween(getX1(), getY1(), getX2(), getY2());
    }

}