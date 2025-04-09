import 'package:flutter/material.dart';

class NewResume extends StatefulWidget {
  const NewResume({super.key});

  @override
  State<NewResume> createState() => _NewResumeState();
}

class _NewResumeState extends State<NewResume> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                
              ]),
        ),
      ),
    );
  }
}
