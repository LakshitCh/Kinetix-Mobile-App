import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Central local storage service for all app data.
/// Replaces backend API calls with on-device persistence.
class LocalStorageService {
  static const String _keyUserName = 'kinetix_user_name';
  static const String _keyWorkouts = 'kinetix_workouts';
  static const String _keyStreak = 'kinetix_streak';
  static const String _keyLastWorkoutDate = 'kinetix_last_workout_date';

  // ─── User ───────────────────────────────────────────

  /// Save the user's display name.
  static Future<void> saveUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name.trim());
  }

  /// Get the stored user name. Returns null if not set.
  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Check if a user session exists.
  static Future<bool> isLoggedIn() async {
    final name = await getUser();
    return name != null && name.isNotEmpty;
  }

  /// Clear all user data (logout).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyWorkouts);
    await prefs.remove(_keyStreak);
    await prefs.remove(_keyLastWorkoutDate);
  }

  // ─── Workouts ───────────────────────────────────────

  /// Save a completed workout to local history.
  static Future<void> saveWorkout({
    required String exerciseName,
    required int reps,
    required int durationSeconds,
    required int calories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    final workout = {
      'exerciseName': exerciseName,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'calories': calories,
      'timestamp': DateTime.now().toIso8601String(),
    };

    workouts.insert(0, workout); // newest first

    await prefs.setString(_keyWorkouts, jsonEncode(workouts));

    // Update streak
    await _updateStreak();
  }

  /// Get all stored workouts (newest first).
  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyWorkouts);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Get workouts for a specific date.
  static Future<List<Map<String, dynamic>>> getWorkoutsForDate(DateTime date) async {
    final workouts = await getWorkouts();
    return workouts.where((w) {
      final ts = DateTime.tryParse(w['timestamp'] ?? '');
      if (ts == null) return false;
      return ts.year == date.year && ts.month == date.month && ts.day == date.day;
    }).toList();
  }

  // ─── Aggregated Stats ──────────────────────────────

  /// Get aggregated statistics from all workouts.
  static Future<Map<String, dynamic>> getStats() async {
    final workouts = await getWorkouts();

    int totalReps = 0;
    int totalCalories = 0;
    int totalDurationSeconds = 0;
    int totalWorkouts = workouts.length;

    for (final w in workouts) {
      totalReps += (w['reps'] as int? ?? 0);
      totalCalories += (w['calories'] as int? ?? 0);
      totalDurationSeconds += (w['durationSeconds'] as int? ?? 0);
    }

    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_keyStreak) ?? 0;

    return {
      'totalReps': totalReps,
      'totalCalories': totalCalories,
      'totalDurationSeconds': totalDurationSeconds,
      'totalWorkouts': totalWorkouts,
      'streak': streak,
      'workouts': workouts,
    };
  }

  /// Get the last N workouts.
  static Future<List<Map<String, dynamic>>> getRecentWorkouts(int count) async {
    final workouts = await getWorkouts();
    return workouts.take(count).toList();
  }

  // ─── Streak Logic ──────────────────────────────────

  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_keyLastWorkoutDate);
    final today = _dateOnly(DateTime.now());

    if (lastDateStr != null) {
      final lastDate = _dateOnly(DateTime.parse(lastDateStr));
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // Same day, streak unchanged
        return;
      } else if (diff == 1) {
        // Consecutive day, increment streak
        final current = prefs.getInt(_keyStreak) ?? 0;
        await prefs.setInt(_keyStreak, current + 1);
      } else {
        // Streak broken, reset to 1
        await prefs.setInt(_keyStreak, 1);
      }
    } else {
      // First workout ever
      await prefs.setInt(_keyStreak, 1);
    }

    await prefs.setString(_keyLastWorkoutDate, today.toIso8601String());
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Format seconds into a readable string (e.g., "1h 5m" or "2m 30s").
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
