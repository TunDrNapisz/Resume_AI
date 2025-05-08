import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateJob extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const UpdateJob({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  @override
  State<UpdateJob> createState() => _UpdateJobPageState();
}

class _UpdateJobPageState extends State<UpdateJob> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _jobNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _jobDescriptionController;
  late TextEditingController _locationController;
  late TextEditingController _jobTypeController;
  final TextEditingController _customSkillController = TextEditingController();

  List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    'Flutter', 'Dart', 'Firebase', 'Android Studio', 'Node.js', 'Python', 'UI/UX'
  ];
  String? _selectedSkill;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _jobNameController = TextEditingController(text: widget.jobData['job_name']);
    _jobTitleController = TextEditingController(text: widget.jobData['job_title']);
    _jobDescriptionController = TextEditingController(text: widget.jobData['job_description']);
    _locationController = TextEditingController(text: widget.jobData['location']);
    _jobTypeController = TextEditingController(text: widget.jobData['job_type']);

    final skillsRaw = widget.jobData['skills_used'];
    if (skillsRaw is List) {
      _selectedSkills = List<String>.from(skillsRaw);
    } else {
      _selectedSkills = [];
    }
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _locationController.dispose();
    _jobTypeController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    if (!_formKey.currentState!.validate() || _selectedSkills.isEmpty) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance.collection('Job').doc(widget.jobId).update({
        'job_name': _jobNameController.text.trim(),
        'job_title': _jobTitleController.text.trim(),
        'job_description': _jobDescriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'job_type': _jobTypeController.text.trim(),
        'skills_used': _selectedSkills,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Job successfully updated")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update job: $e")),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String errorMsg,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return errorMsg;
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSkillSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(15),
            child: DropdownButtonFormField<String>(
              value: _selectedSkill,
              decoration: InputDecoration(
                labelText: 'Select or Add a Skill',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: 'Add Custom Skill',
                  child: Text('Add Custom Skill'),
                ),
                ..._availableSkills.map((skill) {
                  return DropdownMenuItem<String>(
                    value: skill,
                    child: Text(skill),
                  );
                }),
              ],
              onChanged: (selectedSkill) {
                setState(() {
                  _selectedSkill = selectedSkill;

                  if (selectedSkill == 'Add Custom Skill') {
                    _showCustomSkillInput();
                  } else if (selectedSkill != null && !_selectedSkills.contains(selectedSkill)) {
                    _selectedSkills.add(selectedSkill);
                  }
                });
              },
              hint: const Text('Choose or add a skill'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedSkills.map((skill) {
              return Chip(
                label: Text(skill),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedSkills.remove(skill);
                  });
                },
                backgroundColor: Colors.blue[100],
              );
            }).toList(),
          ),
          if (_selectedSkills.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Please select at least one skill', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  void _showCustomSkillInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Skill'),
          content: TextField(
            controller: _customSkillController,
            decoration: const InputDecoration(hintText: 'Custom Skill'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final customSkill = _customSkillController.text.trim();
                if (customSkill.isNotEmpty && !_selectedSkills.contains(customSkill)) {
                  setState(() {
                    _selectedSkills.add(customSkill);
                    _customSkillController.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add Skill'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Job"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _jobNameController,
                label: 'Job Name',
                hint: 'e.g., Flutter Developer',
                errorMsg: 'Please enter job name',
              ),
              _buildTextField(
                controller: _jobTitleController,
                label: 'Job Title',
                hint: 'e.g., Junior Developer',
                errorMsg: 'Please enter job title',
              ),
              _buildTextField(
                controller: _jobDescriptionController,
                label: 'Job Description',
                hint: 'Describe the responsibilities...',
                errorMsg: 'Please enter job description',
                maxLines: 4,
              ),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g., Kuala Lumpur / Remote',
                errorMsg: 'Please enter job location',
              ),
              _buildTextField(
                controller: _jobTypeController,
                label: 'Job Type',
                hint: 'e.g., Full-time / Internship',
                errorMsg: 'Please enter job type',
              ),
              _buildSkillSelector(),
              const SizedBox(height: 20),
              _isUpdating
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Update Job"),
                        onPressed: _updateJob,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
