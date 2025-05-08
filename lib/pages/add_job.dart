import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _customSkillController = TextEditingController();

  List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    'Flutter', 'Dart', 'Firebase', 'Android Studio', 'Node.js', 'Python', 'UI/UX'
  ];

  bool _isLoading = false;
  String? _selectedSkill;

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate() || _selectedSkills.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Job')
          .doc('Add_Job')
          .collection('Add_Job')
          .add({
        'job_name': _jobNameController.text.trim(),
        'job_title': _jobTitleController.text.trim(),
        'job_description': _jobDescriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'job_type': _jobTypeController.text.trim(),
        'skills_used': _selectedSkills,
        'created_at': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Job successfully added")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save job: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.edit_note),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return errorMsg;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSkillSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skills Required', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSkill,
          decoration: InputDecoration(
            labelText: 'Select or Add a Skill',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          items: [
            const DropdownMenuItem(value: 'Add Custom Skill', child: Text('Add Custom Skill')),
            ..._availableSkills.map((skill) => DropdownMenuItem(value: skill, child: Text(skill))),
          ],
          onChanged: (selectedSkill) {
            setState(() {
              _selectedSkill = selectedSkill;
              if (selectedSkill == 'Add Custom Skill') {
                _showCustomSkillInput();
              } else if (!_selectedSkills.contains(selectedSkill!)) {
                _selectedSkills.add(selectedSkill);
              }
            });
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _selectedSkills
              .map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.blue.shade100,
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => setState(() => _selectedSkills.remove(skill)),
                  ))
              .toList(),
        ),
        if (_selectedSkills.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Please select at least one skill', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  void _showCustomSkillInput() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Custom Skill'),
        content: TextField(
          controller: _customSkillController,
          decoration: const InputDecoration(hintText: 'Custom Skill'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add Skill'),
            onPressed: () {
              final skill = _customSkillController.text.trim();
              if (skill.isNotEmpty && !_selectedSkills.contains(skill)) {
                setState(() {
                  _selectedSkills.add(skill);
                  _customSkillController.clear();
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Job"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                    hint: 'Describe responsibilities...',
                    errorMsg: 'Please enter job description',
                    maxLines: 4,
                  ),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'e.g., Kuala Lumpur / Remote',
                    errorMsg: 'Please enter location',
                  ),
                  _buildTextField(
                    controller: _jobTypeController,
                    label: 'Job Type',
                    hint: 'e.g., Full-time / Internship',
                    errorMsg: 'Please enter job type',
                  ),
                  _buildSkillSelector(),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("Save Job"),
                            onPressed: _saveJob,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
