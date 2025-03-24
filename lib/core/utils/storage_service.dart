import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String userBox = 'userBox';
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String themeKey = 'theme';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBox);
  }

  Future<void> saveToken(String token) async {
    final box = Hive.box(userBox);
    await box.put(tokenKey, token);
  }

  Future<void> saveUserId(String userId) async {
    final box = Hive.box(userBox);
    await box.put(userIdKey, userId);
  }

  String? getToken() {
    final box = Hive.box(userBox);
    return box.get(tokenKey);
  }

  String? getUserId() {
    final box = Hive.box(userBox);
    return box.get(userIdKey);
  }

  Future<void> clearUserData() async {
    final box = Hive.box(userBox);
    await box.delete(tokenKey);
    await box.delete(userIdKey);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final box = Hive.box(userBox);
    await box.put(themeKey, isDarkMode);
  }

  bool? getThemeMode() {
    final box = Hive.box(userBox);
    return box.get(themeKey);
  }
}