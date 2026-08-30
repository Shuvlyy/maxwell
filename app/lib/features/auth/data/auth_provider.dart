import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/auth/domain/user.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState
{
  @override
  User? build() => null;

  void setUser(User user)
  {
    state = user;
  }

  void logout()
  {
    state = null;
  }
}
