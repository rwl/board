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
 * @author Oleg V. Khaschansky
 */
class Color {

  static final Color white = new Color(255, 255, 255);

  static final Color WHITE = white;

  static final Color lightGray = new Color(192, 192, 192);

  static final Color LIGHT_GRAY = lightGray;

  static final Color gray = new Color(128, 128, 128);

  static final Color GRAY = gray;

  static final Color darkGray = new Color(64, 64, 64);

  static final Color DARK_GRAY = darkGray;

  static final Color black = new Color(0, 0, 0);

  static final Color BLACK = black;

  static final Color red = new Color(255, 0, 0);

  static final Color RED = red;

  static final Color pink = new Color(255, 175, 175);

  static final Color PINK = pink;

  static final Color orange = new Color(255, 200, 0);

  static final Color ORANGE = orange;

  static final Color yellow = new Color(255, 255, 0);

  static final Color YELLOW = yellow;

  static final Color green = new Color(0, 255, 0);

  static final Color GREEN = green;

  static final Color magenta = new Color(255, 0, 255);

  static final Color MAGENTA = magenta;

  static final Color cyan = new Color(0, 255, 255);

  static final Color CYAN = cyan;

  static final Color blue = new Color(0, 0, 255);

  static final Color BLUE = blue;

  /**
   * Integer RGB value.
   */
  int value;

  Color(int r, int g, int b, [int a = 0xFF000000]) {
    if ((r & 0xFF) != r || (g & 0xFF) != g || (b & 0xFF) != b || (a & 0xFF) != a) {
      throw new ArgumentError("parameter outside of expected range");
    }
    value = b | (g << 8) | (r << 16) | (a << 24);
  }

  factory Color.rgb(int rgb) {
    final color = new Color(0, 0, 0);
    color.value = rgb | 0xFF000000;
    return color;
  }

  factory Color.double(double r, double g, double b, double a) {
    return new Color((r * 255 + 0.5) as int, (g * 255 + 0.5) as int, (b * 255 + 0.5) as int, (a * 255 + 0.5) as int);
  }
  
  //factory Color.canvasFill(CanvasRenderingContext2D context) {    
  //}

  int getRGB() {
    return value;
  }

  int getRed() {
    return (value >> 16) & 0xFF;
  }

  int getGreen() {
    return (value >> 8) & 0xFF;
  }

  int getBlue() {
    return value & 0xFF;
  }

  int getAlpha() {
    return (value >> 24) & 0xFF;
  }
  
  void setCanvasStrokeColor(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(getRed(), getGreen(), getBlue());
  }
  
  void setCanvasFillColor(CanvasRenderingContext2D context) {
    context.setFillColorRgb(getRed(), getGreen(), getBlue());
  }

}
