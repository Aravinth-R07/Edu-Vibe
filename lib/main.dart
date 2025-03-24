import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isFirebaseConnected = false;

  try {
    await Firebase.initializeApp();
    isFirebaseConnected = true;
  } catch (e) {
    isFirebaseConnected = false;
  }

  runApp(MyApp(isFirebaseConnected: isFirebaseConnected));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseConnected;
  const MyApp({super.key, required this.isFirebaseConnected});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Connection Check',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(isFirebaseConnected: isFirebaseConnected),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final bool isFirebaseConnected;
  const MyHomePage({super.key, required this.isFirebaseConnected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Firebase Connection Status"),
      ),
      body: Center(
        child: Text(
          isFirebaseConnected ? "Connected to Firebase ✅" : "Firebase connection failed ❌",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
