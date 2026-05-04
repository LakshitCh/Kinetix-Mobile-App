/// Workout model matching the backend Workout schema.
class WorkoutModel {
  final String? id;
  final String userId;
  final String exerciseName;
  final int reps;
  final int formScore;
  final String duration;
  final DateTime? createdAt;

  const WorkoutModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.reps,
    this.formScore = 100,
    required this.duration,
    this.createdAt,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      reps: json['reps'] ?? 0,
      formScore: json['formScore'] ?? 100,
      duration: json['duration'] ?? '0',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'reps': reps,
      'formScore': formScore,
      'duration': duration,
    };
  }
}
