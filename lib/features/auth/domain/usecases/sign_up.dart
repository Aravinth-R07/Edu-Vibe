import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _repository;

  SignUp(this._repository);

  Future<Either<Failure, User>> call(String email, String password, String name) async {
    return await _repository.signUp(email, password, name);
  }
}