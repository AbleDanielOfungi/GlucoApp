import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/auth.dart';
import 'bluetooth/bluetooth_home_page.dart';
import 'home.dart';
import 'option2/bluetooth1/bs.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BluetoothScreen(),
    );
  }
}
