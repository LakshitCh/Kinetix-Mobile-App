import '../../core/utils/exercise_utils.dart';

/// Exercise session state — mutable state for the rep counting engine.
class ExerciseState {
  int count = 0;
  String phase = 'IDLE'; // IDLE, START, PEAK
  int frames = 0;
  String feedback = 'Assume Starting Position';
  String instruction = 'Stand by for tracking';
  double progress = 0.0;
  int formQuality = 100;
  int timer = 0;
  double debugAngle = 0.0;
  String? visibilityWarning;
  DateTime? timerStart;
  bool isHolding = false;
  int movementFrames = 0;
  double? lastAngle;
  List<List<Point3D>> landmarkHistory = [];
  DateTime? startTimer;

  void reset() {
    count = 0;
    phase = 'IDLE';
    frames = 0;
    progress = 0.0;
    timerStart = null;
    isHolding = false;
    movementFrames = 0;
    lastAngle = null;
    landmarkHistory = [];
    startTimer = null;
  }
}

/// Immutable snapshot of exercise stats for the UI.
class ExerciseStats {
  final int repCount;
  final String feedback;
  final String instruction;
  final double progress;
  final int formQuality;
  final int timer;
  final double debugAngle;
  final String? visibilityWarning;
  final String phase;

  const ExerciseStats({
    required this.repCount,
    required this.feedback,
    required this.instruction,
    required this.progress,
    required this.formQuality,
    required this.timer,
    required this.debugAngle,
    this.visibilityWarning,
    required this.phase,
  });

  static const initial = ExerciseStats(
    repCount: 0,
    feedback: 'Assume Starting Position',
    instruction: 'Stand by for tracking',
    progress: 0.0,
    formQuality: 100,
    timer: 0,
    debugAngle: 0.0,
    phase: 'IDLE',
  );
}

/// Exercise rep counting state machine with joint angle analysis.
/// Handles all 13 exercises with angle-based phase detection.
class ExerciseLogic {
  final ExerciseState _state = ExerciseState();

  /// Reset the session state.
  void resetSession() {
    _state.reset();
    _state.feedback = 'Assume Starting Position';
  }

  /// Reset for a new exercise.
  void setExercise(String exercise) {
    _state.reset();
    _state.instruction = _getStartingInstruction(exercise);
    _state.feedback = 'Assume Starting Position';
  }

  /// Process a frame of landmarks. Returns updated stats snapshot.
  ExerciseStats processFrame(List<Point3D> landmarks, String activeExercise) {
    // --- Smoothing Logic ---
    _state.landmarkHistory.add(landmarks);
    if (_state.landmarkHistory.length > 5) {
      _state.landmarkHistory.removeAt(0);
    }

    final smoothedLandmarks = <Point3D>[];
    for (int i = 0; i < 33; i++) {
      double sumX = 0, sumY = 0, sumZ = 0, sumVis = 0;
      for (final frame in _state.landmarkHistory) {
        if (i < frame.length) {
          sumX += frame[i].x;
          sumY += frame[i].y;
          sumZ += frame[i].z;
          sumVis += frame[i].visibility;
        }
      }
      final count = _state.landmarkHistory.length;
      smoothedLandmarks.add(Point3D(
        x: sumX / count,
        y: sumY / count,
        z: sumZ / count,
        visibility: sumVis / count,
      ));
    }

    // --- Dynamic Joint Detection ---
    final joints = _getRequiredJoints(activeExercise, smoothedLandmarks);
    if (joints != null) {
      final rawAngle = calculateAngle(joints.p1, joints.p2, joints.p3);
      _state.debugAngle = rawAngle.roundToDouble();
      _state.visibilityWarning = null;
    } else {
      _state.visibilityWarning = 'Body Not Fully Visible';
    }

    // --- Dynamic Bio-Start (1.5s Auto-Calibration) ---
    if (_state.phase == 'IDLE') {
      final startReached = _isAtStart(activeExercise, _state.debugAngle);

      if (startReached) {
        _state.startTimer ??= DateTime.now();
        final heldTime = DateTime.now().difference(_state.startTimer!).inMilliseconds / 1000;

        if (heldTime > 1.5) {
          _state.phase = 'START';
          _state.feedback = 'System Locked';
          _state.startTimer = null;
        }
      } else {
        _state.startTimer = null;
      }

      // Fallback: Movement-based skip
      if (_state.lastAngle != null && (_state.debugAngle - _state.lastAngle!).abs() > 3) {
        _state.movementFrames++;
      } else {
        _state.movementFrames = (_state.movementFrames - 0.5).clamp(0, double.infinity).toInt();
      }
      _state.lastAngle = _state.debugAngle;

      if (_state.movementFrames > 90) {
        _state.phase = 'START';
        _state.feedback = 'Manual Override';
      }
    }

    // --- Exercise Logic Router ---
    switch (activeExercise) {
      case 'Bicep Curls':
        _handleBicepCurl(smoothedLandmarks);
        break;
      case 'Push-ups':
        _handlePushups(smoothedLandmarks);
        break;
      case 'Tricep Dips':
        _handleTricepDips(smoothedLandmarks);
        break;
      case 'Squats':
        _handleSquat(smoothedLandmarks);
        break;
      case 'Shoulder Press':
        _handleShoulderPress(smoothedLandmarks);
        break;
      case 'Lateral Raises':
        _handleLateralRaises(smoothedLandmarks);
        break;
      case 'Crunches':
        _handleCrunches(smoothedLandmarks);
        break;
      case 'Planks':
        _handlePlank(smoothedLandmarks);
        break;
      case 'Lats Pulldown':
        _handleLatsPulldown(smoothedLandmarks);
        break;
      case 'Wrist Curls':
        _handleWristCurl(smoothedLandmarks);
        break;
      case 'Chest Press':
        _handleChestPress();
        break;
      case 'Leg Press':
        _handleLegPress();
        break;
      case 'Hip Thrusts':
        _handleHipThrust();
        break;
    }

    // Timer calculation (for Planks)
    int currentTimer = 0;
    if (activeExercise == 'Planks' && _state.isHolding && _state.timerStart != null) {
      currentTimer = DateTime.now().difference(_state.timerStart!).inSeconds;
    }

    return ExerciseStats(
      repCount: _state.count,
      feedback: _state.feedback,
      instruction: _state.instruction,
      progress: _state.progress,
      formQuality: _state.formQuality,
      timer: currentTimer,
      debugAngle: _state.debugAngle,
      visibilityWarning: _state.visibilityWarning,
      phase: _state.phase,
    );
  }

  // --- HELPER: Starting Position Detector (5° Grace) ---
  bool _isAtStart(String exercise, double angle) {
    switch (exercise) {
      case 'Bicep Curls':
      case 'Squats':
        return angle > 145;
      case 'Tricep Dips':
      case 'Push-ups':
        return angle > 155;
      case 'Wrist Curls':
        return angle > 160;
      case 'Crunches':
        return angle < 50;
      default:
        return angle > 150;
    }
  }

  // --- HELPER: Starting Instructions ---
  String _getStartingInstruction(String exercise) {
    switch (exercise) {
      case 'Bicep Curls':
        return 'Straighten your arm to begin';
      case 'Squats':
        return 'Stand tall to begin';
      case 'Push-ups':
      case 'Tricep Dips':
        return 'Lock elbows at the top';
      case 'Crunches':
        return 'Lie flat on your back';
      case 'Shoulder Press':
        return 'Hands at ear level';
      case 'Lateral Raises':
        return 'Hands at your sides';
      case 'Planks':
        return 'Assume a flat bridge position';
      case 'Wrist Curls':
        return 'Flatten your hand to begin';
      default:
        return 'Assume starting position';
    }
  }

  // --- HELPER: Required Joints ---
  _JointSet? _getRequiredJoints(String exercise, List<Point3D> lm) {
    if (lm.length < 33) return null;

    switch (exercise) {
      case 'Squats':
      case 'Leg Press':
        return _JointSet(p1: lm[23], p2: lm[25], p3: lm[27]); // Hip, Knee, Ankle
      case 'Crunches':
      case 'Hip Thrusts':
        return _JointSet(p1: lm[11], p2: lm[23], p3: lm[25]); // Shoulder, Hip, Knee
      case 'Shoulder Press':
        return _JointSet(p1: lm[13], p2: lm[11], p3: lm[23]); // Elbow, Shoulder, Hip
      case 'Wrist Curls':
        return _JointSet(p1: lm[13], p2: lm[15], p3: lm[19]); // Elbow, Wrist, Index Finger
      case 'Bicep Curls':
      default:
        return _JointSet(p1: lm[11], p2: lm[13], p3: lm[15]); // Shoulder, Elbow, Wrist
    }
  }

  // --- EXERCISE HANDLERS ---

  void _handleBicepCurl(List<Point3D> lm) {
    final angle = _state.debugAngle;

    // Joint Stillness Guard: Shoulder [11] should not move significantly
    if (_state.landmarkHistory.length > 1) {
      final prevFrame = _state.landmarkHistory[_state.landmarkHistory.length - 2];
      if (prevFrame.length > 11) {
        final shoulderMovement = (lm[11].y - prevFrame[11].y).abs();
        if (shoulderMovement > 0.05) {
          _state.feedback = 'Keep Shoulder Still';
          return;
        }
      }
    }

    if (_state.phase == 'IDLE') {
      if (angle > 150) { _state.phase = 'START'; _state.feedback = 'Curl Up'; }
      return;
    }
    if (_state.phase == 'START' && angle < 40) { _state.phase = 'PEAK'; _state.feedback = 'Squeeze!'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 150) { _state.phase = 'START'; _state.count++; _state.feedback = 'Good Rep!'; _state.progress = 0; }
  }

  void _handlePushups(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle > 160) { _state.phase = 'START'; _state.feedback = 'Lower Down'; }
      return;
    }
    if (_state.phase == 'START' && angle < 90) { _state.phase = 'PEAK'; _state.feedback = 'Push Up!'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 160) { _state.phase = 'START'; _state.count++; _state.feedback = 'Great Form!'; _state.progress = 0; }
  }

  void _handleTricepDips(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle > 160) { _state.phase = 'START'; _state.feedback = 'Lower Body'; }
      return;
    }
    if (_state.phase == 'START' && angle < 90) { _state.phase = 'PEAK'; _state.feedback = 'Lock Elbows'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 160) { _state.phase = 'START'; _state.count++; _state.feedback = 'Triceps Engaged!'; _state.progress = 0; }
  }

  void _handleSquat(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle > 160) { _state.phase = 'START'; _state.feedback = 'Squat Down'; }
      return;
    }
    if (_state.phase == 'START' && angle < 90) { _state.phase = 'PEAK'; _state.feedback = 'Drive Up'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 160) { _state.phase = 'START'; _state.count++; _state.feedback = 'Strong Legs!'; _state.progress = 0; }
  }

  void _handleShoulderPress(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle < 90) { _state.phase = 'START'; _state.feedback = 'Press Up'; }
      return;
    }
    if (_state.phase == 'START' && angle > 160) { _state.phase = 'PEAK'; _state.feedback = 'Hold Top'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle < 90) { _state.phase = 'START'; _state.count++; _state.feedback = 'Boulder Shoulders!'; _state.progress = 0; }
  }

  void _handleLateralRaises(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle < 40) { _state.phase = 'START'; _state.feedback = 'Raise Arms'; }
      return;
    }
    if (_state.phase == 'START' && angle > 80) { _state.phase = 'PEAK'; _state.feedback = 'Hold Level'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle < 40) { _state.phase = 'START'; _state.count++; _state.feedback = 'Good Control!'; _state.progress = 0; }
  }

  void _handleCrunches(List<Point3D> lm) {
    final angle = _state.debugAngle;
    if (_state.phase == 'IDLE') {
      if (angle > 165) { _state.phase = 'START'; _state.feedback = 'Crunch Up'; }
      return;
    }
    if (_state.phase == 'START' && angle < 130) { _state.phase = 'PEAK'; _state.feedback = 'Squeeze Core'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 165) { _state.phase = 'START'; _state.count++; _state.feedback = 'Abs on Fire!'; _state.progress = 0; }
  }

  void _handlePlank(List<Point3D> lm) {
    final isGood = _state.debugAngle > 165 && _state.debugAngle < 195;
    if (isGood) {
      if (!_state.isHolding) {
        _state.isHolding = true;
        _state.timerStart = DateTime.now();
        _state.feedback = 'Holding Plank';
      }
    } else {
      _state.isHolding = false;
      _state.timerStart = null;
      _state.feedback = 'Align Hips';
    }
  }

  void _handleLatsPulldown(List<Point3D> lm) {
    if (_state.phase == 'IDLE' && lm[15].y < lm[0].y) { _state.phase = 'START'; _state.feedback = 'Pull Down'; }
    if (_state.phase == 'START' && lm[15].y > lm[0].y) { _state.phase = 'PEAK'; _state.feedback = 'Squeeze Lats'; }
    if (_state.phase == 'PEAK' && lm[15].y < lm[0].y) { _state.phase = 'START'; _state.count++; _state.feedback = 'Good Pull!'; }
  }

  void _handleWristCurl(List<Point3D> lm) {
    final angle = _state.debugAngle;

    // Joint Stillness Guard: Elbow [13]
    if (_state.landmarkHistory.length > 1) {
      final prevFrame = _state.landmarkHistory[_state.landmarkHistory.length - 2];
      if (prevFrame.length > 13) {
        final elbowMovement = (lm[13].y - prevFrame[13].y).abs();
        if (elbowMovement > 0.03) {
          _state.feedback = 'Keep Elbow Still';
          return;
        }
      }
    }

    if (_state.phase == 'IDLE') {
      if (angle > 170) { _state.phase = 'START'; _state.feedback = 'Curl Wrist Up'; }
      return;
    }

    _state.progress = ((170 - angle) / (170 - 140)).clamp(0.0, 1.0);

    if (_state.phase == 'START' && angle < 140) { _state.phase = 'PEAK'; _state.feedback = 'Great Flexion!'; _state.progress = 1; }
    if (_state.phase == 'PEAK' && angle > 170) { _state.phase = 'START'; _state.count++; _state.feedback = 'Solid Rep!'; _state.progress = 0; }
  }

  void _handleChestPress() {
    if (_state.phase == 'IDLE' && _state.debugAngle < 90) { _state.phase = 'START'; _state.feedback = 'Push Forward'; }
    if (_state.phase == 'START' && _state.debugAngle > 160) { _state.phase = 'PEAK'; _state.feedback = 'Squeeze'; }
    if (_state.phase == 'PEAK' && _state.debugAngle < 90) { _state.phase = 'START'; _state.count++; _state.feedback = 'Good Press!'; }
  }

  void _handleLegPress() {
    if (_state.phase == 'IDLE' && _state.debugAngle < 100) { _state.phase = 'START'; _state.feedback = 'Push Out'; }
    if (_state.phase == 'START' && _state.debugAngle > 160) { _state.phase = 'PEAK'; _state.feedback = 'Extend Legs'; }
    if (_state.phase == 'PEAK' && _state.debugAngle < 100) { _state.phase = 'START'; _state.count++; _state.feedback = 'Strong Push!'; }
  }

  void _handleHipThrust() {
    if (_state.phase == 'IDLE' && _state.debugAngle < 120) { _state.phase = 'START'; _state.feedback = 'Bridge Up'; }
    if (_state.phase == 'START' && _state.debugAngle > 170) { _state.phase = 'PEAK'; _state.feedback = 'Squeeze Glutes'; }
    if (_state.phase == 'PEAK' && _state.debugAngle < 120) { _state.phase = 'START'; _state.count++; _state.feedback = 'Good Bridge!'; }
  }
}

/// Helper class for joint triplets.
class _JointSet {
  final Point3D p1;
  final Point3D p2;
  final Point3D p3;

  const _JointSet({required this.p1, required this.p2, required this.p3});
}
