import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/utils/exercise_utils.dart';

/// Service wrapping Google ML Kit Pose Detection.
class PoseDetectorService {
  late final PoseDetector _poseDetector;
  bool _isProcessing = false;
  bool _isInitialized = false;

  /// Initialize the pose detector with accurate mode for fitness tracking.
  void initialize() {
    if (_isInitialized) return;

    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream, // Optimized for real-time video
      model: PoseDetectionModel.accurate, // Full 33-landmark model (same as MediaPipe BlazePose)
    );

    _poseDetector = PoseDetector(options: options);
    _isInitialized = true;
  }

  /// Process a single camera frame and return detected poses.
  /// Returns null if already processing (frame drop to avoid backpressure).
  Future<List<Pose>?> processImage(InputImage inputImage) async {
    if (!_isInitialized) return null;
    if (_isProcessing) return null; // Drop frame

    _isProcessing = true;
    try {
      final poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      // Silently handle processing errors (camera frame may be invalid)
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Convert ML Kit Pose landmarks to our Point3D format for exercise logic.
  static List<Point3D> poseLandmarksToPoints(Pose pose) {
    final points = <Point3D>[];

    // ML Kit provides landmarks indexed 0-32, same as MediaPipe BlazePose
    for (int i = 0; i < 33; i++) {
      final landmarkType = PoseLandmarkType.values[i];
      final landmark = pose.landmarks[landmarkType];

      if (landmark != null) {
        points.add(Point3D(
          x: landmark.x,
          y: landmark.y,
          z: landmark.z,
          visibility: landmark.likelihood,
        ));
      } else {
        // Pad with zero-visibility point if landmark is missing
        points.add(const Point3D(x: 0, y: 0, z: 0, visibility: 0));
      }
    }

    return points;
  }

  /// Check if the model is currently processing a frame.
  bool get isProcessing => _isProcessing;

  /// Check if the detector is initialized.
  bool get isInitialized => _isInitialized;

  /// Dispose of the pose detector to free resources.
  Future<void> dispose() async {
    if (_isInitialized) {
      await _poseDetector.close();
      _isInitialized = false;
    }
  }
}
