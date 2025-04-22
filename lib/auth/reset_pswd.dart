
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:resume_screening_system/components/my_back_button.dart';
import 'package:resume_screening_system/components/my_button.dart';
import 'package:resume_screening_system/components/my_textfield.dart';

class ResetPswd extends StatefulWidget {
  ResetPswd({super.key});

  @override
  State<ResetPswd> createState() => _ResetPswdState();
}

class _ResetPswdState extends State<ResetPswd> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future reset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Reset password email is sent to your email',
        confirmBtnText: 'Ok',
      );
    } on FirebaseException catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: e.message.toString(),
        confirmBtnText: 'Ok',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                children: [
                  MyBackButton(),
                ],
              ),
              const SizedBox(
                height: 70,
              ),
              const Icon(
                Icons.lock_reset,
                size: 90,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Please key in your email to reset your password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                hindtext: 'Email',
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              MyButton(text: 'Reset Password', onTap: reset),
            ],
          ),
        ),
      ),
    );
  }
}
