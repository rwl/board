/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.util;

//import java.io.Serializable;

/**
 * Implements a 2-dimensional point with double precision coordinates.
 */
class Image //implements Serializable, Cloneable
{

  /**
   * 
   */
  //	private static final long serialVersionUID = 8541229679513497585L;

  /**
   * Holds the path or URL for the image.
   */
  String _src;

  /**
   * Holds the image width and height.
   */
  int _width, _height;

  /**
   * Constructs a new point at (0, 0).
   */
  Image(String src, int width, int height) {
    this._src = src;
    this._width = width;
    this._height = height;
  }

  /**
   * @return the src
   */
  String getSrc() {
    return _src;
  }

  /**
   * @param src the src to set
   */
  void setSrc(String src) {
    this._src = src;
  }

  /**
   * @return the width
   */
  int getWidth() {
    return _width;
  }

  /**
   * @param width the width to set
   */
  void setWidth(int width) {
    this._width = width;
  }

  /**
   * @return the height
   */
  int getHeight() {
    return _height;
  }

  /**
   * @param height the height to set
   */
  void setHeight(int height) {
    this._height = height;
  }

}
