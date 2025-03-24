import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  const factory Failure.serverFailure([String? message]) = ServerFailure;
  const factory Failure.networkFailure() = NetworkFailure;
  const factory Failure.authFailure([String? message]) = AuthFailure;
  const factory Failure.accountBlockedFailure() = AccountBlockedFailure;

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  final String? message;

  const ServerFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class AuthFailure extends Failure {
  final String? message;

  const AuthFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

class AccountBlockedFailure extends Failure {
  const AccountBlockedFailure();
}
