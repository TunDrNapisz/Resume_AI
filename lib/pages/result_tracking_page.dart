import 'package:flutter/material.dart';

class ResultTracking extends StatefulWidget {
  const ResultTracking({super.key});

  @override
  State<ResultTracking> createState() => _ResultTrackingState();
}

class _ResultTrackingState extends State<ResultTracking> {
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