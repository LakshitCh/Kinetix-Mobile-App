import 'local_config.dart';

/// Application configuration.
/// Switch between dev/prod by changing the active baseUrl.
class AppConfig {
  // --- Development ---
  static const String devBaseUrl = 'http://10.0.2.2:5000'; // Android emulator -> localhost
  static const String devBaseUrlDevice = 'http://${LocalConfig.devIP}:5000'; // Physical device (hidden)

  // --- Production ---
  static const String prodBaseUrl = 'https://your-deployed-backend.com';

  // --- Active Configuration ---
  static const bool isProduction = false;
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrlDevice;

  // API Endpoints
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String workoutsSave = '/api/workouts/save';
  static String workoutsGet(String userId) => '/api/workouts/$userId';
}
