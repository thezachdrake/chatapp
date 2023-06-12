import 'dart:io';

import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  late String _userEmail;
  late String _userPassword;
  late String _userUserName;
  XFile? _selectedImage;
  bool _isUploading = false;

  void _submit() async {
    final bool _isValid = _formKey.currentState!.validate();
    if (!_isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        _isUploading = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
            email: _userEmail, password: _userPassword);
      } else {
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _userEmail, password: _userPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child('${userCredentials.user!.uid}.jpeg');

        await storageRef.putData(await _selectedImage!.readAsBytes());
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          'username': _userUserName,
          'email': userCredentials.user!.email,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!.split(":")[3].split(".")[0]),
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Container(
                width: 600,
                child: Card(
                  elevation: 30,
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    label: Text('Email Address')),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains("@")) {
                                    return "Please enter a valid email address.";
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _userEmail = value!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              if (!_isLogin)
                                TextFormField(
                                  decoration: const InputDecoration(
                                    label: Text("Username"),
                                  ),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 4 ||
                                        value.isEmpty) {
                                      return "Invalid Username";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userUserName = value!;
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    label: Text('Password')),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return "Password must be at least 6 characters long.";
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _userPassword = value!;
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_isUploading) CircularProgressIndicator(),
                              if (!_isUploading)
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  child: Text(_isLogin ? "Log in" : "Sign Up"),
                                ),
                              const SizedBox(height: 12),
                              if (!_isUploading)
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(_isLogin
                                        ? "Create an account"
                                        : "I have an account."))
                            ],
                          )),
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
