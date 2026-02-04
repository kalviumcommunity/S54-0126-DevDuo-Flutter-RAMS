import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// AUTH
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/dashboard_screen.dart';

// ATTENDANCE
import 'features/attendance/screens/attendance_screen.dart';

// STUDENTS
import 'features/students/screens/students_screen.dart';
import 'features/students/screens/student_details_screen.dart';
import 'features/students/screens/add_student_screen.dart'; // ✅ ADDED

// CORE
import 'core/constants/app_colors.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/theme_toggle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final controller =
      ThemeController(isDark ? ThemeMode.dark : ThemeMode.light);

  runApp(
    ThemeControllerProvider(
      controller: controller,
      child: MyApp(controller: controller),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController controller;
  const MyApp({required this.controller, super.key});

  ThemeData _lightTheme() => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 1,
        ),
        cardColor: Colors.white,
        dividerColor: AppColors.border,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      );

  ThemeData _darkTheme() => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textLight,
          elevation: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.borderDark,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textLight),
          bodyMedium: TextStyle(color: AppColors.textLight),
          bodySmall: TextStyle(color: AppColors.textSecondaryDark),
          titleLarge: TextStyle(color: AppColors.textLight),
          titleMedium: TextStyle(color: AppColors.textLight),
          titleSmall: TextStyle(color: AppColors.textLight),
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          hintStyle:
              const TextStyle(color: AppColors.textSecondaryDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primaryDark),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.cardDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          brightness: Brightness.dark,
          surface: AppColors.surfaceDark,
          background: AppColors.backgroundDark,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RAMS',
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: controller.mode,

          // ✅ ROUTES (UPDATED)
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/attendance': (context) => const AttendanceScreen(),
            '/students': (context) => const StudentsScreen(),
            '/student-details': (context) =>
                const StudentDetailsScreen(),

            // ✅ ADD STUDENT ROUTE
            '/add-student': (context) =>
                const AddStudentScreen(),
          },

          home: const LoginScreen(),
        );
      },
    );
  }
}
