import 'package:flutter/material.dart';
import 'package:resume_screening_system/components/my_button.dart';
import 'package:resume_screening_system/components/my_textfield.dart';

class ResultTracking extends StatefulWidget {
  const ResultTracking({super.key});

  @override
  State<ResultTracking> createState() => _ResultTrackingState();
}

class _ResultTrackingState extends State<ResultTracking> {
  final _formKey = GlobalKey<FormState>(); //for form validator
  final TextEditingController emailController = TextEditingController();

  void checkResult() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.workspace_premium,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const Text("Check your application result here ! ",
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
                  MyButton(text: "Check", onTap: checkResult),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
