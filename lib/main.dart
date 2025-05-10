import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resume_screening_system/firebase_options.dart';
import 'package:resume_screening_system/pages/candidate_or_recruiter.dart';
import 'package:resume_screening_system/pages/job_details.dart';
import 'package:resume_screening_system/pages/new_resume_page.dart';
import 'package:resume_screening_system/pages/register_page.dart';
import 'package:resume_screening_system/pages/result_tracking_page.dart';
import 'package:resume_screening_system/pages/add_job.dart';
import 'package:resume_screening_system/pages/job_list.dart';
import 'package:resume_screening_system/pages/update_job.dart';
import 'package:resume_screening_system/pages/chatbot_page.dart';
import 'package:resume_screening_system/pages/recruiter_login_page.dart';
import 'package:resume_screening_system/pages/home_page.dart'; // ✅ Import HomePage
import 'package:resume_screening_system/theme/main_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    anonKey: "your_supabase_anon_key",
    url: "your_supabase_url",
  );

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
          home: const CandidateOrRecruiter(), // 🏠 Initial screen
          theme: mainThemeColor,
          routes: {
            '/candidate_recruiter_page': (context) => const CandidateOrRecruiter(),
            '/new_resume_page': (context) => const NewResume(),
            '/result_tracking_page': (context) => const ResultTracking(),
            '/register_page': (context) => const RegisterPage(),
            '/add_job': (context) => const AddJobPage(),
            '/job_list': (context) => const JobListPage(),
            '/job_details': (context) {
              final jobData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return JobDetailsPage(jobData: jobData);
            },
            '/update_job': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return UpdateJob(
                jobId: args['id'],
                jobData: args['data'],
              );
            },
            '/chatbot': (context) => ChatbotPage(),
            '/recruiter_login_page': (context) => const RecruiterLogin(),
            '/home': (context) => const HomePage(), // ✅ Tambah route untuk HomePage
          },
        );
      },
    );
  }
}
