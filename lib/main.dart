import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner/screens/home_screen.dart';
import 'package:food_scanner/themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (skip on web)
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Configure global animation defaults
  Animate.defaultDuration = const Duration(milliseconds: 500);
  Animate.defaultCurve = Curves.easeOutCubic;

  // Optimize for web if needed
  if (kIsWeb) {
    // Reduce animation complexity on web
    Animate.defaultDuration = const Duration(milliseconds: 300);
    // Disable some heavy animations on web
    Animate.restartOnHotReload = false;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
