import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/services/translation_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedLanguage;
  String _errorMessage = '';

  final TranslationService _translationService = TranslationService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch;
        });
        return;
      }
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text, password: _passwordController.text);

        final name = _nameController.text;
        final address = _addressController.text;

        final translatedName = await _translationService.translate(name);
        final translatedAddress = await _translationService.translate(address);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': translatedName,
          'email': _emailController.text,
          'mobileNumber': _mobileController.text,
          'address': translatedAddress,
          'pincode': _pincodeController.text,
          'language': _selectedLanguage,
          'role': 'user',
        });

        if (!mounted) return;

        if (_selectedLanguage != null) {
          Provider.of<LocaleProvider>(context, listen: false)
              .setLocale(Locale(_selectedLanguage!));
        }
        context.go('/property_preferences');
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
                  Text(
                    AppLocalizations.of(context)!.createAccount,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fullName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.mobileNumber,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourMobileNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.address,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourAddress;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pincode,
                      prefixIcon: const Icon(Icons.pin_drop_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourPincode;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.language,
                      prefixIcon: const Icon(Icons.language_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: const ['en', 'ta']
                        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang == 'en' ? 'English' : 'Tamil')))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context)!.pleaseSelectALanguage;
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
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseConfirmYourPassword;
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
                    onPressed: _register,
                    child: Text(AppLocalizations.of(context)!.register),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: Text(
                      '${AppLocalizations.of(context)!.alreadyHaveAnAccount} ${AppLocalizations.of(context)!.login}',
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
