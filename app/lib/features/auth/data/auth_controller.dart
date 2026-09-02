import 'package:dio/dio.dart';
import 'package:maxwell/core/api/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maxwell/features/auth/domain/user.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController
{
  @override
  User? build()
  {
    _init();
    return null;
  }

  Future<void> _init() async
  {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      try {
        final dio = ref.read(dioProvider);
        final response = await dio.get('/api/auth/me');

        state = User.fromJson(response.data);
      } catch (e) {
        await prefs.remove('access_token');
        state = null;
      }
    }
  }

  Future<void> login(String username, String password) async
  {
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.data['access_token']);

      await _init();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Login failed');
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String roomNumber,
    required String password,
    required String activationCode,
    String? phoneNumber,
  }) async {
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.post('/api/auth/register', data: {
        'activation_code': activationCode,
        'first_name': firstName,
        'last_name': lastName,
        'room_number': roomNumber,
        'password': password,
        'phone': phoneNumber,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.data['access_token']);
      await prefs.setBool('has_completed_onboarding', true);

      await _init();
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Connection error';
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
  }
}
