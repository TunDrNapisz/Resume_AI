import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  final String? previousLct;
   const MyBackButton({super.key, this.previousLct});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => previousLct=='Home',
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
