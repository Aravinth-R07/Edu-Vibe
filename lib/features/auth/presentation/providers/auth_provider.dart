import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user.dart' as app_user;
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/storage_service.dart';

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

// Provider for FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});



// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider for AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AuthLocalDataSource(storageService: storageService);
});

// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Provider for SignIn usecase
final signInProvider = Provider<SignIn>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignIn(repository);
});

// Provider for SignUp usecase
final signUpProvider = Provider<SignUp>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUp(repository);
});

// Provider for CheckAuthStatus usecase
final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatus(repository);
});

// Auth state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  accountBlocked,
  error,
}

// Auth state class
class AuthStateData {
  final AuthState state;
  final app_user.User? user;
  final String? errorMessage;

  AuthStateData({
    required this.state,
    this.user,
    this.errorMessage,
  });

  factory AuthStateData.initial() {
    return AuthStateData(state: AuthState.initial);
  }

  AuthStateData copyWith({
    AuthState? state,
    app_user.User? user,
    String? errorMessage,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthStateData> {
  final SignIn _signIn;
  final SignUp _signUp;
  final CheckAuthStatus _checkAuthStatus;
  final FirebaseFirestore _firestore;
  StreamSubscription? _userStatusSubscription;

  AuthNotifier({
    required SignIn signIn,
    required SignUp signUp,
    required CheckAuthStatus checkAuthStatus,
    required FirebaseFirestore firestore,
  })  : _signIn = signIn,
        _signUp = signUp,
        _checkAuthStatus = checkAuthStatus,
        _firestore = firestore,
        super(AuthStateData.initial());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(state: AuthState.loading);

    final result = await _checkAuthStatus();

    result.fold(
          (failure) {
        if (failure is AccountBlockedFailure) {
          state = state.copyWith(
            state: AuthState.accountBlocked,
            errorMessage: 'Your account has been blocked',
          );
        } else {
          state = state.copyWith(state: AuthState.unauthenticated);
        }
      },
          (user) {
        state = state.copyWith(
          state: AuthState.authenticated,
          user: user,
        );
        // Start listening to user status changes
        _listenToUserStatusChanges(user.id);
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(state: AuthState.loading);

    final result = await _signIn(email, password);

    result.fold(
          (failure) {
        if (failure is AccountBlockedFailure) {
          state = state.copyWith(
            state: AuthState.accountBlocked,
            errorMessage: 'Your account has been blocked',
          );
        } else {
          state = state.copyWith(
            state: AuthState.error,
            errorMessage: _mapFailureToMessage(failure),
          );
        }
      },
          (user) {
        state = state.copyWith(
          state: AuthState.authenticated,
          user: user,
        );
        // Start listening to user status changes
        _listenToUserStatusChanges(user.id);
      },
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(state: AuthState.loading);

    final result = await _signUp(email, password, name);

    result.fold(
          (failure) {
        state = state.copyWith(
          state: AuthState.error,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
          (user) {
        state = state.copyWith(
          state: AuthState.authenticated,
          user: user,
        );
        // Start listening to user status changes
        _listenToUserStatusChanges(user.id);
      },
    );
  }

  void _listenToUserStatusChanges(String userId) {
    // Cancel existing subscription if any
    _userStatusSubscription?.cancel();

    // Listen to changes in the user document
    _userStatusSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data()!;

        if (userData['isBlocked'] == true) {
          state = state.copyWith(
            state: AuthState.accountBlocked,
            errorMessage: 'Your account has been blocked',
          );
        } else if (state.state == AuthState.accountBlocked) {
          // Update user state if account was previously blocked but is now unblocked
          checkAuthStatus();
        }
      }
    });
  }

  void signOut() {
    // Cancel status subscription
    _userStatusSubscription?.cancel();

    state = state.copyWith(state: AuthState.unauthenticated);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Server error';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection';
    } else if (failure is AuthFailure) {
      return failure.message ?? 'Authentication failed';
    } else if (failure is AccountBlockedFailure) {
      return 'Your account has been blocked';
    }
    return 'Unexpected error';
  }

  @override
  void dispose() {
    _userStatusSubscription?.cancel();
    super.dispose();
  }
}

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  final signIn = ref.watch(signInProvider);
  final signUp = ref.watch(signUpProvider);
  final checkAuthStatus = ref.watch(checkAuthStatusProvider);
  final firestore = ref.watch(firestoreProvider);

  return AuthNotifier(
    signIn: signIn,
    signUp: signUp,
    checkAuthStatus: checkAuthStatus,
    firestore: firestore,
  );
});