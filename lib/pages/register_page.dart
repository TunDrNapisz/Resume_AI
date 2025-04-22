import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:resume_screening_system/components/my_button.dart';
import 'package:resume_screening_system/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController comfirmPswdController = TextEditingController();

  Future<void> createHrDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("HR")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'isApprove': false,
        'TimeStamp': Timestamp.now(),
      });
    }
  }

  void registerRecruiter() async {
    try {
      if (passwordController.text != comfirmPswdController.text) {
        // Make sure passwords match
        if (context.mounted) {
          Navigator.pop(context);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'Password not match',
            confirmBtnText: 'Ok',
          );
          return;
        }
      }
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        createHrDocument(userCredential);
        // Hide loading circle
        if (context.mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          // Hide loading circle
          Navigator.pop(context);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: e.message.toString(),
            confirmBtnText: 'Ok',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Hide loading circle
        Navigator.pop(context);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Error: $e",
          confirmBtnText: 'Ok',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 80,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const Text(
                          "Recruiter Register Here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        MyTextField(
                          hindtext: "Username",
                          obscureText: false,
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter A Username';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          hindtext: "Email",
                          obscureText: false,
                          validator: (val) =>
                              val!.isEmpty ? 'Enter An Email' : null,
                          controller: emailController,
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          validator: (val) =>
                              val!.isEmpty ? 'Enter Your Password here' : null,
                          hindtext: "Password",
                          obscureText: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          validator: (val) =>
                              val!.isEmpty ? 'Enter Your Password again' : null,
                          hindtext: "Confirming Password",
                          obscureText: true,
                          controller: comfirmPswdController,
                        ),
                        SizedBox(height: 25),
                        MyButton(
                          text: 'Register',
                          onTap: () {},
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: widget.onTap,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account?"),
                                Text(
                                  " Login now ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
