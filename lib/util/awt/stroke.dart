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
class Stroke {

  static const String CAP_BUTT = "butt";
  static const String CAP_ROUND = "round";
  static const String CAP_SQUARE = "square";

  static const String JOIN_MITER = "miter";
  static const String JOIN_ROUND = "round";
  static const String JOIN_BEVEL = "bevel";

  /**
   * Stroke width
   */
  num width;

  /**
   * Stroke cap type
   */
  String cap;

  /**
   * Stroke join type
   */
  String join;

  /**
   * Stroke miter limit
   */
  num miterLimit;

  /**
   * Stroke dashes array
   */
  List<num> dash;

  /**
   * Stroke dash phase
   */
  num dashPhase;

  Stroke([this.width = 1.0, this.cap = CAP_SQUARE, this.join = JOIN_MITER,
      this.miterLimit = 10, this.dash = null, this.dashPhase = 0]) {
    if (width < 0.0) {
      throw new ArgumentError("Negative width");
    }
    if (cap != CAP_BUTT && cap != CAP_ROUND && cap != CAP_SQUARE) {
      throw new ArgumentError("Illegal cap");
    }
    if (join != JOIN_MITER && join != JOIN_ROUND && join != JOIN_BEVEL) {
      throw new ArgumentError("Illegal join");
    }
    if (join == JOIN_MITER && miterLimit < 1.0) {
      throw new ArgumentError("miterLimit less than 1.0");
    }
    if (dash != null) {
      if (dashPhase < 0.0) {
        throw new ArgumentError("Negative dashPhase");
      }
      if (dash.length == 0) {
        throw new ArgumentError("Zero dash length");
      }
      ZERO: {
        for (int i = 0; i < dash.length; i++) {
          if (dash[i] < 0.0) {
            throw new ArgumentError("Negative dash[$i]");
          }
          if (dash[i] > 0.0) {
            break ZERO;
          }
        }
        throw new ArgumentError("All dash lengths zero");
      }
    }
  }
  
  factory Stroke.canvas(CanvasRenderingContext2D context) {
    return new Stroke(context.lineWidth, context.lineCap, context.lineJoin,
        context.miterLimit, context.getLineDash(), context.lineDashOffset);
  }
  
  void setCanvasStroke(CanvasRenderingContext2D context) {
    context.lineWidth = width;
    context.lineCap = cap;
    context.lineJoin = join;
    context.miterLimit = miterLimit;
    context.setLineDash(dash);
    context.lineDashOffset = dashPhase;
  }
}
