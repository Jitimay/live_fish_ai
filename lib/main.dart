import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_fish_ai/features/nav/view/nav_view.dart';
import 'package:live_fish_ai/features/onboarding/view/onboarding_view.dart';
import 'package:live_fish_ai/features/splash/view/splash_view.dart';
import 'package:live_fish_ai/services/tflite_service.dart';
import 'package:live_fish_ai/models/fish_catch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_fish_ai/theme/app_theme.dart'; // Import the AppTheme

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FishCatchAdapter());
  await Hive.openBox<FishCatch>('fish_catches');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TfliteService(),
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool _initialized = false;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load model
    await context.read<TfliteService>().loadModel();

    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _initialized = true;
      _onboardingCompleted = onboardingCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveFish AI',
      theme: AppTheme.theme, // Use the custom theme
      home: _initialized
          ? (_onboardingCompleted ? const NavView() : const OnboardingView())
          : const SplashView(),
    );
  }
}

