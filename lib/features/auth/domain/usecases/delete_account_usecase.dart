import 'package:ownurtime/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String userId) => _repository.deleteAccount(userId);
}
