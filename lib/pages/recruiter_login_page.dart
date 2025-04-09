import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:resume_screening_system/auth/auth.dart';
import 'package:resume_screening_system/components/my_button.dart';
import 'package:resume_screening_system/components/my_textfield.dart';

class RecruiterLogin extends StatefulWidget {
  const RecruiterLogin({super.key});

  @override
  State<RecruiterLogin> createState() => _RecruiterLoginState();
}

class _RecruiterLoginState extends State<RecruiterLogin> {
  final _formKey = GlobalKey<FormState>(); //for form validator

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void login() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: "Login Successful",
            confirmBtnText: 'Ok',
          );
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: e.code,
            confirmBtnText: 'Ok',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const Text("Recruiter Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MyTextField(
                    hindtext: "Email",
                    obscureText: false,
                    controller: emailController,
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    hindtext: "Password",
                    obscureText: true,
                    controller: passwordController,
                    validator: (val) =>
                        val!.isEmpty ? 'Enter your password' : null,
                  ),
                  SizedBox(height: 25),
                  MyButton(text: "Login", onTap: login),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
