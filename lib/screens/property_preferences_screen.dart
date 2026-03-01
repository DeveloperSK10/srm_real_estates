import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/l10n/app_localizations.dart';

class PropertyPreferencesScreen extends StatefulWidget {
  const PropertyPreferencesScreen({super.key});

  @override
  State<PropertyPreferencesScreen> createState() =>
      _PropertyPreferencesScreenState();
}

class _PropertyPreferencesScreenState extends State<PropertyPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _houseForRent = false;
  bool _houseForSale = false;
  bool _landForRent = false;
  bool _landForSale = false;
  bool _shopForRent = false;
  bool _shopForSale = false;
  bool _flat = false;

  String? _selectedLocation;
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _minBedroomsController = TextEditingController();
  final _maxBedroomsController = TextEditingController();
  bool _parking = false;
  bool _gym = false;
  bool _swimmingPool = false;
  final _additionalRequirementsController = TextEditingController();
  bool _isSaving = false;

  final Map<String, Map<String, String>> _locations = {
    'tirupattur_town': {'en': 'Tirupattur Town', 'ta': 'திருப்பத்தூர் நகரம்'},
    'housing_board': {'en': 'Housing Board', 'ta': 'ஹவுசிங் போர்டு'},
    'adiyur': {'en': 'Adiyur', 'ta': 'ஆதியூர்'},
    'koratti': {'en': 'Koratti', 'ta': 'கொரட்டி'},
    'kandili': {'en': 'Kandili', 'ta': 'கந்திலி'},
    'kejelnaickenpatti': {
      'en': 'Kejelnaickenpatti',
      'ta': 'கெஜல்நாயக்கன்பட்டி'
    },
    'jolarpettai': {'en': 'Jolarpettai', 'ta': 'ஜோலார்பேட்டை'},
    'yelagiri': {'en': 'Yelagiri', 'ta': 'ஏலகிரி'},
    'puduppettai': {'en': 'Puduppettai', 'ta': 'புதுப்பேட்டை'},
    'nattrampalli': {'en': 'Nattrampalli', 'ta': 'நாட்டறம்பள்ளி'},
    'vengalapuram': {'en': 'Vengalapuram', 'ta': 'வெங்களாபுரம்'},
    'kurisilapattu': {'en': 'Kurisilapattu', 'ta': 'குரிசிலாப்பட்டு'},
    'mittur': {'en': 'Mittur', 'ta': 'மிட்டூர்'},
    'alangayam': {'en': 'Alangayam', 'ta': 'ஆலங்காயம்'},
    'pasalikuttam': {'en': 'Pasalikuttam', 'ta': 'பசலிக்குட்டை'},
    'vishamangalam': {'en': 'Vishamangalam', 'ta': 'விஷமங்கலம்'},
  };

  Future<void> _savePreferences() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('property_preferences')
              .doc(user.uid)
              .set({
            'looking_for': {
              'house_for_rent': _houseForRent,
              'house_for_sale': _houseForSale,
              'land_for_rent': _landForRent,
              'land_for_sale': _landForSale,
              'shop_for_rent': _shopForRent,
              'shop_for_sale': _shopForSale,
              'flat': _flat,
            },
            'location': _selectedLocation,
            'budget_range': {
              'min': _minBudgetController.text,
              'max': _maxBudgetController.text,
            },
            'bedrooms': {
              'min': _minBedroomsController.text,
              'max': _maxBedroomsController.text,
            },
            'amenities': {
              'parking': _parking,
              'gym': _gym,
              'swimming_pool': _swimmingPool,
            },
            'additional_requirements': _additionalRequirementsController.text,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences saved successfully!')),
            );
            context.go('/user_home');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving preferences: $e')),
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.propertyPreferences,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.whatAreYouLookingFor,
                      style: const TextStyle(fontSize: 16)),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.houseForRent),
                    value: _houseForRent,
                    onChanged: (value) {
                      setState(() {
                        _houseForRent = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.houseForSale),
                    value: _houseForSale,
                    onChanged: (value) {
                      setState(() {
                        _houseForSale = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.landForRent),
                    value: _landForRent,
                    onChanged: (value) {
                      setState(() {
                        _landForRent = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.landForSale),
                    value: _landForSale,
                    onChanged: (value) {
                      setState(() {
                        _landForSale = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.shopForRent),
                    value: _shopForRent,
                    onChanged: (value) {
                      setState(() {
                        _shopForRent = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.shopForSale),
                    value: _shopForSale,
                    onChanged: (value) {
                      setState(() {
                        _shopForSale = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.flat),
                    value: _flat,
                    onChanged: (value) {
                      setState(() {
                        _flat = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.whichLocationDoYouPrefer,
                      style: const TextStyle(fontSize: 16)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.selectLocation,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    value: _selectedLocation,
                    items: _locations.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value[locale]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.budgetRange,
                      style: const TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minBudgetController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.minBudget,
                            prefixIcon: const Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxBudgetController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.maxBudget,
                            prefixIcon: const Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.numberOfBedrooms,
                      style: const TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minBedroomsController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.minBedrooms,
                            prefixIcon: const Icon(Icons.bed_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxBedroomsController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.maxBedrooms,
                            prefixIcon: const Icon(Icons.bed_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.desiredAmenities,
                      style: const TextStyle(fontSize: 16)),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.parking),
                    value: _parking,
                    onChanged: (value) {
                      setState(() {
                        _parking = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.gym),
                    value: _gym,
                    onChanged: (value) {
                      setState(() {
                        _gym = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.swimmingPool),
                    value: _swimmingPool,
                    onChanged: (value) {
                      setState(() {
                        _swimmingPool = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.additionalRequirements,
                      style: const TextStyle(fontSize: 16)),
                  TextFormField(
                    controller: _additionalRequirementsController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterAdditionalRequirements,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498db),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: _savePreferences,
                          child: Text(AppLocalizations.of(context)!.savePreferences),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
