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
//import java.awt.geom.PathIterator;
//import java.awt.geom.Point2D;
//import java.awt.geom.Rectangle2D;

/**
 * @author Alexey A. Petrenko
 */
abstract class Shape {
//    bool contains(double x, double y);
//
//    bool containsRect(double x, double y, double w, double h);
//
//    bool containsPoint(Point point);
//
//    bool containsRectangle(Rectangle r);
//
//    Rectangle getBounds();
//
//    //public Rectangle2D getBounds2D();
//
//    //public PathIterator getPathIterator(AffineTransform at);
//
//    //public PathIterator getPathIterator(AffineTransform at, double flatness);
//
//    bool intersects(double x, double y, double w, double h);
//
//    bool intersectsRect(Rectangle r);
  
  draw(CanvasRenderingContext2D g);
  
  fill(CanvasRenderingContext2D g);
}