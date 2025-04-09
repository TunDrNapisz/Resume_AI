import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resume_screening_system/auth/auth.dart';
import 'package:resume_screening_system/firebase_options.dart';
import 'package:resume_screening_system/pages/candidate_or_recruiter.dart';
import 'package:resume_screening_system/pages/new_resume_page.dart';
import 'package:resume_screening_system/pages/recruiter_login_page.dart';
import 'package:resume_screening_system/pages/result_tracking_page.dart';
import 'package:resume_screening_system/theme/main_theme.dart';

void main() async {
  //firebase login setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: mainThemeColor,
      routes: {
        '/candidate_recruiter_page': (context) => const CandidateOrRecruiter(),
        '/new_resume_page': (context) => const NewResume(),
        '/result_tracking_page': (context) => const ResultTracking(),
        '/recruiter_login_page': (context) => const RecruiterLogin(),
      },
    );
  }
}
