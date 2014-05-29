library graph.math;

import 'dart:math';

double abs(double x) {
  return x.abs();
}

double round(double x) {
  return x.roundToDouble();
}

double ceil(double x) {
  return x.ceilToDouble();
}

double floor(double x) {
  return x.floorToDouble();
}

double toRadians(double d) {
  return d / 180.0 * PI;
}