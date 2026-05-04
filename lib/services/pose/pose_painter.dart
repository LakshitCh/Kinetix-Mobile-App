import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/theme/app_colors.dart';

/// CustomPainter that draws the pose skeleton overlay on top of the camera feed.
/// Port of @mediapipe/drawing_utils drawConnectors/drawLandmarks.
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
  });

  // BlazePose connection pairs — same as MediaPipe POSE_CONNECTIONS
  static const List<List<int>> _connections = [
    [11, 12], // shoulders
    [11, 13], [13, 15], // left arm
    [12, 14], [14, 16], // right arm
    [11, 23], [12, 24], // torso
    [23, 24], // hips
    [23, 25], [25, 27], // left leg
    [24, 26], [26, 28], // right leg
    [15, 17], [15, 19], [15, 21], // left hand
    [16, 18], [16, 20], [16, 22], // right hand
    [27, 29], [27, 31], // left foot
    [28, 30], [28, 32], // right foot
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    // Connection paint — gradient from primary to secondary
    final connectionPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Landmark paint — bright dots
    final landmarkPaint = Paint()
      ..color = AppColors.neonCyan
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    // Outer glow for landmarks
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw connections
      for (final connection in _connections) {
        final start = pose.landmarks[PoseLandmarkType.values[connection[0]]];
        final end = pose.landmarks[PoseLandmarkType.values[connection[1]]];

        if (start != null && end != null) {
          if (start.likelihood > 0.5 && end.likelihood > 0.5) {
            canvas.drawLine(
              _translatePoint(start, size),
              _translatePoint(end, size),
              connectionPaint,
            );
          }
        }
      }

      // Draw landmarks
      for (final landmark in pose.landmarks.values) {
        if (landmark.likelihood > 0.5) {
          final point = _translatePoint(landmark, size);

          // Outer glow
          canvas.drawCircle(point, 8, glowPaint);
          // Inner dot
          canvas.drawCircle(point, 4, landmarkPaint);
        }
      }
    }
  }

  /// Translate a pose landmark point to canvas coordinates.
  /// Handles camera rotation and mirroring for front camera.
  Offset _translatePoint(PoseLandmark landmark, Size canvasSize) {
    double x = landmark.x;
    double y = landmark.y;

    // Scale from image coordinates to canvas coordinates
    final scaleX = canvasSize.width / imageSize.width;
    final scaleY = canvasSize.height / imageSize.height;

    // Mirror for front camera
    if (cameraLensDirection == CameraLensDirection.front) {
      x = imageSize.width - x;
    }

    return Offset(x * scaleX, y * scaleY);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}
