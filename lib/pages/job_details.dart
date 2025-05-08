import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobDetailsPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const JobDetailsPage({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Job Title Section
            _buildCard(
              title: jobData['job_title'] ?? 'No Title',
              subtitle: "Job Name: ${jobData['job_name'] ?? 'No Name'}",
            ),

            // Job Description
            _buildInfoCard(
              "Job Description",
              jobData['job_description'] ?? 'No description available.',
            ),

            // Job Type
            _buildInfoCard(
              "Job Type",
              jobData['job_type'] ?? 'Not specified.',
            ),

            // Location
            _buildInfoCard(
              "Location",
              jobData['location'] ?? 'Not specified.',
            ),

            // Skills Used
            if (jobData['skills_used'] != null && jobData['skills_used'] is List)
              _buildSkillsCard(jobData['skills_used']),

            // Status
            _buildInfoCard(
              "Job Status",
              jobData['isActive'] == true ? 'Active' : 'Inactive',
              color: jobData['isActive'] == true ? Colors.green : Colors.red,
            ),

            // Created At
            _buildInfoCard(
              "Created At",
              jobData['created_at'] != null
                  ? (jobData['created_at'] as Timestamp).toDate().toString()
                  : 'No creation date available.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String content, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: 16, color: color ?? Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(List<dynamic> skills) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Skills Used", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: skills.map((skill) {
                return Chip(label: Text(skill.toString()));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
