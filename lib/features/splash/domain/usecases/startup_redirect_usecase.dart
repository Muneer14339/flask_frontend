// lib/features/splash/domain/usecases/startup_redirect_usecase.dart
class StartupRedirectUsecase {
  Future<void> execute(Function onComplete) async {
    await Future.delayed(const Duration(seconds: 3));
    onComplete();
  }
}
