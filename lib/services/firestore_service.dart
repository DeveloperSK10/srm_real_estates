import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addAdminUser() async {
    try {
      // This function should only be called once, manually, to set up the initial admin.
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: 'admin@srm.com', password: 'Admin@12345');

      // Storing username and role. DO NOT store the password.
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'username': 'Admin',
        'email': 'admin@srm.com',
        'role': 'admin',
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // This is expected if the admin user has already been created.
        debugPrint('Admin user already exists.');
      } else {
        // Handle other errors, e.g., weak-password
        debugPrint('Error creating admin user: $e');
      }
    }
  }

  Future<void> addSampleUser() async {
    try {
      // This function should only be called once, manually, to set up a sample user.
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: 'user@srm.com', password: 'User@12345');

      // Storing username and role.
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'username': 'Sample User',
        'email': 'user@srm.com',
        'role': 'user',
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // This is expected if the sample user has already been created.
        debugPrint('Sample user already exists.');
      } else {
        // Handle other errors
        debugPrint('Error creating sample user: $e');
      }
    }
  }
}
