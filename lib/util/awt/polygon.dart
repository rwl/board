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
class Polygon implements Shape {

  List<int> xpoints, ypoints;

  //int get npoints => xpoints.length;

  void addPoint(int px, int py) {

    xpoints.add(px);
    ypoints.add(py);

    /*if (bounds != null) {
      bounds.setFrameFromDiagonal(
          Math.min(bounds.getMinX(), px),
          Math.min(bounds.getMinY(), py),
          Math.max(bounds.getMaxX(), px),
          Math.max(bounds.getMaxY(), py));
    }*/
  }

}
