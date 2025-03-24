import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository _repository;

  CheckAuthStatus(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.checkAuthStatus();
  }
}