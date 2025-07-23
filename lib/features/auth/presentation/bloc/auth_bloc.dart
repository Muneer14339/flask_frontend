// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.email, event.password);

    result.fold(
          (failure) => emit(AuthFailure(message: _getFailureMessage(failure))),
          (user) => emit(AuthSuccess(user: user)),
    );
  }

  void _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await googleSignInUseCase();

    result.fold(
          (failure) => emit(AuthFailure(message: _getFailureMessage(failure))),
          (user) => emit(AuthSuccess(user: user)),
    );
  }

  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signUpUseCase(event.fullName, event.email, event.password);

    result.fold(
          (failure) => emit(AuthFailure(message: _getFailureMessage(failure))),
          (user) => emit(AuthSuccess(user: user)),
    );
  }

  void _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
          (failure) => emit(AuthFailure(message: _getFailureMessage(failure))),
          (success) => emit(ForgotPasswordSuccess()),
    );
  }

  void _onOtpVerificationRequested(OtpVerificationRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await verifyOtpUseCase(event.otp);

    result.fold(
          (failure) => emit(AuthFailure(message: _getFailureMessage(failure))),
          (success) => emit(OtpVerificationSuccess()),
    );
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Add sign out logic when repository is updated
    emit(AuthInitial());
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    // Add auth status check logic when repository is updated
    emit(AuthInitial());
  }

  String _getFailureMessage(failure) {
    if (failure.message != null) {
      return failure.message;
    }
    return 'An unexpected error occurred';
  }
}