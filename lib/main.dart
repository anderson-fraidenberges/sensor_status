import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_status/presentation/screens/menuScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuScreen(),      
      debugShowCheckedModeBanner: false,
    );
  }
}
