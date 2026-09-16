import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference students = FirebaseFirestore.instance.collection('student');

  // CREATE
  Future<void> addStudent(String id, String name) async {
    await students.add({
      'id': id,
      'name': name,
    });
  }

  // READ
  Stream<QuerySnapshot> getStudents() {
    return students.snapshots();
  }

  // UPDATE
  Future<void> updateStudent(
    String docId,
    String id,
    String name,
  ) async {
    await students.doc(docId).update({
      'id': id,
      'name': name,
    });
  }

  // DELETE
  Future<void> deleteStudent(String docId) async {
    await students.doc(docId).delete();
  }
}
