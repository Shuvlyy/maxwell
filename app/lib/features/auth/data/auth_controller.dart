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
    final refreshToken = prefs.getString('refresh_token');
    
    if (refreshToken != null) {
      // simulate API call lol
      await Future.delayed(const Duration(milliseconds: 500));

      state = User(
        id: 'user-restored',
        username: 'restored-1234',
        firstName: 'Restored',
        lastName: 'User',
        roomNumber: '1234',
      );
    }
  }

  Future<void> login(String username, String password) async
  {
    // simulate again...
    await Future.delayed(const Duration(seconds: 1));
    
    if (password == 'password123') {
      final user = User(
        id: 'user-login',
        username: username,
        firstName: 'John',
        lastName: 'Doe',
        roomNumber: '101',
      );
      
      state = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', 'sample-refresh-token-lol');
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String roomNumber,
    required String password,
    String? phoneNumber,
  }) async {
    // again...
    await Future.delayed(const Duration(seconds: 1));
    
    // server-side username generation logic (simulated)
    final username = '${firstName.substring(0, 1).toLowerCase()}${lastName.toLowerCase().replaceAll(' ', '')}-$roomNumber';
    
    final user = User(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      firstName: firstName,
      lastName: lastName,
      roomNumber: roomNumber,
      phoneNumber: phoneNumber,
    );

    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', 'sample-refresh-token-lol');
    await prefs.setBool('has_completed_onboarding', true);
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
  }
}
