import 'package:eldercare/providers/clinic_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/health_log_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/profile_provider.dart';

import 'screens/login_page.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(),
          update: (_, auth, p) {
            p!.bindUser(auth.user?.uid);
            return p;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, MedicationProvider>(
          create: (_) => MedicationProvider(),
          update: (_, auth, p) {
            p!.bindUser(auth.user?.uid);
            return p;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, HealthLogProvider>(
          create: (_) => HealthLogProvider(),
          update: (_, auth, p) {
            p!.bindUser(auth.user?.uid);
            return p;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, ClinicProvider>(
          create: (_) => ClinicProvider(),
          update: (_, auth, clinic) {
            clinic ??= ClinicProvider();
            clinic.bindUser(auth.user?.uid);
            return clinic;
          },
        ),
      ],

      
      child: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          final isDark = profile.darkMode;

          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Light base theme, but override scaffold/bg + bottom nav
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,

              // background becomes dark when toggle ON
              scaffoldBackgroundColor:
                  isDark ? const Color(0xFF121212) : const Color(0xFFF7F7FB),

              // Bottom Nav dark + icons white in dark mode
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                selectedItemColor:
                    isDark ? Colors.white : const Color(0xFF1F3CFF),
                unselectedItemColor:
                    isDark ? Colors.white70 : Colors.black45,
              ),
            ),

            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.user == null
                    ? const LoginPage()
                    : const HomePage();
              },
            ),
          );
        },
      ),
    );
  }
}
