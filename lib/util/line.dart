/**
 * Copyright (c) 2007-2010, Gaudenz Alder, David Benson
 * Copyright (c) 2006-2010, The Apache Software Foundation.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
part of graph.util;

//import java.awt.geom.harmony.Line2D;

/**
 * Implements a line with double precision coordinates.
 */
class Line extends Point2d {
  /**
	 * 
	 */
  //	private static final long serialVersionUID = -4730972599169158546L;

  /**
	 * The end point of the line
	 */
  Point2d _endPoint;

  /**
	 * Creates a new line
	 */
  factory Line.between(Point2d startPt, Point2d endPt) {
    return new Line(startPt.getX(), startPt.getY(), endPt);
  }

  /**
	 * Creates a new line
	 */
  Line(double startPtX, double startPtY, Point2d endPt) {
    _x = startPtX;
    _y = startPtY;
    this._endPoint = endPt;
  }

  /**
	 * Returns the end point of the line.
	 * 
	 * @return Returns the end point of the line.
	 */
  Point2d getEndPoint() {
    return this._endPoint;
  }

  /**
	 * Sets the end point of the rectangle.
	 * 
	 * @param value The new end point of the line
	 */
  void setEndPoint(Point2d value) {
    this._endPoint = value;
  }

  /**
	 * Sets the start and end points.
	 */
  void setPoints(Point2d startPt, Point2d endPt) {
    this.setX(startPt.getX());
    this.setY(startPt.getY());
    this._endPoint = endPt;
  }

  /**
	 * Returns the square of the shortest distance from a point to this line.
	 * The line is considered extrapolated infinitely in both directions for 
	 * the purposes of the calculation.
	 *
	 * @param pt the point whose distance is being measured
	 * @return the square of the distance from the specified point to this line.
   *
   * @author Denis M. Kishenko
   * @see Apache Harmony
	 */
  double ptLineDistSq(Point2d pt) {
    double x1 = getX(), y1 = getY();
    double x2 = _endPoint.getX(), y2 = _endPoint.getY();
    double px = pt.getX(), py = pt.getY();

    x2 -= x1;
    y2 -= y1;
    px -= x1;
    py -= y1;
    double s = px * y2 - py * x2;
    return s * s / (x2 * x2 + y2 * y2);
  }

  /**
	 * Returns the square of the shortest distance from a point to this 
	 * line segment.
	 *
	 * @param pt the point whose distance is being measured
	 * @return the square of the distance from the specified point to this segment.
   *
   * @author Denis M. Kishenko
   * @see Apache Harmony
	 */
  double ptSegDistSq(Point2d pt) {
    double x1 = getX(), y1 = getY();
    double x2 = _endPoint.getX(), y2 = _endPoint.getY();
    double px = pt.getX(), py = pt.getY();

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
      dist = 0;
    }
    return dist;
  }

}
