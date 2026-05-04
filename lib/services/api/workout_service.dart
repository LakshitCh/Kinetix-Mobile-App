import '../../core/constants/app_config.dart';
import '../../models/workout.dart';
import 'api_client.dart';

/// Workout API service — port of workoutController.js endpoints.
class WorkoutService {
  /// Save a workout session. POST /api/workouts/save
  static Future<WorkoutModel> saveWorkout({
    required String userId,
    required String exerciseName,
    required int reps,
    int formScore = 100,
    required String duration,
  }) async {
    final response = await ApiClient.post(
      AppConfig.workoutsSave,
      data: {
        'userId': userId,
        'exerciseName': exerciseName,
        'reps': reps,
        'formScore': formScore,
        'duration': duration,
      },
    );

    return WorkoutModel.fromJson(response.data);
  }

  /// Get all workouts for a user. GET /api/workouts/:userId
  static Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    final response = await ApiClient.get(AppConfig.workoutsGet(userId));

    final List<dynamic> data = response.data;
    return data.map((json) => WorkoutModel.fromJson(json)).toList();
  }
}
