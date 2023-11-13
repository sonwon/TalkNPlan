import 'package:ai_scheduler/Calendar.dart';
import 'package:ai_scheduler/Login.dart';
import 'package:flutter/material.dart';

void main(){
  return runApp(MyApp());
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
      },
    );
  }

}

