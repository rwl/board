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
 * @author Oleg V. Khaschansky
 */
class Color {

  /**
     * integer RGB value
     */
  int value;

  Color(int r, int g, int b, [int a = 0xFF000000]) {
    if ((r & 0xFF) != r || (g & 0xFF) != g || (b & 0xFF) != b || (a & 0xFF) != a) {
      throw new ArgumentError("parameter outside of expected range");
    }
    value = b | (g << 8) | (r << 16) | (a << 24);
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

}
