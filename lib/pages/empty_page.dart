import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class emptyPage extends StatelessWidget {
  final String? text;

  const emptyPage({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 150.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 1.h),
            Text(
              text ?? "No data in this page!",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
