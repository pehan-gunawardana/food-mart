import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCachedUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      emit(Authenticated(user));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.clearUserSession();
    emit(Unauthenticated());
  }
}
