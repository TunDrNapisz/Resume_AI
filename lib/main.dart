import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resume_screening_system/auth/auth.dart';
import 'package:resume_screening_system/firebase_options.dart';
import 'package:resume_screening_system/pages/candidate_or_recruiter.dart';
import 'package:resume_screening_system/pages/new_resume_page.dart';
import 'package:resume_screening_system/pages/recruiter_login_page.dart';
import 'package:resume_screening_system/pages/result_tracking_page.dart';
import 'package:resume_screening_system/theme/main_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //firebase login setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //

  await Supabase.initialize(
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrenh0ZWRlbmNtZ21wZGtpZGtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyNzIyNTcsImV4cCI6MjA1OTg0ODI1N30.ZqQNRsuh_zrYp57ZuiPXFRf2qscw8QLm4ufpQ3xx8l4",
      url: "https://pkzxtedencmgmpdkidks.supabase.co");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthPage(),
          theme: mainThemeColor,
          routes: {
            '/candidate_recruiter_page': (context) =>
                const CandidateOrRecruiter(),
            '/new_resume_page': (context) => const NewResume(),
            '/result_tracking_page': (context) => const ResultTracking(),
            '/recruiter_login_page': (context) => const RecruiterLogin(),
          },
        );
      },
    );
  }
}
