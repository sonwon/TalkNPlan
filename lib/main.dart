import 'package:ai_scheduler/Calendar.dart';
import 'package:ai_scheduler/Login.dart';
import 'package:ai_scheduler/register.dart';
import 'package:flutter/material.dart';
import 'package:ai_scheduler/network.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDefault();
  return runApp(MyApp());
}

Future<void> initializeDefault() async {
  FirebaseApp app = await Firebase.initializeApp();
  print('Initialized default app $app');
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => const LoginPage(),
        '/calendar' : (context) => const CalendarPage(),
        '/register' : (context) => const RegisterPage(),
      },
    );
  }

}

