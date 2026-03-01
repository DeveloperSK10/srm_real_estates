import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text, password: _passwordController.text);

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            if (userData.containsKey('language') && userData['language'] != null) {
              Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(Locale(userData['language']));
            }
            if (userData.containsKey('role')) {
              if (userData['role'] == 'admin') {
                context.go('/admin_home');
              } else {
                final preferencesDoc = await FirebaseFirestore.instance
                    .collection('property_preferences')
                    .doc(userCredential.user!.uid)
                    .get();

                if (!mounted) return;

                if (preferencesDoc.exists) {
                  context.go('/user_home');
                } else {
                  context.go('/property_preferences');
                }
              }
            } else {
              setState(() {
                _errorMessage = AppLocalizations.of(context)!.userRoleNotFound;
              });
            }
          } else {
            setState(() {
              _errorMessage = AppLocalizations.of(context)!.userDataNotFound;
            });
          }
        } else {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.userDataNotFound;
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3498db),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.jpeg',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                      }
                      if (!value.contains('@')) {
                        return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _login,
                    child: Text(AppLocalizations.of(context)!.login),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      context.go('/register');
                    },
                    child: Text(
                      '${AppLocalizations.of(context)!.dontHaveAnAccount} ${AppLocalizations.of(context)!.register}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
