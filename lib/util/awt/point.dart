part of graph.harmony;
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
class Point {

    num x;
    num y;

    Point([num x=0, num y=0]) {
        setLocation(x, y);
    }

    Point.from(Point p) {
        setLocation(p.x, p.y);
    }

    bool operator ==(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj is Point) {
            Point p = obj;
            return x == p.x && y == p.y;
        }
        return false;
    }

    String toString() {
        return "Point[x=$x,y=$y]"; 
    }

    double getX() {
        return x;
    }

    double getY() {
        return y;
    }

    Point getLocation() {
        return new Point(x, y);
    }

    void setLocationAt(Point p) {
        setLocation(p.x, p.y);
    }

//    void setLocation(int x, int y) {
//        this.x = x;
//        this.y = y;
//    }

    void setLocation(num x, num y) {
        setLocation(x.round(), y.round());
    }

    void move(int x, int y) {
        setLocation(x, y);
    }

    void translate(int dx, int dy) {
        x += dx;
        y += dy;
    }

    static double _distanceSq(double x1, double y1, double x2, double y2) {
        x2 -= x1;
        y2 -= y1;
        return x2 * x2 + y2 * y2;
    }

    double distanceSq(double px, double py) {
        return Point._distanceSq(getX(), getY(), px, py);
    }

    double distanceSqFrom(Point p) {
        return Point._distanceSq(getX(), getY(), p.getX(), p.getY());
    }

    static double _distance(double x1, double y1, double x2, double y2) {
        return Math.sqrt(_distanceSq(x1, y1, x2, y2));
    }

    double distance(double px, double py) {
      return Math.sqrt(distanceSq(px, py));
    }

    double distanceFrom(Point p) {
        return Math.sqrt(distanceSqFrom(p));
    }
}