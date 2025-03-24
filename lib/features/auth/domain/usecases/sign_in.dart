import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await _repository.signIn(email, password);
  }
}