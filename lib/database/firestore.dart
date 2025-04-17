import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference candidate =
      FirebaseFirestore.instance.collection('Candidate');

  final CollectionReference job = FirebaseFirestore.instance.collection('Job');

  final CollectionReference application =
      FirebaseFirestore.instance.collection('Application');

  Future<String> generateApplicationId() async {
    // Fetch the latest document
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Application')
        .orderBy('applicationId', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastDoc = querySnapshot.docs.first;
      final lastApplicationId = lastDoc['applicationId'];

      // Extract the numeric part and increment it
      final lastNumber =
          int.tryParse(lastApplicationId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      final newNumber = lastNumber + 1;

      // Return the new applicationId
      return 'aplc_${newNumber.toString().padLeft(3, '0')}';
    } else {
      // If no documents exist, start with 'aplc_001'
      return 'aplc_001';
    }
  }

  Future<DocumentSnapshot> getApplicationById(String applicationId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Application')
        .where('applicationId', isEqualTo: applicationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      throw Exception('Application not found');
    }
  }

  Future<void> toggleJob(String id) async {
    final docRef = job.doc(id);

    try {
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final currentStatus = data['isOpen'] as bool? ?? false;

        final newStatus = !currentStatus;

        await docRef.update({
          'isOpen': newStatus,
          'updateOn': Timestamp.now(),
        });
      } else {
        print("Document with ID $id does not exist.");
      }
    } catch (e) {
      print("Error toggling isOpen: $e");
    }
  }

  Stream<QuerySnapshot> getJobStream() {
    return job.where('isOpen', isEqualTo: true).snapshots();
  }
}
