import 'package:firebase_crud/firestore_service.dart';
import 'package:flutter/material.dart';

class StudentFormScreen extends StatefulWidget {
  final String? docId;
  final String? studentId;
  final String? studentName;

  const StudentFormScreen({
    super.key,
    this.docId,
    this.studentId,
    this.studentName,
  });

  bool get isEditing => docId != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();

  final _nameController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Fill existing data when editing
    if (widget.isEditing) {
      _idController.text = widget.studentId ?? '';

      _nameController.text = widget.studentName ?? '';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  Future<void> saveStudent() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final id = _idController.text.trim();
    final name = _nameController.text.trim();

    try {
      if (widget.isEditing) {
        // UPDATE
        await firestoreService.updateStudent(
          widget.docId!,
          id,
          name,
        );
      } else {
        // CREATE
        await firestoreService.addStudent(
          id,
          name,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Student updated successfully' : 'Student added successfully',
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('FIREBASE ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Student' : 'Add Student',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // STUDENT ID
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student ID';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // STUDENT NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // SAVE / UPDATE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveStudent,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          widget.isEditing ? 'Update' : 'Save',
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
