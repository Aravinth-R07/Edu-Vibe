import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      return Left(Failure.networkFailure());
    }

    final result = await _remoteDataSource.signIn(email, password);

    return result.fold(
          (failure) => Left(failure),
          (userModel) {
        // Save user session
        _localDataSource.saveUserSession(
          userModel.id, // Using UID as token for simplicity
          userModel.id,
        );
        return Right(_mapUserModelToEntity(userModel));
      },
    );
  }

  @override
  Future<Either<Failure, User>> signUp(String email, String password, String name) async {
    if (!await _networkInfo.isConnected) {
      return  Left(Failure.networkFailure());
    }

    final result = await _remoteDataSource.signUp(email, password, name);

    return result.fold(
          (failure) => Left(failure),
          (userModel) {
        // Save user session
        _localDataSource.saveUserSession(
          userModel.id, // Using UID as token for simplicity
          userModel.id,
        );
        return Right(_mapUserModelToEntity(userModel));
      },
    );
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    final userId = _localDataSource.getUserId();

    if (userId == null) {
      return  Left(Failure.authFailure('Not logged in'));
    }

    if (!await _networkInfo.isConnected) {
      return  Left(Failure.networkFailure());
    }

    final result = await _remoteDataSource.checkAuthStatus(userId);

    return result.fold(
          (failure) {
        if (failure is AccountBlockedFailure) {
          // Clear session if account is blocked
          _localDataSource.clearUserSession();
        }
        return Left(failure);
      },
          (userModel) => Right(_mapUserModelToEntity(userModel)),
    );
  }

  @override
  Future<void> signOut() async {
    await _localDataSource.clearUserSession();
  }

  @override
  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  // Helper method to map UserModel to User entity
  User _mapUserModelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      isBlocked: model.isBlocked,
    );
  }
}