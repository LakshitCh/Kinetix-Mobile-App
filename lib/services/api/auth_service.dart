import '../../core/constants/app_config.dart';
import '../../models/user.dart';
import 'api_client.dart';

/// Authentication service — port of AuthPage.jsx fetch() calls.
class AuthService {
  /// Login user. Returns UserModel on success.
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      AppConfig.authLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final user = UserModel.fromJson(response.data);
    if (user.token != null) {
      ApiClient.setToken(user.token!);
    }
    return user;
  }

  /// Register new user. Returns UserModel on success.
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      AppConfig.authRegister,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return UserModel.fromJson(response.data);
  }

  /// Logout — clear tokens.
  static void logout() {
    ApiClient.clearToken();
  }
}
