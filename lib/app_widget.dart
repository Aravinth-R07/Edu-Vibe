import 'core/common_imports.dart';


class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check auth status when app starts
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return CupertinoApp(
      title: 'MyApp',
      theme: isDarkMode
          ? const CupertinoThemeData(brightness: Brightness.dark)
          : const CupertinoThemeData(brightness: Brightness.light),
      home: _buildHomeScreen(authState),
    );
  }

  Widget _buildHomeScreen(AuthStateData authState) {
    switch (authState.state) {
      case AuthState.authenticated:
        return const HomeScreen();
      case AuthState.accountBlocked:
        return const BlockedAccountScreen();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const SignInScreen();
      case AuthState.initial:
      case AuthState.loading:
      default:
        return const SplashScreen();
    }
  }
}