// Theme mode provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/storage_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storageService);
});

class ThemeModeNotifier extends StateNotifier<bool> {
  final StorageService _storageService;

  ThemeModeNotifier(this._storageService) : super(false) {
    // Read the stored theme mode
    final isDarkMode = _storageService.getThemeMode();
    state = isDarkMode ?? false;
  }

  void toggleTheme() {
    state = !state;
    _storageService.saveThemeMode(state);
  }
}