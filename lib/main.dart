import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cycle_log_provider.dart';
import 'providers/device_provider.dart';
import 'providers/notification_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/dashboard/today_dashboard.dart';
import 'screens/chat/ai_chat_screen.dart';
import 'screens/tracking/cycle_tracking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/device/devices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 APP STARTING');

  // Load .env (optional)
  try {
    await dotenv.load(fileName: ".env").timeout(
      const Duration(seconds: 3),
      onTimeout: () => throw Exception('.env load timeout'),
    );
    print('✅ .env loaded');
  } catch (e) {
    print('⚠️ .env not loaded (optional)');
  }

  // Initialize Firebase with longer timeout and graceful failure
  bool firebaseReady = false;
  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
    );
    firebaseReady = true;
    print('✅ Firebase initialized');
  } on TimeoutException catch (e) {
    print('⚠️ Firebase init timeout - running in offline mode');
    firebaseReady = false;
  } catch (e) {
    print('⚠️ Firebase failed: $e - running in offline mode');
    firebaseReady = false;
  }

  print('🎨 Running app...');
  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatelessWidget {
  final bool firebaseReady;
  const MyApp({super.key, required this.firebaseReady});

  static const Color darkBg = Color(0xFF111111);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CycleLogProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: darkBg,
          cardColor: cardBg,
          primaryColor: accent,
          colorScheme: const ColorScheme.dark(
            primary: accent,
            surface: cardBg,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: darkBg,
            elevation: 0,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            selectedItemColor: accent,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: firebaseReady ? const AuthWrapper() : const OfflineHomeScreen(),
      ),
    );
  }
}

// Offline home screen when Firebase fails
class OfflineHomeScreen extends StatelessWidget {
  const OfflineHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Health Tracker', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Colors.orange, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Offline Mode',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase is not connected. Please check your internet connection and restart the app.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  runApp(const MyApp(firebaseReady: true));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Retry Connection', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final status = auth.status;

    switch (status) {
      case AuthStatus.uninitialized:
      case AuthStatus.initializing:
      case AuthStatus.authenticating:
        return const _LoadingScreen();

      case AuthStatus.unauthenticated:
        return const LoginScreen();

      case AuthStatus.registering:
        return const _LoadingScreen();

      case AuthStatus.authenticated:
        if (auth.appUser?.profileComplete == false) {
          return const ProfileSetupScreen();
        }
        return const MainNavigation();
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF97316)),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final isFemale = auth.appUser?.gender == 'female';

      setState(() {
        if (isFemale) {
          _screens = const [
            TodayDashboard(),
            AiChatScreen(),
            DevicesScreen(),
            CycleTrackingScreen(),
            ProfileScreen(),
          ];
          _navItems = const [
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'AI Coach'),
            BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Devices'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Cycle'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ];
        } else {
          _screens = const [
            TodayDashboard(),
            AiChatScreen(),
            DevicesScreen(),
            ProfileScreen(),
          ];
          _navItems = const [
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'AI Coach'),
            BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Devices'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF1A1A1A),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFF97316),
            unselectedItemColor: Colors.grey,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}