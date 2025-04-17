// import 'dart:io';
// import 'dart:typed_data';


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagePickerContainer extends StatefulWidget {
//   final String? imageUrl;
//   final String pageName;
//   final String? id;
//   final IconData icon;
//   final Function(Uint8List)? onImageUpdated;

//   const ImagePickerContainer(
//       {Key? key,
//       this.imageUrl,
//       required this.pageName,
//       required this.icon,
//       this.onImageUpdated,
//       this.id})
//       : super(key: key);

//   @override
//   State<ImagePickerContainer> createState() => _ImagePickerContainerState();
// }

// class _ImagePickerContainerState extends State<ImagePickerContainer> {
//   void _viewProfileImage() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: widget.imageUrl != null && widget.imageUrl != ''
//                 ? Image.network(
//                     widget.imageUrl!,
//                     fit: BoxFit.contain,
//                   )
//                 : const Icon(Icons.person),
//           ),
//         );
//       },
//     );
//   }

//   // Function to show the bottom sheet with options
//   void _showImageOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.camera),
//               title: const Text('Take a picture'),
//               onTap: () {
//                 _pickImage(ImageSource.camera); // Corrected method name
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo),
//               title: const Text('Choose from gallery'),
//               onTap: () {
//                 _pickImage(ImageSource.gallery); // Corrected method name
//                 Navigator.pop(context);
//               },
//             ),
//             if (widget.imageUrl != null && widget.imageUrl != '')
//               ListTile(
//                 leading: const Icon(Icons.person),
//                 title: const Text('View profile image'),
//                 onTap: _viewProfileImage,
//               ),
//           ],
//         );
//       },
//     );
//   }

//   String? imagePath; // Store the path of the selected image
//   Uint8List? image;
// // Function to handle image selection
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(source: source);

//       if (pickedFile != null) {
//         // Read the file as bytes and assign it to the Uint8List
//         List<int> bytes = await pickedFile.readAsBytes();
//         setState(() {
//           imagePath = pickedFile.path;
//           image = Uint8List.fromList(bytes);
//         });

//         if (widget.pageName == 'Profile' ||
//             widget.pageName == 'Senior' ||
//             widget.pageName == 'medicine') {
//           if (image != null) {
//             await StoreData().updateProfileImg(
//                 file: image!, id: widget.id, character: widget.pageName);
//           }
//         } else {
//           widget.onImageUpdated!(image!);
//         }
//       }
//     } on PlatformException catch (e) {
//       print('Failed to pick image $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showImageOptions();
//       },
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             padding: const EdgeInsets.all(2),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (widget.pageName == 'Profile' ||
//                     widget.pageName == 'Senior' ||
//                     widget.pageName == 'medicine') ...[
//                   if (widget.imageUrl != null && widget.imageUrl != '') ...[
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(24),
//                       child: Image.network(
//                         // Display the image from the URL
//                         widget.imageUrl!,
//                         width: 130,
//                         height: 130,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ] else ...[
//                     Padding(
//                         padding: const EdgeInsets.all(15),
//                         child: Icon(
//                           widget.icon,
//                           size: 72,
//                         )),
//                   ],
//                 ],
//                 if (widget.pageName == 'Medicine') ...[
//                   if (imagePath != null) ...[
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(24),
//                       child: Image.file(
//                         File(
//                             imagePath!), // Assuming imagePath is the local file path
//                         width: 130,
//                         height: 130,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ] else ...[
//                     Padding(
//                         padding: const EdgeInsets.all(15),
//                         child: Icon(
//                           widget.icon,
//                           size: 72,
//                         )),
//                   ],
//                 ],
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 1,
//             right: -1,
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.grey.shade200,
//               ),
//               padding: const EdgeInsets.all(8),
//               child: const Icon(
//                 Icons.edit,
//                 size: 15,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
