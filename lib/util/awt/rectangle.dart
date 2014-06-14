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
part of graph.util.awt;

//import java.awt.geom.Rectangle2D;
//import java.io.Serializable;

class Rectangle implements Shape {//extends Rectangle2D implements Shape, Serializable {

  static final int OUT_LEFT = 1;
  static final int OUT_TOP = 2;
  static final int OUT_RIGHT = 4;
  static final int OUT_BOTTOM = 8;

  num x;
  num y;
  num width;
  num height;

  factory Rectangle.point(Point p) {
    return new Rectangle(p.x, p.y, 0, 0);
  }

  factory Rectangle.pointDim(Point p, Dimension d) {
    return new Rectangle(p.x, p.y, d.width, d.height);
  }

  Rectangle([num x = 0, num y = 0, num width = 0, num height = 0]) {
    setBounds(x, y, width, height);
  }

  factory Rectangle.origin(int width, int height) {
    return new Rectangle(0, 0, width, height);
  }

  factory Rectangle.from(Rectangle r) {
    return new Rectangle(r.x, r.y, r.width, r.height);
  }

  factory Rectangle.dim(Dimension d) {
    return new Rectangle(0, 0, d.width, d.height);
  }

  num getX() {
    return x;
  }

  num getY() {
    return y;
  }

  num getHeight() {
    return height;
  }

  num getWidth() {
    return width;
  }

  bool isEmpty() {
    return width <= 0 || height <= 0;
  }

  Dimension getSize() {
    return new Dimension(width, height);
  }

  void setSize(int width, int height) {
    this.width = width;
    this.height = height;
  }

  void setSizeDim(Dimension d) {
    setSize(d.width, d.height);
  }

  Point getLocation() {
    return new Point(x, y);
  }

  void setLocation(int x, int y) {
    this.x = x;
    this.y = y;
  }

  void setLocationPoint(Point p) {
    setLocation(p.x, p.y);
  }

  void setRect(double x, double y, double width, double height) {
    int x1 = x.floor();
    int y1 = y.floor();
    int x2 = (x + width).ceil();
    int y2 = (y + height).ceil();
    setBounds(x1, y1, x2 - x1, y2 - y1);
  }

  void setFrame(double x, double y, double width, double height) {
    setRect(x, y, width, height);
  }

  Rectangle getBounds() {
    return new Rectangle(x, y, width, height);
  }

  /*Rectangle2D getBounds2D() {
        return getBounds();
    }*/

  void setBounds(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.height = height;
    this.width = width;
  }

  void setBoundsRect(Rectangle r) {
    setBounds(r.x, r.y, r.width, r.height);
  }

  void grow(int dx, int dy) {
    x -= dx;
    y -= dy;
    width += dx + dx;
    height += dy + dy;
  }

  void translate(int mx, int my) {
    x += mx;
    y += my;
  }

  void add(int px, int py) {
    int x1 = Math.min(x, px);
    int x2 = Math.max(x + width, px);
    int y1 = Math.min(y, py);
    int y2 = Math.max(y + height, py);
    setBounds(x1, y1, x2 - x1, y2 - y1);
  }

  void addPoint(Point p) {
    add(p.x, p.y);
  }

  void addRect(Rectangle r) {
    int x1 = Math.min(x, r.x);
    int x2 = Math.max(x + width, r.x + r.width);
    int y1 = Math.min(y, r.y);
    int y2 = Math.max(y + height, r.y + r.height);
    setBounds(x1, y1, x2 - x1, y2 - y1);
  }

  bool contains(int px, int py) {
    if (isEmpty()) {
      return false;
    }
    if (px < x || py < y) {
      return false;
    }
    px -= x;
    py -= y;
    return px < width && py < height;
  }

  bool containsPoint(Point p) {
    return contains(p.x, p.y);
  }

  bool containsRect(int rx, int ry, int rw, int rh) {
    return contains(rx, ry) && contains(rx + rw - 1, ry + rh - 1);
  }

  bool containsRectangle(Rectangle r) {
    return containsRect(r.x, r.y, r.width, r.height);
  }

  /*Rectangle2D createIntersection(Rectangle2D r) {
        if (r instanceof Rectangle) {
            return intersection((Rectangle) r);
        }
        Rectangle2D dst = new Rectangle2D.Double();
        Rectangle2D.intersect(this, r, dst);
        return dst;
    }*/

  Rectangle intersection(Rectangle r) {
    int x1 = Math.max(x, r.x);
    int y1 = Math.max(y, r.y);
    int x2 = Math.min(x + width, r.x + r.width);
    int y2 = Math.min(y + height, r.y + r.height);
    return new Rectangle(x1, y1, x2 - x1, y2 - y1);
  }

  bool intersects(Rectangle r) {
    return !intersection(r).isEmpty();
  }

  bool intersectsLineBetween(double x1, double y1, double x2, double y2) {
    double rx1 = getX();
    double ry1 = getY();
    double rx2 = rx1 + getWidth();
    double ry2 = ry1 + getHeight();
    return (rx1 <= x1 && x1 <= rx2 && ry1 <= y1 && y1 <= ry2) ||
        (rx1 <= x2 && x2 <= rx2 && ry1 <= y2 && y2 <= ry2) ||
            Line2D.LinesIntersect(rx1, ry1, rx2, ry2, x1, y1, x2, y2) ||
                Line2D.LinesIntersect(rx2, ry1, rx1, ry2, x1, y1, x2, y2);
  }

  bool intersectsLine(Line2D l) {
    return intersectsLineBetween(l.getX1(), l.getY1(), l.getX2(), l.getY2());
  }

  int outcode(double px, double py) {
    int code = 0;

    if (width <= 0) {
      code |= OUT_LEFT | OUT_RIGHT;
    } else if (px < x) {
      code |= OUT_LEFT;
    } else if (px > x + width) {
      code |= OUT_RIGHT;
    }

    if (height <= 0) {
      code |= OUT_TOP | OUT_BOTTOM;
    } else if (py < y) {
      code |= OUT_TOP;
    } else if (py > y + height) {
      code |= OUT_BOTTOM;
    }

    return code;
  }

  /*Rectangle2D createUnion(Rectangle2D r) {
        if (r instanceof Rectangle) {
            return union((Rectangle)r);
        }
        Rectangle2D dst = new Rectangle2D.Double();
        Rectangle2D.union(this, r, dst);
        return dst;
    }*/

  Rectangle union(Rectangle r) {
    Rectangle dst = new Rectangle.from(this);
    dst.addRect(r);
    return dst;
  }

  bool operator ==(Object obj) {
    if (obj == this) {
      return true;
    }
    if (obj is Rectangle) {
      Rectangle r = obj;
      return r.x == x && r.y == y && r.width == width && r.height == height;
    }
    return false;
  }

  String toString() {
    return "Rectangle[x=${x},y=${y},width=${width},height=${height}]";
  }
  
  
  void draw(CanvasRenderingContext2D g) {
    
  }
  
  void fill(CanvasRenderingContext2D g) {
    
  }

}
