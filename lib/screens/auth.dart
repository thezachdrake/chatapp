import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _submit() async {
    final bool _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState!.save();
    if (_isLogin) {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: _userEmail, password: _userPassword);
    } else {
      try {
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _userEmail, password: _userPassword);
        print(userCredentials);
      } on FirebaseAuthException catch (error) {
        print(error.message);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message!.split(":")[3].split(".")[0]),
          ),
        );
      }
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
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? "Log in" : "Sign Up"),
                              ),
                              const SizedBox(height: 12),
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
