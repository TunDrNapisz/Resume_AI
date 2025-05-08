import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Listings"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Job').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data!.docs;

          if (jobs.isEmpty) {
            return const Center(child: Text("No jobs found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final doc = jobs[index];
              final data = doc.data() as Map<String, dynamic>;

              final jobTitle = data['job_title'] ?? 'No Title';
              final jobName = data['job_name'] ?? 'No Name';
              final isActive = (data['isActive'] is String)
                  ? data['isActive'] == 'true'
                  : data['isActive'] ?? true;

              final createdAt = data['created_at'] != null
                  ? (data['created_at'] as Timestamp).toDate()
                  : null;

              final formattedDate = createdAt != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
                  : 'Unknown Date';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.work_outline, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              jobTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jobName,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Created At: $formattedDate",
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.toggle_on, color: Colors.grey),
                              const SizedBox(width: 6),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isActive ? Colors.transparent : Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: FlutterSwitch(
                                  width: 55.0,
                                  height: 25.0,
                                  toggleSize: 20.0,
                                  value: isActive,
                                  borderRadius: 20.0,
                                  padding: 2.0,
                                  activeColor: Colors.green,
                                  inactiveColor: Colors.transparent,
                                  toggleColor: Colors.white,
                                  onToggle: (val) {
                                    FirebaseFirestore.instance
                                        .collection('Job')
                                        .doc(doc.id)
                                        .update({'isActive': val});
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                color: Colors.indigo,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/job_details',
                                    arguments: data,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.orange,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/update_job',
                                    arguments: {'id': doc.id, 'data': data},
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: const Text("Are you sure you want to delete this job?"),
                                        actions: [
                                          TextButton(
                                            child: const Text("Cancel"),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await FirebaseFirestore.instance
                                                  .collection('Job')
                                                  .doc(doc.id)
                                                  .delete();

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Job deleted")),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF2F2F2),
    );
  }
}
