import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App Indonesia',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
      // Panggil SplashScreen dengan huruf kapital awal
      home: const SplashScreen(),
    );
  }
}
