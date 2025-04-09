import 'package:flutter/material.dart';
import 'package:resume_screening_system/components/my_button.dart';

class CandidateOrRecruiter extends StatelessWidget {
  const CandidateOrRecruiter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const Text(
              "Resume Screening System",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 20
                ),
            ),
            SizedBox(height: 20,),
            MyButton(
              text: "Submit Resume", 
              onTap: (){
               Navigator.pushNamed(context, "/new_resume_page");
            }),
            SizedBox(height: 20,),
            MyButton(
              text: "Check Application Result", 
              onTap: (){
               Navigator.pushNamed(context, "/result_tracking_page");
            }),
            SizedBox(height: 20,),
            MyButton(
              text: "Recruiter Login", 
              onTap: (){
               Navigator.pushNamed(context, "/recruiter_login_page");
            }),
          ],
        ),
      )),
    );
  }
}
