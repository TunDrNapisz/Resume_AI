import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Resume Screening System",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: const FloatingButtonMenu(),
    );
  }
}

class FloatingButtonMenu extends StatefulWidget {
  const FloatingButtonMenu({super.key});

  @override
  State<FloatingButtonMenu> createState() => _FloatingButtonMenuState();
}

class _FloatingButtonMenuState extends State<FloatingButtonMenu> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      spaceBetweenChildren: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.people_sharp),
          label: 'Candidate List',
          onTap: () {
            try {
              Navigator.pushNamed(context, '/candidate_list_page');
            } catch (error) {
              print("Error navigating to /candidate_list_page': $error");
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit_document),
          label: 'Job List',
          onTap: () {
            try {
              Navigator.pushNamed(context, '/job_list_page');
            } catch (error) {
              print("Error navigating to /job_list_page': $error");
            }
          },
        ),
         SpeedDialChild(
          child: const Icon(Icons.edit_document),
          label: 'Preference Management',
          onTap: () {
            try {
              Navigator.pushNamed(context, '/job_list_page');
            } catch (error) {
              print("Error navigating to /job_list_page': $error");
            }
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.work),
          onTap: () {
            try {
              Navigator.pushNamed(context, "/add_job");
            } catch (error) {
              print("Error navigating to '/add_job': $error");
            }
          },
          label: 'Add Job',
        ),
        SpeedDialChild(
          child: const Icon(Icons.bar_chart_sharp),
          label: 'Report',
          onTap: () {
            try {
              Navigator.pushNamed(context, '/report');
            } catch (error) {
              print("Error navigating to /report': $error");
            }
          },
        ),
      ],
    );
  }
}
