import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/firestore_service.dart';
import 'package:flutter/material.dart';

import 'student_form_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getStudents(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
              ),
            );
          }

          // No students
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No students found',
              ),
            );
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final doc = students[index];

              final data = doc.data() as Map<String, dynamic>;

              final studentId = data['id']?.toString() ?? '';

              final studentName = data['name']?.toString() ?? '';

              return ListTile(
                title: Text(studentName),
                subtitle: Text(
                  'ID: $studentId',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // EDIT
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentFormScreen(
                              docId: doc.id,
                              studentId: studentId,
                              studentName: studentName,
                            ),
                          ),
                        );
                      },
                    ),

                    // DELETE
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _showDeleteDialog(
                          context,
                          firestoreService,
                          doc.id,
                          studentName,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ADD STUDENT
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FirestoreService firestoreService,
    String docId,
    String studentName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Student',
          ),
          content: Text(
            'Are you sure you want to delete '
            '$studentName?',
          ),
          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            // DELETE
            TextButton(
              onPressed: () async {
                try {
                  await firestoreService.deleteStudent(docId);

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Student deleted successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to delete student',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
