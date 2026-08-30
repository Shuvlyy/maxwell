import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

class OnboardingState
{
  final String firstName;
  final String lastName;
  final String roomNumber;
  final String password;
  final String? phone;
  final bool isLoading;

  OnboardingState({
    this.firstName = '',
    this.lastName = '',
    this.roomNumber = '',
    this.password = '',
    this.phone,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    String? firstName,
    String? lastName,
    String? roomNumber,
    String? password,
    String? phone,
    bool? isLoading,
  })
  {
    return OnboardingState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roomNumber: roomNumber ?? this.roomNumber,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isComplete()
  {
    return firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      roomNumber.isNotEmpty &&
      password.isNotEmpty;
  }
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController
{
  @override
  OnboardingState build() => OnboardingState();

  void updateFirstName(String value) => state = state.copyWith(firstName: value);
  void updateLastName(String value) => state = state.copyWith(lastName: value);
  void updateRoomNumber(String value) => state = state.copyWith(roomNumber: value);
  void updatePassword(String value) => state = state.copyWith(password: value);
  void updatePhone(String value) => state = state.copyWith(phone: value);

  Future<void> verifyActivationCode(String code) async
  {
    state = state.copyWith(isLoading: true);
    
    try {
      await ref.read(authControllerProvider.notifier).register(
        firstName: state.firstName,
        lastName: state.lastName,
        roomNumber: state.roomNumber,
        password: state.password,
        activationCode: code,
        phoneNumber: state.phone,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
