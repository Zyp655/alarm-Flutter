import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart';

import '../../../../features/schedule/presentation/bloc/schedule_bloc.dart';
import '../../../../features/schedule/presentation/bloc/schedule_event.dart';
import '../../domain/usecases/login_usercase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.forgotPasswordUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignUpRequested>(_onSignUp);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);

    await result.fold((failure) async => emit(AuthFailure(failure)), (
      user,
    ) async {
      if (user.id != null) {
        await sl<SharedPreferences>().setInt('current_user_id', user.id!);
      }
      emit(AuthSuccess(user));
    });
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (_) => emit(AuthSuccess(null)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (_) => emit(AuthSuccess(null)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await sl<SharedPreferences>().remove('current_user_id');
    try {
      if (sl.isRegistered<ScheduleBloc>()) {
        sl<ScheduleBloc>().add(ResetSchedule());
      }
    } catch (e) {
    }
    emit(AuthInitial());
  }
}
