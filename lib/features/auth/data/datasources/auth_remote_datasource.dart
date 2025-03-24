import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> signIn(String email, String password);
  Future<Either<Failure, UserModel>> signUp(String email, String password, String name);
  Future<Either<Failure, UserModel>> checkAuthStatus(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<Either<Failure, UserModel>> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger().d(userCredential);

      if (userCredential.user == null) {
        return Left(Failure.authFailure('Authentication failed'));
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return Left(Failure.authFailure('User data not found'));
      }

      final userData = userDoc.data()!;

      Logger().e(userData);

      // Check if account is blocked
      if (userData['isBlocked'] == true) {
        return Left(Failure.accountBlockedFailure());
      }
      Logger().i(userData['isBlocked'] == true);
      return Right(UserModel.fromMap({
        'id': userCredential.user!.uid,
        'email': userCredential.user!.email!,
        'name': userData['name'] ?? '',
        'isBlocked': userData['isBlocked'] ?? false,
      }));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.authFailure(e.message));
    } catch (e) {
      return Left(Failure.serverFailure('Something went wrong'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Left(Failure.authFailure('Registration failed'));
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'isBlocked': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        isBlocked: false,
      ));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.authFailure(e.message));
    } catch (e) {
      Logger().e(e);
      return Left(Failure.serverFailure('Something went wrong'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Left(Failure.authFailure('User not found'));
      }

      final userData = userDoc.data()!;

      // Check if account is blocked
      if (userData['isBlocked'] == true) {
        return Left(Failure.accountBlockedFailure());
      }

      return Right(UserModel.fromMap({
        'id': userId,
        'email': userData['email'],
        'name': userData['name'] ?? '',
        'isBlocked': false,
      }));
    } catch (e) {
      return Left(Failure.serverFailure('Something went wrong'));
    }
  }
}