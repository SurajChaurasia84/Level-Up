import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/achievements_screen.dart';
import 'widgets/add_habit_modal.dart';
import 'services/notification_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("[Main] App starting, initializing services...");
    
    // Set up release-mode error widget to prevent black screen on crashes
    ErrorWidget.builder = (FlutterErrorDetails details) {
      debugPrint("[Main] Caught UI error: ${details.exception}");
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF1F4F8),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFF4B39EF), size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Oops! Something went wrong",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "The app encountered an error. Please try restarting it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF57636C)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B39EF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Close App"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    // Await initialization with a timeout to ensure permission prompt shows up
    // but prevents black screen if it hangs.
    try {
      await NotificationService().init().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint("[Main] NotificationService initialization timed out after 3s");
        },
      );
    } catch (e) {
      debugPrint("[Main] ERROR: NotificationService failed to initialize: $e");
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    
    debugPrint("[Main] Initial services ready, calling runApp...");
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HabitProvider()),
        ],
        child: const LevelUpApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("[Main] CRITICAL STARTUP ERROR: $e");
    debugPrint(stack.toString());
    // Still try to run the app even if something above failed
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HabitProvider()),
        ],
        child: const LevelUpApp(),
      ),
    );
  }
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Level Up',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: provider.isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (provider.hasSeenOnboarding ? const MainNavigation() : const OnboardingScreen()),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    StatsScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        color: Colors.white,
        padding: EdgeInsets.zero,
        height: 70, // Fixed height to prevent overflow
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF14181B),
          unselectedItemColor: const Color(0xFF57636C),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 22,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Today'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Achievements'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddHabitModal(),
          );
        },
        backgroundColor: const Color(0xFF14181B),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
