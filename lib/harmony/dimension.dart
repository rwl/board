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

//import java.awt.geom.Dimension2D;
//import java.io.Serializable;

//import org.apache.harmony.misc.HashCode;


class Dimension {//extends Dimension2D implements Serializable {

    num width;
    num height;

    factory Dimension.from(Dimension d) {
        return new Dimension(d.width, d.height);
    }

//    Dimension() {
//        this(0, 0);
//    }

    Dimension([num width=0, num height=0]) {
        setSize(width, height);
    }

    /*int hashCode() {
        HashCode hash = new HashCode();
        hash.append(width);
        hash.append(height);
        return hash.hashCode();
    }*/

    bool operator ==(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj is Dimension) {
            Dimension d = obj;
            return (d.width == width && d.height == height);
        }
        return false;
    }

    String toString() {
        return "Dimension[width=${width},height=${height}]";
    }

    void setSize(num width, num height) {
        this.width = width.ceil();
        this.height = height.ceil();
    }

    void setDimension(Dimension d) {
        setSize(d.width, d.height);
    }

    /*void setSize(double width, double height) {
        setSize((int)Math.ceil(width), (int)Math.ceil(height));
    }*/

    Dimension getSize() {
        return new Dimension(width, height);
    }

    num getHeight() {
        return height;
    }

    num getWidth() {
        return width;
    }

}
