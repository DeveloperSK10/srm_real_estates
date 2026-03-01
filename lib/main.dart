import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/property_preferences_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/user_home_screen.dart';
import 'package:myapp/screens/admin/admin_home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/language_selection_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language_selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/property_preferences',
      builder: (context, state) => const PropertyPreferencesScreen(),
    ),
    GoRoute(
      path: '/user_home',
      builder: (context, state) => const UserHomeScreen(),
    ),
    GoRoute(
      path: '/admin_home',
      builder: (context, state) => const AdminHomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp.router(
            title: 'SRM Real Estates',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            locale: provider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ta'), // Tamil
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
