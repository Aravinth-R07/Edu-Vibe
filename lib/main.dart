import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/storage_service.dart';
import 'app_widget.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive storage
  final storageService = StorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Initialize StorageService globally
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Edu Vibe Logo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LogoScreen(),
//     );
//   }
// }
//
// class LogoScreen extends StatefulWidget {
//   const LogoScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LogoScreen> createState() => _LogoScreenState();
// }
//
// class _LogoScreenState extends State<LogoScreen> with TickerProviderStateMixin {
//   late AnimationController _hexagonController;
//   late AnimationController _textController;
//   late AnimationController _taglineController;
//   late AnimationController _dotController;
//
//   late Animation<double> _hexagonEnter;
//   late Animation<double> _textOpacity;
//   late Animation<double> _taglineOpacity;
//   late Animation<double> _dotOpacity;
//   late Animation<double> _dotPulse;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Hexagon animation controller
//     _hexagonController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _hexagonEnter = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 0.0, end: 1.1).chain(
//           CurveTween(curve: Curves.easeOutQuad),
//         ),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 1.1, end: 1.0).chain(
//           CurveTween(curve: Curves.easeInOut),
//         ),
//         weight: 40,
//       ),
//     ]).animate(_hexagonController);
//
//     // Text animation controller
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _textOpacity = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: _textController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Tagline animation controller
//     _taglineController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _taglineOpacity = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: _taglineController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Dot animation controller
//     _dotController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _dotOpacity = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: _taglineController,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
//       ),
//     );
//
//     _dotPulse = Tween<double>(
//       begin: 0.9,
//       end: 1.1,
//     ).animate(
//       CurvedAnimation(
//         parent: _dotController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Start animations in sequence
//     _hexagonController.forward().then((_) {
//       _textController.forward().then((_) {
//         _taglineController.forward();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _hexagonController.dispose();
//     _textController.dispose();
//     _taglineController.dispose();
//     _dotController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     // Scale everything based on screen width
//     final scale = screenWidth / 400;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Animated Hexagon Logo
//             AnimatedBuilder(
//               animation: _hexagonController,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _hexagonEnter.value * scale,
//                   child: SizedBox(
//                     width: 140,
//                     height: 140,
//                     child: CustomPaint(
//                       painter: HexagonPainter(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20 * scale),
//             // EDU VIBE Text
//             AnimatedBuilder(
//               animation: _textController,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _textOpacity.value,
//                   child: Text(
//                     'EDU VIBE',
//                     style: TextStyle(
//                       fontSize: 56 * scale,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 2 * scale,
//                       height: 1.0,
//                       color: const Color(0xFF232323),
//                       fontFamily: 'Arial',
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 8 * scale),
//             // Tagline
//             AnimatedBuilder(
//               animation: _taglineController,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _taglineOpacity.value,
//                   child: Text(
//                     'FUEL YOUR MIND, CONQUER THE TEST!',
//                     style: TextStyle(
//                       fontSize: 16 * scale,
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 0.5 * scale,
//                       color: const Color(0xFF444444),
//                       fontFamily: 'Arial',
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 40 * scale),
//             // Animated Dot
//             AnimatedBuilder(
//               animation: Listenable.merge([_taglineController, _dotController]),
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _dotOpacity.value,
//                   child: Transform.scale(
//                     scale: _dotPulse.value,
//                     child: Container(
//                       width: 12 * scale,
//                       height: 12 * scale,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF232323),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class HexagonPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final double centerX = size.width / 2;
//     final double centerY = size.height / 2;
//     final double radius = size.width / 2;
//     final double innerRadius = radius * 0.38;
//
//     List<Offset> outerPoints = [];
//     List<Offset> innerPoints = [];
//
//     for (int i = 0; i < 6; i++) {
//       double angle = (i * 60) * math.pi / 180;
//       outerPoints.add(Offset(centerX + radius * math.cos(angle), centerY + radius * math.sin(angle)));
//       innerPoints.add(Offset(centerX + innerRadius * math.cos(angle), centerY + innerRadius * math.sin(angle)));
//     }
//
//     List<Path> segments = [];
//     for (int i = 0; i < 6; i++) {
//       Path segment = Path();
//       segment.moveTo(centerX, centerY);
//       segment.lineTo(outerPoints[i].dx, outerPoints[i].dy);
//       segment.lineTo(outerPoints[(i + 1) % 6].dx, outerPoints[(i + 1) % 6].dy);
//       segment.close();
//       segments.add(segment);
//     }
//
//     final List<Paint> paints = [
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFFFFC107), Color(0xFFFF5722)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ).createShader(Rect.fromPoints(outerPoints[0], outerPoints[1])),
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFF03A9F4), Color(0xFF0277BD)],
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//         ).createShader(Rect.fromPoints(outerPoints[1], outerPoints[2])),
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
//           begin: Alignment.bottomLeft,
//           end: Alignment.topRight,
//         ).createShader(Rect.fromPoints(outerPoints[2], outerPoints[3])),
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//           begin: Alignment.bottomLeft,
//           end: Alignment.topRight,
//         ).createShader(Rect.fromPoints(outerPoints[3], outerPoints[4])),
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
//           begin: Alignment.bottomLeft,
//           end: Alignment.topRight,
//         ).createShader(Rect.fromPoints(outerPoints[4], outerPoints[5])),
//       Paint()
//         ..shader = LinearGradient(
//           colors: [Color(0xFF673AB7), Color(0xFF311B92)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ).createShader(Rect.fromPoints(outerPoints[5], outerPoints[0])),
//     ];
//
//     for (int i = 0; i < 6; i++) {
//       canvas.drawPath(segments[i], paints[i]);
//     }
//
//     Path hollowCenter = Path();
//     for (int i = 0; i < 6; i++) {
//       if (i == 0) {
//         hollowCenter.moveTo(innerPoints[i].dx, innerPoints[i].dy);
//       } else {
//         hollowCenter.lineTo(innerPoints[i].dx, innerPoints[i].dy);
//       }
//     }
//     hollowCenter.close();
//     canvas.drawPath(hollowCenter, Paint()..color = Colors.white);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

