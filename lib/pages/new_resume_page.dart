import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resume_screening_system/components/my_button.dart';
import 'package:resume_screening_system/components/my_dropdown_button.dart';
import 'package:resume_screening_system/database/firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FirestoreDatabase firestoreDB = FirestoreDatabase();

class NewResume extends StatefulWidget {
  const NewResume({super.key});

  @override
  State<NewResume> createState() => _NewResumeState();
}

class _NewResumeState extends State<NewResume> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController candidateEmailController =
      TextEditingController();

  String? _job;

  File? _imageFile;
  // User? currentUser = FirebaseAuth.instance.currentUser;

  PlatformFile? pickedFile;

  //pick image
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    //pick from gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  //upload image
  Future uploadImage() async {
    if (_imageFile == null) return;

    //generate an unique file path
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "uploads/$fileName";

    //upload the image to supabase storage
    await Supabase.instance.client.storage
        .from('image')
        .upload(path, _imageFile!)
        .then((value) =>
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Image Uploaded Successfully!"),
            )));
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    if (result.files.first.extension != 'pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only PDF files are allowed!')),
      );
      return;
    }

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<String?> uploadFileToSupabase() async {
    if (pickedFile == null) return null;

    final fileBytes = pickedFile!.bytes;
    final fileName = pickedFile!.name;
    final storage = Supabase.instance.client.storage;

    try {
      final filePath = 'resume/$fileName'; // store under pdf/resume/

      await storage
          .from('pdf') // 'pdf' is your bucket
          .uploadBinary(filePath, fileBytes!,
              fileOptions: const FileOptions(upsert: true));

// ✅ Use Supabase's built-in URL generator
      final publicUrl = storage.from('pdf').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Supabase upload error: $e');
      return null;
    }
  }

  void submitResumeData() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Generate applicationId
    final firestore = FirestoreDatabase();
    final applicationId = await firestore.generateApplicationId();

    final fileURL = await uploadFileToSupabase();

    if (fileURL == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload resume.')),
      );
      return;
    }

    // Add document with the new applicationId
    await FirebaseFirestore.instance.collection('Application').add({
      'applicationId': applicationId, // Add applicationId field
      'applyBy': candidateEmailController.text.trim(),
      'job_applied': _job,
      'result': 0,
      'resume_url': fileURL,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Resume Submission'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //   Center(
                    //     child: Column(children: [
                    //       ImagePickerContainer(
                    //         pageName: 'Medicine',
                    //         icon: Icons.medication,
                    //         onImageUpdated: (Uint8List newValue) {
                    //           _imageUrl = newValue;
                    //         },
                    //       ),
                    //       const PanelTitle(
                    //         title: "Medicine Image",
                    //         isRequired: false,
                    //       ),
                    //     ]),
                    //   )
                    const PanelTitle(
                      title: "Choose the job you want to apply ",
                      isRequired: true,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    selectJob(
                      onChanged: (String newValue) {
                        _job = newValue;
                      },
                      formKey: _formKey,
                    ),
                    const PanelTitle(
                      title: "Email",
                      isRequired: true,
                    ),
                    TextFormField(
                      maxLength: 30,
                      validator: (val) =>
                          val!.isEmpty ? 'Enter Your Email' : null,
                      controller: candidateEmailController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    const PanelTitle(
                      title: "Resume",
                      isRequired: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: selectFile,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Upload your resume here",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (pickedFile != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Selected file: ${pickedFile!.name}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Text(
                      "Note: Resubmitting a resume using the same email will replace the earlier one ! ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    MyButton(
                      text: "Submit",
                      onTap: submitResumeData,
                    ),
                  ]),
            )),
      ),
    );
  }
}

class selectJob extends StatefulWidget {
  final void Function(String) onChanged;

  final GlobalKey<FormState> formKey; // Pass the form key

  const selectJob({super.key, required this.formKey, required this.onChanged});

  @override
  State<selectJob> createState() => _selectJobState();
}

class _selectJobState extends State<selectJob> {
  String? selectedReceiver;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreDB.getJobStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Some error occurred ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const CircularProgressIndicator();
        }

        final jobList = snapshot.data!.docs.reversed.toList();

        List<DropdownMenuItem<String>> dropdownItems = [];

        for (var job in jobList) {
          String name = job['job_title'] ?? '';
          String jobId = job.id ?? '';

          dropdownItems.add(
            DropdownMenuItem<String>(
              value: jobId,
              child: Text(name),
            ),
          );
        }

        return MyDropdownButtonForm(
          hintText: 'Choose a job you want to apply',
          value: selectedReceiver,
          items: dropdownItems,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a job !';
            }
            return null; // Return null if the value is valid
          },
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedReceiver = newValue;
              });
              widget.onChanged(newValue);
              widget.formKey.currentState?.validate();
            }
          },
        );
      },
    );
  }
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.title, required this.isRequired});
  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(children: <TextSpan>[
          TextSpan(
            text: title,
          ),
          TextSpan(
            text: isRequired ? "*" : "",
          )
        ]),
      ),
    );
  }
}
