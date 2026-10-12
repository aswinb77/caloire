import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/mallow_theme.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI on desktop platforms (macOS, Linux, Windows)
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      debugPrint('SQLite FFI initialization error: $e');
    }
  }

  bool hasCompletedOnboarding = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    hasCompletedOnboarding = prefs.getBool('mallow_onboarded') ?? false;
  } catch (e) {
    debugPrint('SharedPreferences read error: $e');
  }

  final initialLocation = hasCompletedOnboarding ? '/today' : '/onboarding';

  runApp(
    ProviderScope(
      child: MallowApp(initialLocation: initialLocation),
    ),
  );
}


class MallowApp extends StatefulWidget {
  final String initialLocation;

  const MallowApp({super.key, this.initialLocation = '/onboarding'});

  @override
  State<MallowApp> createState() => _MallowAppState();
}

class _MallowAppState extends State<MallowApp> {
  late final router = createMallowRouter(initialLocation: widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mallow',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MallowColors.creamBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MallowColors.hotPink,
          primary: MallowColors.hotPink,
          secondary: MallowColors.oliveGreen,
          surface: MallowColors.creamBg,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
    );
  }
}
