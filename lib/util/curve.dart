/**
 * Copyright (c) 2009-2012, JGraph Ltd
 */
part of graph.util;

//import java.awt.awt.Rectangle;

class Curve {
  /**
   * A collection of arrays of curve points
   */
  Map<String, List<Point2d>> _points;

  // awt.Rectangle just completely enclosing branch and label/
  double _minXBounds = 10000000.0;

  double _maxXBounds = 0.0;

  double _minYBounds = 10000000.0;

  double _maxYBounds = 0.0;

  /**
   * An array of arrays of intervals. These intervals define the distance
   * along the edge (0 to 1) that each point lies
   */
  Map<String, List<double>> _intervals;

  /**
   * The curve lengths of the curves
   */
  Map<String, double> _curveLengths;

  /**
   * Defines the key for the central curve index
   */
  static String CORE_CURVE = "Center_curve";

  /**
   * Defines the key for the label curve index
   */
  static String LABEL_CURVE = "Label_curve";

  /**
   * Indicates that an invalid position on a curve was requested
   */
  static Line INVALID_POSITION = new Line.between(new Point2d(0.0, 0.0), new Point2d(1.0, 0.0));

  /**
   * Offset of the label curve from the curve the label curve is based on.
   * If you wish to set this value, do so directly after creation of the curve.
   * The first time the curve is used the label curve will be created with 
   * whatever value is contained in this variable. Changes to it after that point 
   * will have no effect.
   */
  double _labelBuffer = Constants.DEFAULT_LABEL_BUFFER;

  /**
   * The points this curve is drawn through. These are typically control
   * points and are at distances from each other that straight lines
   * between them do not describe a smooth curve. This class takes
   * these guiding points and creates a finer set of internal points
   * that visually appears to be a curve when linked by straight lines
   */
  List<Point2d> guidePoints = new List<Point2d>();

  /**
   * Whether or not the curve currently holds valid values
   */
  bool _valid = false;

  void setLabelBuffer(double buffer) {
    _labelBuffer = buffer;
  }

  Rect getBounds() {
    if (!_valid) {
      _createCoreCurve();
    }
    return new Rect(_minXBounds, _minYBounds, _maxXBounds - _minXBounds, _maxYBounds - _minYBounds);
  }

  //	Curve()
  //	{
  //	}

  Curve([List<Point2d> points = null]) {
    if (points == null) {
      return;
    }
    bool nullPoints = false;

    for (Point2d point in points) {
      if (point == null) {
        nullPoints = true;
        break;
      }
    }

    if (!nullPoints) {
      guidePoints = new List<Point2d>.from(points);
    }
  }

  /**
   * Calculates the index of the lower point on the segment
   * that contains the point <i>distance</i> along the 
   */
  int _getLowerIndexOfSegment(String index, double distance) {
    List<double> curveIntervals = getIntervals(index);

    if (curveIntervals == null) {
      return 0;
    }

    int numIntervals = curveIntervals.length;

    if (distance <= 0.0 || numIntervals < 3) {
      return 0;
    }

    if (distance >= 1.0) {
      return numIntervals - 2;
    }

    // Pick a starting index roughly where you expect the point
    // to be
    int testIndex = (numIntervals * distance) as int;

    if (testIndex >= numIntervals) {
      testIndex = numIntervals - 1;
    }

    // The max and min indices tested so far
    int lowerLimit = -1;
    int upperLimit = numIntervals;

    // It cannot take more than the number of intervals to find
    // the correct segment
    for (int i = 0; i < numIntervals; i++) {
      double segmentDistance = curveIntervals[testIndex];
      double multiplier = 0.5;

      if (distance < segmentDistance) {
        upperLimit = Math.min(upperLimit, testIndex);
        multiplier = -0.5;
      } else if (distance > segmentDistance) {
        lowerLimit = Math.max(lowerLimit, testIndex);
      } else {
        // Values equal
        if (testIndex == 0) {
          lowerLimit = 0;
          upperLimit = 1;
        } else {
          lowerLimit = testIndex - 1;
          upperLimit = testIndex;
        }
      }

      int indexDifference = upperLimit - lowerLimit;

      if (indexDifference == 1) {
        break;
      }

      testIndex = (testIndex + indexDifference * multiplier) as int;

      if (testIndex == lowerLimit) {
        testIndex = lowerLimit + 1;
      }

      if (testIndex == upperLimit) {
        testIndex = upperLimit - 1;
      }
    }

    if (lowerLimit != upperLimit - 1) {
      return -1;
    }

    return lowerLimit;
  }

  /**
   * Returns a unit vector parallel to the curve at the specified
   * distance along the curve. To obtain the angle the vector makes
   * with (1,0) perform Math.atan(segVectorY/segVectorX).
   * @param index the curve index specifying the curve to analyse
   * @param distance the distance from start to end of curve (0.0...1.0)
   * @return a unit vector at the specified point on the curve represented
   * 		as a line, parallel with the curve. If the distance or curve is
   * 		invalid, <code>Curve.INVALID_POSITION</code> is returned
   */
  Line getCurveParallel(String index, double distance) {
    List<Point2d> pointsCurve = getCurvePoints(index);
    List<double> curveIntervals = getIntervals(index);

    if (pointsCurve != null && pointsCurve.length > 0 && curveIntervals != null && distance >= 0.0 && distance <= 1.0) {
      // If the curve is zero length, it will only have one point
      // We can't calculate in this case
      if (pointsCurve.length == 1) {
        Point2d point = pointsCurve[0];
        return new Line(point.getX(), point.getY(), new Point2d(1.0, 0.0));
      }

      int lowerLimit = _getLowerIndexOfSegment(index, distance);
      Point2d firstPointOfSeg = pointsCurve[lowerLimit];
      double segVectorX = pointsCurve[lowerLimit + 1].getX() - firstPointOfSeg.getX();
      double segVectorY = pointsCurve[lowerLimit + 1].getY() - firstPointOfSeg.getY();
      double distanceAlongSeg = (distance - curveIntervals[lowerLimit]) / (curveIntervals[lowerLimit + 1] - curveIntervals[lowerLimit]);
      double segLength = Math.sqrt(segVectorX * segVectorX + segVectorY * segVectorY);
      double startPointX = firstPointOfSeg.getX() + segVectorX * distanceAlongSeg;
      double startPointY = firstPointOfSeg.getY() + segVectorY * distanceAlongSeg;
      Point2d endPoint = new Point2d(segVectorX / segLength, segVectorY / segLength);
      return new Line(startPointX, startPointY, endPoint);
    } else {
      return INVALID_POSITION;
    }
  }

  /**
   * Returns a section of the curve as an array of points
   * @param index the curve index specifying the curve to analyse
   * @param start the start position of the curve segment (0.0...1.0)
   * @param end the end position of the curve segment (0.0...1.0)
   * @return a sequence of point representing the curve section or null
   * 			if it cannot be calculated
   */
  List<Point2d> getCurveSection(String index, double start, double end) {
    List<Point2d> pointsCurve = getCurvePoints(index);
    List<double> curveIntervals = getIntervals(index);

    if (pointsCurve != null && pointsCurve.length > 0 && curveIntervals != null && start >= 0.0 && start <= 1.0 && end >= 0.0 && end <= 1.0) {
      // If the curve is zero length, it will only have one point
      // We can't calculate in this case
      if (pointsCurve.length == 1) {
        Point2d point = pointsCurve[0];
        return [new Point2d(point.getX(), point.getY())];
      }

      int lowerLimit = _getLowerIndexOfSegment(index, start);
      Point2d firstPointOfSeg = pointsCurve[lowerLimit];
      double segVectorX = pointsCurve[lowerLimit + 1].getX() - firstPointOfSeg.getX();
      double segVectorY = pointsCurve[lowerLimit + 1].getY() - firstPointOfSeg.getY();
      double distanceAlongSeg = (start - curveIntervals[lowerLimit]) / (curveIntervals[lowerLimit + 1] - curveIntervals[lowerLimit]);
      Point2d startPoint = new Point2d(firstPointOfSeg.getX() + segVectorX * distanceAlongSeg, firstPointOfSeg.getY() + segVectorY * distanceAlongSeg);

      List<Point2d> result = new List<Point2d>();
      result.add(startPoint);

      double current = start;
      current = curveIntervals[++lowerLimit];

      while (current <= end) {
        Point2d nextPointOfSeg = pointsCurve[lowerLimit];
        result.add(nextPointOfSeg);
        current = curveIntervals[++lowerLimit];
      }

      // Add whatever proportion of the last segment has to
      // be added to make the exactly end distance
      if (lowerLimit > 0 && lowerLimit < pointsCurve.length && end > curveIntervals[lowerLimit - 1]) {
        firstPointOfSeg = pointsCurve[lowerLimit - 1];
        segVectorX = pointsCurve[lowerLimit].getX() - firstPointOfSeg.getX();
        segVectorY = pointsCurve[lowerLimit].getY() - firstPointOfSeg.getY();
        distanceAlongSeg = (end - curveIntervals[lowerLimit - 1]) / (curveIntervals[lowerLimit] - curveIntervals[lowerLimit - 1]);
        Point2d endPoint = new Point2d(firstPointOfSeg.getX() + segVectorX * distanceAlongSeg, firstPointOfSeg.getY() + segVectorY * distanceAlongSeg);
        result.add(endPoint);
      }

      List<Point2d> resultArray = new List<Point2d>(result.length);
      return resultArray;
    } else {
      return null;
    }
  }

  /**
   * Returns whether or not the rectangle passed in hits any part of this
   * curve.
   * @param rect the rectangle to detect for a hit
   * @return whether or not the rectangle hits this curve
   */
  bool intersectsRect(awt.Rectangle rect) {
    // To save CPU, we can test if the rectangle intersects the entire
    // bounds of this curve
    if (!getBounds().getRectangle().intersects(rect)) {
      return false;
    }

    List<Point2d> pointsCurve = getCurvePoints(Curve.CORE_CURVE);

    if (pointsCurve != null && pointsCurve.length > 1) {
      Rect r = new Rect.rectangle(rect);
      // First check for any of the curve points lying within the
      // rectangle, then for any of the curve segments intersecting
      // with the rectangle sides
      for (int i = 1; i < pointsCurve.length; i++) {
        if (r.contains(pointsCurve[i].getX(), pointsCurve[i].getY()) || r.contains(pointsCurve[i - 1].getX(), pointsCurve[i - 1].getY())) {
          return true;
        }
      }

      for (int i = 1; i < pointsCurve.length; i++) {
        if (r.intersectLine(pointsCurve[i].getX(), pointsCurve[i].getY(), pointsCurve[i - 1].getX(), pointsCurve[i - 1].getY()) != null) {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Returns the point at which this curve intersects the boundary of 
   * the given rectangle, if it does so. If it does not intersect, 
   * null is returned. If it intersects multiple times, the first 
   * intersection from the start end of the curve is returned.
   * 
   * @param index the curve index specifying the curve to analyse
   * @param rect the whose boundary is to be tested for intersection
   * with this curve
   * @return the point at which this curve intersects the boundary of 
   * the given rectangle, if it does so. If it does not intersect, 
   * null is returned.
   */
  Point2d intersectsRectPerimeter(String index, Rect rect) {
    Point2d result = null;
    List<Point2d> pointsCurve = getCurvePoints(index);

    if (pointsCurve != null && pointsCurve.length > 1) {
      int crossingSeg = _intersectRectPerimeterSeg(index, rect);

      if (crossingSeg != -1) {
        result = _intersectRectPerimeterPoint(index, rect, crossingSeg);
      }
    }

    return result;
  }

  /**
   * Returns the distance from the start of the curve at which this 
   * curve intersects the boundary of the given rectangle, if it does 
   * so. If it does not intersect, -1 is returned. 
   * If it intersects multiple times, the first intersection from 
   * the start end of the curve is returned.
   * 
   * @param index the curve index specifying the curve to analyse
   * @param rect the whose boundary is to be tested for intersection
   * with this curve
   * @return the distance along the curve from the start at which
   * the intersection occurs
   */
  double intersectsRectPerimeterDist(String index, Rect rect) {
    double result = -1.0;
    List<Point2d> pointsCurve = getCurvePoints(index);
    List<double> curveIntervals = getIntervals(index);

    if (pointsCurve != null && pointsCurve.length > 1) {
      int segIndex = _intersectRectPerimeterSeg(index, rect);
      Point2d intersectPoint = null;

      if (segIndex != -1) {
        intersectPoint = _intersectRectPerimeterPoint(index, rect, segIndex);
      }

      if (intersectPoint != null) {
        double startSegX = pointsCurve[segIndex - 1].getX();
        double startSegY = pointsCurve[segIndex - 1].getY();
        double distToStartSeg = curveIntervals[segIndex - 1] * getCurveLength(index);
        double intersectOffsetX = intersectPoint.getX() - startSegX;
        double intersectOffsetY = intersectPoint.getY() - startSegY;
        double lenToIntersect = Math.sqrt(intersectOffsetX * intersectOffsetX + intersectOffsetY * intersectOffsetY);
        result = distToStartSeg + lenToIntersect;
      }
    }

    return result;
  }

  /**
   * Returns a point to move the input rectangle to, in order to
   * attempt to place the rectangle away from the curve. NOTE: Curves
   * are scaled, the input rectangle should be also.
   * @param index  the curve index specifying the curve to analyse
   * @param rect the rectangle that is to be moved
   * @param buffer the amount by which the rectangle is to be moved,
   * 			beyond the dimensions of the rect
   * @return the point to move the top left of the input rect to
   * 			, otherwise null if no point can be determined
   */
  Point2d collisionMove(String index, Rect rect, double buffer) {
    int hitSeg = _intersectRectPerimeterSeg(index, rect);

    // Could test for a second hit (the rect exit, unless the same
    // segment is entry and exit) and allow for that in movement.

    if (hitSeg == -1) {
      return null;
    } else {
      List<Point2d> pointsCurve = getCurvePoints(index);

      double x0 = pointsCurve[hitSeg - 1].getX();
      double y0 = pointsCurve[hitSeg - 1].getY();
      double x1 = pointsCurve[hitSeg].getX();
      double y1 = pointsCurve[hitSeg].getY();

      double x = rect.getX();
      double y = rect.getY();
      double width = rect.getWidth();
      double height = rect.getHeight();

      // Whether the intersection is one of the horizontal sides of the rect
      @SuppressWarnings("unused")
      bool horizIncident = false;
      Point2d hitPoint = Utils.intersection(x, y, x + width, y, x0, y0, x1, y1);

      if (hitPoint != null) {
        horizIncident = true;
      } else {
        hitPoint = Utils.intersection(x + width, y, x + width, y + height, x0, y0, x1, y1);
      }

      if (hitPoint == null) {
        hitPoint = Utils.intersection(x + width, y + height, x, y + height, x0, y0, x1, y1);

        if (hitPoint != null) {
          horizIncident = true;
        } else {
          hitPoint = Utils.intersection(x, y, x, y + height, x0, y0, x1, y1);
        }
      }

      if (hitPoint != null) {

      }

    }

    return null;
  }

  /**
   * Utility method to determine within which segment the specified rectangle
   * intersects the specified curve
   * 
   * @param index the curve index specifying the curve to analyse
   * @param rect the whose boundary is to be tested for intersection
   * with this curve
   * @return the point at which this curve intersects the boundary of 
   * the given rectangle, if it does so. If it does not intersect, 
   * -1 is returned
   */
  //	int _intersectRectPerimeterSeg(String index, Rect rect)
  //	{
  //		return _intersectRectPerimeterSeg(index, rect, 1);
  //	}

  /**
   * Utility method to determine within which segment the specified rectangle
   * intersects the specified curve. This method specifies which segment to
   * start searching at.
   * 
   * @param index the curve index specifying the curve to analyse
   * @param rect the whose boundary is to be tested for intersection
   * with this curve
   * @param startSegment the segment to start searching at. To start at the 
   * 			beginning of the curve, use 1, not 0.
   * @return the point at which this curve intersects the boundary of 
   * the given rectangle, if it does so. If it does not intersect, 
   * -1 is returned
   */
  int _intersectRectPerimeterSeg(String index, Rect rect, [int startSegment = 1]) {
    List<Point2d> pointsCurve = getCurvePoints(index);

    if (pointsCurve != null && pointsCurve.length > 1) {
      for (int i = startSegment; i < pointsCurve.length; i++) {
        if (rect.intersectLine(pointsCurve[i].getX(), pointsCurve[i].getY(), pointsCurve[i - 1].getX(), pointsCurve[i - 1].getY()) != null) {
          return i;
        }
      }
    }

    return -1;
  }

  /**
   * Returns the point at which this curve segment intersects the boundary 
   * of the given rectangle, if it does so. If it does not intersect, 
   * null is returned.
   * 
   * @param curveIndex the curve index specifying the curve to analyse
   * @param rect the whose boundary is to be tested for intersection
   * with this curve
   * @param indexSeg the segments on this curve being checked
   * @return the point at which this curve segment  intersects the boundary 
   * of the given rectangle, if it does so. If it does not intersect, 
   * null is returned.
   */
  Point2d _intersectRectPerimeterPoint(String curveIndex, Rect rect, int indexSeg) {
    Point2d result = null;
    List<Point2d> pointsCurve = getCurvePoints(curveIndex);

    if (pointsCurve != null && pointsCurve.length > 1 && indexSeg >= 0 && indexSeg < pointsCurve.length) {
      double p1X = pointsCurve[indexSeg - 1].getX();
      double p1Y = pointsCurve[indexSeg - 1].getY();
      double p2X = pointsCurve[indexSeg].getX();
      double p2Y = pointsCurve[indexSeg].getY();

      result = rect.intersectLine(p1X, p1Y, p2X, p2Y);
    }

    return result;
  }

  /**
   * Calculates the position of an absolute in terms relative
   * to this curve.
   * 
   * @param absPoint the point whose relative point is to calculated
   * @param index the index of the curve whom the relative position is to be 
   * calculated from
   * @return an Rect where the x is the distance along the curve 
   * (0 to 1), y is the orthogonal offset from the closest segment on the 
   * curve and (width, height) is an additional Cartesian offset applied
   * after the other calculations
   */
  Rect getRelativeFromAbsPoint(Point2d absPoint, String index) {
    // Work out which segment the absolute point is closest to
    List<Point2d> currentCurve = getCurvePoints(index);
    List<double> currentIntervals = getIntervals(index);
    int closestSegment = 0;
    double closestSegDistSq = 10000000.0;
    Line segment = new Line.between(currentCurve[0], currentCurve[1]);

    for (int i = 1; i < currentCurve.length; i++) {
      segment.setPoints(currentCurve[i - 1], currentCurve[i]);
      double segDistSq = segment.ptSegDistSq(absPoint);

      if (segDistSq < closestSegDistSq) {
        closestSegDistSq = segDistSq;
        closestSegment = i - 1;
      }
    }

    // Get the distance (squared) from the point to the
    // infinitely extrapolated line created by the closest
    // segment. If that value is the same as the distance
    // to the segment then an orthogonal offset from some
    // point on the line will intersect the point. If they
    // are not equal, an additional cartesian offset is
    // required
    Point2d startSegPt = currentCurve[closestSegment];
    Point2d endSegPt = currentCurve[closestSegment + 1];

    Line closestSeg = new Line.between(startSegPt, endSegPt);
    double lineDistSq = closestSeg.ptLineDistSq(absPoint);

    double orthogonalOffset = Math.sqrt(Math.min(lineDistSq, closestSegDistSq));
    double segX = endSegPt.getX() - startSegPt.getX();
    double segY = endSegPt.getY() - startSegPt.getY();
    double segDist = Math.sqrt(segX * segX + segY * segY);
    double segNormX = segX / segDist;
    double segNormY = segY / segDist;
    // The orthogonal offset could be in one of two opposite vectors
    // Try both solutions, one will be closer to one of the segment
    // end points (unless the point is on the line)
    double candidateOffX1 = (absPoint.getX() - segNormY * orthogonalOffset) - endSegPt.getX();
    double candidateOffY1 = (absPoint.getY() + segNormX * orthogonalOffset) - endSegPt.getY();
    double candidateOffX2 = (absPoint.getX() + segNormY * orthogonalOffset) - endSegPt.getX();
    double candidateOffY2 = (absPoint.getY() - segNormX * orthogonalOffset) - endSegPt.getY();

    double candidateDist1 = (candidateOffX1 * candidateOffX1) + (candidateOffY1 * candidateOffY1);
    double candidateDist2 = (candidateOffX2 * candidateOffX2) + (candidateOffY2 * candidateOffY2);

    double orthOffsetPointX = 0.0;
    double orthOffsetPointY = 0.0;

    if (candidateDist2 < candidateDist1) {
      orthogonalOffset = -orthogonalOffset;
    }

    orthOffsetPointX = absPoint.getX() - segNormY * orthogonalOffset;
    orthOffsetPointY = absPoint.getY() + segNormX * orthogonalOffset;

    double distAlongEdge = 0.0;
    double cartOffsetX = 0.0;
    double cartOffsetY = 0.0;

    // Don't compare for exact equality, there are often rounding errors
    if (math.abs(closestSegDistSq - lineDistSq) > 0.0001) {
      // The orthogonal offset does not move the point onto the
      // segment. Work out an additional cartesian offset that moves
      // the offset point onto the closest end point of the
      // segment

      // Not exact distances, but the equation holds
      double distToStartPoint = math.abs(orthOffsetPointX - startSegPt.getX()) + math.abs(orthOffsetPointY - startSegPt.getY());
      double distToEndPoint = math.abs(orthOffsetPointX - endSegPt.getX()) + math.abs(orthOffsetPointY - endSegPt.getY());
      if (distToStartPoint < distToEndPoint) {
        distAlongEdge = currentIntervals[closestSegment];
        cartOffsetX = orthOffsetPointX - startSegPt.getX();
        cartOffsetY = orthOffsetPointY - startSegPt.getY();
      } else {
        distAlongEdge = currentIntervals[closestSegment + 1];
        cartOffsetX = orthOffsetPointX - endSegPt.getX();
        cartOffsetY = orthOffsetPointY - endSegPt.getY();
      }
    } else {
      // The point, when orthogonally offset, lies on the segment
      // work out what proportion along the segment, and therefore
      // the entire curve, the offset point lies.
      double segmentLen = Math.sqrt((endSegPt.getX() - startSegPt.getX()) * (endSegPt.getX() - startSegPt.getX()) + (endSegPt.getY() - startSegPt.getY()) * (endSegPt.getY() - startSegPt.getY()));
      double offsetLen = Math.sqrt((orthOffsetPointX - startSegPt.getX()) * (orthOffsetPointX - startSegPt.getX()) + (orthOffsetPointY - startSegPt.getY()) * (orthOffsetPointY - startSegPt.getY()));
      double proportionAlongSeg = offsetLen / segmentLen;
      double segProportingDiff = currentIntervals[closestSegment + 1] - currentIntervals[closestSegment];
      distAlongEdge = currentIntervals[closestSegment] + segProportingDiff * proportionAlongSeg;
    }

    if (distAlongEdge > 1.0) {
      distAlongEdge = 1.0;
    }

    return new Rect(distAlongEdge, orthogonalOffset, cartOffsetX, cartOffsetY);
  }

  /**
   * Creates the core curve that is based on the guide points passed into
   * this class instance
   */
  void _createCoreCurve() {
    // Curve is marked invalid until all of the error situations have
    // been checked
    _valid = false;

    if (guidePoints == null || guidePoints.length == 0) {
      return;
    }

    for (int i = 0; i < guidePoints.length; i++) {
      if (guidePoints[i] == null) {
        return;
      }
    }

    // Reset the cached bounds value
    _minXBounds = _minYBounds = 10000000.0;
    _maxXBounds = _maxYBounds = 0.0;

    Spline spline = new Spline(guidePoints);

    // Need the rough length of the spline, so we can get
    // more samples for longer edges
    double lengthSpline = spline.getLength();

    // Check for errors in the spline calculation or zero length curves
    if (lengthSpline.isNaN || !spline.checkValues() || lengthSpline < 1) {
      return;
    }

    Spline1D splineX = spline.getSplineX();
    Spline1D splineY = spline.getSplineY();
    double baseInterval = 12.0 / lengthSpline;
    double minInterval = 1.0 / lengthSpline;

    // Store the last two spline positions. If the next position is
    // very close to where the extrapolation of the last two points
    // then double the interval. This diviation is terms the "flatness".
    // There is a range where the interval is kept the same, any
    // variation from this range of flatness invokes a proportional
    // adjustment to try to reenter the range without
    // over compensating
    double interval = baseInterval;
    // These deviations are only tested against either
    // dimension individually, working out the correct
    // distance is too computationally intensive
    double minDeviation = 0.15;
    double maxDeviation = 0.3;
    double preferedDeviation = (maxDeviation + minDeviation) / 2.0;

    // x1, y1 are the position two iterations ago, x2, y2
    // the position on the last iteration
    double x1 = -1.0;
    double x2 = -1.0;
    double y1 = -1.0;
    double y2 = -1.0;

    // Store the change in interval amount between iterations.
    // If it changes the extrapolation calculation must
    // take this into account.
    double intervalChange = 1.0;

    List<Point2d> coreCurve = new List<Point2d>();
    List<double> coreIntervals = new List<double>();
    bool twoLoopsComplete = false;

    for (double t = 0.0; t <= 1.5; t += interval) {
      if (t > 1.0) {
        // Use the point regardless of the accuracy,
        t = 1.0001;
        Point2d endControlPoint = guidePoints[guidePoints.length - 1];
        Point2d finalPoint = new Point2d(endControlPoint.getX(), endControlPoint.getY());
        coreCurve.add(finalPoint);
        coreIntervals.add(t);
        _updateBounds(endControlPoint.getX(), endControlPoint.getY());
        break;
      }
      // Whether or not the accuracy of the current point is acceptable
      bool currentPointAccepted = true;

      double newX = splineX.getFastValue(t);
      double newY = splineY.getFastValue(t);

      // Check if the last points are valid (indicated by
      // dissimilar values)
      // Check we're not in the first, second or last run
      if (x1 != -1.0 && twoLoopsComplete && t != 1.0001) {
        // Work out how far the new spline point
        // deviates from the extrapolation created
        // by the last two points
        double diffX = math.abs(((x2 - x1) * intervalChange + x2) - newX);
        double diffY = math.abs(((y2 - y1) * intervalChange + y2) - newY);

        // If either the x or y of the straight line
        // extrapolation from the last two points
        // is more than the 1D deviation allowed
        // go back and re-calculate with a smaller interval
        // It's possible that the edge has curved too fast
        // for the algorithmn. If the interval is
        // reduced to less than the minimum permitted
        // interval, it may be that it's impossible
        // to get within the deviation because of
        // the extrapolation overshoot. The minimum
        // interval is set to draw correctly for the
        // vast majority of cases.
        if ((diffX > maxDeviation || diffY > maxDeviation) && interval != minInterval) {
          double overshootProportion = maxDeviation / Math.max(diffX, diffY);

          if (interval * overshootProportion <= minInterval) {
            // Set the interval
            intervalChange = minInterval / interval;
          } else {
            // The interval can still be reduced, half
            // the interval and go back and redo
            // this iteration
            intervalChange = overshootProportion;
          }

          t -= interval;
          interval *= intervalChange;
          currentPointAccepted = false;
        } else if (diffX < minDeviation && diffY < minDeviation) {
          intervalChange = 1.4;
          interval *= intervalChange;
        } else {
          // Try to keep the deviation around the prefered value
          double errorRatio = preferedDeviation / Math.max(diffX, diffY);
          intervalChange = errorRatio / 4.0;
          interval *= intervalChange;
        }

        if (currentPointAccepted) {
          x1 = x2;
          y1 = y2;
          x2 = newX;
          y2 = newY;
        }
      } else if (x1 == -1.0) {
        x1 = x2 = newX;
        y1 = y2 = newY;
      } else if (x1 == x2 && y1 == y2) {
        x2 = newX;
        y2 = newY;
        twoLoopsComplete = true;
      }
      if (currentPointAccepted) {
        Point2d newPoint = new Point2d(newX, newY);
        coreCurve.add(newPoint);
        coreIntervals.add(t);
        _updateBounds(newX, newY);
      }
    }

    if (coreCurve.length < 2) {
      // A single point makes no sense, leave the curve as invalid
      return;
    }

    List<Point2d> corePoints = new List<Point2d>(coreCurve.length);
    int count = 0;

    for (Point2d point in coreCurve) {
      corePoints[count++] = point;
    }

    _points = new Map<String, List<Point2d>>();
    _curveLengths = new Map<String, double>();
    _points[CORE_CURVE] = corePoints;
    _curveLengths[CORE_CURVE] = lengthSpline;

    List<double> coreIntervalsArray = new List<double>(coreIntervals.length);
    count = 0;

    for (double tempInterval in coreIntervals) {
      coreIntervalsArray[count++] = tempInterval;
    }

    _intervals = new Map<String, List<double>>();
    _intervals[CORE_CURVE] = coreIntervalsArray;

    _valid = true;
  }

  /** Whether or not the label curve starts from the end target
   *  and traces to the start of the branch
   * @return whether the label curve is reversed
   */
  bool isLabelReversed() {
    if (_valid) {
      List<Point2d> centralCurve = getCurvePoints(CORE_CURVE);

      if (centralCurve != null) {
        double changeX = centralCurve[centralCurve.length - 1].getX() - centralCurve[0].getX();

        if (changeX < 0) {
          return true;
        }
      }
    }

    return false;
  }

  void _createLabelCurve() {
    // Place the label on the "high" side of the vector
    // joining the start and end points of the curve
    List<Point2d> currentCurve = _getBaseLabelCurve();

    bool labelReversed = isLabelReversed();

    List<Point2d> labelCurvePoints = new List<Point2d>();

    // Lower and upper curve start from the very ends
    // of their curves, so given that their middle points
    // are derived from the center of the central points
    // they will contain one more point and both
    // side curves contain the same end point

    for (int i = 1; i < currentCurve.length; i++) {
      int currentIndex = i;
      int lastIndex = i - 1;

      if (labelReversed) {
        currentIndex = currentCurve.length - i - 1;
        lastIndex = currentCurve.length - i;
      }

      Point2d segStartPoint = currentCurve[currentIndex];
      Point2d segEndPoint = currentCurve[lastIndex];
      double segVectorX = segEndPoint.getX() - segStartPoint.getX();
      double segVectorY = segEndPoint.getY() - segStartPoint.getY();
      double segVectorLength = Math.sqrt(segVectorX * segVectorX + segVectorY * segVectorY);
      double normSegVectorX = segVectorX / segVectorLength;
      double normSegVectorY = segVectorY / segVectorLength;
      double centerSegX = (segEndPoint.getX() + segStartPoint.getX()) / 2.0;
      double centerSegY = (segEndPoint.getY() + segStartPoint.getY()) / 2.0;

      if (i == 1) {
        // Special case to work out the very end points at
        // the start of the curve
        Point2d startPoint = new Point2d(segEndPoint.getX() - (normSegVectorY * _labelBuffer), segEndPoint.getY() + (normSegVectorX * _labelBuffer));
        labelCurvePoints.add(startPoint);
        _updateBounds(startPoint.getX(), startPoint.getY());
      }

      double pointX = centerSegX - (normSegVectorY * _labelBuffer);
      double pointY = centerSegY + (normSegVectorX * _labelBuffer);
      Point2d labelCurvePoint = new Point2d(pointX, pointY);
      _updateBounds(pointX, pointY);
      labelCurvePoints.add(labelCurvePoint);

      if (i == currentCurve.length - 1) {
        // Special case to work out the very end points at
        // the start of the curve
        Point2d endPoint = new Point2d(segStartPoint.getX() - (normSegVectorY * _labelBuffer), segStartPoint.getY() + (normSegVectorX * _labelBuffer));
        labelCurvePoints.add(endPoint);
        _updateBounds(endPoint.getX(), endPoint.getY());
      }
    }

//    List<Point2d> tmpPoints = new List<Point2d>(labelCurvePoints.length);
    _points[LABEL_CURVE] = labelCurvePoints;//.toArray(tmpPoints);
    _populateIntervals(LABEL_CURVE);
  }

  /**
   * Returns the curve the label curve is too be based on
   */
  List<Point2d> _getBaseLabelCurve() {
    return getCurvePoints(CORE_CURVE);
  }

  void _populateIntervals(String index) {
    List<Point2d> currentCurve = _points[index];

    List<double> newIntervals = new List<double>(currentCurve.length);

    double totalLength = 0.0;
    newIntervals[0] = 0.0;

    for (int i = 0; i < currentCurve.length - 1; i++) {
      double changeX = currentCurve[i + 1].getX() - currentCurve[i].getX();
      double changeY = currentCurve[i + 1].getY() - currentCurve[i].getY();
      double segLength = Math.sqrt(changeX * changeX + changeY * changeY);
      // We initially fill the intervals with the total distance to
      // the end of this segment then later normalize all the values
      totalLength += segLength;
      // The first index was populated before the loop (and is always 0)
      newIntervals[i + 1] = totalLength;
    }

    // Normalize the intervals
    for (int j = 0; j < newIntervals.length; j++) {
      if (j == newIntervals.length - 1) {
        // Make the final interval slightly over
        // 1.0 so any analysis to find the lower
        newIntervals[j] = 1.0001;
      } else {
        newIntervals[j] = newIntervals[j] / totalLength;
      }
    }

    _intervals[index] = newIntervals;
    _curveLengths[index] = totalLength;
  }

  /**
   * Updates the existing curve using the points passed in. 
   * @param newPoints the new guide points
   */
  void updateCurve(List<Point2d> newPoints) {
    bool pointsChanged = false;

    // If any of the new points are null, ignore the list
    for (Point2d point in newPoints) {
      if (point == null) {
        return;
      }
    }

    if (newPoints.length != guidePoints.length) {
      pointsChanged = true;
    } else {
      // Check for a constant translation of all guide points. In that
      // case apply the translation directly to all curves.
      // Also check whether all of the translations are trivial
      if (newPoints.length == guidePoints.length && newPoints.length > 1 && guidePoints.length > 1) {
        bool constantTranslation = true;
        bool trivialTranslation = true;
        Point2d newPoint0 = newPoints[0];
        Point2d oldPoint0 = guidePoints[0];
        double transX = newPoint0.getX() - oldPoint0.getX();
        double transY = newPoint0.getY() - oldPoint0.getY();

        if (math.abs(transX) > 0.01 || math.abs(transY) > 0.01) {
          trivialTranslation = false;
        }

        for (int i = 1; i < newPoints.length; i++) {
          double nextTransX = newPoints[i].getX() - guidePoints[i].getX();
          double nextTransY = newPoints[i].getY() - guidePoints[i].getY();

          if (math.abs(transX - nextTransX) > 0.01 || math.abs(transY - nextTransY) > 0.01) {
            constantTranslation = false;
          }

          if (math.abs(nextTransX) > 0.01 || math.abs(nextTransY) > 0.01) {
            trivialTranslation = false;
          }
        }

        if (trivialTranslation) {
          pointsChanged = false;
        } else if (constantTranslation) {
          pointsChanged = false;
          // Translate all stored points by the translation amounts
          Iterable<List<Point2d>> curves = _points.values;

          // Update all geometry information held by the curve
          // That is, all the curve points, the guide points
          // and the cached bounds
          for (List<Point2d> curve in curves) {
            for (int i = 0; i < curve.length; i++) {
              curve[i].setX(curve[i].getX() + transX);
              curve[i].setY(curve[i].getY() + transY);
            }
          }

          guidePoints = new List<Point2d>.from(newPoints);
          _minXBounds += transX;
          _minYBounds += transY;
          _maxXBounds += transX;
          _maxYBounds += transY;
        } else {
          pointsChanged = true;
        }
      }
    }

    if (pointsChanged) {
      guidePoints = new List<Point2d>.from(newPoints);
      _points = new Map<String, List<Point2d>>();
      _valid = false;
    }
  }

  /**
   * Obtains the points that make up the curve for the specified
   * curve index. If that curve, or the core curve that other curves
   * are based on have not yet been created, then they are lazily
   * created. If creation is impossible, null is returned
   * @param index the key specifying the curve
   * @return the points making up that curve, or null
   */
  List<Point2d> getCurvePoints(String index) {
    if (_validateCurve()) {
      if (_points[LABEL_CURVE] == null && index == LABEL_CURVE) {
        _createLabelCurve();
      }

      return _points[index];
    }

    return null;
  }

  List<double> getIntervals(String index) {
    if (_validateCurve()) {
      if (_points[LABEL_CURVE] == null && index == LABEL_CURVE) {
        _createLabelCurve();
      }

      return _intervals[index];
    }

    return null;
  }

  double getCurveLength(String index) {
    if (_validateCurve()) {
      if (_intervals[index] == null) {
        _createLabelCurve();
      }

      return _curveLengths[index];
    }

    return 0.0;
  }

  /**
   * Method must be called before any attempt to access curve information
   * @return whether or not the curve may be used
   */
  bool _validateCurve() {
    if (!_valid) {
      _createCoreCurve();
    }

    return _valid;
  }

  /**
   * Updates the total bounds of this curve, increasing any dimensions,
   * if necessary, to fit in the specified point
   */
  void _updateBounds(double pointX, double pointY) {
    _minXBounds = Math.min(_minXBounds, pointX);
    _maxXBounds = Math.max(_maxXBounds, pointX);
    _minYBounds = Math.min(_minYBounds, pointY);
    _maxYBounds = Math.max(_maxYBounds, pointY);
  }

  /**
   * @return the guidePoints
   */
  List<Point2d> getGuidePoints() {
    return guidePoints;
  }
}
