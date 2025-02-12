import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Backendservice {
  // Sign Up with Email/Password
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User created, store additional data to Firestore (if needed)
    } catch (e) {
      print("Error signing up: $e");
      // Handle error
    }
  }

  // Sign In with Email/Password
  // Sign In with Email/Password
  Future<Map<String, String>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      if (userCredential.user != null) {
        // Login successful
        print("Login successful: ${userCredential.user?.email}");
        return {
          'status': 'success',
          'message': 'Login successful',
        };
        // Proceed with the next step (e.g., navigate to another screen)
        // Example: Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return {
          'status': 'error',
          'message': 'No user found for that email.',
        };
        // Handle specific error (e.g., show an alert dialog)
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
        return {
          'status': 'error',
          'message': 'Wrong password provided.',
        };
        // Handle specific error (e.g., show an alert dialog)
      }
    } catch (e) {
      print("Error signing in: $e");
      return {
        'status': 'error',
        'message': 'Error signing in er',
      };
      // Handle any other errors
    }

    return {
      'status': 'error',
      'message': 'Error signing in',
    };
  }

  // Sign Out
  void signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen or perform other actions after logout
    } catch (e) {
      print("Error signing out: $e");
      // Handle error
    }
  }

  // // Add User to Firestore
  // Future<void> addPlayerToFirestore({
  //   required String userId,
  //   required String email,
  //   required String password,
  //   required String firstName,
  //   required String lastName,
  //   required String phone,
  //   required String imageUrl,
  //   required String userType,
  //   required List<String> sports,
  //   required String gender,
  // }) async {
  //   Reference referenceRoot = FirebaseStorage.instance.ref();
  //   Reference referenceDirImage = referenceRoot.child('images');

  //   Reference referenceImageToUpload = referenceDirImage
  //       .child('${firstName}_${userType}_${DateTime.now()}.jpg');
  //   try {
  //     await referenceImageToUpload.putFile(File(imageUrl));
  //     imageUrl = await referenceImageToUpload.getDownloadURL();
  //     print(imageUrl + "Image Url");
  //     await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //       'email': email,
  //       'password': password,
  //       'firstName': firstName,
  //       'lastName': lastName,
  //       'phone': phone,
  //       'userType': userType,
  //       'sports': sports,
  //       'imageUrl': imageUrl,
  //       'gender': gender,
  //       // Add more fields as needed
  //     });
  //   } catch (e) {
  //     print("Error adding user to Firestore: $e");
  //     // Handle error
  //   }
  // }

  // Add User to Firestore
  Future<void> addUserToFirestore({
    required String userId,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String imageUrl,
    required String userType,
    required String birthDate,
    required String gender,
    List<Map<String, String>> registeredBatch = const [],
    List<Map<String, String>> registeredTournament = const [],
    List<String> sports = const [],
  }) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImage = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImage
        .child('${firstName}_${userType}_${DateTime.now()}.jpg');
    try {
      await referenceImageToUpload.putFile(File(imageUrl));
      imageUrl = await referenceImageToUpload.getDownloadURL();
      print(imageUrl + "Image Url");
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'userType': userType,
        'sports': sports,
        'imageUrl': imageUrl,
        'gender': gender,
        'birthDate': birthDate,
        'registeredBatch': registeredBatch,
        'registeredTournament': registeredTournament,

        // Add more fields as needed
      });
    } catch (e) {
      print("Error adding user to Firestore: $e");
      // Handle error
    }
  }
}
