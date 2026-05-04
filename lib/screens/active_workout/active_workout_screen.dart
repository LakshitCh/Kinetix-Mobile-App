import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../core/utils/sound_utils.dart';
import '../../services/pose/pose_detector_service.dart';
import '../../services/pose/pose_painter.dart';
import '../../services/workout/exercise_logic.dart';

/// Active Workout Screen — full integration of Camera + ML Kit + Exercise Logic.
class ActiveWorkoutScreen extends StatefulWidget {
  final String exercise;
  final int targetReps;

  const ActiveWorkoutScreen({
    super.key,
    this.exercise = 'Squats',
    this.targetReps = 10,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = -1;

  // Pose Detection
  final PoseDetectorService _poseService = PoseDetectorService();
  List<Pose> _currentPoses = [];
  Size? _imageSize;

  // Exercise Logic
  final ExerciseLogic _exerciseLogic = ExerciseLogic();
  ExerciseStats _stats = ExerciseStats.initial;

  // Session State
  bool _isActive = false;
  bool _isModelLoading = true;
  int _sessionTime = 0;
  Timer? _sessionTimer;
  int _lastRepCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _exerciseLogic.setExercise(widget.exercise);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    _cameraController?.dispose();
    _poseService.dispose();
    PremiumEffects.stopSpeech();
    SoundUtils.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle camera lifecycle
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initialize the front-facing camera.
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _isModelLoading = false);
        return;
      }

      // Prefer front camera for fitness tracking
      _cameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_cameraIndex == -1) _cameraIndex = 0;

      await _startCamera(_cameras[_cameraIndex]);
    } catch (e) {
      debugPrint('Camera init error: $e');
      setState(() => _isModelLoading = false);
    }
  }

  /// Start the camera with the given description.
  Future<void> _startCamera(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium, // Balance between quality and performance
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Required for ML Kit on Android
    );

    try {
      await _cameraController!.initialize();

      // Initialize pose detector
      _poseService.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isModelLoading = false;
        });

        PremiumEffects.speakFeedback(
          'Starting ${widget.exercise.replaceAll('-', ' ')}. Align your body in the frame.',
        );
      }
    } catch (e) {
      debugPrint('Camera start error: $e');
      if (mounted) {
        setState(() => _isModelLoading = false);
      }
    }
  }

  /// Start the image stream for real-time pose detection.
  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((CameraImage image) {
      if (!_isActive) return;

      _processFrame(image);
    });
  }

  /// Stop the image stream.
  void _stopImageStream() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
  }

  /// Process a single camera frame through ML Kit.
  Future<void> _processFrame(CameraImage image) async {
    final camera = _cameras[_cameraIndex];

    // Build InputImage from CameraImage
    final inputImage = _buildInputImage(image, camera);
    if (inputImage == null) return;

    // Store image dimensions for painter scaling
    _imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Run pose detection
    final poses = await _poseService.processImage(inputImage);
    if (poses == null || poses.isEmpty) {
      if (mounted) {
        setState(() => _currentPoses = []);
      }
      return;
    }

    // Convert ML Kit landmarks → our Point3D format → exercise logic
    final landmarks = PoseDetectorService.poseLandmarksToPoints(poses.first);
    final newStats = _exerciseLogic.processFrame(landmarks, widget.exercise);

    // Check for new rep → trigger haptic + sound
    if (newStats.repCount > _lastRepCount) {
      PremiumEffects.triggerHaptic('success');
      SoundUtils.playSuccessSound();

      // Voice coaching every 5 reps
      if (newStats.repCount % 5 == 0) {
        PremiumEffects.speakFeedback('${newStats.repCount} reps. Keep going.');
      }

      // Check if target reached
      if (newStats.repCount >= widget.targetReps) {
        PremiumEffects.speakFeedback('Target reached! Great workout.');
        _handleEndWorkout();
        return;
      }

      _lastRepCount = newStats.repCount;
    }

    if (mounted) {
      setState(() {
        _currentPoses = poses;
        _stats = newStats;
      });
    }
  }

  /// Build an InputImage from a CameraImage for ML Kit processing.
  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // NV21 only has one plane
    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Toggle active state (play/pause).
  void _toggleActive() {
    PremiumEffects.triggerHaptic('medium');
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        PremiumEffects.speakFeedback('Resuming.');
        _startImageStream();
        _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _sessionTime++);
        });
      } else {
        PremiumEffects.speakFeedback('Paused.');
        _stopImageStream();
        _sessionTimer?.cancel();
      }
    });
  }

  /// End the workout and navigate to summary.
  void _handleEndWorkout() {
    PremiumEffects.triggerHaptic('heavy');
    PremiumEffects.speakFeedback('Workout ended. Great job.');
    _stopImageStream();
    _sessionTimer?.cancel();
    context.go(
      '/summary',
      extra: {
        'reps': _stats.repCount,
        'time': _sessionTime,
        'exercise': widget.exercise,
      },
    );
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════
          //  CAMERA PREVIEW & POSE SKELETON
          // ═══════════════════════════════════════════
          if (_isCameraInitialized && _cameraController != null)
            SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? screenSize.width,
                  height: _cameraController!.value.previewSize?.width ?? screenSize.height,
                  child: Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      if (_currentPoses.isNotEmpty && _imageSize != null)
                        CustomPaint(
                          size: Size(
                            _cameraController!.value.previewSize?.height ?? screenSize.width,
                            _cameraController!.value.previewSize?.width ?? screenSize.height,
                          ),
                          painter: PosePainter(
                            poses: _currentPoses,
                            imageSize: _imageSize!,
                            rotation: InputImageRotation.rotation0deg,
                            cameraLensDirection: _cameras.isNotEmpty
                                ? _cameras[_cameraIndex].lensDirection
                                : CameraLensDirection.front,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1A1A1A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_outlined, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                    const SizedBox(height: 16),
                    Text(
                      _cameras.isEmpty ? 'No camera available' : 'Initializing camera...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  LOADING OVERLAY
          // ═══════════════════════════════════════════
          if (_isModelLoading)
            Container(
              color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48, height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Warming up tracker...',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calibrating AI pose detection',
                      style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  ALIGNMENT SILHOUETTE (when paused)
          // ═══════════════════════════════════════════
          if (!_isActive && !_isModelLoading && _currentPoses.isEmpty)
            Center(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  size: Size(screenSize.width * 0.6, screenSize.height * 0.6),
                  painter: _BodySilhouettePainter(),
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  TOP GRADIENT
          // ═══════════════════════════════════════════
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 128,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  HEADER — Back + Exercise Label
          // ═══════════════════════════════════════════
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    PremiumEffects.triggerHaptic('light');
                    _stopImageStream();
                    context.pop();
                  },
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.chevron_left, size: 24, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      if (_isActive)
                        Container(
                          width: 10, height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 10)],
                          ),
                        ),
                      Text(
                        widget.exercise.replaceAll('-', ' '),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          //  PROGRESS BARS (when active)
          // ═══════════════════════════════════════════
          if (_isActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 20, right: 20,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_stats.repCount}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            TextSpan(
                              text: ' / ${widget.targetReps} Reps',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(_sessionTime),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Overall progress bar
                  _ProgressBar(
                    progress: (_stats.repCount / widget.targetReps).clamp(0.0, 1.0),
                    height: 8,
                    color: AppColors.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),
                  // In-rep progress bar
                  _ProgressBar(
                    progress: _stats.progress,
                    height: 6,
                    color: AppColors.secondary,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),

          // ═══════════════════════════════════════════
          //  ANGLE DEBUG (when active, top-right)
          // ═══════════════════════════════════════════
          if (_isActive && _stats.debugAngle > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_stats.debugAngle.round()}°',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonCyan, fontFamily: 'monospace'),
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  VISIBILITY WARNING
          // ═══════════════════════════════════════════
          if (_stats.visibilityWarning != null && _isActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _stats.visibilityWarning!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  CENTER FEEDBACK OVERLAY
          // ═══════════════════════════════════════════
          Positioned(
            top: screenSize.height * 0.5 - 40,
            left: 24, right: 24,
            child: Center(
              child: _isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: _stats.feedback.contains('Good') ||
                                _stats.feedback.contains('Great') ||
                                _stats.feedback.contains('Solid') ||
                                _stats.feedback.contains('Strong') ||
                                _stats.feedback.contains('Rep')
                            ? AppColors.secondary.withValues(alpha: 0.85)
                            : const Color(0xFF1C1C1E).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _stats.feedback.contains('Good') ||
                                  _stats.feedback.contains('Great') ||
                                  _stats.feedback.contains('Solid') ||
                                  _stats.feedback.contains('Strong') ||
                                  _stats.feedback.contains('Rep')
                              ? AppColors.secondary
                              : Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _stats.feedback,
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 26,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : !_isModelLoading
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tap Play to Start',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
          ),

          // ═══════════════════════════════════════════
          //  PLANK TIMER (for Planks exercise only)
          // ═══════════════════════════════════════════
          if (widget.exercise == 'Planks' && _stats.timer > 0 && _isActive)
            Positioned(
              top: screenSize.height * 0.35,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatTime(_stats.timer),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonCyan,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

          // ═══════════════════════════════════════════
          //  BOTTOM GRADIENT
          // ═══════════════════════════════════════════
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 192,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  BOTTOM CONTROLS — Stop / Play / (spacer)
          // ═══════════════════════════════════════════
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // End button
                GestureDetector(
                  onTap: _handleEndWorkout,
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.stop, size: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 32),

                // Play/Pause button
                GestureDetector(
                  onTap: _isModelLoading ? null : _toggleActive,
                  child: Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: _isModelLoading
                          ? AppColors.mutedForeground
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 4,
                      ),
                      boxShadow: _isModelLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Icon(
                      _isActive ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 32),

                // Spacer button (keeps play centered)
                const SizedBox(width: 64, height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  HELPER WIDGETS
// ═══════════════════════════════════════════════════════

/// Simple animated progress bar widget.
class _ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;
  final Color backgroundColor;

  const _ProgressBar({
    required this.progress,
    required this.height,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: progress * constraints.maxWidth,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
                boxShadow: progress > 0
                    ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple body silhouette painter for alignment guide.
class _BodySilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final scale = size.height / 400;

    // Head
    canvas.drawCircle(Offset(cx, 80 * scale), 30 * scale, paint);
    // Body
    canvas.drawLine(Offset(cx, 110 * scale), Offset(cx, 250 * scale), paint);
    // Arms
    canvas.drawLine(Offset(cx - 80 * scale, 160 * scale), Offset(cx, 130 * scale), paint);
    canvas.drawLine(Offset(cx + 80 * scale, 160 * scale), Offset(cx, 130 * scale), paint);
    // Legs
    canvas.drawLine(Offset(cx, 250 * scale), Offset(cx - 50 * scale, 380 * scale), paint);
    canvas.drawLine(Offset(cx, 250 * scale), Offset(cx + 50 * scale, 380 * scale), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
