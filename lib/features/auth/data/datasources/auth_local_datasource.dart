import '../../../../core/utils/storage_service.dart';

class AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSource({required StorageService storageService})
      : _storageService = storageService;

  Future<void> saveUserSession(String token, String userId) async {
    await _storageService.saveToken(token);
    await _storageService.saveUserId(userId);
  }

  Future<void> clearUserSession() async {
    await _storageService.clearUserData();
  }

  String? getUserId() {
    return _storageService.getUserId();
  }

  String? getToken() {
    return _storageService.getToken();
  }

  bool isLoggedIn() {
    final token = _storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}