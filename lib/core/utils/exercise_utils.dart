import 'dart:math';

/// Calculates the angle between three points (a, b, c).
/// b is the vertex. Returns angle in degrees.
double calculateAngle(Point3D a, Point3D b, Point3D c) {
  final radians = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
  double angle = (radians * 180.0 / pi).abs();
  if (angle > 180.0) {
    angle = 360 - angle;
  }
  return angle;
}

/// Calculates Euclidean distance between two points.
double calculateDistance(Point3D a, Point3D b) {
  return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
}

/// Returns a color on a gradient based on progress (0.0 - 1.0) using warm elegant tones.
/// Start: Gray/Muted (107, 114, 128) → End: Warm Orange/Coral (234, 88, 12)
List<int> getRepProgressColorRgb(double progress) {
  final p = progress.clamp(0.0, 1.0);
  final r = (107 + (234 - 107) * p).round();
  final g = (114 + (88 - 114) * p).round();
  final b = (128 + (12 - 128) * p).round();
  return [r, g, b];
}

/// Simple 3D point representation for pose landmarks.
class Point3D {
  final double x;
  final double y;
  final double z;
  final double visibility;

  const Point3D({
    required this.x,
    required this.y,
    this.z = 0.0,
    this.visibility = 1.0,
  });
}
