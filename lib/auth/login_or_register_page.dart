import 'package:flutter/material.dart';
import 'package:resume_screening_system/pages/recruiter_login_page.dart';
import 'package:resume_screening_system/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
   bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return RecruiterLogin(onTap: togglePages);
    } else {
      return RegisterPage(
        onTap: togglePages,
    
      );
    }
  }
}