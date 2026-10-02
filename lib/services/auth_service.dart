
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _api = ApiClient.instance;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    await _api.saveToken(
      response['token'].toString(),
    );

    return User.fromJson(
      Map<String, dynamic>.from(
        response['user'],
      ),
    );
  }

  Future<User> register({
    required String name,
    required String email,
    required String telephone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'telephone': telephone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    await _api.saveToken(
      response['token'].toString(),
    );

    return User.fromJson(
      Map<String, dynamic>.from(
        response['user'],
      ),
    );
  }

  Future<User> me() async {
    final response = await _api.get('/me');

    return User.fromJson(
      Map<String, dynamic>.from(
        response['user'],
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } finally {
      await _api.clearToken();
    }
  }
}
