import 'package:ownurtime/features/auth/domain/entities/app_user.dart';
import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithApple();
}
