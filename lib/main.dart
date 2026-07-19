import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/patient_dashboard.dart';
import 'views/doctor_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'العيادة الذكية',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Tajawal'),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/patient-dashboard': (context) => const PatientDashboard(),
        '/doctor-dashboard': (context) => const DoctorDashboard(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
